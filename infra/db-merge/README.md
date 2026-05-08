# db-merge — 다른 컴퓨터로 DB 전체 옮기기

openplatform_v3 의 모든 DB(테이블 + 데이터)를 한 번에 dump 하고, 다른 컴퓨터에서 그대로
복원할 수 있도록 하는 단일 진입점 스크립트 모음.

## 대상 데이터베이스

| 컨테이너 | DB 종류 | 대상 |
|---|---|---|
| `v3-postgres` | PostgreSQL 16 | `platform_v3` (스키마: `public`, `platform_v3`, `flowable_v3`, `keycloak_v3`), `wiki_v3` |
| `v3-mongo` | MongoDB 7 | 모든 사용자 DB (`admin`, `local`, `config` 제외 — `rocketchat` 등) |

> Redis(AOF), MinIO(오브젝트), Stalwart(메일 메타) 는 본 스크립트의 대상이 아님.
> 필요 시 docker volume 단위 백업으로 별도 처리.

## 사용 방법

### 1. 원본 컴퓨터: dump 받기

PowerShell:
```powershell
cd C:\claude\openplatform_v3
infra\db-merge\dump-all.ps1
```

또는 Linux/macOS/WSL/Git Bash:
```bash
cd /c/claude/openplatform_v3
bash infra/db-merge/dump-all.sh
```

결과 파일은 `infra/db-merge/dumps/` 에 저장됨:
- `postgres-platform_v3.dump` — pg_dump custom format (압축됨)
- `postgres-wiki_v3.dump` — pg_dump custom format
- `postgres-globals.sql` — 역할/사용자 정의 (pg_dumpall --globals-only)
- `mongo-all.archive.gz` — mongodump --archive --gzip 전체
- `MANIFEST.json` — dump 시각, 버전, 파일별 크기/SHA256

### 로그 테이블/컬렉션 제외 규칙

운영 데이터 이관 시 로그성 데이터는 부피만 차지하고 가치가 낮아 **자동 제외**된다.

기본 패턴 (정규식, 테이블/컬렉션 이름에 매칭):
```
(^|_)(log|logs|audit)($|_|s)|^event_entity$|^admin_event_entity$
```

| 대상 | 매칭 시 동작 |
|---|---|
| Postgres | `--exclude-table-data`: **스키마는 dump, 데이터만 제외**. 복원 후 빈 테이블이 됨. |
| MongoDB | `--excludeCollection`: 컬렉션 자체 제외. 복원 후 컬렉션이 존재하지 않음. |

패턴 변경:
```powershell
# PowerShell
infra\db-merge\dump-all.ps1 -ExcludeRegex '(^|_)log($|_)'
```
```bash
# Bash
EXCLUDE_REGEX='(^|_)log($|_)' bash infra/db-merge/dump-all.sh
```

제외하지 않으려면:
```bash
EXCLUDE_REGEX='__never_match__' bash infra/db-merge/dump-all.sh
```

dump 시점에 어떤 테이블/컬렉션이 제외되었는지 콘솔에 출력되며 `MANIFEST.json` 의
`excludeRegex` 에 사용한 패턴이 기록된다.

### 2. dump 파일을 git 으로 옮기기

dump-all 실행 직후 `infra/db-merge/dumps/` 가 변경됨:
```bash
git add infra/db-merge/
git commit -m "chore(db-merge): refresh DB dumps for portability"
git push
```

### 3. 대상 컴퓨터: restore

먼저 v3 인프라가 한 번이라도 기동된 상태여야 함 (DB 컨테이너 존재):
```powershell
cd C:\claude\openplatform_v3
docker compose -f infra\docker-compose.yml up -d postgres mongo
infra\db-merge\restore-all.ps1
```

또는:
```bash
docker compose -f infra/docker-compose.yml up -d postgres mongo
bash infra/db-merge/restore-all.sh
```

restore 동작:
1. `platform_v3`, `wiki_v3` DB 가 비어있는 경우(또는 `-Force`) **모든 객체를 drop** 후 재생성
2. globals(roles) 적용 → custom format dump 를 `pg_restore --clean --if-exists --no-owner` 로 import
3. mongo: `mongorestore --archive --gzip --drop` 로 컬렉션 단위 교체

### 옵션

| 스크립트 | 옵션 | 의미 |
|---|---|---|
| `dump-all.*` | (없음) | 단순 dump |
| `restore-all.ps1` | `-Force` | 데이터가 있어도 강제 덮어쓰기 |
| `restore-all.sh` | `--force` | 동일 |

## 보안 주의

- dump 파일은 **운영 데이터를 그대로 포함**한다. 비밀 키/비번/PII 가 들어 있을 수 있으므로
  공개 저장소에 푸시하지 말 것. 이 워크스페이스는 사내/개인용임을 전제로 한다.
- compose 의 DB 비번(`platform_v3_pass` 등) 은 dev 기본값이며, 운영 환경에서는 반드시 변경.

## 트러블슈팅

- `node is not in primary or recovering state` → mongo replicaSet 미초기화.
  ```bash
  docker exec v3-mongo mongosh --quiet --eval "rs.initiate({_id:'rs0',members:[{_id:0,host:'mongo:27017'}]})"
  ```
- pg_restore 가 권한 오류 → globals 가 미적용일 수 있음. `postgres-globals.sql` 을 먼저 import.
- 컨테이너가 없음 → `docker compose -f infra/docker-compose.yml up -d postgres mongo` 부터 실행.
