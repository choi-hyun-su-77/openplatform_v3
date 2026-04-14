# API 카탈로그 — openplatform_v3

v1(`C:\claude\openplatform`) 분석 결과를 토대로 v3에 **선택 포팅**할 API 목록.
BFF 계층은 v3 신규 설계.

## Core REST (backend-core, 포트 19090)
| Method | Path | 설명 | 인증 | v1 원본 |
|---|---|---|---|---|
| GET | `/api/codes?groups=...` | 공통코드 | 공개 | CodeController:29 |
| GET | `/api/i18n/{locale}?type=MENU` | 다국어 | 공개 | I18nController:27 |
| GET | `/api/notification/subscribe?userId=...` | SSE | 공개(구독 시 userId 검증) | NotificationController:31 |
| POST | `/api/dataset/search` | DataSet 단일 진입점(조회) | JWT | DataSetController |
| POST | `/api/dataset/save` | DataSet 단일 진입점(저장) | JWT | DataSetController |
| POST | `/api/dataset/search-save` | 저장 후 재조회 | JWT | DataSetController |
| GET | `/actuator/health` | health | 공개 | - |

## DataSet serviceName (v3 포팅 대상)
모두 POST `/api/dataset/{search|save}` 본문에 `serviceName` 포함.

### org (조직)
- `org/searchDeptTree` — 부서 트리
- `org/searchEmployees` — 직원 목록 (deptId, keyword)
- `org/searchApprovers` — 결재자 후보 검색

### approval (전자결재, Flowable)
- `approval/searchInbox` — 9종 박스 (DRAFT/MY_DOCS/PENDING/IN_PROGRESS/COMPLETED/REJECTED/RECEIVED/CC_BOX/DEPT_BOX)
- `approval/searchDetail` — 문서 상세 + 결재선 + 이력
- `approval/searchFormTemplates` — 양식 템플릿 목록
- `approval/searchFormDetail` — 양식 상세
- `approval/saveDraft` — 임시저장
- `approval/submitDocument` — 상신
- `approval/approve` — 승인
- `approval/reject` — 반려
- `approval/finalApprove` — 전결
- `approval/withdraw` — 회수
- `approval/delegateApprove` — 대결
- `approval/searchAutoLine` — DMN 기반 자동 결재선

### board (게시판)
- `board/searchPosts`, `board/searchDetail`, `board/savePosts`

### calendar (캘린더)
- `calendar/searchEvents`, `calendar/saveEvents`, `calendar/searchToday`

### notification (알림)
- `notification/searchList`, `notification/markRead`, `notification/markAllRead`

## BFF REST (backend-bff, 포트 19091) — v3 신규 설계
| Path | 포트 | 설명 |
|---|---|---|
| `/api/bff/messenger/channels` | MessagingPort | 채널 목록 |
| `/api/bff/messenger/messages` | MessagingPort | 메시지 조회/전송 |
| `/api/bff/messenger/dm` | MessagingPort | DM 생성 |
| `/api/bff/messenger/stream` | MessagingPort | SSE 이벤트 |
| `/api/bff/mail/mailbox` | MailPort | 받은편지함 |
| `/api/bff/mail/thread` | MailPort | 스레드 |
| `/api/bff/mail/send` | MailPort | 발송 |
| `/api/bff/wiki/pages` | WikiPort | 페이지 목록/검색 |
| `/api/bff/wiki/page` | WikiPort | 단건 조회/저장 |
| `/api/bff/video/room` | VideoPort | 룸 생성 |
| `/api/bff/video/token` | VideoPort | JWT 발급 |
| `/api/bff/storage/upload` | StoragePort | 업로드 |
| `/api/bff/storage/presigned` | StoragePort | presigned URL |
| `/api/bff/identity/me` | IdentityPort | 내 프로필/권한 |

## 선택 포팅 규칙
- v1의 Java 파일을 **통째 복사 금지**
- 각 서비스 메서드를 v3 `com.platform.v3.core.*` 패키지 하위로 **분석 후 재작성**
- MyBatis XML도 내용 분석 후 v3 네임스페이스로 재작성
- BPMN/DMN 리소스는 내용 검토 후 선택 채택
