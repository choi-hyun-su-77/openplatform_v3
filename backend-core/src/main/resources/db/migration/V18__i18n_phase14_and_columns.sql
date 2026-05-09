-- V18: i18n 전수 보완
-- ==============================================================
-- V9 의 기본 라벨/메시지/메뉴/버튼 위에, 다음을 일괄 추가:
--   1) MENU   — Phase 14 신규 메뉴 13개 + 부모 그룹 4개 = 17개 키
--   2) GRID_COL — 전 페이지의 DataTable 헤더 (~100 키)
--   3) LABEL  — 페이지 제목 + 다이얼로그/폼 라벨 + 카드 제목 (~60 키)
--   4) PLACEHOLDER — 검색/입력 placeholder (~25 키)
--   5) BUTTON — 페이지/다이얼로그 액션 버튼 (~25 키)
--   6) STATUS — Approval/Attendance/Leave 상태 라벨 (~25 키)
--   7) FORM   — 결재 양식 코드명 (~7 키)
--   8) BOX    — 결재함 9 박스 코드명
--   9) LEAVE_TYPE — 휴가 유형 6 키
--  10) MSG    — 검증/확인/오류 메시지 보강 (~30 키)
--
-- 모든 키 × 4 언어 (ko/en/zh/ja). msg_type 은 cm_i18n_message 의 표준 분류:
--   LABEL / BUTTON / MENU / MSG  (V9 와 동일)
--   GRID_COL / PLACEHOLDER / STATUS / FORM / BOX / LEAVE_TYPE 는 V18 신규 분류.
-- ==============================================================

SET search_path TO platform_v3, public;

-- ==============================================================
-- 1. MENU — Phase 14 신규 메뉴 17개 (V17 기반)
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
-- 부모 그룹
('MENU_MYWORK','ko','MENU','내 업무'),('MENU_MYWORK','en','MENU','My Work'),('MENU_MYWORK','zh','MENU','我的工作'),('MENU_MYWORK','ja','MENU','マイワーク'),
('MENU_WORK','ko','MENU','업무'),('MENU_WORK','en','MENU','Work'),('MENU_WORK','zh','MENU','业务'),('MENU_WORK','ja','MENU','業務'),
('MENU_SETTINGS_GROUP','ko','MENU','설정'),('MENU_SETTINGS_GROUP','en','MENU','Settings'),('MENU_SETTINGS_GROUP','zh','MENU','设置'),('MENU_SETTINGS_GROUP','ja','MENU','設定'),
('MENU_ADMIN','ko','MENU','시스템관리'),('MENU_ADMIN','en','MENU','Admin'),('MENU_ADMIN','zh','MENU','系统管理'),('MENU_ADMIN','ja','MENU','システム管理'),
-- 통합검색
('MENU_SEARCH','ko','MENU','통합검색'),('MENU_SEARCH','en','MENU','Search'),('MENU_SEARCH','zh','MENU','综合搜索'),('MENU_SEARCH','ja','MENU','統合検索'),
-- mywork 자식
('MENU_ATTENDANCE','ko','MENU','근태'),('MENU_ATTENDANCE','en','MENU','Attendance'),('MENU_ATTENDANCE','zh','MENU','考勤'),('MENU_ATTENDANCE','ja','MENU','勤怠'),
('MENU_LEAVE','ko','MENU','연차/휴가'),('MENU_LEAVE','en','MENU','Leave'),('MENU_LEAVE','zh','MENU','年假/休假'),('MENU_LEAVE','ja','MENU','年次/休暇'),
('MENU_WORKLOG','ko','MENU','업무일지'),('MENU_WORKLOG','en','MENU','Work Log'),('MENU_WORKLOG','zh','MENU','工作日志'),('MENU_WORKLOG','ja','MENU','業務日誌'),
-- work 자식
('MENU_ROOM','ko','MENU','회의실예약'),('MENU_ROOM','en','MENU','Room Booking'),('MENU_ROOM','zh','MENU','会议室预订'),('MENU_ROOM','ja','MENU','会議室予約'),
('MENU_DATALIB','ko','MENU','자료실'),('MENU_DATALIB','en','MENU','Data Library'),('MENU_DATALIB','zh','MENU','资料室'),('MENU_DATALIB','ja','MENU','資料室'),
-- settings 자식
('MENU_SETTINGS_NOTIFY','ko','MENU','알림설정'),('MENU_SETTINGS_NOTIFY','en','MENU','Notification Settings'),('MENU_SETTINGS_NOTIFY','zh','MENU','通知设置'),('MENU_SETTINGS_NOTIFY','ja','MENU','通知設定'),
('MENU_SETTINGS_FAV','ko','MENU','즐겨찾기'),('MENU_SETTINGS_FAV','en','MENU','Favorites'),('MENU_SETTINGS_FAV','zh','MENU','收藏夹'),('MENU_SETTINGS_FAV','ja','MENU','お気に入り'),
-- admin 자식
('MENU_ADMIN_USERS','ko','MENU','사용자관리'),('MENU_ADMIN_USERS','en','MENU','User Management'),('MENU_ADMIN_USERS','zh','MENU','用户管理'),('MENU_ADMIN_USERS','ja','MENU','ユーザー管理'),
('MENU_ADMIN_DEPTS','ko','MENU','조직관리'),('MENU_ADMIN_DEPTS','en','MENU','Department Management'),('MENU_ADMIN_DEPTS','zh','MENU','组织管理'),('MENU_ADMIN_DEPTS','ja','MENU','組織管理'),
('MENU_ADMIN_MENUS','ko','MENU','메뉴관리'),('MENU_ADMIN_MENUS','en','MENU','Menu Management'),('MENU_ADMIN_MENUS','zh','MENU','菜单管理'),('MENU_ADMIN_MENUS','ja','MENU','メニュー管理'),
('MENU_ADMIN_CODES','ko','MENU','공통코드'),('MENU_ADMIN_CODES','en','MENU','Common Codes'),('MENU_ADMIN_CODES','zh','MENU','公共代码'),('MENU_ADMIN_CODES','ja','MENU','共通コード'),
('MENU_ADMIN_AUDIT','ko','MENU','감사로그'),('MENU_ADMIN_AUDIT','en','MENU','Audit Log'),('MENU_ADMIN_AUDIT','zh','MENU','审计日志'),('MENU_ADMIN_AUDIT','ja','MENU','監査ログ')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 2. LABEL — 페이지 헤더 (page H2 등)
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('LBL_PAGE_APPROVAL','ko','LABEL','전자결재'),('LBL_PAGE_APPROVAL','en','LABEL','Approval'),('LBL_PAGE_APPROVAL','zh','LABEL','电子审批'),('LBL_PAGE_APPROVAL','ja','LABEL','電子決裁'),
('LBL_PAGE_BOARD','ko','LABEL','게시판'),('LBL_PAGE_BOARD','en','LABEL','Board'),('LBL_PAGE_BOARD','zh','LABEL','公告板'),('LBL_PAGE_BOARD','ja','LABEL','掲示板'),
('LBL_PAGE_CALENDAR','ko','LABEL','캘린더'),('LBL_PAGE_CALENDAR','en','LABEL','Calendar'),('LBL_PAGE_CALENDAR','zh','LABEL','日历'),('LBL_PAGE_CALENDAR','ja','LABEL','カレンダー'),
('LBL_PAGE_ORG','ko','LABEL','조직도'),('LBL_PAGE_ORG','en','LABEL','Organization'),('LBL_PAGE_ORG','zh','LABEL','组织架构'),('LBL_PAGE_ORG','ja','LABEL','組織図'),
('LBL_PAGE_MAIL','ko','LABEL','메일'),('LBL_PAGE_MAIL','en','LABEL','Mail'),('LBL_PAGE_MAIL','zh','LABEL','邮件'),('LBL_PAGE_MAIL','ja','LABEL','メール'),
('LBL_PAGE_MESSENGER','ko','LABEL','메신저'),('LBL_PAGE_MESSENGER','en','LABEL','Messenger'),('LBL_PAGE_MESSENGER','zh','LABEL','即时通讯'),('LBL_PAGE_MESSENGER','ja','LABEL','メッセンジャー'),
('LBL_PAGE_WIKI','ko','LABEL','위키'),('LBL_PAGE_WIKI','en','LABEL','Wiki'),('LBL_PAGE_WIKI','zh','LABEL','维基'),('LBL_PAGE_WIKI','ja','LABEL','ウィキ'),
('LBL_PAGE_VIDEO','ko','LABEL','화상회의'),('LBL_PAGE_VIDEO','en','LABEL','Video Conference'),('LBL_PAGE_VIDEO','zh','LABEL','视频会议'),('LBL_PAGE_VIDEO','ja','LABEL','ビデオ会議'),
('LBL_PAGE_DASHBOARD','ko','LABEL','대시보드'),('LBL_PAGE_DASHBOARD','en','LABEL','Dashboard'),('LBL_PAGE_DASHBOARD','zh','LABEL','仪表盘'),('LBL_PAGE_DASHBOARD','ja','LABEL','ダッシュボード'),
('LBL_PAGE_ATTENDANCE','ko','LABEL','근태'),('LBL_PAGE_ATTENDANCE','en','LABEL','Attendance'),('LBL_PAGE_ATTENDANCE','zh','LABEL','考勤'),('LBL_PAGE_ATTENDANCE','ja','LABEL','勤怠'),
('LBL_PAGE_LEAVE','ko','LABEL','연차 / 휴가'),('LBL_PAGE_LEAVE','en','LABEL','Leave'),('LBL_PAGE_LEAVE','zh','LABEL','年假 / 休假'),('LBL_PAGE_LEAVE','ja','LABEL','年次 / 休暇'),
('LBL_PAGE_WORKLOG','ko','LABEL','업무일지'),('LBL_PAGE_WORKLOG','en','LABEL','Work Log'),('LBL_PAGE_WORKLOG','zh','LABEL','工作日志'),('LBL_PAGE_WORKLOG','ja','LABEL','業務日誌'),
('LBL_PAGE_ROOM','ko','LABEL','회의실 예약'),('LBL_PAGE_ROOM','en','LABEL','Room Booking'),('LBL_PAGE_ROOM','zh','LABEL','会议室预订'),('LBL_PAGE_ROOM','ja','LABEL','会議室予約'),
('LBL_PAGE_DATALIB','ko','LABEL','자료실'),('LBL_PAGE_DATALIB','en','LABEL','Data Library'),('LBL_PAGE_DATALIB','zh','LABEL','资料室'),('LBL_PAGE_DATALIB','ja','LABEL','資料室'),
('LBL_PAGE_SEARCH','ko','LABEL','통합 검색'),('LBL_PAGE_SEARCH','en','LABEL','Search'),('LBL_PAGE_SEARCH','zh','LABEL','综合搜索'),('LBL_PAGE_SEARCH','ja','LABEL','統合検索'),
('LBL_PAGE_NOTIFY_SETTINGS','ko','LABEL','알림 설정'),('LBL_PAGE_NOTIFY_SETTINGS','en','LABEL','Notification Settings'),('LBL_PAGE_NOTIFY_SETTINGS','zh','LABEL','通知设置'),('LBL_PAGE_NOTIFY_SETTINGS','ja','LABEL','通知設定'),
('LBL_PAGE_FAVORITES','ko','LABEL','즐겨찾기'),('LBL_PAGE_FAVORITES','en','LABEL','Favorites'),('LBL_PAGE_FAVORITES','zh','LABEL','收藏夹'),('LBL_PAGE_FAVORITES','ja','LABEL','お気に入り'),
('LBL_PAGE_ADMIN_USERS','ko','LABEL','사용자 관리'),('LBL_PAGE_ADMIN_USERS','en','LABEL','User Management'),('LBL_PAGE_ADMIN_USERS','zh','LABEL','用户管理'),('LBL_PAGE_ADMIN_USERS','ja','LABEL','ユーザー管理'),
('LBL_PAGE_ADMIN_DEPTS','ko','LABEL','조직 관리'),('LBL_PAGE_ADMIN_DEPTS','en','LABEL','Department Management'),('LBL_PAGE_ADMIN_DEPTS','zh','LABEL','组织管理'),('LBL_PAGE_ADMIN_DEPTS','ja','LABEL','組織管理'),
('LBL_PAGE_ADMIN_MENUS','ko','LABEL','메뉴 / 권한 관리'),('LBL_PAGE_ADMIN_MENUS','en','LABEL','Menu / Permission Management'),('LBL_PAGE_ADMIN_MENUS','zh','LABEL','菜单 / 权限管理'),('LBL_PAGE_ADMIN_MENUS','ja','LABEL','メニュー / 権限管理'),
('LBL_PAGE_ADMIN_CODES','ko','LABEL','공통코드 관리'),('LBL_PAGE_ADMIN_CODES','en','LABEL','Common Code Management'),('LBL_PAGE_ADMIN_CODES','zh','LABEL','公共代码管理'),('LBL_PAGE_ADMIN_CODES','ja','LABEL','共通コード管理'),
('LBL_PAGE_ADMIN_AUDIT','ko','LABEL','감사 로그'),('LBL_PAGE_ADMIN_AUDIT','en','LABEL','Audit Log'),('LBL_PAGE_ADMIN_AUDIT','zh','LABEL','审计日志'),('LBL_PAGE_ADMIN_AUDIT','ja','LABEL','監査ログ')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 3. GRID_COL — 페이지별 DataTable 컬럼 헤더
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
-- Approval inbox
('COL_APPROVAL_NO','ko','GRID_COL','번호'),('COL_APPROVAL_NO','en','GRID_COL','No.'),('COL_APPROVAL_NO','zh','GRID_COL','编号'),('COL_APPROVAL_NO','ja','GRID_COL','番号'),
('COL_APPROVAL_TITLE','ko','GRID_COL','제목'),('COL_APPROVAL_TITLE','en','GRID_COL','Title'),('COL_APPROVAL_TITLE','zh','GRID_COL','标题'),('COL_APPROVAL_TITLE','ja','GRID_COL','タイトル'),
('COL_APPROVAL_DRAFTER','ko','GRID_COL','기안자'),('COL_APPROVAL_DRAFTER','en','GRID_COL','Drafter'),('COL_APPROVAL_DRAFTER','zh','GRID_COL','起草人'),('COL_APPROVAL_DRAFTER','ja','GRID_COL','起案者'),
('COL_APPROVAL_DEPT','ko','GRID_COL','부서'),('COL_APPROVAL_DEPT','en','GRID_COL','Dept'),('COL_APPROVAL_DEPT','zh','GRID_COL','部门'),('COL_APPROVAL_DEPT','ja','GRID_COL','部署'),
('COL_APPROVAL_STATUS','ko','GRID_COL','상태'),('COL_APPROVAL_STATUS','en','GRID_COL','Status'),('COL_APPROVAL_STATUS','zh','GRID_COL','状态'),('COL_APPROVAL_STATUS','ja','GRID_COL','状態'),
('COL_APPROVAL_DRAFT_AT','ko','GRID_COL','기안일'),('COL_APPROVAL_DRAFT_AT','en','GRID_COL','Drafted At'),('COL_APPROVAL_DRAFT_AT','zh','GRID_COL','起草日期'),('COL_APPROVAL_DRAFT_AT','ja','GRID_COL','起案日'),
-- Board
('COL_BOARD_NO','ko','GRID_COL','번호'),('COL_BOARD_NO','en','GRID_COL','No.'),('COL_BOARD_NO','zh','GRID_COL','编号'),('COL_BOARD_NO','ja','GRID_COL','番号'),
('COL_BOARD_TITLE','ko','GRID_COL','제목'),('COL_BOARD_TITLE','en','GRID_COL','Title'),('COL_BOARD_TITLE','zh','GRID_COL','标题'),('COL_BOARD_TITLE','ja','GRID_COL','タイトル'),
('COL_BOARD_TYPE','ko','GRID_COL','분류'),('COL_BOARD_TYPE','en','GRID_COL','Category'),('COL_BOARD_TYPE','zh','GRID_COL','分类'),('COL_BOARD_TYPE','ja','GRID_COL','分類'),
('COL_BOARD_AUTHOR','ko','GRID_COL','작성자'),('COL_BOARD_AUTHOR','en','GRID_COL','Author'),('COL_BOARD_AUTHOR','zh','GRID_COL','作者'),('COL_BOARD_AUTHOR','ja','GRID_COL','作成者'),
('COL_BOARD_VIEWS','ko','GRID_COL','조회'),('COL_BOARD_VIEWS','en','GRID_COL','Views'),('COL_BOARD_VIEWS','zh','GRID_COL','浏览'),('COL_BOARD_VIEWS','ja','GRID_COL','閲覧'),
('COL_BOARD_CREATED_AT','ko','GRID_COL','작성일'),('COL_BOARD_CREATED_AT','en','GRID_COL','Created'),('COL_BOARD_CREATED_AT','zh','GRID_COL','创建日期'),('COL_BOARD_CREATED_AT','ja','GRID_COL','作成日'),
-- Admin Users
('COL_USER_NO','ko','GRID_COL','사번'),('COL_USER_NO','en','GRID_COL','Emp. No.'),('COL_USER_NO','zh','GRID_COL','工号'),('COL_USER_NO','ja','GRID_COL','社員番号'),
('COL_USER_NAME','ko','GRID_COL','이름'),('COL_USER_NAME','en','GRID_COL','Name'),('COL_USER_NAME','zh','GRID_COL','姓名'),('COL_USER_NAME','ja','GRID_COL','氏名'),
('COL_USER_DEPT','ko','GRID_COL','부서'),('COL_USER_DEPT','en','GRID_COL','Department'),('COL_USER_DEPT','zh','GRID_COL','部门'),('COL_USER_DEPT','ja','GRID_COL','部署'),
('COL_USER_POSITION','ko','GRID_COL','직책'),('COL_USER_POSITION','en','GRID_COL','Position'),('COL_USER_POSITION','zh','GRID_COL','职位'),('COL_USER_POSITION','ja','GRID_COL','役職'),
('COL_USER_EMAIL','ko','GRID_COL','이메일'),('COL_USER_EMAIL','en','GRID_COL','Email'),('COL_USER_EMAIL','zh','GRID_COL','邮箱'),('COL_USER_EMAIL','ja','GRID_COL','メール'),
('COL_USER_KC_USERNAME','ko','GRID_COL','KC username'),('COL_USER_KC_USERNAME','en','GRID_COL','KC Username'),('COL_USER_KC_USERNAME','zh','GRID_COL','KC 用户名'),('COL_USER_KC_USERNAME','ja','GRID_COL','KC ユーザー名'),
('COL_USER_STATUS','ko','GRID_COL','상태'),('COL_USER_STATUS','en','GRID_COL','Status'),('COL_USER_STATUS','zh','GRID_COL','状态'),('COL_USER_STATUS','ja','GRID_COL','状態'),
('COL_USER_ACTIONS','ko','GRID_COL','작업'),('COL_USER_ACTIONS','en','GRID_COL','Actions'),('COL_USER_ACTIONS','zh','GRID_COL','操作'),('COL_USER_ACTIONS','ja','GRID_COL','操作'),
-- Admin Codes
('COL_CODE_GROUP','ko','GRID_COL','그룹'),('COL_CODE_GROUP','en','GRID_COL','Group'),('COL_CODE_GROUP','zh','GRID_COL','组'),('COL_CODE_GROUP','ja','GRID_COL','グループ'),
('COL_CODE_CODE','ko','GRID_COL','코드'),('COL_CODE_CODE','en','GRID_COL','Code'),('COL_CODE_CODE','zh','GRID_COL','代码'),('COL_CODE_CODE','ja','GRID_COL','コード'),
('COL_CODE_NAME','ko','GRID_COL','코드명'),('COL_CODE_NAME','en','GRID_COL','Code Name'),('COL_CODE_NAME','zh','GRID_COL','代码名称'),('COL_CODE_NAME','ja','GRID_COL','コード名'),
('COL_CODE_SORT','ko','GRID_COL','순서'),('COL_CODE_SORT','en','GRID_COL','Order'),('COL_CODE_SORT','zh','GRID_COL','顺序'),('COL_CODE_SORT','ja','GRID_COL','順序'),
('COL_CODE_USE','ko','GRID_COL','사용'),('COL_CODE_USE','en','GRID_COL','Use'),('COL_CODE_USE','zh','GRID_COL','使用'),('COL_CODE_USE','ja','GRID_COL','使用'),
('COL_CODE_ACTIONS','ko','GRID_COL','작업'),('COL_CODE_ACTIONS','en','GRID_COL','Actions'),('COL_CODE_ACTIONS','zh','GRID_COL','操作'),('COL_CODE_ACTIONS','ja','GRID_COL','操作'),
-- Admin Audit
('COL_AUDIT_ID','ko','GRID_COL','ID'),('COL_AUDIT_ID','en','GRID_COL','ID'),('COL_AUDIT_ID','zh','GRID_COL','ID'),('COL_AUDIT_ID','ja','GRID_COL','ID'),
('COL_AUDIT_TIME','ko','GRID_COL','작업시각'),('COL_AUDIT_TIME','en','GRID_COL','Acted At'),('COL_AUDIT_TIME','zh','GRID_COL','操作时间'),('COL_AUDIT_TIME','ja','GRID_COL','操作時刻'),
('COL_AUDIT_ACTOR_NO','ko','GRID_COL','작업자'),('COL_AUDIT_ACTOR_NO','en','GRID_COL','Actor'),('COL_AUDIT_ACTOR_NO','zh','GRID_COL','操作者'),('COL_AUDIT_ACTOR_NO','ja','GRID_COL','操作者'),
('COL_AUDIT_ACTOR_NAME','ko','GRID_COL','이름'),('COL_AUDIT_ACTOR_NAME','en','GRID_COL','Name'),('COL_AUDIT_ACTOR_NAME','zh','GRID_COL','姓名'),('COL_AUDIT_ACTOR_NAME','ja','GRID_COL','氏名'),
('COL_AUDIT_ACTION','ko','GRID_COL','액션'),('COL_AUDIT_ACTION','en','GRID_COL','Action'),('COL_AUDIT_ACTION','zh','GRID_COL','操作'),('COL_AUDIT_ACTION','ja','GRID_COL','アクション'),
('COL_AUDIT_TARGET_TYPE','ko','GRID_COL','대상유형'),('COL_AUDIT_TARGET_TYPE','en','GRID_COL','Target Type'),('COL_AUDIT_TARGET_TYPE','zh','GRID_COL','对象类型'),('COL_AUDIT_TARGET_TYPE','ja','GRID_COL','対象種別'),
('COL_AUDIT_TARGET_ID','ko','GRID_COL','대상ID'),('COL_AUDIT_TARGET_ID','en','GRID_COL','Target ID'),('COL_AUDIT_TARGET_ID','zh','GRID_COL','对象ID'),('COL_AUDIT_TARGET_ID','ja','GRID_COL','対象ID'),
('COL_AUDIT_IP','ko','GRID_COL','IP'),('COL_AUDIT_IP','en','GRID_COL','IP'),('COL_AUDIT_IP','zh','GRID_COL','IP'),('COL_AUDIT_IP','ja','GRID_COL','IP'),
-- Admin Menu permission matrix
('COL_MENU_ROLE','ko','GRID_COL','역할'),('COL_MENU_ROLE','en','GRID_COL','Role'),('COL_MENU_ROLE','zh','GRID_COL','角色'),('COL_MENU_ROLE','ja','GRID_COL','役割'),
('COL_MENU_ID','ko','GRID_COL','메뉴'),('COL_MENU_ID','en','GRID_COL','Menu'),('COL_MENU_ID','zh','GRID_COL','菜单'),('COL_MENU_ID','ja','GRID_COL','メニュー'),
('COL_MENU_NAME','ko','GRID_COL','메뉴명'),('COL_MENU_NAME','en','GRID_COL','Menu Name'),('COL_MENU_NAME','zh','GRID_COL','菜单名'),('COL_MENU_NAME','ja','GRID_COL','メニュー名'),
-- Leave history
('COL_LEAVE_NO','ko','GRID_COL','번호'),('COL_LEAVE_NO','en','GRID_COL','No.'),('COL_LEAVE_NO','zh','GRID_COL','编号'),('COL_LEAVE_NO','ja','GRID_COL','番号'),
('COL_LEAVE_TYPE','ko','GRID_COL','유형'),('COL_LEAVE_TYPE','en','GRID_COL','Type'),('COL_LEAVE_TYPE','zh','GRID_COL','类型'),('COL_LEAVE_TYPE','ja','GRID_COL','種別'),
('COL_LEAVE_PERIOD','ko','GRID_COL','기간'),('COL_LEAVE_PERIOD','en','GRID_COL','Period'),('COL_LEAVE_PERIOD','zh','GRID_COL','期间'),('COL_LEAVE_PERIOD','ja','GRID_COL','期間'),
('COL_LEAVE_DAYS','ko','GRID_COL','일수'),('COL_LEAVE_DAYS','en','GRID_COL','Days'),('COL_LEAVE_DAYS','zh','GRID_COL','天数'),('COL_LEAVE_DAYS','ja','GRID_COL','日数'),
('COL_LEAVE_REASON','ko','GRID_COL','사유'),('COL_LEAVE_REASON','en','GRID_COL','Reason'),('COL_LEAVE_REASON','zh','GRID_COL','理由'),('COL_LEAVE_REASON','ja','GRID_COL','理由'),
('COL_LEAVE_STATUS','ko','GRID_COL','상태'),('COL_LEAVE_STATUS','en','GRID_COL','Status'),('COL_LEAVE_STATUS','zh','GRID_COL','状态'),('COL_LEAVE_STATUS','ja','GRID_COL','状態'),
('COL_LEAVE_APPLIED_AT','ko','GRID_COL','신청일'),('COL_LEAVE_APPLIED_AT','en','GRID_COL','Applied At'),('COL_LEAVE_APPLIED_AT','zh','GRID_COL','申请日'),('COL_LEAVE_APPLIED_AT','ja','GRID_COL','申請日')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 4. PLACEHOLDER — 검색/입력
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('PH_APPROVAL_SEARCH','ko','PLACEHOLDER','제목·기안자 검색'),('PH_APPROVAL_SEARCH','en','PLACEHOLDER','Search title or drafter'),('PH_APPROVAL_SEARCH','zh','PLACEHOLDER','搜索标题或起草人'),('PH_APPROVAL_SEARCH','ja','PLACEHOLDER','タイトル・起案者検索'),
('PH_BOARD_SELECT','ko','PLACEHOLDER','게시판 선택'),('PH_BOARD_SELECT','en','PLACEHOLDER','Select board'),('PH_BOARD_SELECT','zh','PLACEHOLDER','选择公告板'),('PH_BOARD_SELECT','ja','PLACEHOLDER','掲示板選択'),
('PH_BOARD_SEARCH','ko','PLACEHOLDER','검색어'),('PH_BOARD_SEARCH','en','PLACEHOLDER','Keyword'),('PH_BOARD_SEARCH','zh','PLACEHOLDER','关键词'),('PH_BOARD_SEARCH','ja','PLACEHOLDER','検索語'),
('PH_USER_SEARCH','ko','PLACEHOLDER','이름/사번/이메일 검색'),('PH_USER_SEARCH','en','PLACEHOLDER','Search name/no/email'),('PH_USER_SEARCH','zh','PLACEHOLDER','搜索姓名/工号/邮箱'),('PH_USER_SEARCH','ja','PLACEHOLDER','氏名/番号/メール検索'),
('PH_STATUS_SELECT','ko','PLACEHOLDER','상태'),('PH_STATUS_SELECT','en','PLACEHOLDER','Status'),('PH_STATUS_SELECT','zh','PLACEHOLDER','状态'),('PH_STATUS_SELECT','ja','PLACEHOLDER','状態'),
('PH_AUDIT_ACTOR','ko','PLACEHOLDER','작업자 사번'),('PH_AUDIT_ACTOR','en','PLACEHOLDER','Actor employee no.'),('PH_AUDIT_ACTOR','zh','PLACEHOLDER','操作者工号'),('PH_AUDIT_ACTOR','ja','PLACEHOLDER','操作者番号'),
('PH_AUDIT_ACTION','ko','PLACEHOLDER','액션 (예: admin/userSave)'),('PH_AUDIT_ACTION','en','PLACEHOLDER','Action (e.g. admin/userSave)'),('PH_AUDIT_ACTION','zh','PLACEHOLDER','操作 (例: admin/userSave)'),('PH_AUDIT_ACTION','ja','PLACEHOLDER','アクション (例: admin/userSave)'),
('PH_DATE_RANGE','ko','PLACEHOLDER','기간'),('PH_DATE_RANGE','en','PLACEHOLDER','Date range'),('PH_DATE_RANGE','zh','PLACEHOLDER','期间'),('PH_DATE_RANGE','ja','PLACEHOLDER','期間'),
('PH_GROUP_SEARCH','ko','PLACEHOLDER','그룹 검색'),('PH_GROUP_SEARCH','en','PLACEHOLDER','Search groups'),('PH_GROUP_SEARCH','zh','PLACEHOLDER','搜索组'),('PH_GROUP_SEARCH','ja','PLACEHOLDER','グループ検索'),
('PH_DEPT_SELECT','ko','PLACEHOLDER','부서 선택'),('PH_DEPT_SELECT','en','PLACEHOLDER','Select department'),('PH_DEPT_SELECT','zh','PLACEHOLDER','选择部门'),('PH_DEPT_SELECT','ja','PLACEHOLDER','部署選択'),
('PH_POSITION_SELECT','ko','PLACEHOLDER','직책 선택'),('PH_POSITION_SELECT','en','PLACEHOLDER','Select position'),('PH_POSITION_SELECT','zh','PLACEHOLDER','选择职位'),('PH_POSITION_SELECT','ja','PLACEHOLDER','役職選択'),
('PH_ROLES_SELECT','ko','PLACEHOLDER','역할 선택'),('PH_ROLES_SELECT','en','PLACEHOLDER','Select roles'),('PH_ROLES_SELECT','zh','PLACEHOLDER','选择角色'),('PH_ROLES_SELECT','ja','PLACEHOLDER','役割選択'),
('PH_FORM_SELECT','ko','PLACEHOLDER','양식을 선택하세요'),('PH_FORM_SELECT','en','PLACEHOLDER','Select form'),('PH_FORM_SELECT','zh','PLACEHOLDER','选择表单'),('PH_FORM_SELECT','ja','PLACEHOLDER','様式を選択'),
('PH_DOC_TITLE','ko','PLACEHOLDER','문서 제목'),('PH_DOC_TITLE','en','PLACEHOLDER','Document title'),('PH_DOC_TITLE','zh','PLACEHOLDER','文档标题'),('PH_DOC_TITLE','ja','PLACEHOLDER','文書タイトル'),
('PH_LEAVE_TYPE_SELECT','ko','PLACEHOLDER','유형을 선택하세요'),('PH_LEAVE_TYPE_SELECT','en','PLACEHOLDER','Select leave type'),('PH_LEAVE_TYPE_SELECT','zh','PLACEHOLDER','选择休假类型'),('PH_LEAVE_TYPE_SELECT','ja','PLACEHOLDER','休暇タイプを選択'),
('PH_LEAVE_REASON','ko','PLACEHOLDER','휴가 사유'),('PH_LEAVE_REASON','en','PLACEHOLDER','Leave reason'),('PH_LEAVE_REASON','zh','PLACEHOLDER','休假理由'),('PH_LEAVE_REASON','ja','PLACEHOLDER','休暇理由'),
('PH_APPROVAL_CONTENT','ko','PLACEHOLDER','결재 본문을 입력하세요'),('PH_APPROVAL_CONTENT','en','PLACEHOLDER','Enter approval content'),('PH_APPROVAL_CONTENT','zh','PLACEHOLDER','输入审批正文'),('PH_APPROVAL_CONTENT','ja','PLACEHOLDER','決裁本文を入力'),
('PH_COMMENT','ko','PLACEHOLDER','의견을 입력하세요'),('PH_COMMENT','en','PLACEHOLDER','Enter comment'),('PH_COMMENT','zh','PLACEHOLDER','输入意见'),('PH_COMMENT','ja','PLACEHOLDER','意見を入力'),
('PH_DELEGATEE_NO','ko','PLACEHOLDER','예: E0010'),('PH_DELEGATEE_NO','en','PLACEHOLDER','e.g. E0010'),('PH_DELEGATEE_NO','zh','PLACEHOLDER','例: E0010'),('PH_DELEGATEE_NO','ja','PLACEHOLDER','例: E0010'),
('PH_DELEGATE_REASON','ko','PLACEHOLDER','휴가 / 출장 등'),('PH_DELEGATE_REASON','en','PLACEHOLDER','Leave / Business trip etc.'),('PH_DELEGATE_REASON','zh','PLACEHOLDER','休假 / 出差 等'),('PH_DELEGATE_REASON','ja','PLACEHOLDER','休暇 / 出張 など'),
('PH_POST_TITLE','ko','PLACEHOLDER','제목을 입력하세요'),('PH_POST_TITLE','en','PLACEHOLDER','Enter title'),('PH_POST_TITLE','zh','PLACEHOLDER','输入标题'),('PH_POST_TITLE','ja','PLACEHOLDER','タイトルを入力'),
('PH_POST_CONTENT','ko','PLACEHOLDER','내용을 입력하세요'),('PH_POST_CONTENT','en','PLACEHOLDER','Enter content'),('PH_POST_CONTENT','zh','PLACEHOLDER','输入内容'),('PH_POST_CONTENT','ja','PLACEHOLDER','内容を入力'),
('PH_TREE_ROOT_NONE','ko','PLACEHOLDER','(루트)'),('PH_TREE_ROOT_NONE','en','PLACEHOLDER','(root)'),('PH_TREE_ROOT_NONE','zh','PLACEHOLDER','(根)'),('PH_TREE_ROOT_NONE','ja','PLACEHOLDER','(ルート)'),
('PH_MENU_PATH','ko','PLACEHOLDER','/example'),('PH_MENU_PATH','en','PLACEHOLDER','/example'),('PH_MENU_PATH','zh','PLACEHOLDER','/example'),('PH_MENU_PATH','ja','PLACEHOLDER','/example'),
('PH_MENU_ICON','ko','PLACEHOLDER','pi pi-folder'),('PH_MENU_ICON','en','PLACEHOLDER','pi pi-folder'),('PH_MENU_ICON','zh','PLACEHOLDER','pi pi-folder'),('PH_MENU_ICON','ja','PLACEHOLDER','pi pi-folder'),
('PH_ORG_SEARCH','ko','PLACEHOLDER','이름/직책 검색'),('PH_ORG_SEARCH','en','PLACEHOLDER','Search name or position'),('PH_ORG_SEARCH','zh','PLACEHOLDER','搜索姓名或职位'),('PH_ORG_SEARCH','ja','PLACEHOLDER','氏名/役職検索')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 5. BUTTON — 페이지/다이얼로그 액션 버튼
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('BTN_NEW_DOC','ko','BUTTON','새 문서 상신'),('BTN_NEW_DOC','en','BUTTON','New Submission'),('BTN_NEW_DOC','zh','BUTTON','新建提交'),('BTN_NEW_DOC','ja','BUTTON','新規起案'),
('BTN_NEW_POST','ko','BUTTON','글쓰기'),('BTN_NEW_POST','en','BUTTON','New Post'),('BTN_NEW_POST','zh','BUTTON','发帖'),('BTN_NEW_POST','ja','BUTTON','投稿'),
('BTN_NEW_EVENT','ko','BUTTON','일정 추가'),('BTN_NEW_EVENT','en','BUTTON','New Event'),('BTN_NEW_EVENT','zh','BUTTON','新建日程'),('BTN_NEW_EVENT','ja','BUTTON','予定追加'),
('BTN_APPLY_LEAVE','ko','BUTTON','휴가 신청'),('BTN_APPLY_LEAVE','en','BUTTON','Apply Leave'),('BTN_APPLY_LEAVE','zh','BUTTON','申请休假'),('BTN_APPLY_LEAVE','ja','BUTTON','休暇申請'),
('BTN_CHECK_IN','ko','BUTTON','출근'),('BTN_CHECK_IN','en','BUTTON','Check In'),('BTN_CHECK_IN','zh','BUTTON','签到'),('BTN_CHECK_IN','ja','BUTTON','出勤'),
('BTN_CHECK_OUT','ko','BUTTON','퇴근'),('BTN_CHECK_OUT','en','BUTTON','Check Out'),('BTN_CHECK_OUT','zh','BUTTON','签退'),('BTN_CHECK_OUT','ja','BUTTON','退勤'),
('BTN_DONE','ko','BUTTON','완료'),('BTN_DONE','en','BUTTON','Done'),('BTN_DONE','zh','BUTTON','完成'),('BTN_DONE','ja','BUTTON','完了'),
('BTN_RESET','ko','BUTTON','초기화'),('BTN_RESET','en','BUTTON','Reset'),('BTN_RESET','zh','BUTTON','重置'),('BTN_RESET','ja','BUTTON','リセット'),
('BTN_ADD_GROUP','ko','BUTTON','그룹 추가'),('BTN_ADD_GROUP','en','BUTTON','Add Group'),('BTN_ADD_GROUP','zh','BUTTON','添加组'),('BTN_ADD_GROUP','ja','BUTTON','グループ追加'),
('BTN_ADD_ROW','ko','BUTTON','행 추가'),('BTN_ADD_ROW','en','BUTTON','Add Row'),('BTN_ADD_ROW','zh','BUTTON','添加行'),('BTN_ADD_ROW','ja','BUTTON','行追加'),
('BTN_ADD_ROOT','ko','BUTTON','루트 추가'),('BTN_ADD_ROOT','en','BUTTON','Add Root'),('BTN_ADD_ROOT','zh','BUTTON','添加根'),('BTN_ADD_ROOT','ja','BUTTON','ルート追加'),
('BTN_NEW_MENU','ko','BUTTON','새 메뉴'),('BTN_NEW_MENU','en','BUTTON','New Menu'),('BTN_NEW_MENU','zh','BUTTON','新建菜单'),('BTN_NEW_MENU','ja','BUTTON','新規メニュー'),
('BTN_SAVE_PERM','ko','BUTTON','권한 저장'),('BTN_SAVE_PERM','en','BUTTON','Save Permissions'),('BTN_SAVE_PERM','zh','BUTTON','保存权限'),('BTN_SAVE_PERM','ja','BUTTON','権限保存'),
('BTN_APPROVE','ko','BUTTON','승인'),('BTN_APPROVE','en','BUTTON','Approve'),('BTN_APPROVE','zh','BUTTON','批准'),('BTN_APPROVE','ja','BUTTON','承認'),
('BTN_REJECT','ko','BUTTON','반려'),('BTN_REJECT','en','BUTTON','Reject'),('BTN_REJECT','zh','BUTTON','退回'),('BTN_REJECT','ja','BUTTON','却下'),
('BTN_WITHDRAW','ko','BUTTON','회수'),('BTN_WITHDRAW','en','BUTTON','Withdraw'),('BTN_WITHDRAW','zh','BUTTON','撤回'),('BTN_WITHDRAW','ja','BUTTON','取下げ'),
('BTN_RESUBMIT','ko','BUTTON','재상신'),('BTN_RESUBMIT','en','BUTTON','Resubmit'),('BTN_RESUBMIT','zh','BUTTON','重新提交'),('BTN_RESUBMIT','ja','BUTTON','再起案'),
('BTN_DELEGATE','ko','BUTTON','대결 등록'),('BTN_DELEGATE','en','BUTTON','Register Delegate'),('BTN_DELEGATE','zh','BUTTON','登记代审'),('BTN_DELEGATE','ja','BUTTON','代決登録'),
('BTN_SUBMIT_DOC','ko','BUTTON','상신'),('BTN_SUBMIT_DOC','en','BUTTON','Submit'),('BTN_SUBMIT_DOC','zh','BUTTON','提交'),('BTN_SUBMIT_DOC','ja','BUTTON','起案'),
('BTN_REGISTER','ko','BUTTON','등록'),('BTN_REGISTER','en','BUTTON','Register'),('BTN_REGISTER','zh','BUTTON','注册'),('BTN_REGISTER','ja','BUTTON','登録'),
('BTN_UPDATE','ko','BUTTON','수정'),('BTN_UPDATE','en','BUTTON','Update'),('BTN_UPDATE','zh','BUTTON','修改'),('BTN_UPDATE','ja','BUTTON','修正'),
('BTN_RESET_PWD','ko','BUTTON','비밀번호 초기화'),('BTN_RESET_PWD','en','BUTTON','Reset Password'),('BTN_RESET_PWD','zh','BUTTON','重置密码'),('BTN_RESET_PWD','ja','BUTTON','パスワード初期化'),
('BTN_TOGGLE_ACTIVE','ko','BUTTON','활성 상태 변경'),('BTN_TOGGLE_ACTIVE','en','BUTTON','Toggle Active'),('BTN_TOGGLE_ACTIVE','zh','BUTTON','切换状态'),('BTN_TOGGLE_ACTIVE','ja','BUTTON','状態切替')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 6. STATUS — Approval / Approval Line / Attendance / Leave
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
-- Approval document
('STATUS_APP_DOC_DRAFT','ko','STATUS','임시'),('STATUS_APP_DOC_DRAFT','en','STATUS','Draft'),('STATUS_APP_DOC_DRAFT','zh','STATUS','草稿'),('STATUS_APP_DOC_DRAFT','ja','STATUS','一時保存'),
('STATUS_APP_DOC_PENDING','ko','STATUS','대기'),('STATUS_APP_DOC_PENDING','en','STATUS','Pending'),('STATUS_APP_DOC_PENDING','zh','STATUS','待审批'),('STATUS_APP_DOC_PENDING','ja','STATUS','保留'),
('STATUS_APP_DOC_IN_PROGRESS','ko','STATUS','진행'),('STATUS_APP_DOC_IN_PROGRESS','en','STATUS','In Progress'),('STATUS_APP_DOC_IN_PROGRESS','zh','STATUS','审批中'),('STATUS_APP_DOC_IN_PROGRESS','ja','STATUS','進行中'),
('STATUS_APP_DOC_APPROVED','ko','STATUS','완료'),('STATUS_APP_DOC_APPROVED','en','STATUS','Approved'),('STATUS_APP_DOC_APPROVED','zh','STATUS','已批准'),('STATUS_APP_DOC_APPROVED','ja','STATUS','完了'),
('STATUS_APP_DOC_REJECTED','ko','STATUS','반려'),('STATUS_APP_DOC_REJECTED','en','STATUS','Rejected'),('STATUS_APP_DOC_REJECTED','zh','STATUS','已退回'),('STATUS_APP_DOC_REJECTED','ja','STATUS','却下'),
-- Approval line
('STATUS_APP_LINE_PENDING','ko','STATUS','대기'),('STATUS_APP_LINE_PENDING','en','STATUS','Pending'),('STATUS_APP_LINE_PENDING','zh','STATUS','待审批'),('STATUS_APP_LINE_PENDING','ja','STATUS','保留'),
('STATUS_APP_LINE_APPROVED','ko','STATUS','승인'),('STATUS_APP_LINE_APPROVED','en','STATUS','Approved'),('STATUS_APP_LINE_APPROVED','zh','STATUS','批准'),('STATUS_APP_LINE_APPROVED','ja','STATUS','承認'),
('STATUS_APP_LINE_REJECTED','ko','STATUS','반려'),('STATUS_APP_LINE_REJECTED','en','STATUS','Rejected'),('STATUS_APP_LINE_REJECTED','zh','STATUS','退回'),('STATUS_APP_LINE_REJECTED','ja','STATUS','却下'),
('STATUS_APP_LINE_SKIPPED','ko','STATUS','전결'),('STATUS_APP_LINE_SKIPPED','en','STATUS','Final Approval'),('STATUS_APP_LINE_SKIPPED','zh','STATUS','终审'),('STATUS_APP_LINE_SKIPPED','ja','STATUS','専決'),
-- Attendance
('STATUS_ATT_NORMAL','ko','STATUS','정상'),('STATUS_ATT_NORMAL','en','STATUS','Normal'),('STATUS_ATT_NORMAL','zh','STATUS','正常'),('STATUS_ATT_NORMAL','ja','STATUS','正常'),
('STATUS_ATT_LATE','ko','STATUS','지각'),('STATUS_ATT_LATE','en','STATUS','Late'),('STATUS_ATT_LATE','zh','STATUS','迟到'),('STATUS_ATT_LATE','ja','STATUS','遅刻'),
('STATUS_ATT_EARLY','ko','STATUS','조퇴'),('STATUS_ATT_EARLY','en','STATUS','Early Leave'),('STATUS_ATT_EARLY','zh','STATUS','早退'),('STATUS_ATT_EARLY','ja','STATUS','早退'),
('STATUS_ATT_ABSENT','ko','STATUS','결근'),('STATUS_ATT_ABSENT','en','STATUS','Absent'),('STATUS_ATT_ABSENT','zh','STATUS','缺勤'),('STATUS_ATT_ABSENT','ja','STATUS','欠勤'),
('STATUS_ATT_HOLIDAY','ko','STATUS','공휴일'),('STATUS_ATT_HOLIDAY','en','STATUS','Holiday'),('STATUS_ATT_HOLIDAY','zh','STATUS','公休'),('STATUS_ATT_HOLIDAY','ja','STATUS','祝日'),
('STATUS_ATT_LEAVE','ko','STATUS','휴가'),('STATUS_ATT_LEAVE','en','STATUS','Leave'),('STATUS_ATT_LEAVE','zh','STATUS','休假'),('STATUS_ATT_LEAVE','ja','STATUS','休暇'),
('STATUS_ATT_NOT_CHECKED','ko','STATUS','미출근'),('STATUS_ATT_NOT_CHECKED','en','STATUS','Not Checked'),('STATUS_ATT_NOT_CHECKED','zh','STATUS','未签到'),('STATUS_ATT_NOT_CHECKED','ja','STATUS','未出勤'),
-- Leave request
('STATUS_LEAVE_PENDING','ko','STATUS','결재중'),('STATUS_LEAVE_PENDING','en','STATUS','In Approval'),('STATUS_LEAVE_PENDING','zh','STATUS','审批中'),('STATUS_LEAVE_PENDING','ja','STATUS','決裁中'),
('STATUS_LEAVE_APPROVED','ko','STATUS','승인'),('STATUS_LEAVE_APPROVED','en','STATUS','Approved'),('STATUS_LEAVE_APPROVED','zh','STATUS','批准'),('STATUS_LEAVE_APPROVED','ja','STATUS','承認'),
('STATUS_LEAVE_REJECTED','ko','STATUS','반려'),('STATUS_LEAVE_REJECTED','en','STATUS','Rejected'),('STATUS_LEAVE_REJECTED','zh','STATUS','退回'),('STATUS_LEAVE_REJECTED','ja','STATUS','却下'),
('STATUS_LEAVE_CANCELLED','ko','STATUS','취소'),('STATUS_LEAVE_CANCELLED','en','STATUS','Cancelled'),('STATUS_LEAVE_CANCELLED','zh','STATUS','取消'),('STATUS_LEAVE_CANCELLED','ja','STATUS','取消'),
-- User active
('STATUS_USER_ACTIVE','ko','STATUS','활성'),('STATUS_USER_ACTIVE','en','STATUS','Active'),('STATUS_USER_ACTIVE','zh','STATUS','活跃'),('STATUS_USER_ACTIVE','ja','STATUS','有効'),
('STATUS_USER_INACTIVE','ko','STATUS','비활성'),('STATUS_USER_INACTIVE','en','STATUS','Inactive'),('STATUS_USER_INACTIVE','zh','STATUS','停用'),('STATUS_USER_INACTIVE','ja','STATUS','無効'),
-- Use Y/N
('STATUS_USE_Y','ko','STATUS','사용'),('STATUS_USE_Y','en','STATUS','Use'),('STATUS_USE_Y','zh','STATUS','使用'),('STATUS_USE_Y','ja','STATUS','使用'),
('STATUS_USE_N','ko','STATUS','미사용'),('STATUS_USE_N','en','STATUS','Unused'),('STATUS_USE_N','zh','STATUS','停用'),('STATUS_USE_N','ja','STATUS','未使用')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 7. FORM — 결재 양식 코드명
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('FORM_LEAVE','ko','FORM','휴가'),('FORM_LEAVE','en','FORM','Leave'),('FORM_LEAVE','zh','FORM','休假'),('FORM_LEAVE','ja','FORM','休暇'),
('FORM_EXPENSE','ko','FORM','지출'),('FORM_EXPENSE','en','FORM','Expense'),('FORM_EXPENSE','zh','FORM','支出'),('FORM_EXPENSE','ja','FORM','支出'),
('FORM_PURCHASE','ko','FORM','구매'),('FORM_PURCHASE','en','FORM','Purchase'),('FORM_PURCHASE','zh','FORM','采购'),('FORM_PURCHASE','ja','FORM','購買'),
('FORM_BIZTRIP','ko','FORM','출장'),('FORM_BIZTRIP','en','FORM','Business Trip'),('FORM_BIZTRIP','zh','FORM','出差'),('FORM_BIZTRIP','ja','FORM','出張'),
('FORM_CONTRACT','ko','FORM','계약'),('FORM_CONTRACT','en','FORM','Contract'),('FORM_CONTRACT','zh','FORM','合同'),('FORM_CONTRACT','ja','FORM','契約'),
('FORM_HR','ko','FORM','인사'),('FORM_HR','en','FORM','HR'),('FORM_HR','zh','FORM','人事'),('FORM_HR','ja','FORM','人事'),
('FORM_IT','ko','FORM','IT'),('FORM_IT','en','FORM','IT'),('FORM_IT','zh','FORM','IT'),('FORM_IT','ja','FORM','IT'),
-- Full form labels (for dropdowns)
('FORM_LEAVE_FULL','ko','FORM','휴가신청서'),('FORM_LEAVE_FULL','en','FORM','Leave Request'),('FORM_LEAVE_FULL','zh','FORM','休假申请'),('FORM_LEAVE_FULL','ja','FORM','休暇申請書'),
('FORM_EXPENSE_FULL','ko','FORM','지출결의서'),('FORM_EXPENSE_FULL','en','FORM','Expense Request'),('FORM_EXPENSE_FULL','zh','FORM','支出申请'),('FORM_EXPENSE_FULL','ja','FORM','支出決議書'),
('FORM_PURCHASE_FULL','ko','FORM','구매요청서'),('FORM_PURCHASE_FULL','en','FORM','Purchase Request'),('FORM_PURCHASE_FULL','zh','FORM','采购申请'),('FORM_PURCHASE_FULL','ja','FORM','購買申請書'),
('FORM_BIZTRIP_FULL','ko','FORM','출장신청서'),('FORM_BIZTRIP_FULL','en','FORM','Business Trip Request'),('FORM_BIZTRIP_FULL','zh','FORM','出差申请'),('FORM_BIZTRIP_FULL','ja','FORM','出張申請書')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 8. BOX — Approval inbox 9-box
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('BOX_DRAFT','ko','BOX','임시저장'),('BOX_DRAFT','en','BOX','Drafts'),('BOX_DRAFT','zh','BOX','草稿'),('BOX_DRAFT','ja','BOX','一時保存'),
('BOX_MY_DOCS','ko','BOX','기안함'),('BOX_MY_DOCS','en','BOX','My Documents'),('BOX_MY_DOCS','zh','BOX','我的草稿'),('BOX_MY_DOCS','ja','BOX','起案箱'),
('BOX_PENDING','ko','BOX','대기함'),('BOX_PENDING','en','BOX','Pending'),('BOX_PENDING','zh','BOX','待办箱'),('BOX_PENDING','ja','BOX','保留箱'),
('BOX_IN_PROGRESS','ko','BOX','진행함'),('BOX_IN_PROGRESS','en','BOX','In Progress'),('BOX_IN_PROGRESS','zh','BOX','进行中'),('BOX_IN_PROGRESS','ja','BOX','進行箱'),
('BOX_COMPLETED','ko','BOX','완료함'),('BOX_COMPLETED','en','BOX','Completed'),('BOX_COMPLETED','zh','BOX','已完成'),('BOX_COMPLETED','ja','BOX','完了箱'),
('BOX_REJECTED','ko','BOX','반려함'),('BOX_REJECTED','en','BOX','Rejected'),('BOX_REJECTED','zh','BOX','退回箱'),('BOX_REJECTED','ja','BOX','却下箱'),
('BOX_RECEIVED','ko','BOX','수신함'),('BOX_RECEIVED','en','BOX','Received'),('BOX_RECEIVED','zh','BOX','收件箱'),('BOX_RECEIVED','ja','BOX','受信箱'),
('BOX_CC_BOX','ko','BOX','참조함'),('BOX_CC_BOX','en','BOX','CC'),('BOX_CC_BOX','zh','BOX','抄送'),('BOX_CC_BOX','ja','BOX','参照箱'),
('BOX_DEPT_BOX','ko','BOX','부서함'),('BOX_DEPT_BOX','en','BOX','Department Box'),('BOX_DEPT_BOX','zh','BOX','部门箱'),('BOX_DEPT_BOX','ja','BOX','部署箱')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 9. LEAVE_TYPE
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('LEAVE_TYPE_ANNUAL','ko','LEAVE_TYPE','연차'),('LEAVE_TYPE_ANNUAL','en','LEAVE_TYPE','Annual'),('LEAVE_TYPE_ANNUAL','zh','LEAVE_TYPE','年假'),('LEAVE_TYPE_ANNUAL','ja','LEAVE_TYPE','年次'),
('LEAVE_TYPE_HALF_AM','ko','LEAVE_TYPE','오전반차'),('LEAVE_TYPE_HALF_AM','en','LEAVE_TYPE','Half Day (AM)'),('LEAVE_TYPE_HALF_AM','zh','LEAVE_TYPE','上午半天'),('LEAVE_TYPE_HALF_AM','ja','LEAVE_TYPE','午前半休'),
('LEAVE_TYPE_HALF_PM','ko','LEAVE_TYPE','오후반차'),('LEAVE_TYPE_HALF_PM','en','LEAVE_TYPE','Half Day (PM)'),('LEAVE_TYPE_HALF_PM','zh','LEAVE_TYPE','下午半天'),('LEAVE_TYPE_HALF_PM','ja','LEAVE_TYPE','午後半休'),
('LEAVE_TYPE_SICK','ko','LEAVE_TYPE','병가'),('LEAVE_TYPE_SICK','en','LEAVE_TYPE','Sick Leave'),('LEAVE_TYPE_SICK','zh','LEAVE_TYPE','病假'),('LEAVE_TYPE_SICK','ja','LEAVE_TYPE','病気休暇'),
('LEAVE_TYPE_FAMILY','ko','LEAVE_TYPE','경조사'),('LEAVE_TYPE_FAMILY','en','LEAVE_TYPE','Family Event'),('LEAVE_TYPE_FAMILY','zh','LEAVE_TYPE','婚丧假'),('LEAVE_TYPE_FAMILY','ja','LEAVE_TYPE','慶弔休暇'),
('LEAVE_TYPE_UNPAID','ko','LEAVE_TYPE','무급휴가'),('LEAVE_TYPE_UNPAID','en','LEAVE_TYPE','Unpaid Leave'),('LEAVE_TYPE_UNPAID','zh','LEAVE_TYPE','无薪假'),('LEAVE_TYPE_UNPAID','ja','LEAVE_TYPE','無給休暇')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 10. LABEL — 다이얼로그/카드/폼 라벨 (보강)
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
-- Approval inbox panel
('LBL_APPROVAL_BOXES','ko','LABEL','결재함'),('LBL_APPROVAL_BOXES','en','LABEL','Approval Boxes'),('LBL_APPROVAL_BOXES','zh','LABEL','审批箱'),('LBL_APPROVAL_BOXES','ja','LABEL','決裁箱'),
('LBL_APPROVAL_INBOX_EMPTY','ko','LABEL','결재함이 비어 있습니다'),('LBL_APPROVAL_INBOX_EMPTY','en','LABEL','Inbox is empty'),('LBL_APPROVAL_INBOX_EMPTY','zh','LABEL','审批箱为空'),('LBL_APPROVAL_INBOX_EMPTY','ja','LABEL','決裁箱が空です'),
-- Approval submit dialog
('LBL_APPROVAL_SUBMIT_HEADER','ko','LABEL','결재 상신'),('LBL_APPROVAL_SUBMIT_HEADER','en','LABEL','Submit Approval'),('LBL_APPROVAL_SUBMIT_HEADER','zh','LABEL','提交审批'),('LBL_APPROVAL_SUBMIT_HEADER','ja','LABEL','決裁起案'),
('LBL_APPROVAL_FORM_REQ','ko','LABEL','양식 *'),('LBL_APPROVAL_FORM_REQ','en','LABEL','Form *'),('LBL_APPROVAL_FORM_REQ','zh','LABEL','表单 *'),('LBL_APPROVAL_FORM_REQ','ja','LABEL','様式 *'),
('LBL_APPROVAL_TITLE_REQ','ko','LABEL','제목 *'),('LBL_APPROVAL_TITLE_REQ','en','LABEL','Title *'),('LBL_APPROVAL_TITLE_REQ','zh','LABEL','标题 *'),('LBL_APPROVAL_TITLE_REQ','ja','LABEL','タイトル *'),
('LBL_APPROVAL_LEAVE_TYPE_REQ','ko','LABEL','휴가 유형 *'),('LBL_APPROVAL_LEAVE_TYPE_REQ','en','LABEL','Leave Type *'),('LBL_APPROVAL_LEAVE_TYPE_REQ','zh','LABEL','休假类型 *'),('LBL_APPROVAL_LEAVE_TYPE_REQ','ja','LABEL','休暇種別 *'),
('LBL_APPROVAL_FROM_DATE_REQ','ko','LABEL','시작일 *'),('LBL_APPROVAL_FROM_DATE_REQ','en','LABEL','From Date *'),('LBL_APPROVAL_FROM_DATE_REQ','zh','LABEL','开始日 *'),('LBL_APPROVAL_FROM_DATE_REQ','ja','LABEL','開始日 *'),
('LBL_APPROVAL_TO_DATE_REQ','ko','LABEL','종료일 *'),('LBL_APPROVAL_TO_DATE_REQ','en','LABEL','To Date *'),('LBL_APPROVAL_TO_DATE_REQ','zh','LABEL','结束日 *'),('LBL_APPROVAL_TO_DATE_REQ','ja','LABEL','終了日 *'),
('LBL_APPROVAL_DAYS','ko','LABEL','일수'),('LBL_APPROVAL_DAYS','en','LABEL','Days'),('LBL_APPROVAL_DAYS','zh','LABEL','天数'),('LBL_APPROVAL_DAYS','ja','LABEL','日数'),
('LBL_APPROVAL_REASON','ko','LABEL','사유'),('LBL_APPROVAL_REASON','en','LABEL','Reason'),('LBL_APPROVAL_REASON','zh','LABEL','理由'),('LBL_APPROVAL_REASON','ja','LABEL','理由'),
('LBL_APPROVAL_AMOUNT','ko','LABEL','금액'),('LBL_APPROVAL_AMOUNT','en','LABEL','Amount'),('LBL_APPROVAL_AMOUNT','zh','LABEL','金额'),('LBL_APPROVAL_AMOUNT','ja','LABEL','金額'),
('LBL_APPROVAL_CONTENT','ko','LABEL','본문'),('LBL_APPROVAL_CONTENT','en','LABEL','Content'),('LBL_APPROVAL_CONTENT','zh','LABEL','正文'),('LBL_APPROVAL_CONTENT','ja','LABEL','本文'),
('LBL_APPROVAL_LINE_PREVIEW','ko','LABEL','결재선 미리보기'),('LBL_APPROVAL_LINE_PREVIEW','en','LABEL','Approval Line Preview'),('LBL_APPROVAL_LINE_PREVIEW','zh','LABEL','审批线预览'),('LBL_APPROVAL_LINE_PREVIEW','ja','LABEL','決裁ラインプレビュー'),
('LBL_APPROVAL_PREVIEW_LOADING','ko','LABEL','불러오는 중...'),('LBL_APPROVAL_PREVIEW_LOADING','en','LABEL','Loading...'),('LBL_APPROVAL_PREVIEW_LOADING','zh','LABEL','加载中...'),('LBL_APPROVAL_PREVIEW_LOADING','ja','LABEL','読み込み中...'),
('LBL_APPROVAL_PREVIEW_EMPTY','ko','LABEL','양식과 금액을 선택하면 결재선이 자동으로 표시됩니다'),('LBL_APPROVAL_PREVIEW_EMPTY','en','LABEL','Select form and amount to see approval line'),('LBL_APPROVAL_PREVIEW_EMPTY','zh','LABEL','选择表单和金额后审批线会自动显示'),('LBL_APPROVAL_PREVIEW_EMPTY','ja','LABEL','様式と金額を選ぶと決裁ラインが自動表示されます'),
('LBL_APPROVAL_STEP_SUFFIX','ko','LABEL','단계'),('LBL_APPROVAL_STEP_SUFFIX','en','LABEL','Step'),('LBL_APPROVAL_STEP_SUFFIX','zh','LABEL','步骤'),('LBL_APPROVAL_STEP_SUFFIX','ja','LABEL','段階'),
('LBL_APPROVAL_DAYS_HINT','ko','LABEL','반차(0.5)는 자동 적용. 영업일 = 주말/공휴일 제외 (UI 측은 주말만 자동 제외).'),('LBL_APPROVAL_DAYS_HINT','en','LABEL','Half-day (0.5) is auto-applied. Business days exclude weekends/holidays (UI excludes weekends only).'),('LBL_APPROVAL_DAYS_HINT','zh','LABEL','半天(0.5)自动应用。工作日 = 排除周末/公休 (UI 仅排除周末)。'),('LBL_APPROVAL_DAYS_HINT','ja','LABEL','半休(0.5)は自動適用。営業日 = 週末/祝日除く (UIは週末のみ自動除外)。'),
-- Approval action dialogs
('LBL_APPROVAL_COMMENT_APPROVE','ko','LABEL','승인 의견'),('LBL_APPROVAL_COMMENT_APPROVE','en','LABEL','Approval Comment'),('LBL_APPROVAL_COMMENT_APPROVE','zh','LABEL','批准意见'),('LBL_APPROVAL_COMMENT_APPROVE','ja','LABEL','承認コメント'),
('LBL_APPROVAL_COMMENT_REJECT','ko','LABEL','반려 사유'),('LBL_APPROVAL_COMMENT_REJECT','en','LABEL','Rejection Reason'),('LBL_APPROVAL_COMMENT_REJECT','zh','LABEL','退回理由'),('LBL_APPROVAL_COMMENT_REJECT','ja','LABEL','却下理由'),
('LBL_APPROVAL_DELEGATE_HEADER','ko','LABEL','대결(위임) 등록'),('LBL_APPROVAL_DELEGATE_HEADER','en','LABEL','Register Delegate'),('LBL_APPROVAL_DELEGATE_HEADER','zh','LABEL','登记代审(委托)'),('LBL_APPROVAL_DELEGATE_HEADER','ja','LABEL','代決(委任)登録'),
('LBL_APPROVAL_DELEGATEE_NO','ko','LABEL','대리 결재자 사번'),('LBL_APPROVAL_DELEGATEE_NO','en','LABEL','Delegatee Emp. No.'),('LBL_APPROVAL_DELEGATEE_NO','zh','LABEL','代理审批人工号'),('LBL_APPROVAL_DELEGATEE_NO','ja','LABEL','代理決裁者番号'),
('LBL_APPROVAL_FROM_DATE','ko','LABEL','시작일'),('LBL_APPROVAL_FROM_DATE','en','LABEL','From Date'),('LBL_APPROVAL_FROM_DATE','zh','LABEL','开始日'),('LBL_APPROVAL_FROM_DATE','ja','LABEL','開始日'),
('LBL_APPROVAL_TO_DATE','ko','LABEL','종료일'),('LBL_APPROVAL_TO_DATE','en','LABEL','To Date'),('LBL_APPROVAL_TO_DATE','zh','LABEL','结束日'),('LBL_APPROVAL_TO_DATE','ja','LABEL','終了日'),
('LBL_APPROVAL_DELEGATED_BY','ko','LABEL','대결'),('LBL_APPROVAL_DELEGATED_BY','en','LABEL','Delegated by'),('LBL_APPROVAL_DELEGATED_BY','zh','LABEL','代审'),('LBL_APPROVAL_DELEGATED_BY','ja','LABEL','代決'),
-- Board form dialog
('LBL_BOARD_FORM_NEW','ko','LABEL','새 글 작성'),('LBL_BOARD_FORM_NEW','en','LABEL','New Post'),('LBL_BOARD_FORM_NEW','zh','LABEL','新建帖子'),('LBL_BOARD_FORM_NEW','ja','LABEL','新規投稿'),
('LBL_BOARD_FORM_EDIT','ko','LABEL','게시글 수정'),('LBL_BOARD_FORM_EDIT','en','LABEL','Edit Post'),('LBL_BOARD_FORM_EDIT','zh','LABEL','编辑帖子'),('LBL_BOARD_FORM_EDIT','ja','LABEL','投稿編集'),
('LBL_BOARD_BOARD','ko','LABEL','게시판'),('LBL_BOARD_BOARD','en','LABEL','Board'),('LBL_BOARD_BOARD','zh','LABEL','公告板'),('LBL_BOARD_BOARD','ja','LABEL','掲示板'),
('LBL_BOARD_TITLE_REQ','ko','LABEL','제목 *'),('LBL_BOARD_TITLE_REQ','en','LABEL','Title *'),('LBL_BOARD_TITLE_REQ','zh','LABEL','标题 *'),('LBL_BOARD_TITLE_REQ','ja','LABEL','タイトル *'),
('LBL_BOARD_CONTENT','ko','LABEL','내용'),('LBL_BOARD_CONTENT','en','LABEL','Content'),('LBL_BOARD_CONTENT','zh','LABEL','内容'),('LBL_BOARD_CONTENT','ja','LABEL','内容'),
('LBL_BOARD_PIN','ko','LABEL','상단 고정'),('LBL_BOARD_PIN','en','LABEL','Pin to Top'),('LBL_BOARD_PIN','zh','LABEL','置顶'),('LBL_BOARD_PIN','ja','LABEL','固定'),
('LBL_BOARD_ATTACHMENT','ko','LABEL','첨부 파일'),('LBL_BOARD_ATTACHMENT','en','LABEL','Attachments'),('LBL_BOARD_ATTACHMENT','zh','LABEL','附件'),('LBL_BOARD_ATTACHMENT','ja','LABEL','添付ファイル'),
('LBL_BOARD_TYPE_NOTICE','ko','LABEL','공지사항'),('LBL_BOARD_TYPE_NOTICE','en','LABEL','Notice'),('LBL_BOARD_TYPE_NOTICE','zh','LABEL','公告'),('LBL_BOARD_TYPE_NOTICE','ja','LABEL','お知らせ'),
('LBL_BOARD_TYPE_GENERAL','ko','LABEL','일반'),('LBL_BOARD_TYPE_GENERAL','en','LABEL','General'),('LBL_BOARD_TYPE_GENERAL','zh','LABEL','一般'),('LBL_BOARD_TYPE_GENERAL','ja','LABEL','一般'),
('LBL_BOARD_TYPE_FREE','ko','LABEL','자유게시판'),('LBL_BOARD_TYPE_FREE','en','LABEL','Free Board'),('LBL_BOARD_TYPE_FREE','zh','LABEL','自由论坛'),('LBL_BOARD_TYPE_FREE','ja','LABEL','自由掲示板'),
('LBL_BOARD_TYPE_DEPT','ko','LABEL','부서게시판'),('LBL_BOARD_TYPE_DEPT','en','LABEL','Dept Board'),('LBL_BOARD_TYPE_DEPT','zh','LABEL','部门论坛'),('LBL_BOARD_TYPE_DEPT','ja','LABEL','部署掲示板'),
('LBL_BOARD_TYPE_ARCHIVE','ko','LABEL','자료실'),('LBL_BOARD_TYPE_ARCHIVE','en','LABEL','Archive'),('LBL_BOARD_TYPE_ARCHIVE','zh','LABEL','资料室'),('LBL_BOARD_TYPE_ARCHIVE','ja','LABEL','資料室'),
('LBL_BOARD_TYPE_ALL','ko','LABEL','전체'),('LBL_BOARD_TYPE_ALL','en','LABEL','All'),('LBL_BOARD_TYPE_ALL','zh','LABEL','全部'),('LBL_BOARD_TYPE_ALL','ja','LABEL','全体'),
-- Calendar filter scope
('LBL_CAL_SCOPE_ALL','ko','LABEL','전체'),('LBL_CAL_SCOPE_ALL','en','LABEL','All'),('LBL_CAL_SCOPE_ALL','zh','LABEL','全部'),('LBL_CAL_SCOPE_ALL','ja','LABEL','全体'),
('LBL_CAL_SCOPE_PERSONAL','ko','LABEL','개인'),('LBL_CAL_SCOPE_PERSONAL','en','LABEL','Personal'),('LBL_CAL_SCOPE_PERSONAL','zh','LABEL','个人'),('LBL_CAL_SCOPE_PERSONAL','ja','LABEL','個人'),
('LBL_CAL_SCOPE_DEPT','ko','LABEL','부서'),('LBL_CAL_SCOPE_DEPT','en','LABEL','Department'),('LBL_CAL_SCOPE_DEPT','zh','LABEL','部门'),('LBL_CAL_SCOPE_DEPT','ja','LABEL','部署'),
('LBL_CAL_SCOPE_COMPANY','ko','LABEL','회사'),('LBL_CAL_SCOPE_COMPANY','en','LABEL','Company'),('LBL_CAL_SCOPE_COMPANY','zh','LABEL','公司'),('LBL_CAL_SCOPE_COMPANY','ja','LABEL','会社'),
-- Attendance card titles
('LBL_ATT_THIS_MONTH','ko','LABEL','이번 달 출근 현황'),('LBL_ATT_THIS_MONTH','en','LABEL','This Month Attendance'),('LBL_ATT_THIS_MONTH','zh','LABEL','本月考勤'),('LBL_ATT_THIS_MONTH','ja','LABEL','今月の勤怠'),
('LBL_ATT_CHECK_IN_AT','ko','LABEL','출근'),('LBL_ATT_CHECK_IN_AT','en','LABEL','Check-in'),('LBL_ATT_CHECK_IN_AT','zh','LABEL','签到'),('LBL_ATT_CHECK_IN_AT','ja','LABEL','出勤'),
('LBL_ATT_CHECK_OUT_AT','ko','LABEL','퇴근'),('LBL_ATT_CHECK_OUT_AT','en','LABEL','Check-out'),('LBL_ATT_CHECK_OUT_AT','zh','LABEL','签退'),('LBL_ATT_CHECK_OUT_AT','ja','LABEL','退勤'),
('LBL_ATT_WORK_TIME','ko','LABEL','근무'),('LBL_ATT_WORK_TIME','en','LABEL','Work'),('LBL_ATT_WORK_TIME','zh','LABEL','工作'),('LBL_ATT_WORK_TIME','ja','LABEL','勤務'),
('LBL_ATT_WORK_DAYS','ko','LABEL','출근일'),('LBL_ATT_WORK_DAYS','en','LABEL','Work Days'),('LBL_ATT_WORK_DAYS','zh','LABEL','出勤日'),('LBL_ATT_WORK_DAYS','ja','LABEL','出勤日'),
('LBL_ATT_TOTAL_TIME','ko','LABEL','총 근무시간'),('LBL_ATT_TOTAL_TIME','en','LABEL','Total Work Time'),('LBL_ATT_TOTAL_TIME','zh','LABEL','总工时'),('LBL_ATT_TOTAL_TIME','ja','LABEL','総労働時間'),
('LBL_ATT_AVG_TIME','ko','LABEL','평균 근무'),('LBL_ATT_AVG_TIME','en','LABEL','Avg Work'),('LBL_ATT_AVG_TIME','zh','LABEL','平均工时'),('LBL_ATT_AVG_TIME','ja','LABEL','平均勤務'),
('LBL_ATT_LATE_DAYS','ko','LABEL','지각'),('LBL_ATT_LATE_DAYS','en','LABEL','Late'),('LBL_ATT_LATE_DAYS','zh','LABEL','迟到'),('LBL_ATT_LATE_DAYS','ja','LABEL','遅刻'),
('LBL_ATT_LEAVE_DAYS','ko','LABEL','휴가'),('LBL_ATT_LEAVE_DAYS','en','LABEL','Leave'),('LBL_ATT_LEAVE_DAYS','zh','LABEL','休假'),('LBL_ATT_LEAVE_DAYS','ja','LABEL','休暇'),
('LBL_ATT_DAY_SUFFIX','ko','LABEL','일'),('LBL_ATT_DAY_SUFFIX','en','LABEL','d'),('LBL_ATT_DAY_SUFFIX','zh','LABEL','天'),('LBL_ATT_DAY_SUFFIX','ja','LABEL','日'),
-- Leave card
('LBL_LEAVE_HISTORY','ko','LABEL','휴가 신청 이력'),('LBL_LEAVE_HISTORY','en','LABEL','Leave Request History'),('LBL_LEAVE_HISTORY','zh','LABEL','休假申请记录'),('LBL_LEAVE_HISTORY','ja','LABEL','休暇申請履歴'),
('LBL_LEAVE_YEAR_SELECT','ko','LABEL','조회 연도'),('LBL_LEAVE_YEAR_SELECT','en','LABEL','Year'),('LBL_LEAVE_YEAR_SELECT','zh','LABEL','年度'),('LBL_LEAVE_YEAR_SELECT','ja','LABEL','照会年度'),
('LBL_LEAVE_EMPTY','ko','LABEL','등록된 휴가 신청이 없습니다'),('LBL_LEAVE_EMPTY','en','LABEL','No leave requests'),('LBL_LEAVE_EMPTY','zh','LABEL','无休假申请记录'),('LBL_LEAVE_EMPTY','ja','LABEL','登録された休暇申請がありません'),
-- Admin User dialog
('LBL_USER_FORM_NEW','ko','LABEL','사용자 추가'),('LBL_USER_FORM_NEW','en','LABEL','Add User'),('LBL_USER_FORM_NEW','zh','LABEL','添加用户'),('LBL_USER_FORM_NEW','ja','LABEL','ユーザー追加'),
('LBL_USER_FORM_EDIT','ko','LABEL','사용자 수정'),('LBL_USER_FORM_EDIT','en','LABEL','Edit User'),('LBL_USER_FORM_EDIT','zh','LABEL','编辑用户'),('LBL_USER_FORM_EDIT','ja','LABEL','ユーザー編集'),
('LBL_USER_NAME_REQ','ko','LABEL','이름 *'),('LBL_USER_NAME_REQ','en','LABEL','Name *'),('LBL_USER_NAME_REQ','zh','LABEL','姓名 *'),('LBL_USER_NAME_REQ','ja','LABEL','氏名 *'),
('LBL_USER_NO_REQ','ko','LABEL','사번 *'),('LBL_USER_NO_REQ','en','LABEL','Emp. No. *'),('LBL_USER_NO_REQ','zh','LABEL','工号 *'),('LBL_USER_NO_REQ','ja','LABEL','社員番号 *'),
('LBL_USER_EMAIL','ko','LABEL','이메일'),('LBL_USER_EMAIL','en','LABEL','Email'),('LBL_USER_EMAIL','zh','LABEL','邮箱'),('LBL_USER_EMAIL','ja','LABEL','メール'),
('LBL_USER_PHONE','ko','LABEL','전화'),('LBL_USER_PHONE','en','LABEL','Phone'),('LBL_USER_PHONE','zh','LABEL','电话'),('LBL_USER_PHONE','ja','LABEL','電話'),
('LBL_USER_DEPT_REQ','ko','LABEL','부서 *'),('LBL_USER_DEPT_REQ','en','LABEL','Department *'),('LBL_USER_DEPT_REQ','zh','LABEL','部门 *'),('LBL_USER_DEPT_REQ','ja','LABEL','部署 *'),
('LBL_USER_POSITION_REQ','ko','LABEL','직책 *'),('LBL_USER_POSITION_REQ','en','LABEL','Position *'),('LBL_USER_POSITION_REQ','zh','LABEL','职位 *'),('LBL_USER_POSITION_REQ','ja','LABEL','役職 *'),
('LBL_USER_KC_USERNAME','ko','LABEL','Keycloak username'),('LBL_USER_KC_USERNAME','en','LABEL','Keycloak Username'),('LBL_USER_KC_USERNAME','zh','LABEL','Keycloak 用户名'),('LBL_USER_KC_USERNAME','ja','LABEL','Keycloak ユーザー名'),
('LBL_USER_ROLES','ko','LABEL','역할'),('LBL_USER_ROLES','en','LABEL','Roles'),('LBL_USER_ROLES','zh','LABEL','角色'),('LBL_USER_ROLES','ja','LABEL','役割'),
('ROLE_USER_NAME','ko','LABEL','일반 사용자'),('ROLE_USER_NAME','en','LABEL','User'),('ROLE_USER_NAME','zh','LABEL','普通用户'),('ROLE_USER_NAME','ja','LABEL','一般ユーザー'),
('ROLE_APPROVER_NAME','ko','LABEL','결재자'),('ROLE_APPROVER_NAME','en','LABEL','Approver'),('ROLE_APPROVER_NAME','zh','LABEL','审批人'),('ROLE_APPROVER_NAME','ja','LABEL','決裁者'),
('ROLE_MANAGER_NAME','ko','LABEL','부서장'),('ROLE_MANAGER_NAME','en','LABEL','Manager'),('ROLE_MANAGER_NAME','zh','LABEL','部门主管'),('ROLE_MANAGER_NAME','ja','LABEL','部署長'),
('ROLE_ADMIN_NAME','ko','LABEL','관리자'),('ROLE_ADMIN_NAME','en','LABEL','Admin'),('ROLE_ADMIN_NAME','zh','LABEL','管理员'),('ROLE_ADMIN_NAME','ja','LABEL','管理者'),
-- Admin Dept form
('LBL_DEPT_NEW','ko','LABEL','새 부서'),('LBL_DEPT_NEW','en','LABEL','New Department'),('LBL_DEPT_NEW','zh','LABEL','新建部门'),('LBL_DEPT_NEW','ja','LABEL','新規部署'),
('LBL_DEPT_EDIT','ko','LABEL','부서 편집'),('LBL_DEPT_EDIT','en','LABEL','Edit Department'),('LBL_DEPT_EDIT','zh','LABEL','编辑部门'),('LBL_DEPT_EDIT','ja','LABEL','部署編集'),
('LBL_DEPT_SELECT_HINT','ko','LABEL','부서를 선택하거나 추가하세요'),('LBL_DEPT_SELECT_HINT','en','LABEL','Select or add a department'),('LBL_DEPT_SELECT_HINT','zh','LABEL','选择或添加部门'),('LBL_DEPT_SELECT_HINT','ja','LABEL','部署を選択または追加'),
('LBL_DEPT_CODE_REQ','ko','LABEL','부서코드 *'),('LBL_DEPT_CODE_REQ','en','LABEL','Dept Code *'),('LBL_DEPT_CODE_REQ','zh','LABEL','部门代码 *'),('LBL_DEPT_CODE_REQ','ja','LABEL','部署コード *'),
('LBL_DEPT_NAME_REQ','ko','LABEL','부서명 *'),('LBL_DEPT_NAME_REQ','en','LABEL','Dept Name *'),('LBL_DEPT_NAME_REQ','zh','LABEL','部门名 *'),('LBL_DEPT_NAME_REQ','ja','LABEL','部署名 *'),
('LBL_DEPT_PARENT','ko','LABEL','상위 부서'),('LBL_DEPT_PARENT','en','LABEL','Parent Dept'),('LBL_DEPT_PARENT','zh','LABEL','上级部门'),('LBL_DEPT_PARENT','ja','LABEL','上位部署'),
('LBL_DEPT_LEVEL','ko','LABEL','레벨'),('LBL_DEPT_LEVEL','en','LABEL','Level'),('LBL_DEPT_LEVEL','zh','LABEL','级别'),('LBL_DEPT_LEVEL','ja','LABEL','レベル'),
('LBL_DEPT_SORT','ko','LABEL','정렬순서'),('LBL_DEPT_SORT','en','LABEL','Sort Order'),('LBL_DEPT_SORT','zh','LABEL','排序'),('LBL_DEPT_SORT','ja','LABEL','並び順'),
('LBL_DEPT_USE','ko','LABEL','사용'),('LBL_DEPT_USE','en','LABEL','Use'),('LBL_DEPT_USE','zh','LABEL','使用'),('LBL_DEPT_USE','ja','LABEL','使用'),
-- Admin Menu form
('LBL_MENU_NEW','ko','LABEL','새 메뉴'),('LBL_MENU_NEW','en','LABEL','New Menu'),('LBL_MENU_NEW','zh','LABEL','新建菜单'),('LBL_MENU_NEW','ja','LABEL','新規メニュー'),
('LBL_MENU_EDIT','ko','LABEL','메뉴 편집'),('LBL_MENU_EDIT','en','LABEL','Edit Menu'),('LBL_MENU_EDIT','zh','LABEL','编辑菜单'),('LBL_MENU_EDIT','ja','LABEL','メニュー編集'),
('LBL_MENU_SELECT_HINT','ko','LABEL','메뉴를 선택하세요'),('LBL_MENU_SELECT_HINT','en','LABEL','Select a menu'),('LBL_MENU_SELECT_HINT','zh','LABEL','选择菜单'),('LBL_MENU_SELECT_HINT','ja','LABEL','メニューを選択'),
('LBL_MENU_ID_REQ','ko','LABEL','메뉴 ID *'),('LBL_MENU_ID_REQ','en','LABEL','Menu ID *'),('LBL_MENU_ID_REQ','zh','LABEL','菜单ID *'),('LBL_MENU_ID_REQ','ja','LABEL','メニューID *'),
('LBL_MENU_NAME_REQ','ko','LABEL','메뉴명 *'),('LBL_MENU_NAME_REQ','en','LABEL','Menu Name *'),('LBL_MENU_NAME_REQ','zh','LABEL','菜单名 *'),('LBL_MENU_NAME_REQ','ja','LABEL','メニュー名 *'),
('LBL_MENU_PATH','ko','LABEL','경로'),('LBL_MENU_PATH','en','LABEL','Path'),('LBL_MENU_PATH','zh','LABEL','路径'),('LBL_MENU_PATH','ja','LABEL','パス'),
('LBL_MENU_PARENT','ko','LABEL','상위 메뉴'),('LBL_MENU_PARENT','en','LABEL','Parent Menu'),('LBL_MENU_PARENT','zh','LABEL','上级菜单'),('LBL_MENU_PARENT','ja','LABEL','上位メニュー'),
('LBL_MENU_LEVEL','ko','LABEL','레벨'),('LBL_MENU_LEVEL','en','LABEL','Level'),('LBL_MENU_LEVEL','zh','LABEL','级别'),('LBL_MENU_LEVEL','ja','LABEL','レベル'),
('LBL_MENU_SORT','ko','LABEL','정렬순서'),('LBL_MENU_SORT','en','LABEL','Sort Order'),('LBL_MENU_SORT','zh','LABEL','排序'),('LBL_MENU_SORT','ja','LABEL','並び順'),
('LBL_MENU_ICON','ko','LABEL','아이콘'),('LBL_MENU_ICON','en','LABEL','Icon'),('LBL_MENU_ICON','zh','LABEL','图标'),('LBL_MENU_ICON','ja','LABEL','アイコン'),
('LBL_MENU_USE','ko','LABEL','사용'),('LBL_MENU_USE','en','LABEL','Use'),('LBL_MENU_USE','zh','LABEL','使用'),('LBL_MENU_USE','ja','LABEL','使用'),
('LBL_MENU_PERM_MATRIX','ko','LABEL','권한 매트릭스'),('LBL_MENU_PERM_MATRIX','en','LABEL','Permission Matrix'),('LBL_MENU_PERM_MATRIX','zh','LABEL','权限矩阵'),('LBL_MENU_PERM_MATRIX','ja','LABEL','権限マトリクス'),
('LBL_MENU_PERM_SELECTED','ko','LABEL','선택 메뉴'),('LBL_MENU_PERM_SELECTED','en','LABEL','Selected Menu'),('LBL_MENU_PERM_SELECTED','zh','LABEL','选中菜单'),('LBL_MENU_PERM_SELECTED','ja','LABEL','選択メニュー'),
('LBL_MENU_PERM_ALL','ko','LABEL','(전체 메뉴)'),('LBL_MENU_PERM_ALL','en','LABEL','(All Menus)'),('LBL_MENU_PERM_ALL','zh','LABEL','(全部菜单)'),('LBL_MENU_PERM_ALL','ja','LABEL','(全メニュー)'),
-- Admin Codes labels
('LBL_CODE_NEW_GROUP','ko','LABEL','새 그룹 추가'),('LBL_CODE_NEW_GROUP','en','LABEL','Add New Group'),('LBL_CODE_NEW_GROUP','zh','LABEL','添加新组'),('LBL_CODE_NEW_GROUP','ja','LABEL','新グループ追加'),
('LBL_CODE_GROUP_ID_REQ','ko','LABEL','그룹 ID *'),('LBL_CODE_GROUP_ID_REQ','en','LABEL','Group ID *'),('LBL_CODE_GROUP_ID_REQ','zh','LABEL','组ID *'),('LBL_CODE_GROUP_ID_REQ','ja','LABEL','グループID *'),
('LBL_CODE_FIRST_REQ','ko','LABEL','첫 코드 *'),('LBL_CODE_FIRST_REQ','en','LABEL','First Code *'),('LBL_CODE_FIRST_REQ','zh','LABEL','首代码 *'),('LBL_CODE_FIRST_REQ','ja','LABEL','最初のコード *'),
('LBL_CODE_NAME_REQ','ko','LABEL','코드명 *'),('LBL_CODE_NAME_REQ','en','LABEL','Code Name *'),('LBL_CODE_NAME_REQ','zh','LABEL','代码名 *'),('LBL_CODE_NAME_REQ','ja','LABEL','コード名 *'),
('LBL_CODE_GROUP_HINT','ko','LABEL','그룹을 선택하세요'),('LBL_CODE_GROUP_HINT','en','LABEL','Select a group'),('LBL_CODE_GROUP_HINT','zh','LABEL','选择组'),('LBL_CODE_GROUP_HINT','ja','LABEL','グループを選択'),
-- Audit detail
('LBL_AUDIT_DETAIL_HEADER','ko','LABEL','감사 로그 상세'),('LBL_AUDIT_DETAIL_HEADER','en','LABEL','Audit Log Detail'),('LBL_AUDIT_DETAIL_HEADER','zh','LABEL','审计日志详情'),('LBL_AUDIT_DETAIL_HEADER','ja','LABEL','監査ログ詳細'),
('LBL_AUDIT_TIME','ko','LABEL','시각'),('LBL_AUDIT_TIME','en','LABEL','Time'),('LBL_AUDIT_TIME','zh','LABEL','时间'),('LBL_AUDIT_TIME','ja','LABEL','時刻'),
('LBL_AUDIT_BEFORE','ko','LABEL','입력 (before)'),('LBL_AUDIT_BEFORE','en','LABEL','Input (before)'),('LBL_AUDIT_BEFORE','zh','LABEL','输入 (前)'),('LBL_AUDIT_BEFORE','ja','LABEL','入力 (before)'),
('LBL_AUDIT_AFTER','ko','LABEL','결과 (after)'),('LBL_AUDIT_AFTER','en','LABEL','Result (after)'),('LBL_AUDIT_AFTER','zh','LABEL','结果 (后)'),('LBL_AUDIT_AFTER','ja','LABEL','結果 (after)'),
('LBL_AUDIT_NONE','ko','LABEL','(없음)'),('LBL_AUDIT_NONE','en','LABEL','(none)'),('LBL_AUDIT_NONE','zh','LABEL','(无)'),('LBL_AUDIT_NONE','ja','LABEL','(なし)'),
('LBL_AUDIT_TARGET','ko','LABEL','대상'),('LBL_AUDIT_TARGET','en','LABEL','Target'),('LBL_AUDIT_TARGET','zh','LABEL','对象'),('LBL_AUDIT_TARGET','ja','LABEL','対象')
ON CONFLICT DO NOTHING;

-- ==============================================================
-- 11. MSG — 검증/확인/오류 메시지 보강
-- ==============================================================
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
('MSG_INPUT_REQUIRED','ko','MSG','입력 필요'),('MSG_INPUT_REQUIRED','en','MSG','Input required'),('MSG_INPUT_REQUIRED','zh','MSG','需要输入'),('MSG_INPUT_REQUIRED','ja','MSG','入力必須'),
('MSG_LOAD_FAILED','ko','MSG','조회 실패'),('MSG_LOAD_FAILED','en','MSG','Load failed'),('MSG_LOAD_FAILED','zh','MSG','加载失败'),('MSG_LOAD_FAILED','ja','MSG','照会失敗'),
('MSG_SAVE_DONE','ko','MSG','저장 완료'),('MSG_SAVE_DONE','en','MSG','Saved'),('MSG_SAVE_DONE','zh','MSG','已保存'),('MSG_SAVE_DONE','ja','MSG','保存完了'),
('MSG_SAVE_FAILED','ko','MSG','저장 실패'),('MSG_SAVE_FAILED','en','MSG','Save failed'),('MSG_SAVE_FAILED','zh','MSG','保存失败'),('MSG_SAVE_FAILED','ja','MSG','保存失敗'),
('MSG_DELETE_DONE','ko','MSG','삭제 완료'),('MSG_DELETE_DONE','en','MSG','Deleted'),('MSG_DELETE_DONE','zh','MSG','已删除'),('MSG_DELETE_DONE','ja','MSG','削除完了'),
('MSG_DELETE_FAILED','ko','MSG','삭제 실패'),('MSG_DELETE_FAILED','en','MSG','Delete failed'),('MSG_DELETE_FAILED','zh','MSG','删除失败'),('MSG_DELETE_FAILED','ja','MSG','削除失敗'),
('MSG_NO_CHANGES','ko','MSG','변경된 항목 없음'),('MSG_NO_CHANGES','en','MSG','No changes'),('MSG_NO_CHANGES','zh','MSG','无更改'),('MSG_NO_CHANGES','ja','MSG','変更なし'),
('MSG_USER_NAME_NO_REQ','ko','MSG','이름/사번은 필수입니다.'),('MSG_USER_NAME_NO_REQ','en','MSG','Name and employee no. are required.'),('MSG_USER_NAME_NO_REQ','zh','MSG','姓名/工号必填。'),('MSG_USER_NAME_NO_REQ','ja','MSG','氏名/番号は必須です。'),
('MSG_USER_DEPT_POS_REQ','ko','MSG','부서/직책을 선택하세요.'),('MSG_USER_DEPT_POS_REQ','en','MSG','Select department and position.'),('MSG_USER_DEPT_POS_REQ','zh','MSG','请选择部门/职位。'),('MSG_USER_DEPT_POS_REQ','ja','MSG','部署/役職を選択してください。'),
('MSG_USER_TOGGLE_CONFIRM','ko','MSG','''{name}''의 활성 상태를 토글합니다.'),('MSG_USER_TOGGLE_CONFIRM','en','MSG','Toggle active status of ''{name}''.'),('MSG_USER_TOGGLE_CONFIRM','zh','MSG','切换''{name}''的激活状态。'),('MSG_USER_TOGGLE_CONFIRM','ja','MSG','''{name}''の有効状態を切替します。'),
('MSG_USER_RESET_PWD_CONFIRM','ko','MSG','''{name}''의 비밀번호를 임시 비밀번호로 초기화합니다.'),('MSG_USER_RESET_PWD_CONFIRM','en','MSG','Reset password of ''{name}'' to a temporary one.'),('MSG_USER_RESET_PWD_CONFIRM','zh','MSG','将''{name}''的密码重置为临时密码。'),('MSG_USER_RESET_PWD_CONFIRM','ja','MSG','''{name}''のパスワードを一時パスワードに初期化します。'),
('MSG_USER_TEMP_PASSWORD','ko','MSG','임시 비밀번호: {pwd}'),('MSG_USER_TEMP_PASSWORD','en','MSG','Temporary password: {pwd}'),('MSG_USER_TEMP_PASSWORD','zh','MSG','临时密码: {pwd}'),('MSG_USER_TEMP_PASSWORD','ja','MSG','一時パスワード: {pwd}'),
('MSG_USER_KC_NOT_SET','ko','MSG','Keycloak username 미설정'),('MSG_USER_KC_NOT_SET','en','MSG','Keycloak username not set'),('MSG_USER_KC_NOT_SET','zh','MSG','未设置 Keycloak 用户名'),('MSG_USER_KC_NOT_SET','ja','MSG','Keycloak ユーザー名未設定'),
('MSG_USER_STATUS_CHANGED','ko','MSG','상태 변경됨'),('MSG_USER_STATUS_CHANGED','en','MSG','Status changed'),('MSG_USER_STATUS_CHANGED','zh','MSG','状态已更改'),('MSG_USER_STATUS_CHANGED','ja','MSG','状態変更'),
('MSG_USER_STATUS_FAILED','ko','MSG','변경 실패'),('MSG_USER_STATUS_FAILED','en','MSG','Change failed'),('MSG_USER_STATUS_FAILED','zh','MSG','更改失败'),('MSG_USER_STATUS_FAILED','ja','MSG','変更失敗'),
('MSG_USER_PWD_RESET','ko','MSG','비밀번호 초기화'),('MSG_USER_PWD_RESET','en','MSG','Password reset'),('MSG_USER_PWD_RESET','zh','MSG','密码重置'),('MSG_USER_PWD_RESET','ja','MSG','パスワード初期化'),
('MSG_USER_PWD_RESET_FAILED','ko','MSG','초기화 실패'),('MSG_USER_PWD_RESET_FAILED','en','MSG','Reset failed'),('MSG_USER_PWD_RESET_FAILED','zh','MSG','重置失败'),('MSG_USER_PWD_RESET_FAILED','ja','MSG','初期化失敗'),
('MSG_DEPT_REQ','ko','MSG','부서코드/부서명은 필수.'),('MSG_DEPT_REQ','en','MSG','Dept code and name are required.'),('MSG_DEPT_REQ','zh','MSG','部门代码/部门名必填。'),('MSG_DEPT_REQ','ja','MSG','部署コード/部署名は必須。'),
('MSG_DEPT_DELETE_CONFIRM','ko','MSG','''{name}'' 부서를 삭제합니다. 하위 부서/소속 직원이 있으면 실패합니다.'),('MSG_DEPT_DELETE_CONFIRM','en','MSG','Delete department ''{name}''. Will fail if it has children or members.'),('MSG_DEPT_DELETE_CONFIRM','zh','MSG','删除部门 ''{name}''。若有子部门/成员将失败。'),('MSG_DEPT_DELETE_CONFIRM','ja','MSG','部署 ''{name}'' を削除します。下位部署/所属社員があれば失敗します。'),
('MSG_MENU_REQ','ko','MSG','메뉴ID/메뉴명은 필수.'),('MSG_MENU_REQ','en','MSG','Menu ID and name are required.'),('MSG_MENU_REQ','zh','MSG','菜单ID/菜单名必填。'),('MSG_MENU_REQ','ja','MSG','メニューID/メニュー名は必須。'),
('MSG_MENU_DELETE_CONFIRM','ko','MSG','''{name}'' 메뉴를 삭제합니다.'),('MSG_MENU_DELETE_CONFIRM','en','MSG','Delete menu ''{name}''.'),('MSG_MENU_DELETE_CONFIRM','zh','MSG','删除菜单 ''{name}''。'),('MSG_MENU_DELETE_CONFIRM','ja','MSG','メニュー ''{name}'' を削除します。'),
('MSG_MENU_PERM_SAVED','ko','MSG','권한 저장됨'),('MSG_MENU_PERM_SAVED','en','MSG','Permissions saved'),('MSG_MENU_PERM_SAVED','zh','MSG','权限已保存'),('MSG_MENU_PERM_SAVED','ja','MSG','権限保存'),
('MSG_CODE_DELETE_CONFIRM','ko','MSG','''{code}'' 코드를 삭제합니다.'),('MSG_CODE_DELETE_CONFIRM','en','MSG','Delete code ''{code}''.'),('MSG_CODE_DELETE_CONFIRM','zh','MSG','删除代码 ''{code}''。'),('MSG_CODE_DELETE_CONFIRM','ja','MSG','コード ''{code}'' を削除します。'),
('MSG_CODE_ALL_REQ','ko','MSG','모든 항목 필수.'),('MSG_CODE_ALL_REQ','en','MSG','All fields are required.'),('MSG_CODE_ALL_REQ','zh','MSG','全部必填。'),('MSG_CODE_ALL_REQ','ja','MSG','全項目必須。'),
('MSG_CODE_GROUP_ADDED','ko','MSG','그룹 추가됨'),('MSG_CODE_GROUP_ADDED','en','MSG','Group added'),('MSG_CODE_GROUP_ADDED','zh','MSG','已添加组'),('MSG_CODE_GROUP_ADDED','ja','MSG','グループ追加'),
('MSG_CODE_ADD_FAILED','ko','MSG','추가 실패'),('MSG_CODE_ADD_FAILED','en','MSG','Add failed'),('MSG_CODE_ADD_FAILED','zh','MSG','添加失败'),('MSG_CODE_ADD_FAILED','ja','MSG','追加失敗'),
('MSG_APPROVAL_REJECT_REASON_REQ','ko','MSG','반려 사유를 입력하세요'),('MSG_APPROVAL_REJECT_REASON_REQ','en','MSG','Please enter rejection reason'),('MSG_APPROVAL_REJECT_REASON_REQ','zh','MSG','请输入退回理由'),('MSG_APPROVAL_REJECT_REASON_REQ','ja','MSG','却下理由を入力してください'),
('MSG_APPROVAL_WITHDRAW_CONFIRM','ko','MSG','이 문서를 회수하시겠습니까? DRAFT 상태로 되돌아갑니다.'),('MSG_APPROVAL_WITHDRAW_CONFIRM','en','MSG','Withdraw this document? It will return to DRAFT.'),('MSG_APPROVAL_WITHDRAW_CONFIRM','zh','MSG','是否撤回此文档？将回到草稿状态。'),('MSG_APPROVAL_WITHDRAW_CONFIRM','ja','MSG','この文書を取下げますか？ DRAFT 状態に戻ります。'),
('MSG_APPROVAL_RESUBMIT_CONFIRM','ko','MSG','반려된 문서를 재상신하시겠습니까? 새 문서 버전이 생성됩니다.'),('MSG_APPROVAL_RESUBMIT_CONFIRM','en','MSG','Resubmit rejected document? A new version will be created.'),('MSG_APPROVAL_RESUBMIT_CONFIRM','zh','MSG','是否重新提交被退回的文档？将创建新版本。'),('MSG_APPROVAL_RESUBMIT_CONFIRM','ja','MSG','却下文書を再起案しますか？ 新しい版が作成されます。'),
('MSG_APPROVAL_RESUBMIT_DONE','ko','MSG','재상신 완료. 신규 docId={id}'),('MSG_APPROVAL_RESUBMIT_DONE','en','MSG','Resubmitted. New docId={id}'),('MSG_APPROVAL_RESUBMIT_DONE','zh','MSG','重新提交完成。新docId={id}'),('MSG_APPROVAL_RESUBMIT_DONE','ja','MSG','再起案完了。新docId={id}'),
('MSG_APPROVAL_DELEGATE_REQ','ko','MSG','대리자 / 시작일 / 종료일은 필수입니다'),('MSG_APPROVAL_DELEGATE_REQ','en','MSG','Delegatee / from / to dates are required'),('MSG_APPROVAL_DELEGATE_REQ','zh','MSG','代审人 / 开始日 / 结束日必填'),('MSG_APPROVAL_DELEGATE_REQ','ja','MSG','代理者 / 開始日 / 終了日は必須です'),
('MSG_APPROVAL_DELEGATE_DONE','ko','MSG','대결 등록 완료'),('MSG_APPROVAL_DELEGATE_DONE','en','MSG','Delegate registered'),('MSG_APPROVAL_DELEGATE_DONE','zh','MSG','代审登记完成'),('MSG_APPROVAL_DELEGATE_DONE','ja','MSG','代決登録完了'),
('MSG_APPROVAL_FORM_REQ','ko','MSG','양식을 선택하세요'),('MSG_APPROVAL_FORM_REQ','en','MSG','Please select a form'),('MSG_APPROVAL_FORM_REQ','zh','MSG','请选择表单'),('MSG_APPROVAL_FORM_REQ','ja','MSG','様式を選択してください'),
('MSG_APPROVAL_TITLE_REQ','ko','MSG','제목을 입력하세요'),('MSG_APPROVAL_TITLE_REQ','en','MSG','Please enter title'),('MSG_APPROVAL_TITLE_REQ','zh','MSG','请输入标题'),('MSG_APPROVAL_TITLE_REQ','ja','MSG','タイトルを入力してください'),
('MSG_APPROVAL_LEAVE_TYPE_REQ','ko','MSG','휴가 유형을 선택하세요'),('MSG_APPROVAL_LEAVE_TYPE_REQ','en','MSG','Please select leave type'),('MSG_APPROVAL_LEAVE_TYPE_REQ','zh','MSG','请选择休假类型'),('MSG_APPROVAL_LEAVE_TYPE_REQ','ja','MSG','休暇種別を選択してください'),
('MSG_APPROVAL_DATE_REQ','ko','MSG','시작일/종료일을 선택하세요'),('MSG_APPROVAL_DATE_REQ','en','MSG','Select from/to dates'),('MSG_APPROVAL_DATE_REQ','zh','MSG','请选择开始/结束日'),('MSG_APPROVAL_DATE_REQ','ja','MSG','開始日/終了日を選択してください'),
('MSG_APPROVAL_DATE_ORDER','ko','MSG','종료일은 시작일 이후여야 합니다'),('MSG_APPROVAL_DATE_ORDER','en','MSG','To date must be after from date'),('MSG_APPROVAL_DATE_ORDER','zh','MSG','结束日须晚于开始日'),('MSG_APPROVAL_DATE_ORDER','ja','MSG','終了日は開始日以降である必要があります'),
('MSG_APPROVAL_DAYS_ZERO','ko','MSG','일수가 0입니다. 날짜를 다시 확인하세요'),('MSG_APPROVAL_DAYS_ZERO','en','MSG','Days is 0. Please re-check dates'),('MSG_APPROVAL_DAYS_ZERO','zh','MSG','天数为 0。请重新检查日期'),('MSG_APPROVAL_DAYS_ZERO','ja','MSG','日数が 0 です。日付を再確認してください'),
('MSG_APPROVAL_SUBMIT_DONE','ko','MSG','상신 완료. 문서번호 {id} (결재자 {n}명)'),('MSG_APPROVAL_SUBMIT_DONE','en','MSG','Submitted. Doc No. {id} ({n} approvers)'),('MSG_APPROVAL_SUBMIT_DONE','zh','MSG','提交完成。文档号 {id} ({n}位审批人)'),('MSG_APPROVAL_SUBMIT_DONE','ja','MSG','起案完了。文書番号 {id} (決裁者 {n}名)'),
('MSG_APPROVAL_SUBMIT_FAILED','ko','MSG','상신 실패'),('MSG_APPROVAL_SUBMIT_FAILED','en','MSG','Submit failed'),('MSG_APPROVAL_SUBMIT_FAILED','zh','MSG','提交失败'),('MSG_APPROVAL_SUBMIT_FAILED','ja','MSG','起案失敗'),
('MSG_APPROVAL_APPROVE_FAILED','ko','MSG','승인 실패'),('MSG_APPROVAL_APPROVE_FAILED','en','MSG','Approve failed'),('MSG_APPROVAL_APPROVE_FAILED','zh','MSG','批准失败'),('MSG_APPROVAL_APPROVE_FAILED','ja','MSG','承認失敗'),
('MSG_APPROVAL_REJECT_FAILED','ko','MSG','반려 실패'),('MSG_APPROVAL_REJECT_FAILED','en','MSG','Reject failed'),('MSG_APPROVAL_REJECT_FAILED','zh','MSG','退回失败'),('MSG_APPROVAL_REJECT_FAILED','ja','MSG','却下失敗'),
('MSG_APPROVAL_WITHDRAW_FAILED','ko','MSG','회수 실패'),('MSG_APPROVAL_WITHDRAW_FAILED','en','MSG','Withdraw failed'),('MSG_APPROVAL_WITHDRAW_FAILED','zh','MSG','撤回失败'),('MSG_APPROVAL_WITHDRAW_FAILED','ja','MSG','取下げ失敗'),
('MSG_APPROVAL_RESUBMIT_FAILED','ko','MSG','재상신 실패'),('MSG_APPROVAL_RESUBMIT_FAILED','en','MSG','Resubmit failed'),('MSG_APPROVAL_RESUBMIT_FAILED','zh','MSG','重新提交失败'),('MSG_APPROVAL_RESUBMIT_FAILED','ja','MSG','再起案失敗'),
('MSG_APPROVAL_DELEGATE_FAILED','ko','MSG','대결 등록 실패'),('MSG_APPROVAL_DELEGATE_FAILED','en','MSG','Delegate registration failed'),('MSG_APPROVAL_DELEGATE_FAILED','zh','MSG','代审登记失败'),('MSG_APPROVAL_DELEGATE_FAILED','ja','MSG','代決登録失敗'),
('MSG_BOARD_TITLE_REQ','ko','MSG','제목을 입력하세요'),('MSG_BOARD_TITLE_REQ','en','MSG','Please enter title'),('MSG_BOARD_TITLE_REQ','zh','MSG','请输入标题'),('MSG_BOARD_TITLE_REQ','ja','MSG','タイトルを入力してください'),
('MSG_BOARD_SAVE_DONE','ko','MSG','게시글이 등록되었습니다'),('MSG_BOARD_SAVE_DONE','en','MSG','Post created'),('MSG_BOARD_SAVE_DONE','zh','MSG','帖子已发布'),('MSG_BOARD_SAVE_DONE','ja','MSG','投稿が登録されました'),
('MSG_BOARD_UPDATE_DONE','ko','MSG','게시글이 수정되었습니다'),('MSG_BOARD_UPDATE_DONE','en','MSG','Post updated'),('MSG_BOARD_UPDATE_DONE','zh','MSG','帖子已更新'),('MSG_BOARD_UPDATE_DONE','ja','MSG','投稿が修正されました'),
('MSG_BOARD_SAVE_FAILED','ko','MSG','저장에 실패했습니다'),('MSG_BOARD_SAVE_FAILED','en','MSG','Save failed'),('MSG_BOARD_SAVE_FAILED','zh','MSG','保存失败'),('MSG_BOARD_SAVE_FAILED','ja','MSG','保存に失敗しました'),
('MSG_CAL_MOVE_FAILED','ko','MSG','일정 이동에 실패했습니다'),('MSG_CAL_MOVE_FAILED','en','MSG','Failed to move event'),('MSG_CAL_MOVE_FAILED','zh','MSG','移动日程失败'),('MSG_CAL_MOVE_FAILED','ja','MSG','予定の移動に失敗しました'),
('MSG_ATT_CHECK_IN_FAILED','ko','MSG','출근 실패: {err}'),('MSG_ATT_CHECK_IN_FAILED','en','MSG','Check-in failed: {err}'),('MSG_ATT_CHECK_IN_FAILED','zh','MSG','签到失败: {err}'),('MSG_ATT_CHECK_IN_FAILED','ja','MSG','出勤失敗: {err}'),
('MSG_ATT_CHECK_OUT_FAILED','ko','MSG','퇴근 실패: {err}'),('MSG_ATT_CHECK_OUT_FAILED','en','MSG','Check-out failed: {err}'),('MSG_ATT_CHECK_OUT_FAILED','zh','MSG','签退失败: {err}'),('MSG_ATT_CHECK_OUT_FAILED','ja','MSG','退勤失敗: {err}')
ON CONFLICT DO NOTHING;
