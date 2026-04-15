# openplatform_v3 포트 할당표

상위 문서: `C:\claude\docker-info.xml`, `C:\claude\port-change-report.md`

## v3 전용 대역
- **주력**: 19xxx
- **UI dev**: 25174 (Vite, ts-spring-fw 25xxx와 비충돌)

## 인프라
| 서비스 | 호스트 포트 | 컨테이너 포트 | 비고 |
|---|---|---|---|
| PostgreSQL (v3 main DB) | 19432 | 5432 | platform_v3, flowable_v3 스키마 |
| Redis (v3 cache/pub-sub) | 19379 | 6379 | |
| Keycloak | 19281 | 8080 | realm `openplatform-v3` |
| MinIO API | 19900 | 9000 | bucket `platform-v3` |
| MinIO Console | 19901 | 9001 | |

## 백엔드
| 서비스 | 호스트 포트 | 비고 |
|---|---|---|
| backend-core | 19090 | Spring Boot, DataSet 진입점 `/api/dataset/*` |
| backend-bff | 19091 | Port-Adapter 프록시 `/api/bff/*` |

## 외부 그룹웨어 서비스 (v3 전용)
| 서비스 | 호스트 포트 | 비고 |
|---|---|---|
| Rocket.Chat | 19065 | Custom OAuth keycloak provider → Keycloak SSO |
| Stalwart SMTP | 19025 | |
| Stalwart IMAP | 19143 | |
| Stalwart Admin | 19480 | |
| LiveKit | 19880 | JWT 발급은 BFF 경유 |
| Wiki.js | 19001 | OIDC |

## UI
| 서비스 | 포트 | 비고 |
|---|---|---|
| Vite dev server | 25174 | `npm run dev` |
| UI nginx (prod) | 19173 | 빌드 산출물 서빙 |

## 충돌 회피 참조
- v1 (openplatform): 17xxx
- v2 (openplatform_v2): 18xxx
- ts-spring-fw: 25xxx (원본 사용 시)
- v3 (openplatform_v3): 19xxx + 25174 (UI dev)

`C:\claude\docker-info.xml` 의 `<project name="openplatform_v3">` 블록과 동기화 유지.
