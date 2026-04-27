# inventory/09_gaps.md — 갭/이상치 보고

> Phase 0.J 산출물. `warn.md` 와 동기화. Phase 1+ 진행에 영향 없는 항목.

## 1. 자동 테스트 부재
- backend-core / backend-bff 에 `src/test/java` 없음
- ui/ 에 vitest / cypress / playwright 없음
- **영향**: SOP Step 10(테스트)는 "코드베이스 컨벤션 부재 → 추가 권장" 표기로 처리
- **권장**: 추후 SpringBoot Test + Vitest 도입

## 2. MDC / correlationId 미사용
- 로깅에 traceId 없음, 분산 추적 어려움
- **영향**: 운영 로그 디버깅 시 요청 흐름 추적 곤란
- **권장**: `OncePerRequestFilter` 로 traceId MDC 주입

## 3. `@Transactional(readOnly=true)` 미사용
- 모든 read 메서드에 `@Transactional` 자체가 없음
- **영향**: 성능 기회 손실 (Hibernate 미사용이라 영향 작음)

## 4. `rollbackFor` 미지정
- Spring 기본 의존 (런타임 예외만 자동 롤백, checked 예외는 롤백 안됨)
- **영향**: 도메인 예외(`BusinessException`)는 RuntimeException 상속이라 정상 동작

## 5. 로깅 패턴 application.yml 미설정
- Logback default pattern 사용 → 운영 환경에서 ELK/Loki 연동 시 파싱 어려움
- **권장**: JSON 패턴 도입

## 6. 메뉴 라벨 i18n 자동 연결 미구현
- `cm_menu.menu_name` 에 한글 직접 저장 → `MENU_*` i18n key lookup 미연결
- **영향**: 다국어 메뉴 라벨 동작 안함
- **권장**: frontend `useI18n()` 에서 `MENU_${menuId.toUpperCase()}` 키 우선 lookup, fallback `menu_name`

## 7. backend-core 의 `RestTemplate` 직접 호출 (admin 도메인)
- 다른 도메인은 BFF 경유, admin 만 backend-core 에서 직접 Keycloak 호출
- **영향**: BFF 일원화 원칙 위반(이상치)
- **권장**: `AdminService` 의 `bffPost`/`bffPut` 호출은 유지, 직접 호출 부분은 BFF 로 이전

## 8. 명명 불일치
- `WorkReportService` ↔ `worklog/*` URL/DB
- `DataLibraryService` ↔ `datalib/*` URL/DB
- `attendance` 와 `leave` 모두 `at_` prefix 공유
- **영향**: 신규 도메인 작성 시 모범 선택 혼란 가능
- **권장**: HANDBOOK 3장(명명 규칙)에서 명시적 표기 + `inventory/04_naming.md` Section 3 참조

## 9. 모범이 부재한 형태/패턴
- 화면 형태 9 종 모두 모범 1개 이상 확보됨
- 패턴 4 종 모두 모범 1개 이상 확보됨
- **갭 없음**

## 10. 메뉴 등록 단계 8 중 1단계 비완전 자동화
- Step 7 (i18n 라벨) 은 인프라(`cm_i18n_message`)는 있으나 frontend 자동 lookup 미구현
- **영향**: 신규 메뉴 추가 시 다국어 라벨 무용 → 한글 직접 입력
- **권장**: 메뉴 SOP Step 7 을 "선택" 으로 표기 + 향후 lookup 도입 권장
