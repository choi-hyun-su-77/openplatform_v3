# 사용자 시나리오 — 15종

UI 설계 및 Playwright E2E 테스트 근거.

## 1. 통합 로그인
`/login` → Keycloak PKCE 리다이렉트 → `/dashboard` 복귀. 한 번의 인증으로 메신저/메일/위키/화상회의 SSO 완료.

## 2. 대시보드
로그인 후 첫 화면. 위젯 5종: **오늘 일정** / **미결 결재(내 대기함)** / **최근 공지** / **읽지 않은 알림** / **메신저 DM 카운트**

## 3. 결재 상신
양식 선택 → 폼 입력 → DMN 자동 결재선 도출 → 파일 첨부(MinIO) → 상신 → 결재자에게 SSE 알림.

## 4. 결재 처리
결재함 9종 탭 전환 → 문서 상세 → 승인/반려/전결/대결/회수 → 이력 자동 기록.

## 5. 부서 게시판
게시글 작성(WYSIWYG) → 이미지/파일 첨부 → 댓글 → 공지 고정.

## 6. 일정 관리
월/주/일 뷰 전환. 개인/부서/회사 필터. 일정 CRUD + 반복 일정.

## 7. 조직도 탐색
부서 트리 → 직원 카드 클릭 → 연락처/메신저DM/메일 작성 바로가기.

## 8. 메신저 (Rocket.Chat)
채널 목록 → 메시지 → DM → 파일 전송. Keycloak Custom OAuth 로 자동 로그인.

## 9. 웹메일 (Stalwart)
받은편지함 → 스레드 → 작성/임시저장/발송. Keycloak LDAP Federation 인증.

## 10. 위키 (Wiki.js)
페이지 탐색 → 편집 → 히스토리 diff. OIDC SSO.

## 11. 화상회의 (LiveKit)
회의 생성 → 참가자 초대(메신저/메일 연동) → 룸 입장 → 화면 공유.

## 12. 파일 공유
MinIO presigned URL로 대용량 업/다운로드. 권한 체크(소유자/공유 대상).

## 13. 알림 센터
SSE 실시간 뱃지 → 드롭다운 목록 → 개별 읽음/전체 읽음.

## 14. 다국어 전환
상단 언어 스위처 (ko/en/zh-CN) → `useLocale` 훅이 즉시 라벨 캐시 갱신.

## 15. 권한 제어
`usePermission(menuId)` 로 버튼/항목 표시 제어. 서버 사이드 재검증 (backend-core).

---

## Phase 14 — 실무 그룹웨어 시나리오 (16~23)

## 16. 출퇴근 + 연차 자동 차감 (트랙 1)
대시보드 출근 위젯 → "출근" 버튼 → at_attendance INSERT. 휴가는 LEAVE 양식으로 결재 → 승인 시 잔여연차 자동 차감 + at_attendance 의 해당일 status='LEAVE' 갱신. 영업일 계산은 cm_holiday + 주말 제외.

## 17. 회의실 예약 + 화상회의 자동 (트랙 2)
/room → 좌측 회의실 목록 + 우측 FullCalendar 빈 슬롯 클릭 → BookingDialog. 충돌검증 통과 시 rm_booking INSERT, has_video 면 LiveKit 룸(`rm-{bookingId}`) 자동 생성, 참석자 each notifyByUserNo, 본인 캘린더 자동 등록.

## 18. 자료실 폴더 + 권한 (트랙 3)
/datalib → 좌측 폴더 트리 (COMPANY/DEPT/PERSONAL) + 우측 파일 DataTable. scope 별 RWUD 권한. 부서 폴더는 본인 부서만 RW, 외부 R 차단. presigned URL 다운로드 + count++.

## 19. 일별 업무일지 + 부서장 팀 뷰 (트랙 4)
/worklog → 좌측 미니 캘린더 + 우측 DailyEditor. ON CONFLICT upsert. 부서장 토글 시 팀 뷰 (행=직원, 열=월~금). 3단 가드 (JWT MGR / dept_head / position_level≤30).

## 20. 관리자 GUI — 사용자/조직/메뉴/코드 (트랙 5)
/admin/users → 추가 다이얼로그 → 이름/사번/이메일/부서/역할 → 저장. backend-core → BFF Keycloak Admin REST 호출 (admin-cli password grant) → KC 사용자 생성 + temp123! 임시 비번. AdminAuditAspect 가 자동으로 sa_audit INSERT.

## 21. 통합 검색 (트랙 6)
헤더 SearchBar 에 키워드 입력 → 4 도메인(POST/DOC/EMP/FILE) UNION 결과 Overlay. Enter 시 /search 풀 페이지. 즐겨찾기 ★ 토글 → 헤더 FavoriteRail 에 추가. 알림 채널은 /settings/notify 카테고리×채널 매트릭스로 사용자 제어 (PORTAL/EMAIL/MESSENGER).

## 22. 대시보드 위젯 커스터마이즈 (트랙 7)
/dashboard 첫 로그인 시 default 6 위젯 자동 시드. 우상단 "편집" 토글 → 화살표(← → ↑ ↓ W± H±)로 12-column 그리드 위치/크기 조정 + 위젯 추가/제거. 저장 시 일괄 saveLayout. 9개 위젯 카탈로그 (출퇴근/잔여/미결/일정/공지/메신저/내회의/팀일지/연차차트).

## 23. 휴가 결재 → 캘린더 / 회의실 예약 자동 표시 (트랙 8 통합)
LEAVE 결재 승인 시 trigger 가 캘린더 events 응답에 'L-{requestId}' readonly 이벤트 자동 추가 (초록). 회의실 예약은 'R-{bookingId}' readonly 이벤트 (주황). 사용자는 추가 작업 없이 통합된 캘린더 뷰에서 모든 일정 확인.
