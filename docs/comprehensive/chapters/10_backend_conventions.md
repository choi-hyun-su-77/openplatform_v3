# 챕터 1.10 — 백엔드 규약 (Backend Conventions)

**작성 기준**: 2026-04-27 | **대상 버전**: openplatform_v3 Phase 14 | **스택**: Spring Boot 3.x + MyBatis + Flowable  
**출처**: 실측 코드 분석 (ApprovalService.java, ApprovalMapper.xml, BoardMapper.xml, common/*.java, V8__approval_and_extras.sql)

---

## 목차

1. [MyBatis 동적 SQL 규약](#1-mybatis-동적-sql-규약)
2. [DataSet 라우팅 규약 (@DataSetServiceMapping)](#2-dataset-라우팅-규약-datasetsservicemapping)
3. [UI 그리드 변경 사항 병합 (_rowType 패턴)](#3-ui-그리드-변경-사항-병합-rowtype-패턴)
4. [트랜잭션 경계 설정](#4-트랜잭션-경계-설정)
5. [응답 표준 (ApiResponse)](#5-응답-표준-apiresponse)
6. [예외 처리 (BusinessException)](#6-예외-처리-businessexception)
7. [시큐리티 컨텍스트 사용 (preferred_username → employee_no)](#7-시큐리티-컨텍스트-사용-preferred_username--employee_no)
8. [순환 의존 회피 패턴](#8-순환-의존-회피-패턴)
9. [Flyway 운영 정책](#9-flyway-운영-정책)
10. [참조](#참조)

---

## 1. MyBatis 동적 SQL 규약

### 1.1 기본 구조: parameterType=Map, resultType=Map 또는 도메인

**예: ApprovalMapper.xml 결재함 조회 (line 6~68)**

**mapper 파일의 select 요소**:
- resultType: map (소문자, 각 행을 Map<String,Object>로 반환)
- parameterType 생략: 기본값 Map
- snake_case ↔ camelCase 자동 변환 (application.yml에서 map-underscore-to-camel-case: true)

데이터베이스 drafter_no → Map 키 drafterNo로 자동 변환됨.

**동적 SQL 태그 패턴**:
- <choose>/<when>/<otherwise>: 상호배타 조건 분기 (boxType 별 WHERE)
- <if test="...">: 조건부 포함 (keyword 검색 필터)
- <foreach>: 배열 반복 (SELECT ... WHERE doc_id IN (...))

### 1.2 INSERT/UPDATE의 keyProperty 패턴

**예: ApprovalMapper.xml insertDocument (line 92~98)**

useGeneratedKeys="true" 옵션으로:
- PostgreSQL BIGSERIAL auto-increment 활성화
- keyProperty="docId": Java Map에 docId 키로 자동 채우기
- keyColumn="doc_id": DB 컬럼명

**서비스에서의 사용**:
`java
Map<String, Object> row = new HashMap<>();
row.put("docTitle", "..."); 
row.put("status", "PENDING");
approvalMapper.insertDocument(row);
Long docId = DataSetSupport.toLong(row.get("docId"));  // 자동 채워짐
`

---

## 2. DataSet 라우팅 규약 (@DataSetServiceMapping)

### 2.1 어노테이션과 메서드 시그니처

**규약**:
- 어노테이션 값: "도메인/액션" 형식 (예: approval/searchInbox)
- 메서드 시그니처 고정:
  - 인자 1: Map<String,Object> datasets (UI에서 전송한 모든 DataSet)
  - 인자 2: String currentUser (Keycloak JWT에서 추출한 employee_no)
  - 반환값: Map<String,Object> ({ "ds_xxx": { "rows": [...], "totalCount": N } } 형식)

### 2.2 입력/출력 변환 헬퍼

**DataSetSupport 유틸** (core/common/DataSetSupport.java):
`
getSearchParams(Map<String,Object>) → Map
toLong(Object) → Long
toStr(Object) → String
rows(List<?>) → Map with "rows" + "totalCount"
`

**사용 패턴**:
- 검색 파라미터 추출: DataSetSupport.getSearchParams(datasets)
- 타입 변환: toLong(...), toStr(...)
- 응답 조립: Map.of("ds_result", DataSetSupport.rows(resultList))

### 2.3 동적 라우팅 메커니즘 (ServiceRegistry)

애플리케이션 시작 시:
1. 모든 Bean을 스캔
2. @DataSetServiceMapping 어노테이션이 있는 메서드를 발견
3. serviceName → (bean, method) 매핑을 ConcurrentHashMap에 저장

호출 흐름: UI의 POST /api/dataset/search → ServiceRegistry.execute(...) → 리플렉션 호출

---

## 3. UI 그리드 변경 사항 병합 (_rowType 패턴)

### 3.1 기본 개념

UI 그리드에서 사용자가 여러 행을 수정하면, 변경 사항을 하나의 배열로 전송:
- _rowType: "C" (CREATE), "U" (UPDATE), "D" (DELETE)
- 한 페이로드에 C/U/D를 모두 묶어서 백엔드가 분기 처리

### 3.2 서비스 측 분기 로직

**예: ApprovalService.submitDocument (line 80~150)**

가장 간단한 패턴 (CREATE만 처리):
`java
@DataSetServiceMapping("approval/submitDocument")
@Transactional
public Map<String, Object> submitDocument(...) {
    Map<String, Object> ds = (Map<String, Object>) datasets.get("ds_doc");
    List<Map<String, Object>> rows = (List<Map<String, Object>>) ds.getOrDefault("rows", List.of());
    
    for (Map<String, Object> row : rows) {
        String rowType = DataSetSupport.toStr(row.get("_rowType"));
        if ("C".equals(rowType)) {
            approvalMapper.insertDocument(row);
        } else if ("U".equals(rowType)) {
            approvalMapper.updateDocument(row);
        } else if ("D".equals(rowType)) {
            approvalMapper.deleteDocument(...);
        }
    }
    return Map.of("success", true);
}
`

**규약**:
- _rowType 값은 문자열 "C"/"U"/"D"
- 실패 시 BusinessException 던지면 @Transactional이 자동 롤백
- 성공 시 영향도 정보를 응답에 포함 (선택사항)

---

## 4. 트랜잭션 경계 설정

### 4.1 @Transactional 사용 규칙

**규약**:
- SELECT만: 트랜잭션 불필요 (어노테이션 미적용)
- INSERT/UPDATE/DELETE 포함: @Transactional 필수
- 기본 격리 수준: READ_COMMITTED (Spring Boot 기본값)

**예: ApprovalService (line 80~82, 152~153, 203~204)**

submitDocument, approve, reject 모두 @Transactional 적용.

### 4.2 외부 서비스 호출 위치

**규약**: Flowable / NotificationService / BffClient 호출은 @Transactional 메서드 내에서 가능하지만, **실패 시 롤백 처리는 선택**:
- NotificationService: 알림 실패 시 warn 로그만 → 결재 자체는 유지
- BffClient: BFF 호출 실패 시 warn 로그 → 트랜잭션 계속
- LeaveService: 휴가 호출 실패 시 warn 로그 → 결재 유지

**예: ApprovalService (line 125~146)**

LeaveService.applyFromDoc 실패 시 try-catch로 warn 로그만 남기고 예외 미전파.

---

## 5. 응답 표준 (ApiResponse)

### 5.1 ApiResponse 구조 (core/common/ApiResponse.java)

record 형식:
- success: boolean
- data: T (제네릭)
- message: String
- error: ErrorDetail (code, field)
- errors: List<FieldError>

**정적 팩토리 메서드**:
- ok(T data)
- fail(String code, String message)
- validationFail(List<FieldError>)

### 5.2 성공 응답

**DataSet API 응답 예**:
`json
{
  "success": true,
  "data": {
    "ds_inbox": {
      "rows": [...],
      "totalCount": N
    }
  }
}
`

HTTP 상태 코드: 200 OK
success: true
data: DataSet 메서드 반환값 그대로

### 5.3 실패 응답

**BusinessException을 GlobalExceptionHandler가 처리**

응답 예:
`json
{
  "success": false,
  "message": "docId required",
  "error": {
    "code": "BAD_REQUEST",
    "field": "docId"
  }
}
`

**HTTP 상태 코드 매핑**:
- 404 Not Found: code: NOT_FOUND
- 400 Bad Request: code: BAD_REQUEST
- 403 Forbidden: code: FORBIDDEN
- 409 Conflict: code: DUPLICATE
- 500 Internal Server Error: code: INTERNAL_ERROR

---

## 6. 예외 처리 (BusinessException)

### 6.1 BusinessException 계층 (core/common/BusinessException.java)

`java
public class BusinessException extends RuntimeException {
    private final HttpStatus status;
    private final String errorCode;
    private final String field;

    public static BusinessException notFound(String message)
    public static BusinessException badRequest(String message, String field)
    public static BusinessException forbidden(String message)
    public static BusinessException duplicate(String message, String field)
}
`

### 6.2 서비스에서의 사용 패턴

**3단계 검증 패턴**:
1. 필수 파라미터 검증: badRequest 던지기
2. 리소스 존재 검증: notFound 던지기
3. 권한 검증: forbidden 던지기

### 6.3 GlobalExceptionHandler 통합

@RestControllerAdvice가 BusinessException을 받아서:
1. 로그 출력 (warn 레벨)
2. HTTP 상태 코드 설정
3. ApiResponse.fail(...)로 변환

모든 업무 예외는 BusinessException으로, @Transactional 메서드에서 던지면 자동 롤백.

---

## 7. 시큐리티 컨텍스트 사용 (preferred_username → employee_no)

### 7.1 JWT 토큰 → currentUser 추출

**규약** (warn.md [2026-04-16] Phase 13):
- Keycloak JWT의 preferred_username (사번, 예: E0032)을 currentUser로 사용
- DataSetController에서 JwtAuthenticationToken.getTokenAttributes()로 추출
- 모든 DataSet 메서드의 두 번째 인자로 전달

### 7.2 서비스에서의 employee_no 사용

**예: ApprovalService.searchInbox (line 51~58)**

currentUser = "E0032" (Keycloak preferred_username)
Mapper 호출 시 사용자 번호를 파라미터로 전달.

### 7.3 개선: employee_no → employee_id 매핑

필요한 경우 OrgMapper를 이용해:
- employee_no → employee_id 변환
- employee_no → employee_name 조회

예: recordHistory 메서드에서 actorNo(employee_no) 입력 시 OrgMapper.findEmployeeByNo로 employee_name 추출.

---

## 8. 순환 의존 회피 패턴

### 8.1 Setter 주입 + required=false

**상황**: ApprovalService가 LeaveService에 의존, LeaveService가 ApprovalService에 의존 (순환)

**해결책**: Setter 주입 (@Autowired(required=false)) 사용

`java
@Service
public class ApprovalService {
    private LeaveService leaveService;
    
    @Autowired(required = false)
    public void setLeaveService(LeaveService leaveService) {
        this.leaveService = leaveService;
    }
    
    // 사용 시 null-safe 처리
    if (leaveService != null && "LEAVE".equals(formCode)) {
        try {
            leaveService.applyFromDoc(...);
        } catch (Exception e) {
            log.warn("LEAVE applyFromDoc 실패: {}", e.getMessage());
        }
    }
}
`

**규약**:
- 순환 의존 발생 시 한쪽을 @Autowired(required=false) setter로 변경
- null-safe 처리 필수 (if check)
- 실패해도 트랜잭션 롤백 금지 (warn 로그만)

---

## 9. Flyway 운영 정책

### 9.1 IF NOT EXISTS + ALTER TABLE ADD COLUMN IF NOT EXISTS 양립

**규약** (V8__approval_and_extras.sql 참조):

런타임 DB와 클린 부팅 양쪽을 지원하려면:

`sql
-- CREATE TABLE IF NOT EXISTS
CREATE TABLE IF NOT EXISTS platform_v3.ap_document (...)

-- ALTER TABLE ADD COLUMN IF NOT EXISTS (추후 버전)
ALTER TABLE platform_v3.ap_document ADD COLUMN IF NOT EXISTS amount BIGINT;
`

**이유**:
- 런타임 중인 기존 DB: 이미 테이블/컬럼이 있으므로 "이미 존재" 오류 없이 스킵
- 클린 부팅: 모든 CREATE/ALTER 정상 실행
- 모든 마이그레이션이 멱등성(idempotent) 보장

### 9.2 마이그레이션 버전 분배 규칙

**Phase 14 Wave 1 기준** (warn.md [2026-04-27]):
- V10: T1 (근태/휴가)
- V11: T2 (회의실)
- V12: T3 (자료실)
- V13: T4 (업무보고)
- V14: T5 (관리)
- V15: T6 (UX)
- V16: T7 (대시보드)

각 트랙은 자신의 버전 번호만 사용. 병렬 개발 시 충돌 없음.

### 9.3 마이그레이션 설정 (application.yml)

`yaml
spring:
  flyway:
    enabled: true
    baseline-on-migrate: true
    default-schema: platform_v3
    schemas: platform_v3
    locations: classpath:db/migration
`

---

## 참조

### 소스 파일 맵

| 파일 | 라인 | 내용 |
|---|---|---|
| ApprovalService.java | 1~50 | DataSet 서비스 6개 메서드 선언 |
| ApprovalMapper.xml | 1~230 | 동적 SQL 12개 쿼리 |
| BoardMapper.xml | 1~107 | 게시판 10개 쿼리 + 댓글/첨부 |
| ApiResponse.java | 1~34 | 응답 표준 record |
| BusinessException.java | 1~36 | 예외 계층 |
| GlobalExceptionHandler.java | 1~37 | 예외 → ApiResponse 변환 |
| DataSetSupport.java | 1~40 | 입출력 헬퍼 |
| ServiceRegistry.java | 1~82 | @DataSetServiceMapping 동적 라우팅 |
| V8__approval_and_extras.sql | 1~189 | 결재 도메인 마이그레이션 |

### 외부 문서 참조

- **warn.md**: [2026-04-27] Phase 13 Identity 정규화 (preferred_username → employee_no)
- **warn.md**: [2026-04-27] T1 순환 의존 회피 (@Autowired(required=false))
- **CLAUDE.md**: 포트 대역 규칙 (19xxx)
- **approval.md**: §3~§4 DataSet API 상세 명세, DMN 결재선 규칙

---

## 이 챕터가 다루지 않은 인접 주제

1. **Flowable BPMN 고급 시나리오** — 병렬 결재, 전결, 동적 결재선. 현재 MyBatis 단순 모델만 구현 (approval.md §5 참조)
2. **JUnit/Mockito 단위 테스트** — 현재 E2E only. 챕터 1.14 "테스트 전략"에서 권장
3. **권한 체크 세부 구현** — 부서장/매니저/어드민 역할. 챕터 1.12 "보안"에서 보강
4. **UI 그리드 동작** — PrimeVue DataTable, _rowType 렌더링. 챕터 2.2 "프론트엔드 규약" 참조
5. **Redis 캐싱** — 현재 비활성. 성능 최적화 시 고려

---

**문서 끝** | 작성 기준: 2026-04-27
