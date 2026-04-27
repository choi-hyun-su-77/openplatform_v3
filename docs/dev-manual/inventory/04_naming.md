# inventory/04_naming.md — 식별자 명명 규칙

> Phase 0.E 산출물. 9개 도메인 표본에서 도출한 변환 규칙 + 템플릿용 치환 변수.

## 1. 도메인별 변환 표

| 도메인 | 한글명 | Service 클래스 | Mapper 클래스 | DataSet 접두 | DB 테이블 접두 | URL 경로 | UI 페이지 | 메뉴코드 | i18n key |
|---|---|---|---|---|---|---|---|---|---|
| approval | 전자결재 | `ApprovalService` | `ApprovalMapper` | `approval/...` | `ap_` | `/approval` | `PageApproval.vue` | `approval` | `LBL_APPROVAL_*` / `MENU_APPROVAL` |
| board | 게시판 | `BoardService` | `BoardMapper` | `board/...` | `bd_` | `/board` | `PageBoard.vue` | `board` | `LBL_BOARD_*` |
| calendar | 캘린더 | `CalendarService` | `CalendarMapper` | `calendar/...` | `cal_` | `/calendar` | `PageCalendar.vue` | `calendar` | `LBL_CAL_*` |
| notification | 알림 | `NotificationService` | `NotificationMapper` | `notification/...` | `nt_` | `/notification` | `PageNotifySettings.vue` | `notification` | `LBL_NOTIFICATION` |
| attendance | 근태 | `AttendanceService` | `AttendanceMapper` | `attendance/...` | `at_` | `/attendance` | `PageAttendance.vue` | `attendance` | (전용 prefix 없음) |
| leave | 연차/휴가 | `LeaveService` | `LeaveMapper` | `leave/...` | `at_` (공유) | `/leave` | `PageLeave.vue` | `leave` | (전용 prefix 없음) |
| room | 회의실 | `RoomService` | `RoomMapper` | `room/...` | `rm_` | `/room` | `PageRoom.vue` | `room` | (전용 prefix 없음) |
| datalib | 자료실 | `DataLibraryService` | `DataLibraryMapper` | `datalib/...` | `dl_` | `/datalib` | `PageDataLibrary.vue` | `datalib` | (전용 prefix 없음) |
| worklog | 업무일지 | `WorkReportService` | `WorkReportMapper` | `worklog/...` | `wr_` | `/worklog` | `PageWorkLog.vue` | `worklog` | (전용 prefix 없음) |
| org | 조직 | `OrgService` | `OrgMapper` | `org/...` | `org_` | `/org` | `PageOrg.vue` | `org` | `MENU_ORG` |

> 출처: `[code: backend-core/src/main/java/com/platform/v3/core/{domain}/]`, `[code: backend-core/src/main/resources/db/migration/V8/V10/V11/V12/V13.sql]`, `[code: ui/src/pages/]`, `[code: backend-core/src/main/resources/db/migration/V17__phase14_menus.sql]`

## 2. 일관 변환 규칙

### Rule 1 — 도메인명 → 5가지 표기

| 표기 | 변환 | 예시 (`approval`) |
|---|---|---|
| `__DomainPascal__` | PascalCase | `Approval` |
| `__domainCamel__` | camelCase (도메인 단일 단어 시 lower-case 와 동일) | `approval` |
| `__domain_snake__` | snake_case | `approval` |
| `__domain-kebab__` | kebab-case | `approval` |
| `__DOMAIN_UPPER__` | UPPER_CASE | `APPROVAL` |
| `__dm_table_prefix__` | 2~3 letter table prefix | `ap_` |

### Rule 2 — Java Service 계층

- 클래스명: `{DomainPascal}Service` (예: `ApprovalService`)
- 어노테이션: `@Service`
- DataSet 매핑: `@DataSetServiceMapping("{domainKebab}/{actionCamel}")` (예: `approval/searchInbox`)
- 액션은 `verb+noun` (`search*`, `save*`, `delete*`, `upload*`, `list*`, `check*`)
- 출처 `[code: backend-core/src/main/java/com/platform/v3/core/approval/ApprovalService.java:24, 50, 61, 75, 80, 152, 203]`

### Rule 3 — MyBatis Mapper

- 인터페이스: `{DomainPascal}Mapper.java`
- XML 위치: `backend-core/src/main/resources/mapper/{domain}/{DomainPascal}Mapper.xml`
- namespace: `com.platform.v3.core.{domain}.mapper.{DomainPascal}Mapper`
- 쿼리 ID: DB 동작 기반 (`selectInbox`, `insertDocument`, `updateDocumentStatus`)

### Rule 4 — DB 테이블

- prefix: 2~3 letter (`ap_`, `bd_`, `cal_`, `nt_`, `at_`, `rm_`, `dl_`, `wr_`, `org_`, `cm_`, `dw_`, `ux_`, `sa_`)
- 컬럼: `snake_case` (`doc_id`, `approver_no`, `created_at`)
- PK: `{table_singular}_id` 또는 도메인 자연키 (`employee_no`, `dept_id`)
- 출처 `[code: backend-core/src/main/resources/db/migration/V8__approval_and_extras.sql:10, 41, 63, 77, 91]`

### Rule 5 — URL/REST

- DataSet 진입점: `POST /api/dataset/{search|save}` (도메인별 컨트롤러 없음 — `serviceName` 으로 라우팅)
- 도메인 페이지 라우트: `/{domainKebab}` (e.g. `/approval`, `/board`, `/calendar`)
- 외부 통합 BFF: `/api/bff/{capability}/{action}` (e.g. `/api/bff/identity/users`, `/api/bff/video/token`)

### Rule 6 — UI 컴포넌트/페이지

- 페이지 파일: `Page{DomainPascal}.vue`
- 컴포넌트 폴더: `ui/src/components/{domain}/`
- 컴포넌트 명: PascalCase + 컨텍스트 suffix (`ApprovalDetailDialog`, `LeaveBalanceCard`, `BoardFormDialog`)
- 출처 `[code: ui/src/pages/PageApproval.vue, ui/src/components/approval/]`

### Rule 7 — 메뉴 / 다국어

- 메뉴 코드(`cm_menu.menu_id`): `{domainKebab}` (예: `approval`)
- 부모 그룹: `mywork`, `work`, `settings`, `admin`
- 다국어 키 prefix:
  - 일반 라벨: `LBL_{DOMAIN}_{CONCEPT}` (예: `LBL_APPROVAL_INBOX`)
  - 메뉴 라벨: `MENU_{DOMAIN}` (예: `MENU_APPROVAL`)
  - 메시지: `MSG_{DOMAIN}_{ACTION}` (예: `MSG_APPROVAL_SUBMITTED`)
- 출처 `[code: backend-core/src/main/resources/db/migration/V17__phase14_menus.sql:8-56]`, `[code: V9__i18n_labels_and_seed_data.sql:38-58]`

## 3. 일관성 깨진 사례 (warn.md 기록 후보)

| 이슈 | 관찰 | 사유 | 권장 |
|---|---|---|---|
| `attendance`/`leave` 모두 `at_` prefix 사용 | `at_attendance`, `at_leave_balance`, `at_leave_request` | Phase 14 에서 두 도메인을 묶어 운영 | 그대로 유지 + 도메인 컨텍스트는 service 레이어에서 결정 |
| `WorkReportService` ↔ `worklog/*` URL | service=`WorkReportService`, dataset path=`worklog/*` | 이력적 명명 (work report → URL 단축) | 사용자 노출은 `worklog`, 코드에서는 `WorkReport` 명시 (혼용 허용) |
| `DataLibraryService` ↔ `datalib/*` | service 풀네임, URL/DB 약어 | 풀네임은 가독성, 약어는 frontend/DB 단축 | 충돌 없음 (service 내부 표기) |
| `notification` URL ↔ `nt_` 테이블 | URL 풀네임, table 2-letter | DB 단축이 표준, URL 가독성 우선 | 둘 다 표준으로 인정 |
| `org` 테이블 prefix `org_` (vs `emp_`/`dept_` 가능) | `org_employee`, `org_dept`, `org_position` | 논리적 그룹 namespace 사용 | 신규 도메인에 적용 |

## 4. 템플릿 치환 변수 정의

```text
__DomainPascal__       → ApprovalService / BoardService (클래스명)
__domainCamel__        → approvalService / boardService (변수/메서드명)
__domain_snake__       → approval_service / board_service (config key 등)
__domain-kebab__       → approval / board (URL / 메뉴코드 / 폴더명)
__DOMAIN_UPPER__       → APPROVAL / BOARD (상수, ENUM)
__dm_table_prefix__    → ap_ / bd_ / cal_ (DB 테이블 prefix)
__DomainTitle__        → Approval / Board (UI 라벨 영문)
__domainKorean__       → 전자결재 / 게시판 (UI 라벨 한글, i18n MENU_* 로 fetch)
```

> 코드베이스에서 사용되지 않는 표기 (예: `THIS_DOMAIN_KEY`)는 정의에서 제외.

## 5. 패턴 예시 (template-friendly)

```java
// {domain} 패키지: backend-core/src/main/java/com/platform/v3/core/__domain-kebab__/
package com.platform.v3.core.__domain-kebab__;

@Service
public class __DomainPascal__Service {
    private final __DomainPascal__Mapper mapper;

    @DataSetServiceMapping("__domain-kebab__/searchList")
    public Map<String, Object> searchList(Map<String, Object> datasets, String currentUser) { ... }
}
```

```sql
-- DB 테이블 패턴 (Vn__{domain}_schema.sql)
CREATE TABLE platform_v3.__dm_table_prefix__main (
    __domain_snake___id   VARCHAR(32) PRIMARY KEY,
    title                 VARCHAR(256),
    created_by            VARCHAR(64),
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

```typescript
// Router (ui/src/router/index.ts)
{
  path: '__domain-kebab__',
  name: '__domain-kebab__',
  component: () => import('@/pages/Page__DomainPascal__.vue'),
  meta: { menuId: '__domain-kebab__' }
}
```

## 6. 핵심 관찰

1. **DataSet 단일 진입**: 모든 도메인 service 가 `@DataSetServiceMapping` 으로 진입점 노출 → 도메인별 REST 컨트롤러 없음.
2. **테이블 접두 강제**: 2~3 letter prefix 가 9개 도메인에서 일관 → 신규 도메인도 반드시 따라야 함.
3. **camelCase 액션 + kebab 경로**: 액션 내부는 camelCase (`searchInbox`), URL/메뉴/폴더는 kebab.
4. **i18n 계층**:
   - 메뉴 코드 `{domain}` (단순)
   - UI 라벨 `LBL_{DOMAIN}_*` (구체)
   - 메시지 `MSG_{DOMAIN}_*` (행위 결과)
5. **UI 라우팅 규칙**: 단순 kebab(`/approval`) → `Page{DomainPascal}.vue` (Vue Router meta `menuId`).
