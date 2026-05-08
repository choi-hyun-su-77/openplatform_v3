--
-- PostgreSQL database cluster dump
--

\restrict eryp0VhjQIN2ybP5E4m6DR23jwRxqGIbIgRjosq2hnduc9LfTgQjRsd5MfN7tQK

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE platform_v3;
ALTER ROLE platform_v3 WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;

--
-- User Configurations
--

--
-- User Config "platform_v3"
--

ALTER ROLE platform_v3 SET search_path TO 'platform_v3', 'public';








\unrestrict eryp0VhjQIN2ybP5E4m6DR23jwRxqGIbIgRjosq2hnduc9LfTgQjRsd5MfN7tQK

--
-- PostgreSQL database cluster dump complete
--

