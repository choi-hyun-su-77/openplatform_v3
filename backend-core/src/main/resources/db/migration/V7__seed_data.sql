-- Flyway 자동 시드 — expand_test_data.sql 의 중복 회피 버전
-- V2~V6 의 테이블이 존재함을 전제로 삽입만 수행 (ON CONFLICT DO NOTHING)

-- 부서 확장
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

-- 직원 30명
INSERT INTO platform_v3.org_employee (employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status) VALUES
    ('E0001','김대표',1,1,'ceo@v3.local','010-0000-0001','admin','2020-01-01','ACTIVE'),
    ('E0010','박본부',10,2,'mgt.head@v3.local','010-0000-0010',NULL,'2020-03-01','ACTIVE'),
    ('E0011','이인사',11,3,'hr.lead@v3.local','010-0000-0011',NULL,'2021-02-01','ACTIVE'),
    ('E0012','최인사',11,4,'hr1@v3.local','010-0000-0012',NULL,'2022-05-01','ACTIVE'),
    ('E0020','정사업',20,2,'biz.head@v3.local','010-0000-0020',NULL,'2020-04-01','ACTIVE'),
    ('E0021','윤영업',21,3,'sales1@v3.local','010-0000-0021',NULL,'2021-06-01','ACTIVE'),
    ('E0022','한영업',21,4,'sales1a@v3.local','010-0000-0022',NULL,'2022-07-01','ACTIVE'),
    ('E0030','오개발',30,2,'dev.head@v3.local','010-0000-0030',NULL,'2020-05-01','ACTIVE'),
    ('E0031','남프론',31,3,'fe.lead@v3.local','010-0000-0031',NULL,'2021-08-01','ACTIVE'),
    ('E0032','서프론',31,4,'fe1@v3.local','010-0000-0032','user1','2022-09-01','ACTIVE'),
    ('E0033','배프론',31,5,'fe2@v3.local','010-0000-0033',NULL,'2023-10-01','ACTIVE'),
    ('E0034','강백엔',32,3,'be.lead@v3.local','010-0000-0034',NULL,'2021-09-01','ACTIVE'),
    ('E0035','임백엔',32,4,'be1@v3.local','010-0000-0035',NULL,'2022-10-01','ACTIVE'),
    ('E0036','노인프',33,3,'infra.lead@v3.local','010-0000-0036',NULL,'2021-11-01','ACTIVE'),
    ('E0037','장인프',33,5,'infra1@v3.local','010-0000-0037',NULL,'2023-12-01','ACTIVE')
ON CONFLICT (employee_no) DO NOTHING;
