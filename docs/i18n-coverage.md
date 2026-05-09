# i18n Coverage — 4 언어(ko/en/zh/ja) 보강 결과

## 요약

| 항목 | 값 |
|---|---|
| 백엔드 엔드포인트 | `GET /api/labels?locale={ko,en,zh,ja}` (신규, permitAll) |
| 응답 형태 | `{ success: true, data: { msgKey: text, ... } }` (단일 평면 맵) |
| DB 테이블 | `platform_v3.cm_i18n_message(msg_key, locale, msg_type, message)` |
| 4 언어 총 행 수 | 1,672 행 |

## 카테고리별 키 수

| msg_type | 행 수 | 키 수 (행/4) | 용도 |
|---|---:|---:|---|
| LABEL | 690 | 173 | 페이지 제목, 폼 라벨, 다이얼로그 헤더, 카드 제목 |
| MSG | 244 | 61 | 토스트 / 확인 / 검증 / 오류 메시지 |
| GRID_COL | 176 | 44 | DataTable 컬럼 헤더 |
| BUTTON | 136 | 34 | 페이지/다이얼로그 액션 버튼 |
| MENU | 122 | 31 | 사이드바 메뉴명 (V9 기본 9 + V18 신규 22) |
| PLACEHOLDER | 104 | 26 | 검색/입력 placeholder |
| STATUS | 96 | 24 | 결재/결재선/근태/휴가/사용자 상태 라벨 |
| FORM | 44 | 11 | 결재 양식 코드명 |
| BOX | 36 | 9 | 결재함 9-box |
| LEAVE_TYPE | 24 | 6 | 휴가 유형 |
| **합계** | **1,672** | **419** | |

## 변환된 파일

### 백엔드
- `backend-core/.../i18n/I18nService.java` — `getLabelMap(locale)` 추가 (msgKey → message 평면 맵)
- `backend-core/.../i18n/LabelsController.java` (신규) — `/api/labels?locale=xx`
- `backend-core/.../config/SecurityConfig.java` — `/api/labels` permitAll
- `backend-core/.../db/migration/V18__i18n_phase14_and_columns.sql` (신규)

### 프론트엔드 — 핵심 페이지/다이얼로그 (S2 1차 범위)
- `ui/src/pages/PageApproval.vue` — h2/box 라벨/그리드 헤더/status/form 변환
- `ui/src/pages/PageBoard.vue` — h2/그리드/boardType/placeholder
- `ui/src/pages/PageCalendar.vue` — h2/scope filter/locale
- `ui/src/pages/PageOrg.vue` — h2/검색
- `ui/src/pages/PageMessenger.vue` — h2
- `ui/src/pages/PageWiki.vue` — h2
- `ui/src/pages/PageVideo.vue` — h2
- `ui/src/pages/PageAttendance.vue` — h2/status/통계 라벨/버튼/메시지
- `ui/src/pages/PageLeave.vue` — h2/그리드/leaveType/status/empty
- `ui/src/pages/admin/PageUsers.vue` — h2/그리드/다이얼로그 폼/메시지
- `ui/src/pages/admin/PageDepts.vue` — h2/트리/폼/메시지
- `ui/src/pages/admin/PageMenus.vue` — h2/트리/폼/권한 매트릭스/메시지
- `ui/src/pages/admin/PageCodes.vue` — h2/그리드/다이얼로그/메시지
- `ui/src/pages/admin/PageAudit.vue` — h2/그리드/상세 다이얼로그
- `ui/src/components/approval/ApprovalLineTimeline.vue` — statusLabel
- `ui/src/components/approval/ApprovalActionBar.vue` — 5 액션 버튼/대결 다이얼로그/검증 메시지
- `ui/src/components/approval/ApprovalSubmitDialog.vue` — 헤더/폼 라벨/leaveType/검증 메시지
- `ui/src/components/board/BoardFormDialog.vue` — 헤더/폼 라벨/검증
- `ui/src/components/layout/LayoutSidebar.vue` — `menuLabel(m) = t('MENU_'+menuId.toUpperCase(), menuName)`

### 잔여 (S2 후속 — 단순 헤더 위주)
- `ui/src/pages/PageMail.vue`, `PageDashboard.vue`, `PageSearch.vue`, `PageNotifySettings.vue`, `PageFavorites.vue`, `PageRoom.vue`, `PageDataLibrary.vue`, `PageWorkLog.vue`, `PageLogin.vue`, `Page403.vue`
- `ui/src/components/{approval/ApprovalDetailDialog, board/BoardDetailDialog, calendar/CalendarEventDialog, org/EmployeeDetailDialog, mail/ComposeDialog, room/BookingDialog}.vue`

이 파일들은 헤더/그리드/공통 다이얼로그 패턴이 동일하므로 S2 1차 변환 후 후속 PR 에서 같은 키 셋으로 일괄 적용 가능.

## 검증 결과

### 백엔드 4 언어 샘플 응답 (자동 검증, 2026-05-09)
```
=== ko ===                       === en ===                  === zh ===                === ja ===
LBL_PAGE_APPROVAL=전자결재       Approval                    电子审批                  電子決裁
MENU_ATTENDANCE=근태             Attendance                  考勤                      勤怠
COL_USER_NO=사번                 Emp. No.                    工号                      社員番号
BTN_CHECK_IN=출근                Check In                    签到                      出勤
STATUS_APP_DOC_PENDING=대기      Pending                     待审批                    保留
LEAVE_TYPE_ANNUAL=연차           Annual                      年假                      年次
MSG_SAVE_DONE=저장 완료          Saved                       已保存                    保存完了
```

### 프론트 검증 (수동 — 후속)
- ko/en/zh/ja 토글 시 사이드바·그리드·다이얼로그·메시지 즉시 갱신 확인
- 5 페이지(/approval, /board, /admin/users, /admin/codes, /attendance) 대표 스크린샷 4 × 5 = 20 장 권장

## 키 명명 규칙 (V18 기준)

| 패턴 | 용도 | 예 |
|---|---|---|
| `LBL_PAGE_*` | 페이지 H2 제목 | `LBL_PAGE_APPROVAL`, `LBL_PAGE_ADMIN_USERS` |
| `LBL_*` | 라벨/카드 제목/폼 라벨 | `LBL_APPROVAL_SUBMIT_HEADER`, `LBL_USER_NAME_REQ` |
| `COL_{도메인}_{필드}` | DataTable 컬럼 헤더 | `COL_APPROVAL_NO`, `COL_BOARD_VIEWS` |
| `BTN_*` | 버튼 라벨 | `BTN_APPROVE`, `BTN_NEW_DOC`, `BTN_CHECK_IN` |
| `PH_*` | placeholder | `PH_APPROVAL_SEARCH`, `PH_FORM_SELECT` |
| `STATUS_{도메인}_{값}` | 상태 라벨 | `STATUS_APP_DOC_PENDING`, `STATUS_ATT_LATE` |
| `FORM_*` | 결재 양식 코드명 | `FORM_LEAVE`, `FORM_BIZTRIP_FULL` |
| `BOX_*` | 결재함 9-box | `BOX_PENDING`, `BOX_CC_BOX` |
| `LEAVE_TYPE_*` | 휴가 유형 | `LEAVE_TYPE_ANNUAL` |
| `MSG_*` | 토스트/확인/오류 메시지 | `MSG_APPROVAL_WITHDRAW_CONFIRM` |
| `MENU_*` | 사이드바 메뉴명 (menuId 대문자) | `MENU_ATTENDANCE`, `MENU_ADMIN_USERS` |
| `ROLE_*_NAME` | 역할 표시명 | `ROLE_ADMIN_NAME` |

## 사용 패턴

```vue
<script setup>
import { useLabel } from '@/composables/useLabel'
const { t } = useLabel()
</script>
<template>
  <h2>{{ t('LBL_PAGE_APPROVAL') }}</h2>
  <Button :label="t('BTN_NEW_DOC')" />
  <Column field="docId" :header="t('COL_APPROVAL_NO')" />
  <Tag :value="t('STATUS_APP_DOC_' + status, status)" />
</template>
```

```ts
// 메시지 + 파라미터 치환
alert(t('MSG_APPROVAL_RESUBMIT_DONE').replace('{id}', String(docId)))
alert(t('MSG_USER_TOGGLE_CONFIRM').replace('{name}', user.employeeName))
```
