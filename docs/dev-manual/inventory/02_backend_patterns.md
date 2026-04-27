# inventory/02_backend_patterns.md — 백엔드 작성 패턴 인벤토리

> Phase 0.C 산출물. 17개 도메인 × 6개 BFF 어댑터를 클러스터링한 결과 **4개 패턴** 도출.
> 후속 `scaffolds/` 의 SOP 개수는 4개로 결정된다.

## 1. 도메인 파일 인벤토리

| 도메인 | Controller | Service | Mapper | Flowable | 권한 | 외부 통합 |
|---|---|---|---|---|---|---|
| admin | (없음) | AdminService | AdminMapper | (없음) | `requireAdmin()` | BFF/Keycloak user CRUD |
| approval | (없음) | ApprovalService | ApprovalMapper | CompleteDelegate / StartListener / AssigneeResolver / NotificationListener | `verifyDocAccess()` | Flowable engine, LeaveService hook |
| attendance | (없음) | AttendanceService | AttendanceMapper | (없음) | implicit (read-only) | (없음) |
| board | (없음) | BoardService | BoardMapper | (없음) | implicit | (없음) |
| calendar | (없음) | CalendarService | CalendarMapper | (없음) | implicit | room booking hook |
| code | CodeController | CodeService | CodeMapper | (없음) | (public) | (없음) |
| datalib | (없음) | DataLibraryService | DataLibraryMapper | (없음) | implicit | (없음) |
| dataset | DataSetController | DataSetService + ServiceRegistry | (없음) | (없음) | JWT in Controller | user normalization (Keycloak→empNo) |
| i18n | I18nController | I18nService | I18nMapper | (없음) | (public) | (없음) |
| leave | (없음) | LeaveService | LeaveMapper | (없음) | implicit (currentUser) | ApprovalService caller |
| menu | (없음) | MenuService | MenuMapper | (없음) | implicit | (없음) |
| notification | NotificationController | NotificationService | NotificationMapper | (없음) | JWT + employee_id resolve | (없음) |
| org | (없음) | OrgService | OrgMapper | (없음) | implicit | identity resolution |
| room | (없음) | RoomService | RoomMapper | (없음) | `isAdminUser()` | BFF/LiveKitAdapter, CalendarMapper |
| ux | (없음) | SearchService / FavoriteService / NotifyPrefService | UxMapper | (없음) | currentUser context | OrgMapper resolution |
| widget | (없음) | WidgetService | WidgetMapper | (없음) | implicit | (없음) |
| worklog | (없음) | WorkReportService | WorkReportMapper | (없음) | implicit | (없음) |

> 출처: `[code: backend-core/src/main/java/com/platform/v3/core/{domain}/]` 디렉토리 트리 + Service/Mapper 클래스 검사

## 2. BFF Port-Adapter 인벤토리

| Port | Adapter | 대상 시스템 | 대표 메서드 |
|---|---|---|---|
| IdentityPort | KeycloakIdentityAdapter | Keycloak Admin REST | `getMe`, `getRoles`, `getUserById`, `createUser`, `updateUser`, `setActive`, `resetPassword` |
| StoragePort | MinioStorageAdapter | MinIO S3 | `uploadFile`, `presignedGetUrl`, `presignedPutUrl`, `deleteFile` |
| MessagingPort | RocketChatAdapter | Rocket.Chat v6 REST | `listChannels`, `listMessages`, `postMessage`, `createDirectChannel`, `unreadBadge` |
| VideoPort | LiveKitAdapter | LiveKit | `createRoom`, `issueToken`, `getRoom`, `deleteRoom` |
| MailPort | StalwartMailAdapter | Stalwart SMTP | `sendEmail` |
| WikiPort | WikiJsAdapter | Wiki.js | `getPage`, `createPage`, `updatePage` |

> 출처: `[code: backend-bff/src/main/java/com/platform/v3/bff/port/]` + `[code: backend-bff/src/main/java/com/platform/v3/bff/adapter/]`

## 3. 패턴 클러스터 (4종)

### Pattern A — 표준 CRUD + MyBatis

**식별 기준**
- Service 1개 / Mapper 1개 / Controller 선택
- Flowable 미사용, 외부 시스템 호출 없음
- DataSet 진입점(`@DataSetServiceMapping`)으로 CRUD
- 권한: implicit (currentUser) 또는 (public)

**구성 파일**
```
{domain}/
  ├── {Domain}Service.java         (@Service + @DataSetServiceMapping)
  ├── ({Domain}Controller.java)    (선택)
  └── mapper/
      └── {Domain}Mapper.java
```

**대표 도메인**
- `[code: backend-core/src/main/java/com/platform/v3/core/code/]`
- `[code: backend-core/src/main/java/com/platform/v3/core/i18n/]`
- `[code: backend-core/src/main/java/com/platform/v3/core/org/]`
- `[code: backend-core/src/main/java/com/platform/v3/core/menu/]`
- `[code: backend-core/src/main/java/com/platform/v3/core/board/]`

**적합한 경우**
- Read-only 또는 단순 CRUD (search/save/delete)
- 단일 도메인 영속 (cross-domain workflow 없음)
- Stateless
- public 또는 단순 role 가드

**부적합한 경우**
- 다단계 워크플로(결재 체인, state machine)
- 복잡한 권한(문서 소유자 + 결재선 멤버 등)
- 외부 시스템 통합(Keycloak/MinIO/LiveKit)
- 감사/컴플라이언스 요구

**실행 흐름 (예시)**
1. `POST /api/dataset/search { serviceName: "code/getCodesByGroups", datasets: { ... } }`
2. `DataSetController` → `DataSetServiceRegistry` 가 classpath 스캔으로 `@DataSetServiceMapping("code/...")` 매핑된 메서드 발견
3. `CodeService.getCodesByGroups(datasets, currentUser)` 호출
4. Service → `CodeMapper` SELECT → `Map<String, List>` 반환
5. Controller 가 `ApiResponse.ok(...)` 래핑

---

### Pattern B — Workflow-Driven (Flowable + Delegates)

**식별 기준**
- Service 가 진입점 정의(`@DataSetServiceMapping`) + Flowable 프로세스 정의(`*.bpmn20.xml`)
- Delegate 클래스가 `JavaDelegate` 구현 → state transition
- State: `PENDING → IN_PROGRESS → APPROVED|REJECTED|DRAFT`
- StartListener / CompleteDelegate / AssigneeResolver / NotificationListener
- Cross-domain hook (`ApprovalService → LeaveService.applyFromDoc`) 가능
- 권한: `verifyDocAccess()` (소유자 + 결재선)

**구성 파일**
```
approval/
  ├── ApprovalService.java                  (CRUD + workflow 진입점)
  ├── mapper/ApprovalMapper.java
  └── flowable/
      ├── ApprovalProcessStartListener.java
      ├── ApprovalCompleteDelegate.java
      ├── ApprovalAssigneeResolver.java
      └── ApprovalNotificationListener.java
```

**대표 도메인**
- `[code: backend-core/src/main/java/com/platform/v3/core/approval/]` (주력)
- 부분: `[code: backend-core/src/main/java/com/platform/v3/core/leave/]` (hook 만 사용)

**적합한 경우**
- 다단계 프로세스 (결재 체인, 조건 분기)
- 명확한 entry/exit 의 state machine
- 감사 추적(프로세스 history 자동 기록)
- 병렬/순차 task 할당
- 단계 간 트랜잭션 보장
- 회수/재상신 로직

**부적합한 경우**
- state 없는 단순 CRUD
- 실시간 스트리밍 (REST + SSE 사용)
- 서브밀리초 latency (워크플로 오버헤드 50~100ms)

**실행 흐름**
1. UI → `POST /api/dataset/save { serviceName: "approval/submitDocument" }`
2. `ApprovalService.submitDocument()` 검증 → `ap_document` + `ap_approval_line` insert
3. `approvalMapper.selectApproversForDocFromDmn()` 동적 결재선 결정
4. 각 결재자: `ap_approval_line` insert + `NotificationService.notifyByUserNo()`
5. Hook: `formCode='LEAVE'` 면 `LeaveService.applyFromDoc()` (실패해도 rollback 없음)
6. Flowable 프로세스 자동 시작 (트리거)
7. 첫 결재자 task assign (`ApprovalAssigneeResolver`)
8. UI 인박스 폴링 / SSE → 결재자 "승인"
9. `ApprovalService.approve()` line update → 모두 승인 시 `ApprovalCompleteDelegate` 발화
10. CompleteDelegate → 기안자 알림 + LEAVE 폼 시 `leaveService.onDocApproved()`

---

### Pattern C — External System Passthrough (BFF Port-Adapter)

**식별 기준**
- backend-core Service 가 `BffClient` 또는 Port 인터페이스 주입
- BFF 의 Port = Spring 인터페이스, Adapter 구현이 WebClient/RestTemplate 으로 외부 REST 호출
- backend-core 영속 상태 거의 없음(또는 메타데이터 캐시만)
- 에러 처리: 우아한 fallback 또는 BusinessException
- 인증: 토큰 전파 (JWT → admin token → 외부 OAuth2)

**구성 파일**
```
backend-core/
  └── {domain}/{Domain}Service.java        (bffPost / bffPut / Port 호출)

backend-bff/
  ├── port/
  │   ├── {Capability}Port.java            (인터페이스)
  └── adapter/
      └── {External}{Capability}Adapter.java  (구현)
```

**대표 도메인**
- backend-core 호출자: `admin` (Keycloak), `room` (LiveKit), `approval` (MinIO 첨부), `datalib` (MinIO 파일)
- BFF 어댑터: `[code: backend-bff/src/main/java/com/platform/v3/bff/adapter/]`

**적합한 경우**
- 3rd-party 시스템 통합 (Identity/Storage/Messaging/Video/Mail/Wiki)
- Operational token 관리(서비스 계정/API 키)
- DB + 외부 상태의 cross-system 일관성
- Rate limit / circuit breaker 보호
- 표준 에러 매핑

**부적합한 경우**
- 내부 CRUD (Pattern A)
- 고빈도 호출 (async + cache 권장)
- 저latency (<100ms, BFF hop 회피)

**실행 흐름 (admin 예)**
1. `AdminService.userSave()` 가 신규 직원 DataSet 수신
2. `org_employee` insert (backend-core DB)
3. Keycloak user creation 요청 구성
4. `bffPost("/api/bff/identity/users", req)` 호출
5. BFF `IdentityController` → `KeycloakIdentityAdapter.createUser()` 라우팅
6. Adapter: admin token 획득 (admin-cli password grant)
7. `POST /admin/realms/{realm}/users` Keycloak 호출
8. `{userId, username}` 반환 → backend-core 로 전파
9. AdminService 성공 로그; Keycloak 실패해도 DB row 는 유지(warn 로그)

---

### Pattern D — Read-Only / Aggregation (Dashboard + 통합검색)

**식별 기준**
- Service 가 다수 mapper/도메인 데이터 집계
- INSERT/UPDATE/DELETE 없음 (read-only)
- 권한 필터: `employee_id`, `dept_id` 기반 접근 제한
- 응답: `List<Map>` 표준 필드
- 최적화: LIMIT, ILIKE, GIN 인덱스
- 트랜잭션 없음

**구성 파일**
```
ux/
  ├── SearchService.java       (multi-mapper aggregation)
  ├── FavoriteService.java
  ├── NotifyPrefService.java
  └── mapper/UxMapper.java     (UNION + ILIKE + indexed query)

widget/
  └── WidgetService.java       (catalog read + 사용자 layout)

attendance/
  └── AttendanceService.java   (요약 쿼리만)
```

**대표 도메인**
- `[code: backend-core/src/main/java/com/platform/v3/core/ux/SearchService.java]` (POST+DOC+EMP+FILE 통합검색)
- `[code: backend-core/src/main/java/com/platform/v3/core/widget/WidgetService.java]` (대시보드 위젯)
- `[code: backend-core/src/main/java/com/platform/v3/core/attendance/AttendanceService.java]` (근태 요약)

**적합한 경우**
- 대시보드 (PENDING_APPROVAL count, TODAY_EVENTS, LEAVE_BALANCE 위젯)
- 통합검색 (도메인 간 키워드)
- Read-only 분석/리포트
- 사용자 환경설정 조회
- 카탈로그 lookup (코드 그룹, 위젯 카탈로그)

**부적합한 경우**
- 상태 변경 (CRUD)
- 워크플로 단계 (Pattern B)
- 외부 쓰기 (Pattern C)

**실행 흐름 (widget 예)**
1. UI → `POST /api/dataset/search { serviceName: "widget/listMine" }`
2. `WidgetService.listMine()` → `widgetMapper.countMine(currentUser)`
3. count=0 (첫 로그인) → `DEFAULT_LAYOUT` 6개 자동 시드
4. `widgetMapper.selectMine()` → 사용자 layout + catalog 정보 반환
5. UI 가 6개 위젯 렌더 (Attendance / LeaveBalance / PendingApproval / Calendar / News / WorkReport)

## 4. 패턴 결정 트리 (decision factors)

```
외부 시스템 호출이 필요한가?
├─ YES → Pattern C (Port-Adapter in BFF)
└─ NO
   │
   └─ 워크플로/state machine 이 필요한가?
      ├─ YES → Pattern B (Flowable + Delegates)
      └─ NO
         │
         └─ Read-only / 집계 인가?
            ├─ YES → Pattern D
            └─ NO  → Pattern A (단순 CRUD)
```

## 5. 권한 모델 매핑

| 패턴 | 메커니즘 | 위치 | 적용 범위 |
|---|---|---|---|
| A (CRUD) | 없음 / implicit | Service 메서드 | currentUser=employee_no (nullable 허용) |
| A (Admin) | `requireAdmin()` → `SecurityContext.getAuthentication()` | `[code: backend-core/.../admin/AdminService.java]` | `ROLE_ADMIN` only |
| B (Workflow) | `verifyDocAccess()` → 문서 소유자 + 결재선 | `[code: backend-core/.../approval/ApprovalService.java]` | 기안자 + 할당된 결재자 |
| C (External) | JWT → admin token → OAuth2 | `[code: backend-bff/.../adapter/KeycloakIdentityAdapter.java]` | service account |
| D (Dashboard) | 권한 필터(`dept_id`, `employee_id`) | `[code: backend-core/.../ux/SearchService.java]` | 사용자 → 부서 접근 |

## 6. 영속 모델

| 패턴 | 접근 방식 | ORM | 트랜잭션 | 예시 |
|---|---|---|---|---|
| A | MyBatis Mapper 인터페이스 | (BaseMapper 패턴 추정) | `@Transactional` 조건적 | CodeService → CodeMapper |
| B | MyBatis + Flowable engine | MyBatis + BpmnModel | `@Transactional` (Service 진입) | ApprovalService + flowable |
| C | 메타데이터 캐시만 | WebClient REST | 없음(외부가 진실 source) | MinioStorageAdapter |
| D | Read-only MyBatis | indexed SELECT/UNION | 없음 | SearchService |

## 7. Cross-Domain 통합 포인트

| Caller → Callee | 패턴 | 메커니즘 | 실패 처리 |
|---|---|---|---|
| ApprovalService → LeaveService.applyFromDoc | B→A | 직접 Java 호출(setter inject) | `required=false`, warn 로그 |
| ApprovalCompleteDelegate → LeaveService.onDocApproved | B→A | JavaDelegate → setter inject | try-catch wrap |
| AdminService → BffClient.post() | A→C | RestTemplate → BFF | warn 로그, DB row 유지 |
| RoomService → BffClient.createVideoRoom() | A→C | BffClient wrapper | warn 로그, fallback |
| RoomService → CalendarMapper.insertEvent() | A→A | 직접 Java 호출 | warn 로그, booking 성공 유지 |
| DataSetController → OrgMapper (currentUser 해석) | A→A | `@Autowired` mapper inject | fallback: username 그대로 |
| NotificationController → OrgMapper (employee_id 해석) | D→A | constructor inject | fallback: userId param |

> 핵심 통찰: cross-domain 호출 실패는 로깅만 하고 primary 트랜잭션은 rollback 하지 않는다. Loose coupling 유지하되 데이터 불일치 위험 존재.

## 8. 진입점 요약

| 진입 | 패턴 | HTTP | Endpoint | 인증 |
|---|---|---|---|---|
| DataSetController | A/B/D | POST | `/api/dataset/search`, `/api/dataset/save` | JWT → employee_no |
| CodeController | A | GET | `/api/codes?groups=...` | (없음) |
| I18nController | A | GET | `/api/i18n/{locale}?type=...` | (없음) |
| NotificationController | D | GET (SSE) | `/api/notification/subscribe?token=...` | JWT → SSE emitter |

## 9. 패턴별 SOP 매핑

| 패턴 | scaffolds 파일 | 모범 도메인 |
|---|---|---|
| A | `scaffolds/01_pattern_a_crud_mybatis.md` | code, board |
| B | `scaffolds/02_pattern_b_workflow_flowable.md` | approval |
| C | `scaffolds/03_pattern_c_bff_adapter.md` | admin (Keycloak), room (LiveKit) |
| D | `scaffolds/04_pattern_d_aggregation_readonly.md` | widget, ux/search |

## 10. 권고

1. backend-core 의 직접 RestTemplate 사용은 가급적 BFF Port-Adapter 로 통일 (현재 admin 도메인이 변종)
2. 표준 BusinessException 계층 + `Resilience4j` CircuitBreaker (BFF 호출용)
3. 통합검색이 ILIKE+UNION 기반 → 사용자 500+ 시 GIN 인덱스 또는 OpenSearch 마이그레이션
4. Pattern B 통합 테스트(approval + delegate chain) 추가
5. Keycloak admin 자격증명을 service account(client_credentials) 로 교체 (현재 admin/admin)
6. `@DataSetServiceMapping` Javadoc 표준화: 입력 스키마(`ds_search`, `ds_data`) + 출력 구조 명시
