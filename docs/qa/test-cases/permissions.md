# TC-PERM — 권한 매트릭스

| 항목 | 값 |
|---|---|
| spec | `ui/tests/e2e/specs/23-permissions.spec.ts` |
| 의존 | `auth.ts.menus` (역할별 동적 로드), router beforeEach 의 `requiresAdmin/canRead` 가드 |

## 케이스 (admin)

| ID | 시나리오 | 기대 | 상태 |
|---|---|---|---|
| TC-PERM-NO-403-DASHBOARD | admin → /dashboard | URL not /403 | ⏳ |
| TC-PERM-NO-403-ADMIN-USERS | admin → /admin/users | URL not /403 | ⏳ |

## 추가 진행 후보 (별도 storageState — user1/user1)

- TC-PERM-USER-403-ADMIN-USERS — ROLE_USER 가 /admin/users 진입 → /403 redirect
- TC-PERM-USER-403-ADMIN-AUDIT — /admin/audit → /403
- TC-PERM-USER-OK-APPROVAL — /approval 정상 진입
- TC-PERM-USER-NO-CREATE — `[추가]` 등 canCreate=false 시 비표시
- TC-PERM-MGR-OK-LEAVE — ROLE_MANAGER 가 /leave 정상

## 비고

`directAccessGrantsEnabled=false` 운영 정책으로 user1 의 storageState 는 setup spec 의 user별 분기로 1회 생성 후 캐시 권장.
