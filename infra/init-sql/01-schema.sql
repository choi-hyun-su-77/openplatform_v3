-- openplatform_v3 초기 DB 스키마
-- 실행 순서: postgres 최초 기동 시 자동 로드

CREATE SCHEMA IF NOT EXISTS platform_v3 AUTHORIZATION platform_v3;
CREATE SCHEMA IF NOT EXISTS flowable_v3 AUTHORIZATION platform_v3;
CREATE SCHEMA IF NOT EXISTS keycloak_v3 AUTHORIZATION platform_v3;

-- Rocket.Chat 은 Mongo 를 사용하므로 PostgreSQL DB 생성 불필요 (v3-mongo 컨테이너 별도)

-- Wiki.js 전용 DB
CREATE DATABASE wiki_v3 OWNER platform_v3;

-- 기본 검색 경로
ALTER ROLE platform_v3 SET search_path TO platform_v3, public;
