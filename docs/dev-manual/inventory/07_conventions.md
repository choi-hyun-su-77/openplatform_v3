# inventory/07_conventions.md — 표준 컨벤션 (응답·로깅·에러·권한·테스트·AOP·트랜잭션)

> Phase 0.H 산출물. 모든 SOP 의 "표준 응답·로깅·예외·권한 컨벤션 적용" Step 의 1차 정보원.

## 1. 표준 응답 봉투

| 항목 | 사실 |
|---|---|
| 래퍼 | `ApiResponse<T>` record 5 fields | `[code: backend-core/src/main/java/com/platform/v3/core/common/ApiResponse.java:5-34]` |
| 필드 | `success`, `data`, `message`, `error`, `errors` |
| 팩토리 | `ok(data)`, `ok(data, message)`, `fail(code, message)`, `validationFail(errors)` |
| 사용처 | `DataSetController`, `CodeController`, `NotificationController`, `I18nController` |
| 상태 매핑 | `BusinessException` 이 `HttpStatus` 보유, GlobalExceptionHandler 가 매핑 |

```java
// 예시 — DataSetController
@PostMapping("/search")
public ApiResponse<Map<String, Object>> search(
    @RequestBody Map<String, Object> body,
    Authentication authentication
) {
    return ApiResponse.ok(dataSetService.search(serviceName, datasets, user));
}
```
출처: `[code: backend-core/.../DataSetController.java:32-41]`

## 2. 로깅 컨벤션

| 항목 | 사실 |
|---|---|
| backend-core 레벨 | `com.platform.v3: DEBUG`, `org.springframework.security: INFO` | `[code: backend-core/src/main/resources/application.yml:92-96]` |
| backend-bff 레벨 | `com.platform.v3.bff: DEBUG` | `[code: backend-bff/src/main/resources/application.yml:56-59]` |
| 패턴 | SLF4J + Logger per class (default Logback pattern) |
| 공용 키 | `username`, `employee_no`, `serviceName`, `keyword` |
| MDC/correlationId | **갭 — 없음** |
| JWT 정규화 로그 | `currentUser 정규화: {} → {}` | `[code: backend-core/.../DataSetController.java:105]` |
| Fallback 로그 | normalization 실패 시 username 그대로 사용 로깅 | `[code: DataSetController.java:110]` |

> 갭(`warn.md`): MDC/traceId 미사용. 분산 추적이 필요하면 도입 필요.

## 3. 예외/에러 매핑

| 예외 타입 | HTTP 상태 | 응답 |
|---|---|---|
| `BusinessException` | 예외에 임베디드 `HttpStatus` | `ApiResponse.fail(code, message, field)` |
| `MethodArgumentNotValidException` | 400 Bad Request | `ApiResponse.validationFail(errors)` |
| 일반 `Exception` | 500 Internal Server Error | `ApiResponse.fail("INTERNAL_ERROR", "...")` |

`BusinessException` 팩토리 메서드:
- `notFound(message)` → 404 NOT_FOUND
- `duplicate(message, field)` → 409 CONFLICT
- `forbidden(message)` → 403 FORBIDDEN
- `badRequest(message, field)` → 400 BAD_REQUEST

출처:
- `[code: backend-core/.../GlobalExceptionHandler.java:12-37]`
- `[code: backend-core/.../BusinessException.java:5-36]`

## 4. 권한 모델

| 항목 | 사실 |
|---|---|
| 역할 | 4 realm role: `ROLE_USER`, `ROLE_APPROVER`, `ROLE_MANAGER`, `ROLE_ADMIN` |
| 역할 source | Keycloak JWT `realm_access.roles` → Spring `GrantedAuthority` 변환 |
| Admin 가드 | 메서드 레벨 `requireAdmin()` |
| 인증 모델 | OAuth2 Resource Server, stateless (no session) |
| JWT → 사번 해석 | `DataSetController.currentUser()` 가 `preferred_username → org_employee.keycloak_user_id → employee_no` 변환 |
| Keycloak realm | `openplatform-v3` (`[code: infra/keycloak/realm-export.json]`) |

JWT Authority Converter:
```java
converter.setJwtGrantedAuthoritiesConverter(jwt -> {
    var authorities = new ArrayList<GrantedAuthority>();
    Map<String, Object> realmAccess = jwt.getClaimAsMap("realm_access");
    if (realmAccess != null && realmAccess.get("roles") instanceof List<?> roles) {
        for (Object role : roles) {
            authorities.add(new SimpleGrantedAuthority(
                "ROLE_" + role.toString().replaceFirst("^ROLE_", "")
            ));
        }
    }
    return authorities;
});
```
출처: `[code: backend-core/.../SecurityConfig.java:62-75]`

`requireAdmin()`:
```java
private void requireAdmin() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth == null || !auth.isAuthenticated())
        throw BusinessException.forbidden("ROLE_ADMIN required");
    for (GrantedAuthority a : auth.getAuthorities())
        if ("ROLE_ADMIN".equals(a.getAuthority())) return;
    throw BusinessException.forbidden("ROLE_ADMIN required");
}
```
출처: `[code: backend-core/.../admin/AdminService.java:400-410]`

## 5. AOP 감사 (`AdminAuditAspect`)

| 항목 | 사실 |
|---|---|
| 트리거 | `@DataSetServiceMapping` 어노테이션 + `admin/*` serviceName |
| 우선순위 | `@Order(100)` |
| 테이블 | `sa_audit` (audit_id, actor_no, actor_name, action, target_type, target_id, before_json, after_json, ip_addr, acted_at) | `[code: V14__admin_audit.sql:7-18]` |
| 인터셉트 데이터 | 입력 datasets(before_json), 반환값(after_json), SecurityContext actor, HttpServletRequest IP |
| JSON 최대 길이 | 16KB, 초과 시 `__truncated` 마커 |
| 실패 처리 | JSON 직렬화 실패해도 원래 결과 영향 없음 |

워크플로:
1. `@DataSetServiceMapping` 메서드 인터셉트
2. `admin/*` 만 필터링
3. 정상 실행(예외는 그대로 전파, 감사 미기록)
4. 성공 시 serviceName / datasets / currentUser 추출
5. `adminMapper.insertAudit()`

출처: `[code: backend-core/.../admin/AdminAuditAspect.java:48-95]`

## 6. 테스트

| 항목 | 사실 |
|---|---|
| 단위 테스트 | **갭 — `src/test/java` 디렉토리 부재 (backend-core, backend-bff)** |
| 통합 테스트 | **갭 — 없음** |
| UI 테스트 (vitest/cypress/playwright) | **갭 — `ui/` 에 테스트 파일 없음** |
| 의존성 | JUnit/Mockito 미참조 |

> warn.md 기록: 자동 테스트 부재 → SOP 의 Step 10(테스트)는 "코드베이스 컨벤션 부재 → 추가 권장" 으로 표기.

## 7. 트랜잭션

| 항목 | 사실 |
|---|---|
| `@Transactional` 적용 위치 | write-heavy(insert/update/delete) 서비스 메서드 |
| 기본 동작 | `Propagation.REQUIRED`, PostgreSQL READ_COMMITTED |
| `readOnly=true` | **갭 — 미사용** (성능 기회) |
| `rollbackFor` | **갭 — 미지정**, Spring 기본(런타임 예외 자동 롤백) 의존 |
| 사례 | `userSave()`, `submitDocument()`, `approveDocument()`, `rejectDocument()` |
| 읽기 메서드 | `userList()`, `searchDetail()`, `searchFormTemplates()` 등은 `@Transactional` 없음 |

출처: `[code: backend-core/.../admin/AdminService.java:81]` (write), `[code: backend-core/.../admin/AdminService.java:66]` (read)

## 8. 컨벤션 체크리스트 (SOP 자기검증용)

- [ ] Controller → `ApiResponse.ok(...)` 또는 `fail(...)` 으로 래핑
- [ ] Service write → `@Transactional` 명시
- [ ] 권한 분기 → `requireAdmin()` 또는 `verifyDocAccess()` (Pattern B)
- [ ] 비즈니스 예외 → `BusinessException.notFound/duplicate/forbidden/badRequest`
- [ ] 감사 대상 → `@DataSetServiceMapping("admin/*")` 패턴 사용 → `AdminAuditAspect` 자동 적용
- [ ] 로깅 → SLF4J Logger per class, currentUser/serviceName 키 포함
- [ ] (갭 — 권장) MDC traceId, `readOnly=true` (read-only methods), `rollbackFor` 지정

## 9. 명시적 갭 정리 (warn.md 후보)

1. 자동 테스트 부재 (unit/integration/e2e)
2. MDC/correlationId 미사용 (분산 추적 어려움)
3. `@Transactional(readOnly=true)` 미사용 (성능 기회)
4. `rollbackFor` 미지정 (Spring 기본 의존)
5. 로깅 패턴 application.yml 미설정 (Logback default 사용)
6. 메뉴 라벨 i18n 자동 연결 미구현 (`cm_menu.menu_name` 직접 저장)
