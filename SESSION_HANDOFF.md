# SESSION_HANDOFF — openplatform v3 Phase A 진행중 체크포인트

**작성**: 2026-04-16 (Phase A 백엔드 90% + 프론트 핵심 헬퍼 완료 시점)
**다음 세션**: 이 문서 1개 + `TODO.md` + `warn.md` 만 읽으면 5분 안에 컨텍스트 복원 가능.

---

## 1. 큰 그림 (전체 100h 플랜에서 어디?)

**플랜 파일**: `C:\Users\hyunsu_choi\.claude\plans\magical-fluttering-wombat.md` (Phase 0~H 전체 설계)

**진행률**: ~25% (Phase 0 + Phase A 백엔드 + 프론트 헬퍼 일부)

```
[████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 100h 중 ≈25h
Phase 0  ✅ Identity & Schema (6h)
Phase A  🔄 결재 프로덕션 (24h 중 약 12h)
   ├─ V8 마이그레이션         ✅
   ├─ 백엔드 6 신규 메서드      ✅ (PA-1)
   ├─ Mapper SQL 확장          ✅ (PA-2)
   ├─ useApproval composable   ✅ (PA-9)
   ├─ ApprovalLineTimeline    ✅ (PA-6)
   ├─ ApprovalActionBar       ✅ (PA-7)
   ├─ PageApproval 재작성       ⏳ (PA-3) 다음 작업
   ├─ ApprovalDetailDialog    ⏳ (PA-4) 다음 작업
   ├─ ApprovalSubmitDialog    ⏳ (PA-5) 다음 작업
   ├─ ApprovalAttachmentList  ⏳ (PA-8) 다음 작업
   └─ Playwright A1~A3        ⏳ (PA-11)
Phase B  ⏳ 게시판 (14h)
Phase C  ⏳ 캘린더 (10h)
Phase D  ⏳ 조직도 (6h)
Phase E  ⏳ 대시보드 + SSE 알림센터 (8h, A 와 병행)
Phase F  ⏳ 공통 인프라 + i18n 4언어 (10h)
Phase G  ⏳ 백엔드 DataSet 보강 (A/B/E 흡수)
Phase H  ⏳ 메일 포탈 내부 UI (18h)
```

---

## 2. Phase 0 — 완료된 핵심 결정사항 (변경 금지)

### 2.1 Identity 정규화 패턴 (전체 시스템의 단일 진실)

**문제**: Keycloak 의 `preferred_username = admin` 과 도메인 DB 의 `org_employee.employee_no = E0001` 이 다른 식별자였음. 모든 도메인 서비스가 employee_no 로 작동해야 하므로 정규화가 필수.

**해결**:
1. `org_employee.keycloak_user_id` 컬럼 (이미 V2 에 존재) 을 **권위 있는 매핑**으로 사용
2. `OrgMapper.findEmployeeByKeycloakUserId(keycloakUsername)` 신규 — full row 반환
3. `OrgMapper.findEmployeeByNo(employeeNo)` 신규 — employee_no 로 직접 조회
4. `DataSetController.currentUser()` 가 항상 employee_no 를 반환:
   ```
   JWT preferred_username → OrgMapper.findEmployeeByKeycloakUserId → employee_no
   매핑 실패 시 fallback: 원본 username 그대로
   ```
5. **결과**: 모든 `@DataSetServiceMapping` 메서드의 `currentUser` 매개변수는 employee_no (예: "E0001") 로 받는다고 가정 가능.
6. `NotificationService.notifyByUserNo(String userNo, ...)` 가 employee_no → employee_id 변환 후 SSE 발송

**중요**: MyBatis 가 underscore→camelCase 변환을 적용함. Map 키는 `employeeNo` 가 정답 (`employee_no` 는 fallback). 따라서 `emp.get("employeeNo")` 우선, `emp.get("employee_no")` 차선.

### 2.2 V8 Flyway 마이그레이션 적용 완료
**파일**: `backend-core/src/main/resources/db/migration/V8__approval_and_extras.sql`
**테이블 7종**:
- `ap_document` (이미 런타임 존재했음, V8 가 IF NOT EXISTS + ALTER TABLE 로 amount/parent_doc_id/version 컬럼 추가)
- `ap_approval_line` (acted_by_no 컬럼 추가)
- `ap_attachment` (신규 — MinIO 첨부 메타)
- `ap_delegation` (신규 — 대결 위임)
- `ap_history` (신규 — 감사 이력)
- `bd_comment`, `bd_attachment` (신규 — Phase B 용)
- `cm_holiday` (신규 — Phase C 용, 2026 한국 공휴일 15건 시드)
- `cm_code` 시드: FORM_CODE 7종, BOARD_TYPE 4종

**검증**: `flyway_schema_history` 에 `version=8 description='approval and extras'` 표시.

### 2.3 sample 시드 데이터
- `org_employee` 25명 시드 (admin → employee_no=E0001, keycloak_user_id='admin', 직책=대표이사)
- 다른 사용자는 keycloak_user_id 비어있음 → user1 등으로 SSO 로그인 시 정규화 fallback 동작 (username 그대로 employee_no 로 사용 시도 → 실패 → username 반환)

---

## 3. Phase A — 완료 / 진행중 / 대기

### 3.1 완료 (백엔드)

**ApprovalService.java** — 6 신규 `@DataSetServiceMapping` 메서드 + 1 헬퍼:
| serviceName | 입력 | 출력 | 정책 |
|---|---|---|---|
| `approval/withdraw` | docId | success | 기안자 + PENDING/IN_PROGRESS only → DRAFT |
| `approval/resubmit` | docId, content?, amount?, docTitle? | newDocId, approvers | 기안자 + REJECTED only, parent_doc_id 로 추적 |
| `approval/delegate` | delegateeNo, reason?, fromDate, toDate | success | ap_delegation 등록 |
| `approval/uploadAttachment` | docId, objectKey, filename, sizeBytes, mimeType | attachId | UI 가 presigned PUT 후 호출 |
| `approval/listAttachments` | docId | ds_attachments | |
| `approval/countPending` | (없음) | ds_count | currentUser 기준 미결 |
| `approval/searchHistory` | docId | ds_history | 감사 로그 |

**기존 메서드 수정**:
- `submitDocument`: `notifyByUserNo(approver_no, ...)` 로 첫 결재자 알림
- `approve`: `notifyByUserNo(drafter_no, ...)` (전결 완료 시), 다음 단계 결재자 자동 알림 추가
- `reject`: `notifyByUserNo(drafter_no, ...)` (반려 알림)
- `recordHistory()` private helper — withdraw/reject 등에서 ap_history 자동 기록

**ApprovalMapper.java/.xml** — 9 신규 SQL:
- `insertAttachment`, `selectAttachmentsByDoc`, `deleteAttachment`
- `insertHistory`, `selectHistoryByDoc`
- `insertDelegation` (CAST(...) AS DATE 적용), `selectActiveDelegation`
- `cloneDocumentForResubmit`, `updateDocumentContent`
- `resetLinesForWithdraw`
- 기존 `selectApproversForDocFromDmn` 에 `formCode IN ('HR','IT')` 분기 추가

**검증 결과** (smoke test 통과):
- countPending → `{count:0}` 200
- searchHistory → `[]` 200
- listAttachments → `[]` 200
- delegate → `success:true` 200, ap_delegation row 생성 확인
- withdraw 999 → `404 NOT_FOUND` (정상)

### 3.2 완료 (프론트엔드)

**`ui/src/composables/useApproval.ts` (신규)** — 13개 메서드:
```typescript
useApproval(): {
  searchInbox(boxType, keyword?), searchDetail(docId), searchFormTemplates(),
  submitDocument(doc), approve(lineId, docId, comment?), reject(lineId, docId, comment),
  withdraw(docId), resubmit(docId, patch), delegate(payload),
  uploadAttachmentMeta(payload), listAttachments(docId), countPending(),
  searchHistory(docId), getPresignedPutUrl(objectName, expireSec?),
  getPresignedGetUrl(objectName, expireSec?)
}
```

**`ui/src/components/approval/ApprovalLineTimeline.vue` (신규)** — 결재선 시각화
- Props: `lines: ApprovalLine[]`
- PrimeVue Timeline 사용. 상태별 marker 색상 (PENDING 회색/APPROVED 초록/REJECTED 빨강/SKIPPED 노랑)
- 대결 표시 (`acted_by_no !== approver_no`)

**`ui/src/components/approval/ApprovalActionBar.vue` (신규)** — 액션 버튼 + 다이얼로그
- Props: `doc`, `line` (현재 사용자의 PENDING 라인)
- 동적 노출: 승인/반려 (current approver), 회수 (drafter + PENDING/IN_PROGRESS), 재상신 (drafter + REJECTED), 대결 등록 (항상)
- 코멘트 입력 다이얼로그, 대결 등록 다이얼로그 내장
- Emits `'changed'` — 부모가 새로고침

### 3.3 대기 (다음 세션 시작 항목)

**즉시 작업할 4개 컴포넌트** (모두 PrimeVue Dialog 기반):

#### PA-3: PageApproval.vue 재작성
- 현재 76 lines (단순 리스트). 신규: `useDataSetPaging(...)` + `CrudToolbar` + 9-box nav + row click → `<ApprovalDetailDialog>` 호스팅
- 양식 버튼 → `<ApprovalSubmitDialog>` 호스팅
- 사용 composable: `useApproval`, `useAuthStore`
- `usePermission('approval')` 로 버튼 gate
- 참고: `ui/src/components/common/CrudToolbar.vue`, `ui/src/components/common/SearchPanel.vue` 가 이미 존재 (재사용)

#### PA-4: ApprovalDetailDialog.vue
- PrimeVue Dialog modal. `header` = doc title. 3~4탭 (`primevue/tabview`):
  - **내용**: doc.content (md-editor-v3 readonly 또는 prose)
  - **결재선**: `<ApprovalLineTimeline :lines="line">`
  - **첨부**: `<ApprovalAttachmentList :doc-id="doc.docId">`
  - **이력**: `useApproval().searchHistory(docId)` → 간단 목록
- Footer: `<ApprovalActionBar :doc="doc" :line="myCurrentLine" @changed="reload">`
- Props: `visible`, `docId` / Emits: `update:visible`, `closed`

#### PA-5: ApprovalSubmitDialog.vue
- PrimeVue Dialog. 폼 필드:
  - 양식 `<Dropdown>` (← `useApproval().searchFormTemplates()`)
  - 제목 `<InputText>`
  - 금액 `<InputNumber>`
  - 본문 `<MdEditor>` (md-editor-v3 패키지 이미 deps 존재)
  - 첨부 업로더 (file input → presigned PUT → uploadAttachmentMeta) — Phase A 의 마지막 작업
- DMN 결재선 미리보기 패널: 양식/금액 변경 시 `selectApproversForDocFromDmn` 결과 미리 보여주기 (양식/금액 watch 로)
  - **주의**: backend-core 에 새 service `approval/previewApprovers` 추가가 필요 (mapper 의 `selectApproversForDocFromDmn` 을 단독 노출). 지금 안 만들어져 있음 — Phase A 마무리 시 추가.
- 제출: `useApproval().submitDocument({docTitle, formCode, amount, content})` → 성공 시 `emit('submitted', docId)` + 첨부 메타 등록 → 다이얼로그 닫기

#### PA-8: ApprovalAttachmentList.vue
- Props: `docId`, `editable` (drafter + DRAFT/REJECTED 상태에서만 true)
- 마운트 시 `listAttachments(docId)` 호출
- 업로드 (editable=true): file input → `getPresignedPutUrl` → fetch PUT → `uploadAttachmentMeta` → 목록 새로고침
- 다운로드: `getPresignedGetUrl` 로 새 탭 open (모든 사용자)
- 삭제 (editable=true): `approval/deleteAttachment` — **백엔드 미구현**. PA-1 잔여 작업으로 추가 필요.

### 3.4 미해결 결정 / TODO

1. **`approval/previewApprovers`** DataSet 서비스 추가 필요 — SubmitDialog 의 결재선 미리보기용
2. **`approval/deleteAttachment`** DataSet 서비스 + Mapper 가 미구현. PA-8 작업 시 함께.
3. **첨부 다운로드 시 보안**: 현재 누구나 presigned GET URL 을 받아 다운 가능. 권한 체크 (drafter, approver, 관리자) 추가는 Phase F.
4. **재상신 시 감사 이력**: `recordHistory(newDocId, null, 'RESUBMIT', currentUser, '원본 docId=...')` 를 추가했지만 actorName 을 OrgMapper 로 lookup 안 함 (TODO 주석).

---

## 4. 다음 세션 시작 가이드 (5분)

### 4.1 빠른 컨텍스트 복원
```bash
cd /c/claude/openplatform_v3
git log --oneline -5         # 마지막 커밋들 확인
docker ps --format "{{.Names}} {{.Status}}" | grep ^v3-  # 컨테이너 상태
curl -s -o /dev/null -w "core=%{http_code}\n" http://localhost:19090/actuator/health
curl -s -o /dev/null -w "bff=%{http_code}\n"  http://localhost:19091/actuator/health
curl -s -o /dev/null -w "ui=%{http_code}\n"   http://localhost:19173/
```
모두 200 이면 인프라 정상. 만약 컨테이너 down: `docker compose -f infra/docker-compose.yml up -d`

### 4.2 다음 작업 진입
```
1. SESSION_HANDOFF.md 읽기 (이 파일)
2. TODO.md 의 [in_progress] / 다음 [pending] 확인
3. 우선순위:
   PA-3 (PageApproval 재작성) → PA-4 (ApprovalDetailDialog) → PA-8 (Attachment) → PA-5 (Submit)
4. 각 컴포넌트 작성 후 ui 빌드:
   docker compose -f infra/docker-compose.yml build --no-cache ui-frontend && \
   docker compose -f infra/docker-compose.yml up -d --force-recreate ui-frontend
5. Playwright MCP 로 시나리오 A1~A3 검증
```

### 4.3 자주 쓰는 디버그 명령
```bash
# 백엔드 로그
docker logs v3-backend-core --tail 50 2>&1 | grep -iE "exception|error"

# DB 확인
docker exec v3-postgres psql -U platform_v3 -d platform_v3 -c "SELECT * FROM platform_v3.ap_document ORDER BY doc_id DESC LIMIT 5;"

# Keycloak 토큰 발급 (E2E 스크립트용 - directAccessGrantsEnabled 필요)
TOKEN=$(curl -s -X POST "http://localhost:19281/realms/openplatform-v3/protocol/openid-connect/token" \
  -d "client_id=v3-ui" -d "username=admin" -d "password=admin" -d "grant_type=password" | \
  python -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# DataSet 호출
curl -s -X POST http://localhost:19090/api/dataset/search \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"serviceName":"approval/searchInbox","datasets":{"ds_search":{"boxType":"PENDING","userNo":"E0001"}}}'
```

### 4.4 보안 노트
- `v3-ui` Keycloak 클라이언트의 `directAccessGrantsEnabled=true` 가 활성화되어 있음 (E2E 스크립트용). Phase Final 에서 false 로 복구 필요. (warn.md 기록)

---

## 5. 핵심 파일 인덱스

### Backend (수정/신규)
- `backend-core/src/main/resources/db/migration/V8__approval_and_extras.sql` ⭐ NEW
- `backend-core/src/main/java/com/platform/v3/core/approval/ApprovalService.java` ⭐ EXTENDED (+6 메서드)
- `backend-core/src/main/java/com/platform/v3/core/approval/mapper/ApprovalMapper.java` ⭐ EXTENDED (+9 메서드)
- `backend-core/src/main/resources/mapper/approval/ApprovalMapper.xml` ⭐ EXTENDED (+9 SQL)
- `backend-core/src/main/java/com/platform/v3/core/org/mapper/OrgMapper.java` ⭐ EXTENDED (+findByKeycloakUserId, +findByNo)
- `backend-core/src/main/resources/mapper/org/OrgMapper.xml` ⭐ EXTENDED
- `backend-core/src/main/java/com/platform/v3/core/org/OrgService.java` ⭐ EXTENDED (+findMyEmployee)
- `backend-core/src/main/java/com/platform/v3/core/notification/NotificationService.java` ⭐ EXTENDED (+notifyByUserNo)
- `backend-core/src/main/java/com/platform/v3/core/dataset/DataSetController.java` ⭐ EXTENDED (+currentUser 정규화)

### Frontend (수정/신규)
- `ui/src/store/auth.ts` ⭐ EXTENDED (UserInfo +5 필드, loadUserInfo +findMyEmployee fallback)
- `ui/src/composables/useApproval.ts` ⭐ NEW (13 메서드)
- `ui/src/components/approval/ApprovalLineTimeline.vue` ⭐ NEW
- `ui/src/components/approval/ApprovalActionBar.vue` ⭐ NEW
- `ui/src/pages/PageApproval.vue` (PA-3 에서 재작성 예정)
- `ui/src/pages/PageDashboard.vue` ⭐ EXTENDED (하드코딩 ID 제거)
- `ui/src/pages/PageCalendar.vue` ⭐ EXTENDED (하드코딩 ID 제거)

---

**문서 끝 — 다음 세션은 §4.2 의 우선순위로 PA-3 부터 시작.**
