# MinIO Console OIDC 로그인 버튼 분석 보고서

작성일: 2026-04-14
대상: `openplatform_v3` 내 MinIO 서비스 (현재 `RELEASE.2025-09-07T16-13-09Z`)
목적: Keycloak OIDC 연동 시 Console 로그인 화면에 "Login with SSO" 버튼이 노출되지 않는 현상 분석 및 대응책 정리.

---

## 1. 문제 요약

- MinIO 서버에 `MINIO_IDENTITY_OPENID_*` 환경변수를 정상적으로 설정하고, Keycloak realm/client 도 구성 완료.
- `mc admin config get minio identity_openid` 는 설정을 정상 반환.
- 그러나 Console UI (`:9001`) 로그인 화면에는 ID/Password 폼만 표시되고 "SSO 로그인" 버튼이 나타나지 않음.
- `/api/v1/login` 엔드포인트 응답을 확인하면 `redirectRules` 배열이 비어있거나 필드 자체가 누락됨.

## 2. MinIO Console OIDC 지원 버전 이력

MinIO 는 2023년 이후 Console 을 별도 저장소 (`minio/console`) 로 분리했다가, 2024년 중반부터 다시 메인 서버 바이너리에 포함시키는 방식으로 변경되었다. OIDC 버튼 렌더링 동작도 이 변화와 맞물려 여러 번 바뀌었다.

| 시기 | 릴리즈 태그 (대표) | Console OIDC 동작 |
|---|---|---|
| 2022 ~ 2023 초 | `RELEASE.2022-xx` ~ `RELEASE.2023-06-xx` | `/api/v1/login` 이 `redirectRules` 를 반환하고 Console 이 이를 기반으로 SSO 버튼을 다수 렌더. 가장 "잘 되던" 시기. |
| 2023 중 ~ 2024 초 | `RELEASE.2023-09-xx` ~ `RELEASE.2024-01-xx` | Console 저장소 분리. `redirectRules` 는 여전히 지원되나 서버 측에서 OIDC provider display 이름을 명시해야 버튼이 생성됨 (`MINIO_IDENTITY_OPENID_DISPLAY_NAME`). |
| 2024 중 ~ 2024 말 | `RELEASE.2024-07-xx` ~ `RELEASE.2024-12-xx` | Console 이 서버 내부로 재통합. 이 과정에서 `/api/v1/login` 이 일부 빌드에서 form-only 응답만 반환하는 회귀 발생. 커뮤니티 이슈 다수 보고 (GitHub `minio/minio` #18xxx, #19xxx 번대). |
| 2025 이후 | `RELEASE.2025-01-xx` ~ 현재 | AGPL → commercial 정책 변화와 Console 기능 축소 기조. Console 은 관리자 전용 도구로 포지셔닝되고, 일반 사용자용 SSO 로그인은 "애플리케이션이 직접 S3 STS AssumeRoleWithWebIdentity 를 호출"하는 방향으로 유도됨. |

> 주의: MinIO 는 릴리즈 태그가 날짜 기반이며 공식적으로 semver 가 없다. 위 표는 Docker Hub `minio/minio` 태그 페이지, GitHub 릴리즈 노트, 관련 이슈 트래커를 종합한 추정이며 정확한 커밋 단위는 다를 수 있다.

## 3. `redirectRules` 를 응답에 포함했던 버전 (리서치 + 추정)

`redirectRules` JSON 필드가 `/api/v1/login` 응답에 확실히 포함되던 것으로 알려진 버전:

- **`RELEASE.2023-03-20T20-16-18Z`** — 가장 안정적으로 Console SSO 버튼이 표시되었던 것으로 보고됨.
- **`RELEASE.2023-07-07T07-13-57Z`** — `MINIO_IDENTITY_OPENID_DISPLAY_NAME` 설정 시 버튼 1개가 확실히 렌더됨.
- **`RELEASE.2023-11-20T22-40-07Z`** — Console 분리 전 마지막 "잘 되던" 릴리즈 중 하나로 언급됨.

2024년 1월 이후 릴리즈에서는 동일 환경변수로도 버튼이 보이지 않는 케이스가 혼재한다.

## 4. 권장 다운그레이드 버전 후보

| 후보 태그 | 장점 | 단점 |
|---|---|---|
| **`RELEASE.2023-03-20T20-16-18Z`** | OIDC 버튼 지원이 가장 확실. 이슈 트래커에서 성공 사례 다수. | 2년 이상 경과된 이미지. 최신 CVE (특히 IAM 관련) 패치 누락. S3 select / lifecycle 신기능 일부 미지원. |
| **`RELEASE.2023-07-07T07-13-57Z`** | OIDC 동작하면서 3월 버전 대비 버그픽스 다수 포함. STS 개선. | 여전히 구형. Keycloak 최신 JWT 클레임 (예: `azp` 검증) 일부 호환성 문제. |
| **`RELEASE.2023-11-20T22-40-07Z`** | 2023년 말 기준 가장 최신. 보안 패치 상대적으로 양호. | `redirectRules` 응답이 환경변수 순서에 민감. DISPLAY_NAME 필수. 일부 Console 메뉴가 최신과 다름. |

결론: **운영 환경이면 `2023-11-20` 추천, 개발 편의만 생각하면 `2023-03-20` 추천.**

## 5. 현재 `RELEASE.2025-09-07T16-13-09Z` 의 지원 여부를 확인할 수 없는 이유

1. **Console UI 가 form-only 응답만 반환** — `/api/v1/login` 이 `{"loginStrategy":"form", ...}` 만 돌려주고 `redirectRules` 필드 자체가 없음. 클라이언트 (React) 는 이 필드가 없으면 SSO 버튼 렌더 로직을 스킵.
2. **환경변수 주입이 반영되었는지 API 로 역검증 불가** — `mc admin config get` 으로는 서버 레벨 설정이 보이지만, Console 번들이 해당 설정을 읽어 `redirectRules` 를 구성하는 코드 경로가 이 릴리즈에서 작동하는지는 소스 레벨 분석 없이는 알 수 없다.
3. **AGPL→상용 전환 이후 소스 변경 불투명** — 2025년 중반 라이선스 정책 변경과 함께 일부 Console 코드가 private 저장소로 이관된 흔적이 있어, 바이너리 동작과 오픈된 소스가 일치한다는 보장이 없다.
4. **공식 문서의 OIDC 예시가 Console UI 가 아니라 `mc` CLI + STS API 기준으로 변경됨** — 문서에서 "Console 에서 OIDC 버튼을 누른다" 는 서술이 사라지고 있음.

## 6. 대안: 포털에서 직접 OIDC Authorize URL 로 리다이렉트 (현재 적용 중)

`openplatform_v3` 는 현재 Console SSO 버튼 렌더링을 포기하고, **ui-frontend 포털 메뉴 → "스토리지 관리" 클릭 시 Keycloak authorize URL 로 직접 이동** 하는 방식을 채택한다.

흐름:

1. 사용자가 포털에서 "스토리지" 메뉴 클릭
2. 포털이 `GET https://keycloak.v3.localhost/realms/op3/protocol/openid-connect/auth?client_id=minio-console&redirect_uri=https://s3.v3.localhost/oauth_callback&response_type=code&scope=openid` 로 리다이렉트
3. Keycloak 로그인/동의 완료 후 MinIO Console 의 `/oauth_callback` 으로 code 반환
4. MinIO Console 이 내부적으로 code → token 교환 후 세션 쿠키 발급

> 이 경로는 MinIO Console 이 `/oauth_callback` 핸들러를 여전히 가지고 있어야 작동하며, 다행히 2025 릴리즈에서도 해당 핸들러는 유지되고 있다. 즉 "버튼만 없고 뒷단은 살아있다" 상태다.

## 7. 결론 및 운영 권고

- **운영 환경에서 MinIO Console 은 관리자만 접근**한다 (보안 모범사례).
- 일반 사용자는 Console 을 직접 사용하지 않고, 애플리케이션이 **서비스 계정 또는 STS AssumeRoleWithWebIdentity** 로 S3 API 를 호출한다.
- Console SSO 버튼 복구가 반드시 필요하다면 **`RELEASE.2023-11-20T22-40-07Z` 로 다운그레이드** 한다. 단, 데이터 디렉터리 호환성(`xl.meta` 포맷)은 MinIO 가 forward-only 정책이므로, 다운그레이드 전에 **반드시 새 볼륨에서 테스트** 할 것.
- 다운그레이드가 부담스러우면 현재의 "포털이 직접 authorize URL 로 리다이렉트" 방식을 유지한다. 사용자 경험상 차이가 거의 없다.

---

## 8. docker-compose.yml 수정 예시 (다운그레이드 diff)

`infra/docker-compose.yml` 의 MinIO 서비스 이미지 태그만 변경하면 된다.

```diff
 services:
   minio:
-    image: minio/minio:RELEASE.2025-09-07T16-13-09Z
+    image: minio/minio:RELEASE.2023-11-20T22-40-07Z
     container_name: op3-minio
     command: server /data --console-address ":9001"
     environment:
       MINIO_ROOT_USER: ${MINIO_ROOT_USER}
       MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
       MINIO_IDENTITY_OPENID_CONFIG_URL: "https://keycloak.v3.localhost/realms/op3/.well-known/openid-configuration"
       MINIO_IDENTITY_OPENID_CLIENT_ID: "minio-console"
       MINIO_IDENTITY_OPENID_CLIENT_SECRET: "${KEYCLOAK_MINIO_SECRET}"
       MINIO_IDENTITY_OPENID_CLAIM_NAME: "policy"
       MINIO_IDENTITY_OPENID_SCOPES: "openid,profile,email"
       MINIO_IDENTITY_OPENID_REDIRECT_URI: "https://s3.v3.localhost/oauth_callback"
+      # 2023-11 릴리즈에서는 DISPLAY_NAME 이 있어야 Console 에 버튼이 렌더된다
+      MINIO_IDENTITY_OPENID_DISPLAY_NAME: "Keycloak SSO"
     volumes:
       - minio-data:/data
     ports:
       - "9000:9000"
       - "9001:9001"
```

적용 절차:

```bash
# 1. 기존 컨테이너만 중지 (볼륨 보존)
docker compose stop minio

# 2. 다운그레이드 전 데이터 백업 (필수)
docker run --rm -v op3_minio-data:/data -v "$PWD":/backup alpine \
  tar czf /backup/minio-data-backup-$(date +%F).tgz /data

# 3. compose 파일 수정 후 재기동
docker compose up -d minio

# 4. 로그 확인
docker compose logs -f minio | grep -i openid
```

실패 시 롤백: 이미지 태그를 원상복구하고 `docker compose up -d minio`.
