# readme_db — 다른 PC 에서 openplatform_v3 DB 재현 절차

이 문서는 **새 PC** 에 openplatform_v3 의 DB 상태(스키마 + 데이터) 를 그대로 복제하기 위한
end-to-end 절차이다. 원본 PC 에서 미리 받아둔 dump 가 git 에 이미 포함되어 있으므로,
별도 파일 전송 없이 `git pull` → `restore-all` 한 번으로 끝난다.

> 스크립트 자체와 옵션 상세는 `infra/db-merge/README.md` 참조. 본 문서는 절차 중심.

---

## 0. 사전 준비

| 항목 | 요구사항 |
|---|---|
| Git | 2.40+ |
| Docker | Docker Desktop 4.x 이상 (Windows/macOS) 또는 docker engine 24+ (Linux) |
| docker compose v2 | `docker compose version` 으로 확인 |
| 디스크 | 최소 10 GB 여유 (이미지 + 볼륨) |
| 호스트 포트 | `19xxx` 대역 사용. `19432`, `19379`, `19281`, `19090`, `19091`, `19173` 등이 비어있어야 함 |
| traefik-net 네트워크 | 워크스페이스 표준 외부 네트워크. 없으면 아래 1-b 단계 |

Windows 의 경우 추가:
- WSL2 + Docker Desktop 의 WSL integration 이 활성화되어 있을 것
- PowerShell 5.1 또는 7+

---

## 1. 저장소 동기화

```bash
git clone https://github.com/choi-hyun-su-77/openplatform_v3.git C:/claude/openplatform_v3
cd C:/claude/openplatform_v3
git pull
```

작업 위치가 다르면 경로만 바꾸면 된다.

확인:
```bash
ls infra/db-merge/dumps/
# 다음이 모두 있어야 함:
#   MANIFEST.json
#   postgres-globals.sql
#   postgres-platform_v3.dump
#   postgres-wiki_v3.dump
#   mongo-all.archive.gz
```

### 1-b. traefik-net 외부 네트워크 (없을 때만)

```bash
docker network ls | grep traefik-net || docker network create traefik-net
```

---

## 2. 인프라 기동

```powershell
# Windows PowerShell
docker compose -f infra\docker-compose.yml up -d
```
```bash
# bash / zsh
docker compose -f infra/docker-compose.yml up -d
```

기동까지 보통 1–2 분. 다음이 모두 healthy/running 이 되어야 함:

```bash
docker ps --filter "name=v3-" --format "table {{.Names}}\t{{.Status}}"
# v3-postgres   Up ... (healthy)
# v3-redis      Up ... (healthy)
# v3-mongo      Up ...
# v3-keycloak   Up ...
# v3-minio      Up ... (healthy)
# v3-backend-core  Up ...
# v3-backend-bff   Up ...
# v3-ui-frontend   Up ...
# v3-rocketchat / v3-wikijs / v3-stalwart / v3-livekit ...
```

> `v3-openldap` 이 재시작 루프인 것은 알려진 별개 이슈(LDIF seed) 로 DB 복원과 무관.

### 2-a. MongoDB replicaSet 초기화 (최초 1 회)

`v3-mongo` 는 `--replSet rs0` 으로 기동되므로 첫 부팅 시 한 번만 init 필요.

```bash
docker exec v3-mongo mongosh --quiet --eval \
  "rs.initiate({_id:'rs0', members:[{_id:0, host:'mongo:27017'}]})"
# 결과: { ok: 1 }
```

이미 init 되어 있으면 `already initialized` 메시지가 나오며 무시해도 된다.
상태 확인:
```bash
docker exec v3-mongo mongosh --quiet --eval "rs.status().myState"
# 1 (PRIMARY) 면 정상
```

---

## 3. DB 복원

```powershell
# Windows PowerShell — 빈 DB 에 안전 import
infra\db-merge\restore-all.ps1

# 이미 데이터가 있는 경우 강제 덮어쓰기
infra\db-merge\restore-all.ps1 -Force
```
```bash
# bash
bash infra/db-merge/restore-all.sh

# 강제 덮어쓰기
bash infra/db-merge/restore-all.sh --force
```

스크립트 동작 순서:
1. `postgres-globals.sql` 적용 — 기본 ROLE 등 (이미 존재해도 무시)
2. `postgres-platform_v3.dump` → `pg_restore --clean --if-exists --no-owner` 로 import
3. `postgres-wiki_v3.dump` → 동일 방식
4. `mongo-all.archive.gz` → `mongorestore --gzip --drop --nsExclude='admin.*|config.*|local.*'`

> Postgres 의 `--clean --if-exists` 는 매 객체를 drop 후 재생성한다. 따라서 `-Force` 없이도
> 기존 객체와 충돌하지 않는다. `-Force` 는 "테이블이 1개라도 있으면 skip" 가드를 끄는 용도.

---

## 4. 복원 확인

```bash
# Postgres: 188 개 정도가 정상
docker exec v3-postgres psql -U platform_v3 -d platform_v3 -c \
  "SELECT count(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') AND table_type='BASE TABLE'"

# Wiki.js DB
docker exec v3-postgres psql -U platform_v3 -d wiki_v3 -c \
  "SELECT count(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema')"

# 로그 테이블은 스키마만 있고 데이터는 비어있어야 함
docker exec v3-postgres psql -U platform_v3 -d platform_v3 -c \
  "SELECT count(*) FROM keycloak_v3.event_entity"   # 0 이어야 정상

# Mongo
docker exec v3-mongo mongosh --quiet --eval \
  "db.getSiblingDB('rocketchat').getCollectionNames().length"
```

### 4-a. dump 무결성 체크 (선택)

```powershell
# PowerShell — MANIFEST 의 SHA256 과 비교
$m = Get-Content infra\db-merge\dumps\MANIFEST.json -Raw | ConvertFrom-Json
foreach ($f in $m.files) {
    $h = (Get-FileHash -Algorithm SHA256 "infra\db-merge\dumps\$($f.name)").Hash.ToLower()
    if ($h -ne $f.sha256) { Write-Host "MISMATCH: $($f.name)" -ForegroundColor Red }
    else { Write-Host "OK: $($f.name)" }
}
```
```bash
# bash
cd infra/db-merge/dumps
sha256sum -c <(jq -r '.files[] | "\(.sha256)  \(.name)"' MANIFEST.json)
```

---

## 5. 애플리케이션 가동 확인

| URL | 기대 |
|---|---|
| http://localhost:19281/realms/openplatform-v3 | Keycloak realm 페이지 |
| http://localhost:19090/actuator/health | backend-core `{ "status": "UP" }` |
| http://localhost:19091/actuator/health | backend-bff `{ "status": "UP" }` |
| http://localhost:19173 | UI 정적 빌드 (nginx) |
| http://localhost:19065 | Rocket.Chat — 기존 admin 계정 (v3admin / Admin1234!) 로 로그인 |
| http://localhost:19001 | Wiki.js — 복원된 페이지/계정 |
| http://localhost:19901 | MinIO Console |

---

## 6. 새 dump 만들기 (원본 PC 에서)

데이터가 변경되어 다시 배포가 필요할 때:

```powershell
infra\db-merge\dump-all.ps1
git add infra/db-merge/dumps
git commit -m "chore(db-merge): refresh dumps"
git push
```

다른 PC 는 `git pull` 후 `restore-all -Force` 한 번이면 동기화 완료.

---

## 7. 트러블슈팅

| 증상 | 조치 |
|---|---|
| `docker ... 500 Internal Server Error` | Docker Desktop 재시작 또는 `wsl --shutdown` 후 Docker Desktop 자동 복구 대기 |
| `node is not in primary or recovering state` | 2-a 의 rs.initiate 미수행 — 한 번만 실행 |
| `pg_restore: error: ... permission denied for schema` | `postgres-globals.sql` 가 적용되지 않음. 직접 import: `docker exec -i v3-postgres psql -U platform_v3 -d postgres < infra/db-merge/dumps/postgres-globals.sql` |
| `port already allocated` | 19xxx 대역 충돌. 다른 워크스페이스 컨테이너를 stop 하거나 compose 의 호스트 포트 변경 |
| Keycloak 로그인 후 redirect_uri 오류 | Keycloak realm 의 client redirect URI 가 새 PC 호스트와 맞지 않음. realm 설정에서 redirect URIs 보정 |
| restore 후 mongo 컬렉션이 비어있음 | `mongorestore` 가 `--nsExclude` 로 엉뚱한 DB 를 막았을 가능성. mongo archive 는 user DB 만 매칭되도록 검증된 패턴이지만 변형이 필요하면 `restore-all.{ps1,sh}` 의 `--nsExclude` 인자 수정 |

---

## 8. 보안 주의 (중요)

- dump 파일에는 **현재 시점의 운영 데이터가 그대로 들어있다.** 비밀번호 hash, 세션 토큰,
  사용자 PII 등이 포함될 수 있으므로 본 저장소가 **공개되지 않은 사내/개인 저장소** 임을
  반드시 확인할 것.
- 새 PC 에서 운영 환경으로 사용한다면 `infra/docker-compose.yml` 의 dev 기본 비밀번호
  (`platform_v3_pass`, `v3_redis_pass`, `v3minio_pass`, `Admin1234!` 등) 와 Keycloak
  realm secret 들을 모두 교체해야 한다.
