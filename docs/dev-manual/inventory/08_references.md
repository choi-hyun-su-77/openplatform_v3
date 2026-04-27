# inventory/08_references.md — 레퍼런스 모범 선정

> Phase 0.I 산출물. 각 SOP의 워크스루 마무리 섹션이 본 모범을 따라간다.

## 1. 백엔드 패턴별 모범 도메인

| 패턴 | 모범 도메인 | 경로 | 선정 사유 |
|---|---|---|---|
| A. 표준 CRUD | board (게시판) | `[code: backend-core/src/main/java/com/platform/v3/core/board/]` | Mapper/Service/페이지 모두 가장 표준적, Phase 14 기준 최신 일관, V4 마이그레이션 단순 명료 |
| A. (관리자 변종) | code (공통코드) | `[code: backend-core/src/main/java/com/platform/v3/core/code/]` | Public REST 컨트롤러(`CodeController`) 동반 - 단순 read 표본 |
| B. Workflow | approval (전자결재) | `[code: backend-core/src/main/java/com/platform/v3/core/approval/]` | 코드베이스 유일 정식 Workflow 도메인. Service + 4개 Delegate + DMN, hook(LeaveService) 포함 |
| C. BFF Adapter | admin (Keycloak) | `[code: backend-core/.../admin/AdminService.java]` + `[code: backend-bff/.../adapter/KeycloakIdentityAdapter.java]` | 사용자 CRUD 의 가장 완전한 BFF 흐름 (DB + Keycloak + 감사 AOP) |
| C. (Video 변종) | room (LiveKit) | `[code: backend-core/.../room/RoomService.java]` + `[code: backend-bff/.../adapter/LiveKitAdapter.java]` | Calendar mapper 결합 + LiveKit 토큰 발급 — 다중 시스템 cross-domain |
| D. Read-only/집계 | widget (대시보드) | `[code: backend-core/.../widget/WidgetService.java]` | DEFAULT_LAYOUT 자동 시드 + 사용자 layout merge 의 모범 |
| D. (검색 변종) | ux/SearchService | `[code: backend-core/.../ux/SearchService.java]` | UNION + ILIKE 통합검색 표본 |

## 2. 화면 형태별 모범 페이지

| 형태 | 모범 페이지 | 선정 사유 |
|---|---|---|
| 1. 다건 목록 | `[code: ui/src/pages/PageBoard.vue]` | Toolbar + DataTable + 행 클릭 → Dialog 의 가장 표준 패턴 |
| 2. 단건 상세 | `[code: ui/src/components/approval/ApprovalDetailDialog.vue]` | TabView + Timeline(결재선) + 액션 버튼의 풍부 표본 |
| 3. 마스터-디테일 | `[code: ui/src/pages/PageDataLibrary.vue]` | Tree + DataTable + ContextMenu(폴더/파일) 가장 정형 |
| 4. 캘린더 | `[code: ui/src/pages/PageCalendar.vue]` | FullCalendar(month/week/day) + scope 필터 + Dialog 의 표준 |
| 5. 대시보드 | `[code: ui/src/pages/PageDashboard.vue]` | 12-col grid + 편집 모드 + 위젯 catalog 의 유일/완전 구현 |
| 6. 다단계 입력 | `[code: ui/src/components/approval/ApprovalSubmitDialog.vue]` | form_code 분기 + 결재선 + 첨부 의 다단계 폼 표본 |
| 7. SSO 래퍼 | `[code: ui/src/pages/PageWiki.vue]` | 단순·명확한 Keycloak SSO 진입(임베디드 iframe X) |
| 8. 실시간 | `[code: ui/src/pages/PageVideo.vue]` | LiveKit Room/RoomEvent 의 reactive tile 렌더 표본 |
| 9. 폼 매트릭스 | `[code: ui/src/pages/PageNotifySettings.vue]` | DataTable + ToggleButton in-place edit + 배치 저장 |

## 3. 모범 외 변종/이상치 (warn.md 후보)

- `admin` 도메인은 backend-core 에서 직접 `RestTemplate` 사용 (다른 도메인은 BFF 경유) → 향후 BFF 일원화 권장
- `WorkReportService` ↔ `worklog/*` 명명 불일치 (이력적)
- `attendance/leave` 가 `at_*` prefix 공유 → 도메인 이중 사용
- 메뉴명 i18n 자동 연결 미구현 (`cm_menu.menu_name` 직접 저장)

## 4. 모범 활용 가이드

각 SOP(`scaffolds/*.md`, `screens/*.md`, `recipes/*.md`)의 **마지막 워크스루 섹션** 은 위 표의 모범 1개를 처음부터 끝까지 따라간다.

- Pattern A SOP 워크스루 → board 도메인의 `BoardService.java`/`BoardMapper.java`/`PageBoard.vue` 한 길로 따라감.
- Pattern B SOP 워크스루 → approval 도메인의 ApprovalService → 4 Delegate → ApprovalSubmitDialog/ApprovalDetailDialog.
- Pattern C SOP 워크스루 → admin 도메인의 사용자 CRUD: AdminService → bffPost → KeycloakIdentityAdapter.
- Pattern D SOP 워크스루 → widget 도메인의 listMine + DEFAULT_LAYOUT 자동 시드.
- 형태 1~9 워크스루 → 모범 페이지 1개 코드 흐름을 따라가며 표 4개(복사/신규/수정/치환) 채움.
