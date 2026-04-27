# recipes/03_add_new_role.md — 권한 모델에 역할 추가

> Phase 5.3 산출물. 가상 시나리오: `ROLE_HR` (인사 부서 역할) 추가, 휴가 관리 화면 접근 부여.

## 사전 정보

- 신규 역할: `ROLE_HR`
- 한국어 이름: `인사`
- 부여 대상: 휴가 / 근태 / 사용자 관리 메뉴

## Phase 0.H.4 권한 모델 기반 변경 표

| 위치 | 파일 | 변경 |
|---|---|---|
| **Keycloak realm** | `infra/keycloak/realm-export.json` | `realmRoles` 배열에 `{ "name": "ROLE_HR", "description": "인사 역할" }` 추가 |
| **DB cm_role** | `V{N+1}__hr_role.sql` | `INSERT INTO cm_role (role_id, role_name) VALUES ('ROLE_HR', '인사')` |
| **DB cm_role_menu** | 동일 마이그레이션 | `INSERT INTO cm_role_menu (role_id, menu_id, can_*)` 부여 (휴가/근태/사용자) |
| **JWT Converter** | `[code: backend-core/.../SecurityConfig.java:62-75]` | (변경 없음 — 자동으로 `realm_access.roles` 변환) |
| **권한 가드** | (선택) Service 별 `requireRole("ROLE_HR")` | 신규 메서드 가드 시 |
| **UI router 가드** | `ui/src/router/index.ts` `meta.roles?` 확장 (선택) | 라우트별 다중 역할 허용 시 |
| **Sidebar 노출** | (자동 — `cm_role_menu` 따라 렌더) | 변경 없음 |

## 단계 절차

### Step 1 — Keycloak realm 에 ROLE_HR 추가

Keycloak Admin Console 에서 수동 또는 realm-export.json 업데이트:

```json
{
  "realmRoles": [
    { "name": "ROLE_USER", ... },
    { "name": "ROLE_APPROVER", ... },
    { "name": "ROLE_MANAGER", ... },
    { "name": "ROLE_ADMIN", ... },
    { "name": "ROLE_HR", "description": "인사 역할" }
  ]
}
```

reimport 또는 API 호출.

### Step 2 — DB 역할/메뉴 권한 마이그레이션

`V{N+1}__hr_role.sql`:

```sql
-- 역할 등록
INSERT INTO platform_v3.cm_role (role_id, role_name, description)
VALUES ('ROLE_HR', '인사', '휴가/근태/사용자 관리 권한')
ON CONFLICT (role_id) DO NOTHING;

-- 메뉴 권한 부여 (휴가/근태/사용자 관리)
INSERT INTO platform_v3.cm_role_menu
  (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
VALUES
  ('ROLE_HR', 'leave',       TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
  ('ROLE_HR', 'attendance',  TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
  ('ROLE_HR', 'admin_users', TRUE, TRUE, TRUE, FALSE, TRUE, TRUE)
ON CONFLICT (role_id, menu_id) DO NOTHING;
```

### Step 3 — 사용자에 역할 부여

Keycloak Admin Console 또는 API:
```
POST /admin/realms/openplatform-v3/users/{userId}/role-mappings/realm
[{ "name": "ROLE_HR" }]
```

### Step 4 — (선택) 백엔드 가드

`HrService` 같은 서비스가 새로 생기는 경우 `requireRole("ROLE_HR")` 메서드 추가:

```java
private void requireRole(String role) {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth == null || !auth.isAuthenticated())
        throw BusinessException.forbidden(role + " required");
    for (GrantedAuthority a : auth.getAuthorities())
        if (role.equals(a.getAuthority())) return;
    throw BusinessException.forbidden(role + " required");
}
```

### Step 5 — (선택) UI 다중 역할 라우트 가드

`ui/src/router/index.ts` 의 `beforeEach` 가드 확장:

```typescript
if (to.meta?.roles && Array.isArray(to.meta.roles)) {
  const roles = to.meta.roles as string[]
  if (!roles.some(r => auth.hasRole(r))) {
    return next('/403')
  }
}
```

라우트 정의 예:
```typescript
{ path: 'admin/users', component: ..., meta: { roles: ['ROLE_ADMIN', 'ROLE_HR'] } }
```

### Step 6 — 검증

1. Keycloak: 사용자에 `ROLE_HR` 부여 후 새 JWT 발급
2. JWT decode: `realm_access.roles` 에 `ROLE_HR` 포함 확인
3. UI 로그인: 사이드바 `내 업무 > 휴가` 등이 노출되는지 확인 (cm_role_menu 따라)
4. URL 직접 접근: 부여한 메뉴 OK, 미부여 메뉴 `/403`
5. ROLE_USER + ROLE_HR 동시 보유 시 권한 합집합 동작 확인

## 자기검증 체크

- [ ] Keycloak realm 에 역할 등록
- [ ] cm_role 행 추가
- [ ] cm_role_menu 행 추가 (메뉴별 can_* 명시)
- [ ] JWT 에 `realm_access.roles` 에 새 역할 포함
- [ ] 사이드바에 Step 2 의 `cm_role_menu` 에서 부여한 메뉴(예: 휴가/근태/사용자 관리)만 노출
- [ ] 미부여 메뉴 직접 URL 접근 시 `/403`
