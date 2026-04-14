-- openplatform_v3 초기 DB 스키마
-- 실행 순서: postgres 최초 기동 시 자동 로드

CREATE SCHEMA IF NOT EXISTS platform_v3 AUTHORIZATION platform_v3;
CREATE SCHEMA IF NOT EXISTS flowable_v3 AUTHORIZATION platform_v3;
CREATE SCHEMA IF NOT EXISTS keycloak_v3 AUTHORIZATION platform_v3;

-- Mattermost 전용 DB
CREATE DATABASE mattermost_v3 OWNER platform_v3;

-- Wiki.js 전용 DB
CREATE DATABASE wiki_v3 OWNER platform_v3;

-- 기본 검색 경로
ALTER ROLE platform_v3 SET search_path TO platform_v3, public;
