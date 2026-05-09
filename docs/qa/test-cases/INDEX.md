# E2E 테스트 케이스 인덱스

마지막 갱신: 2026-05-09

## 명명 규칙

`TC-{DOMAIN}-{ACTION}-{SEQ}-{VARIANT?}`

| 영역 | 코드 |
|---|---|
| 인증 | AUTH |
| 대시보드 | DASH |
| 결재 | APP |
| 게시판 | BRD |
| 캘린더 | CAL |
| 조직도 | ORG |
| 메일 | MAIL |
| 메신저 | MSG |
| 위키 | WIKI |
| 화상회의 | VID |
| 근태 | ATT |
| 휴가 | LEV |
| 회의실 | ROOM |
| 자료실 | DLB |
| 업무일지 | WLG |
| 통합검색 | SCH |
| 알림설정 | NOT |
| 즐겨찾기 | FAV |
| 사용자관리 | ADM-USR |
| 조직관리 | ADM-DEPT |
| 메뉴관리 | ADM-MENU |
| 공통코드 | ADM-CODE |
| 감사로그 | ADM-AUDIT |
| 권한 매트릭스 | PERM |
| 다국어 | I18N |
| 에러 흐름 | ERR |

## spec 파일 인벤토리 (25 spec / 100+ 케이스)

| spec 파일 | 도메인 | 케이스 수 |
|---|---|---:|
| `01-login.spec.ts` | AUTH | 3 |
| `02-dashboard.spec.ts` | DASH | 4 |
| `03-approval.spec.ts` | APP | 7 |
| `04-board.spec.ts` | BRD | 6 |
| `05-calendar.spec.ts` | CAL | 5 |
| `06-org.spec.ts` | ORG | 3 |
| `07-mail.spec.ts` | MAIL | 3 |
| `08-messenger.spec.ts` | MSG | 1 |
| `09-wiki.spec.ts` | WIKI | 1 |
| `10-video.spec.ts` | VID | 1 |
| `11-attendance.spec.ts` | ATT | 4 |
| `12-leave.spec.ts` | LEV | 5 |
| `13-room.spec.ts` | ROOM | 4 |
| `14-datalib.spec.ts` | DLB | 2 |
| `15-worklog.spec.ts` | WLG | 2 |
| `16-search.spec.ts` | SCH | 3 |
| `17-settings.spec.ts` | NOT, FAV | 5 |
| `18-admin-users.spec.ts` | ADM-USR | 5 |
| `19-admin-depts.spec.ts` | ADM-DEPT | 4 |
| `20-admin-menus.spec.ts` | ADM-MENU | 5 |
| `21-admin-codes.spec.ts` | ADM-CODE | 5 |
| `22-admin-audit.spec.ts` | ADM-AUDIT | 4 |
| `23-permissions.spec.ts` | PERM | 22 |
| `24-i18n.spec.ts` | I18N | 5 |
| `25-error-flows.spec.ts` | ERR | 3 |
| **합계** | | **112** |

## 도메인별 상세 문서

- [auth.md](auth.md) — 인증 흐름
- [dashboard.md](dashboard.md) — 대시보드
- [approval.md](approval.md) — 결재
- [board.md](board.md) — 게시판
- [calendar.md](calendar.md) — 캘린더
- [attendance-leave.md](attendance-leave.md) — 근태 / 휴가
- [room-datalib-worklog.md](room-datalib-worklog.md) — 회의실 / 자료실 / 업무일지
- [settings-search.md](settings-search.md) — 통합검색 / 알림설정 / 즐겨찾기
- [admin-users.md](admin-users.md) — 사용자관리
- [admin-extra.md](admin-extra.md) — 조직/메뉴/코드/감사로그/에러
- [permissions.md](permissions.md) — 권한 매트릭스
- [i18n.md](i18n.md) — 다국어

## 통과 결과 (최종 회귀)

**최종 회귀**: `cd ui && npm run test:e2e` → **112 / 112 (100%) ✅** (12.8분 / chromium / workers=4)

진화: 8 → 27 → 37 → 47 → 109 → 111 → **112 / 112**.

| 도메인 | spec | 케이스 | 결과 |
|---|---|---:|---|
| AUTH | 01-login | 3 | ✅ |
| DASH | 02-dashboard | 4 | ✅ |
| APP | 03-approval | 7 | ✅ |
| BRD | 04-board | 6 | ✅ |
| CAL | 05-calendar | 5 | ✅ |
| ORG | 06-org | 3 | ✅ |
| MAIL | 07-mail | 3 | ✅ |
| MSG | 08-messenger | 1 | ✅ |
| WIKI | 09-wiki | 1 | ✅ |
| VID | 10-video | 1 | ✅ |
| ATT | 11-attendance | 4 | ✅ |
| LEV | 12-leave | 5 | ✅ |
| ROOM | 13-room | 4 | ✅ |
| DLB | 14-datalib | 2 | ✅ |
| WLG | 15-worklog | 2 | ✅ |
| SCH | 16-search | 3 | ✅ |
| NOT/FAV | 17-settings | 5 | ✅ |
| ADM-USR | 18-admin-users | 5 | ✅ |
| ADM-DEPT | 19-admin-depts | 4 | ✅ |
| ADM-MENU | 20-admin-menus | 5 | ✅ |
| ADM-CODE | 21-admin-codes | 5 | ✅ |
| ADM-AUDIT | 22-admin-audit | 4 | ✅ |
| PERM | 23-permissions | 22 | ✅ |
| I18N | 24-i18n | 5 | ✅ |
| ERR | 25-error-flows | 3 | ✅ |
| **합계** | **25 spec** | **112** | **100%** |

## 부족한 영역 (후속 보강)

- TC-PERM-USER-* (ROLE_USER 의 admin 라우트 진입 시 /403 검증) — 별도 user1 storageState 필요
- 외부 SSO iframe (Rocket.Chat / Wiki.js / MinIO Console) — Type A 수동 검증
- LiveKit 화상회의 — 카메라/마이크 권한이 필요하므로 manual check
- 시각 회귀 (Playwright `toHaveScreenshot()`) — 다이얼로그 / 위젯 레이아웃
- 4 언어 UI 토글 spec (현재는 API 회귀만)
