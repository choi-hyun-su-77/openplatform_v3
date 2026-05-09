-- ============================================================
-- openplatform_v3 [main] — data.sql (idempotent merge)
-- Generated: 2026-05-10 08:36:28
-- DB: platform_v3 @ v3-postgres
-- Mode: INSERT ... ON CONFLICT DO NOTHING (기존 데이터 보존)
-- ============================================================
--
-- PostgreSQL database dump
--

\restrict KqWFIfNXwDKdo8oNsPhLTw0v7o8U29d24xdYC9Al4WQIT8desBWcBneUzPEcjjr

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: ap_document; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE platform_v3.ap_document DISABLE TRIGGER ALL;

INSERT INTO platform_v3.ap_document (doc_id, doc_title, form_code, drafter_no, drafter_name, drafter_dept, status, content, amount, parent_doc_id, version, created_at, updated_at) VALUES (1, '서울 고객사 출장 (4/20~4/21)', 'BIZTRIP', 'E0001', '김대표', '경영지원팀', 'APPROVED', '목적: ㈜한국테크 2차 미팅 및 계약 검토\n기간: 4/20(월)~4/21(화)\n장소: 서울 강남구\n예상비용: 350,000원', 350000, NULL, 1, '2026-04-21 19:06:51.544784+00', '2026-04-23 19:06:51.544784+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ap_document (doc_id, doc_title, form_code, drafter_no, drafter_name, drafter_dept, status, content, amount, parent_doc_id, version, created_at, updated_at) VALUES (2, '연차 사용 (5/5~5/6)', 'LEAVE', 'E0020', '이영희', '개발팀', 'PENDING', '사유: 개인 사유\n기간: 5/5(월)~5/6(화) 2일\n비상연락처: 010-xxxx-xxxx', 0, NULL, 1, '2026-04-25 19:06:51.544784+00', '2026-04-25 19:06:51.544784+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ap_document (doc_id, doc_title, form_code, drafter_no, drafter_name, drafter_dept, status, content, amount, parent_doc_id, version, created_at, updated_at) VALUES (3, '4월 프로젝트 서버 비용 결의', 'EXPENSE', 'E0001', '김대표', '경영지원팀', 'IN_PROGRESS', 'AWS EC2 + RDS 4월분 비용 정산\n\n- EC2 m5.xlarge x2: 580,000원\n- RDS r5.large: 420,000원\n- S3 + CloudFront: 150,000원\n합계: 1,150,000원', 1150000, NULL, 1, '2026-04-24 19:06:51.544784+00', '2026-04-25 19:06:51.544784+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.ap_document ENABLE TRIGGER ALL;

--
-- Data for Name: ap_approval_line; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.ap_approval_line DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.ap_approval_line ENABLE TRIGGER ALL;

--
-- Data for Name: ap_attachment; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.ap_attachment DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.ap_attachment ENABLE TRIGGER ALL;

--
-- Data for Name: ap_delegation; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.ap_delegation DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.ap_delegation ENABLE TRIGGER ALL;

--
-- Data for Name: at_attendance; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.at_attendance DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.at_attendance ENABLE TRIGGER ALL;

--
-- Data for Name: at_leave_balance; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.at_leave_balance DISABLE TRIGGER ALL;

INSERT INTO platform_v3.at_leave_balance (balance_id, employee_no, year, total_days, used_days, carry_over, updated_at) VALUES (1, 'E0001', 2026, 15.0, 0.0, 0.0, '2026-04-26 19:06:51.607868+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.at_leave_balance (balance_id, employee_no, year, total_days, used_days, carry_over, updated_at) VALUES (2, 'E0002', 2026, 12.0, 0.0, 0.0, '2026-04-26 19:06:51.607868+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.at_leave_balance (balance_id, employee_no, year, total_days, used_days, carry_over, updated_at) VALUES (3, 'E0003', 2026, 12.0, 0.0, 0.0, '2026-04-26 19:06:51.607868+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.at_leave_balance (balance_id, employee_no, year, total_days, used_days, carry_over, updated_at) VALUES (4, 'E0004', 2026, 12.0, 0.0, 0.0, '2026-04-26 19:06:51.607868+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.at_leave_balance ENABLE TRIGGER ALL;

--
-- Data for Name: at_leave_request; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.at_leave_request DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.at_leave_request ENABLE TRIGGER ALL;

--
-- Data for Name: bd_attachment; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.bd_attachment DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.bd_attachment ENABLE TRIGGER ALL;

--
-- Data for Name: bd_comment; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.bd_comment DISABLE TRIGGER ALL;

INSERT INTO platform_v3.bd_comment (comment_id, post_id, parent_id, content, author_no, author_name, created_at, updated_at, deleted) VALUES (1, 8, NULL, '좋은 정보 감사합니다!', 'E0020', '이영희', '2026-04-24 19:06:51.544784+00', '2026-04-24 19:06:51.544784+00', false) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_comment (comment_id, post_id, parent_id, content, author_no, author_name, created_at, updated_at, deleted) VALUES (2, 9, NULL, '교육 링크 공유해 주실 수 있나요?', 'E0020', '이영희', '2026-04-20 19:06:51.544784+00', '2026-04-20 19:06:51.544784+00', false) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_comment (comment_id, post_id, parent_id, content, author_no, author_name, created_at, updated_at, deleted) VALUES (3, 11, NULL, '강남역 3번 출구 "목화반점" 추천합니다. 룸 있고 가성비 좋아요.', 'E0010', '박과장', '2026-04-24 19:06:51.544784+00', '2026-04-24 19:06:51.544784+00', false) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_comment (comment_id, post_id, parent_id, content, author_no, author_name, created_at, updated_at, deleted) VALUES (4, 6, NULL, '파스타 진짜 맛있었어요! 카르보나라 추천합니다.', 'E0010', '박과장', '2026-04-25 19:06:51.544784+00', '2026-04-25 19:06:51.544784+00', false) ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.bd_comment ENABLE TRIGGER ALL;

--
-- Data for Name: org_department; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.org_department DISABLE TRIGGER ALL;

INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (1, 'HQ', '본사', NULL, 1, 1, 'Y', '2026-04-26 19:06:50.903987+00', '2026-04-26 19:06:50.903987+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (10, 'MGT', '경영지원본부', 1, 2, 1, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (11, 'HR', '인사팀', 10, 3, 1, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (12, 'FIN', '재무팀', 10, 3, 2, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (13, 'GA', '총무팀', 10, 3, 3, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (20, 'BIZ', '사업본부', 1, 2, 2, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (21, 'SALES', '영업1팀', 20, 3, 1, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (22, 'SALES2', '영업2팀', 20, 3, 2, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (23, 'MKT', '마케팅팀', 20, 3, 3, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (30, 'DEV', '개발본부', 1, 2, 3, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (31, 'FE', '프론트엔드팀', 30, 3, 1, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (32, 'BE', '백엔드팀', 30, 3, 2, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_department (dept_id, dept_code, dept_name, parent_dept_id, dept_level, sort_order, use_yn, created_at, updated_at) VALUES (33, 'INFRA', '인프라팀', 30, 3, 3, 'Y', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.org_department ENABLE TRIGGER ALL;

--
-- Data for Name: bd_post; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.bd_post DISABLE TRIGGER ALL;

INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (1, 'NOTICE', NULL, '[필독] openplatform v3 런칭 안내', '통합 그룹웨어 v3 가 런칭되었습니다. 메신저/메일/위키/화상회의가 통합되었으니 많은 이용 바랍니다.', 0, 'Y', NULL, 'admin', NULL, NULL, '2026-04-25 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (2, 'NOTICE', NULL, '2026년 2분기 전사 워크샵 공지', '4월 20일 본사 대강당에서 2분기 워크샵을 진행합니다.', 0, 'Y', NULL, 'admin', NULL, NULL, '2026-04-24 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (3, 'NOTICE', NULL, '근태관리 시스템 업데이트 안내', '근태관리가 전자결재와 통합되었습니다.', 0, 'N', NULL, 'admin', NULL, NULL, '2026-04-23 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (4, 'DEPT', 30, '[개발본부] 주간 스탠드업 공지', '매주 월요일 10시', 0, 'N', NULL, 'dev.head', NULL, NULL, '2026-04-26 15:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (5, 'DEPT', 31, '[FE팀] Vue 3.5 업그레이드 스터디', '매주 수요일', 0, 'N', NULL, 'fe.lead', NULL, NULL, '2026-04-26 13:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (6, 'FREE', NULL, '점심 맛집 추천', '본사 근처 맛집 공유합니다.', 0, 'N', NULL, 'user1', NULL, NULL, '2026-04-26 11:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (7, 'FREE', NULL, '사내 동아리 축구팀 모집', '4월 토요일 오전 경기', 0, 'N', NULL, 'user1', NULL, NULL, '2026-04-26 07:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (8, 'NOTICE', NULL, '2026년 2분기 경영방침 안내', '안녕하세요. 2026년 2분기 경영방침을 안내드립니다.\n\n1. 고객 만족도 향상 프로그램 강화\n2. 신규 서비스 런칭 (5월 예정)\n3. 사내 교육 확대\n\n자세한 내용은 첨부 파일을 참고해 주세요.', 142, 'Y', NULL, 'E0001', NULL, NULL, '2026-04-16 19:06:51.544784+00', '2026-04-16 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (9, 'NOTICE', NULL, '정보보안 교육 필수 이수 안내', '전 직원 대상 정보보안 교육을 실시합니다.\n\n- 기간: 4/20 ~ 4/30\n- 방법: LMS 온라인 교육\n- 미이수 시 인사 불이익이 있을 수 있습니다.', 98, 'Y', NULL, 'E0001', NULL, NULL, '2026-04-19 19:06:51.544784+00', '2026-04-19 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (10, 'NOTICE', NULL, '사옥 주차장 공사 안내 (4/25~5/10)', '지하 1층 주차장 방수 공사로 인해 4/25부터 5/10까지 지하 1층 주차가 불가합니다.\n대체 주차장: B동 옥상 주차장을 이용해 주세요.', 76, 'N', NULL, 'E0010', NULL, NULL, '2026-04-21 19:06:51.544784+00', '2026-04-21 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (11, 'GENERAL', NULL, '팀 회식 장소 추천해주세요', '이번 달 팀 회식 장소를 찾고 있습니다.\n강남역 근처로 10~15명 수용 가능한 곳 추천 부탁드립니다.\n예산은 1인당 5만원 내외입니다.', 23, 'N', NULL, 'E0020', NULL, NULL, '2026-04-23 19:06:51.544784+00', '2026-04-23 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (12, 'GENERAL', NULL, '사내 동호회 가입 안내', '사내 동호회 목록입니다:\n\n- 축구: 매주 토요일 오전\n- 등산: 격주 일요일\n- 독서: 매월 마지막 수요일\n- 사진: 매월 2째 토요일\n\n가입 희망 시 총무팀에 문의해 주세요.', 45, 'N', NULL, 'E0010', NULL, NULL, '2026-04-11 19:06:51.544784+00', '2026-04-11 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (13, 'FREE', NULL, '점심 맛집 공유합니다', '회사 앞 새로 오픈한 이탈리안 레스토랑 다녀왔는데 파스타가 정말 맛있습니다.\n런치 세트가 12,000원이고 샐러드도 같이 나옵니다.\n점심시간에 한번 가보세요!', 67, 'N', NULL, 'E0020', NULL, NULL, '2026-04-24 19:06:51.544784+00', '2026-04-24 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (14, 'FREE', NULL, '재택근무 팁 공유', '재택근무 3년차 직장인으로서 생산성 높이는 팁 공유합니다.\n\n1. 오전에 가장 집중력 필요한 업무 먼저\n2. 포모도로 기법 (25분 집중 + 5분 휴식)\n3. 업무 공간과 생활 공간 분리\n4. 점심 후 10분 산책', 34, 'N', NULL, 'E0001', NULL, NULL, '2026-04-18 19:06:51.544784+00', '2026-04-18 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.bd_post (post_id, board_type, dept_id, title, content, view_count, is_pinned, attachments, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (15, 'DEPT', NULL, '개발팀 코드리뷰 가이드라인', '코드리뷰 가이드라인을 정리했습니다.\n\n1. PR은 200줄 이내로 분할\n2. 리뷰어는 24시간 내 피드백\n3. approve 전 CI 통과 필수\n4. 주요 로직 변경 시 설계 문서 첨부', 56, 'N', NULL, 'E0001', NULL, NULL, '2026-04-14 19:06:51.544784+00', '2026-04-14 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.bd_post ENABLE TRIGGER ALL;

--
-- Data for Name: cal_event; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cal_event DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (1, '전사 임원회의', '월간 전사 임원회의', 'COMPANY', 1, NULL, '2026-04-26 21:06:51.169529+00', '2026-04-26 23:06:51.169529+00', false, '#3b82f6', '본사 대회의실', 'admin', NULL, NULL, '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (2, 'FE팀 스프린트 리뷰', '이번 스프린트 리뷰', 'DEPT', 10, 31, '2026-04-27 00:06:51.169529+00', '2026-04-27 01:06:51.169529+00', false, '#10b981', 'FE팀 회의실', 'fe.lead', NULL, NULL, '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (3, '점심 약속 - 고객사', 'ABC 주식회사 방문', 'PERSONAL', 10, NULL, '2026-04-27 19:06:51.169529+00', '2026-04-27 20:06:51.169529+00', false, '#f59e0b', '외부', 'user1', NULL, NULL, '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (4, '분기 리뷰', 'Q1 결산 리뷰', 'COMPANY', 1, NULL, '2026-04-29 19:06:51.169529+00', '2026-04-29 21:06:51.169529+00', false, '#ef4444', '본사 강당', 'admin', NULL, NULL, '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (5, 'BE팀 기술 공유', 'Kafka 도입 검토', 'DEPT', 10, 32, '2026-05-01 19:06:51.169529+00', '2026-05-01 20:06:51.169529+00', false, '#8b5cf6', 'BE팀 회의실', 'be.lead', NULL, NULL, '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (6, '휴가', '연차 휴가', 'PERSONAL', 10, NULL, '2026-05-03 00:00:00+00', '2026-05-05 00:00:00+00', true, '#6b7280', '', 'user1', NULL, NULL, '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (7, '2분기 킥오프 미팅', '전사 2분기 킥오프 미팅. 대회의실 A.', 'COMPANY', 1, 1, '2026-04-28 19:06:51.544784+00', '2026-04-28 21:06:51.544784+00', false, '#3b82f6', NULL, 'E0001', NULL, NULL, '2026-04-26 19:06:51.544784+00', '2026-04-26 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (8, '팀 주간 스탠드업', '매주 월요일 오전 10시 개발팀 스탠드업 미팅', 'DEPT', 1, 1, '2026-04-29 19:06:51.544784+00', '2026-04-29 19:36:51.544784+00', false, '#10b981', NULL, 'E0001', NULL, NULL, '2026-04-26 19:06:51.544784+00', '2026-04-26 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (9, '연차 (김대표)', '개인 연차', 'PERSONAL', 1, 1, '2026-05-03 19:06:51.544784+00', '2026-05-04 19:06:51.544784+00', true, '#f59e0b', NULL, 'E0001', NULL, NULL, '2026-04-26 19:06:51.544784+00', '2026-04-26 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (10, '고객사 미팅', '㈜한국테크 2차 미팅 — 요구사항 확인', 'PERSONAL', 1, 1, '2026-05-02 09:06:51.544784+00', '2026-05-02 11:06:51.544784+00', false, '#ef4444', NULL, 'E0001', NULL, NULL, '2026-04-26 19:06:51.544784+00', '2026-04-26 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (11, '신입사원 OJT', '2026년 신입사원 OJT 교육 (1주간)', 'COMPANY', 1, 1, '2026-05-06 19:06:51.544784+00', '2026-05-10 19:06:51.544784+00', true, '#8b5cf6', NULL, 'E0001', NULL, NULL, '2026-04-26 19:06:51.544784+00', '2026-04-26 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cal_event (event_id, title, description, event_type, owner_id, dept_id, start_dt, end_dt, all_day, color, location, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at) VALUES (12, '분기 성과발표', '2026 Q1 성과 발표회. 강당.', 'COMPANY', 1, 1, '2026-05-12 05:06:51.544784+00', '2026-05-12 07:06:51.544784+00', false, '#06b6d4', NULL, 'E0001', NULL, NULL, '2026-04-26 19:06:51.544784+00', '2026-04-26 19:06:51.544784+00', NULL) ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cal_event ENABLE TRIGGER ALL;

--
-- Data for Name: cm_code; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cm_code DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('BOARD_TYPE', 'NOTICE', '공지사항', 1, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('BOARD_TYPE', 'DEPT', '부서게시판', 2, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('BOARD_TYPE', 'FREE', '자유게시판', 3, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('BOARD_TYPE', 'ARCHIVE', '자료실', 4, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('EVENT_TYPE', 'PERSONAL', '개인', 1, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('EVENT_TYPE', 'DEPT', '부서', 2, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('EVENT_TYPE', 'COMPANY', '회사', 3, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('EMP_STATUS', 'ACTIVE', '재직', 1, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('EMP_STATUS', 'LEAVE', '휴직', 2, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('EMP_STATUS', 'RETIRED', '퇴직', 3, 'Y', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('FORM_CODE', 'LEAVE', '휴가신청서', 1, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('FORM_CODE', 'EXPENSE', '지출결의서', 2, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('FORM_CODE', 'PURCHASE', '구매요청서', 3, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('FORM_CODE', 'BIZTRIP', '출장신청서', 4, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('FORM_CODE', 'CONTRACT', '계약검토서', 5, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('FORM_CODE', 'HR', '인사품의서', 6, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('FORM_CODE', 'IT', 'IT자산신청', 7, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_code (group_cd, code, code_name, sort_order, use_yn, created_at) VALUES ('BOARD_TYPE', 'GENERAL', '일반', 2, 'Y', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cm_code ENABLE TRIGGER ALL;

--
-- Data for Name: cm_holiday; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cm_holiday DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (1, '2026-01-01', '신정', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (2, '2026-02-17', '설날', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (3, '2026-02-18', '설날', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (4, '2026-02-19', '설날', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (5, '2026-03-01', '삼일절', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (6, '2026-05-05', '어린이날', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (7, '2026-05-24', '부처님오신날', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (8, '2026-06-06', '현충일', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (9, '2026-08-15', '광복절', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (10, '2026-09-25', '추석', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (11, '2026-09-26', '추석', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (12, '2026-09-27', '추석', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (13, '2026-10-03', '개천절', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (14, '2026-10-09', '한글날', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_holiday (holiday_id, holiday_date, holiday_name, holiday_type, created_at) VALUES (15, '2026-12-25', '성탄절', 'PUBLIC', '2026-04-26 19:06:51.323712+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cm_holiday ENABLE TRIGGER ALL;

--
-- Data for Name: cm_i18n_message; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cm_i18n_message DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.dashboard', 'ko', 'MENU', '대시보드') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.approval', 'ko', 'MENU', '전자결재') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.board', 'ko', 'MENU', '게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.calendar', 'ko', 'MENU', '캘린더') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.org', 'ko', 'MENU', '조직도') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.messenger', 'ko', 'MENU', '메신저') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.mail', 'ko', 'MENU', '메일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.wiki', 'ko', 'MENU', '위키') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.video', 'ko', 'MENU', '화상회의') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.dashboard', 'en', 'MENU', 'Dashboard') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.approval', 'en', 'MENU', 'Approval') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.board', 'en', 'MENU', 'Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.calendar', 'en', 'MENU', 'Calendar') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.org', 'en', 'MENU', 'Organization') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.messenger', 'en', 'MENU', 'Messenger') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.mail', 'en', 'MENU', 'Mail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.wiki', 'en', 'MENU', 'Wiki') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('menu.video', 'en', 'MENU', 'Video') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('login.title', 'ko', 'LABEL', '통합 그룹웨어') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('login.button', 'ko', 'LABEL', 'Keycloak 로 로그인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.welcome', 'ko', 'LABEL', '환영합니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.today', 'ko', 'LABEL', '오늘 일정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.pending', 'ko', 'LABEL', '미결 결재') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.notice', 'ko', 'LABEL', '최근 공지') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.unread', 'ko', 'LABEL', '읽지 않은 알림') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('login.title', 'en', 'LABEL', 'Groupware Portal') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('login.button', 'en', 'LABEL', 'Sign in with Keycloak') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.welcome', 'en', 'LABEL', 'Welcome') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.today', 'en', 'LABEL', 'Today''s Schedule') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.pending', 'en', 'LABEL', 'Pending Approvals') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.notice', 'en', 'LABEL', 'Recent Notices') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('dashboard.unread', 'en', 'LABEL', 'Unread Notifications') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE', 'ko', 'BUTTON', '저장') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE', 'en', 'BUTTON', 'Save') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE', 'zh', 'BUTTON', '保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE', 'ja', 'BUTTON', '保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CANCEL', 'ko', 'BUTTON', '취소') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CANCEL', 'en', 'BUTTON', 'Cancel') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CANCEL', 'zh', 'BUTTON', '取消') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CANCEL', 'ja', 'BUTTON', 'キャンセル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELETE', 'ko', 'BUTTON', '삭제') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELETE', 'en', 'BUTTON', 'Delete') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELETE', 'zh', 'BUTTON', '删除') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELETE', 'ja', 'BUTTON', '削除') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EDIT', 'ko', 'BUTTON', '수정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EDIT', 'en', 'BUTTON', 'Edit') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EDIT', 'zh', 'BUTTON', '编辑') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EDIT', 'ja', 'BUTTON', '編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD', 'ko', 'BUTTON', '추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD', 'en', 'BUTTON', 'Add') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD', 'zh', 'BUTTON', '添加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD', 'ja', 'BUTTON', '追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SEARCH', 'ko', 'BUTTON', '검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SEARCH', 'en', 'BUTTON', 'Search') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SEARCH', 'zh', 'BUTTON', '搜索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SEARCH', 'ja', 'BUTTON', '検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CLOSE', 'ko', 'BUTTON', '닫기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CLOSE', 'en', 'BUTTON', 'Close') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CLOSE', 'zh', 'BUTTON', '关闭') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CLOSE', 'ja', 'BUTTON', '閉じる') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CONFIRM', 'ko', 'BUTTON', '확인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CONFIRM', 'en', 'BUTTON', 'Confirm') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CONFIRM', 'zh', 'BUTTON', '确认') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CONFIRM', 'ja', 'BUTTON', '確認') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGOUT', 'ko', 'BUTTON', '로그아웃') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGOUT', 'en', 'BUTTON', 'Logout') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGOUT', 'zh', 'BUTTON', '退出') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGOUT', 'ja', 'BUTTON', 'ログアウト') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REFRESH', 'ko', 'BUTTON', '새로고침') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REFRESH', 'en', 'BUTTON', 'Refresh') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REFRESH', 'zh', 'BUTTON', '刷新') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REFRESH', 'ja', 'BUTTON', '更新') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EXPORT', 'ko', 'BUTTON', '내보내기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EXPORT', 'en', 'BUTTON', 'Export') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EXPORT', 'zh', 'BUTTON', '导出') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EXPORT', 'ja', 'BUTTON', 'エクスポート') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DASHBOARD', 'ko', 'MENU', '대시보드') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DASHBOARD', 'en', 'MENU', 'Dashboard') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DASHBOARD', 'zh', 'MENU', '仪表盘') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DASHBOARD', 'ja', 'MENU', 'ダッシュボード') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_APPROVAL', 'ko', 'MENU', '전자결재') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_APPROVAL', 'en', 'MENU', 'Approval') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_APPROVAL', 'zh', 'MENU', '电子审批') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_APPROVAL', 'ja', 'MENU', '電子決裁') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_BOARD', 'ko', 'MENU', '게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_BOARD', 'en', 'MENU', 'Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_BOARD', 'zh', 'MENU', '公告板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_BOARD', 'ja', 'MENU', '掲示板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_CALENDAR', 'ko', 'MENU', '캘린더') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_CALENDAR', 'en', 'MENU', 'Calendar') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_CALENDAR', 'zh', 'MENU', '日历') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_CALENDAR', 'ja', 'MENU', 'カレンダー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ORG', 'ko', 'MENU', '조직도') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ORG', 'en', 'MENU', 'Organization') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ORG', 'zh', 'MENU', '组织架构') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ORG', 'ja', 'MENU', '組織図') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MESSENGER', 'ko', 'MENU', '메신저') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MESSENGER', 'en', 'MENU', 'Messenger') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MESSENGER', 'zh', 'MENU', '即时通讯') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MESSENGER', 'ja', 'MENU', 'メッセンジャー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MAIL', 'ko', 'MENU', '메일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MAIL', 'en', 'MENU', 'Mail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MAIL', 'zh', 'MENU', '邮件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MAIL', 'ja', 'MENU', 'メール') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WIKI', 'ko', 'MENU', '위키') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WIKI', 'en', 'MENU', 'Wiki') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WIKI', 'zh', 'MENU', '维基') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WIKI', 'ja', 'MENU', 'ウィキ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_VIDEO', 'ko', 'MENU', '화상회의') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_VIDEO', 'en', 'MENU', 'Video Call') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_VIDEO', 'zh', 'MENU', '视频会议') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_VIDEO', 'ja', 'MENU', 'ビデオ会議') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX', 'ko', 'LABEL', '결재함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX', 'en', 'LABEL', 'Approval Inbox') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX', 'zh', 'LABEL', '审批箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX', 'ja', 'LABEL', '決裁箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DRAFT', 'ko', 'LABEL', '기안함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DRAFT', 'en', 'LABEL', 'Drafts') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DRAFT', 'zh', 'LABEL', '草稿箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DRAFT', 'ja', 'LABEL', '起案箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PENDING', 'ko', 'LABEL', '대기함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PENDING', 'en', 'LABEL', 'Pending') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PENDING', 'zh', 'LABEL', '待审批') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PENDING', 'ja', 'LABEL', '保留中') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMPLETED', 'ko', 'LABEL', '완료함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMPLETED', 'en', 'LABEL', 'Completed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMPLETED', 'zh', 'LABEL', '已完成') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMPLETED', 'ja', 'LABEL', '完了') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECTED', 'ko', 'LABEL', '반려함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECTED', 'en', 'LABEL', 'Rejected') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECTED', 'zh', 'LABEL', '已退回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECTED', 'ja', 'LABEL', '却下') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT', 'ko', 'LABEL', '상신') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT', 'en', 'LABEL', 'Submit') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT', 'zh', 'LABEL', '提交') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT', 'ja', 'LABEL', '起案') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_APPROVE', 'ko', 'LABEL', '승인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_APPROVE', 'en', 'LABEL', 'Approve') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_APPROVE', 'zh', 'LABEL', '批准') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_APPROVE', 'ja', 'LABEL', '承認') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECT', 'ko', 'LABEL', '반려') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECT', 'en', 'LABEL', 'Reject') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECT', 'zh', 'LABEL', '退回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REJECT', 'ja', 'LABEL', '却下') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_WITHDRAW', 'ko', 'LABEL', '회수') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_WITHDRAW', 'en', 'LABEL', 'Withdraw') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_WITHDRAW', 'zh', 'LABEL', '撤回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_WITHDRAW', 'ja', 'LABEL', '取下げ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE', 'ko', 'LABEL', '대결') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE', 'en', 'LABEL', 'Delegate') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE', 'zh', 'LABEL', '委托') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE', 'ja', 'LABEL', '代決') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_RESUBMIT', 'ko', 'LABEL', '재상신') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_RESUBMIT', 'en', 'LABEL', 'Resubmit') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_RESUBMIT', 'zh', 'LABEL', '重新提交') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_RESUBMIT', 'ja', 'LABEL', '再起案') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DOC_TITLE', 'ko', 'LABEL', '문서 제목') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DOC_TITLE', 'en', 'LABEL', 'Document Title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DOC_TITLE', 'zh', 'LABEL', '文档标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DOC_TITLE', 'ja', 'LABEL', '文書タイトル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORM_CODE', 'ko', 'LABEL', '양식') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORM_CODE', 'en', 'LABEL', 'Form') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORM_CODE', 'zh', 'LABEL', '表单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORM_CODE', 'ja', 'LABEL', '様式') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AMOUNT', 'ko', 'LABEL', '금액') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AMOUNT', 'en', 'LABEL', 'Amount') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AMOUNT', 'zh', 'LABEL', '金额') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AMOUNT', 'ja', 'LABEL', '金額') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DRAFTER', 'ko', 'LABEL', '기안자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DRAFTER', 'en', 'LABEL', 'Drafter') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DRAFTER', 'zh', 'LABEL', '起草人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DRAFTER', 'ja', 'LABEL', '起案者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVER', 'ko', 'LABEL', '결재자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVER', 'en', 'LABEL', 'Approver') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVER', 'zh', 'LABEL', '审批人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVER', 'ja', 'LABEL', '決裁者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE', 'ko', 'LABEL', '결재선') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE', 'en', 'LABEL', 'Approval Line') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE', 'zh', 'LABEL', '审批流程') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE', 'ja', 'LABEL', '決裁ライン') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATTACHMENT', 'ko', 'LABEL', '첨부파일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATTACHMENT', 'en', 'LABEL', 'Attachments') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATTACHMENT', 'zh', 'LABEL', '附件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATTACHMENT', 'ja', 'LABEL', '添付ファイル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_HISTORY', 'ko', 'LABEL', '이력') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_HISTORY', 'en', 'LABEL', 'History') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_HISTORY', 'zh', 'LABEL', '历史记录') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_HISTORY', 'ja', 'LABEL', '履歴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_NOTICE', 'ko', 'LABEL', '공지사항') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_NOTICE', 'en', 'LABEL', 'Notice') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_NOTICE', 'zh', 'LABEL', '公告') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_NOTICE', 'ja', 'LABEL', 'お知らせ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_GENERAL', 'ko', 'LABEL', '일반') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_GENERAL', 'en', 'LABEL', 'General') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_GENERAL', 'zh', 'LABEL', '一般') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_GENERAL', 'ja', 'LABEL', '一般') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FREE', 'ko', 'LABEL', '자유게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FREE', 'en', 'LABEL', 'Free Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FREE', 'zh', 'LABEL', '自由论坛') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FREE', 'ja', 'LABEL', '自由掲示板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DEPT', 'ko', 'LABEL', '부서게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DEPT', 'en', 'LABEL', 'Dept Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DEPT', 'zh', 'LABEL', '部门论坛') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DEPT', 'ja', 'LABEL', '部署掲示板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_TITLE', 'ko', 'LABEL', '제목') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_TITLE', 'en', 'LABEL', 'Title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_TITLE', 'zh', 'LABEL', '标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_TITLE', 'ja', 'LABEL', 'タイトル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CONTENT', 'ko', 'LABEL', '내용') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CONTENT', 'en', 'LABEL', 'Content') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CONTENT', 'zh', 'LABEL', '内容') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CONTENT', 'ja', 'LABEL', '内容') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUTHOR', 'ko', 'LABEL', '작성자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUTHOR', 'en', 'LABEL', 'Author') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUTHOR', 'zh', 'LABEL', '作者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUTHOR', 'ja', 'LABEL', '作成者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_VIEW_COUNT', 'ko', 'LABEL', '조회수') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_VIEW_COUNT', 'en', 'LABEL', 'Views') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_VIEW_COUNT', 'zh', 'LABEL', '浏览量') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_VIEW_COUNT', 'ja', 'LABEL', '閲覧数') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_COMMENT', 'ko', 'LABEL', '댓글') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_COMMENT', 'en', 'LABEL', 'Comments') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_COMMENT', 'zh', 'LABEL', '评论') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_COMMENT', 'ja', 'LABEL', 'コメント') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PIN', 'ko', 'LABEL', '상단 고정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PIN', 'en', 'LABEL', 'Pinned') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PIN', 'zh', 'LABEL', '置顶') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PIN', 'ja', 'LABEL', '固定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_PERSONAL', 'ko', 'LABEL', '개인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_PERSONAL', 'en', 'LABEL', 'Personal') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_PERSONAL', 'zh', 'LABEL', '个人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_PERSONAL', 'ja', 'LABEL', '個人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DEPT', 'ko', 'LABEL', '부서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DEPT', 'en', 'LABEL', 'Department') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DEPT', 'zh', 'LABEL', '部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DEPT', 'ja', 'LABEL', '部署') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COMPANY', 'ko', 'LABEL', '회사') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COMPANY', 'en', 'LABEL', 'Company') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COMPANY', 'zh', 'LABEL', '公司') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COMPANY', 'ja', 'LABEL', '会社') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_ALL_DAY', 'ko', 'LABEL', '종일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_ALL_DAY', 'en', 'LABEL', 'All Day') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_ALL_DAY', 'zh', 'LABEL', '全天') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_ALL_DAY', 'ja', 'LABEL', '終日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_NEW_EVENT', 'ko', 'LABEL', '새 일정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_NEW_EVENT', 'en', 'LABEL', 'New Event') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_NEW_EVENT', 'zh', 'LABEL', '新建日程') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_NEW_EVENT', 'ja', 'LABEL', '新規予定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EDIT_EVENT', 'ko', 'LABEL', '일정 수정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EDIT_EVENT', 'en', 'LABEL', 'Edit Event') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EDIT_EVENT', 'zh', 'LABEL', '编辑日程') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EDIT_EVENT', 'ja', 'LABEL', '予定編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CREATED_AT', 'ko', 'LABEL', '작성일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CREATED_AT', 'en', 'LABEL', 'Created') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CREATED_AT', 'zh', 'LABEL', '创建时间') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CREATED_AT', 'ja', 'LABEL', '作成日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_UPDATED_AT', 'ko', 'LABEL', '수정일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_UPDATED_AT', 'en', 'LABEL', 'Updated') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_UPDATED_AT', 'zh', 'LABEL', '更新时间') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_UPDATED_AT', 'ja', 'LABEL', '更新日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_STATUS', 'ko', 'LABEL', '상태') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_STATUS', 'en', 'LABEL', 'Status') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_STATUS', 'zh', 'LABEL', '状态') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_STATUS', 'ja', 'LABEL', '状態') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_DATA', 'ko', 'LABEL', '데이터가 없습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_DATA', 'en', 'LABEL', 'No data') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_DATA', 'zh', 'LABEL', '没有数据') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_DATA', 'ja', 'LABEL', 'データがありません') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOADING', 'ko', 'LABEL', '로딩 중...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOADING', 'en', 'LABEL', 'Loading...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOADING', 'zh', 'LABEL', '加载中...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOADING', 'ja', 'LABEL', '読み込み中...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_THEME_SETTINGS', 'ko', 'LABEL', '테마 설정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_THEME_SETTINGS', 'en', 'LABEL', 'Theme Settings') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_THEME_SETTINGS', 'zh', 'LABEL', '主题设置') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_THEME_SETTINGS', 'ja', 'LABEL', 'テーマ設定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFICATION', 'ko', 'LABEL', '알림') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFICATION', 'en', 'LABEL', 'Notifications') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFICATION', 'zh', 'LABEL', '通知') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFICATION', 'ja', 'LABEL', '通知') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MARK_ALL_READ', 'ko', 'LABEL', '모두 읽음') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MARK_ALL_READ', 'en', 'LABEL', 'Mark all read') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MARK_ALL_READ', 'zh', 'LABEL', '全部已读') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MARK_ALL_READ', 'ja', 'LABEL', '全て既読') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_NOTIFICATION', 'ko', 'LABEL', '새 알림이 없습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_NOTIFICATION', 'en', 'LABEL', 'No new notifications') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_NOTIFICATION', 'zh', 'LABEL', '没有新通知') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NO_NOTIFICATION', 'ja', 'LABEL', '新しい通知はありません') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN', 'ko', 'LABEL', '접근 권한이 없습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN', 'en', 'LABEL', 'Access denied') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN', 'zh', 'LABEL', '访问被拒绝') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN', 'ja', 'LABEL', 'アクセスが拒否されました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_SUCCESS', 'ko', 'MSG', '저장되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_SUCCESS', 'en', 'MSG', 'Saved successfully') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_SUCCESS', 'zh', 'MSG', '保存成功') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_SUCCESS', 'ja', 'MSG', '保存しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_SUCCESS', 'ko', 'MSG', '삭제되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_SUCCESS', 'en', 'MSG', 'Deleted successfully') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_SUCCESS', 'zh', 'MSG', '删除成功') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_SUCCESS', 'ja', 'MSG', '削除しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_CONFIRM', 'ko', 'MSG', '정말 삭제하시겠습니까?') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_CONFIRM', 'en', 'MSG', 'Are you sure you want to delete?') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_CONFIRM', 'zh', 'MSG', '确定要删除吗？') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_CONFIRM', 'ja', 'MSG', '本当に削除しますか？') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ERROR', 'ko', 'MSG', '오류가 발생했습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ERROR', 'en', 'MSG', 'An error occurred') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ERROR', 'zh', 'MSG', '发生错误') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ERROR', 'ja', 'MSG', 'エラーが発生しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMITTED', 'ko', 'MSG', '결재가 상신되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMITTED', 'en', 'MSG', 'Approval submitted') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMITTED', 'zh', 'MSG', '审批已提交') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMITTED', 'ja', 'MSG', '決裁を起案しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVED', 'ko', 'MSG', '승인되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVED', 'en', 'MSG', 'Approved') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVED', 'zh', 'MSG', '已批准') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVED', 'ja', 'MSG', '承認しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECTED', 'ko', 'MSG', '반려되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECTED', 'en', 'MSG', 'Rejected') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECTED', 'zh', 'MSG', '已退回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECTED', 'ja', 'MSG', '却下しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_COMMENT_ADDED', 'ko', 'MSG', '댓글이 등록되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_COMMENT_ADDED', 'en', 'MSG', 'Comment added') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_COMMENT_ADDED', 'zh', 'MSG', '评论已添加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_COMMENT_ADDED', 'ja', 'MSG', 'コメントを追加しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MAIL_SENT', 'ko', 'MSG', '메일이 발송되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MAIL_SENT', 'en', 'MSG', 'Email sent') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MAIL_SENT', 'zh', 'MSG', '邮件已发送') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MAIL_SENT', 'ja', 'MSG', 'メールを送信しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_COMPOSE_MAIL', 'ko', 'BUTTON', '새 메일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_COMPOSE_MAIL', 'en', 'BUTTON', 'Compose') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_COMPOSE_MAIL', 'zh', 'BUTTON', '新邮件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_COMPOSE_MAIL', 'ja', 'BUTTON', '新規メール') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_EDIT', 'ko', 'BUTTON', '편집') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_EDIT', 'en', 'BUTTON', 'Edit') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_EDIT', 'zh', 'BUTTON', '编辑') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_EDIT', 'ja', 'BUTTON', '編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_ADD_WIDGET', 'ko', 'BUTTON', '위젯 추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_ADD_WIDGET', 'en', 'BUTTON', 'Add Widget') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_ADD_WIDGET', 'zh', 'BUTTON', '添加小部件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DASH_ADD_WIDGET', 'ja', 'BUTTON', 'ウィジェット追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_BOOK_ROOM', 'ko', 'BUTTON', '예약하기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_BOOK_ROOM', 'en', 'BUTTON', 'Book') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_BOOK_ROOM', 'zh', 'BUTTON', '预订') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_BOOK_ROOM', 'ja', 'BUTTON', '予約する') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_DEFAULT', 'ko', 'BUTTON', '기본값으로') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_DEFAULT', 'en', 'BUTTON', 'Reset to Default') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_DEFAULT', 'zh', 'BUTTON', '恢复默认') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_DEFAULT', 'ja', 'BUTTON', 'デフォルト') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_GO_DASHBOARD', 'ko', 'BUTTON', '대시보드로 이동') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_GO_DASHBOARD', 'en', 'BUTTON', 'Go to Dashboard') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_GO_DASHBOARD', 'zh', 'BUTTON', '返回仪表盘') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_GO_DASHBOARD', 'ja', 'BUTTON', 'ダッシュボードへ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_FOLDER', 'ko', 'BUTTON', '새 폴더') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_FOLDER', 'en', 'BUTTON', 'New Folder') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_FOLDER', 'zh', 'BUTTON', '新建文件夹') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_FOLDER', 'ja', 'BUTTON', '新規フォルダ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPLOAD', 'ko', 'BUTTON', '업로드') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPLOAD', 'en', 'BUTTON', 'Upload') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPLOAD', 'zh', 'BUTTON', '上传') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPLOAD', 'ja', 'BUTTON', 'アップロード') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DOWNLOAD', 'ko', 'BUTTON', '다운로드') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DOWNLOAD', 'en', 'BUTTON', 'Download') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DOWNLOAD', 'zh', 'BUTTON', '下载') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DOWNLOAD', 'ja', 'BUTTON', 'ダウンロード') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RENAME', 'ko', 'BUTTON', '이름변경') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RENAME', 'en', 'BUTTON', 'Rename') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RENAME', 'zh', 'BUTTON', '重命名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RENAME', 'ja', 'BUTTON', '名前変更') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGIN_KC', 'ko', 'BUTTON', 'Keycloak으로 로그인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGIN_KC', 'en', 'BUTTON', 'Sign in with Keycloak') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGIN_KC', 'zh', 'BUTTON', '使用 Keycloak 登录') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_LOGIN_KC', 'ja', 'BUTTON', 'Keycloak でログイン') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GREETING', 'ko', 'LABEL', '안녕하세요, {name}님') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GREETING', 'en', 'LABEL', 'Welcome, {name}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GREETING', 'zh', 'LABEL', '您好，{name}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GREETING', 'ja', 'LABEL', 'こんにちは、{name}様') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_PICK_WIDGET', 'ko', 'LABEL', '추가할 위젯 선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_PICK_WIDGET', 'en', 'LABEL', 'Pick a widget to add') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_PICK_WIDGET', 'zh', 'LABEL', '选择要添加的小部件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_PICK_WIDGET', 'ja', 'LABEL', '追加するウィジェットを選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GUEST', 'ko', 'LABEL', '사용자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GUEST', 'en', 'LABEL', 'User') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GUEST', 'zh', 'LABEL', '用户') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DASH_GUEST', 'ja', 'LABEL', 'ユーザー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_TARGETS', 'ko', 'LABEL', '대상') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_TARGETS', 'en', 'LABEL', 'Targets') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_TARGETS', 'zh', 'LABEL', '对象') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_TARGETS', 'ja', 'LABEL', '対象') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_POST', 'ko', 'LABEL', '게시글') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_POST', 'en', 'LABEL', 'Posts') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_POST', 'zh', 'LABEL', '帖子') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_POST', 'ja', 'LABEL', '投稿') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_APPROVAL', 'ko', 'LABEL', '전자결재') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_APPROVAL', 'en', 'LABEL', 'Approval') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_APPROVAL', 'zh', 'LABEL', '电子审批') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_APPROVAL', 'ja', 'LABEL', '電子決裁') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_BOARD', 'ko', 'LABEL', '게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_BOARD', 'en', 'LABEL', 'Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_BOARD', 'zh', 'LABEL', '公告板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_BOARD', 'ja', 'LABEL', '掲示板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_CALENDAR', 'ko', 'LABEL', '캘린더') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_CALENDAR', 'en', 'LABEL', 'Calendar') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_CALENDAR', 'zh', 'LABEL', '日历') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_CALENDAR', 'ja', 'LABEL', 'カレンダー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ORG', 'ko', 'LABEL', '조직도') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ORG', 'en', 'LABEL', 'Organization') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ORG', 'zh', 'LABEL', '组织架构') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ORG', 'ja', 'LABEL', '組織図') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MAIL', 'ko', 'LABEL', '메일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MAIL', 'en', 'LABEL', 'Mail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MAIL', 'zh', 'LABEL', '邮件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MAIL', 'ja', 'LABEL', 'メール') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MESSENGER', 'ko', 'LABEL', '메신저') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MESSENGER', 'en', 'LABEL', 'Messenger') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MESSENGER', 'zh', 'LABEL', '即时通讯') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_MESSENGER', 'ja', 'LABEL', 'メッセンジャー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WIKI', 'ko', 'LABEL', '위키') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WIKI', 'en', 'LABEL', 'Wiki') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WIKI', 'zh', 'LABEL', '维基') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WIKI', 'ja', 'LABEL', 'ウィキ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_VIDEO', 'ko', 'LABEL', '화상회의') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_VIDEO', 'en', 'LABEL', 'Video Conference') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_VIDEO', 'zh', 'LABEL', '视频会议') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_VIDEO', 'ja', 'LABEL', 'ビデオ会議') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DASHBOARD', 'ko', 'LABEL', '대시보드') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DASHBOARD', 'en', 'LABEL', 'Dashboard') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DASHBOARD', 'zh', 'LABEL', '仪表盘') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DASHBOARD', 'ja', 'LABEL', 'ダッシュボード') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ATTENDANCE', 'ko', 'LABEL', '근태') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ATTENDANCE', 'en', 'LABEL', 'Attendance') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ATTENDANCE', 'zh', 'LABEL', '考勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ATTENDANCE', 'ja', 'LABEL', '勤怠') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_LEAVE', 'ko', 'LABEL', '연차 / 휴가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_LEAVE', 'en', 'LABEL', 'Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_LEAVE', 'zh', 'LABEL', '年假 / 休假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_LEAVE', 'ja', 'LABEL', '年次 / 休暇') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WORKLOG', 'ko', 'LABEL', '업무일지') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WORKLOG', 'en', 'LABEL', 'Work Log') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WORKLOG', 'zh', 'LABEL', '工作日志') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_WORKLOG', 'ja', 'LABEL', '業務日誌') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ROOM', 'ko', 'LABEL', '회의실 예약') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ROOM', 'en', 'LABEL', 'Room Booking') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ROOM', 'zh', 'LABEL', '会议室预订') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ROOM', 'ja', 'LABEL', '会議室予約') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DATALIB', 'ko', 'LABEL', '자료실') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DATALIB', 'en', 'LABEL', 'Data Library') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DATALIB', 'zh', 'LABEL', '资料室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_DATALIB', 'ja', 'LABEL', '資料室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_SEARCH', 'ko', 'LABEL', '통합 검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_SEARCH', 'en', 'LABEL', 'Search') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_SEARCH', 'zh', 'LABEL', '综合搜索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_SEARCH', 'ja', 'LABEL', '統合検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_NOTIFY_SETTINGS', 'ko', 'LABEL', '알림 설정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_NOTIFY_SETTINGS', 'en', 'LABEL', 'Notification Settings') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_NOTIFY_SETTINGS', 'zh', 'LABEL', '通知设置') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_NOTIFY_SETTINGS', 'ja', 'LABEL', '通知設定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_FAVORITES', 'ko', 'LABEL', '즐겨찾기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_FAVORITES', 'en', 'LABEL', 'Favorites') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_FAVORITES', 'zh', 'LABEL', '收藏夹') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_FAVORITES', 'ja', 'LABEL', 'お気に入り') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_USERS', 'ko', 'LABEL', '사용자 관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_USERS', 'en', 'LABEL', 'User Management') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_USERS', 'zh', 'LABEL', '用户管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_USERS', 'ja', 'LABEL', 'ユーザー管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_DEPTS', 'ko', 'LABEL', '조직 관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_DEPTS', 'en', 'LABEL', 'Department Management') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_DEPTS', 'zh', 'LABEL', '组织管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_DEPTS', 'ja', 'LABEL', '組織管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_MENUS', 'ko', 'LABEL', '메뉴 / 권한 관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_MENUS', 'en', 'LABEL', 'Menu / Permission Management') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_MENUS', 'zh', 'LABEL', '菜单 / 权限管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_MENUS', 'ja', 'LABEL', 'メニュー / 権限管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_CODES', 'ko', 'LABEL', '공통코드 관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_CODES', 'en', 'LABEL', 'Common Code Management') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_CODES', 'zh', 'LABEL', '公共代码管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_CODES', 'ja', 'LABEL', '共通コード管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_WITHDRAW', 'ko', 'BUTTON', '회수') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_AUDIT', 'ko', 'LABEL', '감사 로그') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_AUDIT', 'en', 'LABEL', 'Audit Log') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_AUDIT', 'zh', 'LABEL', '审计日志') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_PAGE_ADMIN_AUDIT', 'ja', 'LABEL', '監査ログ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_DOC', 'ko', 'LABEL', '결재') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_DOC', 'en', 'LABEL', 'Approval') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_DOC', 'zh', 'LABEL', '审批') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_DOC', 'ja', 'LABEL', '決裁') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_EMP', 'ko', 'LABEL', '사람') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_EMP', 'en', 'LABEL', 'People') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_EMP', 'zh', 'LABEL', '人员') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_EMP', 'ja', 'LABEL', '人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_FILE', 'ko', 'LABEL', '파일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_FILE', 'en', 'LABEL', 'Files') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_FILE', 'zh', 'LABEL', '文件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_SEARCH_FILE', 'ja', 'LABEL', 'ファイル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_MIN_CAPACITY', 'ko', 'LABEL', '최소 인원') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_MIN_CAPACITY', 'en', 'LABEL', 'Min Capacity') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_MIN_CAPACITY', 'zh', 'LABEL', '最少人数') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_MIN_CAPACITY', 'ja', 'LABEL', '最低人数') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_HAS_VIDEO', 'ko', 'LABEL', '화상회의 가능') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_HAS_VIDEO', 'en', 'LABEL', 'Video conference') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_HAS_VIDEO', 'zh', 'LABEL', '支持视频会议') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_HAS_VIDEO', 'ja', 'LABEL', 'ビデオ会議可能') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LOADING', 'ko', 'LABEL', '불러오는 중...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LOADING', 'en', 'LABEL', 'Loading...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LOADING', 'zh', 'LABEL', '加载中...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LOADING', 'ja', 'LABEL', '読み込み中...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_EMPTY', 'ko', 'LABEL', '조건에 맞는 회의실이 없습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_EMPTY', 'en', 'LABEL', 'No rooms match') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_EMPTY', 'zh', 'LABEL', '没有符合条件的会议室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_EMPTY', 'ja', 'LABEL', '条件に合う会議室がありません') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_SELECT_HINT', 'ko', 'LABEL', '회의실을 선택하면 예약 현황이 표시됩니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_SELECT_HINT', 'en', 'LABEL', 'Select a room to view bookings') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_SELECT_HINT', 'zh', 'LABEL', '选择会议室查看预订情况') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_SELECT_HINT', 'ja', 'LABEL', '会議室を選択すると予約状況が表示されます') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_CAPACITY_SUFFIX', 'ko', 'LABEL', '정원 {n}명') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_CAPACITY_SUFFIX', 'en', 'LABEL', 'Capacity {n}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_CAPACITY_SUFFIX', 'zh', 'LABEL', '容量 {n}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_CAPACITY_SUFFIX', 'ja', 'LABEL', '定員 {n}名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DATALIB_FOLDERS', 'ko', 'LABEL', '폴더') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DATALIB_FOLDERS', 'en', 'LABEL', 'Folders') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DATALIB_FOLDERS', 'zh', 'LABEL', '文件夹') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DATALIB_FOLDERS', 'ja', 'LABEL', 'フォルダ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_MINE', 'ko', 'LABEL', '본인 뷰') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_MINE', 'en', 'LABEL', 'My View') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_MINE', 'zh', 'LABEL', '本人视图') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_MINE', 'ja', 'LABEL', '本人ビュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_TEAM', 'ko', 'LABEL', '팀 뷰') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_TEAM', 'en', 'LABEL', 'Team View') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_TEAM', 'zh', 'LABEL', '团队视图') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_VIEW_TEAM', 'ja', 'LABEL', 'チームビュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_CALENDAR', 'ko', 'LABEL', '캘린더') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_CALENDAR', 'en', 'LABEL', 'Calendar') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_CALENDAR', 'zh', 'LABEL', '日历') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_WORKLOG_CALENDAR', 'ja', 'LABEL', 'カレンダー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFY_NOTE', 'ko', 'LABEL', '각 카테고리별로 알림을 받을 채널을 선택하세요. 포탈은 헤더 종 아이콘에 SSE 로 즉시 알림, 이메일은 등록된 메일 주소로 발송, 메신저는 Rocket.Chat DM 으로 전달됩니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFY_NOTE', 'en', 'LABEL', 'Select channels per category. Portal: real-time bell icon (SSE). Email: registered address. Messenger: Rocket.Chat DM.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFY_NOTE', 'zh', 'LABEL', '为每个类别选择接收通知的渠道。门户：通过 SSE 实时显示在铃铛图标。邮件：发送至已注册邮箱。聊天：通过 Rocket.Chat 私信。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_NOTIFY_NOTE', 'ja', 'LABEL', 'カテゴリーごとに通知を受け取るチャネルを選択してください。ポータル：SSE でベルアイコンに即時通知。メール：登録メールアドレス宛。メッセンジャー：Rocket.Chat DM。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_TITLE', 'ko', 'LABEL', '즐겨찾기 관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_TITLE', 'en', 'LABEL', 'Manage Favorites') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_TITLE', 'zh', 'LABEL', '管理收藏夹') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_TITLE', 'ja', 'LABEL', 'お気に入り管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_EMPTY', 'ko', 'LABEL', '등록된 즐겨찾기가 없습니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_EMPTY', 'en', 'LABEL', 'No favorites yet.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_EMPTY', 'zh', 'LABEL', '尚无收藏。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FAVORITES_EMPTY', 'ja', 'LABEL', 'お気に入りがありません。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_TITLE', 'ko', 'LABEL', 'openplatform v3') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_TITLE', 'en', 'LABEL', 'openplatform v3') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_TITLE', 'zh', 'LABEL', 'openplatform v3') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_TITLE', 'ja', 'LABEL', 'openplatform v3') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_SUBTITLE', 'ko', 'LABEL', '통합 그룹웨어 — Keycloak SSO') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_SUBTITLE', 'en', 'LABEL', 'Unified Groupware — Keycloak SSO') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_SUBTITLE', 'zh', 'LABEL', '统一协作平台 — Keycloak SSO') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_SUBTITLE', 'ja', 'LABEL', '統合グループウェア — Keycloak SSO') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_HINT', 'ko', 'LABEL', 'admin / admin 또는 user1 / user1') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_HINT', 'en', 'LABEL', 'admin / admin or user1 / user1') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_HINT', 'zh', 'LABEL', 'admin / admin 或 user1 / user1') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LOGIN_HINT', 'ja', 'LABEL', 'admin / admin または user1 / user1') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DETAIL_HEADER', 'ko', 'LABEL', '게시글 상세') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DETAIL_HEADER', 'en', 'LABEL', 'Post Detail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DETAIL_HEADER', 'zh', 'LABEL', '帖子详情') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_DETAIL_HEADER', 'ja', 'LABEL', '投稿詳細') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DETAIL_HEADER', 'ko', 'LABEL', '결재 문서 상세') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DETAIL_HEADER', 'en', 'LABEL', 'Approval Document Detail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DETAIL_HEADER', 'zh', 'LABEL', '审批文档详情') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DETAIL_HEADER', 'ja', 'LABEL', '決裁文書詳細') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_NEW', 'ko', 'LABEL', '새 일정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_NEW', 'en', 'LABEL', 'New Event') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_NEW', 'zh', 'LABEL', '新建日程') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_NEW', 'ja', 'LABEL', '新規予定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_EDIT', 'ko', 'LABEL', '일정 수정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_EDIT', 'en', 'LABEL', 'Edit Event') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_EDIT', 'zh', 'LABEL', '编辑日程') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_EVENT_EDIT', 'ja', 'LABEL', '予定編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COLOR', 'ko', 'LABEL', '색상') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COLOR', 'en', 'LABEL', 'Color') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COLOR', 'zh', 'LABEL', '颜色') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_COLOR', 'ja', 'LABEL', '色') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DESCRIPTION', 'ko', 'LABEL', '설명') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DESCRIPTION', 'en', 'LABEL', 'Description') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DESCRIPTION', 'zh', 'LABEL', '描述') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_DESCRIPTION', 'ja', 'LABEL', '説明') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_DETAIL_HEADER', 'ko', 'LABEL', '직원 상세') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_DETAIL_HEADER', 'en', 'LABEL', 'Employee Detail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_DETAIL_HEADER', 'zh', 'LABEL', '员工详情') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_DETAIL_HEADER', 'ja', 'LABEL', '社員詳細') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_HIRE_DATE', 'ko', 'LABEL', '입사일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_HIRE_DATE', 'en', 'LABEL', 'Hire Date') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_HIRE_DATE', 'zh', 'LABEL', '入职日期') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_EMP_HIRE_DATE', 'ja', 'LABEL', '入社日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_DM', 'ko', 'BUTTON', '메신저 DM') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_DM', 'en', 'BUTTON', 'Messenger DM') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_DM', 'zh', 'BUTTON', '即时消息') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_DM', 'ja', 'BUTTON', 'メッセンジャー DM') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_MAIL', 'ko', 'BUTTON', '메일 보내기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_MAIL', 'en', 'BUTTON', 'Send Mail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_MAIL', 'zh', 'BUTTON', '发送邮件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_EMP_MAIL', 'ja', 'BUTTON', 'メール送信') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_COMPOSE_HEADER', 'ko', 'LABEL', '새 메일 작성') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_COMPOSE_HEADER', 'en', 'LABEL', 'New Mail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_COMPOSE_HEADER', 'zh', 'LABEL', '撰写邮件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_COMPOSE_HEADER', 'ja', 'LABEL', '新規メール作成') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_REPLY', 'ko', 'LABEL', '답장') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_REPLY', 'en', 'LABEL', 'Reply') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_REPLY', 'zh', 'LABEL', '回复') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_REPLY', 'ja', 'LABEL', '返信') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_FORWARD', 'ko', 'LABEL', '전달') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_FORWARD', 'en', 'LABEL', 'Forward') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_FORWARD', 'zh', 'LABEL', '转发') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_FORWARD', 'ja', 'LABEL', '転送') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_TO', 'ko', 'LABEL', '받는 사람') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_TO', 'en', 'LABEL', 'To') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_TO', 'zh', 'LABEL', '收件人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_TO', 'ja', 'LABEL', '宛先') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_CC', 'ko', 'LABEL', '참조 (CC)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_CC', 'en', 'LABEL', 'Cc') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_CC', 'zh', 'LABEL', '抄送') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_CC', 'ja', 'LABEL', 'Cc') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_OPTIONAL', 'ko', 'LABEL', '선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_OPTIONAL', 'en', 'LABEL', 'optional') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_OPTIONAL', 'zh', 'LABEL', '可选') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MAIL_OPTIONAL', 'ja', 'LABEL', '任意') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_DRAFT', 'ko', 'BUTTON', '임시저장') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_DRAFT', 'en', 'BUTTON', 'Save Draft') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_DRAFT', 'zh', 'BUTTON', '保存草稿') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_DRAFT', 'ja', 'BUTTON', '下書き保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_SEND', 'ko', 'BUTTON', '발송') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_SEND', 'en', 'BUTTON', 'Send') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_SEND', 'zh', 'BUTTON', '发送') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_MAIL_SEND', 'ja', 'BUTTON', '送信') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_BOOKING_HEADER', 'ko', 'LABEL', '회의실 예약') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_BOOKING_HEADER', 'en', 'LABEL', 'Book Room') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_BOOKING_HEADER', 'zh', 'LABEL', '预订会议室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_BOOKING_HEADER', 'ja', 'LABEL', '会議室予約') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LABEL', 'ko', 'LABEL', '회의실') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LABEL', 'en', 'LABEL', 'Room') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LABEL', 'zh', 'LABEL', '会议室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_LABEL', 'ja', 'LABEL', '会議室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_ATTENDEES', 'ko', 'LABEL', '참석자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_ATTENDEES', 'en', 'LABEL', 'Attendees') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_ATTENDEES', 'zh', 'LABEL', '参与者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_ATTENDEES', 'ja', 'LABEL', '参加者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_AUTO_VIDEO', 'ko', 'LABEL', '화상회의 자동 생성 (이 회의실은 LiveKit 연동)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_AUTO_VIDEO', 'en', 'LABEL', 'Auto-create video conference (LiveKit-enabled room)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_AUTO_VIDEO', 'zh', 'LABEL', '自动创建视频会议 (此会议室已接入 LiveKit)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ROOM_AUTO_VIDEO', 'ja', 'LABEL', 'ビデオ会議自動生成 (LiveKit 連携会議室)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_MEETING_TITLE', 'ko', 'PLACEHOLDER', '회의 제목') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_MEETING_TITLE', 'en', 'PLACEHOLDER', 'Meeting title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_MEETING_TITLE', 'zh', 'PLACEHOLDER', '会议标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_MEETING_TITLE', 'ja', 'PLACEHOLDER', '会議タイトル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SELECT', 'ko', 'PLACEHOLDER', '회의실 선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SELECT', 'en', 'PLACEHOLDER', 'Select a room') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SELECT', 'zh', 'PLACEHOLDER', '选择会议室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SELECT', 'ja', 'PLACEHOLDER', '会議室を選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_ATTENDEES', 'ko', 'PLACEHOLDER', '참석자 선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_ATTENDEES', 'en', 'PLACEHOLDER', 'Select attendees') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_ATTENDEES', 'zh', 'PLACEHOLDER', '选择参与者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_ATTENDEES', 'ja', 'PLACEHOLDER', '参加者選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN_DETAIL', 'ko', 'LABEL', '이 페이지에 대한 접근 권한이 없습니다. 관리자에게 문의하세요.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN_DETAIL', 'en', 'LABEL', 'You do not have permission to access this page. Please contact your administrator.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN_DETAIL', 'zh', 'LABEL', '您没有访问此页面的权限。请联系管理员。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_FORBIDDEN_DETAIL', 'ja', 'LABEL', 'このページへのアクセス権限がありません。管理者にお問い合わせください。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GLOBAL_SEARCH', 'ko', 'PLACEHOLDER', '통합 검색...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GLOBAL_SEARCH', 'en', 'PLACEHOLDER', 'Global search...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GLOBAL_SEARCH', 'zh', 'PLACEHOLDER', '综合搜索...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GLOBAL_SEARCH', 'ja', 'PLACEHOLDER', '統合検索...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SEARCH', 'ko', 'PLACEHOLDER', '회의실 검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SEARCH', 'en', 'PLACEHOLDER', 'Search rooms') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SEARCH', 'zh', 'PLACEHOLDER', '搜索会议室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROOM_SEARCH', 'ja', 'PLACEHOLDER', '会議室検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_DOC', 'ko', 'BUTTON', '새 문서 상신') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_DOC', 'en', 'BUTTON', 'New Submission') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_DOC', 'zh', 'BUTTON', '新建提交') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_DOC', 'ja', 'BUTTON', '新規起案') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_POST', 'ko', 'BUTTON', '글쓰기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_POST', 'en', 'BUTTON', 'New Post') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_POST', 'zh', 'BUTTON', '发帖') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_POST', 'ja', 'BUTTON', '投稿') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_EVENT', 'ko', 'BUTTON', '일정 추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_EVENT', 'en', 'BUTTON', 'New Event') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_EVENT', 'zh', 'BUTTON', '新建日程') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_EVENT', 'ja', 'BUTTON', '予定追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPLY_LEAVE', 'ko', 'BUTTON', '휴가 신청') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPLY_LEAVE', 'en', 'BUTTON', 'Apply Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPLY_LEAVE', 'zh', 'BUTTON', '申请休假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPLY_LEAVE', 'ja', 'BUTTON', '休暇申請') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_IN', 'ko', 'BUTTON', '출근') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_IN', 'en', 'BUTTON', 'Check In') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_IN', 'zh', 'BUTTON', '签到') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_IN', 'ja', 'BUTTON', '出勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_OUT', 'ko', 'BUTTON', '퇴근') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_OUT', 'en', 'BUTTON', 'Check Out') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_OUT', 'zh', 'BUTTON', '签退') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_CHECK_OUT', 'ja', 'BUTTON', '退勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DONE', 'ko', 'BUTTON', '완료') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DONE', 'en', 'BUTTON', 'Done') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DONE', 'zh', 'BUTTON', '完成') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DONE', 'ja', 'BUTTON', '完了') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET', 'ko', 'BUTTON', '초기화') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET', 'en', 'BUTTON', 'Reset') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET', 'zh', 'BUTTON', '重置') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET', 'ja', 'BUTTON', 'リセット') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_GROUP', 'ko', 'BUTTON', '그룹 추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_GROUP', 'en', 'BUTTON', 'Add Group') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_GROUP', 'zh', 'BUTTON', '添加组') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_GROUP', 'ja', 'BUTTON', 'グループ追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROW', 'ko', 'BUTTON', '행 추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROW', 'en', 'BUTTON', 'Add Row') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROW', 'zh', 'BUTTON', '添加行') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROW', 'ja', 'BUTTON', '行追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROOT', 'ko', 'BUTTON', '루트 추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROOT', 'en', 'BUTTON', 'Add Root') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROOT', 'zh', 'BUTTON', '添加根') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_ADD_ROOT', 'ja', 'BUTTON', 'ルート追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_MENU', 'ko', 'BUTTON', '새 메뉴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_MENU', 'en', 'BUTTON', 'New Menu') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_MENU', 'zh', 'BUTTON', '新建菜单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_NEW_MENU', 'ja', 'BUTTON', '新規メニュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE_PERM', 'ko', 'BUTTON', '권한 저장') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE_PERM', 'en', 'BUTTON', 'Save Permissions') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE_PERM', 'zh', 'BUTTON', '保存权限') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SAVE_PERM', 'ja', 'BUTTON', '権限保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPROVE', 'ko', 'BUTTON', '승인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPROVE', 'en', 'BUTTON', 'Approve') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPROVE', 'zh', 'BUTTON', '批准') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_APPROVE', 'ja', 'BUTTON', '承認') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REJECT', 'ko', 'BUTTON', '반려') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REJECT', 'en', 'BUTTON', 'Reject') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REJECT', 'zh', 'BUTTON', '退回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REJECT', 'ja', 'BUTTON', '却下') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_WITHDRAW', 'en', 'BUTTON', 'Withdraw') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_WITHDRAW', 'zh', 'BUTTON', '撤回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_WITHDRAW', 'ja', 'BUTTON', '取下げ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESUBMIT', 'ko', 'BUTTON', '재상신') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESUBMIT', 'en', 'BUTTON', 'Resubmit') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESUBMIT', 'zh', 'BUTTON', '重新提交') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESUBMIT', 'ja', 'BUTTON', '再起案') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELEGATE', 'ko', 'BUTTON', '대결 등록') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELEGATE', 'en', 'BUTTON', 'Register Delegate') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELEGATE', 'zh', 'BUTTON', '登记代审') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_DELEGATE', 'ja', 'BUTTON', '代決登録') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SUBMIT_DOC', 'ko', 'BUTTON', '상신') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SUBMIT_DOC', 'en', 'BUTTON', 'Submit') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SUBMIT_DOC', 'zh', 'BUTTON', '提交') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_SUBMIT_DOC', 'ja', 'BUTTON', '起案') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REGISTER', 'ko', 'BUTTON', '등록') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REGISTER', 'en', 'BUTTON', 'Register') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REGISTER', 'zh', 'BUTTON', '注册') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_REGISTER', 'ja', 'BUTTON', '登録') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPDATE', 'ko', 'BUTTON', '수정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPDATE', 'en', 'BUTTON', 'Update') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPDATE', 'zh', 'BUTTON', '修改') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_UPDATE', 'ja', 'BUTTON', '修正') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_PWD', 'ko', 'BUTTON', '비밀번호 초기화') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_PWD', 'en', 'BUTTON', 'Reset Password') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_PWD', 'zh', 'BUTTON', '重置密码') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_RESET_PWD', 'ja', 'BUTTON', 'パスワード初期化') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_TOGGLE_ACTIVE', 'ko', 'BUTTON', '활성 상태 변경') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_TOGGLE_ACTIVE', 'en', 'BUTTON', 'Toggle Active') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_TOGGLE_ACTIVE', 'zh', 'BUTTON', '切换状态') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BTN_TOGGLE_ACTIVE', 'ja', 'BUTTON', '状態切替') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_BOXES', 'ko', 'LABEL', '결재함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_BOXES', 'en', 'LABEL', 'Approval Boxes') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_BOXES', 'zh', 'LABEL', '审批箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_BOXES', 'ja', 'LABEL', '決裁箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX_EMPTY', 'ko', 'LABEL', '결재함이 비어 있습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX_EMPTY', 'en', 'LABEL', 'Inbox is empty') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX_EMPTY', 'zh', 'LABEL', '审批箱为空') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_INBOX_EMPTY', 'ja', 'LABEL', '決裁箱が空です') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT_HEADER', 'ko', 'LABEL', '결재 상신') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT_HEADER', 'en', 'LABEL', 'Submit Approval') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT_HEADER', 'zh', 'LABEL', '提交审批') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_SUBMIT_HEADER', 'ja', 'LABEL', '決裁起案') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FORM_REQ', 'ko', 'LABEL', '양식 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FORM_REQ', 'en', 'LABEL', 'Form *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FORM_REQ', 'zh', 'LABEL', '表单 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FORM_REQ', 'ja', 'LABEL', '様式 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TITLE_REQ', 'ko', 'LABEL', '제목 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TITLE_REQ', 'en', 'LABEL', 'Title *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TITLE_REQ', 'zh', 'LABEL', '标题 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TITLE_REQ', 'ja', 'LABEL', 'タイトル *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LEAVE_TYPE_REQ', 'ko', 'LABEL', '휴가 유형 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LEAVE_TYPE_REQ', 'en', 'LABEL', 'Leave Type *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LEAVE_TYPE_REQ', 'zh', 'LABEL', '休假类型 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LEAVE_TYPE_REQ', 'ja', 'LABEL', '休暇種別 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE_REQ', 'ko', 'LABEL', '시작일 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE_REQ', 'en', 'LABEL', 'From Date *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE_REQ', 'zh', 'LABEL', '开始日 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE_REQ', 'ja', 'LABEL', '開始日 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE_REQ', 'ko', 'LABEL', '종료일 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE_REQ', 'en', 'LABEL', 'To Date *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE_REQ', 'zh', 'LABEL', '结束日 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE_REQ', 'ja', 'LABEL', '終了日 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS', 'ko', 'LABEL', '일수') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS', 'en', 'LABEL', 'Days') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS', 'zh', 'LABEL', '天数') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS', 'ja', 'LABEL', '日数') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REASON', 'ko', 'LABEL', '사유') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REASON', 'en', 'LABEL', 'Reason') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REASON', 'zh', 'LABEL', '理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_REASON', 'ja', 'LABEL', '理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_AMOUNT', 'ko', 'LABEL', '금액') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_AMOUNT', 'en', 'LABEL', 'Amount') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_AMOUNT', 'zh', 'LABEL', '金额') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_AMOUNT', 'ja', 'LABEL', '金額') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_CONTENT', 'ko', 'LABEL', '본문') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_CONTENT', 'en', 'LABEL', 'Content') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_CONTENT', 'zh', 'LABEL', '正文') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_CONTENT', 'ja', 'LABEL', '本文') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE_PREVIEW', 'ko', 'LABEL', '결재선 미리보기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE_PREVIEW', 'en', 'LABEL', 'Approval Line Preview') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE_PREVIEW', 'zh', 'LABEL', '审批线预览') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_LINE_PREVIEW', 'ja', 'LABEL', '決裁ラインプレビュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_LOADING', 'ko', 'LABEL', '불러오는 중...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_LOADING', 'en', 'LABEL', 'Loading...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_LOADING', 'zh', 'LABEL', '加载中...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_LOADING', 'ja', 'LABEL', '読み込み中...') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_EMPTY', 'ko', 'LABEL', '양식과 금액을 선택하면 결재선이 자동으로 표시됩니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_EMPTY', 'en', 'LABEL', 'Select form and amount to see approval line') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_EMPTY', 'zh', 'LABEL', '选择表单和金额后审批线会自动显示') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_PREVIEW_EMPTY', 'ja', 'LABEL', '様式と金額を選ぶと決裁ラインが自動表示されます') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_STEP_SUFFIX', 'ko', 'LABEL', '단계') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_STEP_SUFFIX', 'en', 'LABEL', 'Step') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_STEP_SUFFIX', 'zh', 'LABEL', '步骤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_STEP_SUFFIX', 'ja', 'LABEL', '段階') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS_HINT', 'ko', 'LABEL', '반차(0.5)는 자동 적용. 영업일 = 주말/공휴일 제외 (UI 측은 주말만 자동 제외).') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS_HINT', 'en', 'LABEL', 'Half-day (0.5) is auto-applied. Business days exclude weekends/holidays (UI excludes weekends only).') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS_HINT', 'zh', 'LABEL', '半天(0.5)自动应用。工作日 = 排除周末/公休 (UI 仅排除周末)。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DAYS_HINT', 'ja', 'LABEL', '半休(0.5)は自動適用。営業日 = 週末/祝日除く (UIは週末のみ自動除外)。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_APPROVE', 'ko', 'LABEL', '승인 의견') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_APPROVE', 'en', 'LABEL', 'Approval Comment') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_APPROVE', 'zh', 'LABEL', '批准意见') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_APPROVE', 'ja', 'LABEL', '承認コメント') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_REJECT', 'ko', 'LABEL', '반려 사유') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_REJECT', 'en', 'LABEL', 'Rejection Reason') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_REJECT', 'zh', 'LABEL', '退回理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_COMMENT_REJECT', 'ja', 'LABEL', '却下理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE_HEADER', 'ko', 'LABEL', '대결(위임) 등록') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE_HEADER', 'en', 'LABEL', 'Register Delegate') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE_HEADER', 'zh', 'LABEL', '登记代审(委托)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATE_HEADER', 'ja', 'LABEL', '代決(委任)登録') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATEE_NO', 'ko', 'LABEL', '대리 결재자 사번') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATEE_NO', 'en', 'LABEL', 'Delegatee Emp. No.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATEE_NO', 'zh', 'LABEL', '代理审批人工号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATEE_NO', 'ja', 'LABEL', '代理決裁者番号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE', 'ko', 'LABEL', '시작일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE', 'en', 'LABEL', 'From Date') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE', 'zh', 'LABEL', '开始日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_FROM_DATE', 'ja', 'LABEL', '開始日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE', 'ko', 'LABEL', '종료일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE', 'en', 'LABEL', 'To Date') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE', 'zh', 'LABEL', '结束日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_TO_DATE', 'ja', 'LABEL', '終了日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATED_BY', 'ko', 'LABEL', '대결') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATED_BY', 'en', 'LABEL', 'Delegated by') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATED_BY', 'zh', 'LABEL', '代审') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_APPROVAL_DELEGATED_BY', 'ja', 'LABEL', '代決') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_NEW', 'ko', 'LABEL', '새 글 작성') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_NEW', 'en', 'LABEL', 'New Post') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_NEW', 'zh', 'LABEL', '新建帖子') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_NEW', 'ja', 'LABEL', '新規投稿') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_EDIT', 'ko', 'LABEL', '게시글 수정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_EDIT', 'en', 'LABEL', 'Edit Post') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_EDIT', 'zh', 'LABEL', '编辑帖子') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_FORM_EDIT', 'ja', 'LABEL', '投稿編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_BOARD', 'ko', 'LABEL', '게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_BOARD', 'en', 'LABEL', 'Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_BOARD', 'zh', 'LABEL', '公告板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_BOARD', 'ja', 'LABEL', '掲示板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TITLE_REQ', 'ko', 'LABEL', '제목 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TITLE_REQ', 'en', 'LABEL', 'Title *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TITLE_REQ', 'zh', 'LABEL', '标题 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TITLE_REQ', 'ja', 'LABEL', 'タイトル *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_CONTENT', 'ko', 'LABEL', '내용') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_CONTENT', 'en', 'LABEL', 'Content') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_CONTENT', 'zh', 'LABEL', '内容') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_CONTENT', 'ja', 'LABEL', '内容') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_PIN', 'ko', 'LABEL', '상단 고정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_PIN', 'en', 'LABEL', 'Pin to Top') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_PIN', 'zh', 'LABEL', '置顶') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_PIN', 'ja', 'LABEL', '固定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_ATTACHMENT', 'ko', 'LABEL', '첨부 파일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_ATTACHMENT', 'en', 'LABEL', 'Attachments') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_ATTACHMENT', 'zh', 'LABEL', '附件') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_ATTACHMENT', 'ja', 'LABEL', '添付ファイル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_NOTICE', 'ko', 'LABEL', '공지사항') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_NOTICE', 'en', 'LABEL', 'Notice') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_NOTICE', 'zh', 'LABEL', '公告') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_NOTICE', 'ja', 'LABEL', 'お知らせ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_GENERAL', 'ko', 'LABEL', '일반') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_GENERAL', 'en', 'LABEL', 'General') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_GENERAL', 'zh', 'LABEL', '一般') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_GENERAL', 'ja', 'LABEL', '一般') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_FREE', 'ko', 'LABEL', '자유게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_FREE', 'en', 'LABEL', 'Free Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_FREE', 'zh', 'LABEL', '自由论坛') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_FREE', 'ja', 'LABEL', '自由掲示板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_DEPT', 'ko', 'LABEL', '부서게시판') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_DEPT', 'en', 'LABEL', 'Dept Board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_DEPT', 'zh', 'LABEL', '部门论坛') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_DEPT', 'ja', 'LABEL', '部署掲示板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ARCHIVE', 'ko', 'LABEL', '자료실') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ARCHIVE', 'en', 'LABEL', 'Archive') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ARCHIVE', 'zh', 'LABEL', '资料室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ARCHIVE', 'ja', 'LABEL', '資料室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ALL', 'ko', 'LABEL', '전체') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ALL', 'en', 'LABEL', 'All') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ALL', 'zh', 'LABEL', '全部') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_BOARD_TYPE_ALL', 'ja', 'LABEL', '全体') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_ALL', 'ko', 'LABEL', '전체') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_ALL', 'en', 'LABEL', 'All') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_ALL', 'zh', 'LABEL', '全部') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_ALL', 'ja', 'LABEL', '全体') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_PERSONAL', 'ko', 'LABEL', '개인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_PERSONAL', 'en', 'LABEL', 'Personal') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_PERSONAL', 'zh', 'LABEL', '个人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_PERSONAL', 'ja', 'LABEL', '個人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_DEPT', 'ko', 'LABEL', '부서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_DEPT', 'en', 'LABEL', 'Department') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_DEPT', 'zh', 'LABEL', '部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_DEPT', 'ja', 'LABEL', '部署') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_COMPANY', 'ko', 'LABEL', '회사') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_COMPANY', 'en', 'LABEL', 'Company') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_COMPANY', 'zh', 'LABEL', '公司') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CAL_SCOPE_COMPANY', 'ja', 'LABEL', '会社') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_THIS_MONTH', 'ko', 'LABEL', '이번 달 출근 현황') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_THIS_MONTH', 'en', 'LABEL', 'This Month Attendance') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_THIS_MONTH', 'zh', 'LABEL', '本月考勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_THIS_MONTH', 'ja', 'LABEL', '今月の勤怠') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_IN_AT', 'ko', 'LABEL', '출근') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_IN_AT', 'en', 'LABEL', 'Check-in') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_IN_AT', 'zh', 'LABEL', '签到') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_IN_AT', 'ja', 'LABEL', '出勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_OUT_AT', 'ko', 'LABEL', '퇴근') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_OUT_AT', 'en', 'LABEL', 'Check-out') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_OUT_AT', 'zh', 'LABEL', '签退') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_CHECK_OUT_AT', 'ja', 'LABEL', '退勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_TIME', 'ko', 'LABEL', '근무') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_TIME', 'en', 'LABEL', 'Work') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_TIME', 'zh', 'LABEL', '工作') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_TIME', 'ja', 'LABEL', '勤務') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_DAYS', 'ko', 'LABEL', '출근일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_DAYS', 'en', 'LABEL', 'Work Days') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_DAYS', 'zh', 'LABEL', '出勤日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_WORK_DAYS', 'ja', 'LABEL', '出勤日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_TOTAL_TIME', 'ko', 'LABEL', '총 근무시간') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_TOTAL_TIME', 'en', 'LABEL', 'Total Work Time') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_TOTAL_TIME', 'zh', 'LABEL', '总工时') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_TOTAL_TIME', 'ja', 'LABEL', '総労働時間') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_AVG_TIME', 'ko', 'LABEL', '평균 근무') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_AVG_TIME', 'en', 'LABEL', 'Avg Work') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_AVG_TIME', 'zh', 'LABEL', '平均工时') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_AVG_TIME', 'ja', 'LABEL', '平均勤務') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LATE_DAYS', 'ko', 'LABEL', '지각') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LATE_DAYS', 'en', 'LABEL', 'Late') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LATE_DAYS', 'zh', 'LABEL', '迟到') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LATE_DAYS', 'ja', 'LABEL', '遅刻') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LEAVE_DAYS', 'ko', 'LABEL', '휴가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LEAVE_DAYS', 'en', 'LABEL', 'Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LEAVE_DAYS', 'zh', 'LABEL', '休假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_LEAVE_DAYS', 'ja', 'LABEL', '休暇') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_DAY_SUFFIX', 'ko', 'LABEL', '일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_DAY_SUFFIX', 'en', 'LABEL', 'd') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_DAY_SUFFIX', 'zh', 'LABEL', '天') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_ATT_DAY_SUFFIX', 'ja', 'LABEL', '日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_HISTORY', 'ko', 'LABEL', '휴가 신청 이력') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_HISTORY', 'en', 'LABEL', 'Leave Request History') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_HISTORY', 'zh', 'LABEL', '休假申请记录') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_HISTORY', 'ja', 'LABEL', '休暇申請履歴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_YEAR_SELECT', 'ko', 'LABEL', '조회 연도') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_YEAR_SELECT', 'en', 'LABEL', 'Year') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_YEAR_SELECT', 'zh', 'LABEL', '年度') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_YEAR_SELECT', 'ja', 'LABEL', '照会年度') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_EMPTY', 'ko', 'LABEL', '등록된 휴가 신청이 없습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_EMPTY', 'en', 'LABEL', 'No leave requests') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_EMPTY', 'zh', 'LABEL', '无休假申请记录') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_LEAVE_EMPTY', 'ja', 'LABEL', '登録された休暇申請がありません') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_NEW', 'ko', 'LABEL', '사용자 추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_NEW', 'en', 'LABEL', 'Add User') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_NEW', 'zh', 'LABEL', '添加用户') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_NEW', 'ja', 'LABEL', 'ユーザー追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_EDIT', 'ko', 'LABEL', '사용자 수정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_EDIT', 'en', 'LABEL', 'Edit User') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_EDIT', 'zh', 'LABEL', '编辑用户') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_FORM_EDIT', 'ja', 'LABEL', 'ユーザー編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NAME_REQ', 'ko', 'LABEL', '이름 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NAME_REQ', 'en', 'LABEL', 'Name *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NAME_REQ', 'zh', 'LABEL', '姓名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NAME_REQ', 'ja', 'LABEL', '氏名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NO_REQ', 'ko', 'LABEL', '사번 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NO_REQ', 'en', 'LABEL', 'Emp. No. *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NO_REQ', 'zh', 'LABEL', '工号 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_NO_REQ', 'ja', 'LABEL', '社員番号 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_EMAIL', 'ko', 'LABEL', '이메일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_EMAIL', 'en', 'LABEL', 'Email') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_EMAIL', 'zh', 'LABEL', '邮箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_EMAIL', 'ja', 'LABEL', 'メール') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_PHONE', 'ko', 'LABEL', '전화') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_PHONE', 'en', 'LABEL', 'Phone') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_PHONE', 'zh', 'LABEL', '电话') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_PHONE', 'ja', 'LABEL', '電話') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_DEPT_REQ', 'ko', 'LABEL', '부서 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_DEPT_REQ', 'en', 'LABEL', 'Department *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_DEPT_REQ', 'zh', 'LABEL', '部门 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_DEPT_REQ', 'ja', 'LABEL', '部署 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_POSITION_REQ', 'ko', 'LABEL', '직책 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_POSITION_REQ', 'en', 'LABEL', 'Position *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_POSITION_REQ', 'zh', 'LABEL', '职位 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_POSITION_REQ', 'ja', 'LABEL', '役職 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_KC_USERNAME', 'ko', 'LABEL', 'Keycloak username') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_KC_USERNAME', 'en', 'LABEL', 'Keycloak Username') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_KC_USERNAME', 'zh', 'LABEL', 'Keycloak 用户名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_KC_USERNAME', 'ja', 'LABEL', 'Keycloak ユーザー名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_ROLES', 'ko', 'LABEL', '역할') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_ROLES', 'en', 'LABEL', 'Roles') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_ROLES', 'zh', 'LABEL', '角色') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_USER_ROLES', 'ja', 'LABEL', '役割') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_USER_NAME', 'ko', 'LABEL', '일반 사용자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_USER_NAME', 'en', 'LABEL', 'User') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_USER_NAME', 'zh', 'LABEL', '普通用户') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_USER_NAME', 'ja', 'LABEL', '一般ユーザー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_APPROVER_NAME', 'ko', 'LABEL', '결재자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_APPROVER_NAME', 'en', 'LABEL', 'Approver') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_APPROVER_NAME', 'zh', 'LABEL', '审批人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_APPROVER_NAME', 'ja', 'LABEL', '決裁者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_MANAGER_NAME', 'ko', 'LABEL', '부서장') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_MANAGER_NAME', 'en', 'LABEL', 'Manager') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_MANAGER_NAME', 'zh', 'LABEL', '部门主管') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_MANAGER_NAME', 'ja', 'LABEL', '部署長') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_ADMIN_NAME', 'ko', 'LABEL', '관리자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_ADMIN_NAME', 'en', 'LABEL', 'Admin') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_ADMIN_NAME', 'zh', 'LABEL', '管理员') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('ROLE_ADMIN_NAME', 'ja', 'LABEL', '管理者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NEW', 'ko', 'LABEL', '새 부서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NEW', 'en', 'LABEL', 'New Department') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NEW', 'zh', 'LABEL', '新建部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NEW', 'ja', 'LABEL', '新規部署') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_EDIT', 'ko', 'LABEL', '부서 편집') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_EDIT', 'en', 'LABEL', 'Edit Department') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_EDIT', 'zh', 'LABEL', '编辑部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_EDIT', 'ja', 'LABEL', '部署編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SELECT_HINT', 'ko', 'LABEL', '부서를 선택하거나 추가하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SELECT_HINT', 'en', 'LABEL', 'Select or add a department') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SELECT_HINT', 'zh', 'LABEL', '选择或添加部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SELECT_HINT', 'ja', 'LABEL', '部署を選択または追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_CODE_REQ', 'ko', 'LABEL', '부서코드 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_CODE_REQ', 'en', 'LABEL', 'Dept Code *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_CODE_REQ', 'zh', 'LABEL', '部门代码 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_CODE_REQ', 'ja', 'LABEL', '部署コード *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NAME_REQ', 'ko', 'LABEL', '부서명 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NAME_REQ', 'en', 'LABEL', 'Dept Name *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NAME_REQ', 'zh', 'LABEL', '部门名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_NAME_REQ', 'ja', 'LABEL', '部署名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_PARENT', 'ko', 'LABEL', '상위 부서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_PARENT', 'en', 'LABEL', 'Parent Dept') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_PARENT', 'zh', 'LABEL', '上级部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_PARENT', 'ja', 'LABEL', '上位部署') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_LEVEL', 'ko', 'LABEL', '레벨') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_LEVEL', 'en', 'LABEL', 'Level') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_LEVEL', 'zh', 'LABEL', '级别') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_LEVEL', 'ja', 'LABEL', 'レベル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SORT', 'ko', 'LABEL', '정렬순서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SORT', 'en', 'LABEL', 'Sort Order') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SORT', 'zh', 'LABEL', '排序') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_SORT', 'ja', 'LABEL', '並び順') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_USE', 'ko', 'LABEL', '사용') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_USE', 'en', 'LABEL', 'Use') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_USE', 'zh', 'LABEL', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_DEPT_USE', 'ja', 'LABEL', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NEW', 'ko', 'LABEL', '새 메뉴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NEW', 'en', 'LABEL', 'New Menu') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NEW', 'zh', 'LABEL', '新建菜单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NEW', 'ja', 'LABEL', '新規メニュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_EDIT', 'ko', 'LABEL', '메뉴 편집') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_EDIT', 'en', 'LABEL', 'Edit Menu') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_EDIT', 'zh', 'LABEL', '编辑菜单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_EDIT', 'ja', 'LABEL', 'メニュー編集') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SELECT_HINT', 'ko', 'LABEL', '메뉴를 선택하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SELECT_HINT', 'en', 'LABEL', 'Select a menu') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SELECT_HINT', 'zh', 'LABEL', '选择菜单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SELECT_HINT', 'ja', 'LABEL', 'メニューを選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ID_REQ', 'ko', 'LABEL', '메뉴 ID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ID_REQ', 'en', 'LABEL', 'Menu ID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ID_REQ', 'zh', 'LABEL', '菜单ID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ID_REQ', 'ja', 'LABEL', 'メニューID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NAME_REQ', 'ko', 'LABEL', '메뉴명 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NAME_REQ', 'en', 'LABEL', 'Menu Name *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NAME_REQ', 'zh', 'LABEL', '菜单名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_NAME_REQ', 'ja', 'LABEL', 'メニュー名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PATH', 'ko', 'LABEL', '경로') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PATH', 'en', 'LABEL', 'Path') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PATH', 'zh', 'LABEL', '路径') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PATH', 'ja', 'LABEL', 'パス') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PARENT', 'ko', 'LABEL', '상위 메뉴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PARENT', 'en', 'LABEL', 'Parent Menu') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PARENT', 'zh', 'LABEL', '上级菜单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PARENT', 'ja', 'LABEL', '上位メニュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_LEVEL', 'ko', 'LABEL', '레벨') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_LEVEL', 'en', 'LABEL', 'Level') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_LEVEL', 'zh', 'LABEL', '级别') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_LEVEL', 'ja', 'LABEL', 'レベル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SORT', 'ko', 'LABEL', '정렬순서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SORT', 'en', 'LABEL', 'Sort Order') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SORT', 'zh', 'LABEL', '排序') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_SORT', 'ja', 'LABEL', '並び順') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ICON', 'ko', 'LABEL', '아이콘') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ICON', 'en', 'LABEL', 'Icon') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ICON', 'zh', 'LABEL', '图标') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_ICON', 'ja', 'LABEL', 'アイコン') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_USE', 'ko', 'LABEL', '사용') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_USE', 'en', 'LABEL', 'Use') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_USE', 'zh', 'LABEL', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_USE', 'ja', 'LABEL', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_MATRIX', 'ko', 'LABEL', '권한 매트릭스') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_MATRIX', 'en', 'LABEL', 'Permission Matrix') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_MATRIX', 'zh', 'LABEL', '权限矩阵') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_MATRIX', 'ja', 'LABEL', '権限マトリクス') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_SELECTED', 'ko', 'LABEL', '선택 메뉴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_SELECTED', 'en', 'LABEL', 'Selected Menu') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_SELECTED', 'zh', 'LABEL', '选中菜单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_SELECTED', 'ja', 'LABEL', '選択メニュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_ALL', 'ko', 'LABEL', '(전체 메뉴)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_ALL', 'en', 'LABEL', '(All Menus)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_ALL', 'zh', 'LABEL', '(全部菜单)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_MENU_PERM_ALL', 'ja', 'LABEL', '(全メニュー)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NEW_GROUP', 'ko', 'LABEL', '새 그룹 추가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NEW_GROUP', 'en', 'LABEL', 'Add New Group') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NEW_GROUP', 'zh', 'LABEL', '添加新组') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NEW_GROUP', 'ja', 'LABEL', '新グループ追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_ID_REQ', 'ko', 'LABEL', '그룹 ID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_ID_REQ', 'en', 'LABEL', 'Group ID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_ID_REQ', 'zh', 'LABEL', '组ID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_ID_REQ', 'ja', 'LABEL', 'グループID *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_FIRST_REQ', 'ko', 'LABEL', '첫 코드 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_FIRST_REQ', 'en', 'LABEL', 'First Code *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_FIRST_REQ', 'zh', 'LABEL', '首代码 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_FIRST_REQ', 'ja', 'LABEL', '最初のコード *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NAME_REQ', 'ko', 'LABEL', '코드명 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NAME_REQ', 'en', 'LABEL', 'Code Name *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NAME_REQ', 'zh', 'LABEL', '代码名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_NAME_REQ', 'ja', 'LABEL', 'コード名 *') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_HINT', 'ko', 'LABEL', '그룹을 선택하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_HINT', 'en', 'LABEL', 'Select a group') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_HINT', 'zh', 'LABEL', '选择组') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_CODE_GROUP_HINT', 'ja', 'LABEL', 'グループを選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_DETAIL_HEADER', 'ko', 'LABEL', '감사 로그 상세') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_DETAIL_HEADER', 'en', 'LABEL', 'Audit Log Detail') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_DETAIL_HEADER', 'zh', 'LABEL', '审计日志详情') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_DETAIL_HEADER', 'ja', 'LABEL', '監査ログ詳細') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TIME', 'ko', 'LABEL', '시각') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TIME', 'en', 'LABEL', 'Time') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TIME', 'zh', 'LABEL', '时间') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TIME', 'ja', 'LABEL', '時刻') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_BEFORE', 'ko', 'LABEL', '입력 (before)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_BEFORE', 'en', 'LABEL', 'Input (before)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_BEFORE', 'zh', 'LABEL', '输入 (前)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_BEFORE', 'ja', 'LABEL', '入力 (before)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_AFTER', 'ko', 'LABEL', '결과 (after)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_AFTER', 'en', 'LABEL', 'Result (after)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_AFTER', 'zh', 'LABEL', '结果 (后)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_AFTER', 'ja', 'LABEL', '結果 (after)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_NONE', 'ko', 'LABEL', '(없음)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_NONE', 'en', 'LABEL', '(none)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_NONE', 'zh', 'LABEL', '(无)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_NONE', 'ja', 'LABEL', '(なし)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TARGET', 'ko', 'LABEL', '대상') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TARGET', 'en', 'LABEL', 'Target') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TARGET', 'zh', 'LABEL', '对象') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LBL_AUDIT_TARGET', 'ja', 'LABEL', '対象') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_INPUT_REQUIRED', 'ko', 'MSG', '입력 필요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_INPUT_REQUIRED', 'en', 'MSG', 'Input required') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_INPUT_REQUIRED', 'zh', 'MSG', '需要输入') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_INPUT_REQUIRED', 'ja', 'MSG', '入力必須') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_LOAD_FAILED', 'ko', 'MSG', '조회 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_LOAD_FAILED', 'en', 'MSG', 'Load failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_LOAD_FAILED', 'zh', 'MSG', '加载失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_LOAD_FAILED', 'ja', 'MSG', '照会失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_DONE', 'ko', 'MSG', '저장 완료') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_DONE', 'en', 'MSG', 'Saved') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_DONE', 'zh', 'MSG', '已保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_DONE', 'ja', 'MSG', '保存完了') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_FAILED', 'ko', 'MSG', '저장 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_FAILED', 'en', 'MSG', 'Save failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_FAILED', 'zh', 'MSG', '保存失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_SAVE_FAILED', 'ja', 'MSG', '保存失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_DONE', 'ko', 'MSG', '삭제 완료') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_DONE', 'en', 'MSG', 'Deleted') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_DONE', 'zh', 'MSG', '已删除') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_DONE', 'ja', 'MSG', '削除完了') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_FAILED', 'ko', 'MSG', '삭제 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_FAILED', 'en', 'MSG', 'Delete failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_FAILED', 'zh', 'MSG', '删除失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DELETE_FAILED', 'ja', 'MSG', '削除失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_NO_CHANGES', 'ko', 'MSG', '변경된 항목 없음') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_NO_CHANGES', 'en', 'MSG', 'No changes') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_NO_CHANGES', 'zh', 'MSG', '无更改') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_NO_CHANGES', 'ja', 'MSG', '変更なし') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_NAME_NO_REQ', 'ko', 'MSG', '이름/사번은 필수입니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_NAME_NO_REQ', 'en', 'MSG', 'Name and employee no. are required.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_NAME_NO_REQ', 'zh', 'MSG', '姓名/工号必填。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_NAME_NO_REQ', 'ja', 'MSG', '氏名/番号は必須です。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_DEPT_POS_REQ', 'ko', 'MSG', '부서/직책을 선택하세요.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_DEPT_POS_REQ', 'en', 'MSG', 'Select department and position.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_DEPT_POS_REQ', 'zh', 'MSG', '请选择部门/职位。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_DEPT_POS_REQ', 'ja', 'MSG', '部署/役職を選択してください。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TOGGLE_CONFIRM', 'ko', 'MSG', '''{name}''의 활성 상태를 토글합니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TOGGLE_CONFIRM', 'en', 'MSG', 'Toggle active status of ''{name}''.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TOGGLE_CONFIRM', 'zh', 'MSG', '切换''{name}''的激活状态。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TOGGLE_CONFIRM', 'ja', 'MSG', '''{name}''の有効状態を切替します。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_RESET_PWD_CONFIRM', 'ko', 'MSG', '''{name}''의 비밀번호를 임시 비밀번호로 초기화합니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_RESET_PWD_CONFIRM', 'en', 'MSG', 'Reset password of ''{name}'' to a temporary one.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MYWORK', 'ko', 'MENU', '내 업무') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_RESET_PWD_CONFIRM', 'zh', 'MSG', '将''{name}''的密码重置为临时密码。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_RESET_PWD_CONFIRM', 'ja', 'MSG', '''{name}''のパスワードを一時パスワードに初期化します。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TEMP_PASSWORD', 'ko', 'MSG', '임시 비밀번호: {pwd}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TEMP_PASSWORD', 'en', 'MSG', 'Temporary password: {pwd}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TEMP_PASSWORD', 'zh', 'MSG', '临时密码: {pwd}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_TEMP_PASSWORD', 'ja', 'MSG', '一時パスワード: {pwd}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_KC_NOT_SET', 'ko', 'MSG', 'Keycloak username 미설정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_KC_NOT_SET', 'en', 'MSG', 'Keycloak username not set') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_KC_NOT_SET', 'zh', 'MSG', '未设置 Keycloak 用户名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_KC_NOT_SET', 'ja', 'MSG', 'Keycloak ユーザー名未設定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_CHANGED', 'ko', 'MSG', '상태 변경됨') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_CHANGED', 'en', 'MSG', 'Status changed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_CHANGED', 'zh', 'MSG', '状态已更改') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_CHANGED', 'ja', 'MSG', '状態変更') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_FAILED', 'ko', 'MSG', '변경 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_FAILED', 'en', 'MSG', 'Change failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_FAILED', 'zh', 'MSG', '更改失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_STATUS_FAILED', 'ja', 'MSG', '変更失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET', 'ko', 'MSG', '비밀번호 초기화') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET', 'en', 'MSG', 'Password reset') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET', 'zh', 'MSG', '密码重置') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET', 'ja', 'MSG', 'パスワード初期化') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET_FAILED', 'ko', 'MSG', '초기화 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET_FAILED', 'en', 'MSG', 'Reset failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET_FAILED', 'zh', 'MSG', '重置失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_USER_PWD_RESET_FAILED', 'ja', 'MSG', '初期化失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_REQ', 'ko', 'MSG', '부서코드/부서명은 필수.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_REQ', 'en', 'MSG', 'Dept code and name are required.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_REQ', 'zh', 'MSG', '部门代码/部门名必填。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_REQ', 'ja', 'MSG', '部署コード/部署名は必須。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_DELETE_CONFIRM', 'ko', 'MSG', '''{name}'' 부서를 삭제합니다. 하위 부서/소속 직원이 있으면 실패합니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_DELETE_CONFIRM', 'en', 'MSG', 'Delete department ''{name}''. Will fail if it has children or members.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_DELETE_CONFIRM', 'zh', 'MSG', '删除部门 ''{name}''。若有子部门/成员将失败。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_DEPT_DELETE_CONFIRM', 'ja', 'MSG', '部署 ''{name}'' を削除します。下位部署/所属社員があれば失敗します。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_REQ', 'ko', 'MSG', '메뉴ID/메뉴명은 필수.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_REQ', 'en', 'MSG', 'Menu ID and name are required.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_REQ', 'zh', 'MSG', '菜单ID/菜单名必填。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_REQ', 'ja', 'MSG', 'メニューID/メニュー名は必須。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_DELETE_CONFIRM', 'ko', 'MSG', '''{name}'' 메뉴를 삭제합니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_DELETE_CONFIRM', 'en', 'MSG', 'Delete menu ''{name}''.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_DELETE_CONFIRM', 'zh', 'MSG', '删除菜单 ''{name}''。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_DELETE_CONFIRM', 'ja', 'MSG', 'メニュー ''{name}'' を削除します。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_PERM_SAVED', 'ko', 'MSG', '권한 저장됨') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_PERM_SAVED', 'en', 'MSG', 'Permissions saved') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_PERM_SAVED', 'zh', 'MSG', '权限已保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_MENU_PERM_SAVED', 'ja', 'MSG', '権限保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_DELETE_CONFIRM', 'ko', 'MSG', '''{code}'' 코드를 삭제합니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_DELETE_CONFIRM', 'en', 'MSG', 'Delete code ''{code}''.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_DELETE_CONFIRM', 'zh', 'MSG', '删除代码 ''{code}''。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_DELETE_CONFIRM', 'ja', 'MSG', 'コード ''{code}'' を削除します。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ALL_REQ', 'ko', 'MSG', '모든 항목 필수.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ALL_REQ', 'en', 'MSG', 'All fields are required.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ALL_REQ', 'zh', 'MSG', '全部必填。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ALL_REQ', 'ja', 'MSG', '全項目必須。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_GROUP_ADDED', 'ko', 'MSG', '그룹 추가됨') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_GROUP_ADDED', 'en', 'MSG', 'Group added') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_GROUP_ADDED', 'zh', 'MSG', '已添加组') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_GROUP_ADDED', 'ja', 'MSG', 'グループ追加') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ADD_FAILED', 'ko', 'MSG', '추가 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ADD_FAILED', 'en', 'MSG', 'Add failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ADD_FAILED', 'zh', 'MSG', '添加失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CODE_ADD_FAILED', 'ja', 'MSG', '追加失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_REASON_REQ', 'ko', 'MSG', '반려 사유를 입력하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_REASON_REQ', 'en', 'MSG', 'Please enter rejection reason') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_REASON_REQ', 'zh', 'MSG', '请输入退回理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_REASON_REQ', 'ja', 'MSG', '却下理由を入力してください') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_CONFIRM', 'ko', 'MSG', '이 문서를 회수하시겠습니까? DRAFT 상태로 되돌아갑니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_CONFIRM', 'en', 'MSG', 'Withdraw this document? It will return to DRAFT.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_CONFIRM', 'zh', 'MSG', '是否撤回此文档？将回到草稿状态。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_CONFIRM', 'ja', 'MSG', 'この文書を取下げますか？ DRAFT 状態に戻ります。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_CONFIRM', 'ko', 'MSG', '반려된 문서를 재상신하시겠습니까? 새 문서 버전이 생성됩니다.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_CONFIRM', 'en', 'MSG', 'Resubmit rejected document? A new version will be created.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_CONFIRM', 'zh', 'MSG', '是否重新提交被退回的文档？将创建新版本。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_CONFIRM', 'ja', 'MSG', '却下文書を再起案しますか？ 新しい版が作成されます。') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_DONE', 'ko', 'MSG', '재상신 완료. 신규 docId={id}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_DONE', 'en', 'MSG', 'Resubmitted. New docId={id}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_DONE', 'zh', 'MSG', '重新提交完成。新docId={id}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_DONE', 'ja', 'MSG', '再起案完了。新docId={id}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_REQ', 'ko', 'MSG', '대리자 / 시작일 / 종료일은 필수입니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_REQ', 'en', 'MSG', 'Delegatee / from / to dates are required') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_REQ', 'zh', 'MSG', '代审人 / 开始日 / 结束日必填') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_REQ', 'ja', 'MSG', '代理者 / 開始日 / 終了日は必須です') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_DONE', 'ko', 'MSG', '대결 등록 완료') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_DONE', 'en', 'MSG', 'Delegate registered') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_DONE', 'zh', 'MSG', '代审登记完成') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_DONE', 'ja', 'MSG', '代決登録完了') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_FORM_REQ', 'ko', 'MSG', '양식을 선택하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MYWORK', 'en', 'MENU', 'My Work') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_FORM_REQ', 'en', 'MSG', 'Please select a form') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_FORM_REQ', 'zh', 'MSG', '请选择表单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_FORM_REQ', 'ja', 'MSG', '様式を選択してください') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_TITLE_REQ', 'ko', 'MSG', '제목을 입력하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_TITLE_REQ', 'en', 'MSG', 'Please enter title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_TITLE_REQ', 'zh', 'MSG', '请输入标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_TITLE_REQ', 'ja', 'MSG', 'タイトルを入力してください') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_LEAVE_TYPE_REQ', 'ko', 'MSG', '휴가 유형을 선택하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_LEAVE_TYPE_REQ', 'en', 'MSG', 'Please select leave type') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_LEAVE_TYPE_REQ', 'zh', 'MSG', '请选择休假类型') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_LEAVE_TYPE_REQ', 'ja', 'MSG', '休暇種別を選択してください') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_REQ', 'ko', 'MSG', '시작일/종료일을 선택하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_REQ', 'en', 'MSG', 'Select from/to dates') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_REQ', 'zh', 'MSG', '请选择开始/结束日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_REQ', 'ja', 'MSG', '開始日/終了日を選択してください') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_ORDER', 'ko', 'MSG', '종료일은 시작일 이후여야 합니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_ORDER', 'en', 'MSG', 'To date must be after from date') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_ORDER', 'zh', 'MSG', '结束日须晚于开始日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DATE_ORDER', 'ja', 'MSG', '終了日は開始日以降である必要があります') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DAYS_ZERO', 'ko', 'MSG', '일수가 0입니다. 날짜를 다시 확인하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DAYS_ZERO', 'en', 'MSG', 'Days is 0. Please re-check dates') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DAYS_ZERO', 'zh', 'MSG', '天数为 0。请重新检查日期') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DAYS_ZERO', 'ja', 'MSG', '日数が 0 です。日付を再確認してください') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_DONE', 'ko', 'MSG', '상신 완료. 문서번호 {id} (결재자 {n}명)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_DONE', 'en', 'MSG', 'Submitted. Doc No. {id} ({n} approvers)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_DONE', 'zh', 'MSG', '提交完成。文档号 {id} ({n}位审批人)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_DONE', 'ja', 'MSG', '起案完了。文書番号 {id} (決裁者 {n}名)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_FAILED', 'ko', 'MSG', '상신 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_FAILED', 'en', 'MSG', 'Submit failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_FAILED', 'zh', 'MSG', '提交失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_SUBMIT_FAILED', 'ja', 'MSG', '起案失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVE_FAILED', 'ko', 'MSG', '승인 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVE_FAILED', 'en', 'MSG', 'Approve failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVE_FAILED', 'zh', 'MSG', '批准失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_APPROVE_FAILED', 'ja', 'MSG', '承認失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_FAILED', 'ko', 'MSG', '반려 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_FAILED', 'en', 'MSG', 'Reject failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_FAILED', 'zh', 'MSG', '退回失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_REJECT_FAILED', 'ja', 'MSG', '却下失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_FAILED', 'ko', 'MSG', '회수 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_FAILED', 'en', 'MSG', 'Withdraw failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_FAILED', 'zh', 'MSG', '撤回失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_WITHDRAW_FAILED', 'ja', 'MSG', '取下げ失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_FAILED', 'ko', 'MSG', '재상신 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_FAILED', 'en', 'MSG', 'Resubmit failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_FAILED', 'zh', 'MSG', '重新提交失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_RESUBMIT_FAILED', 'ja', 'MSG', '再起案失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_FAILED', 'ko', 'MSG', '대결 등록 실패') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_FAILED', 'en', 'MSG', 'Delegate registration failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_FAILED', 'zh', 'MSG', '代审登记失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_APPROVAL_DELEGATE_FAILED', 'ja', 'MSG', '代決登録失敗') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_TITLE_REQ', 'ko', 'MSG', '제목을 입력하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_TITLE_REQ', 'en', 'MSG', 'Please enter title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_TITLE_REQ', 'zh', 'MSG', '请输入标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_TITLE_REQ', 'ja', 'MSG', 'タイトルを入力してください') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_DONE', 'ko', 'MSG', '게시글이 등록되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_DONE', 'en', 'MSG', 'Post created') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_DONE', 'zh', 'MSG', '帖子已发布') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_DONE', 'ja', 'MSG', '投稿が登録されました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_UPDATE_DONE', 'ko', 'MSG', '게시글이 수정되었습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_UPDATE_DONE', 'en', 'MSG', 'Post updated') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_UPDATE_DONE', 'zh', 'MSG', '帖子已更新') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_UPDATE_DONE', 'ja', 'MSG', '投稿が修正されました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_FAILED', 'ko', 'MSG', '저장에 실패했습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_FAILED', 'en', 'MSG', 'Save failed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_FAILED', 'zh', 'MSG', '保存失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_BOARD_SAVE_FAILED', 'ja', 'MSG', '保存に失敗しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CAL_MOVE_FAILED', 'ko', 'MSG', '일정 이동에 실패했습니다') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CAL_MOVE_FAILED', 'en', 'MSG', 'Failed to move event') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CAL_MOVE_FAILED', 'zh', 'MSG', '移动日程失败') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_CAL_MOVE_FAILED', 'ja', 'MSG', '予定の移動に失敗しました') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_IN_FAILED', 'ko', 'MSG', '출근 실패: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_IN_FAILED', 'en', 'MSG', 'Check-in failed: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_IN_FAILED', 'zh', 'MSG', '签到失败: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_IN_FAILED', 'ja', 'MSG', '出勤失敗: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_OUT_FAILED', 'ko', 'MSG', '퇴근 실패: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_OUT_FAILED', 'en', 'MSG', 'Check-out failed: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_OUT_FAILED', 'zh', 'MSG', '签退失败: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MSG_ATT_CHECK_OUT_FAILED', 'ja', 'MSG', '退勤失敗: {err}') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MYWORK', 'zh', 'MENU', '我的工作') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_MYWORK', 'ja', 'MENU', 'マイワーク') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORK', 'ko', 'MENU', '업무') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORK', 'en', 'MENU', 'Work') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORK', 'zh', 'MENU', '业务') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORK', 'ja', 'MENU', '業務') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_GROUP', 'ko', 'MENU', '설정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_GROUP', 'en', 'MENU', 'Settings') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_GROUP', 'zh', 'MENU', '设置') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_GROUP', 'ja', 'MENU', '設定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN', 'ko', 'MENU', '시스템관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN', 'en', 'MENU', 'Admin') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN', 'zh', 'MENU', '系统管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN', 'ja', 'MENU', 'システム管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SEARCH', 'ko', 'MENU', '통합검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SEARCH', 'en', 'MENU', 'Search') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SEARCH', 'zh', 'MENU', '综合搜索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SEARCH', 'ja', 'MENU', '統合検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ATTENDANCE', 'ko', 'MENU', '근태') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ATTENDANCE', 'en', 'MENU', 'Attendance') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ATTENDANCE', 'zh', 'MENU', '考勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ATTENDANCE', 'ja', 'MENU', '勤怠') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_LEAVE', 'ko', 'MENU', '연차/휴가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_LEAVE', 'en', 'MENU', 'Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_LEAVE', 'zh', 'MENU', '年假/休假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_LEAVE', 'ja', 'MENU', '年次/休暇') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORKLOG', 'ko', 'MENU', '업무일지') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORKLOG', 'en', 'MENU', 'Work Log') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORKLOG', 'zh', 'MENU', '工作日志') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_WORKLOG', 'ja', 'MENU', '業務日誌') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ROOM', 'ko', 'MENU', '회의실예약') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ROOM', 'en', 'MENU', 'Room Booking') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ROOM', 'zh', 'MENU', '会议室预订') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ROOM', 'ja', 'MENU', '会議室予約') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DATALIB', 'ko', 'MENU', '자료실') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DATALIB', 'en', 'MENU', 'Data Library') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DATALIB', 'zh', 'MENU', '资料室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_DATALIB', 'ja', 'MENU', '資料室') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_NOTIFY', 'ko', 'MENU', '알림설정') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_NOTIFY', 'en', 'MENU', 'Notification Settings') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_NOTIFY', 'zh', 'MENU', '通知设置') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_NOTIFY', 'ja', 'MENU', '通知設定') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_FAV', 'ko', 'MENU', '즐겨찾기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_FAV', 'en', 'MENU', 'Favorites') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_FAV', 'zh', 'MENU', '收藏夹') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_SETTINGS_FAV', 'ja', 'MENU', 'お気に入り') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_USERS', 'ko', 'MENU', '사용자관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_USERS', 'en', 'MENU', 'User Management') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_USERS', 'zh', 'MENU', '用户管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_USERS', 'ja', 'MENU', 'ユーザー管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_DEPTS', 'ko', 'MENU', '조직관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_DEPTS', 'en', 'MENU', 'Department Management') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_DEPTS', 'zh', 'MENU', '组织管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_DEPTS', 'ja', 'MENU', '組織管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_MENUS', 'ko', 'MENU', '메뉴관리') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_MENUS', 'en', 'MENU', 'Menu Management') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_MENUS', 'zh', 'MENU', '菜单管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_MENUS', 'ja', 'MENU', 'メニュー管理') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_CODES', 'ko', 'MENU', '공통코드') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_CODES', 'en', 'MENU', 'Common Codes') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_CODES', 'zh', 'MENU', '公共代码') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_CODES', 'ja', 'MENU', '共通コード') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_AUDIT', 'ko', 'MENU', '감사로그') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_AUDIT', 'en', 'MENU', 'Audit Log') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_AUDIT', 'zh', 'MENU', '审计日志') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('MENU_ADMIN_AUDIT', 'ja', 'MENU', '監査ログ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_NO', 'ko', 'GRID_COL', '번호') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_NO', 'en', 'GRID_COL', 'No.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_NO', 'zh', 'GRID_COL', '编号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_NO', 'ja', 'GRID_COL', '番号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_TITLE', 'ko', 'GRID_COL', '제목') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_TITLE', 'en', 'GRID_COL', 'Title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_TITLE', 'zh', 'GRID_COL', '标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_TITLE', 'ja', 'GRID_COL', 'タイトル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFTER', 'ko', 'GRID_COL', '기안자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFTER', 'en', 'GRID_COL', 'Drafter') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFTER', 'zh', 'GRID_COL', '起草人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFTER', 'ja', 'GRID_COL', '起案者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DEPT', 'ko', 'GRID_COL', '부서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DEPT', 'en', 'GRID_COL', 'Dept') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DEPT', 'zh', 'GRID_COL', '部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DEPT', 'ja', 'GRID_COL', '部署') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_STATUS', 'ko', 'GRID_COL', '상태') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_STATUS', 'en', 'GRID_COL', 'Status') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_STATUS', 'zh', 'GRID_COL', '状态') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_STATUS', 'ja', 'GRID_COL', '状態') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFT_AT', 'ko', 'GRID_COL', '기안일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFT_AT', 'en', 'GRID_COL', 'Drafted At') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFT_AT', 'zh', 'GRID_COL', '起草日期') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_APPROVAL_DRAFT_AT', 'ja', 'GRID_COL', '起案日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_NO', 'ko', 'GRID_COL', '번호') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_NO', 'en', 'GRID_COL', 'No.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_NO', 'zh', 'GRID_COL', '编号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_NO', 'ja', 'GRID_COL', '番号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TITLE', 'ko', 'GRID_COL', '제목') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TITLE', 'en', 'GRID_COL', 'Title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TITLE', 'zh', 'GRID_COL', '标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TITLE', 'ja', 'GRID_COL', 'タイトル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TYPE', 'ko', 'GRID_COL', '분류') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TYPE', 'en', 'GRID_COL', 'Category') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TYPE', 'zh', 'GRID_COL', '分类') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_TYPE', 'ja', 'GRID_COL', '分類') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_AUTHOR', 'ko', 'GRID_COL', '작성자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_AUTHOR', 'en', 'GRID_COL', 'Author') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_AUTHOR', 'zh', 'GRID_COL', '作者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_AUTHOR', 'ja', 'GRID_COL', '作成者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_VIEWS', 'ko', 'GRID_COL', '조회') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_VIEWS', 'en', 'GRID_COL', 'Views') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_VIEWS', 'zh', 'GRID_COL', '浏览') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_VIEWS', 'ja', 'GRID_COL', '閲覧') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_CREATED_AT', 'ko', 'GRID_COL', '작성일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_CREATED_AT', 'en', 'GRID_COL', 'Created') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_CREATED_AT', 'zh', 'GRID_COL', '创建日期') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_BOARD_CREATED_AT', 'ja', 'GRID_COL', '作成日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NO', 'ko', 'GRID_COL', '사번') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NO', 'en', 'GRID_COL', 'Emp. No.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NO', 'zh', 'GRID_COL', '工号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NO', 'ja', 'GRID_COL', '社員番号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NAME', 'ko', 'GRID_COL', '이름') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NAME', 'en', 'GRID_COL', 'Name') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NAME', 'zh', 'GRID_COL', '姓名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_NAME', 'ja', 'GRID_COL', '氏名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_DEPT', 'ko', 'GRID_COL', '부서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_DEPT', 'en', 'GRID_COL', 'Department') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_DEPT', 'zh', 'GRID_COL', '部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_DEPT', 'ja', 'GRID_COL', '部署') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_POSITION', 'ko', 'GRID_COL', '직책') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_POSITION', 'en', 'GRID_COL', 'Position') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_POSITION', 'zh', 'GRID_COL', '职位') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_POSITION', 'ja', 'GRID_COL', '役職') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_EMAIL', 'ko', 'GRID_COL', '이메일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_EMAIL', 'en', 'GRID_COL', 'Email') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_EMAIL', 'zh', 'GRID_COL', '邮箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_EMAIL', 'ja', 'GRID_COL', 'メール') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_KC_USERNAME', 'ko', 'GRID_COL', 'KC username') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_KC_USERNAME', 'en', 'GRID_COL', 'KC Username') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_KC_USERNAME', 'zh', 'GRID_COL', 'KC 用户名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_KC_USERNAME', 'ja', 'GRID_COL', 'KC ユーザー名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_STATUS', 'ko', 'GRID_COL', '상태') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_STATUS', 'en', 'GRID_COL', 'Status') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_STATUS', 'zh', 'GRID_COL', '状态') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_STATUS', 'ja', 'GRID_COL', '状態') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_ACTIONS', 'ko', 'GRID_COL', '작업') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_ACTIONS', 'en', 'GRID_COL', 'Actions') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_ACTIONS', 'zh', 'GRID_COL', '操作') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_USER_ACTIONS', 'ja', 'GRID_COL', '操作') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_GROUP', 'ko', 'GRID_COL', '그룹') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_GROUP', 'en', 'GRID_COL', 'Group') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_GROUP', 'zh', 'GRID_COL', '组') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_GROUP', 'ja', 'GRID_COL', 'グループ') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_CODE', 'ko', 'GRID_COL', '코드') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_CODE', 'en', 'GRID_COL', 'Code') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_CODE', 'zh', 'GRID_COL', '代码') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_CODE', 'ja', 'GRID_COL', 'コード') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_NAME', 'ko', 'GRID_COL', '코드명') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_NAME', 'en', 'GRID_COL', 'Code Name') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_NAME', 'zh', 'GRID_COL', '代码名称') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_NAME', 'ja', 'GRID_COL', 'コード名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_SORT', 'ko', 'GRID_COL', '순서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_SORT', 'en', 'GRID_COL', 'Order') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_SORT', 'zh', 'GRID_COL', '顺序') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_SORT', 'ja', 'GRID_COL', '順序') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_USE', 'ko', 'GRID_COL', '사용') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_USE', 'en', 'GRID_COL', 'Use') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_USE', 'zh', 'GRID_COL', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_USE', 'ja', 'GRID_COL', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_ACTIONS', 'ko', 'GRID_COL', '작업') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_ACTIONS', 'en', 'GRID_COL', 'Actions') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_ACTIONS', 'zh', 'GRID_COL', '操作') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_CODE_ACTIONS', 'ja', 'GRID_COL', '操作') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ID', 'ko', 'GRID_COL', 'ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ID', 'en', 'GRID_COL', 'ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ID', 'zh', 'GRID_COL', 'ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ID', 'ja', 'GRID_COL', 'ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TIME', 'ko', 'GRID_COL', '작업시각') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TIME', 'en', 'GRID_COL', 'Acted At') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TIME', 'zh', 'GRID_COL', '操作时间') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TIME', 'ja', 'GRID_COL', '操作時刻') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NO', 'ko', 'GRID_COL', '작업자') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NO', 'en', 'GRID_COL', 'Actor') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NO', 'zh', 'GRID_COL', '操作者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NO', 'ja', 'GRID_COL', '操作者') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NAME', 'ko', 'GRID_COL', '이름') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NAME', 'en', 'GRID_COL', 'Name') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NAME', 'zh', 'GRID_COL', '姓名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTOR_NAME', 'ja', 'GRID_COL', '氏名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTION', 'ko', 'GRID_COL', '액션') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTION', 'en', 'GRID_COL', 'Action') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTION', 'zh', 'GRID_COL', '操作') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_ACTION', 'ja', 'GRID_COL', 'アクション') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_TYPE', 'ko', 'GRID_COL', '대상유형') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_TYPE', 'en', 'GRID_COL', 'Target Type') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_TYPE', 'zh', 'GRID_COL', '对象类型') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_TYPE', 'ja', 'GRID_COL', '対象種別') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_ID', 'ko', 'GRID_COL', '대상ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_ID', 'en', 'GRID_COL', 'Target ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_ID', 'zh', 'GRID_COL', '对象ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_TARGET_ID', 'ja', 'GRID_COL', '対象ID') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_IP', 'ko', 'GRID_COL', 'IP') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_IP', 'en', 'GRID_COL', 'IP') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_IP', 'zh', 'GRID_COL', 'IP') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_AUDIT_IP', 'ja', 'GRID_COL', 'IP') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ROLE', 'ko', 'GRID_COL', '역할') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ROLE', 'en', 'GRID_COL', 'Role') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ROLE', 'zh', 'GRID_COL', '角色') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ROLE', 'ja', 'GRID_COL', '役割') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ID', 'ko', 'GRID_COL', '메뉴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ID', 'en', 'GRID_COL', 'Menu') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ID', 'zh', 'GRID_COL', '菜单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_ID', 'ja', 'GRID_COL', 'メニュー') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_NAME', 'ko', 'GRID_COL', '메뉴명') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_NAME', 'en', 'GRID_COL', 'Menu Name') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_NAME', 'zh', 'GRID_COL', '菜单名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_MENU_NAME', 'ja', 'GRID_COL', 'メニュー名') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_NO', 'ko', 'GRID_COL', '번호') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_NO', 'en', 'GRID_COL', 'No.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_NO', 'zh', 'GRID_COL', '编号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_NO', 'ja', 'GRID_COL', '番号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_TYPE', 'ko', 'GRID_COL', '유형') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_TYPE', 'en', 'GRID_COL', 'Type') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_TYPE', 'zh', 'GRID_COL', '类型') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_TYPE', 'ja', 'GRID_COL', '種別') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_PERIOD', 'ko', 'GRID_COL', '기간') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_PERIOD', 'en', 'GRID_COL', 'Period') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_PERIOD', 'zh', 'GRID_COL', '期间') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_PERIOD', 'ja', 'GRID_COL', '期間') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_DAYS', 'ko', 'GRID_COL', '일수') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_DAYS', 'en', 'GRID_COL', 'Days') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_DAYS', 'zh', 'GRID_COL', '天数') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_DAYS', 'ja', 'GRID_COL', '日数') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_REASON', 'ko', 'GRID_COL', '사유') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_REASON', 'en', 'GRID_COL', 'Reason') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_REASON', 'zh', 'GRID_COL', '理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_REASON', 'ja', 'GRID_COL', '理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_STATUS', 'ko', 'GRID_COL', '상태') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_STATUS', 'en', 'GRID_COL', 'Status') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_STATUS', 'zh', 'GRID_COL', '状态') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_STATUS', 'ja', 'GRID_COL', '状態') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_APPLIED_AT', 'ko', 'GRID_COL', '신청일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_APPLIED_AT', 'en', 'GRID_COL', 'Applied At') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_APPLIED_AT', 'zh', 'GRID_COL', '申请日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('COL_LEAVE_APPLIED_AT', 'ja', 'GRID_COL', '申請日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_SEARCH', 'ko', 'PLACEHOLDER', '제목·기안자 검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_SEARCH', 'en', 'PLACEHOLDER', 'Search title or drafter') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_SEARCH', 'zh', 'PLACEHOLDER', '搜索标题或起草人') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_SEARCH', 'ja', 'PLACEHOLDER', 'タイトル・起案者検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SELECT', 'ko', 'PLACEHOLDER', '게시판 선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SELECT', 'en', 'PLACEHOLDER', 'Select board') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SELECT', 'zh', 'PLACEHOLDER', '选择公告板') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SELECT', 'ja', 'PLACEHOLDER', '掲示板選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SEARCH', 'ko', 'PLACEHOLDER', '검색어') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SEARCH', 'en', 'PLACEHOLDER', 'Keyword') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SEARCH', 'zh', 'PLACEHOLDER', '关键词') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_BOARD_SEARCH', 'ja', 'PLACEHOLDER', '検索語') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_USER_SEARCH', 'ko', 'PLACEHOLDER', '이름/사번/이메일 검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_USER_SEARCH', 'en', 'PLACEHOLDER', 'Search name/no/email') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_USER_SEARCH', 'zh', 'PLACEHOLDER', '搜索姓名/工号/邮箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_USER_SEARCH', 'ja', 'PLACEHOLDER', '氏名/番号/メール検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_STATUS_SELECT', 'ko', 'PLACEHOLDER', '상태') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_STATUS_SELECT', 'en', 'PLACEHOLDER', 'Status') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_STATUS_SELECT', 'zh', 'PLACEHOLDER', '状态') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_STATUS_SELECT', 'ja', 'PLACEHOLDER', '状態') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTOR', 'ko', 'PLACEHOLDER', '작업자 사번') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTOR', 'en', 'PLACEHOLDER', 'Actor employee no.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTOR', 'zh', 'PLACEHOLDER', '操作者工号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTOR', 'ja', 'PLACEHOLDER', '操作者番号') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTION', 'ko', 'PLACEHOLDER', '액션 (예: admin/userSave)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTION', 'en', 'PLACEHOLDER', 'Action (e.g. admin/userSave)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTION', 'zh', 'PLACEHOLDER', '操作 (例: admin/userSave)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_AUDIT_ACTION', 'ja', 'PLACEHOLDER', 'アクション (例: admin/userSave)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DATE_RANGE', 'ko', 'PLACEHOLDER', '기간') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DATE_RANGE', 'en', 'PLACEHOLDER', 'Date range') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DATE_RANGE', 'zh', 'PLACEHOLDER', '期间') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DATE_RANGE', 'ja', 'PLACEHOLDER', '期間') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GROUP_SEARCH', 'ko', 'PLACEHOLDER', '그룹 검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GROUP_SEARCH', 'en', 'PLACEHOLDER', 'Search groups') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GROUP_SEARCH', 'zh', 'PLACEHOLDER', '搜索组') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_GROUP_SEARCH', 'ja', 'PLACEHOLDER', 'グループ検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DEPT_SELECT', 'ko', 'PLACEHOLDER', '부서 선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DEPT_SELECT', 'en', 'PLACEHOLDER', 'Select department') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DEPT_SELECT', 'zh', 'PLACEHOLDER', '选择部门') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DEPT_SELECT', 'ja', 'PLACEHOLDER', '部署選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POSITION_SELECT', 'ko', 'PLACEHOLDER', '직책 선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POSITION_SELECT', 'en', 'PLACEHOLDER', 'Select position') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POSITION_SELECT', 'zh', 'PLACEHOLDER', '选择职位') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POSITION_SELECT', 'ja', 'PLACEHOLDER', '役職選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROLES_SELECT', 'ko', 'PLACEHOLDER', '역할 선택') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROLES_SELECT', 'en', 'PLACEHOLDER', 'Select roles') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROLES_SELECT', 'zh', 'PLACEHOLDER', '选择角色') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ROLES_SELECT', 'ja', 'PLACEHOLDER', '役割選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_FORM_SELECT', 'ko', 'PLACEHOLDER', '양식을 선택하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_FORM_SELECT', 'en', 'PLACEHOLDER', 'Select form') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_FORM_SELECT', 'zh', 'PLACEHOLDER', '选择表单') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_FORM_SELECT', 'ja', 'PLACEHOLDER', '様式を選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DOC_TITLE', 'ko', 'PLACEHOLDER', '문서 제목') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DOC_TITLE', 'en', 'PLACEHOLDER', 'Document title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DOC_TITLE', 'zh', 'PLACEHOLDER', '文档标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DOC_TITLE', 'ja', 'PLACEHOLDER', '文書タイトル') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_TYPE_SELECT', 'ko', 'PLACEHOLDER', '유형을 선택하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_TYPE_SELECT', 'en', 'PLACEHOLDER', 'Select leave type') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_TYPE_SELECT', 'zh', 'PLACEHOLDER', '选择休假类型') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_TYPE_SELECT', 'ja', 'PLACEHOLDER', '休暇タイプを選択') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_REASON', 'ko', 'PLACEHOLDER', '휴가 사유') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_REASON', 'en', 'PLACEHOLDER', 'Leave reason') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_REASON', 'zh', 'PLACEHOLDER', '休假理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_LEAVE_REASON', 'ja', 'PLACEHOLDER', '休暇理由') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_CONTENT', 'ko', 'PLACEHOLDER', '결재 본문을 입력하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_CONTENT', 'en', 'PLACEHOLDER', 'Enter approval content') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_CONTENT', 'zh', 'PLACEHOLDER', '输入审批正文') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_APPROVAL_CONTENT', 'ja', 'PLACEHOLDER', '決裁本文を入力') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_COMMENT', 'ko', 'PLACEHOLDER', '의견을 입력하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_COMMENT', 'en', 'PLACEHOLDER', 'Enter comment') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_COMMENT', 'zh', 'PLACEHOLDER', '输入意见') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_COMMENT', 'ja', 'PLACEHOLDER', '意見を入力') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATEE_NO', 'ko', 'PLACEHOLDER', '예: E0010') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATEE_NO', 'en', 'PLACEHOLDER', 'e.g. E0010') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATEE_NO', 'zh', 'PLACEHOLDER', '例: E0010') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATEE_NO', 'ja', 'PLACEHOLDER', '例: E0010') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATE_REASON', 'ko', 'PLACEHOLDER', '휴가 / 출장 등') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATE_REASON', 'en', 'PLACEHOLDER', 'Leave / Business trip etc.') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATE_REASON', 'zh', 'PLACEHOLDER', '休假 / 出差 等') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_DELEGATE_REASON', 'ja', 'PLACEHOLDER', '休暇 / 出張 など') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_TITLE', 'ko', 'PLACEHOLDER', '제목을 입력하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_TITLE', 'en', 'PLACEHOLDER', 'Enter title') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_TITLE', 'zh', 'PLACEHOLDER', '输入标题') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_TITLE', 'ja', 'PLACEHOLDER', 'タイトルを入力') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_CONTENT', 'ko', 'PLACEHOLDER', '내용을 입력하세요') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_CONTENT', 'en', 'PLACEHOLDER', 'Enter content') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_CONTENT', 'zh', 'PLACEHOLDER', '输入内容') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_POST_CONTENT', 'ja', 'PLACEHOLDER', '内容を入力') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_TREE_ROOT_NONE', 'ko', 'PLACEHOLDER', '(루트)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_TREE_ROOT_NONE', 'en', 'PLACEHOLDER', '(root)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_TREE_ROOT_NONE', 'zh', 'PLACEHOLDER', '(根)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_TREE_ROOT_NONE', 'ja', 'PLACEHOLDER', '(ルート)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_PATH', 'ko', 'PLACEHOLDER', '/example') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_PATH', 'en', 'PLACEHOLDER', '/example') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_PATH', 'zh', 'PLACEHOLDER', '/example') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_PATH', 'ja', 'PLACEHOLDER', '/example') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_ICON', 'ko', 'PLACEHOLDER', 'pi pi-folder') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_ICON', 'en', 'PLACEHOLDER', 'pi pi-folder') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_ICON', 'zh', 'PLACEHOLDER', 'pi pi-folder') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_MENU_ICON', 'ja', 'PLACEHOLDER', 'pi pi-folder') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ORG_SEARCH', 'ko', 'PLACEHOLDER', '이름/직책 검색') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ORG_SEARCH', 'en', 'PLACEHOLDER', 'Search name or position') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ORG_SEARCH', 'zh', 'PLACEHOLDER', '搜索姓名或职位') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('PH_ORG_SEARCH', 'ja', 'PLACEHOLDER', '氏名/役職検索') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_DRAFT', 'ko', 'STATUS', '임시') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_DRAFT', 'en', 'STATUS', 'Draft') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_DRAFT', 'zh', 'STATUS', '草稿') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_DRAFT', 'ja', 'STATUS', '一時保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_PENDING', 'ko', 'STATUS', '대기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_PENDING', 'en', 'STATUS', 'Pending') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_PENDING', 'zh', 'STATUS', '待审批') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_PENDING', 'ja', 'STATUS', '保留') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_IN_PROGRESS', 'ko', 'STATUS', '진행') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_IN_PROGRESS', 'en', 'STATUS', 'In Progress') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_IN_PROGRESS', 'zh', 'STATUS', '审批中') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_IN_PROGRESS', 'ja', 'STATUS', '進行中') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_APPROVED', 'ko', 'STATUS', '완료') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_APPROVED', 'en', 'STATUS', 'Approved') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_APPROVED', 'zh', 'STATUS', '已批准') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_APPROVED', 'ja', 'STATUS', '完了') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_REJECTED', 'ko', 'STATUS', '반려') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_REJECTED', 'en', 'STATUS', 'Rejected') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_REJECTED', 'zh', 'STATUS', '已退回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_DOC_REJECTED', 'ja', 'STATUS', '却下') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_PENDING', 'ko', 'STATUS', '대기') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_PENDING', 'en', 'STATUS', 'Pending') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_PENDING', 'zh', 'STATUS', '待审批') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_PENDING', 'ja', 'STATUS', '保留') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_APPROVED', 'ko', 'STATUS', '승인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_APPROVED', 'en', 'STATUS', 'Approved') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_APPROVED', 'zh', 'STATUS', '批准') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_APPROVED', 'ja', 'STATUS', '承認') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_REJECTED', 'ko', 'STATUS', '반려') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_REJECTED', 'en', 'STATUS', 'Rejected') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_REJECTED', 'zh', 'STATUS', '退回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_REJECTED', 'ja', 'STATUS', '却下') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_SKIPPED', 'ko', 'STATUS', '전결') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_SKIPPED', 'en', 'STATUS', 'Final Approval') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_SKIPPED', 'zh', 'STATUS', '终审') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_APP_LINE_SKIPPED', 'ja', 'STATUS', '専決') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NORMAL', 'ko', 'STATUS', '정상') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NORMAL', 'en', 'STATUS', 'Normal') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NORMAL', 'zh', 'STATUS', '正常') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NORMAL', 'ja', 'STATUS', '正常') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LATE', 'ko', 'STATUS', '지각') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LATE', 'en', 'STATUS', 'Late') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LATE', 'zh', 'STATUS', '迟到') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LATE', 'ja', 'STATUS', '遅刻') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_EARLY', 'ko', 'STATUS', '조퇴') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_EARLY', 'en', 'STATUS', 'Early Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_EARLY', 'zh', 'STATUS', '早退') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_EARLY', 'ja', 'STATUS', '早退') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_ABSENT', 'ko', 'STATUS', '결근') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_ABSENT', 'en', 'STATUS', 'Absent') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_ABSENT', 'zh', 'STATUS', '缺勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_ABSENT', 'ja', 'STATUS', '欠勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_HOLIDAY', 'ko', 'STATUS', '공휴일') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_HOLIDAY', 'en', 'STATUS', 'Holiday') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_HOLIDAY', 'zh', 'STATUS', '公休') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_HOLIDAY', 'ja', 'STATUS', '祝日') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LEAVE', 'ko', 'STATUS', '휴가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LEAVE', 'en', 'STATUS', 'Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LEAVE', 'zh', 'STATUS', '休假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_LEAVE', 'ja', 'STATUS', '休暇') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NOT_CHECKED', 'ko', 'STATUS', '미출근') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NOT_CHECKED', 'en', 'STATUS', 'Not Checked') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NOT_CHECKED', 'zh', 'STATUS', '未签到') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_ATT_NOT_CHECKED', 'ja', 'STATUS', '未出勤') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_PENDING', 'ko', 'STATUS', '결재중') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_PENDING', 'en', 'STATUS', 'In Approval') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_PENDING', 'zh', 'STATUS', '审批中') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_PENDING', 'ja', 'STATUS', '決裁中') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_APPROVED', 'ko', 'STATUS', '승인') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_APPROVED', 'en', 'STATUS', 'Approved') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_APPROVED', 'zh', 'STATUS', '批准') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_APPROVED', 'ja', 'STATUS', '承認') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_REJECTED', 'ko', 'STATUS', '반려') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_REJECTED', 'en', 'STATUS', 'Rejected') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_REJECTED', 'zh', 'STATUS', '退回') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_REJECTED', 'ja', 'STATUS', '却下') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_CANCELLED', 'ko', 'STATUS', '취소') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_CANCELLED', 'en', 'STATUS', 'Cancelled') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_CANCELLED', 'zh', 'STATUS', '取消') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_LEAVE_CANCELLED', 'ja', 'STATUS', '取消') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_ACTIVE', 'ko', 'STATUS', '활성') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_ACTIVE', 'en', 'STATUS', 'Active') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_ACTIVE', 'zh', 'STATUS', '活跃') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_ACTIVE', 'ja', 'STATUS', '有効') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_INACTIVE', 'ko', 'STATUS', '비활성') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_INACTIVE', 'en', 'STATUS', 'Inactive') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_INACTIVE', 'zh', 'STATUS', '停用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USER_INACTIVE', 'ja', 'STATUS', '無効') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_Y', 'ko', 'STATUS', '사용') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_Y', 'en', 'STATUS', 'Use') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_Y', 'zh', 'STATUS', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_Y', 'ja', 'STATUS', '使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_N', 'ko', 'STATUS', '미사용') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_N', 'en', 'STATUS', 'Unused') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_N', 'zh', 'STATUS', '停用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('STATUS_USE_N', 'ja', 'STATUS', '未使用') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE', 'ko', 'FORM', '휴가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE', 'en', 'FORM', 'Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE', 'zh', 'FORM', '休假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE', 'ja', 'FORM', '休暇') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE', 'ko', 'FORM', '지출') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE', 'en', 'FORM', 'Expense') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE', 'zh', 'FORM', '支出') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE', 'ja', 'FORM', '支出') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE', 'ko', 'FORM', '구매') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE', 'en', 'FORM', 'Purchase') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE', 'zh', 'FORM', '采购') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE', 'ja', 'FORM', '購買') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP', 'ko', 'FORM', '출장') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP', 'en', 'FORM', 'Business Trip') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP', 'zh', 'FORM', '出差') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP', 'ja', 'FORM', '出張') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_CONTRACT', 'ko', 'FORM', '계약') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_CONTRACT', 'en', 'FORM', 'Contract') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_CONTRACT', 'zh', 'FORM', '合同') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_CONTRACT', 'ja', 'FORM', '契約') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_HR', 'ko', 'FORM', '인사') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_HR', 'en', 'FORM', 'HR') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_HR', 'zh', 'FORM', '人事') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_HR', 'ja', 'FORM', '人事') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_IT', 'ko', 'FORM', 'IT') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_IT', 'en', 'FORM', 'IT') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_IT', 'zh', 'FORM', 'IT') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_IT', 'ja', 'FORM', 'IT') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE_FULL', 'ko', 'FORM', '휴가신청서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE_FULL', 'en', 'FORM', 'Leave Request') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE_FULL', 'zh', 'FORM', '休假申请') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_LEAVE_FULL', 'ja', 'FORM', '休暇申請書') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE_FULL', 'ko', 'FORM', '지출결의서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE_FULL', 'en', 'FORM', 'Expense Request') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE_FULL', 'zh', 'FORM', '支出申请') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_EXPENSE_FULL', 'ja', 'FORM', '支出決議書') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE_FULL', 'ko', 'FORM', '구매요청서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE_FULL', 'en', 'FORM', 'Purchase Request') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE_FULL', 'zh', 'FORM', '采购申请') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_PURCHASE_FULL', 'ja', 'FORM', '購買申請書') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP_FULL', 'ko', 'FORM', '출장신청서') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP_FULL', 'en', 'FORM', 'Business Trip Request') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP_FULL', 'zh', 'FORM', '出差申请') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('FORM_BIZTRIP_FULL', 'ja', 'FORM', '出張申請書') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DRAFT', 'ko', 'BOX', '임시저장') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DRAFT', 'en', 'BOX', 'Drafts') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DRAFT', 'zh', 'BOX', '草稿') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DRAFT', 'ja', 'BOX', '一時保存') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_MY_DOCS', 'ko', 'BOX', '기안함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_MY_DOCS', 'en', 'BOX', 'My Documents') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_MY_DOCS', 'zh', 'BOX', '我的草稿') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_MY_DOCS', 'ja', 'BOX', '起案箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_PENDING', 'ko', 'BOX', '대기함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_PENDING', 'en', 'BOX', 'Pending') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_PENDING', 'zh', 'BOX', '待办箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_PENDING', 'ja', 'BOX', '保留箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_IN_PROGRESS', 'ko', 'BOX', '진행함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_IN_PROGRESS', 'en', 'BOX', 'In Progress') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_IN_PROGRESS', 'zh', 'BOX', '进行中') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_IN_PROGRESS', 'ja', 'BOX', '進行箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_COMPLETED', 'ko', 'BOX', '완료함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_COMPLETED', 'en', 'BOX', 'Completed') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_COMPLETED', 'zh', 'BOX', '已完成') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_COMPLETED', 'ja', 'BOX', '完了箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_REJECTED', 'ko', 'BOX', '반려함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_REJECTED', 'en', 'BOX', 'Rejected') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_REJECTED', 'zh', 'BOX', '退回箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_REJECTED', 'ja', 'BOX', '却下箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_RECEIVED', 'ko', 'BOX', '수신함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_RECEIVED', 'en', 'BOX', 'Received') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_RECEIVED', 'zh', 'BOX', '收件箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_RECEIVED', 'ja', 'BOX', '受信箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_CC_BOX', 'ko', 'BOX', '참조함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_CC_BOX', 'en', 'BOX', 'CC') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_CC_BOX', 'zh', 'BOX', '抄送') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_CC_BOX', 'ja', 'BOX', '参照箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DEPT_BOX', 'ko', 'BOX', '부서함') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DEPT_BOX', 'en', 'BOX', 'Department Box') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DEPT_BOX', 'zh', 'BOX', '部门箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('BOX_DEPT_BOX', 'ja', 'BOX', '部署箱') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_ANNUAL', 'ko', 'LEAVE_TYPE', '연차') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_ANNUAL', 'en', 'LEAVE_TYPE', 'Annual') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_ANNUAL', 'zh', 'LEAVE_TYPE', '年假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_ANNUAL', 'ja', 'LEAVE_TYPE', '年次') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_AM', 'ko', 'LEAVE_TYPE', '오전반차') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_AM', 'en', 'LEAVE_TYPE', 'Half Day (AM)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_AM', 'zh', 'LEAVE_TYPE', '上午半天') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_AM', 'ja', 'LEAVE_TYPE', '午前半休') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_PM', 'ko', 'LEAVE_TYPE', '오후반차') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_PM', 'en', 'LEAVE_TYPE', 'Half Day (PM)') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_PM', 'zh', 'LEAVE_TYPE', '下午半天') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_HALF_PM', 'ja', 'LEAVE_TYPE', '午後半休') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_SICK', 'ko', 'LEAVE_TYPE', '병가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_SICK', 'en', 'LEAVE_TYPE', 'Sick Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_SICK', 'zh', 'LEAVE_TYPE', '病假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_SICK', 'ja', 'LEAVE_TYPE', '病気休暇') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_FAMILY', 'ko', 'LEAVE_TYPE', '경조사') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_FAMILY', 'en', 'LEAVE_TYPE', 'Family Event') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_FAMILY', 'zh', 'LEAVE_TYPE', '婚丧假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_FAMILY', 'ja', 'LEAVE_TYPE', '慶弔休暇') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_UNPAID', 'ko', 'LEAVE_TYPE', '무급휴가') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_UNPAID', 'en', 'LEAVE_TYPE', 'Unpaid Leave') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_UNPAID', 'zh', 'LEAVE_TYPE', '无薪假') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message) VALUES ('LEAVE_TYPE_UNPAID', 'ja', 'LEAVE_TYPE', '無給休暇') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cm_i18n_message ENABLE TRIGGER ALL;

--
-- Data for Name: cm_menu; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cm_menu DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('dashboard', '대시보드', '/dashboard', NULL, 1, 1, 'pi pi-th-large', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('approval', '전자결재', '/approval', NULL, 1, 2, 'pi pi-file-edit', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('board', '게시판', '/board', NULL, 1, 3, 'pi pi-comment', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('calendar', '캘린더', '/calendar', NULL, 1, 4, 'pi pi-calendar', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('org', '조직도', '/org', NULL, 1, 5, 'pi pi-sitemap', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('messenger', '메신저', '/messenger', NULL, 1, 6, 'pi pi-send', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('mail', '메일', '/mail', NULL, 1, 7, 'pi pi-inbox', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('wiki', '위키', '/wiki', NULL, 1, 8, 'pi pi-book', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('video', '화상회의', '/video', NULL, 1, 9, 'pi pi-video', 'Y', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('mywork', '내 업무', NULL, NULL, 1, 10, 'pi pi-briefcase', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('work', '업무', NULL, NULL, 1, 20, 'pi pi-folder', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('settings', '설정', NULL, NULL, 1, 80, 'pi pi-cog', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('admin', '시스템관리', NULL, NULL, 1, 90, 'pi pi-shield', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('search', '통합검색', '/search', NULL, 1, 5, 'pi pi-search', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('attendance', '근태', '/attendance', 'mywork', 2, 11, 'pi pi-clock', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('leave', '연차/휴가', '/leave', 'mywork', 2, 12, 'pi pi-calendar-plus', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('worklog', '업무일지', '/worklog', 'mywork', 2, 13, 'pi pi-pencil', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('room', '회의실예약', '/room', 'work', 2, 21, 'pi pi-users', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('datalib', '자료실', '/datalib', 'work', 2, 22, 'pi pi-folder-open', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('settings_notify', '알림설정', '/settings/notify', 'settings', 2, 81, 'pi pi-bell', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('settings_fav', '즐겨찾기', '/settings/favorites', 'settings', 2, 82, 'pi pi-star', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('admin_users', '사용자관리', '/admin/users', 'admin', 2, 91, 'pi pi-user-plus', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('admin_depts', '조직관리', '/admin/depts', 'admin', 2, 92, 'pi pi-sitemap', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('admin_menus', '메뉴관리', '/admin/menus', 'admin', 2, 93, 'pi pi-bars', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('admin_codes', '공통코드', '/admin/codes', 'admin', 2, 94, 'pi pi-list', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon, use_yn, created_at) VALUES ('admin_audit', '감사로그', '/admin/audit', 'admin', 2, 95, 'pi pi-history', 'Y', '2026-04-26 19:13:48.168874+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cm_menu ENABLE TRIGGER ALL;

--
-- Data for Name: cm_notification; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cm_notification DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cm_notification (notification_id, recipient_id, doc_id, notification_type, channel, title, content, is_read, read_at, created_at) VALUES (1, 10, NULL, 'SYSTEM', 'WEB', 'openplatform v3 에 오신 것을 환영합니다', '첫 로그인 환영 메시지', 'N', NULL, '2026-04-26 19:01:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_notification (notification_id, recipient_id, doc_id, notification_type, channel, title, content, is_read, read_at, created_at) VALUES (2, 10, 1, 'APPROVAL', 'WEB', '결재 요청 - 휴가 신청서', '결재 대기 중', 'N', NULL, '2026-04-26 18:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_notification (notification_id, recipient_id, doc_id, notification_type, channel, title, content, is_read, read_at, created_at) VALUES (3, 10, 2, 'APPROVAL', 'WEB', '결재 승인 - 지출 품의', '승인 완료', 'Y', NULL, '2026-04-25 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_notification (notification_id, recipient_id, doc_id, notification_type, channel, title, content, is_read, read_at, created_at) VALUES (4, 10, NULL, 'BOARD', 'WEB', '새 공지가 등록되었습니다', '[필독] openplatform v3 런칭 안내', 'N', NULL, '2026-04-26 13:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_notification (notification_id, recipient_id, doc_id, notification_type, channel, title, content, is_read, read_at, created_at) VALUES (5, 10, NULL, 'MENTION', 'WEB', '메신저에서 언급되었습니다', '@user1 오늘 점심 같이', 'N', NULL, '2026-04-26 18:36:51.169529+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cm_notification ENABLE TRIGGER ALL;

--
-- Data for Name: cm_role; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cm_role DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cm_role (role_id, role_name, description, created_at) VALUES ('ROLE_USER', '일반 사용자', '전 직원 기본 권한', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role (role_id, role_name, description, created_at) VALUES ('ROLE_APPROVER', '결재자', '결재 권한 보유', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role (role_id, role_name, description, created_at) VALUES ('ROLE_MANAGER', '부서장', '부서 관리 권한', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role (role_id, role_name, description, created_at) VALUES ('ROLE_ADMIN', '관리자', '시스템 전체 관리', '2026-04-26 19:06:51.224338+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cm_role ENABLE TRIGGER ALL;

--
-- Data for Name: cm_role_menu; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.cm_role_menu DISABLE TRIGGER ALL;

INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'dashboard', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'approval', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'board', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'calendar', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'org', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'messenger', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'mail', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'wiki', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'video', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'dashboard', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'approval', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'board', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'calendar', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'org', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'messenger', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'mail', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'wiki', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'video', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'mywork', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'work', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'settings', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'search', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'attendance', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'leave', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'worklog', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'room', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'datalib', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'settings_notify', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_USER', 'settings_fav', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'mywork', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'work', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'settings', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'search', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'attendance', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'leave', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'worklog', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'room', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'datalib', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'settings_notify', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_MANAGER', 'settings_fav', true, true, true, false, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'mywork', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'work', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'settings', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'admin', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'search', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'attendance', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'leave', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'worklog', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'room', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'datalib', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'settings_notify', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'settings_fav', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'admin_users', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'admin_depts', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'admin_menus', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'admin_codes', true, true, true, true, true, true) ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.cm_role_menu (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print) VALUES ('ROLE_ADMIN', 'admin_audit', true, true, true, true, true, true) ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.cm_role_menu ENABLE TRIGGER ALL;

--
-- Data for Name: db_widget; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.db_widget DISABLE TRIGGER ALL;

INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('ATTENDANCE', '출퇴근', '오늘 출/퇴근 + 근무시간', 4, 1, 'PERSONAL', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('LEAVE_BALANCE', '연차 잔여', '잔여/총 일수 도넛', 4, 1, 'PERSONAL', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('PENDING_APPROVAL', '미결 결재', '내 미결 결재 카운트', 4, 1, 'WORK', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('TODAY_EVENTS', '오늘 일정', '오늘 캘린더 이벤트', 6, 1, 'WORK', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('NOTICES', '최근 공지', '게시판 NOTICE 5건', 6, 1, 'WORK', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('MESSENGER_UNREAD', '메신저', 'Rocket.Chat unread DM', 4, 1, 'WORK', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('MY_ROOMS', '다가오는 회의', '내 회의실 예약 3건', 6, 1, 'WORK', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('TEAM_WORKLOG', '팀 업무일지', '부서원 5명 × 오늘 업무일지 (부서장)', 12, 1, 'TEAM', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_widget (widget_code, title, description, default_w, default_h, category, active, created_at, updated_at) VALUES ('CHART_LEAVE_USAGE', '연차 사용 추이', '월별 연차 사용 막대 그래프', 6, 2, 'PERSONAL', true, '2026-04-26 19:13:48.09671+00', '2026-04-26 19:13:48.09671+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.db_widget ENABLE TRIGGER ALL;

--
-- Data for Name: db_user_widget; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.db_user_widget DISABLE TRIGGER ALL;

INSERT INTO platform_v3.db_user_widget (id, employee_no, widget_code, pos_x, pos_y, width, height, config_json, sort_order, created_at, updated_at) VALUES (1, 'E0001', 'ATTENDANCE', 0, 0, 4, 1, NULL, 0, '2026-04-26 19:56:46.56527+00', '2026-04-26 19:56:46.56527+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_user_widget (id, employee_no, widget_code, pos_x, pos_y, width, height, config_json, sort_order, created_at, updated_at) VALUES (2, 'E0001', 'LEAVE_BALANCE', 4, 0, 4, 1, NULL, 1, '2026-04-26 19:56:46.56527+00', '2026-04-26 19:56:46.56527+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_user_widget (id, employee_no, widget_code, pos_x, pos_y, width, height, config_json, sort_order, created_at, updated_at) VALUES (3, 'E0001', 'PENDING_APPROVAL', 8, 0, 4, 1, NULL, 2, '2026-04-26 19:56:46.56527+00', '2026-04-26 19:56:46.56527+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_user_widget (id, employee_no, widget_code, pos_x, pos_y, width, height, config_json, sort_order, created_at, updated_at) VALUES (4, 'E0001', 'TODAY_EVENTS', 0, 1, 6, 1, NULL, 3, '2026-04-26 19:56:46.56527+00', '2026-04-26 19:56:46.56527+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_user_widget (id, employee_no, widget_code, pos_x, pos_y, width, height, config_json, sort_order, created_at, updated_at) VALUES (5, 'E0001', 'NOTICES', 6, 1, 6, 1, NULL, 4, '2026-04-26 19:56:46.56527+00', '2026-04-26 19:56:46.56527+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.db_user_widget (id, employee_no, widget_code, pos_x, pos_y, width, height, config_json, sort_order, created_at, updated_at) VALUES (6, 'E0001', 'MESSENGER_UNREAD', 0, 2, 4, 1, NULL, 5, '2026-04-26 19:56:46.56527+00', '2026-04-26 19:56:46.56527+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.db_user_widget ENABLE TRIGGER ALL;

--
-- Data for Name: dl_folder; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.dl_folder DISABLE TRIGGER ALL;

INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (1, NULL, '회사 공용', 'COMPANY', NULL, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (2, 1, '규정/정책', 'COMPANY', NULL, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (3, 1, '양식/서식', 'COMPANY', NULL, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (4, 1, '교육자료', 'COMPANY', NULL, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (5, NULL, '인사팀', 'DEPT', 11, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (6, NULL, '재무팀', 'DEPT', 12, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (7, NULL, '총무팀', 'DEPT', 13, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (8, NULL, '영업1팀', 'DEPT', 21, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (9, NULL, '영업2팀', 'DEPT', 22, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (10, NULL, '마케팅팀', 'DEPT', 23, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (11, NULL, '프론트엔드팀', 'DEPT', 31, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (12, NULL, '백엔드팀', 'DEPT', 32, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.dl_folder (folder_id, parent_id, folder_name, scope, owner_dept_id, owner_no, created_at) VALUES (13, NULL, '인프라팀', 'DEPT', 33, NULL, '2026-04-26 19:13:47.616506+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.dl_folder ENABLE TRIGGER ALL;

--
-- Data for Name: dl_file; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.dl_file DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.dl_file ENABLE TRIGGER ALL;

--
-- Data for Name: org_position; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.org_position DISABLE TRIGGER ALL;

INSERT INTO platform_v3.org_position (position_id, position_code, position_name, position_level, created_at) VALUES (1, 'CEO', '대표이사', 1, '2026-04-26 19:06:50.903987+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_position (position_id, position_code, position_name, position_level, created_at) VALUES (2, 'DIV_HEAD', '본부장', 2, '2026-04-26 19:06:50.903987+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_position (position_id, position_code, position_name, position_level, created_at) VALUES (3, 'TEAM_LEAD', '팀장', 3, '2026-04-26 19:06:50.903987+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_position (position_id, position_code, position_name, position_level, created_at) VALUES (4, 'MANAGER', '과장', 4, '2026-04-26 19:06:50.903987+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_position (position_id, position_code, position_name, position_level, created_at) VALUES (5, 'STAFF', '사원', 5, '2026-04-26 19:06:50.903987+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.org_position ENABLE TRIGGER ALL;

--
-- Data for Name: org_employee; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.org_employee DISABLE TRIGGER ALL;

INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (1, 'E0001', '김대표', 1, 1, 'ceo@v3.local', '010-0000-0001', 'admin', '2020-01-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (2, 'E0010', '박본부', 10, 2, 'mgt.head@v3.local', '010-0000-0010', NULL, '2020-03-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (3, 'E0011', '이인사', 11, 3, 'hr.lead@v3.local', '010-0000-0011', NULL, '2021-02-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (4, 'E0012', '최인사', 11, 4, 'hr1@v3.local', '010-0000-0012', NULL, '2022-05-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (5, 'E0020', '정사업', 20, 2, 'biz.head@v3.local', '010-0000-0020', NULL, '2020-04-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (6, 'E0021', '윤영업', 21, 3, 'sales1@v3.local', '010-0000-0021', NULL, '2021-06-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (7, 'E0022', '한영업', 21, 4, 'sales1a@v3.local', '010-0000-0022', NULL, '2022-07-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (8, 'E0030', '오개발', 30, 2, 'dev.head@v3.local', '010-0000-0030', NULL, '2020-05-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (9, 'E0031', '남프론', 31, 3, 'fe.lead@v3.local', '010-0000-0031', NULL, '2021-08-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (10, 'E0032', '서프론', 31, 4, 'fe1@v3.local', '010-0000-0032', 'user1', '2022-09-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (11, 'E0033', '배프론', 31, 5, 'fe2@v3.local', '010-0000-0033', NULL, '2023-10-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (12, 'E0034', '강백엔', 32, 3, 'be.lead@v3.local', '010-0000-0034', NULL, '2021-09-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (13, 'E0035', '임백엔', 32, 4, 'be1@v3.local', '010-0000-0035', NULL, '2022-10-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (14, 'E0036', '노인프', 33, 3, 'infra.lead@v3.local', '010-0000-0036', NULL, '2021-11-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.org_employee (employee_id, employee_no, employee_name, dept_id, position_id, email, phone, keycloak_user_id, hire_date, status, created_at, updated_at) VALUES (15, 'E0037', '장인프', 33, 5, 'infra1@v3.local', '010-0000-0037', NULL, '2023-12-01', 'ACTIVE', '2026-04-26 19:06:51.169529+00', '2026-04-26 19:06:51.169529+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.org_employee ENABLE TRIGGER ALL;

--
-- Data for Name: rm_room; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.rm_room DISABLE TRIGGER ALL;

INSERT INTO platform_v3.rm_room (room_id, room_name, capacity, location, has_video, has_phone, amenities, active, created_at) VALUES (1, '대회의실', 20, NULL, true, false, '프로젝터,화이트보드,스피커폰', true, '2026-04-26 19:06:51.68964+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.rm_room (room_id, room_name, capacity, location, has_video, has_phone, amenities, active, created_at) VALUES (2, '소회의실A', 8, NULL, false, false, '화이트보드', true, '2026-04-26 19:06:51.68964+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.rm_room (room_id, room_name, capacity, location, has_video, has_phone, amenities, active, created_at) VALUES (3, '소회의실B', 8, NULL, true, false, 'TV', true, '2026-04-26 19:06:51.68964+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.rm_room (room_id, room_name, capacity, location, has_video, has_phone, amenities, active, created_at) VALUES (4, '임원회의실', 12, NULL, true, false, '프로젝터,화이트보드,스피커폰', true, '2026-04-26 19:06:51.68964+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.rm_room (room_id, room_name, capacity, location, has_video, has_phone, amenities, active, created_at) VALUES (5, '화상회의실A', 6, NULL, true, false, '카메라,스피커', true, '2026-04-26 19:06:51.68964+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.rm_room ENABLE TRIGGER ALL;

--
-- Data for Name: rm_booking; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.rm_booking DISABLE TRIGGER ALL;



ALTER TABLE platform_v3.rm_booking ENABLE TRIGGER ALL;

--
-- Data for Name: ux_favorite; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.ux_favorite DISABLE TRIGGER ALL;

INSERT INTO platform_v3.ux_favorite (fav_id, employee_no, target_type, target_id, label, url, icon, sort_order, created_at) VALUES (1, 'E0001', 'MENU', 'approval', '결재함', '/approval', 'pi pi-file-edit', 1, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_favorite (fav_id, employee_no, target_type, target_id, label, url, icon, sort_order, created_at) VALUES (2, 'E0001', 'MENU', 'board', '게시판', '/board', 'pi pi-comment', 2, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_favorite (fav_id, employee_no, target_type, target_id, label, url, icon, sort_order, created_at) VALUES (3, 'E0001', 'MENU', 'calendar', '캘린더', '/calendar', 'pi pi-calendar', 3, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_favorite (fav_id, employee_no, target_type, target_id, label, url, icon, sort_order, created_at) VALUES (4, 'E0001', 'MENU', 'attendance', '근태', '/attendance', 'pi pi-clock', 4, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_favorite (fav_id, employee_no, target_type, target_id, label, url, icon, sort_order, created_at) VALUES (5, 'E0001', 'MENU', 'datalib', '자료실', '/datalib', 'pi pi-folder', 5, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.ux_favorite ENABLE TRIGGER ALL;

--
-- Data for Name: ux_notify_pref; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.ux_notify_pref DISABLE TRIGGER ALL;

INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (1, 'E0001', 'APPROVAL', 'PORTAL', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (2, 'E0001', 'APPROVAL', 'EMAIL', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (3, 'E0001', 'APPROVAL', 'MESSENGER', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (4, 'E0001', 'BOARD', 'PORTAL', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (5, 'E0001', 'BOARD', 'EMAIL', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (6, 'E0001', 'BOARD', 'MESSENGER', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (7, 'E0001', 'CALENDAR', 'PORTAL', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (8, 'E0001', 'CALENDAR', 'EMAIL', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (9, 'E0001', 'CALENDAR', 'MESSENGER', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (10, 'E0001', 'MENTION', 'PORTAL', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (11, 'E0001', 'MENTION', 'EMAIL', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (12, 'E0001', 'MENTION', 'MESSENGER', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (13, 'E0001', 'ROOM', 'PORTAL', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (14, 'E0001', 'ROOM', 'EMAIL', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (15, 'E0001', 'ROOM', 'MESSENGER', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (16, 'E0001', 'LEAVE', 'PORTAL', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (17, 'E0001', 'LEAVE', 'EMAIL', true, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.ux_notify_pref (pref_id, employee_no, category, channel, enabled, updated_at) VALUES (18, 'E0001', 'LEAVE', 'MESSENGER', false, '2026-04-26 19:13:48.009434+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.ux_notify_pref ENABLE TRIGGER ALL;

--
-- Data for Name: wr_daily; Type: TABLE DATA; Schema: platform_v3; Owner: -
--

ALTER TABLE platform_v3.wr_daily DISABLE TRIGGER ALL;

INSERT INTO platform_v3.wr_daily (report_id, employee_no, report_date, done_today, plan_tomorrow, issue, mood, hours_worked, created_at, updated_at) VALUES (1, 'E0001', '2026-04-24', '근태 모듈 코드 리뷰 / 회의실 예약 시드 작성', '업무일지 폼 디자인', NULL, 'GOOD', 8.0, '2026-04-26 19:13:47.879184+00', '2026-04-26 19:13:47.879184+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.wr_daily (report_id, employee_no, report_date, done_today, plan_tomorrow, issue, mood, hours_worked, created_at, updated_at) VALUES (2, 'E0001', '2026-04-25', '업무일지 V13 마이그레이션 / Service 골격', '팀 뷰 DataTable + DailyEditor 구현', '주간 보정 로직 검토 필요', 'NORMAL', 8.5, '2026-04-26 19:13:47.879184+00', '2026-04-26 19:13:47.879184+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.wr_daily (report_id, employee_no, report_date, done_today, plan_tomorrow, issue, mood, hours_worked, created_at, updated_at) VALUES (3, 'E0002', '2026-04-25', '결재 LEAVE 분기 테스트', '회의실 BookingDialog UI', NULL, 'GOOD', 7.5, '2026-04-26 19:13:47.879184+00', '2026-04-26 19:13:47.879184+00') ON CONFLICT DO NOTHING;
INSERT INTO platform_v3.wr_daily (report_id, employee_no, report_date, done_today, plan_tomorrow, issue, mood, hours_worked, created_at, updated_at) VALUES (4, 'E0003', '2026-04-25', '자료실 폴더 트리 권한 헬퍼 작성', '업로드 메타 검증 보강', '용량 정책 확인 필요', 'NORMAL', 8.0, '2026-04-26 19:13:47.879184+00', '2026-04-26 19:13:47.879184+00') ON CONFLICT DO NOTHING;


ALTER TABLE platform_v3.wr_daily ENABLE TRIGGER ALL;

--
-- Name: ap_approval_line_line_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.ap_approval_line_line_id_seq', 1, false);


--
-- Name: ap_attachment_attach_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.ap_attachment_attach_id_seq', 1, false);


--
-- Name: ap_delegation_delegation_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.ap_delegation_delegation_id_seq', 1, false);


--
-- Name: ap_document_doc_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.ap_document_doc_id_seq', 3, true);


--
-- Name: at_attendance_attendance_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.at_attendance_attendance_id_seq', 1, false);


--
-- Name: at_leave_balance_balance_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.at_leave_balance_balance_id_seq', 4, true);


--
-- Name: at_leave_request_request_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.at_leave_request_request_id_seq', 1, false);


--
-- Name: bd_attachment_attach_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.bd_attachment_attach_id_seq', 1, false);


--
-- Name: bd_comment_comment_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.bd_comment_comment_id_seq', 4, true);


--
-- Name: bd_post_post_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.bd_post_post_id_seq', 15, true);


--
-- Name: cal_event_event_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.cal_event_event_id_seq', 12, true);


--
-- Name: cm_holiday_holiday_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.cm_holiday_holiday_id_seq', 15, true);


--
-- Name: cm_notification_notification_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.cm_notification_notification_id_seq', 5, true);


--
-- Name: db_user_widget_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.db_user_widget_id_seq', 6, true);


--
-- Name: dl_file_file_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.dl_file_file_id_seq', 1, false);


--
-- Name: dl_folder_folder_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.dl_folder_folder_id_seq', 13, true);


--
-- Name: org_department_dept_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.org_department_dept_id_seq', 1, true);


--
-- Name: org_employee_employee_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.org_employee_employee_id_seq', 30, true);


--
-- Name: org_position_position_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.org_position_position_id_seq', 5, true);


--
-- Name: rm_booking_booking_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.rm_booking_booking_id_seq', 1, false);


--
-- Name: rm_room_room_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.rm_room_room_id_seq', 5, true);


--
-- Name: ux_favorite_fav_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.ux_favorite_fav_id_seq', 5, true);


--
-- Name: ux_notify_pref_pref_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.ux_notify_pref_pref_id_seq', 18, true);


--
-- Name: wr_daily_report_id_seq; Type: SEQUENCE SET; Schema: platform_v3; Owner: -
--

SELECT pg_catalog.setval('platform_v3.wr_daily_report_id_seq', 4, true);


--
-- PostgreSQL database dump complete
--

\unrestrict KqWFIfNXwDKdo8oNsPhLTw0v7o8U29d24xdYC9Al4WQIT8desBWcBneUzPEcjjr

