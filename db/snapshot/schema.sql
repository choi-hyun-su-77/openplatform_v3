-- ============================================================
-- openplatform_v3 [main] — schema.sql (idempotent)
-- Generated: 2026-05-10 08:36:27
-- DB: platform_v3 @ v3-postgres
-- Tables: 30 (whitelist 기반, 로그/감사 제외)
-- ============================================================
--
-- PostgreSQL database dump
--

\restrict VOSborudrH8GS0ssLy6d1u6kunmdhjTp1d8F3gr0u4yIdXtlX2NkH2kRPoADAA7

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ap_approval_line; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.ap_approval_line (
    line_id bigint NOT NULL,
    doc_id bigint NOT NULL,
    step_order integer NOT NULL,
    approver_no character varying(32) NOT NULL,
    approver_name character varying(64) NOT NULL,
    role character varying(32),
    status character varying(16) DEFAULT 'PENDING'::character varying NOT NULL,
    comment text,
    acted_at timestamp with time zone,
    acted_by_no character varying(32)
);


--
-- Name: ap_approval_line_line_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.ap_approval_line_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ap_approval_line_line_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.ap_approval_line_line_id_seq OWNED BY platform_v3.ap_approval_line.line_id;


--
-- Name: ap_attachment; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.ap_attachment (
    attach_id bigint NOT NULL,
    doc_id bigint NOT NULL,
    object_key character varying(512) NOT NULL,
    filename character varying(256) NOT NULL,
    size_bytes bigint NOT NULL,
    mime_type character varying(128),
    uploader_no character varying(32) NOT NULL,
    uploaded_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ap_attachment_attach_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.ap_attachment_attach_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ap_attachment_attach_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.ap_attachment_attach_id_seq OWNED BY platform_v3.ap_attachment.attach_id;


--
-- Name: ap_delegation; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.ap_delegation (
    delegation_id bigint NOT NULL,
    delegator_no character varying(32) NOT NULL,
    delegatee_no character varying(32) NOT NULL,
    reason character varying(256),
    from_date date NOT NULL,
    to_date date NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ap_delegation_delegation_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.ap_delegation_delegation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ap_delegation_delegation_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.ap_delegation_delegation_id_seq OWNED BY platform_v3.ap_delegation.delegation_id;


--
-- Name: ap_document; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.ap_document (
    doc_id bigint NOT NULL,
    doc_title character varying(256) NOT NULL,
    form_code character varying(32) NOT NULL,
    drafter_no character varying(32) NOT NULL,
    drafter_name character varying(64) NOT NULL,
    drafter_dept character varying(64),
    status character varying(16) NOT NULL,
    content text,
    amount bigint,
    parent_doc_id bigint,
    version integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ap_document_doc_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.ap_document_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ap_document_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.ap_document_doc_id_seq OWNED BY platform_v3.ap_document.doc_id;


--
-- Name: at_attendance; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.at_attendance (
    attendance_id bigint NOT NULL,
    employee_no character varying(32) NOT NULL,
    work_date date NOT NULL,
    check_in_at timestamp with time zone,
    check_out_at timestamp with time zone,
    work_minutes integer,
    status character varying(16) DEFAULT 'NORMAL'::character varying NOT NULL,
    note character varying(256),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: at_attendance_attendance_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.at_attendance_attendance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: at_attendance_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.at_attendance_attendance_id_seq OWNED BY platform_v3.at_attendance.attendance_id;


--
-- Name: at_leave_balance; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.at_leave_balance (
    balance_id bigint NOT NULL,
    employee_no character varying(32) NOT NULL,
    year integer NOT NULL,
    total_days numeric(5,1) NOT NULL,
    used_days numeric(5,1) DEFAULT 0 NOT NULL,
    carry_over numeric(5,1) DEFAULT 0 NOT NULL,
    remaining numeric(5,1) GENERATED ALWAYS AS (((total_days + carry_over) - used_days)) STORED,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: at_leave_balance_balance_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.at_leave_balance_balance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: at_leave_balance_balance_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.at_leave_balance_balance_id_seq OWNED BY platform_v3.at_leave_balance.balance_id;


--
-- Name: at_leave_request; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.at_leave_request (
    request_id bigint NOT NULL,
    doc_id bigint,
    employee_no character varying(32) NOT NULL,
    leave_type character varying(16) NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL,
    days numeric(4,1) NOT NULL,
    reason character varying(512),
    status character varying(16) DEFAULT 'PENDING'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: at_leave_request_request_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.at_leave_request_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: at_leave_request_request_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.at_leave_request_request_id_seq OWNED BY platform_v3.at_leave_request.request_id;


--
-- Name: bd_attachment; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.bd_attachment (
    attach_id bigint NOT NULL,
    post_id bigint NOT NULL,
    object_key character varying(512) NOT NULL,
    filename character varying(256) NOT NULL,
    size_bytes bigint NOT NULL,
    mime_type character varying(128),
    uploader_no character varying(32) NOT NULL,
    uploaded_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bd_attachment_attach_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.bd_attachment_attach_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bd_attachment_attach_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.bd_attachment_attach_id_seq OWNED BY platform_v3.bd_attachment.attach_id;


--
-- Name: bd_comment; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.bd_comment (
    comment_id bigint NOT NULL,
    post_id bigint NOT NULL,
    parent_id bigint,
    content text NOT NULL,
    author_no character varying(32) NOT NULL,
    author_name character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted boolean DEFAULT false NOT NULL
);


--
-- Name: bd_comment_comment_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.bd_comment_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bd_comment_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.bd_comment_comment_id_seq OWNED BY platform_v3.bd_comment.comment_id;


--
-- Name: bd_post; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.bd_post (
    post_id bigint NOT NULL,
    board_type character varying(32) NOT NULL,
    dept_id bigint,
    title character varying(256) NOT NULL,
    content text,
    view_count integer DEFAULT 0 NOT NULL,
    is_pinned character(1) DEFAULT 'N'::bpchar NOT NULL,
    attachments jsonb,
    created_by character varying(64),
    updated_by character varying(64),
    deleted_by character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: bd_post_post_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.bd_post_post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bd_post_post_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.bd_post_post_id_seq OWNED BY platform_v3.bd_post.post_id;


--
-- Name: cal_event; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cal_event (
    event_id bigint NOT NULL,
    title character varying(256) NOT NULL,
    description text,
    event_type character varying(16) NOT NULL,
    owner_id bigint,
    dept_id bigint,
    start_dt timestamp with time zone NOT NULL,
    end_dt timestamp with time zone NOT NULL,
    all_day boolean DEFAULT false NOT NULL,
    color character varying(16),
    location character varying(256),
    created_by character varying(64),
    updated_by character varying(64),
    deleted_by character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cal_event_event_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.cal_event_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cal_event_event_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.cal_event_event_id_seq OWNED BY platform_v3.cal_event.event_id;


--
-- Name: cm_code; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cm_code (
    group_cd character varying(32) NOT NULL,
    code character varying(32) NOT NULL,
    code_name character varying(128) NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cm_holiday; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cm_holiday (
    holiday_id bigint NOT NULL,
    holiday_date date NOT NULL,
    holiday_name character varying(64) NOT NULL,
    holiday_type character varying(16) DEFAULT 'PUBLIC'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cm_holiday_holiday_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.cm_holiday_holiday_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cm_holiday_holiday_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.cm_holiday_holiday_id_seq OWNED BY platform_v3.cm_holiday.holiday_id;


--
-- Name: cm_i18n_message; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cm_i18n_message (
    msg_key character varying(128) NOT NULL,
    locale character varying(16) NOT NULL,
    msg_type character varying(32) NOT NULL,
    message text NOT NULL
);


--
-- Name: cm_menu; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cm_menu (
    menu_id character varying(32) NOT NULL,
    menu_name character varying(128) NOT NULL,
    menu_path character varying(256),
    parent_menu_id character varying(32),
    menu_level integer DEFAULT 1 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    icon character varying(64),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cm_notification; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cm_notification (
    notification_id bigint NOT NULL,
    recipient_id bigint NOT NULL,
    doc_id bigint,
    notification_type character varying(32) NOT NULL,
    channel character varying(32),
    title character varying(256),
    content text,
    is_read character(1) DEFAULT 'N'::bpchar NOT NULL,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cm_notification_notification_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.cm_notification_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cm_notification_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.cm_notification_notification_id_seq OWNED BY platform_v3.cm_notification.notification_id;


--
-- Name: cm_role; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cm_role (
    role_id character varying(32) NOT NULL,
    role_name character varying(128) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cm_role_menu; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.cm_role_menu (
    role_id character varying(32) NOT NULL,
    menu_id character varying(32) NOT NULL,
    can_read boolean DEFAULT true NOT NULL,
    can_create boolean DEFAULT false NOT NULL,
    can_update boolean DEFAULT false NOT NULL,
    can_delete boolean DEFAULT false NOT NULL,
    can_export boolean DEFAULT false NOT NULL,
    can_print boolean DEFAULT false NOT NULL
);


--
-- Name: db_user_widget; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.db_user_widget (
    id bigint NOT NULL,
    employee_no character varying(32) NOT NULL,
    widget_code character varying(32) NOT NULL,
    pos_x integer DEFAULT 0 NOT NULL,
    pos_y integer DEFAULT 0 NOT NULL,
    width integer DEFAULT 3 NOT NULL,
    height integer DEFAULT 1 NOT NULL,
    config_json jsonb,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: db_user_widget_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.db_user_widget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: db_user_widget_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.db_user_widget_id_seq OWNED BY platform_v3.db_user_widget.id;


--
-- Name: db_widget; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.db_widget (
    widget_code character varying(32) NOT NULL,
    title character varying(64) NOT NULL,
    description character varying(256),
    default_w integer DEFAULT 1 NOT NULL,
    default_h integer DEFAULT 1 NOT NULL,
    category character varying(32),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: dl_file; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.dl_file (
    file_id bigint NOT NULL,
    folder_id bigint NOT NULL,
    file_name character varying(256) NOT NULL,
    object_key character varying(512) NOT NULL,
    size_bytes bigint NOT NULL,
    mime_type character varying(128),
    tags character varying(256),
    uploader_no character varying(32) NOT NULL,
    uploaded_at timestamp with time zone DEFAULT now() NOT NULL,
    download_count integer DEFAULT 0 NOT NULL
);


--
-- Name: dl_file_file_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.dl_file_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dl_file_file_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.dl_file_file_id_seq OWNED BY platform_v3.dl_file.file_id;


--
-- Name: dl_folder; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.dl_folder (
    folder_id bigint NOT NULL,
    parent_id bigint,
    folder_name character varying(128) NOT NULL,
    scope character varying(16) NOT NULL,
    owner_dept_id bigint,
    owner_no character varying(32),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: dl_folder_folder_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.dl_folder_folder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dl_folder_folder_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.dl_folder_folder_id_seq OWNED BY platform_v3.dl_folder.folder_id;


--
-- Name: org_department; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.org_department (
    dept_id bigint NOT NULL,
    dept_code character varying(32) NOT NULL,
    dept_name character varying(128) NOT NULL,
    parent_dept_id bigint,
    dept_level integer DEFAULT 1 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: org_department_dept_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.org_department_dept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_department_dept_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.org_department_dept_id_seq OWNED BY platform_v3.org_department.dept_id;


--
-- Name: org_employee; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.org_employee (
    employee_id bigint NOT NULL,
    employee_no character varying(32) NOT NULL,
    employee_name character varying(64) NOT NULL,
    dept_id bigint NOT NULL,
    position_id bigint NOT NULL,
    email character varying(128),
    phone character varying(32),
    keycloak_user_id character varying(64),
    hire_date date,
    status character varying(16) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: org_employee_employee_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.org_employee_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_employee_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.org_employee_employee_id_seq OWNED BY platform_v3.org_employee.employee_id;


--
-- Name: org_position; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.org_position (
    position_id bigint NOT NULL,
    position_code character varying(32) NOT NULL,
    position_name character varying(64) NOT NULL,
    position_level integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: org_position_position_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.org_position_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_position_position_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.org_position_position_id_seq OWNED BY platform_v3.org_position.position_id;


--
-- Name: rm_booking; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.rm_booking (
    booking_id bigint NOT NULL,
    room_id bigint NOT NULL,
    booker_no character varying(32) NOT NULL,
    title character varying(128) NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    attendees text,
    livekit_room character varying(64),
    status character varying(16) DEFAULT 'BOOKED'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT rm_booking_check CHECK ((end_at > start_at))
);


--
-- Name: rm_booking_booking_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.rm_booking_booking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rm_booking_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.rm_booking_booking_id_seq OWNED BY platform_v3.rm_booking.booking_id;


--
-- Name: rm_room; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.rm_room (
    room_id bigint NOT NULL,
    room_name character varying(64) NOT NULL,
    capacity integer NOT NULL,
    location character varying(128),
    has_video boolean DEFAULT false NOT NULL,
    has_phone boolean DEFAULT false NOT NULL,
    amenities text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: rm_room_room_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.rm_room_room_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rm_room_room_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.rm_room_room_id_seq OWNED BY platform_v3.rm_room.room_id;


--
-- Name: ux_favorite; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.ux_favorite (
    fav_id bigint NOT NULL,
    employee_no character varying(32) NOT NULL,
    target_type character varying(16) NOT NULL,
    target_id character varying(64) NOT NULL,
    label character varying(128),
    url character varying(256),
    icon character varying(32),
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ux_favorite_fav_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.ux_favorite_fav_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ux_favorite_fav_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.ux_favorite_fav_id_seq OWNED BY platform_v3.ux_favorite.fav_id;


--
-- Name: ux_notify_pref; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.ux_notify_pref (
    pref_id bigint NOT NULL,
    employee_no character varying(32) NOT NULL,
    category character varying(32) NOT NULL,
    channel character varying(16) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ux_notify_pref_pref_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.ux_notify_pref_pref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ux_notify_pref_pref_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.ux_notify_pref_pref_id_seq OWNED BY platform_v3.ux_notify_pref.pref_id;


--
-- Name: wr_daily; Type: TABLE; Schema: platform_v3; Owner: -
--

CREATE TABLE IF NOT EXISTS platform_v3.wr_daily (
    report_id bigint NOT NULL,
    employee_no character varying(32) NOT NULL,
    report_date date NOT NULL,
    done_today text,
    plan_tomorrow text,
    issue text,
    mood character varying(16),
    hours_worked numeric(4,1),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: wr_daily_report_id_seq; Type: SEQUENCE; Schema: platform_v3; Owner: -
--

CREATE SEQUENCE IF NOT EXISTS platform_v3.wr_daily_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wr_daily_report_id_seq; Type: SEQUENCE OWNED BY; Schema: platform_v3; Owner: -
--

ALTER SEQUENCE platform_v3.wr_daily_report_id_seq OWNED BY platform_v3.wr_daily.report_id;


--
-- Name: ap_approval_line line_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_approval_line ALTER COLUMN line_id SET DEFAULT nextval('platform_v3.ap_approval_line_line_id_seq'::regclass);


--
-- Name: ap_attachment attach_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_attachment ALTER COLUMN attach_id SET DEFAULT nextval('platform_v3.ap_attachment_attach_id_seq'::regclass);


--
-- Name: ap_delegation delegation_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_delegation ALTER COLUMN delegation_id SET DEFAULT nextval('platform_v3.ap_delegation_delegation_id_seq'::regclass);


--
-- Name: ap_document doc_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_document ALTER COLUMN doc_id SET DEFAULT nextval('platform_v3.ap_document_doc_id_seq'::regclass);


--
-- Name: at_attendance attendance_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_attendance ALTER COLUMN attendance_id SET DEFAULT nextval('platform_v3.at_attendance_attendance_id_seq'::regclass);


--
-- Name: at_leave_balance balance_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_leave_balance ALTER COLUMN balance_id SET DEFAULT nextval('platform_v3.at_leave_balance_balance_id_seq'::regclass);


--
-- Name: at_leave_request request_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_leave_request ALTER COLUMN request_id SET DEFAULT nextval('platform_v3.at_leave_request_request_id_seq'::regclass);


--
-- Name: bd_attachment attach_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.bd_attachment ALTER COLUMN attach_id SET DEFAULT nextval('platform_v3.bd_attachment_attach_id_seq'::regclass);


--
-- Name: bd_comment comment_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.bd_comment ALTER COLUMN comment_id SET DEFAULT nextval('platform_v3.bd_comment_comment_id_seq'::regclass);


--
-- Name: bd_post post_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.bd_post ALTER COLUMN post_id SET DEFAULT nextval('platform_v3.bd_post_post_id_seq'::regclass);


--
-- Name: cal_event event_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cal_event ALTER COLUMN event_id SET DEFAULT nextval('platform_v3.cal_event_event_id_seq'::regclass);


--
-- Name: cm_holiday holiday_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_holiday ALTER COLUMN holiday_id SET DEFAULT nextval('platform_v3.cm_holiday_holiday_id_seq'::regclass);


--
-- Name: cm_notification notification_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_notification ALTER COLUMN notification_id SET DEFAULT nextval('platform_v3.cm_notification_notification_id_seq'::regclass);


--
-- Name: db_user_widget id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.db_user_widget ALTER COLUMN id SET DEFAULT nextval('platform_v3.db_user_widget_id_seq'::regclass);


--
-- Name: dl_file file_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.dl_file ALTER COLUMN file_id SET DEFAULT nextval('platform_v3.dl_file_file_id_seq'::regclass);


--
-- Name: dl_folder folder_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.dl_folder ALTER COLUMN folder_id SET DEFAULT nextval('platform_v3.dl_folder_folder_id_seq'::regclass);


--
-- Name: org_department dept_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_department ALTER COLUMN dept_id SET DEFAULT nextval('platform_v3.org_department_dept_id_seq'::regclass);


--
-- Name: org_employee employee_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_employee ALTER COLUMN employee_id SET DEFAULT nextval('platform_v3.org_employee_employee_id_seq'::regclass);


--
-- Name: org_position position_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_position ALTER COLUMN position_id SET DEFAULT nextval('platform_v3.org_position_position_id_seq'::regclass);


--
-- Name: rm_booking booking_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.rm_booking ALTER COLUMN booking_id SET DEFAULT nextval('platform_v3.rm_booking_booking_id_seq'::regclass);


--
-- Name: rm_room room_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.rm_room ALTER COLUMN room_id SET DEFAULT nextval('platform_v3.rm_room_room_id_seq'::regclass);


--
-- Name: ux_favorite fav_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ux_favorite ALTER COLUMN fav_id SET DEFAULT nextval('platform_v3.ux_favorite_fav_id_seq'::regclass);


--
-- Name: ux_notify_pref pref_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ux_notify_pref ALTER COLUMN pref_id SET DEFAULT nextval('platform_v3.ux_notify_pref_pref_id_seq'::regclass);


--
-- Name: wr_daily report_id; Type: DEFAULT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.wr_daily ALTER COLUMN report_id SET DEFAULT nextval('platform_v3.wr_daily_report_id_seq'::regclass);


--
-- Name: ap_approval_line ap_approval_line_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_approval_line
    ADD CONSTRAINT ap_approval_line_pkey PRIMARY KEY (line_id);


--
-- Name: ap_attachment ap_attachment_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_attachment
    ADD CONSTRAINT ap_attachment_pkey PRIMARY KEY (attach_id);


--
-- Name: ap_delegation ap_delegation_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_delegation
    ADD CONSTRAINT ap_delegation_pkey PRIMARY KEY (delegation_id);


--
-- Name: ap_document ap_document_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_document
    ADD CONSTRAINT ap_document_pkey PRIMARY KEY (doc_id);


--
-- Name: at_attendance at_attendance_employee_no_work_date_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_attendance
    ADD CONSTRAINT at_attendance_employee_no_work_date_key UNIQUE (employee_no, work_date);


--
-- Name: at_attendance at_attendance_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_attendance
    ADD CONSTRAINT at_attendance_pkey PRIMARY KEY (attendance_id);


--
-- Name: at_leave_balance at_leave_balance_employee_no_year_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_leave_balance
    ADD CONSTRAINT at_leave_balance_employee_no_year_key UNIQUE (employee_no, year);


--
-- Name: at_leave_balance at_leave_balance_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_leave_balance
    ADD CONSTRAINT at_leave_balance_pkey PRIMARY KEY (balance_id);


--
-- Name: at_leave_request at_leave_request_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_leave_request
    ADD CONSTRAINT at_leave_request_pkey PRIMARY KEY (request_id);


--
-- Name: bd_attachment bd_attachment_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.bd_attachment
    ADD CONSTRAINT bd_attachment_pkey PRIMARY KEY (attach_id);


--
-- Name: bd_comment bd_comment_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.bd_comment
    ADD CONSTRAINT bd_comment_pkey PRIMARY KEY (comment_id);


--
-- Name: bd_post bd_post_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.bd_post
    ADD CONSTRAINT bd_post_pkey PRIMARY KEY (post_id);


--
-- Name: cal_event cal_event_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cal_event
    ADD CONSTRAINT cal_event_pkey PRIMARY KEY (event_id);


--
-- Name: cm_code cm_code_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_code
    ADD CONSTRAINT cm_code_pkey PRIMARY KEY (group_cd, code);


--
-- Name: cm_holiday cm_holiday_holiday_date_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_holiday
    ADD CONSTRAINT cm_holiday_holiday_date_key UNIQUE (holiday_date);


--
-- Name: cm_holiday cm_holiday_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_holiday
    ADD CONSTRAINT cm_holiday_pkey PRIMARY KEY (holiday_id);


--
-- Name: cm_i18n_message cm_i18n_message_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_i18n_message
    ADD CONSTRAINT cm_i18n_message_pkey PRIMARY KEY (msg_key, locale);


--
-- Name: cm_menu cm_menu_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_menu
    ADD CONSTRAINT cm_menu_pkey PRIMARY KEY (menu_id);


--
-- Name: cm_notification cm_notification_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_notification
    ADD CONSTRAINT cm_notification_pkey PRIMARY KEY (notification_id);


--
-- Name: cm_role_menu cm_role_menu_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_role_menu
    ADD CONSTRAINT cm_role_menu_pkey PRIMARY KEY (role_id, menu_id);


--
-- Name: cm_role cm_role_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_role
    ADD CONSTRAINT cm_role_pkey PRIMARY KEY (role_id);


--
-- Name: db_user_widget db_user_widget_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.db_user_widget
    ADD CONSTRAINT db_user_widget_pkey PRIMARY KEY (id);


--
-- Name: db_widget db_widget_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.db_widget
    ADD CONSTRAINT db_widget_pkey PRIMARY KEY (widget_code);


--
-- Name: dl_file dl_file_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.dl_file
    ADD CONSTRAINT dl_file_pkey PRIMARY KEY (file_id);


--
-- Name: dl_folder dl_folder_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.dl_folder
    ADD CONSTRAINT dl_folder_pkey PRIMARY KEY (folder_id);


--
-- Name: org_department org_department_dept_code_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_department
    ADD CONSTRAINT org_department_dept_code_key UNIQUE (dept_code);


--
-- Name: org_department org_department_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_department
    ADD CONSTRAINT org_department_pkey PRIMARY KEY (dept_id);


--
-- Name: org_employee org_employee_employee_no_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_employee
    ADD CONSTRAINT org_employee_employee_no_key UNIQUE (employee_no);


--
-- Name: org_employee org_employee_keycloak_user_id_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_employee
    ADD CONSTRAINT org_employee_keycloak_user_id_key UNIQUE (keycloak_user_id);


--
-- Name: org_employee org_employee_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_employee
    ADD CONSTRAINT org_employee_pkey PRIMARY KEY (employee_id);


--
-- Name: org_position org_position_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_position
    ADD CONSTRAINT org_position_pkey PRIMARY KEY (position_id);


--
-- Name: org_position org_position_position_code_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_position
    ADD CONSTRAINT org_position_position_code_key UNIQUE (position_code);


--
-- Name: rm_booking rm_booking_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.rm_booking
    ADD CONSTRAINT rm_booking_pkey PRIMARY KEY (booking_id);


--
-- Name: rm_room rm_room_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.rm_room
    ADD CONSTRAINT rm_room_pkey PRIMARY KEY (room_id);


--
-- Name: rm_room rm_room_room_name_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.rm_room
    ADD CONSTRAINT rm_room_room_name_key UNIQUE (room_name);


--
-- Name: db_user_widget uq_db_user_widget; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.db_user_widget
    ADD CONSTRAINT uq_db_user_widget UNIQUE (employee_no, widget_code);


--
-- Name: ux_favorite ux_favorite_employee_no_target_type_target_id_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ux_favorite
    ADD CONSTRAINT ux_favorite_employee_no_target_type_target_id_key UNIQUE (employee_no, target_type, target_id);


--
-- Name: ux_favorite ux_favorite_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ux_favorite
    ADD CONSTRAINT ux_favorite_pkey PRIMARY KEY (fav_id);


--
-- Name: ux_notify_pref ux_notify_pref_employee_no_category_channel_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ux_notify_pref
    ADD CONSTRAINT ux_notify_pref_employee_no_category_channel_key UNIQUE (employee_no, category, channel);


--
-- Name: ux_notify_pref ux_notify_pref_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ux_notify_pref
    ADD CONSTRAINT ux_notify_pref_pkey PRIMARY KEY (pref_id);


--
-- Name: wr_daily wr_daily_employee_no_report_date_key; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.wr_daily
    ADD CONSTRAINT wr_daily_employee_no_report_date_key UNIQUE (employee_no, report_date);


--
-- Name: wr_daily wr_daily_pkey; Type: CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.wr_daily
    ADD CONSTRAINT wr_daily_pkey PRIMARY KEY (report_id);


--
-- Name: idx_ap_attachment_doc; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ap_attachment_doc ON platform_v3.ap_attachment USING btree (doc_id);


--
-- Name: idx_ap_delegation_delegator; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ap_delegation_delegator ON platform_v3.ap_delegation USING btree (delegator_no, active, from_date, to_date);


--
-- Name: idx_ap_document_drafter; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ap_document_drafter ON platform_v3.ap_document USING btree (drafter_no);


--
-- Name: idx_ap_document_form; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ap_document_form ON platform_v3.ap_document USING btree (form_code);


--
-- Name: idx_ap_document_status; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ap_document_status ON platform_v3.ap_document USING btree (status);


--
-- Name: idx_ap_line_approver; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ap_line_approver ON platform_v3.ap_approval_line USING btree (approver_no);


--
-- Name: idx_ap_line_doc; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ap_line_doc ON platform_v3.ap_approval_line USING btree (doc_id);


--
-- Name: idx_at_attendance_emp_date; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_at_attendance_emp_date ON platform_v3.at_attendance USING btree (employee_no, work_date DESC);


--
-- Name: idx_at_leave_doc; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_at_leave_doc ON platform_v3.at_leave_request USING btree (doc_id);


--
-- Name: idx_at_leave_emp; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_at_leave_emp ON platform_v3.at_leave_request USING btree (employee_no, from_date DESC);


--
-- Name: idx_bd_attachment_post; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_bd_attachment_post ON platform_v3.bd_attachment USING btree (post_id);


--
-- Name: idx_bd_comment_parent; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_bd_comment_parent ON platform_v3.bd_comment USING btree (parent_id);


--
-- Name: idx_bd_comment_post; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_bd_comment_post ON platform_v3.bd_comment USING btree (post_id);


--
-- Name: idx_bd_post_created; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_bd_post_created ON platform_v3.bd_post USING btree (created_at DESC);


--
-- Name: idx_bd_post_type_dept; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_bd_post_type_dept ON platform_v3.bd_post USING btree (board_type, dept_id, deleted_at);


--
-- Name: idx_cal_event_dept; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_cal_event_dept ON platform_v3.cal_event USING btree (dept_id);


--
-- Name: idx_cal_event_owner; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_cal_event_owner ON platform_v3.cal_event USING btree (owner_id);


--
-- Name: idx_cal_event_range; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_cal_event_range ON platform_v3.cal_event USING btree (start_dt, end_dt);


--
-- Name: idx_db_user_widget_emp; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_db_user_widget_emp ON platform_v3.db_user_widget USING btree (employee_no);


--
-- Name: idx_dl_file_folder; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_dl_file_folder ON platform_v3.dl_file USING btree (folder_id);


--
-- Name: idx_dl_file_name; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_dl_file_name ON platform_v3.dl_file USING btree (file_name);


--
-- Name: idx_dl_file_uploader; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_dl_file_uploader ON platform_v3.dl_file USING btree (uploader_no);


--
-- Name: idx_dl_folder_dept; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_dl_folder_dept ON platform_v3.dl_folder USING btree (owner_dept_id);


--
-- Name: idx_dl_folder_owner; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_dl_folder_owner ON platform_v3.dl_folder USING btree (owner_no);


--
-- Name: idx_dl_folder_parent; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_dl_folder_parent ON platform_v3.dl_folder USING btree (parent_id);


--
-- Name: idx_dl_folder_scope; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_dl_folder_scope ON platform_v3.dl_folder USING btree (scope);


--
-- Name: idx_i18n_type; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_i18n_type ON platform_v3.cm_i18n_message USING btree (locale, msg_type);


--
-- Name: idx_notif_recipient; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_notif_recipient ON platform_v3.cm_notification USING btree (recipient_id, is_read, created_at DESC);


--
-- Name: idx_org_employee_dept; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_org_employee_dept ON platform_v3.org_employee USING btree (dept_id);


--
-- Name: idx_org_employee_keycloak; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_org_employee_keycloak ON platform_v3.org_employee USING btree (keycloak_user_id);


--
-- Name: idx_rm_booking_booker; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_rm_booking_booker ON platform_v3.rm_booking USING btree (booker_no);


--
-- Name: idx_rm_booking_room_time; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_rm_booking_room_time ON platform_v3.rm_booking USING btree (room_id, start_at, end_at);


--
-- Name: idx_ux_favorite_emp_sort; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ux_favorite_emp_sort ON platform_v3.ux_favorite USING btree (employee_no, sort_order);


--
-- Name: idx_ux_notify_pref_emp_cat; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_ux_notify_pref_emp_cat ON platform_v3.ux_notify_pref USING btree (employee_no, category);


--
-- Name: idx_wr_daily_date; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_wr_daily_date ON platform_v3.wr_daily USING btree (report_date);


--
-- Name: idx_wr_daily_emp_date; Type: INDEX; Schema: platform_v3; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_wr_daily_emp_date ON platform_v3.wr_daily USING btree (employee_no, report_date DESC);


--
-- Name: ap_approval_line ap_approval_line_doc_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_approval_line
    ADD CONSTRAINT ap_approval_line_doc_id_fkey FOREIGN KEY (doc_id) REFERENCES platform_v3.ap_document(doc_id) ON DELETE CASCADE;


--
-- Name: ap_attachment ap_attachment_doc_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.ap_attachment
    ADD CONSTRAINT ap_attachment_doc_id_fkey FOREIGN KEY (doc_id) REFERENCES platform_v3.ap_document(doc_id) ON DELETE CASCADE;


--
-- Name: at_leave_request at_leave_request_doc_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.at_leave_request
    ADD CONSTRAINT at_leave_request_doc_id_fkey FOREIGN KEY (doc_id) REFERENCES platform_v3.ap_document(doc_id) ON DELETE SET NULL;


--
-- Name: bd_post bd_post_dept_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.bd_post
    ADD CONSTRAINT bd_post_dept_id_fkey FOREIGN KEY (dept_id) REFERENCES platform_v3.org_department(dept_id);


--
-- Name: cal_event cal_event_dept_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cal_event
    ADD CONSTRAINT cal_event_dept_id_fkey FOREIGN KEY (dept_id) REFERENCES platform_v3.org_department(dept_id);


--
-- Name: cm_role_menu cm_role_menu_menu_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_role_menu
    ADD CONSTRAINT cm_role_menu_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES platform_v3.cm_menu(menu_id) ON DELETE CASCADE;


--
-- Name: cm_role_menu cm_role_menu_role_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.cm_role_menu
    ADD CONSTRAINT cm_role_menu_role_id_fkey FOREIGN KEY (role_id) REFERENCES platform_v3.cm_role(role_id) ON DELETE CASCADE;


--
-- Name: db_user_widget db_user_widget_widget_code_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.db_user_widget
    ADD CONSTRAINT db_user_widget_widget_code_fkey FOREIGN KEY (widget_code) REFERENCES platform_v3.db_widget(widget_code) ON DELETE CASCADE;


--
-- Name: dl_file dl_file_folder_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.dl_file
    ADD CONSTRAINT dl_file_folder_id_fkey FOREIGN KEY (folder_id) REFERENCES platform_v3.dl_folder(folder_id) ON DELETE CASCADE;


--
-- Name: dl_folder dl_folder_parent_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.dl_folder
    ADD CONSTRAINT dl_folder_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES platform_v3.dl_folder(folder_id) ON DELETE CASCADE;


--
-- Name: org_department org_department_parent_dept_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_department
    ADD CONSTRAINT org_department_parent_dept_id_fkey FOREIGN KEY (parent_dept_id) REFERENCES platform_v3.org_department(dept_id);


--
-- Name: org_employee org_employee_dept_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_employee
    ADD CONSTRAINT org_employee_dept_id_fkey FOREIGN KEY (dept_id) REFERENCES platform_v3.org_department(dept_id);


--
-- Name: org_employee org_employee_position_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.org_employee
    ADD CONSTRAINT org_employee_position_id_fkey FOREIGN KEY (position_id) REFERENCES platform_v3.org_position(position_id);


--
-- Name: rm_booking rm_booking_room_id_fkey; Type: FK CONSTRAINT; Schema: platform_v3; Owner: -
--

ALTER TABLE ONLY platform_v3.rm_booking
    ADD CONSTRAINT rm_booking_room_id_fkey FOREIGN KEY (room_id) REFERENCES platform_v3.rm_room(room_id);


--
-- PostgreSQL database dump complete
--

\unrestrict VOSborudrH8GS0ssLy6d1u6kunmdhjTp1d8F3gr0u4yIdXtlX2NkH2kRPoADAA7

