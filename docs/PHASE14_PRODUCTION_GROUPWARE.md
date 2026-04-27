# Phase 14 — Production-Grade 그룹웨어 강화 (병렬 8 트랙)

> **본 문서를 그대로 다음 세션에 던지면 된다.**
> 단일 명령: *"docs/PHASE14_PRODUCTION_GROUPWARE.md 진행해"*
>
> 작성일 2026-04-27 / 대상 브랜치 main / 전제: Phase 0~13 완료 + Phase 13 H/F 까지 done.

---

## 0. 메타 지침 (반드시 먼저 읽고 시작)

### 0.1 목표
지금까지의 v3는 데모 수준이었다. **Phase 14 의 끝나는 순간, 50명 규모의 회사가 한 달 단위로 실제 업무를 돌릴 수 있는 그룹웨어**가 되어야 한다. 핵심 기준 3가지:

1. **빈 상태로 로그인해도 매일 누르고 싶은 메뉴가 있다** — 출근체크 / 오늘 일정 / 미결 / 공지 / 회의실
2. **관리자 한 명이 GUI 만으로 사용자·조직·메뉴·코드를 운영할 수 있다** — DB 직접 수정 0건
3. **결재가 단순 흐름이 아니라 실제 휴가/경비/회의실 예약과 연동된다** — 승인되면 잔여연차 차감, 회의실 자동 점유

### 0.2 자율 실행 규칙 (워크스페이스 최상위 규칙 상속)
- **사용자에게 질문 금지.** 모든 분기는 합리적 기본값으로 결정 후 `warn.md` 기록.
- 막히면 대안 → warn.md / 5회 실패 → fatal.md.
- 외부 서비스 불가 시 mock 으로 대체 → warn.md.

### 0.3 병렬 진행 정책 (중요)
이 문서는 **8개 트랙으로 분리**되어 있고, 각 트랙은 다른 트랙과 **DB 스키마(테이블 prefix)·API namespace·UI 라우트가 겹치지 않게** 설계됨.

**진행 방식 (둘 중 하나 채택)**:
- **Mode A — 단일 세션 순차** : 트랙 1→2→…→8 순서대로 진행. 한 트랙 끝날 때마다 빌드+smoke test 통과 후 다음.
- **Mode B — 병렬 (`Agent` subagent_type=general-purpose)** : 트랙 1·2·3·4·5·6·7·8 을 4개 동시 실행 (메인 세션은 8 만 수행). 각 에이전트는 본 문서의 해당 §섹션 + §1(공통 컨벤션) + §2(전제 검증) 만 보면 자력 진행 가능. 트랙 간 충돌은 없음 — 충돌 가능성이 있는 §1.4 의 라우트/메뉴 등록만 8번 트랙(메인)에서 마지막에 일괄 합치기.

**기본값**: 가용 시간이 4h 이상이면 Mode B, 미만이면 Mode A.

### 0.4 품질 기준 (Definition of Done) — 모든 트랙 공통
한 트랙이 "완료"가 되려면 아래 7가지 모두 green:
1. **DB 마이그레이션** Flyway 가 클린 부팅에 성공 (`docker compose down -v && up -d` 후 `flyway_schema_history` 에 신규 V## 표시)
2. **백엔드 컴파일** `cd backend-core && mvn -q -DskipTests package` 성공 + 컨테이너 healthy
3. **DataSet smoke test** 트랙의 모든 신규 service 가 `curl /api/dataset/search` 200 응답 (인증된 토큰)
4. **UI 빌드** `cd ui && npm run build` 성공 (vue-tsc 에러 0)
5. **Playwright MCP 시나리오** 트랙별 §"검증 시나리오" 의 핵심 1개 이상 통과 — 스크린샷 `docs/screenshots/phase14-track{N}-*.png` 저장
6. **권한 가드** 신규 메뉴는 `cm_menu` 등록 + `usePermission(menuId)` 적용 + 비권한 사용자 접속 시 /403 리다이렉트 확인
7. **TODO 체크박스** 본 문서의 해당 트랙 TODO 가 전부 [x] 또는 [~](명확한 잔여 사유)

### 0.5 산출물 동기화 의무
- `docs/api-catalog.md` — 트랙별 신규 DataSet service 라인 추가
- `docs/scenarios.md` — 트랙별 사용자 시나리오 1줄 추가
- `TODO.md` — Phase 14 섹션을 본 문서와 일치하도록 갱신
- `info.md` (없으면 신규) — 진행률 업데이트 1분 단위
- `warn.md` — 자율 결정 1건당 1라인
- 트랙 끝 커밋 메시지 prefix: `feat(phase14-tN): ...` (N=트랙 번호)

### 0.6 절대 하지 말 것 (Anti-pattern)
- ❌ vue-spring-fw 원본 (`C:\claude\vue-spring-fw\**`) 수정 — 컴포넌트 필요하면 `ui/` 로 정적 복사
- ❌ v1 (`C:\claude\openplatform`) / v2 (`C:\claude\openplatform_v2`) 수정 또는 통째 복사
- ❌ DataSet 패턴 우회한 신규 REST 컨트롤러 생성 — 모두 `@DataSetServiceMapping` 으로 노출 (관리자 전용 admin/* namespace 도 마찬가지)
- ❌ 하드코딩 employee_no/employee_id (Phase 13 Phase 0 정규화 패턴 준수 — `DataSetController.currentUser()` 사용)
- ❌ 신규 외부 컨테이너 추가 (현 9개 인프라로 충분) — 새 인프라 필요 시 warn.md 기록 후 사용자 대기
- ❌ `directAccessGrantsEnabled=true` 재활성화 — F-9 에서 false 로 복구 완료, 유지

---

## 1. 공통 컨벤션 (모든 트랙 공유)

### 1.1 DB 스키마 prefix 표준
| 트랙 | 도메인 | 테이블 prefix | Flyway 버전 |
|---|---|---|---|
| 1 | 근태/휴가 | `at_*` | V10 |
| 2 | 회의실 예약 | `rm_*` | V11 |
| 3 | 자료실 | `dl_*` | V12 |
| 4 | 업무일지/주간보고 | `wr_*` | V13 |
| 5 | 시스템관리 | (기존 `cm_menu`/`cm_code`/`org_*` 활용 + `sa_audit`) | V14 |
| 6 | 즐겨찾기/검색/알림설정 | `ux_favorite`, `ux_search_index`, `ux_notify_pref` | V15 |
| 7 | 대시보드 위젯 | `db_widget`, `db_user_widget` | V16 |
| 8 | (메인 통합) | 없음 — 다른 트랙 마이그레이션 검수만 | - |

**버전 충돌 방지**: 각 트랙은 자기 V## 만 작성. 공유 테이블(cm_menu, cm_code, org_employee) 변경은 §1.4 의 일괄 마이그레이션으로 처리.

### 1.2 DataSet Service 네이밍 규칙
```
{domain}/{action}{Object?}
예: attendance/checkIn, attendance/searchMyMonth
   leave/searchBalance, leave/applyFromDoc
   room/searchAvailable, room/reserve
   datalib/listFolders, datalib/uploadMeta
   worklog/saveDaily, worklog/searchTeamWeekly
   admin/userList, admin/menuSave, admin/codeSave
   ux/listFavorites, ux/saveNotifyPref
   widget/listMine, widget/saveLayout
```

권한 매핑은 `cm_menu_permission` 으로 단일화. namespace `admin/*` 는 ROLE_ADMIN 한정.

### 1.3 UI 라우트 표준
```
/attendance         근태 (트랙 1)
/leave              연차/휴가 (트랙 1, 결재 연동)
/room               회의실 예약 (트랙 2)
/datalib            자료실 (트랙 3)
/worklog            업무일지 (트랙 4)
/admin/users        사용자 관리 (트랙 5)
/admin/depts        조직 관리 (트랙 5)
/admin/menus        메뉴/권한 (트랙 5)
/admin/codes        공통코드 (트랙 5)
/admin/audit        감사 로그 (트랙 5)
/search             통합 검색 결과 (트랙 6)
/settings/notify    알림 설정 (트랙 6)
/settings/favorites 즐겨찾기 관리 (트랙 6)
/dashboard          (기존, 트랙 7에서 위젯 시스템화)
```

각 라우트는 `meta.menuId` 보유 + Router 가드(`canRead`)로 보호.

### 1.4 메뉴/권한 등록 — **트랙 8(메인)에서 일괄 처리**
각 트랙은 자기 페이지 작성만 하고, `cm_menu` INSERT 와 `cm_menu_permission` 시드는 **트랙 8** 에서 한 번에 등록. 트랙 1~7은 자기 트랙의 메뉴 정의를 본 문서 §10 "메뉴 등록 카탈로그" 에 한 줄 추가만 하면 됨.

### 1.5 공통 UI 부품 재사용 (이미 존재)
- `components/common/CrudToolbar.vue` — 검색/필터/액션 바
- `components/common/SearchPanel.vue` — 검색 패널
- `components/common/FileUploadPanel.vue` — MinIO presigned 업로드
- `components/common/LoadingSkeleton.vue` — 로딩 스켈레톤
- `components/common/NotificationBell.vue` — 헤더 종 (이미 LayoutHeader 에 마운트됨)
- `composables/useDataSet*` — DataSet 호출 헬퍼
- `composables/usePermission` — 권한 체크
- `composables/useStorage` — MinIO 업/다운로드

**원칙**: 새 페이지는 위 부품을 *반드시* 재사용. 기능 부족 시 부품을 확장(props 추가)하고 다른 페이지 영향 없이 후방 호환 유지.

### 1.6 시드 데이터 일관성
- 모든 트랙은 V## 마지막에 "최소 검증용 시드 5건" 삽입 (`ON CONFLICT DO NOTHING`)
- 사용자는 기존 시드 admin/user1/user2/user3 활용
- 부서는 기존 시드(영업/개발/인사 등) 활용
- 회의실(트랙2): 시드 5개 (대회의실/소회의실A/B/임원실/화상회의실A)
- 공휴일은 V8 의 cm_holiday 활용 (트랙 1·2 가 영업일 계산 시 참조)

### 1.7 검증 토큰 발급 (smoke test 용)
F-9 에서 directAccessGrantsEnabled=false 로 복구되었으므로 **토큰은 PKCE 로만 발급**. smoke test 는 다음 둘 중 하나:
- (A) Playwright MCP 로 admin/admin 로그인 후 `localStorage.getItem('keycloak-token')` 추출 → curl
- (B) 임시로 `directAccessGrantsEnabled=true` 활성화 → 검증 후 즉시 `false` 복구 (kcadm 명령으로 자동화, warn.md 기록 필수)

기본 채택: **(A)**. (B) 는 5회 시도 실패 시에만.

### 1.8 권한 매트릭스 (트랙별 신규 메뉴)
| 메뉴 | 일반사용자 | 부서장 | 인사담당 | 관리자 |
|---|---|---|---|---|
| 근태 (본인) | RWUD | RWUD | R | RWUD |
| 근태 (팀) | - | R | R | R |
| 휴가신청 | RWUD | RWUD | R | RWUD |
| 휴가승인 | - | RW | RW | RW |
| 회의실예약 | RWUD(본인) | RWUD | - | RWUD |
| 자료실(부서) | RWUD(본인부서) | RWUD | - | RWUD |
| 업무일지 | RWUD(본인) | R(팀) | - | R |
| 시스템관리 | - | - | - | RWUD |
| 알림설정 | RWUD(본인) | RWUD(본인) | - | RWUD |
| 대시보드 위젯 | RWUD(본인) | RWUD(본인) | - | RWUD |

R=read W=write U=update D=delete. Keycloak 역할: `ROLE_USER`/`ROLE_MGR`/`ROLE_HR`/`ROLE_ADMIN` (이미 realm 시드 존재).

---

## 2. 전제 검증 (5분, 모든 트랙 시작 전 필수)

```bash
cd /c/claude/openplatform_v3

# 컨테이너 상태
docker ps --format "{{.Names}} {{.Status}}" | grep ^v3- | sort

# 핵심 헬스
curl -s -o /dev/null -w "core=%{http_code}\n" http://localhost:19090/actuator/health
curl -s -o /dev/null -w "bff=%{http_code}\n"  http://localhost:19091/actuator/health
curl -s -o /dev/null -w "ui=%{http_code}\n"   http://localhost:19173/

# 마이그레이션 현황
docker exec v3-postgres psql -U platform_v3 -d platform_v3 -c \
  "SELECT version, description, success FROM platform_v3.flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;"

# 마지막이 V9 / success=t 여야 함. 다르면 STOP — fatal.md 기록.
```

모두 통과 시 트랙 진입. 실패 시 §0.2 자율복구 시도.

---

## 3. 트랙 1 — 근태·연차·휴가 (Attendance & Leave) ⭐ 최우선

### 3.1 사용자 가치
- "오늘 출근/퇴근 버튼이 대시보드에 있다" — 50명 회사가 매일 누름
- "연차 잔여일수가 마이페이지에 보이고, 휴가 결재 완료 시 자동 차감" — 별도 엑셀 관리 불필요
- "팀원의 부재(휴가/외근) 가 캘린더에 자동 노출" — 트랙 8 에서 캘린더 통합

### 3.2 DB 스키마 (V10__attendance_leave.sql)
```sql
-- 출퇴근 일별 기록
CREATE TABLE platform_v3.at_attendance (
  attendance_id BIGSERIAL PRIMARY KEY,
  employee_no   VARCHAR(32) NOT NULL,
  work_date     DATE NOT NULL,
  check_in_at   TIMESTAMPTZ,
  check_out_at  TIMESTAMPTZ,
  work_minutes  INT,                  -- 자동 계산
  status        VARCHAR(16) NOT NULL DEFAULT 'NORMAL',  -- NORMAL|LATE|EARLY|ABSENT|HOLIDAY|LEAVE
  note          VARCHAR(256),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (employee_no, work_date)
);
CREATE INDEX idx_at_attendance_emp_date ON platform_v3.at_attendance(employee_no, work_date DESC);

-- 연차 잔여 (연도별)
CREATE TABLE platform_v3.at_leave_balance (
  balance_id    BIGSERIAL PRIMARY KEY,
  employee_no   VARCHAR(32) NOT NULL,
  year          INT NOT NULL,
  total_days    NUMERIC(5,1) NOT NULL,    -- 부여 (15.0 등)
  used_days     NUMERIC(5,1) NOT NULL DEFAULT 0,
  carry_over    NUMERIC(5,1) NOT NULL DEFAULT 0,  -- 이월
  remaining     NUMERIC(5,1) GENERATED ALWAYS AS (total_days + carry_over - used_days) STORED,
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (employee_no, year)
);

-- 휴가 신청 (결재 ap_document 와 1:1 매핑, form_code='LEAVE')
CREATE TABLE platform_v3.at_leave_request (
  request_id    BIGSERIAL PRIMARY KEY,
  doc_id        BIGINT REFERENCES platform_v3.ap_document(doc_id) ON DELETE SET NULL,
  employee_no   VARCHAR(32) NOT NULL,
  leave_type    VARCHAR(16) NOT NULL,     -- ANNUAL|HALF_AM|HALF_PM|SICK|FAMILY|UNPAID
  from_date     DATE NOT NULL,
  to_date       DATE NOT NULL,
  days          NUMERIC(4,1) NOT NULL,    -- 0.5 단위 (반차 0.5)
  reason        VARCHAR(512),
  status        VARCHAR(16) NOT NULL DEFAULT 'PENDING', -- PENDING|APPROVED|REJECTED|CANCELLED
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_at_leave_emp ON platform_v3.at_leave_request(employee_no, from_date DESC);

-- 시드: 2026 연차 잔여 (admin 15일, user1~3 각 12일)
INSERT INTO platform_v3.at_leave_balance (employee_no, year, total_days) VALUES
  ('E0001', 2026, 15.0),
  ('E0002', 2026, 12.0),
  ('E0003', 2026, 12.0),
  ('E0004', 2026, 12.0)
ON CONFLICT DO NOTHING;
```

### 3.3 백엔드 — `AttendanceService.java`, `LeaveService.java`
DataSet 서비스 (10개):
| service | 입력 | 출력 |
|---|---|---|
| `attendance/checkIn` | (없음) | `success`, `checkInAt` |
| `attendance/checkOut` | (없음) | `success`, `checkOutAt`, `workMinutes` |
| `attendance/searchToday` | (없음) | 오늘 row (없으면 null) |
| `attendance/searchMyMonth` | `yearMonth: '2026-04'` | 월별 30 row |
| `attendance/searchTeamDaily` | `deptId, workDate` | 팀원 일별 (부서장만) |
| `leave/searchBalance` | `year` | 잔여/사용/총 |
| `leave/searchMyHistory` | `year` | 신청 이력 |
| `leave/searchTeamCalendar` | `from, to, deptId` | 팀 부재 표시용 |
| `leave/applyFromDoc` | `docId, leaveType, fromDate, toDate, days, reason` | 결재 상신 후 호출 |
| `leave/onDocApproved` | `docId` (Flowable listener에서 호출) | balance.used_days 자동 차감 + at_attendance 의 해당일 status='LEAVE' 갱신 |

**연동 포인트**:
- `ApprovalService.submitDocument` 의 form_code='LEAVE' 분기에서 `LeaveService.applyFromDoc` 자동 호출
- `ApprovalCompleteDelegate` (Flowable) 에서 form_code='LEAVE' && status='APPROVED' 시 `LeaveService.onDocApproved` 호출
- `CalendarService.searchEvents` 에서 leave 데이터 합치기 (트랙 8 통합 단계에서 추가 — 이 트랙은 leave 데이터만 노출)

### 3.4 UI
- **`pages/PageAttendance.vue`** : 상단에 큰 출근/퇴근 버튼 + 오늘 시각 + 이번 달 출근 캘린더(작은 hex grid 5x6) + 누적 근무시간
- **`pages/PageLeave.vue`** : 상단 카드(잔여/사용/총) + DataTable 신청이력 + "휴가 신청" 버튼 → ApprovalSubmitDialog (form_code='LEAVE' 프리셋, 추가 필드 leave_type/from/to/days)
- **`components/attendance/MonthlyCalendar.vue`** : 월별 출근 시각화 (출근=초록 / 지각=노랑 / 결근=빨강 / 휴가=파랑)
- **`components/leave/LeaveBalanceCard.vue`** : Donut chart (PrimeVue Chart.js)
- **`composables/useAttendance.ts`** / **`useLeave.ts`**

### 3.5 대시보드 위젯 (트랙 7 에서 위젯 시스템에 등록될 후보)
- 출퇴근 위젯: 오늘 출근 안 했으면 "출근 체크" 큰 버튼, 했으면 시각 표시
- 잔여 연차 위젯: 숫자 + Donut 작게

### 3.6 검증 시나리오
1. admin 로그인 → /attendance → "출근" 클릭 → check_in_at 기록 → 페이지 갱신 시 "퇴근" 버튼으로 변경
2. /leave → 잔여 15.0 → "휴가 신청" → ApprovalSubmitDialog (form_code=LEAVE 자동) → from/to=2026-05-01~05-02, 2일 → 상신
3. admin (결재자) 로 승인 → balance 가 15.0 → 13.0 으로 차감
4. /attendance 의 5/1, 5/2 칸 색상이 파랑(LEAVE)으로 변경

### 3.7 TODO (병렬 진행 시 단일 에이전트)
- [x] T1-1. V10 마이그레이션 작성 (clean boot 검증은 Docker daemon 복구 후 트랙 8 에서)
- [x] T1-2. AttendanceService.java + AttendanceMapper.xml (5 service)
- [x] T1-3. LeaveService.java + LeaveMapper.xml (5 service: searchBalance/searchMyHistory/searchTeamCalendar/applyFromDoc/onDocApproved)
- [x] T1-4. ApprovalService.submitDocument 의 form_code='LEAVE' 분기 추가 (LeaveService setter 주입 + applyFromDoc 자동 호출)
- [x] T1-5. ApprovalCompleteDelegate 에 onDocApproved 호출 추가 (+ApprovalService.approve 의 allApproved 분기에서도 onDocApproved 호출 — UI 결재 시 즉시 차감)
- [x] T1-6. PageAttendance.vue + MonthlyCalendar.vue
- [x] T1-7. PageLeave.vue + LeaveBalanceCard.vue (SVG 두 원으로 Donut 구현 — 외부 라이브러리 미사용)
- [x] T1-8. useAttendance.ts / useLeave.ts
- [x] T1-9. ApprovalSubmitDialog.vue 의 LEAVE 프리셋 (initialFormCode prop + leaveType Dropdown / from-to DatePicker / days 자동계산(주말제외) / reason)
- [~] T1-10. /attendance, /leave 라우트 + 메뉴 카탈로그 §10 등록 — **트랙 8(메인) 일괄 처리** (router/menu 는 본 트랙에서 수정 금지)
- [~] T1-11. Smoke test 5종 + Playwright 시나리오 1·3 — **Docker daemon 미실행으로 deferred**, 트랙 8 에서 컨테이너 기동 후 일괄 검증
- [~] T1-12. api-catalog.md / scenarios.md 갱신 — 트랙 8 통합 시 일괄 반영

**예상 시간**: 12h

---

## 4. 트랙 2 — 회의실 예약 (Room Booking)

### 4.1 사용자 가치
- "내일 14시 대회의실 가능?" 한 번에 확인 + 예약
- 충돌 검증 자동
- 화상회의가 필요한 회의실은 LiveKit 룸 자동 생성 + 참석자에게 알림 + 캘린더 자동 등록

### 4.2 DB 스키마 (V11__room_booking.sql)
```sql
CREATE TABLE platform_v3.rm_room (
  room_id      BIGSERIAL PRIMARY KEY,
  room_name    VARCHAR(64) NOT NULL UNIQUE,
  capacity     INT NOT NULL,
  location     VARCHAR(128),
  has_video    BOOLEAN NOT NULL DEFAULT FALSE,  -- LiveKit 연동 가능
  has_phone    BOOLEAN NOT NULL DEFAULT FALSE,
  amenities    TEXT,                            -- 화이트보드/프로젝터 등 (CSV)
  active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE platform_v3.rm_booking (
  booking_id    BIGSERIAL PRIMARY KEY,
  room_id       BIGINT NOT NULL REFERENCES platform_v3.rm_room(room_id),
  booker_no     VARCHAR(32) NOT NULL,
  title         VARCHAR(128) NOT NULL,
  start_at      TIMESTAMPTZ NOT NULL,
  end_at        TIMESTAMPTZ NOT NULL,
  attendees     TEXT,                            -- CSV employee_no
  livekit_room  VARCHAR(64),                     -- 화상 룸 이름 (자동 생성)
  status        VARCHAR(16) NOT NULL DEFAULT 'BOOKED', -- BOOKED|CANCELLED|DONE
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (end_at > start_at)
);
CREATE INDEX idx_rm_booking_room_time ON platform_v3.rm_booking(room_id, start_at, end_at);
CREATE INDEX idx_rm_booking_booker ON platform_v3.rm_booking(booker_no);

-- 시드 5개
INSERT INTO platform_v3.rm_room (room_name, capacity, has_video, amenities) VALUES
  ('대회의실',     20, TRUE,  '프로젝터,화이트보드,스피커폰'),
  ('소회의실A',    8,  FALSE, '화이트보드'),
  ('소회의실B',    8,  TRUE,  'TV'),
  ('임원회의실',   12, TRUE,  '프로젝터,화이트보드,스피커폰'),
  ('화상회의실A',  6,  TRUE,  '카메라,스피커')
ON CONFLICT DO NOTHING;
```

### 4.3 백엔드 — `RoomService.java`
| service | 설명 |
|---|---|
| `room/searchRooms` | 활성 회의실 목록 |
| `room/searchAvailable` | 입력 `from, to` 기준 가용 회의실 |
| `room/searchBookings` | 입력 `roomId?, from, to` 예약 목록 |
| `room/searchMyBookings` | 내 예약 (다가오는 / 지난) |
| `room/reserve` | 예약 등록 (충돌 검증 + has_video 면 LiveKit 룸 자동 생성 + 참석자 알림 + 본인 캘린더 등록) |
| `room/cancel` | 본인 또는 관리자만 |
| `room/checkConflict` | 입력 `roomId, from, to, excludeBookingId?` → boolean |

**핵심 비즈니스**: `reserve` 가 트랜잭션으로 ① rm_booking insert ② has_video 면 BFF `LiveKitAdapter.createRoom` 호출 ③ 참석자 each `NotificationService.notifyByUserNo` ④ 본인 calendar_event insert.

### 4.4 UI
- **`pages/PageRoom.vue`** : 좌측 회의실 목록(필터: 인원/장비/화상) + 우측 FullCalendar 일/주 뷰 (timeGridWeek) — 선택 회의실의 예약 표시. 빈 슬롯 클릭 → 예약 다이얼로그.
- **`components/room/BookingDialog.vue`** : 제목 / 회의실 Dropdown / 시작-끝 DateTime / 참석자 MultiSelect (org_employee 검색) / has_video 체크박스 / "예약" 버튼
- **`components/room/RoomCard.vue`** : 회의실 정보 카드 (사이드바)

### 4.5 대시보드 위젯
- "내 다가오는 회의" 위젯 (3건)

### 4.6 검증 시나리오
1. /room → 화상회의실A 선택 → 내일 14:00~15:00 슬롯 클릭 → 다이얼로그 → 제목·참석자 입력 → 예약
2. 같은 시간 동일 회의실 다시 예약 시도 → 충돌 에러 toast
3. 참석자 user1 로 재로그인 → 알림 종에 새 알림 + /calendar 에 일정 표시
4. has_video=true 였으므로 예약 상세에 "화상회의 입장" 버튼 → /video?room=<livekit_room> 진입

### 4.7 TODO
- [x] T2-1. V11 마이그레이션 작성 (clean boot 검증은 트랙 8 / Docker 재기동 시)
- [x] T2-2. RoomService.java + RoomMapper.java/xml (7 service: searchRooms/searchAvailable/searchBookings/searchMyBookings/checkConflict/reserve/cancel)
- [x] T2-3. backend-core BffClient 신규 + RoomService.reserve 에서 BFF /api/bff/video/room 호출 (Spring 6 RestClient, 실패 시 LiveKit 자동생성으로 폴백)
- [x] T2-4. PageRoom.vue + BookingDialog.vue + RoomCard.vue
- [x] T2-5. useRoom.ts composable
- [~] T2-6. CalendarService.searchEvents 의 rm_booking UNION — 트랙 8 에서 진행 (본 트랙은 reserve 시 cal_event 자동 INSERT 까지만)
- [~] T2-7. /room 라우트 + 메뉴 카탈로그 — 트랙 8 에서 일괄 등록
- [~] T2-8. Smoke + Playwright — Docker daemon 미실행으로 트랙 8 검증 단계 deferred

**예상 시간**: 10h

---

## 5. 트랙 3 — 자료실 (Document Library)

### 5.1 사용자 가치
- 부서별/공용 폴더에 파일을 정리해서 보관
- 게시판 첨부와 다르게 "문서 그 자체가 콘텐츠" — 이름/태그/검색
- 권한: 부서원만 읽기 / 작성자만 삭제 / 관리자 전체

### 5.2 DB 스키마 (V12__data_library.sql)
```sql
CREATE TABLE platform_v3.dl_folder (
  folder_id    BIGSERIAL PRIMARY KEY,
  parent_id    BIGINT REFERENCES platform_v3.dl_folder(folder_id) ON DELETE CASCADE,
  folder_name  VARCHAR(128) NOT NULL,
  scope        VARCHAR(16) NOT NULL,    -- COMPANY|DEPT|PERSONAL
  owner_dept_id BIGINT,                  -- DEPT scope 일 때
  owner_no     VARCHAR(32),              -- PERSONAL scope 일 때
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_dl_folder_parent ON platform_v3.dl_folder(parent_id);

CREATE TABLE platform_v3.dl_file (
  file_id      BIGSERIAL PRIMARY KEY,
  folder_id    BIGINT NOT NULL REFERENCES platform_v3.dl_folder(folder_id) ON DELETE CASCADE,
  file_name    VARCHAR(256) NOT NULL,
  object_key   VARCHAR(512) NOT NULL,    -- minio: datalib/{folderId}/{filename}
  size_bytes   BIGINT NOT NULL,
  mime_type    VARCHAR(128),
  tags         VARCHAR(256),             -- CSV
  uploader_no  VARCHAR(32) NOT NULL,
  uploaded_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  download_count INT NOT NULL DEFAULT 0
);
CREATE INDEX idx_dl_file_folder ON platform_v3.dl_file(folder_id);
CREATE INDEX idx_dl_file_name ON platform_v3.dl_file(file_name);

-- 시드: COMPANY 루트 + 부서 폴더
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope) VALUES
  (1, NULL, '회사 공용', 'COMPANY')
ON CONFLICT DO NOTHING;
SELECT setval('platform_v3.dl_folder_folder_id_seq', 100);
```

### 5.3 백엔드 — `DataLibraryService.java`
| service | 설명 |
|---|---|
| `datalib/listFolders` | 폴더 트리 (사용자 권한 필터링) |
| `datalib/listFiles` | 폴더 내 파일 |
| `datalib/createFolder` | 권한 체크 (DEPT 는 본인 부서, COMPANY 는 admin) |
| `datalib/renameFolder` / `deleteFolder` | 권한 체크 |
| `datalib/uploadMeta` | UI 가 presigned PUT 후 호출 |
| `datalib/searchFiles` | 키워드 + 태그 + 폴더 |
| `datalib/getDownloadUrl` | presigned GET (다운로드 카운트 ++) |
| `datalib/deleteFile` | 권한 체크 (uploader 또는 admin) |
| `datalib/moveFile` | 폴더 변경 |

권한 헬퍼: `canAccessFolder(folderId, employeeNo)` — scope 별 분기.

### 5.4 UI
- **`pages/PageDataLibrary.vue`** : 좌측 폴더 트리 (PrimeVue Tree) + 우측 파일 DataTable (이름·크기·업로더·날짜·다운로드 버튼·삭제 버튼)
- **`components/datalib/FolderActions.vue`** : 우클릭 컨텍스트 (이름 변경 / 삭제 / 새 폴더 / 새 파일 업로드)
- 업로드는 `FileUploadPanel.vue` 재사용

### 5.5 검증 시나리오
1. /datalib → "회사 공용" 폴더 → 새 폴더 "기획문서" 생성
2. 업로드: PDF 파일 → 목록 표시
3. 다운로드: 파일 클릭 → presigned URL → 새 탭 → 다운로드 카운트 1 → 1
4. user1 로 재로그인 → 같은 폴더 보이지만 삭제 버튼 비활성

### 5.6 TODO
- [x] T3-1. V12 마이그레이션 + clean boot  (clean boot 검증은 트랙 8 에서 docker 가용 시 일괄)
- [x] T3-2. DataLibraryService.java + Mapper.xml (10 service: listFolders/listFiles/createFolder/renameFolder/deleteFolder/uploadMeta/searchFiles/getDownloadUrl/deleteFile/moveFile)
- [x] T3-3. PageDataLibrary.vue (Tree + DataTable + 검색/업로드/새 폴더/이름변경/삭제/다운로드)
- [x] T3-4. FolderActions.vue (ContextMenu)
- [x] T3-5. useDataLibrary.ts
- [~] T3-6. /datalib 라우트 + 메뉴 등록 — **트랙 8 에서 일괄 (router/index.ts·cm_menu)**
- [~] T3-7. Smoke + Playwright 시나리오 1·3 — Docker daemon 미실행 환경, 트랙 8 클린 부팅 후 일괄 검증

**예상 시간**: 10h

---

## 6. 트랙 4 — 업무일지 (Work Report)

### 6.1 사용자 가치
- 매일 5분, "오늘 한 일 / 내일 할 일 / 이슈" 기록
- 부서장은 팀원 일지 한 화면에서 조회
- 주간 리포트 자동 합산 (월~금)

### 6.2 DB 스키마 (V13__work_report.sql)
```sql
CREATE TABLE platform_v3.wr_daily (
  report_id    BIGSERIAL PRIMARY KEY,
  employee_no  VARCHAR(32) NOT NULL,
  report_date  DATE NOT NULL,
  done_today   TEXT,
  plan_tomorrow TEXT,
  issue        TEXT,
  mood         VARCHAR(16),               -- GOOD|NORMAL|BAD (선택)
  hours_worked NUMERIC(4,1),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (employee_no, report_date)
);
CREATE INDEX idx_wr_daily_emp_date ON platform_v3.wr_daily(employee_no, report_date DESC);
```

### 6.3 백엔드 — `WorkReportService.java`
| service | 설명 |
|---|---|
| `worklog/saveDaily` | upsert (UNIQUE 제약 활용) |
| `worklog/searchMyWeek` | 입력 `weekStart` 7일 |
| `worklog/searchTeamDaily` | 부서장 전용, 팀원 N명 × 1일 |
| `worklog/searchTeamWeekly` | 부서장 전용, 팀원 N명 × 7일 |
| `worklog/searchMonth` | 본인 월별 |

### 6.4 UI
- **`pages/PageWorkLog.vue`** : 좌측 캘린더 미니뷰 (날짜 선택) + 우측 폼 (오늘 한 일 / 내일 할 일 / 이슈 / 기분) + 저장 버튼. 부서장 토글 시 팀 뷰로 전환 (DataTable: 행=직원, 열=요일).
- **`components/worklog/DailyEditor.vue`**

### 6.5 검증 시나리오
1. /worklog → 오늘 → 내용 입력 → 저장 → "저장됨" toast
2. 새로고침 → 입력값 유지
3. admin (부서장) 로 팀 뷰 토글 → 부서원 일지 한 화면

### 6.6 TODO
- [x] T4-1. V13 마이그레이션 (wr_daily UNIQUE(employee_no, report_date) + 인덱스 + 검증 시드 4건)
- [x] T4-2. WorkReportService.java + Mapper.xml (5 service: saveDaily/searchMyWeek/searchTeamDaily/searchTeamWeekly/searchMonth) + 부서장 가드(ROLE_ADMIN/ROLE_MGR + dept head + position_level 임계치 30)
- [x] T4-3. PageWorkLog.vue + DailyEditor.vue (좌측 inline DatePicker dot + 우측 폼 / 팀 뷰 DataTable 5칸 + readonly Dialog)
- [x] T4-4. useWorkLog.ts (toMondayOfWeek/ymd/ymOf util 포함)
- [~] T4-5. /worklog 라우트 + 메뉴 등록 — **트랙 8(메인) 일괄 처리** (router/index.ts 수정 금지)
- [~] T4-6. Smoke + Playwright 시나리오 1 — **Docker daemon 미실행으로 deferred** (트랙 8 클린 부팅 시점 검증)

**예상 시간**: 8h

---

## 7. 트랙 5 — 시스템 관리자 페이지 (Admin Console)

### 7.1 사용자 가치
- 관리자가 GUI 만으로 운영: 사용자 추가 / 부서 변경 / 메뉴 권한 / 공통 코드
- 모든 변경은 `sa_audit` 에 자동 로깅

### 7.2 DB 스키마 (V14__admin_audit.sql)
```sql
CREATE TABLE platform_v3.sa_audit (
  audit_id     BIGSERIAL PRIMARY KEY,
  actor_no     VARCHAR(32) NOT NULL,
  actor_name   VARCHAR(64) NOT NULL,
  action       VARCHAR(32) NOT NULL,    -- CREATE_USER|UPDATE_DEPT|...
  target_type  VARCHAR(32),
  target_id    VARCHAR(64),
  before_json  JSONB,
  after_json   JSONB,
  ip_addr      VARCHAR(45),
  acted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_sa_audit_actor_time ON platform_v3.sa_audit(actor_no, acted_at DESC);
CREATE INDEX idx_sa_audit_target ON platform_v3.sa_audit(target_type, target_id);
```

기존 테이블 (`org_employee`, `org_dept`, `cm_menu`, `cm_menu_permission`, `cm_code`) 활용.

### 7.3 백엔드 — `AdminService.java` (네임스페이스 `admin/*`, 전부 ROLE_ADMIN 한정)
| service | 설명 |
|---|---|
| `admin/userList` | 검색·페이징 |
| `admin/userSave` | upsert + Keycloak 사용자 생성/수정(BFF 경유) + sa_audit |
| `admin/userToggleActive` | activate/deactivate |
| `admin/userResetPwd` | Keycloak temp 패스워드 발행 (BFF 경유) |
| `admin/deptTree` | 트리 |
| `admin/deptSave` | upsert + sa_audit |
| `admin/menuList` / `menuSave` / `menuDelete` | 메뉴 CRUD |
| `admin/permSave` | menu × role 권한 매트릭스 |
| `admin/codeGroupList` / `codeList` / `codeSave` / `codeDelete` | 공통코드 CRUD |
| `admin/auditSearch` | 감사 로그 페이징 |

**Keycloak 연동**: BFF 의 `KeycloakIdentityAdapter` 에 `createUser`, `updateUser`, `setActive`, `resetPassword` 추가. backend-core 가 BFF 호출. (admin REST: `POST /admin/realms/openplatform-v3/users` with admin token via client-credentials).

### 7.4 UI
- **`pages/admin/PageUsers.vue`** : DataTable + 검색 + 추가/편집 다이얼로그 (이름/사번/이메일/부서/직책/Keycloak 사용자명/역할 MultiSelect)
- **`pages/admin/PageDepts.vue`** : Tree + 좌클릭 편집
- **`pages/admin/PageMenus.vue`** : Tree (메뉴 계층) + 우측 권한 매트릭스 (역할 × R/W/U/D)
- **`pages/admin/PageCodes.vue`** : 좌측 그룹코드 목록 + 우측 상세 코드 목록
- **`pages/admin/PageAudit.vue`** : 감사 로그 (필터: 작업자 / 액션 / 기간)

### 7.5 검증 시나리오
1. /admin/users → "추가" → 이름/사번/이메일/부서 입력 → 저장 → Keycloak 에 사용자 생성 + DB org_employee row 생성 + sa_audit 1건
2. /admin/audit → 방금 작업이 1건 표시
3. /admin/menus → 새 메뉴 "테스트" 추가 → 권한 ROLE_USER=R 부여 → user1 로그인 시 메뉴 표시
4. user1 로 /admin/users 직접 접근 → /403 리다이렉트

### 7.6 TODO
- [x] T5-1. V14 마이그레이션 (sa_audit + 시드 5건)
- [x] T5-2. AdminService.java + AdminMapper.xml (14 service: userList/Save/ToggleActive/ResetPwd, deptTree/Save, menuList/Save/Delete/permSave, codeGroupList/codeList/codeSave/codeDelete, auditSearch)
- [x] T5-3. BFF KeycloakIdentityAdapter 확장 (createUser/updateUser/setActive/resetPassword) + BffController POST/PUT /api/bff/identity/users routes
- [x] T5-4. PageUsers / PageDepts / PageMenus / PageCodes / PageAudit (5 페이지) + useAdmin.ts
- [x] T5-5. AdminAuditAspect (Spring AOP @Around — admin/* prefix 한정, 정상 종료만 기록, JSON 16KB truncation, IP/actor 추출)
- [x] T5-6. useAdmin.ts
- [~] T5-7. /admin/* 라우트 + 메뉴 등록 + Router 가드 강화 — **트랙 8 일괄 처리 대상** (본 트랙은 페이지/composable 까지만 작성, router/index.ts 수정 금지)
- [~] T5-8. Smoke + Playwright 시나리오 1·2·4 — Docker daemon 미실행으로 deferred (트랙 8 클린 부팅 시점 검증)

**예상 시간**: 16h (트랙 중 가장 큼)

---

## 8. 트랙 6 — UX 강화: 통합검색 / 즐겨찾기 / 알림설정

### 8.1 사용자 가치
- 헤더 검색창 1개로 게시글·결재·사람·메일 통합 검색
- 자주 가는 메뉴/문서를 즐겨찾기 → 헤더 옆 빠른 접근
- 알림을 어디로 받을지 선택 (포탈 / 이메일 / 메신저 DM)

### 8.2 DB 스키마 (V15__ux_features.sql)
```sql
CREATE TABLE platform_v3.ux_favorite (
  fav_id       BIGSERIAL PRIMARY KEY,
  employee_no  VARCHAR(32) NOT NULL,
  target_type  VARCHAR(16) NOT NULL,    -- MENU|POST|DOC|EMPLOYEE
  target_id    VARCHAR(64) NOT NULL,
  label        VARCHAR(128),
  url          VARCHAR(256),
  sort_order   INT NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (employee_no, target_type, target_id)
);

CREATE TABLE platform_v3.ux_notify_pref (
  pref_id      BIGSERIAL PRIMARY KEY,
  employee_no  VARCHAR(32) NOT NULL,
  category     VARCHAR(32) NOT NULL,   -- APPROVAL|BOARD|CALENDAR|MENTION|ROOM|...
  channel      VARCHAR(16) NOT NULL,   -- PORTAL|EMAIL|MESSENGER
  enabled      BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (employee_no, category, channel)
);

-- 검색은 별도 인덱스 테이블 없이 PG 의 ILIKE + UNION 으로 처리 (50명 규모면 충분).
-- 추후 필요 시 pg_trgm 또는 OpenSearch 추가.
```

### 8.3 백엔드
- `SearchService.java` — `ux/search?q=keyword&types=POST,DOC,EMP` → 4 도메인 UNION (각 LIMIT 10)
- `FavoriteService.java` — `ux/listFavorites`, `ux/addFavorite`, `ux/removeFavorite`, `ux/reorder`
- `NotifyPrefService.java` — `ux/getNotifyPref`, `ux/saveNotifyPref` (matrix)
- `NotificationService.notifyByUserNo` 확장: 카테고리 입력받아 ux_notify_pref 조회 후 채널별 분기 (PORTAL=기존 SSE, EMAIL=Stalwart 발송, MESSENGER=Rocket.Chat DM via BFF)

### 8.4 UI
- **`components/layout/SearchBar.vue`** : 헤더에 통합 검색 입력 + Overlay 결과 (4 그룹 탭) — `LayoutHeader.vue` 에 마운트
- **`components/layout/FavoriteRail.vue`** : 헤더 우측에 ★ 아이콘들 (최대 8개) — 클릭 시 라우팅
- **`pages/PageSearch.vue`** : 풀 검색 결과 페이지 (헤더 결과 "더보기" 클릭 시)
- **`pages/PageNotifySettings.vue`** : 카테고리 × 채널 매트릭스 토글 (DataTable)
- **`pages/PageFavorites.vue`** : 즐겨찾기 관리 (드래그 정렬)

### 8.5 검증 시나리오
1. 헤더 검색창에 "휴가" 입력 → 결재 1건 + 게시글 1건 표시
2. 결재 상세에 ★ 추가 → 헤더 ★ 레일에 노출
3. /settings/notify → 결재 알림 EMAIL 끄기 → 결재 발생 시 이메일 발송 안 됨 (로그 확인)

### 8.6 TODO
- [x] T6-1. V15 마이그레이션 (ux_favorite + ux_notify_pref + 검증용 시드)
- [x] T6-2. SearchService / FavoriteService / NotifyPrefService + UxMapper.java/xml
- [x] T6-3. NotificationService 채널 분기 추가 — `notifyByUserNo(...)` 옵셔널 `category` 오버로드(기존 시그니처 호환), PORTAL/EMAIL/MESSENGER 분기. BffClient 에 `sendNotificationEmail` (BFF `/api/bff/mail/send` 경유) 추가. `sendNotificationDm` 은 RocketChatAdapter 의 sendDm 메서드가 미구현(stub) 이므로 warn 로그 후 스킵 (warn.md 기록)
- [x] T6-4. SearchBar.vue 신규 작성 — InputText + OverlayPanel + 4탭(게시글/결재/사람/파일). LayoutHeader 마운트는 트랙 8
- [~] T6-5. FavoriteRail.vue 신규 작성 — 가로 ★ 아이콘 레일 + 관리 버튼. ★ 토글 버튼(결재상세/게시글상세) 및 LayoutHeader 마운트는 트랙 8
- [x] T6-6. PageSearch.vue / PageNotifySettings.vue / PageFavorites.vue + useUx.ts (드래그 정렬은 npm 추가 금지로 ▲▼ 화살표 버튼 + reorder 일괄 호출 채택)
- [~] T6-7. /search, /settings/notify, /settings/favorites 라우트 + 메뉴 등록 — **트랙 8 일괄**
- [~] T6-8. Smoke + Playwright 시나리오 1·2 — Docker daemon 미실행으로 deferred (트랙 8 클린 부팅 시점 검증)

**예상 시간**: 12h

---

## 9. 트랙 7 — 대시보드 위젯 시스템 (Customizable Dashboard)

### 9.1 사용자 가치
- 위젯을 사용자가 추가/제거/배치 가능
- "내가 자주 보는 정보를 한 화면에"

### 9.2 DB 스키마 (V16__dashboard_widget.sql)
```sql
CREATE TABLE platform_v3.db_widget (
  widget_code  VARCHAR(32) PRIMARY KEY,    -- ATTENDANCE|LEAVE_BALANCE|PENDING_APPROVAL|TODAY_EVENTS|NOTICES|MESSENGER_UNREAD|MY_ROOMS|TEAM_WORKLOG|FAVORITES|CHART_LEAVE_USAGE
  title        VARCHAR(64) NOT NULL,
  description  VARCHAR(256),
  default_w    INT NOT NULL DEFAULT 1,     -- grid columns 1~3
  default_h    INT NOT NULL DEFAULT 1,     -- grid rows 1~2
  category     VARCHAR(32),                -- WORK|PERSONAL|TEAM
  active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE platform_v3.db_user_widget (
  id           BIGSERIAL PRIMARY KEY,
  employee_no  VARCHAR(32) NOT NULL,
  widget_code  VARCHAR(32) NOT NULL REFERENCES platform_v3.db_widget(widget_code),
  pos_x        INT NOT NULL,
  pos_y        INT NOT NULL,
  width        INT NOT NULL,
  height       INT NOT NULL,
  config_json  JSONB,
  UNIQUE (employee_no, widget_code)
);

INSERT INTO platform_v3.db_widget (widget_code, title, default_w, default_h, category) VALUES
  ('ATTENDANCE',         '출퇴근',        1, 1, 'PERSONAL'),
  ('LEAVE_BALANCE',      '연차 잔여',      1, 1, 'PERSONAL'),
  ('PENDING_APPROVAL',   '미결 결재',      1, 1, 'WORK'),
  ('TODAY_EVENTS',       '오늘 일정',      2, 1, 'WORK'),
  ('NOTICES',            '최근 공지',      2, 1, 'WORK'),
  ('MESSENGER_UNREAD',   '메신저',         1, 1, 'WORK'),
  ('MY_ROOMS',           '다가오는 회의',   2, 1, 'WORK'),
  ('TEAM_WORKLOG',       '팀 업무일지',    3, 1, 'TEAM'),
  ('CHART_LEAVE_USAGE',  '연차 사용 추이', 2, 1, 'PERSONAL')
ON CONFLICT DO NOTHING;
```

### 9.3 백엔드 — `WidgetService.java`
| service | 설명 |
|---|---|
| `widget/listAll` | 위젯 카탈로그 |
| `widget/listMine` | 내 위젯 (배치/설정 포함) |
| `widget/saveLayout` | 위치/크기 일괄 저장 |
| `widget/addWidget` / `removeWidget` | 단건 |

### 9.4 UI — Dashboard 재작성
- **`pages/PageDashboard.vue`** : Grid 레이아웃 (vue-grid-layout 또는 자체 CSS Grid + drag) — 첫 로그인 시 default 6 위젯 자동 배치
- **`components/dashboard/widgets/`** :
  - WidgetAttendance.vue / WidgetLeaveBalance.vue / WidgetPendingApproval.vue / WidgetTodayEvents.vue / WidgetNotices.vue / WidgetMessenger.vue / WidgetMyRooms.vue / WidgetTeamWorklog.vue / WidgetLeaveChart.vue
- **편집 모드**: 우상단 "편집" 토글 → 위젯 드래그 가능 + 추가 버튼 + 삭제 X 표시 → 저장 버튼

### 9.5 검증 시나리오
1. 첫 로그인 → 6 default 위젯 표시
2. 편집 모드 → "팀 업무일지" 추가 → 저장
3. 새로고침 → 추가된 위젯 유지
4. 출퇴근 위젯에서 출근 클릭 → 트랙 1 의 attendance/checkIn 호출

### 9.6 TODO
- [x] T7-1. V16 마이그레이션
- [x] T7-2. WidgetService.java + Mapper
- [x] T7-3. PageDashboard.vue 재작성 (grid + 편집모드)
- [x] T7-4. 위젯 9종 컴포넌트 (각각 트랙 1~6 의 service 호출)
- [x] T7-5. useWidget.ts
- [x] T7-6. (vue-grid-layout-next 또는 동등) 의존성 추가 — 자체 CSS Grid 12-column + 화살표 버튼(이동·리사이즈) + 카탈로그 picker 채택. npm 패키지 추가 없음.
- [~] T7-7. Smoke + Playwright 시나리오 1·2·3 — Docker daemon 미실행으로 SKIP. 트랙 8 통합 후 수행.

**예상 시간**: 14h

**의존성**: 트랙 1·2·4·6 의 서비스가 존재해야 위젯이 데이터를 받을 수 있음. **병렬 진행 시 트랙 7은 가장 마지막에 시작** (또는 1·2·4 가 최소 백엔드까지 끝난 후).

---

## 10. 트랙 8 — 통합·메뉴 카탈로그·공통 보안 (메인 세션 전담)

### 10.1 책임
다른 모든 트랙이 끝난 후, 메인 세션이 직접 수행:
1. **메뉴 일괄 등록** (cm_menu + cm_menu_permission)
2. **Router 등록** (ui/src/router/index.ts) — 트랙별로 별도 등록도 가능하나 충돌 방지 위해 일괄
3. **CalendarService 통합** — leave / room booking 데이터 합치기
4. **첨부 권한 검증 sweep** (warn.md 기재된 잔여)
5. **F-9 보안 sweep**: directAccessGrantsEnabled 재확인, 개발용 토큰 누설 점검
6. **회귀 E2E** — Phase 13 의 C1~C6 + Phase 14 의 모든 트랙 시나리오 1개씩 통과
7. **클린 부팅 검증** (DESTRUCTIVE: `docker compose down -v && up -d`) — Flyway V1~V16 모두 success
8. **README.md / docs/api-catalog.md / docs/scenarios.md 갱신**
9. **info.md / TODO.md 최종 동기화 + warn.md 정리**
10. **최종 보고서**: `docs/PHASE14_REPORT.md` 작성 (전·후 비교, 추가된 service 수, 추가된 페이지 수, E2E 통과 수, 잔여 이슈)

### 10.2 메뉴 등록 카탈로그 (V## 마이그레이션 또는 어드민 화면 통해)
| menu_id | 부모 | 라벨 | url | sort | 권한 (R) |
|---|---|---|---|---|---|
| `attendance`     | mywork  | 근태       | /attendance | 10 | USER,MGR,ADMIN |
| `leave`          | mywork  | 연차/휴가  | /leave | 11 | USER,MGR,ADMIN |
| `room`           | work    | 회의실예약 | /room | 20 | USER,MGR,ADMIN |
| `datalib`        | work    | 자료실     | /datalib | 25 | USER,MGR,ADMIN |
| `worklog`        | mywork  | 업무일지   | /worklog | 12 | USER,MGR,ADMIN |
| `admin_users`    | admin   | 사용자관리 | /admin/users | 90 | ADMIN |
| `admin_depts`    | admin   | 조직관리   | /admin/depts | 91 | ADMIN |
| `admin_menus`    | admin   | 메뉴관리   | /admin/menus | 92 | ADMIN |
| `admin_codes`    | admin   | 공통코드   | /admin/codes | 93 | ADMIN |
| `admin_audit`    | admin   | 감사로그   | /admin/audit | 94 | ADMIN |
| `search`         | (top)   | 검색       | /search | 5  | USER,MGR,ADMIN |
| `settings_notify`| settings| 알림설정   | /settings/notify | 80 | USER,MGR,ADMIN |
| `settings_fav`   | settings| 즐겨찾기   | /settings/favorites | 81 | USER,MGR,ADMIN |

`mywork`/`work`/`admin`/`settings` 부모 메뉴가 없으면 함께 INSERT.

### 10.3 TODO (트랙 8)
- [ ] T8-1. 트랙 1~7 의 결과 검수 (각자 §"검증 시나리오" 통과 여부 확인)
- [ ] T8-2. 메뉴/권한 일괄 INSERT (V17__phase14_menus.sql)
- [ ] T8-3. Router 일괄 합치기 (각 트랙이 라우트 정의를 별도 파일로 export 했다면 import + spread)
- [ ] T8-4. CalendarService 통합 (leave/room 데이터 UNION)
- [ ] T8-5. 첨부 권한 검증 — `BoardService.getAttachmentDownloadUrl` / `DataLibraryService.getDownloadUrl` / `ApprovalService.getAttachmentDownloadUrl` 권한 체크 보강
- [ ] T8-6. 클린 부팅 검증 (down -v / up -d / Flyway 확인)
- [ ] T8-7. Phase 13 회귀 (C1~C6) + Phase 14 시나리오 8개 (각 트랙 1개) Playwright MCP
- [ ] T8-8. docs/api-catalog.md 갱신 (신규 service 50+ 라인)
- [ ] T8-9. docs/scenarios.md 에 8개 신규 시나리오 추가
- [ ] T8-10. README.md 의 §7 시드 카운트 갱신
- [ ] T8-11. docs/PHASE14_REPORT.md 작성
- [ ] T8-12. TODO.md / info.md / warn.md 최종 정리

**예상 시간**: 8h

---

## 11. 진행 순서 요약

### 11.1 Mode A (순차)
T1 → T2 → T5 (큰 트랙 먼저) → T3 → T4 → T6 → T7 → T8
*총 약 90h.*

### 11.2 Mode B (병렬, 권장)
**Wave 1 (4 동시 시작)**: T1·T2·T3·T5
**Wave 2 (전 wave 완료 후)**: T4·T6·T7
**Wave 3 (메인)**: T8

각 wave 시작 시 메인 세션이 `Agent` (subagent_type=general-purpose) 4개를 단일 메시지로 spawn. 각 에이전트 프롬프트는:
```
docs/PHASE14_PRODUCTION_GROUPWARE.md 의 §0~§2 를 먼저 읽고,
§{해당트랙섹션} 만 수행. 다른 트랙은 건드리지 말 것.
TODO 체크박스를 [x] 로 갱신하면서 진행.
완료 시 짧은 보고서 (변경 파일 목록 + 검증 결과 + 잔여 이슈).
```

*Mode B 총 wall-clock: 약 30~36h (4 동시 + 직렬 wave).*

---

## 12. 리스크 & 대응

| 리스크 | 대응 |
|---|---|
| 트랙 간 라우트/메뉴 ID 충돌 | §1.4 + §10.2 카탈로그를 본 문서 단일 소스로 사용 |
| Flyway 버전 충돌 | §1.1 의 V10~V16 분배 엄수. 이미 같은 V## 가 있으면 V##.1 patch 형태로 |
| Keycloak 사용자 생성 실패 (트랙 5) | BFF KeycloakIdentityAdapter 가 admin token client_credentials 로 발급 — `infra/keycloak/realm-export.json` 의 `realm-management` 클라이언트 활용 |
| LiveKit 룸 자동 생성 실패 (트랙 2) | `view-only` 폴백 (Phase 12.1 패턴) — 예약은 성공, 화상은 입장 시 재시도 |
| 위젯 드래그 라이브러리 부재 (트랙 7) | vue-grid-layout-next 추가 또는 자체 CSS Grid (후자 default) |
| 50명 규모 검색 성능 (트랙 6) | ILIKE + LIMIT 20 으로 충분. 100명+ 되면 pg_trgm 인덱스 |
| 클린 부팅 실패 | warn.md 기록 후 영향받는 V## 만 dryRun 분리 검증 |

---

## 13. 완료 후 산출물 (Phase 14 종료 시)

- DB: 17 → 23 테이블 (+`at_*`/`rm_*`/`dl_*`/`wr_*`/`sa_audit`/`ux_*`/`db_*`)
- DataSet service: 37 → 약 90+ (트랙별 5~12개 합산)
- UI 페이지: 11 → 약 26 (`/attendance`,`/leave`,`/room`,`/datalib`,`/worklog`,`/admin/{users,depts,menus,codes,audit}`,`/search`,`/settings/{notify,favorites}` + 위젯 시스템화된 dashboard)
- 신규 메뉴: 13개 (cm_menu)
- Playwright 시나리오: Phase 13 의 6개 + 신규 8개 = 14개 통과
- 산출 문서: PHASE14_REPORT.md (메인 결과), api-catalog.md / scenarios.md / README 갱신

---

## 14. 시작하는 법 (다음 세션의 첫 메시지)

```
docs/PHASE14_PRODUCTION_GROUPWARE.md 진행해.
- 가용 시간 충분하면 Mode B (병렬). 그렇지 않으면 Mode A.
- §2 전제 검증부터 시작.
- 자율 결정 모두 warn.md 기록.
- 끝나면 docs/PHASE14_REPORT.md 보여줘.
```

이 한 메시지면 본 문서 전체가 자동 실행된다.

---

_Phase 14 prompt — 2026-04-27 작성. 본 문서 수정 시 §10.2 메뉴 카탈로그·§1.1 Flyway 버전 표를 가장 먼저 검토할 것._
