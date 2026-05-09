-- V19: 잔여 페이지 (Mail/Dashboard/Search/Room/DataLib/WorkLog/NotifySettings/Favorites/403) 보강
-- BUTTON, LABEL, PLACEHOLDER, MSG 키 × 4 언어 (ko/en/zh/ja)

SET search_path TO platform_v3, public;

-- ==============================================================
-- 1. BUTTON
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('BTN_COMPOSE_MAIL','ko','BUTTON','새 메일'),('BTN_COMPOSE_MAIL','en','BUTTON','Compose'),('BTN_COMPOSE_MAIL','zh','BUTTON','新邮件'),('BTN_COMPOSE_MAIL','ja','BUTTON','新規メール'),
('BTN_DASH_EDIT','ko','BUTTON','편집'),('BTN_DASH_EDIT','en','BUTTON','Edit'),('BTN_DASH_EDIT','zh','BUTTON','编辑'),('BTN_DASH_EDIT','ja','BUTTON','編集'),
('BTN_DASH_ADD_WIDGET','ko','BUTTON','위젯 추가'),('BTN_DASH_ADD_WIDGET','en','BUTTON','Add Widget'),('BTN_DASH_ADD_WIDGET','zh','BUTTON','添加小部件'),('BTN_DASH_ADD_WIDGET','ja','BUTTON','ウィジェット追加'),
('BTN_BOOK_ROOM','ko','BUTTON','예약하기'),('BTN_BOOK_ROOM','en','BUTTON','Book'),('BTN_BOOK_ROOM','zh','BUTTON','预订'),('BTN_BOOK_ROOM','ja','BUTTON','予約する'),
('BTN_RESET_DEFAULT','ko','BUTTON','기본값으로'),('BTN_RESET_DEFAULT','en','BUTTON','Reset to Default'),('BTN_RESET_DEFAULT','zh','BUTTON','恢复默认'),('BTN_RESET_DEFAULT','ja','BUTTON','デフォルト'),
('BTN_GO_DASHBOARD','ko','BUTTON','대시보드로 이동'),('BTN_GO_DASHBOARD','en','BUTTON','Go to Dashboard'),('BTN_GO_DASHBOARD','zh','BUTTON','返回仪表盘'),('BTN_GO_DASHBOARD','ja','BUTTON','ダッシュボードへ'),
('BTN_NEW_FOLDER','ko','BUTTON','새 폴더'),('BTN_NEW_FOLDER','en','BUTTON','New Folder'),('BTN_NEW_FOLDER','zh','BUTTON','新建文件夹'),('BTN_NEW_FOLDER','ja','BUTTON','新規フォルダ'),
('BTN_UPLOAD','ko','BUTTON','업로드'),('BTN_UPLOAD','en','BUTTON','Upload'),('BTN_UPLOAD','zh','BUTTON','上传'),('BTN_UPLOAD','ja','BUTTON','アップロード'),
('BTN_DOWNLOAD','ko','BUTTON','다운로드'),('BTN_DOWNLOAD','en','BUTTON','Download'),('BTN_DOWNLOAD','zh','BUTTON','下载'),('BTN_DOWNLOAD','ja','BUTTON','ダウンロード'),
('BTN_RENAME','ko','BUTTON','이름변경'),('BTN_RENAME','en','BUTTON','Rename'),('BTN_RENAME','zh','BUTTON','重命名'),('BTN_RENAME','ja','BUTTON','名前変更'),
('BTN_LOGIN_KC','ko','BUTTON','Keycloak으로 로그인'),('BTN_LOGIN_KC','en','BUTTON','Sign in with Keycloak'),('BTN_LOGIN_KC','zh','BUTTON','使用 Keycloak 登录'),('BTN_LOGIN_KC','ja','BUTTON','Keycloak でログイン')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 2. LABEL — 잔여 페이지 카드/패널
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
-- Dashboard
('LBL_DASH_GREETING','ko','LABEL','안녕하세요, {name}님'),('LBL_DASH_GREETING','en','LABEL','Welcome, {name}'),('LBL_DASH_GREETING','zh','LABEL','您好，{name}'),('LBL_DASH_GREETING','ja','LABEL','こんにちは、{name}様'),
('LBL_DASH_PICK_WIDGET','ko','LABEL','추가할 위젯 선택'),('LBL_DASH_PICK_WIDGET','en','LABEL','Pick a widget to add'),('LBL_DASH_PICK_WIDGET','zh','LABEL','选择要添加的小部件'),('LBL_DASH_PICK_WIDGET','ja','LABEL','追加するウィジェットを選択'),
('LBL_DASH_GUEST','ko','LABEL','사용자'),('LBL_DASH_GUEST','en','LABEL','User'),('LBL_DASH_GUEST','zh','LABEL','用户'),('LBL_DASH_GUEST','ja','LABEL','ユーザー'),
-- Search
('LBL_SEARCH_TARGETS','ko','LABEL','대상'),('LBL_SEARCH_TARGETS','en','LABEL','Targets'),('LBL_SEARCH_TARGETS','zh','LABEL','对象'),('LBL_SEARCH_TARGETS','ja','LABEL','対象'),
('LBL_SEARCH_POST','ko','LABEL','게시글'),('LBL_SEARCH_POST','en','LABEL','Posts'),('LBL_SEARCH_POST','zh','LABEL','帖子'),('LBL_SEARCH_POST','ja','LABEL','投稿'),
('LBL_SEARCH_DOC','ko','LABEL','결재'),('LBL_SEARCH_DOC','en','LABEL','Approval'),('LBL_SEARCH_DOC','zh','LABEL','审批'),('LBL_SEARCH_DOC','ja','LABEL','決裁'),
('LBL_SEARCH_EMP','ko','LABEL','사람'),('LBL_SEARCH_EMP','en','LABEL','People'),('LBL_SEARCH_EMP','zh','LABEL','人员'),('LBL_SEARCH_EMP','ja','LABEL','人'),
('LBL_SEARCH_FILE','ko','LABEL','파일'),('LBL_SEARCH_FILE','en','LABEL','Files'),('LBL_SEARCH_FILE','zh','LABEL','文件'),('LBL_SEARCH_FILE','ja','LABEL','ファイル'),
-- Room
('LBL_ROOM_MIN_CAPACITY','ko','LABEL','최소 인원'),('LBL_ROOM_MIN_CAPACITY','en','LABEL','Min Capacity'),('LBL_ROOM_MIN_CAPACITY','zh','LABEL','最少人数'),('LBL_ROOM_MIN_CAPACITY','ja','LABEL','最低人数'),
('LBL_ROOM_HAS_VIDEO','ko','LABEL','화상회의 가능'),('LBL_ROOM_HAS_VIDEO','en','LABEL','Video conference'),('LBL_ROOM_HAS_VIDEO','zh','LABEL','支持视频会议'),('LBL_ROOM_HAS_VIDEO','ja','LABEL','ビデオ会議可能'),
('LBL_ROOM_LOADING','ko','LABEL','불러오는 중...'),('LBL_ROOM_LOADING','en','LABEL','Loading...'),('LBL_ROOM_LOADING','zh','LABEL','加载中...'),('LBL_ROOM_LOADING','ja','LABEL','読み込み中...'),
('LBL_ROOM_EMPTY','ko','LABEL','조건에 맞는 회의실이 없습니다'),('LBL_ROOM_EMPTY','en','LABEL','No rooms match'),('LBL_ROOM_EMPTY','zh','LABEL','没有符合条件的会议室'),('LBL_ROOM_EMPTY','ja','LABEL','条件に合う会議室がありません'),
('LBL_ROOM_SELECT_HINT','ko','LABEL','회의실을 선택하면 예약 현황이 표시됩니다'),('LBL_ROOM_SELECT_HINT','en','LABEL','Select a room to view bookings'),('LBL_ROOM_SELECT_HINT','zh','LABEL','选择会议室查看预订情况'),('LBL_ROOM_SELECT_HINT','ja','LABEL','会議室を選択すると予約状況が表示されます'),
('LBL_ROOM_CAPACITY_SUFFIX','ko','LABEL','정원 {n}명'),('LBL_ROOM_CAPACITY_SUFFIX','en','LABEL','Capacity {n}'),('LBL_ROOM_CAPACITY_SUFFIX','zh','LABEL','容量 {n}'),('LBL_ROOM_CAPACITY_SUFFIX','ja','LABEL','定員 {n}名'),
-- DataLibrary
('LBL_DATALIB_FOLDERS','ko','LABEL','폴더'),('LBL_DATALIB_FOLDERS','en','LABEL','Folders'),('LBL_DATALIB_FOLDERS','zh','LABEL','文件夹'),('LBL_DATALIB_FOLDERS','ja','LABEL','フォルダ'),
-- WorkLog
('LBL_WORKLOG_VIEW_MINE','ko','LABEL','본인 뷰'),('LBL_WORKLOG_VIEW_MINE','en','LABEL','My View'),('LBL_WORKLOG_VIEW_MINE','zh','LABEL','本人视图'),('LBL_WORKLOG_VIEW_MINE','ja','LABEL','本人ビュー'),
('LBL_WORKLOG_VIEW_TEAM','ko','LABEL','팀 뷰'),('LBL_WORKLOG_VIEW_TEAM','en','LABEL','Team View'),('LBL_WORKLOG_VIEW_TEAM','zh','LABEL','团队视图'),('LBL_WORKLOG_VIEW_TEAM','ja','LABEL','チームビュー'),
('LBL_WORKLOG_CALENDAR','ko','LABEL','캘린더'),('LBL_WORKLOG_CALENDAR','en','LABEL','Calendar'),('LBL_WORKLOG_CALENDAR','zh','LABEL','日历'),('LBL_WORKLOG_CALENDAR','ja','LABEL','カレンダー'),
-- NotifySettings
('LBL_NOTIFY_NOTE','ko','LABEL','각 카테고리별로 알림을 받을 채널을 선택하세요. 포탈은 헤더 종 아이콘에 SSE 로 즉시 알림, 이메일은 등록된 메일 주소로 발송, 메신저는 Rocket.Chat DM 으로 전달됩니다.'),
('LBL_NOTIFY_NOTE','en','LABEL','Select channels per category. Portal: real-time bell icon (SSE). Email: registered address. Messenger: Rocket.Chat DM.'),
('LBL_NOTIFY_NOTE','zh','LABEL','为每个类别选择接收通知的渠道。门户：通过 SSE 实时显示在铃铛图标。邮件：发送至已注册邮箱。聊天：通过 Rocket.Chat 私信。'),
('LBL_NOTIFY_NOTE','ja','LABEL','カテゴリーごとに通知を受け取るチャネルを選択してください。ポータル：SSE でベルアイコンに即時通知。メール：登録メールアドレス宛。メッセンジャー：Rocket.Chat DM。'),
-- Favorites
('LBL_FAVORITES_TITLE','ko','LABEL','즐겨찾기 관리'),('LBL_FAVORITES_TITLE','en','LABEL','Manage Favorites'),('LBL_FAVORITES_TITLE','zh','LABEL','管理收藏夹'),('LBL_FAVORITES_TITLE','ja','LABEL','お気に入り管理'),
('LBL_FAVORITES_EMPTY','ko','LABEL','등록된 즐겨찾기가 없습니다.'),('LBL_FAVORITES_EMPTY','en','LABEL','No favorites yet.'),('LBL_FAVORITES_EMPTY','zh','LABEL','尚无收藏。'),('LBL_FAVORITES_EMPTY','ja','LABEL','お気に入りがありません。'),
-- Login
('LBL_LOGIN_TITLE','ko','LABEL','openplatform v3'),('LBL_LOGIN_TITLE','en','LABEL','openplatform v3'),('LBL_LOGIN_TITLE','zh','LABEL','openplatform v3'),('LBL_LOGIN_TITLE','ja','LABEL','openplatform v3'),
('LBL_LOGIN_SUBTITLE','ko','LABEL','통합 그룹웨어 — Keycloak SSO'),('LBL_LOGIN_SUBTITLE','en','LABEL','Unified Groupware — Keycloak SSO'),('LBL_LOGIN_SUBTITLE','zh','LABEL','统一协作平台 — Keycloak SSO'),('LBL_LOGIN_SUBTITLE','ja','LABEL','統合グループウェア — Keycloak SSO'),
('LBL_LOGIN_HINT','ko','LABEL','admin / admin 또는 user1 / user1'),('LBL_LOGIN_HINT','en','LABEL','admin / admin or user1 / user1'),('LBL_LOGIN_HINT','zh','LABEL','admin / admin 或 user1 / user1'),('LBL_LOGIN_HINT','ja','LABEL','admin / admin または user1 / user1'),
-- Board detail
('LBL_BOARD_DETAIL_HEADER','ko','LABEL','게시글 상세'),('LBL_BOARD_DETAIL_HEADER','en','LABEL','Post Detail'),('LBL_BOARD_DETAIL_HEADER','zh','LABEL','帖子详情'),('LBL_BOARD_DETAIL_HEADER','ja','LABEL','投稿詳細'),
-- Approval detail / Calendar event / Org employee / Mail compose / Room booking dialog 기본 헤더
('LBL_APPROVAL_DETAIL_HEADER','ko','LABEL','결재 문서 상세'),('LBL_APPROVAL_DETAIL_HEADER','en','LABEL','Approval Document Detail'),('LBL_APPROVAL_DETAIL_HEADER','zh','LABEL','审批文档详情'),('LBL_APPROVAL_DETAIL_HEADER','ja','LABEL','決裁文書詳細'),
('LBL_CAL_EVENT_NEW','ko','LABEL','새 일정'),('LBL_CAL_EVENT_NEW','en','LABEL','New Event'),('LBL_CAL_EVENT_NEW','zh','LABEL','新建日程'),('LBL_CAL_EVENT_NEW','ja','LABEL','新規予定'),
('LBL_CAL_EVENT_EDIT','ko','LABEL','일정 수정'),('LBL_CAL_EVENT_EDIT','en','LABEL','Edit Event'),('LBL_CAL_EVENT_EDIT','zh','LABEL','编辑日程'),('LBL_CAL_EVENT_EDIT','ja','LABEL','予定編集'),
('LBL_CAL_COLOR','ko','LABEL','색상'),('LBL_CAL_COLOR','en','LABEL','Color'),('LBL_CAL_COLOR','zh','LABEL','颜色'),('LBL_CAL_COLOR','ja','LABEL','色'),
('LBL_CAL_DESCRIPTION','ko','LABEL','설명'),('LBL_CAL_DESCRIPTION','en','LABEL','Description'),('LBL_CAL_DESCRIPTION','zh','LABEL','描述'),('LBL_CAL_DESCRIPTION','ja','LABEL','説明'),
('LBL_EMP_DETAIL_HEADER','ko','LABEL','직원 상세'),('LBL_EMP_DETAIL_HEADER','en','LABEL','Employee Detail'),('LBL_EMP_DETAIL_HEADER','zh','LABEL','员工详情'),('LBL_EMP_DETAIL_HEADER','ja','LABEL','社員詳細'),
('LBL_EMP_HIRE_DATE','ko','LABEL','입사일'),('LBL_EMP_HIRE_DATE','en','LABEL','Hire Date'),('LBL_EMP_HIRE_DATE','zh','LABEL','入职日期'),('LBL_EMP_HIRE_DATE','ja','LABEL','入社日'),
('BTN_EMP_DM','ko','BUTTON','메신저 DM'),('BTN_EMP_DM','en','BUTTON','Messenger DM'),('BTN_EMP_DM','zh','BUTTON','即时消息'),('BTN_EMP_DM','ja','BUTTON','メッセンジャー DM'),
('BTN_EMP_MAIL','ko','BUTTON','메일 보내기'),('BTN_EMP_MAIL','en','BUTTON','Send Mail'),('BTN_EMP_MAIL','zh','BUTTON','发送邮件'),('BTN_EMP_MAIL','ja','BUTTON','メール送信'),
('LBL_MAIL_COMPOSE_HEADER','ko','LABEL','새 메일 작성'),('LBL_MAIL_COMPOSE_HEADER','en','LABEL','New Mail'),('LBL_MAIL_COMPOSE_HEADER','zh','LABEL','撰写邮件'),('LBL_MAIL_COMPOSE_HEADER','ja','LABEL','新規メール作成'),
('LBL_MAIL_REPLY','ko','LABEL','답장'),('LBL_MAIL_REPLY','en','LABEL','Reply'),('LBL_MAIL_REPLY','zh','LABEL','回复'),('LBL_MAIL_REPLY','ja','LABEL','返信'),
('LBL_MAIL_FORWARD','ko','LABEL','전달'),('LBL_MAIL_FORWARD','en','LABEL','Forward'),('LBL_MAIL_FORWARD','zh','LABEL','转发'),('LBL_MAIL_FORWARD','ja','LABEL','転送'),
('LBL_MAIL_TO','ko','LABEL','받는 사람'),('LBL_MAIL_TO','en','LABEL','To'),('LBL_MAIL_TO','zh','LABEL','收件人'),('LBL_MAIL_TO','ja','LABEL','宛先'),
('LBL_MAIL_CC','ko','LABEL','참조 (CC)'),('LBL_MAIL_CC','en','LABEL','Cc'),('LBL_MAIL_CC','zh','LABEL','抄送'),('LBL_MAIL_CC','ja','LABEL','Cc'),
('LBL_MAIL_OPTIONAL','ko','LABEL','선택'),('LBL_MAIL_OPTIONAL','en','LABEL','optional'),('LBL_MAIL_OPTIONAL','zh','LABEL','可选'),('LBL_MAIL_OPTIONAL','ja','LABEL','任意'),
('BTN_MAIL_DRAFT','ko','BUTTON','임시저장'),('BTN_MAIL_DRAFT','en','BUTTON','Save Draft'),('BTN_MAIL_DRAFT','zh','BUTTON','保存草稿'),('BTN_MAIL_DRAFT','ja','BUTTON','下書き保存'),
('BTN_MAIL_SEND','ko','BUTTON','발송'),('BTN_MAIL_SEND','en','BUTTON','Send'),('BTN_MAIL_SEND','zh','BUTTON','发送'),('BTN_MAIL_SEND','ja','BUTTON','送信'),
('LBL_ROOM_BOOKING_HEADER','ko','LABEL','회의실 예약'),('LBL_ROOM_BOOKING_HEADER','en','LABEL','Book Room'),('LBL_ROOM_BOOKING_HEADER','zh','LABEL','预订会议室'),('LBL_ROOM_BOOKING_HEADER','ja','LABEL','会議室予約'),
('LBL_ROOM_LABEL','ko','LABEL','회의실'),('LBL_ROOM_LABEL','en','LABEL','Room'),('LBL_ROOM_LABEL','zh','LABEL','会议室'),('LBL_ROOM_LABEL','ja','LABEL','会議室'),
('LBL_ROOM_ATTENDEES','ko','LABEL','참석자'),('LBL_ROOM_ATTENDEES','en','LABEL','Attendees'),('LBL_ROOM_ATTENDEES','zh','LABEL','参与者'),('LBL_ROOM_ATTENDEES','ja','LABEL','参加者'),
('LBL_ROOM_AUTO_VIDEO','ko','LABEL','화상회의 자동 생성 (이 회의실은 LiveKit 연동)'),('LBL_ROOM_AUTO_VIDEO','en','LABEL','Auto-create video conference (LiveKit-enabled room)'),('LBL_ROOM_AUTO_VIDEO','zh','LABEL','自动创建视频会议 (此会议室已接入 LiveKit)'),('LBL_ROOM_AUTO_VIDEO','ja','LABEL','ビデオ会議自動生成 (LiveKit 連携会議室)'),
('PH_ROOM_MEETING_TITLE','ko','PLACEHOLDER','회의 제목'),('PH_ROOM_MEETING_TITLE','en','PLACEHOLDER','Meeting title'),('PH_ROOM_MEETING_TITLE','zh','PLACEHOLDER','会议标题'),('PH_ROOM_MEETING_TITLE','ja','PLACEHOLDER','会議タイトル'),
('PH_ROOM_SELECT','ko','PLACEHOLDER','회의실 선택'),('PH_ROOM_SELECT','en','PLACEHOLDER','Select a room'),('PH_ROOM_SELECT','zh','PLACEHOLDER','选择会议室'),('PH_ROOM_SELECT','ja','PLACEHOLDER','会議室を選択'),
('PH_ROOM_ATTENDEES','ko','PLACEHOLDER','참석자 선택'),('PH_ROOM_ATTENDEES','en','PLACEHOLDER','Select attendees'),('PH_ROOM_ATTENDEES','zh','PLACEHOLDER','选择参与者'),('PH_ROOM_ATTENDEES','ja','PLACEHOLDER','参加者選択'),
-- 403
('LBL_FORBIDDEN_DETAIL','ko','LABEL','이 페이지에 대한 접근 권한이 없습니다. 관리자에게 문의하세요.'),
('LBL_FORBIDDEN_DETAIL','en','LABEL','You do not have permission to access this page. Please contact your administrator.'),
('LBL_FORBIDDEN_DETAIL','zh','LABEL','您没有访问此页面的权限。请联系管理员。'),
('LBL_FORBIDDEN_DETAIL','ja','LABEL','このページへのアクセス権限がありません。管理者にお問い合わせください。')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 3. PLACEHOLDER
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('PH_GLOBAL_SEARCH','ko','PLACEHOLDER','통합 검색...'),('PH_GLOBAL_SEARCH','en','PLACEHOLDER','Global search...'),('PH_GLOBAL_SEARCH','zh','PLACEHOLDER','综合搜索...'),('PH_GLOBAL_SEARCH','ja','PLACEHOLDER','統合検索...'),
('PH_ROOM_SEARCH','ko','PLACEHOLDER','회의실 검색'),('PH_ROOM_SEARCH','en','PLACEHOLDER','Search rooms'),('PH_ROOM_SEARCH','zh','PLACEHOLDER','搜索会议室'),('PH_ROOM_SEARCH','ja','PLACEHOLDER','会議室検索')
ON CONFLICT DO NOTHING;
