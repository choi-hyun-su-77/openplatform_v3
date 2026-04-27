# Chapter 1.9 — Backend Architecture: Hybrid Pattern (DataSet + Port-Adapter)

**작성 일자**: 2026-04-27  
**범위**: ackend-core (Stack A) + ackend-bff (Stack B)  
**핵심**: 16개 도메인의 DataSet 라우팅(core) ↔ 6개 외부 서비스의 Port-Adapter 페더레이션(bff)

---

## 1. 하이브리드 아키텍처 개요

v3 백엔드는 **두 개의 Spring Boot 애플리케이션**으로 구성되며, 각각 다른 아키텍처 패턴을 채용합니다.

| 계층 | 애플리케이션 | 패턴 | 포트 | 역할 |
|------|------------|------|------|------|
| **Domain Logic** | `backend-core` | DataSet 라우팅 + 도메인 서비스 | 19090 | 결재·게시판·인사 등 16개 도메인의 비즈니스 로직 |
| **Federation** | `backend-bff` | Port-Adapter (Hexagonal) | 19091 | Keycloak·RocketChat·MinIO 등 외부 서비스 통합 |

**흐름**:
\\\
Vue 포탈
  ↓
POST /api/dataset/{method}        (backend-core:19090)
  ├─→ DataSetController
  ├─→ ServiceRegistry (annotation-driven dispatch)
  └─→ @DataSetServiceMapping("domain/method") Service
       └─→ DB (PostgreSQL + MyBatis)

GET /api/bff/*                    (backend-bff:19091)
  ├─→ BffController
  ├─→ Port (interface)
  └─→ Adapter (구현체)
       └─→ 외부 서비스 (Keycloak/RocketChat/MinIO/Stalwart/Wiki.js/LiveKit)
\\\

---

## 2. Pattern A: Backend-Core Domain Ecosystem

### 2.1 DataSet 단일 진입점

모든 **도메인 CRUD 및 비즈니스 로직**은 하나의 컨트롤러 엔드포인트를 통합합니다.

\\\java
// DataSetController.java — 3개 메서드
@PostMapping("/search")        // 조회
@PostMapping("/save")          // 저장 (INSERT/UPDATE)
@PostMapping("/search-save")   // 저장 후 조회
\\\

**요청 구조**:
\\\json
{
  "serviceName": "approval/submitDocument",
  "datasets": {
    "ds_doc": {
      "rows": [{ "docTitle": "...", "amount": 1000 }]
    },
    "ds_search": { "keyword": "결재" }
  }
}
\\\

**응답 구조**:
\\\json
{
  "success": true,
  "data": {
    "ds_inbox": { "rows": [...] },
    "ds_count": { "count": 5 }
  }
}
\\\

### 2.2 ServiceRegistry: 런타임 Reflection Dispatch

\@DataSetServiceMapping("domain/method")\ 어노테이션이 붙은 모든 메서드를 애플리케이션 시작 시 스캔하여 등록:

\\\java
@Component
public class ServiceRegistry implements SmartInitializingSingleton {
    private final Map<String, ServiceMethodHolder> registry = new ConcurrentHashMap<>();
    
    @Override
    public void afterSingletonsInstantiated() {
        // 모든 빈 스캔 → @DataSetServiceMapping 어노테이션 추출 → registry 등록
    }
    
    public Map<String, Object> execute(String serviceName, Map<String, Object> datasets, String currentUser) {
        ServiceMethodHolder holder = registry.get(serviceName);
        return (Map<String, Object>) holder.method().invoke(holder.bean(), datasets, currentUser);
    }
}
\\\

**장점**:
- 컨트롤러 계층 없음 → 도메인 서비스가 직접 응답
- 신규 메서드 추가 시 라우팅 수정 불필요 (어노테이션만 붙이면 자동 등록)
- 통일된 요청/응답 구조

### 2.3 도메인 서비스 인벤토리 (16개)

| # | 도메인 | 주요 메서드 | 비고 |
|---|--------|----------|------|
| 1 | admin | userList, userSave, userToggleActive, deptTree, menuList, auditSearch | Keycloak 통합 (Phase 14 T5) |
| 2 | approval | submitDocument, approve, reject, withdraw, resubmit, countPending | Flowable 7.1.0 BPMN, Leave 자동 연동 |
| 3 | attendance | checkIn, checkOut, searchMyMonth | SSO 타임스탠프 |
| 4 | board | searchPosts, savePosts, deletePost | 게시판·댓글·첨부 |
| 5 | calendar | searchEvents, saveEvents, deleteEvent | 전사 휴무일 + 개인 일정 |
| 6 | code | getCodesByGroup | 드롭다운 마스터 |
| 7 | datalib | listFolders, uploadFile, deleteFile | MinIO 연계 |
| 8 | dataset | invoke | 라우팅 제어 |
| 9 | i18n | getLabel, saveLabel | 다국어 레이블 |
| 10 | leave | submitLeaveRequest, getLeaveBalance | 결재 자동 차감 |
| 11 | menu | getMenuTreeByRole | 역할 기반 메뉴 |
| 12 | notification | searchList, markRead, notify, notifyByUserNo | SSE + 다형 오버로드 (T6) |
| 13 | org | getDeptTree, getUsersByDept | 조직도 |
| 14 | room | createBooking, cancelBooking | 회의실 예약 |
| 15 | ux | addFavorite, updatePreferences, search | UX 선호도 (Phase 14 T6) |
| 16 | widget | getWidgetConfig | 대시보드 위젯 |

**총 요약**: 4 Controllers, 21 Services, 17 MyBatis Mappers, 17 Flyway Migrations (platform_v3 schema)

### 2.4 Flowable 7.1.0 BPMN 통합

결재 프로세스(approval domain)는 **별도의 flowable_v3 스키마**에서 BPMN 엔진으로 실행됩니다.

| 컴포넌트 | 파일 | 역할 |
|---------|------|------|
| CompleteDelegate | ApprovalCompleteDelegate.java | 전결 endEvent 처리 → 상태 APPROVED, 기안자 알림 |
| AssigneeResolver | ApprovalAssigneeResolver.java | 동적 결재자 해석 (위임·대결) |
| NotificationListener | ApprovalNotificationListener.java | 결재 작업 생성 시 결재자 알림 |
| ProcessStartListener | ApprovalProcessStartListener.java | 프로세스 시작 시 메타정보 초기화 |

**특징**:
- DMN(Decision Model) 으로 금액/양식별 결재선 자동 결정
- Leave 양식(formCode='LEAVE')일 경우 LeaveService 자동 호출 (setter 주입 required=false)
- 기안자·결재자·반려자 모두 NotificationService로 SSE 알림

---

## 3. Pattern B: Backend-BFF Port-Adapter Federation

### 3.1 Port-Adapter 패턴 (Hexagonal Architecture)

BFF는 **외부 서비스와의 의존성을 추상화**하여 느슨한 결합을 유지합니다.

\\\
BffController (REST 엔드포인트)
  ↓
Port Interface (추상 계약)
  ↓
Adapter 구현체 (외부 서비스 호출)
\\\

### 3.2 Port 인터페이스 (7개)

| Port | 주요 메서드 | 서비스 |
|------|-----------|--------|
| IdentityPort | getMe, createUser, updateUser, setActive, resetPassword | Keycloak |
| MessagingPort | listChannels, listMessages, postMessage | RocketChat |
| MailPort | listMailboxes, listEmails, sendEmail, saveDraft | Stalwart (JMAP) |
| WikiPort | searchPages, getPage | Wiki.js (GraphQL) |
| VideoPort | createRoom, issueToken | LiveKit |
| StoragePort | uploadFile, presignedGetUrl, presignedPutUrl, removeObject | MinIO S3 |
| NotificationPort | (미구현) | 향후 |

### 3.3 Adapter 구현 상태

| Adapter | 상태 | 주요 구현 |
|---------|------|---------|
| KeycloakIdentityAdapter | ✅ | admin-cli password grant, 사용자/역할 CRUD |
| RocketChatAdapter | ❌ Stub | 메시지·채널·구독 (Phase 10 구현 예정) |
| StalwartMailAdapter | ❌ Stub | JMAP 호출 (Phase 10 구현 예정) |
| WikiJsAdapter | ❌ Stub | GraphQL 쿼리 (Phase 10 구현 예정) |
| MinioStorageAdapter | ✅ | putObject, presignedGetUrl, presignedPutUrl, removeObject |
| LiveKitAdapter | ✅ | JWT HS256 토큰, 방 생성 |

### 3.4 KeycloakIdentityAdapter (Phase 14 T5)

\\\java
@Component
public class KeycloakIdentityAdapter implements IdentityPort {
    // admin-cli (master realm) + password grant 사용
    // 운영 환경에서는 service-account (client_credentials) 권장
    
    private String adminToken() {
        // POST /realms/master/protocol/openid-connect/token
        // grant_type=password, client_id=admin-cli
    }
    
    public Map<String, Object> createUser(Map<String, Object> request) {
        // 1) POST /admin/realms/{realm}/users
        // 2) lookupUserIdByUsername
        // 3) assignRealmRoles (있으면)
    }
}
\\\

### 3.5 BffController 주요 엔드포인트

| 메서드 | 경로 | Port | 설명 |
|--------|------|------|------|
| GET | /identity/me | IdentityPort | 현재 사용자 정보 |
| POST | /identity/users | IdentityPort | 신규 사용자 (ROLE_ADMIN) |
| PUT | /identity/users/{username} | IdentityPort | 사용자 수정 |
| PUT | /identity/users/{username}/active | IdentityPort | 활성/비활성 토글 |
| POST | /identity/users/{username}/reset-password | IdentityPort | 임시 비밀번호 |
| GET | /messenger/channels | MessagingPort | RocketChat 채널 |
| GET | /messenger/messages | MessagingPort | 메시지 페이징 |
| POST | /messenger/messages | MessagingPort | 메시지 전송 |
| GET | /mail/mailboxes | MailPort | 메일함 목록 |
| GET | /mail/emails | MailPort | 메일 목록 |
| POST | /mail/send | MailPort | 메일 발송 |
| GET | /wiki/search | WikiPort | 위키 검색 |
| POST | /video/token | VideoPort | 화상회의 토큰 |
| GET | /storage/presigned | StoragePort | MinIO presigned URL |

---

## 4. Pattern C: 외부 서비스 직통 호출

UI가 BFF를 우회하고 외부 서비스에 직접 접근하는 경우:

| 서비스 | 시나리오 | 이유 |
|--------|---------|------|
| MinIO | Presigned GET 다운로드 | 브라우저 S3 직접 다운로드 |
| RocketChat | OAuth 리다이렉트 | Keycloak 자동 인증 |
| Wiki.js | OIDC 리다이렉트 | Keycloak 자동 인증 |
| LiveKit | WebSocket 직접 연결 | BFF JWT 토큰만 발급 |

---

## 5. NotificationService: 다형 시그니처 (Phase 14 T6)

\\\java
// 기본 4개 인자
public void notify(Long docId, Long recipientId, String type, String channel) { ... }

// 제목/본문 추가
public void notify(Long docId, Long recipientId, String type, String channel, 
                   String title, String content) { ... }

// employee_no(문자) 기반 (기존 호환)
public void notifyByUserNo(String recipientUserNo, Long docId, String type, String channel,
                           String title, String content) { ... }

// 카테고리 추가 (채널 환경설정 분기) — 총 6/7 오버로드
public void notifyByUserNo(String recipientUserNo, Long docId, String type, String channel,
                           String title, String content, String category) { ... }
\\\

**Track 6**: category(APPROVAL|BOARD|CALENDAR|MENTION|ROOM|LEAVE) 기반으로
- PORTAL (SSE + DB) 활성 확인
- EMAIL (BFF /api/bff/mail/send) 활성 확인
- MESSENGER (RocketChat DM, 현재 미구현) 활성 확인

---

## 6. 공통 인프라

### 6.1 ApiResponse 통일

\\\java
public record ApiResponse<T>(
    boolean success,
    T data,
    String message,
    ErrorDetail error,
    List<FieldError> errors
)

// 사용
return ApiResponse.ok(result);
return ApiResponse.fail("NOT_FOUND", "문서를 찾을 수 없습니다");
\\\

### 6.2 BusinessException & GlobalExceptionHandler

\\\java
public class BusinessException extends RuntimeException {
    // Factory: notFound(), badRequest(), forbidden(), duplicate()
}

@RestControllerAdvice
public class GlobalExceptionHandler {
    // @ExceptionHandler 3가지: BusinessException, MethodArgumentNotValidException, Exception
}
\\\

### 6.3 BFF SecurityConfig

- Stateless (SessionCreationPolicy.STATELESS)
- JWT 검증: Keycloak JWKS
- CORS: localhost:* (포트 가변)
- 엔드포인트: /actuator/health 만 permitAll

---

## 7. 특수 패턴: ApprovalService ↔ LeaveService

결재·휴가 느슨한 결합:

\\\java
// ApprovalService
private LeaveService leaveService;

@Autowired(required = false)
public void setLeaveService(LeaveService leaveService) {
    this.leaveService = leaveService;
}

// submitDocument() 에서
if (leaveService != null && "LEAVE".equals(formCode)) {
    leaveService.applyFromDoc(docId, currentUser, leaveType, ...);
}
\\\

**이점**: Track 1 없이도 Approval 동작, Track 6 추가 시 자동 활성화

---

## 8. 데이터베이스 스키마

### 8.1 PostgreSQL (platform_v3)

17개 Flyway migration:
- V1: 기본 (user, dept, role)
- V4: board, calendar
- V8: approval (ap_document, ap_approval_line)
- V10: attendance, leave
- V12: data_lib
- V14: admin_audit
- V15: favorite, notify_pref (UX)
- V16: widget

### 8.2 Flowable (flowable_v3, 자동 생성)

- ACT_RE_*: 프로세스 정의
- ACT_RU_*: 런타임 인스턴스
- ACT_HI_*: 이력

---

## 9. 배포 구조

\\\
backend-core:19090           (Spring Boot)
backend-bff:19091            (Spring Boot)
postgres:5432                (platform_v3 + flowable_v3)
keycloak:19281               (SSO)
rocketchat:19065 (외부)
wikijs:19001 (외부)
minio:19900 (외부)
stalwart:19480 (외부)
livekit:19880 (외부)
\\\

---

## 10. 흐름 예시

### 10.1 결재 상신

1. Vue: POST /api/dataset
2. DataSetController.save()
3. ServiceRegistry.execute("approval/submitDocument", ...)
4. ApprovalService.submitDocument()
   - ap_document INSERT
   - ap_approval_line 다건 INSERT (DMN 으로 결재자 결정)
   - notifyByUserNo() 호출 (첫 결재자에게 SSE)
   - leaveService.applyFromDoc() (formCode="LEAVE" 이면)
5. NotificationService.notifyByUserNo()
   - category="APPROVAL" 시:
     - PORTAL enabled → SSE 전송
     - EMAIL enabled → BFF /api/bff/mail/send
     - MESSENGER enabled → stub (미구현)

### 10.2 비디오 토큰 발급

1. Vue: POST /api/bff/video/token (Bearer JWT)
2. BffController.issueVideoToken() → username 추출
3. LiveKitAdapter.issueToken() → JWT HS256 생성
4. 응답: { token, wsUrl: "ws://localhost:19880" }
5. Vue: livekit-client 직접 WS 연결 (BFF 우회)

---

## 참조

- **Stack A 인벤토리**: docs/comprehensive/inventory/02_stack_a_backend.md
- **Stack B 인벤토리**: docs/comprehensive/inventory/03_stack_b_backend.md
- **외부 서비스 매뉴얼**: docs/group_ware.md
- **Phase 14 결정**: docs/comprehensive/warn.md
- **소스**: backend-core/src/main/java/.../dataset/, backend-bff/src/main/java/.../port/adapter/

---

## 이 챕터가 다루지 않은 인접 주제

- **Chapter 1.10**: 코딩 컨벤션 (DataSet 입출력, 에러 처리)
- **Chapter 1.11**: API 에러 시나리오 (retry, timeout, circuit breaker)
- **Chapter 1.12**: 보안 심화 (RBAC, audit trail, encryption)
- **Chapter 1.13**: 배포 구성 (docker-compose 튜닝)
- **Chapter 1.17**: 운영 절차 (백업, 복구)
- **Chapter 1.19**: 트러블슈팅 (알려진 미완: recordHistory actorName, BFF mail service-account)
