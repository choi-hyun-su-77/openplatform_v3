-- V9: i18n 라벨 4개 언어 (ko/en/zh/ja) + 게시판/캘린더/결재 예시 데이터

-- ============================================================
-- 1. i18n 라벨 (핵심 ~200 키 × 4개 언어)
-- ============================================================

-- msg_type: LABEL(화면 라벨), BUTTON(버튼), MSG(메시지/토스트), MENU(메뉴명)

-- === 공통 BUTTON ===
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('BTN_SAVE','ko','BUTTON','저장'),('BTN_SAVE','en','BUTTON','Save'),('BTN_SAVE','zh','BUTTON','保存'),('BTN_SAVE','ja','BUTTON','保存'),
('BTN_CANCEL','ko','BUTTON','취소'),('BTN_CANCEL','en','BUTTON','Cancel'),('BTN_CANCEL','zh','BUTTON','取消'),('BTN_CANCEL','ja','BUTTON','キャンセル'),
('BTN_DELETE','ko','BUTTON','삭제'),('BTN_DELETE','en','BUTTON','Delete'),('BTN_DELETE','zh','BUTTON','删除'),('BTN_DELETE','ja','BUTTON','削除'),
('BTN_EDIT','ko','BUTTON','수정'),('BTN_EDIT','en','BUTTON','Edit'),('BTN_EDIT','zh','BUTTON','编辑'),('BTN_EDIT','ja','BUTTON','編集'),
('BTN_ADD','ko','BUTTON','추가'),('BTN_ADD','en','BUTTON','Add'),('BTN_ADD','zh','BUTTON','添加'),('BTN_ADD','ja','BUTTON','追加'),
('BTN_SEARCH','ko','BUTTON','검색'),('BTN_SEARCH','en','BUTTON','Search'),('BTN_SEARCH','zh','BUTTON','搜索'),('BTN_SEARCH','ja','BUTTON','検索'),
('BTN_CLOSE','ko','BUTTON','닫기'),('BTN_CLOSE','en','BUTTON','Close'),('BTN_CLOSE','zh','BUTTON','关闭'),('BTN_CLOSE','ja','BUTTON','閉じる'),
('BTN_CONFIRM','ko','BUTTON','확인'),('BTN_CONFIRM','en','BUTTON','Confirm'),('BTN_CONFIRM','zh','BUTTON','确认'),('BTN_CONFIRM','ja','BUTTON','確認'),
('BTN_LOGOUT','ko','BUTTON','로그아웃'),('BTN_LOGOUT','en','BUTTON','Logout'),('BTN_LOGOUT','zh','BUTTON','退出'),('BTN_LOGOUT','ja','BUTTON','ログアウト'),
('BTN_REFRESH','ko','BUTTON','새로고침'),('BTN_REFRESH','en','BUTTON','Refresh'),('BTN_REFRESH','zh','BUTTON','刷新'),('BTN_REFRESH','ja','BUTTON','更新'),
('BTN_EXPORT','ko','BUTTON','내보내기'),('BTN_EXPORT','en','BUTTON','Export'),('BTN_EXPORT','zh','BUTTON','导出'),('BTN_EXPORT','ja','BUTTON','エクスポート')
ON CONFLICT DO NOTHING;

-- === 메뉴 ===
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('MENU_DASHBOARD','ko','MENU','대시보드'),('MENU_DASHBOARD','en','MENU','Dashboard'),('MENU_DASHBOARD','zh','MENU','仪表盘'),('MENU_DASHBOARD','ja','MENU','ダッシュボード'),
('MENU_APPROVAL','ko','MENU','전자결재'),('MENU_APPROVAL','en','MENU','Approval'),('MENU_APPROVAL','zh','MENU','电子审批'),('MENU_APPROVAL','ja','MENU','電子決裁'),
('MENU_BOARD','ko','MENU','게시판'),('MENU_BOARD','en','MENU','Board'),('MENU_BOARD','zh','MENU','公告板'),('MENU_BOARD','ja','MENU','掲示板'),
('MENU_CALENDAR','ko','MENU','캘린더'),('MENU_CALENDAR','en','MENU','Calendar'),('MENU_CALENDAR','zh','MENU','日历'),('MENU_CALENDAR','ja','MENU','カレンダー'),
('MENU_ORG','ko','MENU','조직도'),('MENU_ORG','en','MENU','Organization'),('MENU_ORG','zh','MENU','组织架构'),('MENU_ORG','ja','MENU','組織図'),
('MENU_MESSENGER','ko','MENU','메신저'),('MENU_MESSENGER','en','MENU','Messenger'),('MENU_MESSENGER','zh','MENU','即时通讯'),('MENU_MESSENGER','ja','MENU','メッセンジャー'),
('MENU_MAIL','ko','MENU','메일'),('MENU_MAIL','en','MENU','Mail'),('MENU_MAIL','zh','MENU','邮件'),('MENU_MAIL','ja','MENU','メール'),
('MENU_WIKI','ko','MENU','위키'),('MENU_WIKI','en','MENU','Wiki'),('MENU_WIKI','zh','MENU','维基'),('MENU_WIKI','ja','MENU','ウィキ'),
('MENU_VIDEO','ko','MENU','화상회의'),('MENU_VIDEO','en','MENU','Video Call'),('MENU_VIDEO','zh','MENU','视频会议'),('MENU_VIDEO','ja','MENU','ビデオ会議')
ON CONFLICT DO NOTHING;

-- === 결재 라벨 ===
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('LBL_APPROVAL_INBOX','ko','LABEL','결재함'),('LBL_APPROVAL_INBOX','en','LABEL','Approval Inbox'),('LBL_APPROVAL_INBOX','zh','LABEL','审批箱'),('LBL_APPROVAL_INBOX','ja','LABEL','決裁箱'),
('LBL_APPROVAL_DRAFT','ko','LABEL','기안함'),('LBL_APPROVAL_DRAFT','en','LABEL','Drafts'),('LBL_APPROVAL_DRAFT','zh','LABEL','草稿箱'),('LBL_APPROVAL_DRAFT','ja','LABEL','起案箱'),
('LBL_APPROVAL_PENDING','ko','LABEL','대기함'),('LBL_APPROVAL_PENDING','en','LABEL','Pending'),('LBL_APPROVAL_PENDING','zh','LABEL','待审批'),('LBL_APPROVAL_PENDING','ja','LABEL','保留中'),
('LBL_APPROVAL_COMPLETED','ko','LABEL','완료함'),('LBL_APPROVAL_COMPLETED','en','LABEL','Completed'),('LBL_APPROVAL_COMPLETED','zh','LABEL','已完成'),('LBL_APPROVAL_COMPLETED','ja','LABEL','完了'),
('LBL_APPROVAL_REJECTED','ko','LABEL','반려함'),('LBL_APPROVAL_REJECTED','en','LABEL','Rejected'),('LBL_APPROVAL_REJECTED','zh','LABEL','已退回'),('LBL_APPROVAL_REJECTED','ja','LABEL','却下'),
('LBL_APPROVAL_SUBMIT','ko','LABEL','상신'),('LBL_APPROVAL_SUBMIT','en','LABEL','Submit'),('LBL_APPROVAL_SUBMIT','zh','LABEL','提交'),('LBL_APPROVAL_SUBMIT','ja','LABEL','起案'),
('LBL_APPROVAL_APPROVE','ko','LABEL','승인'),('LBL_APPROVAL_APPROVE','en','LABEL','Approve'),('LBL_APPROVAL_APPROVE','zh','LABEL','批准'),('LBL_APPROVAL_APPROVE','ja','LABEL','承認'),
('LBL_APPROVAL_REJECT','ko','LABEL','반려'),('LBL_APPROVAL_REJECT','en','LABEL','Reject'),('LBL_APPROVAL_REJECT','zh','LABEL','退回'),('LBL_APPROVAL_REJECT','ja','LABEL','却下'),
('LBL_APPROVAL_WITHDRAW','ko','LABEL','회수'),('LBL_APPROVAL_WITHDRAW','en','LABEL','Withdraw'),('LBL_APPROVAL_WITHDRAW','zh','LABEL','撤回'),('LBL_APPROVAL_WITHDRAW','ja','LABEL','取下げ'),
('LBL_APPROVAL_DELEGATE','ko','LABEL','대결'),('LBL_APPROVAL_DELEGATE','en','LABEL','Delegate'),('LBL_APPROVAL_DELEGATE','zh','LABEL','委托'),('LBL_APPROVAL_DELEGATE','ja','LABEL','代決'),
('LBL_APPROVAL_RESUBMIT','ko','LABEL','재상신'),('LBL_APPROVAL_RESUBMIT','en','LABEL','Resubmit'),('LBL_APPROVAL_RESUBMIT','zh','LABEL','重新提交'),('LBL_APPROVAL_RESUBMIT','ja','LABEL','再起案'),
('LBL_DOC_TITLE','ko','LABEL','문서 제목'),('LBL_DOC_TITLE','en','LABEL','Document Title'),('LBL_DOC_TITLE','zh','LABEL','文档标题'),('LBL_DOC_TITLE','ja','LABEL','文書タイトル'),
('LBL_FORM_CODE','ko','LABEL','양식'),('LBL_FORM_CODE','en','LABEL','Form'),('LBL_FORM_CODE','zh','LABEL','表单'),('LBL_FORM_CODE','ja','LABEL','様式'),
('LBL_AMOUNT','ko','LABEL','금액'),('LBL_AMOUNT','en','LABEL','Amount'),('LBL_AMOUNT','zh','LABEL','金额'),('LBL_AMOUNT','ja','LABEL','金額'),
('LBL_DRAFTER','ko','LABEL','기안자'),('LBL_DRAFTER','en','LABEL','Drafter'),('LBL_DRAFTER','zh','LABEL','起草人'),('LBL_DRAFTER','ja','LABEL','起案者'),
('LBL_APPROVER','ko','LABEL','결재자'),('LBL_APPROVER','en','LABEL','Approver'),('LBL_APPROVER','zh','LABEL','审批人'),('LBL_APPROVER','ja','LABEL','決裁者'),
('LBL_APPROVAL_LINE','ko','LABEL','결재선'),('LBL_APPROVAL_LINE','en','LABEL','Approval Line'),('LBL_APPROVAL_LINE','zh','LABEL','审批流程'),('LBL_APPROVAL_LINE','ja','LABEL','決裁ライン'),
('LBL_ATTACHMENT','ko','LABEL','첨부파일'),('LBL_ATTACHMENT','en','LABEL','Attachments'),('LBL_ATTACHMENT','zh','LABEL','附件'),('LBL_ATTACHMENT','ja','LABEL','添付ファイル'),
('LBL_HISTORY','ko','LABEL','이력'),('LBL_HISTORY','en','LABEL','History'),('LBL_HISTORY','zh','LABEL','历史记录'),('LBL_HISTORY','ja','LABEL','履歴')
ON CONFLICT DO NOTHING;

-- === 게시판 라벨 ===
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('LBL_BOARD_NOTICE','ko','LABEL','공지사항'),('LBL_BOARD_NOTICE','en','LABEL','Notice'),('LBL_BOARD_NOTICE','zh','LABEL','公告'),('LBL_BOARD_NOTICE','ja','LABEL','お知らせ'),
('LBL_BOARD_GENERAL','ko','LABEL','일반'),('LBL_BOARD_GENERAL','en','LABEL','General'),('LBL_BOARD_GENERAL','zh','LABEL','一般'),('LBL_BOARD_GENERAL','ja','LABEL','一般'),
('LBL_BOARD_FREE','ko','LABEL','자유게시판'),('LBL_BOARD_FREE','en','LABEL','Free Board'),('LBL_BOARD_FREE','zh','LABEL','自由论坛'),('LBL_BOARD_FREE','ja','LABEL','自由掲示板'),
('LBL_BOARD_DEPT','ko','LABEL','부서게시판'),('LBL_BOARD_DEPT','en','LABEL','Dept Board'),('LBL_BOARD_DEPT','zh','LABEL','部门论坛'),('LBL_BOARD_DEPT','ja','LABEL','部署掲示板'),
('LBL_TITLE','ko','LABEL','제목'),('LBL_TITLE','en','LABEL','Title'),('LBL_TITLE','zh','LABEL','标题'),('LBL_TITLE','ja','LABEL','タイトル'),
('LBL_CONTENT','ko','LABEL','내용'),('LBL_CONTENT','en','LABEL','Content'),('LBL_CONTENT','zh','LABEL','内容'),('LBL_CONTENT','ja','LABEL','内容'),
('LBL_AUTHOR','ko','LABEL','작성자'),('LBL_AUTHOR','en','LABEL','Author'),('LBL_AUTHOR','zh','LABEL','作者'),('LBL_AUTHOR','ja','LABEL','作成者'),
('LBL_VIEW_COUNT','ko','LABEL','조회수'),('LBL_VIEW_COUNT','en','LABEL','Views'),('LBL_VIEW_COUNT','zh','LABEL','浏览量'),('LBL_VIEW_COUNT','ja','LABEL','閲覧数'),
('LBL_COMMENT','ko','LABEL','댓글'),('LBL_COMMENT','en','LABEL','Comments'),('LBL_COMMENT','zh','LABEL','评论'),('LBL_COMMENT','ja','LABEL','コメント'),
('LBL_PIN','ko','LABEL','상단 고정'),('LBL_PIN','en','LABEL','Pinned'),('LBL_PIN','zh','LABEL','置顶'),('LBL_PIN','ja','LABEL','固定')
ON CONFLICT DO NOTHING;

-- === 캘린더 라벨 ===
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('LBL_CAL_PERSONAL','ko','LABEL','개인'),('LBL_CAL_PERSONAL','en','LABEL','Personal'),('LBL_CAL_PERSONAL','zh','LABEL','个人'),('LBL_CAL_PERSONAL','ja','LABEL','個人'),
('LBL_CAL_DEPT','ko','LABEL','부서'),('LBL_CAL_DEPT','en','LABEL','Department'),('LBL_CAL_DEPT','zh','LABEL','部门'),('LBL_CAL_DEPT','ja','LABEL','部署'),
('LBL_CAL_COMPANY','ko','LABEL','회사'),('LBL_CAL_COMPANY','en','LABEL','Company'),('LBL_CAL_COMPANY','zh','LABEL','公司'),('LBL_CAL_COMPANY','ja','LABEL','会社'),
('LBL_CAL_ALL_DAY','ko','LABEL','종일'),('LBL_CAL_ALL_DAY','en','LABEL','All Day'),('LBL_CAL_ALL_DAY','zh','LABEL','全天'),('LBL_CAL_ALL_DAY','ja','LABEL','終日'),
('LBL_CAL_NEW_EVENT','ko','LABEL','새 일정'),('LBL_CAL_NEW_EVENT','en','LABEL','New Event'),('LBL_CAL_NEW_EVENT','zh','LABEL','新建日程'),('LBL_CAL_NEW_EVENT','ja','LABEL','新規予定'),
('LBL_CAL_EDIT_EVENT','ko','LABEL','일정 수정'),('LBL_CAL_EDIT_EVENT','en','LABEL','Edit Event'),('LBL_CAL_EDIT_EVENT','zh','LABEL','编辑日程'),('LBL_CAL_EDIT_EVENT','ja','LABEL','予定編集')
ON CONFLICT DO NOTHING;

-- === 공통 라벨 ===
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('LBL_CREATED_AT','ko','LABEL','작성일'),('LBL_CREATED_AT','en','LABEL','Created'),('LBL_CREATED_AT','zh','LABEL','创建时间'),('LBL_CREATED_AT','ja','LABEL','作成日'),
('LBL_UPDATED_AT','ko','LABEL','수정일'),('LBL_UPDATED_AT','en','LABEL','Updated'),('LBL_UPDATED_AT','zh','LABEL','更新时间'),('LBL_UPDATED_AT','ja','LABEL','更新日'),
('LBL_STATUS','ko','LABEL','상태'),('LBL_STATUS','en','LABEL','Status'),('LBL_STATUS','zh','LABEL','状态'),('LBL_STATUS','ja','LABEL','状態'),
('LBL_NO_DATA','ko','LABEL','데이터가 없습니다'),('LBL_NO_DATA','en','LABEL','No data'),('LBL_NO_DATA','zh','LABEL','没有数据'),('LBL_NO_DATA','ja','LABEL','データがありません'),
('LBL_LOADING','ko','LABEL','로딩 중...'),('LBL_LOADING','en','LABEL','Loading...'),('LBL_LOADING','zh','LABEL','加载中...'),('LBL_LOADING','ja','LABEL','読み込み中...'),
('LBL_THEME_SETTINGS','ko','LABEL','테마 설정'),('LBL_THEME_SETTINGS','en','LABEL','Theme Settings'),('LBL_THEME_SETTINGS','zh','LABEL','主题设置'),('LBL_THEME_SETTINGS','ja','LABEL','テーマ設定'),
('LBL_NOTIFICATION','ko','LABEL','알림'),('LBL_NOTIFICATION','en','LABEL','Notifications'),('LBL_NOTIFICATION','zh','LABEL','通知'),('LBL_NOTIFICATION','ja','LABEL','通知'),
('LBL_MARK_ALL_READ','ko','LABEL','모두 읽음'),('LBL_MARK_ALL_READ','en','LABEL','Mark all read'),('LBL_MARK_ALL_READ','zh','LABEL','全部已读'),('LBL_MARK_ALL_READ','ja','LABEL','全て既読'),
('LBL_NO_NOTIFICATION','ko','LABEL','새 알림이 없습니다'),('LBL_NO_NOTIFICATION','en','LABEL','No new notifications'),('LBL_NO_NOTIFICATION','zh','LABEL','没有新通知'),('LBL_NO_NOTIFICATION','ja','LABEL','新しい通知はありません'),
('LBL_FORBIDDEN','ko','LABEL','접근 권한이 없습니다'),('LBL_FORBIDDEN','en','LABEL','Access denied'),('LBL_FORBIDDEN','zh','LABEL','访问被拒绝'),('LBL_FORBIDDEN','ja','LABEL','アクセスが拒否されました')
ON CONFLICT DO NOTHING;

-- === 토스트/메시지 ===
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('MSG_SAVE_SUCCESS','ko','MSG','저장되었습니다'),('MSG_SAVE_SUCCESS','en','MSG','Saved successfully'),('MSG_SAVE_SUCCESS','zh','MSG','保存成功'),('MSG_SAVE_SUCCESS','ja','MSG','保存しました'),
('MSG_DELETE_SUCCESS','ko','MSG','삭제되었습니다'),('MSG_DELETE_SUCCESS','en','MSG','Deleted successfully'),('MSG_DELETE_SUCCESS','zh','MSG','删除成功'),('MSG_DELETE_SUCCESS','ja','MSG','削除しました'),
('MSG_DELETE_CONFIRM','ko','MSG','정말 삭제하시겠습니까?'),('MSG_DELETE_CONFIRM','en','MSG','Are you sure you want to delete?'),('MSG_DELETE_CONFIRM','zh','MSG','确定要删除吗？'),('MSG_DELETE_CONFIRM','ja','MSG','本当に削除しますか？'),
('MSG_ERROR','ko','MSG','오류가 발생했습니다'),('MSG_ERROR','en','MSG','An error occurred'),('MSG_ERROR','zh','MSG','发生错误'),('MSG_ERROR','ja','MSG','エラーが発生しました'),
('MSG_APPROVAL_SUBMITTED','ko','MSG','결재가 상신되었습니다'),('MSG_APPROVAL_SUBMITTED','en','MSG','Approval submitted'),('MSG_APPROVAL_SUBMITTED','zh','MSG','审批已提交'),('MSG_APPROVAL_SUBMITTED','ja','MSG','決裁を起案しました'),
('MSG_APPROVAL_APPROVED','ko','MSG','승인되었습니다'),('MSG_APPROVAL_APPROVED','en','MSG','Approved'),('MSG_APPROVAL_APPROVED','zh','MSG','已批准'),('MSG_APPROVAL_APPROVED','ja','MSG','承認しました'),
('MSG_APPROVAL_REJECTED','ko','MSG','반려되었습니다'),('MSG_APPROVAL_REJECTED','en','MSG','Rejected'),('MSG_APPROVAL_REJECTED','zh','MSG','已退回'),('MSG_APPROVAL_REJECTED','ja','MSG','却下しました'),
('MSG_COMMENT_ADDED','ko','MSG','댓글이 등록되었습니다'),('MSG_COMMENT_ADDED','en','MSG','Comment added'),('MSG_COMMENT_ADDED','zh','MSG','评论已添加'),('MSG_COMMENT_ADDED','ja','MSG','コメントを追加しました'),
('MSG_MAIL_SENT','ko','MSG','메일이 발송되었습니다'),('MSG_MAIL_SENT','en','MSG','Email sent'),('MSG_MAIL_SENT','zh','MSG','邮件已发送'),('MSG_MAIL_SENT','ja','MSG','メールを送信しました')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. 예시 데이터 — 게시판 (없는 경우만 삽입)
-- ============================================================

INSERT INTO platform_v3.bd_post (board_type, title, content, created_by, is_pinned, view_count, created_at, updated_at) VALUES
('NOTICE', '2026년 2분기 경영방침 안내', '안녕하세요. 2026년 2분기 경영방침을 안내드립니다.\n\n1. 고객 만족도 향상 프로그램 강화\n2. 신규 서비스 런칭 (5월 예정)\n3. 사내 교육 확대\n\n자세한 내용은 첨부 파일을 참고해 주세요.', 'E0001', 'Y', 142, NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
('NOTICE', '정보보안 교육 필수 이수 안내', '전 직원 대상 정보보안 교육을 실시합니다.\n\n- 기간: 4/20 ~ 4/30\n- 방법: LMS 온라인 교육\n- 미이수 시 인사 불이익이 있을 수 있습니다.', 'E0001', 'Y', 98, NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),
('NOTICE', '사옥 주차장 공사 안내 (4/25~5/10)', '지하 1층 주차장 방수 공사로 인해 4/25부터 5/10까지 지하 1층 주차가 불가합니다.\n대체 주차장: B동 옥상 주차장을 이용해 주세요.', 'E0010', 'N', 76, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
('GENERAL', '팀 회식 장소 추천해주세요', '이번 달 팀 회식 장소를 찾고 있습니다.\n강남역 근처로 10~15명 수용 가능한 곳 추천 부탁드립니다.\n예산은 1인당 5만원 내외입니다.', 'E0020', 'N', 23, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
('GENERAL', '사내 동호회 가입 안내', '사내 동호회 목록입니다:\n\n- 축구: 매주 토요일 오전\n- 등산: 격주 일요일\n- 독서: 매월 마지막 수요일\n- 사진: 매월 2째 토요일\n\n가입 희망 시 총무팀에 문의해 주세요.', 'E0010', 'N', 45, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
('FREE', '점심 맛집 공유합니다', '회사 앞 새로 오픈한 이탈리안 레스토랑 다녀왔는데 파스타가 정말 맛있습니다.\n런치 세트가 12,000원이고 샐러드도 같이 나옵니다.\n점심시간에 한번 가보세요!', 'E0020', 'N', 67, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
('FREE', '재택근무 팁 공유', '재택근무 3년차 직장인으로서 생산성 높이는 팁 공유합니다.\n\n1. 오전에 가장 집중력 필요한 업무 먼저\n2. 포모도로 기법 (25분 집중 + 5분 휴식)\n3. 업무 공간과 생활 공간 분리\n4. 점심 후 10분 산책', 'E0001', 'N', 34, NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
('DEPT', '개발팀 코드리뷰 가이드라인', '코드리뷰 가이드라인을 정리했습니다.\n\n1. PR은 200줄 이내로 분할\n2. 리뷰어는 24시간 내 피드백\n3. approve 전 CI 통과 필수\n4. 주요 로직 변경 시 설계 문서 첨부', 'E0001', 'N', 56, NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. 예시 데이터 — 댓글
-- ============================================================

-- bd_post 에 방금 삽입한 게시글들의 ID 는 시퀀스에 의존하므로,
-- subquery로 최근 게시글을 참조
INSERT INTO platform_v3.bd_comment (post_id, content, author_no, author_name, created_at, updated_at)
SELECT p.post_id, '좋은 정보 감사합니다!', 'E0020', '이영희', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'
FROM platform_v3.bd_post p WHERE p.title LIKE '%경영방침%' LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO platform_v3.bd_comment (post_id, content, author_no, author_name, created_at, updated_at)
SELECT p.post_id, '교육 링크 공유해 주실 수 있나요?', 'E0020', '이영희', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'
FROM platform_v3.bd_post p WHERE p.title LIKE '%정보보안%' LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO platform_v3.bd_comment (post_id, content, author_no, author_name, created_at, updated_at)
SELECT p.post_id, '강남역 3번 출구 "목화반점" 추천합니다. 룸 있고 가성비 좋아요.', 'E0010', '박과장', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'
FROM platform_v3.bd_post p WHERE p.title LIKE '%회식%' LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO platform_v3.bd_comment (post_id, content, author_no, author_name, created_at, updated_at)
SELECT p.post_id, '파스타 진짜 맛있었어요! 카르보나라 추천합니다.', 'E0010', '박과장', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'
FROM platform_v3.bd_post p WHERE p.title LIKE '%맛집%' LIMIT 1
ON CONFLICT DO NOTHING;

-- ============================================================
-- 4. 예시 데이터 — 캘린더 이벤트
-- ============================================================

INSERT INTO platform_v3.cal_event (title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, created_by, created_at, updated_at) VALUES
('2분기 킥오프 미팅', '전사 2분기 킥오프 미팅. 대회의실 A.', 'COMPANY', 1, 1, NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days' + INTERVAL '2 hours', false, '#3b82f6', 'E0001', NOW(), NOW()),
('팀 주간 스탠드업', '매주 월요일 오전 10시 개발팀 스탠드업 미팅', 'DEPT', 1, 1, NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days' + INTERVAL '30 minutes', false, '#10b981', 'E0001', NOW(), NOW()),
('연차 (김대표)', '개인 연차', 'PERSONAL', 1, 1, NOW() + INTERVAL '7 days', NOW() + INTERVAL '8 days', true, '#f59e0b', 'E0001', NOW(), NOW()),
('고객사 미팅', '㈜한국테크 2차 미팅 — 요구사항 확인', 'PERSONAL', 1, 1, NOW() + INTERVAL '5 days' + INTERVAL '14 hours', NOW() + INTERVAL '5 days' + INTERVAL '16 hours', false, '#ef4444', 'E0001', NOW(), NOW()),
('신입사원 OJT', '2026년 신입사원 OJT 교육 (1주간)', 'COMPANY', 1, 1, NOW() + INTERVAL '10 days', NOW() + INTERVAL '14 days', true, '#8b5cf6', 'E0001', NOW(), NOW()),
('분기 성과발표', '2026 Q1 성과 발표회. 강당.', 'COMPANY', 1, 1, NOW() + INTERVAL '15 days' + INTERVAL '10 hours', NOW() + INTERVAL '15 days' + INTERVAL '12 hours', false, '#06b6d4', 'E0001', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- 5. 예시 데이터 — 결재 문서 (기존 데이터가 있으면 스킵)
-- ============================================================

-- 출장신청서 1건 (APPROVED)
INSERT INTO platform_v3.ap_document (doc_title, form_code, drafter_no, drafter_name, drafter_dept, status, content, amount, created_at, updated_at)
SELECT '서울 고객사 출장 (4/20~4/21)', 'BIZTRIP', 'E0001', '김대표', '경영지원팀', 'APPROVED',
       '목적: ㈜한국테크 2차 미팅 및 계약 검토\n기간: 4/20(월)~4/21(화)\n장소: 서울 강남구\n예상비용: 350,000원',
       350000, NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days'
WHERE NOT EXISTS (SELECT 1 FROM platform_v3.ap_document WHERE doc_title LIKE '%서울 고객사%');

-- 휴가신청서 1건 (PENDING)
INSERT INTO platform_v3.ap_document (doc_title, form_code, drafter_no, drafter_name, drafter_dept, status, content, amount, created_at, updated_at)
SELECT '연차 사용 (5/5~5/6)', 'LEAVE', 'E0020', '이영희', '개발팀', 'PENDING',
       '사유: 개인 사유\n기간: 5/5(월)~5/6(화) 2일\n비상연락처: 010-xxxx-xxxx',
       0, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'
WHERE NOT EXISTS (SELECT 1 FROM platform_v3.ap_document WHERE doc_title LIKE '%연차 사용%');

-- 지출결의서 1건 (IN_PROGRESS)
INSERT INTO platform_v3.ap_document (doc_title, form_code, drafter_no, drafter_name, drafter_dept, status, content, amount, created_at, updated_at)
SELECT '4월 프로젝트 서버 비용 결의', 'EXPENSE', 'E0001', '김대표', '경영지원팀', 'IN_PROGRESS',
       'AWS EC2 + RDS 4월분 비용 정산\n\n- EC2 m5.xlarge x2: 580,000원\n- RDS r5.large: 420,000원\n- S3 + CloudFront: 150,000원\n합계: 1,150,000원',
       1150000, NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'
WHERE NOT EXISTS (SELECT 1 FROM platform_v3.ap_document WHERE doc_title LIKE '%서버 비용%');
