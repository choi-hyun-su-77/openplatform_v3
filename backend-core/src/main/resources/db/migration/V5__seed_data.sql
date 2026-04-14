-- 개발/테스트용 시드 데이터 — E2E 시나리오 15종 커버

-- 부서 트리 (본사 → 경영지원본부/사업본부/개발본부 → 팀)
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order) VALUES
    (10, 'MGT',   '경영지원본부', 1,  2, 1),
    (11, 'HR',    '인사팀',       10, 3, 1),
    (12, 'FIN',   '재무팀',       10, 3, 2),
    (13, 'GA',    '총무팀',       10, 3, 3),
    (20, 'BIZ',   '사업본부',     1,  2, 2),
    (21, 'SALES', '영업1팀',      20, 3, 1),
    (22, 'SALES2','영업2팀',      20, 3, 2),
    (23, 'MKT',   '마케팅팀',     20, 3, 3),
    (30, 'DEV',   '개발본부',     1,  2, 3),
    (31, 'FE',    '프론트엔드팀', 30, 3, 1),
    (32, 'BE',    '백엔드팀',     30, 3, 2),
    (33, 'INFRA', '인프라팀',     30, 3, 3)
ON CONFLICT (dept_code) DO NOTHING;

-- 직원 (15명)
INSERT INTO platform_v3.org_employee (employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status) VALUES
    ('E0001', '김대표', 1,  1, 'ceo@v3.local',     '010-0000-0001', 'admin', '2020-01-01', 'ACTIVE'),
    ('E0010', '박본부', 10, 2, 'mgt.head@v3.local','010-0000-0010', NULL,    '2020-03-01', 'ACTIVE'),
    ('E0011', '이인사', 11, 3, 'hr.lead@v3.local', '010-0000-0011', NULL,    '2021-02-01', 'ACTIVE'),
    ('E0012', '최인사', 11, 4, 'hr1@v3.local',     '010-0000-0012', NULL,    '2022-05-01', 'ACTIVE'),
    ('E0020', '정사업', 20, 2, 'biz.head@v3.local','010-0000-0020', NULL,    '2020-04-01', 'ACTIVE'),
    ('E0021', '윤영업', 21, 3, 'sales1@v3.local',  '010-0000-0021', NULL,    '2021-06-01', 'ACTIVE'),
    ('E0022', '한영업', 21, 4, 'sales1a@v3.local', '010-0000-0022', NULL,    '2022-07-01', 'ACTIVE'),
    ('E0030', '오개발', 30, 2, 'dev.head@v3.local','010-0000-0030', NULL,    '2020-05-01', 'ACTIVE'),
    ('E0031', '남프론', 31, 3, 'fe.lead@v3.local', '010-0000-0031', NULL,    '2021-08-01', 'ACTIVE'),
    ('E0032', '서프론', 31, 4, 'fe1@v3.local',     '010-0000-0032', 'user1', '2022-09-01', 'ACTIVE'),
    ('E0033', '배프론', 31, 5, 'fe2@v3.local',     '010-0000-0033', NULL,    '2023-10-01', 'ACTIVE'),
    ('E0034', '강백엔', 32, 3, 'be.lead@v3.local', '010-0000-0034', NULL,    '2021-09-01', 'ACTIVE'),
    ('E0035', '임백엔', 32, 4, 'be1@v3.local',     '010-0000-0035', NULL,    '2022-10-01', 'ACTIVE'),
    ('E0036', '노인프', 33, 3, 'infra.lead@v3.local','010-0000-0036',NULL, '2021-11-01', 'ACTIVE'),
    ('E0037', '장인프', 33, 5, 'infra1@v3.local',  '010-0000-0037', NULL,    '2023-12-01', 'ACTIVE')
ON CONFLICT (employee_no) DO NOTHING;

-- 공통코드
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order) VALUES
    ('BOARD_TYPE', 'NOTICE',  '공지사항',   1),
    ('BOARD_TYPE', 'DEPT',    '부서게시판', 2),
    ('BOARD_TYPE', 'FREE',    '자유게시판', 3),
    ('BOARD_TYPE', 'ARCHIVE', '자료실',     4),
    ('EVENT_TYPE', 'PERSONAL','개인',       1),
    ('EVENT_TYPE', 'DEPT',    '부서',       2),
    ('EVENT_TYPE', 'COMPANY', '회사',       3),
    ('EMP_STATUS', 'ACTIVE',  '재직',       1),
    ('EMP_STATUS', 'LEAVE',   '휴직',       2),
    ('EMP_STATUS', 'RETIRED', '퇴직',       3)
ON CONFLICT (group_cd, code) DO NOTHING;

-- 게시글 (공지 3 + 부서 2 + 자유 2)
INSERT INTO platform_v3.bd_post (board_type, dept_id, title, content, created_by, is_pinned, created_at) VALUES
    ('NOTICE', NULL, '[필독] openplatform v3 런칭 안내', '통합 그룹웨어 v3 가 런칭되었습니다. 메신저/메일/위키/화상회의가 통합되었으니 많은 이용 바랍니다.', 'admin', 'Y', NOW() - INTERVAL '1 day'),
    ('NOTICE', NULL, '2026년 2분기 전사 워크샵 공지', '4월 20일 본사 대강당에서 2분기 워크샵을 진행합니다.', 'admin', 'Y', NOW() - INTERVAL '2 days'),
    ('NOTICE', NULL, '근태관리 시스템 업데이트 안내',   '근태관리가 전자결재와 통합되었습니다.', 'admin', 'N', NOW() - INTERVAL '3 days'),
    ('DEPT',   30,   '[개발본부] 주간 스탠드업 공지',  '매주 월요일 10시', 'dev.head', 'N', NOW() - INTERVAL '4 hours'),
    ('DEPT',   31,   '[FE팀] Vue 3.5 업그레이드 스터디','매주 수요일', 'fe.lead', 'N', NOW() - INTERVAL '6 hours'),
    ('FREE',   NULL, '점심 맛집 추천',                   '본사 근처 맛집 공유합니다.', 'user1', 'N', NOW() - INTERVAL '8 hours'),
    ('FREE',   NULL, '사내 동아리 축구팀 모집',          '4월 토요일 오전 경기', 'user1', 'N', NOW() - INTERVAL '12 hours');

-- 캘린더 이벤트 (오늘 + 이번 달)
INSERT INTO platform_v3.cal_event (title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by) VALUES
    ('전사 임원회의',          '월간 전사 임원회의',   'COMPANY', 1,  NULL, NOW() + INTERVAL '2 hours',  NOW() + INTERVAL '4 hours',  FALSE, '#3b82f6', '본사 대회의실', 'admin'),
    ('FE팀 스프린트 리뷰',     '이번 스프린트 리뷰',   'DEPT',    10, 31,   NOW() + INTERVAL '5 hours',  NOW() + INTERVAL '6 hours',  FALSE, '#10b981', 'FE팀 회의실',   'fe.lead'),
    ('점심 약속 - 고객사',     'ABC 주식회사 방문',    'PERSONAL',10, NULL, NOW() + INTERVAL '1 day',    NOW() + INTERVAL '1 day 1 hour', FALSE, '#f59e0b', '외부',         'user1'),
    ('분기 리뷰',              'Q1 결산 리뷰',         'COMPANY', 1,  NULL, NOW() + INTERVAL '3 days',   NOW() + INTERVAL '3 days 2 hours', FALSE, '#ef4444', '본사 강당',    'admin'),
    ('BE팀 기술 공유',         'Kafka 도입 검토',      'DEPT',    10, 32,   NOW() + INTERVAL '5 days',   NOW() + INTERVAL '5 days 1 hour',  FALSE, '#8b5cf6', 'BE팀 회의실',  'be.lead'),
    ('휴가',                   '연차 휴가',            'PERSONAL',10, NULL, CURRENT_DATE + INTERVAL '7 days', CURRENT_DATE + INTERVAL '9 days', TRUE, '#6b7280', '',            'user1');

-- 알림 (user id 10 = user1 매핑)
INSERT INTO platform_v3.cm_notification (recipient_id, doc_id, notification_type, channel, title, content, is_read, created_at) VALUES
    (10, NULL, 'SYSTEM',  'WEB', 'openplatform v3 에 오신 것을 환영합니다', '첫 로그인 환영 메시지', 'N', NOW() - INTERVAL '5 minutes'),
    (10, 1,    'APPROVAL','WEB', '결재 요청 - 휴가 신청서',                 '결재 대기 중', 'N', NOW() - INTERVAL '1 hour'),
    (10, 2,    'APPROVAL','WEB', '결재 승인 - 지출 품의',                   '승인 완료', 'Y', NOW() - INTERVAL '1 day'),
    (10, NULL, 'BOARD',   'WEB', '새 공지가 등록되었습니다',                '[필독] openplatform v3 런칭 안내', 'N', NOW() - INTERVAL '6 hours'),
    (10, NULL, 'MENTION', 'WEB', '메신저에서 언급되었습니다',               '@user1 오늘 점심 같이', 'N', NOW() - INTERVAL '30 minutes');

-- i18n 추가 메시지 (로그인/대시보드용)
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
    ('login.title',          'ko', 'LABEL', '통합 그룹웨어'),
    ('login.button',         'ko', 'LABEL', 'Keycloak 로 로그인'),
    ('dashboard.welcome',    'ko', 'LABEL', '환영합니다'),
    ('dashboard.today',      'ko', 'LABEL', '오늘 일정'),
    ('dashboard.pending',    'ko', 'LABEL', '미결 결재'),
    ('dashboard.notice',     'ko', 'LABEL', '최근 공지'),
    ('dashboard.unread',     'ko', 'LABEL', '읽지 않은 알림'),
    ('login.title',          'en', 'LABEL', 'Groupware Portal'),
    ('login.button',         'en', 'LABEL', 'Sign in with Keycloak'),
    ('dashboard.welcome',    'en', 'LABEL', 'Welcome'),
    ('dashboard.today',      'en', 'LABEL', 'Today''s Schedule'),
    ('dashboard.pending',    'en', 'LABEL', 'Pending Approvals'),
    ('dashboard.notice',     'en', 'LABEL', 'Recent Notices'),
    ('dashboard.unread',     'en', 'LABEL', 'Unread Notifications')
ON CONFLICT (msg_key, locale) DO NOTHING;
