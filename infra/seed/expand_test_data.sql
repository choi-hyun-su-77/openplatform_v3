-- ================================================================
-- openplatform v3 테스트 데이터 대폭 확장
-- 실행: docker exec v3-postgres bash -c "psql -U platform_v3 -d platform_v3 -f /tmp/expand.sql"
-- ================================================================

BEGIN;

-- ── Data-1a: 중복 정리 ──
-- 같은 title 로 들어간 게시글/이벤트/알림을 최신만 남김
DELETE FROM platform_v3.bd_post a USING platform_v3.bd_post b
 WHERE a.post_id < b.post_id AND a.title = b.title AND a.board_type = b.board_type;

DELETE FROM platform_v3.cal_event a USING platform_v3.cal_event b
 WHERE a.event_id < b.event_id AND a.title = b.title AND a.start_dt = b.start_dt;

DELETE FROM platform_v3.cm_notification a USING platform_v3.cm_notification b
 WHERE a.notification_id < b.notification_id
   AND a.recipient_id = b.recipient_id
   AND a.title = b.title
   AND a.created_at = b.created_at;

-- ── Data-1b: 직원 확장 (팀당 2~3명 추가로 30명 목표) ──
INSERT INTO platform_v3.org_employee (employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status) VALUES
    ('E0013', 'Jenny Kim',  12, 3, 'jenny.kim@v3.local',  '010-1010-0013', NULL, '2021-03-01', 'ACTIVE'),
    ('E0014', 'Mark Lee',   12, 4, 'mark.lee@v3.local',   '010-1010-0014', NULL, '2022-04-01', 'ACTIVE'),
    ('E0015', 'Alice Jung', 13, 3, 'alice.jung@v3.local', '010-1010-0015', NULL, '2021-05-01', 'ACTIVE'),
    ('E0016', 'Brian Park', 13, 4, 'brian.park@v3.local', '010-1010-0016', NULL, '2022-06-01', 'ACTIVE'),
    ('E0023', 'Cathy Han',  22, 3, 'cathy.han@v3.local',  '010-1010-0023', NULL, '2021-07-01', 'ACTIVE'),
    ('E0024', 'Daniel Yoo', 22, 4, 'daniel.yoo@v3.local', '010-1010-0024', NULL, '2023-01-15', 'ACTIVE'),
    ('E0025', 'Ella Choi',  23, 3, 'ella.choi@v3.local',  '010-1010-0025', NULL, '2021-09-01', 'ACTIVE'),
    ('E0026', 'Frank Kang', 23, 5, 'frank.kang@v3.local', '010-1010-0026', NULL, '2023-03-15', 'ACTIVE'),
    ('E0038', 'Grace Lim',  32, 5, 'grace.lim@v3.local',  '010-1010-0038', NULL, '2023-11-01', 'ACTIVE'),
    ('E0039', 'Harry Noh',  32, 4, 'harry.noh@v3.local',  '010-1010-0039', NULL, '2022-12-01', 'ACTIVE'),
    ('E0040', 'Iris Seo',   31, 5, 'iris.seo@v3.local',   '010-1010-0040', NULL, '2024-01-15', 'ACTIVE'),
    ('E0041', 'Jack Oh',    33, 4, 'jack.oh@v3.local',    '010-1010-0041', NULL, '2022-08-01', 'ACTIVE'),
    ('E0042', 'Karen Bae',  11, 5, 'karen.bae@v3.local',  '010-1010-0042', NULL, '2024-02-01', 'ACTIVE'),
    ('E0043', 'Leo Jang',   21, 4, 'leo.jang@v3.local',   '010-1010-0043', NULL, '2023-04-01', 'ACTIVE'),
    ('E0044', 'Mia Son',    20, 3, 'mia.son@v3.local',    '010-1010-0044', NULL, '2021-10-15', 'ACTIVE')
ON CONFLICT (employee_no) DO NOTHING;

-- ── Data-2: 게시판 40+ 게시글 ──
INSERT INTO platform_v3.bd_post (board_type, dept_id, title, content, created_by, is_pinned, view_count, attachments, created_at) VALUES
    -- NOTICE (공지사항) 10건
    ('NOTICE', NULL, '4월 전사 안전교육 필참 안내',          '4/18(목) 14:00 본사 대강당. 전 임직원 필수 참석입니다.', 'admin',    'Y',  412, '[]'::jsonb, NOW() - INTERVAL '2 hours'),
    ('NOTICE', NULL, '사내 보안 정책 개정 공지',               '4/20부터 VPN 이중인증 의무화. 관련 안내문 첨부.',         'admin',    'Y',  298, '[{"name":"security-policy-v2.pdf","size":240312}]'::jsonb, NOW() - INTERVAL '5 hours'),
    ('NOTICE', NULL, '신규 입사자 오리엔테이션 일정',           '4/22(월) 10:00 HR팀 회의실. 신규 입사자 5명 대상.',       'hr.lead',  'Y',  156, '[]'::jsonb, NOW() - INTERVAL '10 hours'),
    ('NOTICE', NULL, '2026 상반기 건강검진 대상자 안내',        '30세 이상 전 임직원 건강검진 대상. 4/25~5/10 기간 내 예약.', 'hr.lead','N', 203, '[{"name":"checkup-guide.pdf","size":180500}]'::jsonb, NOW() - INTERVAL '1 day'),
    ('NOTICE', NULL, '연차 소진 독려 공지',                     '2분기 내 5일 이상 연차 소진 권장. 부서별 일정 조율 바랍니다.','admin',  'N', 345, '[]'::jsonb, NOW() - INTERVAL '1 day 2 hours'),
    ('NOTICE', NULL, '사내 포털 v3 런칭 이벤트',                '포털 v3 런칭 기념 경품 이벤트! 피드백 제출자 추첨 10명.',  'admin',    'N', 512, '[]'::jsonb, NOW() - INTERVAL '1 day 4 hours'),
    ('NOTICE', NULL, '주차장 운영 규칙 변경',                   '4/16부터 지정 주차제 폐지, 선착순 운영으로 변경.',        'admin',    'N', 98,  '[]'::jsonb, NOW() - INTERVAL '2 days'),
    ('NOTICE', NULL, '전사 정전 안내',                          '4/19(금) 23:00~24:00 정전 점검. 핵심 시스템은 예비전력 운영.',  'infra.lead','N', 142, '[]'::jsonb, NOW() - INTERVAL '2 days 5 hours'),
    ('NOTICE', NULL, '휴가 제도 개선안 의견 수렴',              '3일 이상 장기휴가 권장. 의견은 HR 메일로 제출.',          'hr.lead',  'N',  76, '[]'::jsonb, NOW() - INTERVAL '3 days'),
    ('NOTICE', NULL, '사내 카페 운영 시간 변경',                '평일 08:00~19:00 로 확대. 주말 운영 중단.',               'admin',    'N',  88, '[]'::jsonb, NOW() - INTERVAL '3 days 8 hours'),

    -- DEPT (부서게시판) 10건
    ('DEPT',   30, '[개발본부] 주간 싱크업 회의록 (4/14)',       '1) 스프린트 리뷰 2) 이슈 공유 3) 다음주 계획', 'dev.head',   'N',  45, '[]'::jsonb, NOW() - INTERVAL '3 hours'),
    ('DEPT',   31, '[FE팀] Vue 3.5 마이그레이션 가이드',         'composition API 변환 체크리스트 공유.',        'fe.lead',    'Y',  67, '[]'::jsonb, NOW() - INTERVAL '8 hours'),
    ('DEPT',   32, '[BE팀] Kafka 도입 기술 리뷰',                '이벤트 소싱 아키텍처 검토. 슬라이드 첨부.',    'be.lead',    'N',  52, '[{"name":"kafka-review.pptx","size":1520334}]'::jsonb, NOW() - INTERVAL '12 hours'),
    ('DEPT',   33, '[인프라팀] k8s 업그레이드 계획',             '1.28 → 1.30 upgrade plan 공유.',                'infra.lead', 'N',  38, '[]'::jsonb, NOW() - INTERVAL '18 hours'),
    ('DEPT',   11, '[인사팀] 4월 채용 현황',                    '경력 7명 면접 진행 중. 최종 합격자 2명 예정.',  'hr.lead',    'N',  29, '[]'::jsonb, NOW() - INTERVAL '1 day'),
    ('DEPT',   12, '[재무팀] 3월 결산 공유',                    '매출 +12%, 비용 -3%. 상세는 회계팀 자료 참조.',  'mgt.head',   'N',  55, '[{"name":"2026-Q1-result.xlsx","size":245600}]'::jsonb, NOW() - INTERVAL '1 day 3 hours'),
    ('DEPT',   21, '[영업1팀] 분기 실적 리뷰',                  'Q1 목표 대비 108% 달성. 분석 자료 공유.',       'sales1.lead','N',  72, '[]'::jsonb, NOW() - INTERVAL '1 day 6 hours'),
    ('DEPT',   22, '[영업2팀] 신규 고객 파이프라인',            '신규 3건 계약 임박. 담당자 공유.',               'sales2.lead','N',  41, '[]'::jsonb, NOW() - INTERVAL '2 days'),
    ('DEPT',   23, '[마케팅팀] 4월 캠페인 KPI',                 'CTR 2.3%, CVR 0.8%. 타겟 재조정 논의 필요.',   'mkt.lead',   'N',  33, '[]'::jsonb, NOW() - INTERVAL '2 days 4 hours'),
    ('DEPT',   13, '[총무팀] 사무용품 신청 마감',                '월말 마감 주의. 4/25까지 신청 부탁드립니다.',   'ga.lead',    'N',  19, '[]'::jsonb, NOW() - INTERVAL '2 days 10 hours'),

    -- FREE (자유게시판) 15건
    ('FREE', NULL, '점심 맛집 추천 - 본사 근처 TOP 10',          '1. 김치찌개 집 2. 국밥 3. 파스타...',             'user1',      'N', 189, '[]'::jsonb, NOW() - INTERVAL '2 hours'),
    ('FREE', NULL, '사내 풋살팀 신규 멤버 모집',                 '매주 토요일 오전 9시. 초보자 환영!',               'user1',      'N',  45, '[]'::jsonb, NOW() - INTERVAL '4 hours'),
    ('FREE', NULL, '개발자 컨퍼런스 후기 - JSConf 2026',         '트렌드 + 인상 깊었던 세션 공유합니다.',             'fe.lead',    'N',  78, '[]'::jsonb, NOW() - INTERVAL '6 hours'),
    ('FREE', NULL, '반려동물 자랑 스레드',                       '우리 강아지 사진 공유합니다 🐶',                    'user1',      'N', 112, '[]'::jsonb, NOW() - INTERVAL '8 hours'),
    ('FREE', NULL, '커피머신 원두 추천',                          '에티오피아 vs 콜롬비아 투표',                       'user1',      'N',  34, '[]'::jsonb, NOW() - INTERVAL '10 hours'),
    ('FREE', NULL, '영화 동호회 이달의 추천작',                  '오펜하이머 관람 후기',                              'user1',      'N',  56, '[]'::jsonb, NOW() - INTERVAL '12 hours'),
    ('FREE', NULL, '사내 독서모임 4월 도서',                      'Clean Architecture. 토요 오전 스터디.',             'be.lead',    'N',  40, '[]'::jsonb, NOW() - INTERVAL '14 hours'),
    ('FREE', NULL, '운동 챌린지 - 4월 한달 걷기',                 '하루 1만보 챌린지. 인증 댓글.',                     'user1',      'N',  88, '[]'::jsonb, NOW() - INTERVAL '16 hours'),
    ('FREE', NULL, '카풀 모집 - 강남 → 판교',                    '매일 출퇴근 카풀 구합니다.',                        'user1',      'N',  22, '[]'::jsonb, NOW() - INTERVAL '18 hours'),
    ('FREE', NULL, '사진 동호회 전시 안내',                      '5월 첫째주 로비 전시. 참여 희망자 댓글 주세요.',    'user1',      'N',  30, '[]'::jsonb, NOW() - INTERVAL '20 hours'),
    ('FREE', NULL, '제주도 워크샵 후기',                          '숙소/음식/액티비티 추천.',                          'user1',      'N',  95, '[]'::jsonb, NOW() - INTERVAL '1 day'),
    ('FREE', NULL, '방탈출 카페 추천',                           '신사역 근처 강추합니다.',                            'user1',      'N',  27, '[]'::jsonb, NOW() - INTERVAL '1 day 4 hours'),
    ('FREE', NULL, '중고 판매 - 기계식 키보드',                  '로지텍 MX Mechanical. 10만원.',                     'user1',      'N',  14, '[]'::jsonb, NOW() - INTERVAL '1 day 8 hours'),
    ('FREE', NULL, '분실물 - 블루투스 이어폰 (3층)',              '에어팟 프로. 습득 시 연락 부탁드립니다.',           'user1',      'N',  11, '[]'::jsonb, NOW() - INTERVAL '2 days'),
    ('FREE', NULL, '취미생활 공유 - 드론 촬영',                   '한강 야경 촬영 후기.',                              'user1',      'N',  48, '[]'::jsonb, NOW() - INTERVAL '2 days 6 hours'),

    -- ARCHIVE (자료실) 8건
    ('ARCHIVE', NULL, '2026 개발자 온보딩 가이드',                'v3 프로젝트 구조, 컨벤션, 배포 절차.',   'dev.head',   'Y', 167, '[{"name":"onboarding-v3.pdf","size":1250000}]'::jsonb, NOW() - INTERVAL '6 hours'),
    ('ARCHIVE', NULL, '사내 디자인 시스템 v2',                   'Figma 파일 + Token 가이드.',            'fe.lead',    'Y',  98, '[{"name":"design-system-v2.fig","size":3450000}]'::jsonb, NOW() - INTERVAL '1 day'),
    ('ARCHIVE', NULL, '회의실 예약 매뉴얼',                      '포털 캘린더 사용법 PDF.',                 'ga.lead',    'N',  45, '[{"name":"room-booking.pdf","size":520000}]'::jsonb, NOW() - INTERVAL '1 day 12 hours'),
    ('ARCHIVE', NULL, '보안 인증 체크리스트',                    'ISMS 내부 감사 체크리스트.',             'infra.lead', 'N',  33, '[{"name":"security-checklist.xlsx","size":180000}]'::jsonb, NOW() - INTERVAL '2 days'),
    ('ARCHIVE', NULL, '재무 보고서 템플릿',                      '월별 결산 엑셀 템플릿.',                  'mgt.head',   'N',  27, '[{"name":"financial-template.xlsx","size":310000}]'::jsonb, NOW() - INTERVAL '3 days'),
    ('ARCHIVE', NULL, 'CS 응대 매뉴얼 v3',                       '고객 문의 대응 가이드.',                   'sales1.lead','N',  52, '[{"name":"cs-guide-v3.pdf","size":890000}]'::jsonb, NOW() - INTERVAL '4 days'),
    ('ARCHIVE', NULL, '제품 소개 프레젠테이션 템플릿',           '영업용 발표자료 템플릿.',                  'mkt.lead',   'N',  41, '[{"name":"product-intro.pptx","size":2100000}]'::jsonb, NOW() - INTERVAL '5 days'),
    ('ARCHIVE', NULL, '법무 검토 요청 서식',                     '외부 계약 검토 요청서.',                  'hr.lead',    'N',  18, '[{"name":"legal-review-form.docx","size":95000}]'::jsonb, NOW() - INTERVAL '6 days');

-- ── Data-3: 캘린더 40+ 이벤트 (4월 오늘=15일 전후 + 5월) ──
INSERT INTO platform_v3.cal_event (title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by) VALUES
    -- PERSONAL 15
    ('개인 업무 정리',        '주간 업무 정리',       'PERSONAL', 10, NULL, DATE_TRUNC('day', NOW()) + INTERVAL '9 hours',   DATE_TRUNC('day', NOW()) + INTERVAL '10 hours',  FALSE, '#6b7280', '자리',        'user1'),
    ('점심 약속',             'ABC 고객 미팅',        'PERSONAL', 10, NULL, NOW() + INTERVAL '1 day 2 hours', NOW() + INTERVAL '1 day 3 hours', FALSE, '#f59e0b', '강남 파스타', 'user1'),
    ('치과 예약',             '정기 검진',            'PERSONAL', 10, NULL, NOW() + INTERVAL '2 days 1 hour', NOW() + INTERVAL '2 days 2 hours', FALSE, '#f59e0b', '연세치과',    'user1'),
    ('피트니스',              'PT 수업',              'PERSONAL', 10, NULL, NOW() + INTERVAL '3 days 12 hours', NOW() + INTERVAL '3 days 13 hours', FALSE, '#10b981', '센터',        'user1'),
    ('가족 저녁',             '부모님 방문',          'PERSONAL', 10, NULL, NOW() + INTERVAL '4 days 10 hours', NOW() + INTERVAL '4 days 12 hours', FALSE, '#ec4899', '본가',         'user1'),
    ('독서 모임',             '4월 도서 토론',         'PERSONAL', 10, NULL, NOW() + INTERVAL '5 days 1 hour',  NOW() + INTERVAL '5 days 3 hours', FALSE, '#8b5cf6', '스타벅스',    'user1'),
    ('연차 휴가',             '봄맞이 휴가',           'PERSONAL', 10, NULL, NOW() + INTERVAL '7 days',         NOW() + INTERVAL '9 days',         TRUE,  '#6b7280', '',            'user1'),
    ('영화 예매',             '오펜하이머',            'PERSONAL', 10, NULL, NOW() + INTERVAL '6 days 10 hours', NOW() + INTERVAL '6 days 13 hours', FALSE, '#a78bfa', 'CGV',         'user1'),
    ('미용실 예약',           '커트',                  'PERSONAL', 10, NULL, NOW() + INTERVAL '10 days 3 hours', NOW() + INTERVAL '10 days 4 hours', FALSE, '#f59e0b', '살롱',        'user1'),
    ('친구 생일',             '생일 축하',             'PERSONAL', 10, NULL, NOW() + INTERVAL '12 days 10 hours', NOW() + INTERVAL '12 days 14 hours', FALSE, '#ec4899', '이태원',      'user1'),
    ('사이드 프로젝트 작업',  'Pet project',           'PERSONAL', 10, NULL, NOW() + INTERVAL '14 days 11 hours', NOW() + INTERVAL '14 days 15 hours', FALSE, '#3b82f6', '자택',        'user1'),
    ('세차',                  '정기 세차',             'PERSONAL', 10, NULL, NOW() + INTERVAL '16 days 2 hours',  NOW() + INTERVAL '16 days 3 hours',  FALSE, '#6b7280', '세차장',      'user1'),
    ('병원',                  '알러지 검사',           'PERSONAL', 10, NULL, NOW() + INTERVAL '18 days 1 hour',   NOW() + INTERVAL '18 days 2 hours',  FALSE, '#ef4444', '내과',        'user1'),
    ('쇼핑',                  '봄옷 쇼핑',             'PERSONAL', 10, NULL, NOW() + INTERVAL '20 days 4 hours',  NOW() + INTERVAL '20 days 6 hours',  FALSE, '#ec4899', '백화점',      'user1'),
    ('가족 여행',             '제주도 주말',           'PERSONAL', 10, NULL, NOW() + INTERVAL '22 days',          NOW() + INTERVAL '24 days',          TRUE,  '#10b981', '제주',        'user1'),

    -- DEPT 15 (개발본부/FE팀 위주로 user1 이 속한 부서 중심)
    ('FE팀 데일리 스탠드업',  '매일 오전 스탠드업',    'DEPT',     10, 31, DATE_TRUNC('day', NOW()) + INTERVAL '10 hours', DATE_TRUNC('day', NOW()) + INTERVAL '10 hours 15 minutes', FALSE, '#10b981', 'FE팀 회의실', 'fe.lead'),
    ('FE팀 스프린트 리뷰',    '2주 스프린트 리뷰',     'DEPT',     10, 31, NOW() + INTERVAL '2 days 5 hours',  NOW() + INTERVAL '2 days 6 hours', FALSE, '#10b981', 'FE팀 회의실', 'fe.lead'),
    ('BE팀 코드 리뷰',        'PR 리뷰 세션',          'DEPT',     10, 32, NOW() + INTERVAL '3 days 5 hours',  NOW() + INTERVAL '3 days 6 hours', FALSE, '#8b5cf6', 'BE팀 회의실', 'be.lead'),
    ('개발본부 월간회의',     '본부 전체 모임',        'DEPT',     10, 30, NOW() + INTERVAL '5 days 9 hours',  NOW() + INTERVAL '5 days 11 hours', FALSE, '#3b82f6', '대회의실',    'dev.head'),
    ('인프라팀 릴리즈',       '프로덕션 배포',         'DEPT',     10, 33, NOW() + INTERVAL '7 days 15 hours', NOW() + INTERVAL '7 days 17 hours', FALSE, '#ef4444', '오퍼레이션',  'infra.lead'),
    ('영업1팀 주간회의',      '실적 공유',             'DEPT',     10, 21, NOW() + INTERVAL '1 day 4 hours',   NOW() + INTERVAL '1 day 5 hours',  FALSE, '#f59e0b', '영업실',      'sales1.lead'),
    ('마케팅팀 브레인스토밍', 'Q2 캠페인 아이디어',    'DEPT',     10, 23, NOW() + INTERVAL '4 days 3 hours',  NOW() + INTERVAL '4 days 5 hours', FALSE, '#ec4899', '크리에이티브룸','mkt.lead'),
    ('인사팀 면접',           '경력 FE 개발자 면접',   'DEPT',     10, 11, NOW() + INTERVAL '6 days 4 hours',  NOW() + INTERVAL '6 days 5 hours', FALSE, '#06b6d4', 'HR 면접실',   'hr.lead'),
    ('재무팀 월결산 마감',    '월결산 회의',           'DEPT',     10, 12, NOW() + INTERVAL '8 days 14 hours', NOW() + INTERVAL '8 days 16 hours', FALSE, '#6366f1', '재무팀',      'mgt.head'),
    ('총무팀 워크샵 준비',    '워크샵 실무회의',       'DEPT',     10, 13, NOW() + INTERVAL '10 days 5 hours', NOW() + INTERVAL '10 days 6 hours', FALSE, '#06b6d4', '총무팀',      'ga.lead'),
    ('FE+디자인 공동세션',    'UI 리뷰',               'DEPT',     10, 31, NOW() + INTERVAL '11 days 3 hours', NOW() + INTERVAL '11 days 4 hours', FALSE, '#10b981', '5층 라운지',  'fe.lead'),
    ('BE+인프라 공동세션',    'Kafka 도입 준비',       'DEPT',     10, 32, NOW() + INTERVAL '13 days 6 hours', NOW() + INTERVAL '13 days 7 hours', FALSE, '#8b5cf6', '컨퍼런스룸',  'be.lead'),
    ('개발 전체 Town Hall',   '개발본부 분기 발표',    'DEPT',     10, 30, NOW() + INTERVAL '15 days 14 hours', NOW() + INTERVAL '15 days 16 hours', FALSE, '#3b82f6', '대강당',      'dev.head'),
    ('영업2팀 신규 계약 보고','신규 3건 보고',          'DEPT',     10, 22, NOW() + INTERVAL '17 days 3 hours', NOW() + INTERVAL '17 days 4 hours', FALSE, '#f59e0b', '영업실2',     'sales2.lead'),
    ('경영지원 정기회의',     '본부 정기회의',          'DEPT',     10, 10, NOW() + INTERVAL '20 days 9 hours', NOW() + INTERVAL '20 days 11 hours', FALSE, '#6b7280', '경영지원실',  'mgt.head'),

    -- COMPANY 10
    ('전사 CEO 메시지',       '월간 CEO 메시지',        'COMPANY', 1, NULL, DATE_TRUNC('day', NOW()) + INTERVAL '14 hours', DATE_TRUNC('day', NOW()) + INTERVAL '15 hours', FALSE, '#3b82f6', '대강당',         'admin'),
    ('전사 안전교육',         '4월 의무 교육',          'COMPANY', 1, NULL, NOW() + INTERVAL '3 days 5 hours', NOW() + INTERVAL '3 days 7 hours', FALSE, '#ef4444', '대강당',         'admin'),
    ('Q1 실적 발표',          '분기 결산 발표',         'COMPANY', 1, NULL, NOW() + INTERVAL '6 days 9 hours', NOW() + INTERVAL '6 days 11 hours', FALSE, '#6366f1', '본사 컨벤션홀', 'admin'),
    ('신규 입사자 환영회',    '4월 신규 입사자 5명',    'COMPANY', 1, NULL, NOW() + INTERVAL '9 days 17 hours', NOW() + INTERVAL '9 days 19 hours', FALSE, '#10b981', '로비',           'admin'),
    ('전사 워크샵',           '2분기 전사 워크샵',      'COMPANY', 1, NULL, NOW() + INTERVAL '14 days',         NOW() + INTERVAL '15 days',         TRUE,  '#a78bfa', '양평 리조트',    'admin'),
    ('커뮤니케이션 세션',     '익명 Q&A with CEO',      'COMPANY', 1, NULL, NOW() + INTERVAL '18 days 16 hours', NOW() + INTERVAL '18 days 17 hours', FALSE, '#ec4899', '온라인',         'admin'),
    ('정기 주주총회',         '2026 정기 주총',         'COMPANY', 1, NULL, NOW() + INTERVAL '22 days 9 hours',  NOW() + INTERVAL '22 days 12 hours', FALSE, '#1e40af', '본사 9층',       'admin'),
    ('전사 봉사활동',         '연탄 나눔 봉사',          'COMPANY', 1, NULL, NOW() + INTERVAL '25 days',          NOW() + INTERVAL '25 days 6 hours', FALSE, '#10b981', '성북구',          'admin'),
    ('창립기념일',            '창립 15주년',             'COMPANY', 1, NULL, NOW() + INTERVAL '28 days',          NOW() + INTERVAL '28 days',         TRUE,  '#f59e0b', '본사 전체',      'admin'),
    ('전사 해커톤',           '48시간 해커톤',           'COMPANY', 1, NULL, NOW() + INTERVAL '30 days 9 hours', NOW() + INTERVAL '32 days 9 hours', FALSE, '#8b5cf6', '지하 라운지',    'admin');

-- ── Data-4: 공통코드 확장 ──
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order) VALUES
    ('APPROVAL_STATUS','DRAFT',       '임시저장', 1),
    ('APPROVAL_STATUS','PENDING',     '대기',     2),
    ('APPROVAL_STATUS','IN_PROGRESS', '진행',     3),
    ('APPROVAL_STATUS','APPROVED',    '승인',     4),
    ('APPROVAL_STATUS','REJECTED',    '반려',     5),
    ('APPROVAL_STATUS','WITHDRAWN',   '회수',     6),
    ('FORM_CODE','LEAVE',    '휴가신청서',  1),
    ('FORM_CODE','EXPENSE',  '지출결의서',  2),
    ('FORM_CODE','PURCHASE', '구매요청서',  3),
    ('FORM_CODE','BIZTRIP',  '출장신청서',  4),
    ('FORM_CODE','CONTRACT', '계약검토서',  5),
    ('FORM_CODE','HR',       '인사품의서',  6),
    ('FORM_CODE','IT',       'IT자산신청', 7),
    ('NOTIF_TYPE','SYSTEM',  '시스템',   1),
    ('NOTIF_TYPE','APPROVAL','결재',     2),
    ('NOTIF_TYPE','BOARD',   '게시판',   3),
    ('NOTIF_TYPE','MENTION', '언급',     4),
    ('NOTIF_TYPE','SCHEDULE','일정',     5)
ON CONFLICT (group_cd, code) DO NOTHING;

-- ── Data-4b: i18n 메시지 확장 ──
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES
    ('label.search',   'ko', 'LABEL',   '검색'),
    ('label.save',     'ko', 'LABEL',   '저장'),
    ('label.cancel',   'ko', 'LABEL',   '취소'),
    ('label.delete',   'ko', 'LABEL',   '삭제'),
    ('label.confirm',  'ko', 'LABEL',   '확인'),
    ('msg.save.success','ko','MESSAGE', '저장되었습니다.'),
    ('msg.delete.confirm','ko','MESSAGE','삭제하시겠습니까?'),
    ('msg.noData',     'ko', 'MESSAGE', '데이터가 없습니다.'),
    ('label.search',   'en', 'LABEL',   'Search'),
    ('label.save',     'en', 'LABEL',   'Save'),
    ('label.cancel',   'en', 'LABEL',   'Cancel'),
    ('label.delete',   'en', 'LABEL',   'Delete'),
    ('label.confirm',  'en', 'LABEL',   'Confirm'),
    ('msg.save.success','en','MESSAGE', 'Saved successfully.'),
    ('msg.delete.confirm','en','MESSAGE','Delete?'),
    ('msg.noData',     'en', 'MESSAGE', 'No data.')
ON CONFLICT (msg_key, locale) DO NOTHING;

-- ── Data-4c: 알림 25건 ──
INSERT INTO platform_v3.cm_notification (recipient_id, doc_id, notification_type, channel, title, content, is_read, created_at) VALUES
    (10, NULL, 'SYSTEM',   'WEB', '포털 v3 에 오신 것을 환영합니다',     '첫 로그인 환영',             'N', NOW() - INTERVAL '5 minutes'),
    (10, 1001, 'APPROVAL', 'WEB', '결재 요청 — 연차 휴가 신청서',         '서프론님이 기안했습니다',     'N', NOW() - INTERVAL '30 minutes'),
    (10, 1002, 'APPROVAL', 'WEB', '결재 요청 — 출장 신청서',               '결재 대기',                   'N', NOW() - INTERVAL '1 hour'),
    (10, 1004, 'APPROVAL', 'WEB', '결재 요청 — 노트북 구매',               '결재 대기',                   'N', NOW() - INTERVAL '1 hour 30 minutes'),
    (10, NULL, 'BOARD',    'WEB', '새 공지: 4월 전사 안전교육',             '필참 공지',                   'N', NOW() - INTERVAL '2 hours'),
    (10, NULL, 'BOARD',    'WEB', '새 공지: 사내 보안 정책 개정',           'VPN 이중인증',                 'N', NOW() - INTERVAL '3 hours'),
    (10, NULL, 'MENTION',  'WEB', '@user1 점심 같이?',                      '마케팅팀 Ella Choi',          'N', NOW() - INTERVAL '4 hours'),
    (10, NULL, 'SCHEDULE', 'WEB', '일정 알림: FE팀 스프린트 리뷰',          '2시간 후 시작',               'N', NOW() - INTERVAL '5 hours'),
    (10, NULL, 'SCHEDULE', 'WEB', '일정 알림: 전사 CEO 메시지',             '14:00 대강당',                'N', NOW() - INTERVAL '6 hours'),
    (10, 1003, 'APPROVAL', 'WEB', '결재 승인 — 3월 경비 정산',              '승인 완료',                   'Y', NOW() - INTERVAL '1 day'),
    (10, NULL, 'BOARD',    'WEB', '내 게시글에 댓글이 달렸습니다',         '점심 맛집 추천',              'Y', NOW() - INTERVAL '1 day 2 hours'),
    (10, NULL, 'MENTION',  'WEB', '@user1 주말 풋살 참여 가능?',            '자유게시판 댓글',             'N', NOW() - INTERVAL '1 day 4 hours'),
    (10, NULL, 'SYSTEM',   'WEB', '비밀번호 만료 예정',                      '30일 이내 변경',              'N', NOW() - INTERVAL '1 day 6 hours'),
    (10, 1005, 'APPROVAL', 'WEB', '결재 요청 — 신입사원 채용',              '결재 대기',                   'N', NOW() - INTERVAL '1 day 8 hours'),
    (10, 1006, 'APPROVAL', 'WEB', '결재 진행 — Datadog 계약',               '1차 승인 완료',               'N', NOW() - INTERVAL '1 day 10 hours'),
    (10, NULL, 'SCHEDULE', 'WEB', '일정 알림: 연차 휴가 D-7',                '봄맞이 휴가 예정',            'N', NOW() - INTERVAL '1 day 12 hours'),
    (10, NULL, 'BOARD',    'WEB', '[개발본부] 주간 싱크업 회의록 업로드',  '회의록 확인',                 'N', NOW() - INTERVAL '2 days'),
    (10, NULL, 'BOARD',    'WEB', '[FE팀] Vue 3.5 마이그레이션 가이드',     '신규 게시글',                 'Y', NOW() - INTERVAL '2 days 4 hours'),
    (10, 1008, 'APPROVAL', 'WEB', '결재 반려 — 워크샵 장소 대관',            '반려 사유 확인 필요',         'N', NOW() - INTERVAL '2 days 6 hours'),
    (10, NULL, 'SCHEDULE', 'WEB', '일정 알림: 전사 워크샵 D-14',             '2분기 워크샵 예정',           'Y', NOW() - INTERVAL '3 days'),
    (10, NULL, 'SYSTEM',   'WEB', 'MinIO 저장소 사용량 80%',                 '정리 필요',                   'N', NOW() - INTERVAL '3 days 4 hours'),
    (10, NULL, 'MENTION',  'WEB', '@user1 스터디 참여하시겠어요?',           '독서모임 초대',               'Y', NOW() - INTERVAL '4 days'),
    (10, 1007, 'APPROVAL', 'WEB', '결재 요청 — Figma 라이선스 신청',         '결재 대기',                   'N', NOW() - INTERVAL '4 days 6 hours'),
    (10, NULL, 'BOARD',    'WEB', '[FE팀] 디자인 시스템 v2 업로드',          '자료실 신규',                 'N', NOW() - INTERVAL '5 days'),
    (10, NULL, 'SYSTEM',   'WEB', '시스템 점검 안내',                        '4/19 23:00 정전',             'N', NOW() - INTERVAL '6 days');

-- ── Data-5: 결재 문서 DB 테이블 + 25건 ──
CREATE TABLE IF NOT EXISTS platform_v3.ap_document (
    doc_id        BIGSERIAL PRIMARY KEY,
    doc_title     VARCHAR(256) NOT NULL,
    form_code     VARCHAR(32) NOT NULL,
    drafter_no    VARCHAR(32) NOT NULL,
    drafter_name  VARCHAR(64) NOT NULL,
    drafter_dept  VARCHAR(64),
    status        VARCHAR(16) NOT NULL,
    content       TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ap_document_status  ON platform_v3.ap_document(status);
CREATE INDEX IF NOT EXISTS idx_ap_document_drafter ON platform_v3.ap_document(drafter_no);

CREATE TABLE IF NOT EXISTS platform_v3.ap_approval_line (
    line_id       BIGSERIAL PRIMARY KEY,
    doc_id        BIGINT NOT NULL REFERENCES platform_v3.ap_document(doc_id) ON DELETE CASCADE,
    step_order    INT NOT NULL,
    approver_no   VARCHAR(32) NOT NULL,
    approver_name VARCHAR(64) NOT NULL,
    role          VARCHAR(32),
    status        VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    comment       TEXT,
    acted_at      TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_ap_line_doc ON platform_v3.ap_approval_line(doc_id);

INSERT INTO platform_v3.ap_document (doc_title, form_code, drafter_no, drafter_name, drafter_dept, status, content, created_at) VALUES
    ('2026-04 연차 휴가 신청서',        'LEAVE',    'E0032', '서프론', '프론트엔드팀', 'IN_PROGRESS', '4/22~4/24 (3일) 연차 신청.',                     NOW() - INTERVAL '2 hours'),
    ('ABC 고객 방문 출장 신청',          'BIZTRIP',  'E0032', '서프론', '프론트엔드팀', 'PENDING',     '4/20 부산 ABC社 방문.',                           NOW() - INTERVAL '3 hours'),
    ('3월 경비 정산 지출결의',           'EXPENSE',  'E0032', '서프론', '프론트엔드팀', 'APPROVED',    '식대 120,000 교통비 45,000 총 165,000원.',       NOW() - INTERVAL '1 day'),
    ('개발팀 노트북 2대 구매요청',       'PURCHASE', 'E0031', '남프론', '프론트엔드팀', 'PENDING',     'MacBook Pro M3 16" x 2대 신규 입사자용.',        NOW() - INTERVAL '4 hours'),
    ('신입사원 채용 품의서',             'HR',       'E0011', '이인사', '인사팀',       'IN_PROGRESS', 'FE 경력 2명 채용 품의.',                          NOW() - INTERVAL '5 hours'),
    ('Datadog 연간 라이선스 계약',        'CONTRACT', 'E0036', '노인프', '인프라팀',    'IN_PROGRESS', 'Datadog Pro 플랜 연 20,000 USD.',                  NOW() - INTERVAL '6 hours'),
    ('Figma Enterprise 플랜 신청',        'IT',       'E0031', '남프론', '프론트엔드팀','PENDING',     '디자인 팀 10석 Enterprise.',                      NOW() - INTERVAL '7 hours'),
    ('하계 워크샵 장소 대관 품의',        'PURCHASE', 'E0010', '박본부', '경영지원본부','REJECTED',    '5/20~21 양평 리조트 80명 대관.',                  NOW() - INTERVAL '2 days'),
    ('모니터 2대 추가 요청',              'IT',       'E0033', '배프론', '프론트엔드팀','DRAFT',       '듀얼 모니터 환경 구축.',                          NOW() - INTERVAL '3 days'),
    ('경력 개발자 1명 채용 품의',         'HR',       'E0011', '이인사', '인사팀',      'APPROVED',    '시니어 BE 1명 채용.',                             NOW() - INTERVAL '5 days'),
    ('AWS 크레딧 구매요청',               'PURCHASE', 'E0036', '노인프', '인프라팀',    'IN_PROGRESS', '프로덕션 증설용 50,000 USD 크레딧.',              NOW() - INTERVAL '1 day 2 hours'),
    ('일본 출장 신청 (도쿄)',             'BIZTRIP',  'E0034', '강백엔', '백엔드팀',    'PENDING',     '4/28~5/2 파트너사 미팅.',                         NOW() - INTERVAL '1 day 5 hours'),
    ('IDC 이전 계약 검토',                'CONTRACT', 'E0036', '노인프', '인프라팀',    'IN_PROGRESS', '새 IDC 이전 계약 법무 검토.',                     NOW() - INTERVAL '1 day 8 hours'),
    ('복지 포인트 승인',                  'EXPENSE',  'E0011', '이인사', '인사팀',      'APPROVED',    'Q1 복지 포인트 직원당 300,000원.',                NOW() - INTERVAL '6 days'),
    ('콘퍼런스 참석 신청',                'BIZTRIP',  'E0031', '남프론', '프론트엔드팀','APPROVED',    'JSConf Asia 2026 참석.',                          NOW() - INTERVAL '7 days'),
    ('사무용품 구매',                     'PURCHASE', 'E0013', '장총무', '총무팀',      'APPROVED',    '4월 사무용품 일괄 구매 250,000원.',               NOW() - INTERVAL '8 days'),
    ('교육비 지원 신청',                  'EXPENSE',  'E0032', '서프론', '프론트엔드팀','APPROVED',    '온라인 강의 구매 180,000원.',                     NOW() - INTERVAL '9 days'),
    ('회의실 예약 시스템 도입',           'IT',       'E0013', '장총무', '총무팀',      'WITHDRAWN',   '예산 재검토 후 재상신 예정.',                     NOW() - INTERVAL '10 days'),
    ('영문 문서 번역 외주',               'CONTRACT', 'E0031', '남프론', '프론트엔드팀','PENDING',     '제품 소개서 영문화.',                             NOW() - INTERVAL '11 days'),
    ('태국 출장 신청',                    'BIZTRIP',  'E0021', '윤영업', '영업1팀',    'APPROVED',    '방콕 고객 방문 5일.',                             NOW() - INTERVAL '12 days'),
    ('서버실 CCTV 증설',                  'PURCHASE', 'E0036', '노인프', '인프라팀',    'APPROVED',    '보안 강화 CCTV 4대 추가.',                        NOW() - INTERVAL '13 days'),
    ('휴가 3일 (병가)',                   'LEAVE',    'E0035', '임백엔', '백엔드팀',    'APPROVED',    '병가 3일 신청.',                                  NOW() - INTERVAL '14 days'),
    ('신입 온보딩 매뉴얼 제작',           'HR',       'E0011', '이인사', '인사팀',      'DRAFT',       '신규 입사자 온보딩 매뉴얼 제작 품의.',           NOW() - INTERVAL '15 days'),
    ('SaaS 요금 갱신 (Slack)',             'CONTRACT', 'E0010', '박본부', '경영지원본부','APPROVED',    '연간 약 8,000 USD.',                              NOW() - INTERVAL '16 days'),
    ('QA 장비 증설',                      'PURCHASE', 'E0035', '임백엔', '백엔드팀',    'PENDING',     '테스트용 노트북 3대.',                            NOW() - INTERVAL '17 days');

-- 결재선 자동 생성 (3단 결재: 팀장→본부장→CEO)
INSERT INTO platform_v3.ap_approval_line (doc_id, step_order, approver_no, approver_name, role, status, acted_at)
SELECT d.doc_id, 1, 'E0031', '남프론', 'TEAM_LEADER', 'APPROVED', d.created_at + INTERVAL '1 hour' FROM platform_v3.ap_document d WHERE d.drafter_no IN ('E0032','E0033');
INSERT INTO platform_v3.ap_approval_line (doc_id, step_order, approver_no, approver_name, role, status, acted_at)
SELECT d.doc_id, 2, 'E0030', '오개발', 'DIVISION_HEAD', CASE WHEN d.status IN ('APPROVED','REJECTED') THEN d.status ELSE 'PENDING' END, CASE WHEN d.status IN ('APPROVED','REJECTED') THEN d.created_at + INTERVAL '3 hours' ELSE NULL END
FROM platform_v3.ap_document d WHERE d.drafter_no IN ('E0032','E0033');

COMMIT;

-- ── 카운트 리포트 ──
SELECT 'org_department' AS t, COUNT(*) FROM platform_v3.org_department
UNION ALL SELECT 'org_employee', COUNT(*) FROM platform_v3.org_employee
UNION ALL SELECT 'bd_post', COUNT(*) FROM platform_v3.bd_post
UNION ALL SELECT 'cal_event', COUNT(*) FROM platform_v3.cal_event
UNION ALL SELECT 'cm_notification', COUNT(*) FROM platform_v3.cm_notification
UNION ALL SELECT 'cm_code', COUNT(*) FROM platform_v3.cm_code
UNION ALL SELECT 'cm_i18n_message', COUNT(*) FROM platform_v3.cm_i18n_message
UNION ALL SELECT 'ap_document', COUNT(*) FROM platform_v3.ap_document
UNION ALL SELECT 'ap_approval_line', COUNT(*) FROM platform_v3.ap_approval_line
ORDER BY t;
