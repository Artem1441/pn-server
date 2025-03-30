--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg22.04+1)
-- Dumped by pg_dump version 17.4 (Ubuntu 17.4-1.pgdg22.04+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: banks; Type: SCHEMA; Schema: -; Owner: nails
--

CREATE SCHEMA banks;


ALTER SCHEMA banks OWNER TO nails;

--
-- Name: client_search; Type: SCHEMA; Schema: -; Owner: nails
--

CREATE SCHEMA client_search;


ALTER SCHEMA client_search OWNER TO nails;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- Name: data_types; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.data_types AS ENUM (
    'users',
    'specialists',
    'specialist_regs'
);


ALTER TYPE public.data_types OWNER TO nails;

--
-- Name: locales; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.locales AS ENUM (
    'ru'
);


ALTER TYPE public.locales OWNER TO nails;

--
-- Name: mail_types; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.mail_types AS ENUM (
    'password_recover'
);


ALTER TYPE public.mail_types OWNER TO nails;

--
-- Name: notif_providers; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.notif_providers AS ENUM (
    'email',
    'sms',
    'wa',
    'tm',
    'vb'
);


ALTER TYPE public.notif_providers OWNER TO nails;

--
-- Name: notif_types; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.notif_types AS ENUM (
    'new_specialist',
    'tel_check',
    'email_check',
    'docs_for_sign',
    'signed_docs',
    'new_account'
);


ALTER TYPE public.notif_types OWNER TO nails;

--
-- Name: role_types; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.role_types AS ENUM (
    'admin',
    'specialist',
    'accountant'
);


ALTER TYPE public.role_types OWNER TO nails;

--
-- Name: specialist_status_types; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.specialist_status_types AS ENUM (
    'contract_signed',
    'contract_terminated',
    'contract_signing'
);


ALTER TYPE public.specialist_status_types OWNER TO nails;

--
-- Name: template_batch_types; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.template_batch_types AS ENUM (
    'specialist_registration',
    'specialist_salary'
);


ALTER TYPE public.template_batch_types OWNER TO nails;

--
-- Name: template_value; Type: TYPE; Schema: public; Owner: nails
--

CREATE TYPE public.template_value AS (
	field text,
	value text
);


ALTER TYPE public.template_value OWNER TO nails;

--
-- Name: ms; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER ms FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'ms',
    host '192.168.1.177',
    port '5432'
);


ALTER SERVER ms OWNER TO postgres;

--
-- Name: USER MAPPING nails SERVER ms; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR nails SERVER ms OPTIONS (
    password '159753',
    "user" 'ms'
);


--
-- Name: banks; Type: FOREIGN TABLE; Schema: banks; Owner: nails
--

CREATE FOREIGN TABLE banks.banks (
    bik character varying(9) NOT NULL,
    codegr character varying(9),
    name text,
    korshet character varying(20),
    adres text,
    gor text,
    tgroup boolean
)
SERVER ms
OPTIONS (
    schema_name 'banks',
    table_name 'banks'
);
ALTER FOREIGN TABLE ONLY banks.banks ALTER COLUMN bik OPTIONS (
    column_name 'bik'
);
ALTER FOREIGN TABLE ONLY banks.banks ALTER COLUMN codegr OPTIONS (
    column_name 'codegr'
);
ALTER FOREIGN TABLE ONLY banks.banks ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE ONLY banks.banks ALTER COLUMN korshet OPTIONS (
    column_name 'korshet'
);
ALTER FOREIGN TABLE ONLY banks.banks ALTER COLUMN adres OPTIONS (
    column_name 'adres'
);
ALTER FOREIGN TABLE ONLY banks.banks ALTER COLUMN gor OPTIONS (
    column_name 'gor'
);
ALTER FOREIGN TABLE ONLY banks.banks ALTER COLUMN tgroup OPTIONS (
    column_name 'tgroup'
);


ALTER FOREIGN TABLE banks.banks OWNER TO nails;

--
-- Name: banks_ref(banks.banks); Type: FUNCTION; Schema: banks; Owner: nails
--

CREATE FUNCTION banks.banks_ref(banks.banks) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'bik',$1.bik   
			),	
		'descr',$1.bik||', '||$1.name||', '||$1.korshet,
		'dataType','banks'
	);
$_$;


ALTER FUNCTION banks.banks_ref(banks.banks) OWNER TO nails;

--
-- Name: attachments_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.attachments_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		--delete files
		PERFORM pg_notify('Attachment.clear_cache', json_build_object(
			'ref', OLD.ref::json,
			'content_id', OLD.content_info->>'id'
		)::text);
		
		--EXECUTE format('COPY (SELECT 1) TO PROGRAM ''rm -f %s/%s''', '/home/andrey/www/nails/CACHE', md5(format('att_%s%s_%s', OLD.ref->>'dataType', OLD.ref->'keys'->>'id', OLD.content_info->>'id')));		
		--EXECUTE format('COPY (SELECT 1) TO PROGRAM ''rm -f %s/%s''', '/home/andrey/www/nails/CACHE', md5(format('prev_%s%s_%s', OLD.ref->>'dataType', OLD.ref->'keys'->>'id', OLD.content_info->>'id')));
		
		RETURN OLD;
		
	ELSIF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE' ) THEN
		IF TG_OP='INSERT' OR NEW.content_data IS NOT NULL THEN
			NEW.content_info = coalesce(NEW.content_info, OLD.content_info) ||
					jsonb_build_object('size', length(NEW.content_data));
		END IF;
		
		RETURN NEW;
	END IF;
END;
$$;


ALTER FUNCTION public.attachments_process() OWNER TO nails;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bank_payments; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.bank_payments (
    id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_date timestamp with time zone,
    document_num integer,
    document_total numeric(15,2) DEFAULT 0,
    document_comment text,
    payer_acc character varying(20),
    payer_bank_acc character varying(20),
    payer_bank_bik character varying(9),
    payer_bank text,
    payer_bank_place text,
    rec_acc character varying(20),
    rec_bank_acc character varying(20),
    rec_bank_bik character varying(9),
    rec_bank text,
    rec_bank_place text,
    specialist_id integer NOT NULL,
    specialist_period_salary_detail_id integer NOT NULL,
    payer text,
    rec text,
    payer_inn character varying(12),
    rec_inn character varying(12)
);


ALTER TABLE public.bank_payments OWNER TO nails;

--
-- Name: bank_payments_ref(public.bank_payments); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.bank_payments_ref(public.bank_payments) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr', $1.document_num::text || ' ' ||to_char($1.document_date, 'DD/MM/YY'),
		'dataType','bank_payments'
	);
$_$;


ALTER FUNCTION public.bank_payments_ref(public.bank_payments) OWNER TO nails;

--
-- Name: capit_first_letter(text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.capit_first_letter(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT 
		upper(substr($1,1,1)) ||
		lower(substr($1,2));	
$_$;


ALTER FUNCTION public.capit_first_letter(text) OWNER TO nails;

--
-- Name: const_doc_per_page_count_set_val(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_doc_per_page_count_set_val(integer) RETURNS void
    LANGUAGE sql
    AS $_$
		UPDATE const_doc_per_page_count SET val=$1;
	$_$;


ALTER FUNCTION public.const_doc_per_page_count_set_val(integer) OWNER TO nails;

--
-- Name: const_doc_per_page_count_val(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_doc_per_page_count_val() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
		
		SELECT val::int AS val FROM const_doc_per_page_count LIMIT 1;
		
	$$;


ALTER FUNCTION public.const_doc_per_page_count_val() OWNER TO nails;

--
-- Name: const_email_set_val(jsonb); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_email_set_val(jsonb) RETURNS void
    LANGUAGE sql
    AS $_$
		UPDATE const_email SET val=$1;
	$_$;


ALTER FUNCTION public.const_email_set_val(jsonb) OWNER TO nails;

--
-- Name: const_email_val(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_email_val() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
		
		SELECT val::jsonb AS val FROM const_email LIMIT 1;
		
	$$;


ALTER FUNCTION public.const_email_val() OWNER TO nails;

--
-- Name: const_grid_refresh_interval_set_val(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_grid_refresh_interval_set_val(integer) RETURNS void
    LANGUAGE sql
    AS $_$
		UPDATE const_grid_refresh_interval SET val=$1;
	$_$;


ALTER FUNCTION public.const_grid_refresh_interval_set_val(integer) OWNER TO nails;

--
-- Name: const_grid_refresh_interval_val(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_grid_refresh_interval_val() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
		
		SELECT val::int AS val FROM const_grid_refresh_interval LIMIT 1;
		
	$$;


ALTER FUNCTION public.const_grid_refresh_interval_val() OWNER TO nails;

--
-- Name: const_join_contract_set_val(text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_join_contract_set_val(text) RETURNS void
    LANGUAGE sql
    AS $_$
		UPDATE const_join_contract SET val=$1;
	$_$;


ALTER FUNCTION public.const_join_contract_set_val(text) OWNER TO nails;

--
-- Name: const_join_contract_val(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_join_contract_val() RETURNS text
    LANGUAGE sql STABLE
    AS $$
		
		SELECT val::text AS val FROM const_join_contract LIMIT 1;
		
	$$;


ALTER FUNCTION public.const_join_contract_val() OWNER TO nails;

--
-- Name: const_person_tax_set_val(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_person_tax_set_val(integer) RETURNS void
    LANGUAGE sql
    AS $_$
		UPDATE const_person_tax SET val=$1;
	$_$;


ALTER FUNCTION public.const_person_tax_set_val(integer) OWNER TO nails;

--
-- Name: const_person_tax_val(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_person_tax_val() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
		
		SELECT val::int AS val FROM const_person_tax LIMIT 1;
		
	$$;


ALTER FUNCTION public.const_person_tax_val() OWNER TO nails;

--
-- Name: const_specialist_pay_comment_template_set_val(text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_specialist_pay_comment_template_set_val(text) RETURNS void
    LANGUAGE sql
    AS $_$
		UPDATE const_specialist_pay_comment_template SET val=$1;
	$_$;


ALTER FUNCTION public.const_specialist_pay_comment_template_set_val(text) OWNER TO nails;

--
-- Name: const_specialist_pay_comment_template_val(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_specialist_pay_comment_template_val() RETURNS text
    LANGUAGE sql STABLE
    AS $$
		
		SELECT val::text AS val FROM const_specialist_pay_comment_template LIMIT 1;
		
	$$;


ALTER FUNCTION public.const_specialist_pay_comment_template_val() OWNER TO nails;

--
-- Name: const_specialist_services_set_val(text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_specialist_services_set_val(text) RETURNS void
    LANGUAGE sql
    AS $_$
		UPDATE const_specialist_services SET val=$1;
	$_$;


ALTER FUNCTION public.const_specialist_services_set_val(text) OWNER TO nails;

--
-- Name: const_specialist_services_val(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.const_specialist_services_val() RETURNS text
    LANGUAGE sql STABLE
    AS $$
		
		SELECT val::text AS val FROM const_specialist_services LIMIT 1;
		
	$$;


ALTER FUNCTION public.const_specialist_services_val() OWNER TO nails;

--
-- Name: contacts_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.contacts_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='UPDATE' OR TG_OP='INSERT') THEN
		/*IF TG_OP='INSERT'
		OR coalesce(NEW.name,'') <> coalesce(OLD.name,'')
		OR coalesce(NEW.post_id,0) <> coalesce(OLD.post_id,0)
		OR coalesce(NEW.tel,'') <> coalesce(OLD.tel,'')
		OR coalesce(NEW.email,'') <> coalesce(OLD.email,'')
		OR coalesce(NEW.tel_ext,'') <> coalesce(OLD.tel_ext,'')
		THEN*/
			NEW.descr = coalesce(NEW.name,'')||
				CASE
					WHEN NEW.post_id IS NOT NULL THEN
						(SELECT '('||posts.name||') ' FROM posts WHERE posts.id = NEW.post_id)
					ELSE ''
				END||
				CASE
					WHEN coalesce(NEW.email,'')<>'' THEN ', '||NEW.email
					ELSE ''
				END||
				CASE
					--||format_cel_standart(
					WHEN coalesce(NEW.tel,'')<>'' THEN ', +7'||NEW.tel||
						CASE
							WHEN coalesce(NEW.tel_ext,'')<>'' THEN ' ('||NEW.tel_ext||')'
							ELSE ''
						END
					ELSE ''
				END				
			;
		--END IF;
		
		RETURN NEW;
	END IF;
END;
$$;


ALTER FUNCTION public.contacts_process() OWNER TO nails;

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.contacts (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    post_id integer,
    email character varying(100),
    tel character varying(11),
    tel_ext character varying(20),
    descr text,
    comment_text text,
    email_confirmed boolean DEFAULT false,
    tel_confirmed boolean DEFAULT false
);


ALTER TABLE public.contacts OWNER TO nails;

--
-- Name: contacts_ref(public.contacts); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.contacts_ref(public.contacts) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.descr
		,
		'dataType','contacts'
	);
$_$;


ALTER FUNCTION public.contacts_ref(public.contacts) OWNER TO nails;

--
-- Name: contacts_upsert(text, text, text, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.contacts_upsert(in_name text, in_tel text, in_email text, in_tel_ext text) RETURNS json
    LANGUAGE plpgsql
    AS $$  
DECLARE
	v_contacts_ref json;
BEGIN  
	BEGIN
		INSERT INTO contacts (name, tel, email, tel_ext)
		VALUES (
			in_name,
			in_tel,
			CASE WHEN coalesce(in_email,'') = '' THEN NULL ELSE in_email END,
			CASE WHEN coalesce(in_tel_ext,'') = '' THEN NULL ELSE in_tel_ext END
		)
		RETURNING contacts_ref(contacts) AS contacts_ref INTO v_contacts_ref;
		
	EXCEPTION WHEN SQLSTATE '23505' THEN
		SELECT
			contacts_ref(contacts) AS contacts_ref
		INTO v_contacts_ref
		FROM contacts
		WHERE tel=in_tel;
	END;
	
	RETURN v_contacts_ref;
END;
$$;


ALTER FUNCTION public.contacts_upsert(in_name text, in_tel text, in_email text, in_tel_ext text) OWNER TO nails;

--
-- Name: document_templates_agent_dogovor(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_agent_dogovor(in_specialist_id integer) RETURNS jsonb
    LANGUAGE sql
    AS $$
	WITH
	contr_date AS
		(SELECT sp_st.date_time::date AS d
			FROM specialist_statuses AS sp_st
			WHERE sp_st.specialist_id = in_specialist_id
			AND sp_st.status_type = 'contract_signing'
		)	
	SELECT
		jsonb_build_object(
			'dogovorNum', to_char(sp.id, 'fm000'),
			'dateDay', (SELECT to_char(d, 'DD') FROM contr_date),			
			'dateMonthStr', (SELECT month_rus(d) FROM contr_date),
			'dateYear', (SELECT to_char(d, 'YYYY') FROM contr_date),
			'flName', sp.name,
			'flNameShort', person_init(sp.name),
			'flBirthdate', to_char(sp.birthdate, 'DD/MM/YYYY'),
			'flAddressReg', sp.address_reg,
			'flTel', (SELECT
					format_cel_phone(ct.tel)
				FROM entity_contacts AS e_ct				
				LEFT JOIN contacts AS ct ON ct.id = e_ct.contact_id
				WHERE e_ct.entity_type = 'specialists' AND e_ct.entity_id = in_specialist_id
				), 
			'flPassSeries', sp.passport->>'series',
			'flPassNum', sp.passport->>'num',
			'flPassIssueDate', to_char((sp.passport->>'issue_date')::date, 'DD/MM/YYYY'),
			'flPassIssueBody', sp.passport->>'issue_body',
			'flPassDepCode', sp.passport->>'dep_code',
			'flInn', sp.inn,
			'bankBik', sp.bank_bik,
			'bankAccNum', sp.bank_acc
			-- Это делаем при вызове функции когда надо
			--'flSign', '   '
		)
	FROM specialists AS sp
	WHERE sp.id = in_specialist_id;
$$;


ALTER FUNCTION public.document_templates_agent_dogovor(in_specialist_id integer) OWNER TO nails;

--
-- Name: document_templates_application(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_application(in_specialist_reg_id integer) RETURNS jsonb
    LANGUAGE sql
    AS $$
	SELECT
		jsonb_build_object(
			'flName', sp.name_full,
			'flNameShort', person_init(sp.name_full),
			'flBirthdate', to_char(sp.birthdate, 'DD/MM/YYYY'),
			'flAddressReg', sp.address_reg,
			'flTel', format_cel_phone(sp.tel),
			'flEmail', sp.email,
			'flPassSeries', sp.passport->>'series',
			'flPassNum', sp.passport->>'num',
			'flPassIssueDate', to_char((sp.passport->>'issue_date')::date, 'DD/MM/YYYY'),
			'flPassIssueBody', sp.passport->>'issue_body',
			'flPassIssueDepCode', sp.passport->>'dep_code',
			'flInn', sp.inn,
			'bankName', sp.banks_ref->>'descr',
			'bankBik', sp.banks_ref->'id'->>'bik',
			'bankAccNum', sp.bank_acc
		)
	FROM specialist_regs AS sp
	WHERE sp.id = in_specialist_reg_id;
$$;


ALTER FUNCTION public.document_templates_application(in_specialist_reg_id integer) OWNER TO nails;

--
-- Name: document_templates_format_num(numeric); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_format_num(in_num numeric) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
	SELECT
		CASE
			WHEN in_num = 0 THEN '0,00'
			ELSE
				replace(
					replace( 
						trim( to_char(in_num, '999,999D99') ) 
					, ',', ' ') --thousand
				,'.',',') --decimal
		END
	;
$$;


ALTER FUNCTION public.document_templates_format_num(in_num numeric) OWNER TO nails;

--
-- Name: document_templates_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM attachments WHERE ref->>'dataType' = 'document_templates' AND (ref->'keys'->>'id')::int = OLD.id;
			
		RETURN OLD;
		
	END IF;
END;
$$;


ALTER FUNCTION public.document_templates_process() OWNER TO nails;

--
-- Name: document_templates; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.document_templates (
    id integer NOT NULL,
    name text,
    fields jsonb,
    sql_query text,
    need_signing boolean,
    sign_image_name text
);


ALTER TABLE public.document_templates OWNER TO nails;

--
-- Name: document_templates_ref(public.document_templates); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_ref(public.document_templates) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','document_templates'
	);
$_$;


ALTER FUNCTION public.document_templates_ref(public.document_templates) OWNER TO nails;

--
-- Name: document_templates_rent_contract(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_rent_contract(in_specialist_id integer) RETURNS jsonb
    LANGUAGE sql
    AS $$
	WITH
	contr_date AS
		(SELECT
			sp_st.date_time::date AS d
		FROM specialist_statuses AS sp_st
		WHERE sp_st.specialist_id = in_specialist_id
		AND sp_st.status_type = 'contract_signing'
		)	
	SELECT
		jsonb_build_object(
			'dogovorNum', to_char(sp.id, 'fm000'),
			'dateDay', (SELECT to_char(d, 'DD') FROM contr_date),			
			'dateMonthStr', (SELECT month_rus(d) FROM contr_date),
			'dateYear', (SELECT to_char(d, 'YYYY') FROM contr_date),
			'flName', sp.name,
			'flNameShort', person_init(sp.name),
			'flBirthdate', to_char(sp.birthdate, 'DD/MM/YYYY'),
			'flAddressReg', sp.address_reg,
			'flTel', (SELECT
					format_cel_phone(ct.tel)
				FROM entity_contacts AS e_ct				
				LEFT JOIN contacts AS ct ON ct.id = e_ct.contact_id
				WHERE e_ct.entity_type = 'specialists' AND e_ct.entity_id = in_specialist_id
				), 
			'flPassSeries', sp.passport->>'series',
			'flPassNum', sp.passport->>'num',
			'flPassIssueDate', to_char((sp.passport->>'issue_date')::date, 'DD/MM/YYYY'),
			'flPassIssueBody', sp.passport->>'issue_body',
			'flPassDepCode', sp.passport->>'dep_code',
			'flInn', sp.inn,
			'bankBik', sp.bank_bik,
			'bankAccNum', sp.bank_acc,
			'equip',
				(SELECT
					jsonb_agg(
						jsonb_build_object(
							'name', r->'fields'->>'name',
							'quant', r->'fields'->>'quant',
							'mUnit', r->'fields'->>'measure_unit'
						)						
					)
				FROM jsonb_array_elements(sp.equipments->'rows') AS r
				)
		)
	FROM specialists AS sp
	WHERE sp.id = in_specialist_id;
$$;


ALTER FUNCTION public.document_templates_rent_contract(in_specialist_id integer) OWNER TO nails;

--
-- Name: document_templates_salary(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_salary(in_salary_detail_id integer) RETURNS jsonb
    LANGUAGE sql
    AS $$
	WITH
	contr_date AS
		(SELECT
			sp_st.date_time::date AS d
		FROM specialist_statuses AS sp_st
		WHERE sp_st.specialist_id = in_salary_detail_id
		AND sp_st.status_type = 'contract_signing'
		)	
	SELECT
		jsonb_build_object(
			'dateDay', to_char(sal_h.date_time::date, 'DD'),			
			'dateMonthStr', month_rus(sal_h.date_time::date),
			'dateYear', to_char(sal_h.date_time, 'YYYY'),
			
			'aktNum', to_char(sal_h.id, 'fm00000') || '-' || to_char(sal.line_num, 'fm00'),
			'aktDateDay', to_char(sal_h.date_time::date, 'DD'),			
			'aktDateMonthStr', month_rus(sal_h.date_time::date),
			'aktDateYear', to_char(sal_h.date_time::date, 'YYYY'),
			
			'dogNum', to_char(sp.id, 'fm000'),
			'dogDateDay', to_char(stat.date_time::date, 'DD'),			
			'dogDateMonthStr', month_rus(stat.date_time::date),
			'dogDateYear', to_char(stat.date_time::date, 'YYYY'),
			'flName', sp.name,
			'flNameShort', person_init(sp.name),
			'perFromDateDay', to_char(sal.period, 'DD'),
			'perFromDateMonthStr', month_rus(sal.period),
			'perFromDateYear', to_char(sal.period, 'YYYY'),
			'perToDateDay', to_char(last_month_day(sal.period), 'DD'),
			'perToDateMonthStr', month_rus(sal.period),
			'perToDateYear', to_char(sal.period, 'YYYY'),
			'cust',
				(SELECT
					count(sb.*)
				FROM (
					SELECT
						DISTINCT ycl.client||ycl.client_phone
					FROM ycl_transactions_list AS ycl
					WHERE ycl.specialist_id = sp.id
						AND ycl.date BETWEEN sal.period AND last_month_day(sal.period)
					GROUP BY ycl.client,ycl.client_phone
				) AS sb
				),
			
			'serv',
				(SELECT count(ycl.*)
				FROM ycl_transactions_doc_all_list AS ycl
				WHERE ycl.specialist_id = sp.id
					AND ycl.date BETWEEN sal.period AND last_month_day(sal.period)
				),
			
			'hour', sal.hours,
			'total', document_templates_format_num(sal.total),
			'workTotal', document_templates_format_num(sal.work_total),
			'dkTotal', document_templates_format_num(sal.debet - sal.kredit),
			'rent', document_templates_format_num(sal.rent_total),
			'agentTotal', document_templates_format_num(sal.work_total - sal.work_total_salary)
		)
	FROM specialist_period_salary_details AS sal
	LEFT JOIN specialists AS sp ON sp.id = sal.specialist_id
	LEFT JOIN specialist_statuses AS stat ON stat.specialist_id = sal.specialist_id AND stat.status_type = 'contract_signing'
	LEFT JOIN specialist_period_salaries AS sal_h ON sal_h.id = sal.specialist_period_salary_id
	WHERE sal.id = in_salary_detail_id
	;
$$;


ALTER FUNCTION public.document_templates_salary(in_salary_detail_id integer) OWNER TO nails;

--
-- Name: document_templates_spec_reg_exec_query(integer, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_spec_reg_exec_query(in_specialist_id integer, in_query text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_res jsonb;
BEGIN
	EXECUTE replace(in_query, '%d'::text, in_specialist_id::text) INTO v_res;
	RETURN v_res;
END;
$$;


ALTER FUNCTION public.document_templates_spec_reg_exec_query(in_specialist_id integer, in_query text) OWNER TO nails;

--
-- Name: document_templates_spec_sal_exec_query(integer, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.document_templates_spec_sal_exec_query(in_salary_detail_id integer, in_query text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_res jsonb;
BEGIN
	EXECUTE replace(in_query, '%d'::text, in_salary_detail_id::text) INTO v_res;
	RETURN v_res;
END;
$$;


ALTER FUNCTION public.document_templates_spec_sal_exec_query(in_salary_detail_id integer, in_query text) OWNER TO nails;

--
-- Name: email_check(text, text, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.email_check(in_to_addr text, in_name_full text, in_key text) RETURNS TABLE(from_addr text, from_name text, reply_name text, sender_addr text, to_addr text, to_name text, body text, subject text)
    LANGUAGE sql
    AS $$
	WITH
	email AS (SELECT const_email_val() AS v),
	tmpl AS (SELECT
			t.template AS v,
			(SELECT
				fields.f->'fields'->>'descr'
			FROM (
				SELECT json_array_elements(t.provider_values->'rows') AS f
			) AS fields	
			WHERE fields.f->'fields'->>'id'='subject'
			LIMIT 1
			) AS s
			
		FROM notif_templates t
		WHERE t.notif_type = 'email_check'::notif_types
		LIMIT 1
	)	
	SELECT
		(SELECT v->>'from_addr' FROM email) AS from_addr,
		(SELECT v->>'from_name' FROM email) AS from_name,
		(SELECT v->>'reply_name' FROM email) AS reply_name,
		(SELECT v->>'sender_addr' FROM email) AS sender_addr,
		in_to_addr AS to_addr,
		in_name_full AS to_name,
		coalesce(templates_text(
			ARRAY[
				ROW('key', in_key)::template_value,
				ROW('name', in_name_full)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body,
		coalesce((SELECT s FROM tmpl),'') AS subject
	;
$$;


ALTER FUNCTION public.email_check(in_to_addr text, in_name_full text, in_key text) OWNER TO nails;

--
-- Name: email_new_account(integer, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.email_new_account(in_specialist_id integer, in_pwd text) RETURNS TABLE(from_addr text, from_name text, reply_name text, sender_addr text, to_addr text, to_name text, body text, subject text)
    LANGUAGE sql
    AS $$
	WITH
	email AS (SELECT const_email_val() AS v),
	tmpl AS (SELECT
			t.template AS v,
			(SELECT
				fields.f->'fields'->>'descr'
			FROM (
				SELECT json_array_elements(t.provider_values->'rows') AS f
			) AS fields	
			WHERE fields.f->'fields'->>'id'='subject'
			LIMIT 1
			) AS s
			
		FROM notif_templates t
		WHERE t.notif_type = 'new_account'::notif_types AND t.notif_provider = 'email'
		LIMIT 1
	)	
	SELECT
		(SELECT v->>'from_addr' FROM email) AS from_addr,
		(SELECT v->>'from_name' FROM email) AS from_name,
		(SELECT v->>'reply_name' FROM email) AS reply_name,
		(SELECT v->>'sender_addr' FROM email) AS sender_addr,
		ct.email AS to_addr,
		sp.name AS to_name,
		coalesce(templates_text(
			ARRAY[
				ROW('pwd', in_pwd)::template_value,
				ROW('name', sp.name)::template_value,
				ROW('login', '7'||u.name)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body,
		coalesce((SELECT s FROM tmpl),'') AS subject
	FROM specialists AS sp
	LEFT JOIN users AS u ON u.id = sp.user_id
	LEFT JOIN entity_contacts AS e_ct ON e_ct.entity_id = sp.id AND e_ct.entity_type = 'specialists'
	LEFT JOIN contacts AS ct ON ct.id = e_ct.contact_id
	WHERE sp.id = in_specialist_id
	;
$$;


ALTER FUNCTION public.email_new_account(in_specialist_id integer, in_pwd text) OWNER TO nails;

--
-- Name: email_signed_docs(text, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.email_signed_docs(in_to_addr text, in_name_full text) RETURNS TABLE(from_addr text, from_name text, reply_name text, sender_addr text, to_addr text, to_name text, body text, subject text)
    LANGUAGE sql
    AS $$
	WITH
	email AS (SELECT const_email_val() AS v),
	tmpl AS (SELECT
			t.template AS v,
			(SELECT
				fields.f->'fields'->>'descr'
			FROM (
				SELECT json_array_elements(t.provider_values->'rows') AS f
			) AS fields	
			WHERE fields.f->'fields'->>'id'='subject'
			LIMIT 1
			) AS s
			
		FROM notif_templates t
		WHERE t.notif_type = 'signed_docs'::notif_types AND t.notif_provider = 'email'
		LIMIT 1
	)	
	SELECT
		(SELECT v->>'from_addr' FROM email) AS from_addr,
		(SELECT v->>'from_name' FROM email) AS from_name,
		(SELECT v->>'reply_name' FROM email) AS reply_name,
		(SELECT v->>'sender_addr' FROM email) AS sender_addr,
		in_to_addr AS to_addr,
		in_name_full AS to_name,
		coalesce(templates_text(
			ARRAY[
				ROW('name', in_name_full)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body,
		coalesce((SELECT s FROM tmpl),'') AS subject
	;
$$;


ALTER FUNCTION public.email_signed_docs(in_to_addr text, in_name_full text) OWNER TO nails;

--
-- Name: enum_data_types_val(public.data_types, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_data_types_val(public.data_types, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='users'::data_types AND $2='ru'::locales THEN 'Пользователи'
		WHEN $1='specialists'::data_types AND $2='ru'::locales THEN 'Мастера'
		WHEN $1='specialist_regs'::data_types AND $2='ru'::locales THEN 'Регистрация мастера'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_data_types_val(public.data_types, public.locales) OWNER TO nails;

--
-- Name: enum_locales_val(public.locales, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_locales_val(public.locales, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='ru'::locales AND $2='ru'::locales THEN 'Русский'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_locales_val(public.locales, public.locales) OWNER TO nails;

--
-- Name: enum_mail_types_val(public.mail_types, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_mail_types_val(public.mail_types, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='password_recover'::mail_types AND $2='ru'::locales THEN 'Восстановление пароля'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_mail_types_val(public.mail_types, public.locales) OWNER TO nails;

--
-- Name: enum_notif_providers_val(public.notif_providers, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_notif_providers_val(public.notif_providers, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='email'::notif_providers AND $2='ru'::locales THEN 'Электронная почта'
		WHEN $1='sms'::notif_providers AND $2='ru'::locales THEN 'СМС'
		WHEN $1='wa'::notif_providers AND $2='ru'::locales THEN 'WhatsUp'
		WHEN $1='tm'::notif_providers AND $2='ru'::locales THEN 'Telegram'
		WHEN $1='vb'::notif_providers AND $2='ru'::locales THEN 'Viber'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_notif_providers_val(public.notif_providers, public.locales) OWNER TO nails;

--
-- Name: enum_notif_types_val(public.notif_types, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_notif_types_val(public.notif_types, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='new_specialist'::notif_types AND $2='ru'::locales THEN 'Добавлен самозанятый'
		WHEN $1='tel_check'::notif_types AND $2='ru'::locales THEN 'Проверка телефона'
		WHEN $1='email_check'::notif_types AND $2='ru'::locales THEN 'Проверка электронной почты'
		WHEN $1='docs_for_sign'::notif_types AND $2='ru'::locales THEN 'Документы для подписания'
		WHEN $1='signed_docs'::notif_types AND $2='ru'::locales THEN 'Подписанные документы'
		WHEN $1='new_account'::notif_types AND $2='ru'::locales THEN 'Новый аккаунт'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_notif_types_val(public.notif_types, public.locales) OWNER TO nails;

--
-- Name: enum_role_types_val(public.role_types, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_role_types_val(public.role_types, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='admin'::role_types AND $2='ru'::locales THEN 'Администратор'
		WHEN $1='specialist'::role_types AND $2='ru'::locales THEN 'Мастер'
		WHEN $1='accountant'::role_types AND $2='ru'::locales THEN 'Бухгалтер'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_role_types_val(public.role_types, public.locales) OWNER TO nails;

--
-- Name: enum_specialist_status_types_val(public.specialist_status_types, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_specialist_status_types_val(public.specialist_status_types, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='contract_signing'::specialist_status_types AND $2='ru'::locales THEN 'Подписание контракта'
		WHEN $1='contract_signed'::specialist_status_types AND $2='ru'::locales THEN 'Заключен контракт'
		WHEN $1='contract_terminated'::specialist_status_types AND $2='ru'::locales THEN 'Расторгнут контракт'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_specialist_status_types_val(public.specialist_status_types, public.locales) OWNER TO nails;

--
-- Name: enum_template_batch_types_val(public.template_batch_types, public.locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.enum_template_batch_types_val(public.template_batch_types, public.locales) RETURNS text
    LANGUAGE sql
    AS $_$
		SELECT
		CASE
		WHEN $1='specialist_registration'::template_batch_types AND $2='ru'::locales THEN 'Регистрация мастера'
		WHEN $1='specialist_salary'::template_batch_types AND $2='ru'::locales THEN 'Расчет зарплаты'
		ELSE ''
		END;		
	$_$;


ALTER FUNCTION public.enum_template_batch_types_val(public.template_batch_types, public.locales) OWNER TO nails;

--
-- Name: firms; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.firms (
    id integer NOT NULL,
    name text NOT NULL,
    inn character varying(12),
    name_full text,
    legal_address text,
    post_address text,
    kpp character varying(10),
    ogrn character varying(15),
    okpo character varying(20),
    okved text,
    bank_acc character varying(20),
    bank_bik character varying(9)
);


ALTER TABLE public.firms OWNER TO nails;

--
-- Name: firms_ref(public.firms); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.firms_ref(public.firms) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','firms'
	);
$_$;


ALTER FUNCTION public.firms_ref(public.firms) OWNER TO nails;

--
-- Name: format_cel_phone(text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.format_cel_phone(text) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
	SELECT 
		CASE
			WHEN char_length($1)<10 THEN $1
			ELSE
				'+7-'||substr($1,1,3)||'-'||substr($1,4,3)||'-'||substr($1,7,2)||'-'||substr($1,9,2)
		END;
$_$;


ALTER FUNCTION public.format_cel_phone(text) OWNER TO nails;

--
-- Name: last_month_day(date); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.last_month_day(date) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
 	SELECT (date_trunc('MONTH', $1) + INTERVAL '1 MONTH - 1 day')::date;
$_$;


ALTER FUNCTION public.last_month_day(date) OWNER TO nails;

--
-- Name: login_devices_uniq(jsonb); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.login_devices_uniq(user_agent jsonb) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
	SELECT CASE WHEN (user_agent->>'bot')::bool THEN 'Бот, ' ELSE '' END||
		CASE WHEN (user_agent->>'mobile')::bool THEN 'Мобильное устр-во, ' ELSE '' END||
		'ОС:'||(user_agent->>'osName')::text||', '||
		'платформа: '||(user_agent->>'platform')::text
	;
$$;


ALTER FUNCTION public.login_devices_uniq(user_agent jsonb) OWNER TO nails;

--
-- Name: logins_user_agent_descr(jsonb); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.logins_user_agent_descr(user_agent jsonb) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
	SELECT
		CASE WHEN (user_agent->>'bot')::bool THEN 'Бот, ' ELSE '' END||
		CASE WHEN (user_agent->>'mobile')::bool THEN 'Мобильное устр-во, ' ELSE '' END||
		'ОС:'||(user_agent->>'osName')::text||', '||
		CASE WHEN coalesce(user_agent->>'osVersion','')<>'' THEN 'версия:'||(user_agent->>'osVersion')::text||', ' ELSE '' END||	
		'платформа: '||(user_agent->>'platform')::text||', '||
		CASE WHEN coalesce(user_agent->>'browserName','')<>'' THEN 'браузер:'||(user_agent->>'browserName')::text||' '||(user_agent->>'browserVersion')::text||', ' ELSE '' END
	
$$;


ALTER FUNCTION public.logins_user_agent_descr(user_agent jsonb) OWNER TO nails;

--
-- Name: month_period_rus(date); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.month_period_rus(in_date date) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT
		(SELECT unnest(ARRAY['Январь', 'Февраль', 'Март', 'Апрель', 'Май',
			'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь',
			'Ноябрь', 'Декабрь'])
		LIMIT 1 OFFSET date_part('month', $1) - 1		
		) || ' ' ||date_part('year', in_date)::text
	;
$_$;


ALTER FUNCTION public.month_period_rus(in_date date) OWNER TO nails;

--
-- Name: month_rus(date); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.month_rus(date) RETURNS character varying
    LANGUAGE sql
    AS $_$
	SELECT unnest(ARRAY['Января', 'Февраля', 'Марта', 'Апреля', 'Мая',
		'Июня', 'Июля', 'Августа', 'Сентября', 'Октября',
		'Ноября', 'Декабря'])
	LIMIT 1 OFFSET date_part('month', $1) - 1;
$_$;


ALTER FUNCTION public.month_rus(date) OWNER TO nails;

--
-- Name: parse_person_name(text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.parse_person_name(text) RETURNS record
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT
		CASE
			WHEN position(' ' in $1)=0 THEN
				--нет Имя,отчество
				ROW(capit_first_letter($1)::text,''::text,''::text)
			ELSE
				CASE
					WHEN position(' ' in substr($1,position(' ' in $1)+1 ))=0 THEN
						--нет отчество
						ROW(
							capit_first_letter(substr($1,1,position(' ' in $1))::text),
							capit_first_letter(substr($1,position(' ' in $1)+1)::text),
							''::text
						)
					ELSE
						--есть все
						ROW(
							capit_first_letter(substr($1,1,position(' ' in $1)-1)::text),
							
							capit_first_letter(
							substr($1,position(' ' in $1)+1,
							   position(' ' in 
								substr($1,position(' ' in $1)+1)
								)-1		
							)::text
							),
							
							capit_first_letter(
								substr(substr($1,position(' ' in $1)+1),position(' ' in substr($1,position(' ' in $1)+1))+1)::text
							)
						)								
				END
		END
$_$;


ALTER FUNCTION public.parse_person_name(text) OWNER TO nails;

--
-- Name: permissions_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.permissions_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM pg_notify('Permission.change', NULL);
	
	IF TG_WHEN='AFTER' AND (TG_OP='UPDATE' OR TG_OP='INSERT') THEN
		
		RETURN NEW;
		
	ELSIF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		RETURN OLD;
		
	END IF;
END;
$$;


ALTER FUNCTION public.permissions_process() OWNER TO nails;

--
-- Name: person_init(text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.person_init(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT
		first||
		CASE WHEN length(second)>0 THEN ' '||substr(second,1,1)||'.' ELSE '' END||
		CASE WHEN length(middle)>0 THEN ' '||substr(middle,1,1)||'.' ELSE '' END
	FROM parse_person_name($1)
	AS (first text,second text,middle text)
$_$;


ALTER FUNCTION public.person_init(text) OWNER TO nails;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


ALTER TABLE public.posts OWNER TO nails;

--
-- Name: posts_ref(public.posts); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.posts_ref(public.posts) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','posts'
	);
$_$;


ALTER FUNCTION public.posts_ref(public.posts) OWNER TO nails;

--
-- Name: salary_debets; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.salary_debets (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.salary_debets OWNER TO nails;

--
-- Name: salary_debets_ref(public.salary_debets); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.salary_debets_ref(public.salary_debets) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','salary_debets'
	);
$_$;


ALTER FUNCTION public.salary_debets_ref(public.salary_debets) OWNER TO nails;

--
-- Name: salary_kredits; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.salary_kredits (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.salary_kredits OWNER TO nails;

--
-- Name: salary_kredits_ref(public.salary_kredits); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.salary_kredits_ref(public.salary_kredits) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','salary_kredits'
	);
$_$;


ALTER FUNCTION public.salary_kredits_ref(public.salary_kredits) OWNER TO nails;

--
-- Name: session_vals_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.session_vals_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		UPDATE logins SET date_time_out = now() WHERE session_id=OLD.id;
		
		RETURN OLD;
	END IF;
END;
$$;


ALTER FUNCTION public.session_vals_process() OWNER TO nails;

--
-- Name: sms_docs_for_sign(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.sms_docs_for_sign(in_specialist_id integer) RETURNS TABLE(tel text, body text)
    LANGUAGE sql
    AS $$
	WITH
	tmpl AS (SELECT
			t.template AS v
		FROM notif_templates t
		WHERE t.notif_type = 'docs_for_sign'::notif_types AND t.notif_provider = 'sms'
		LIMIT 1
	)	
	SELECT
		'7'||sp.tel AS tel,
		coalesce(templates_text(
			ARRAY[]::template_value[],
			(SELECT v FROM tmpl)
		), '') AS body
	FROM specialists_dialog AS sp
	WHERE sp.id = in_specialist_id
	;
$$;


ALTER FUNCTION public.sms_docs_for_sign(in_specialist_id integer) OWNER TO nails;

--
-- Name: sms_tel_check(text, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.sms_tel_check(in_tel text, in_key text) RETURNS TABLE(tel text, body text)
    LANGUAGE sql
    AS $$
	WITH
	tmpl AS (SELECT
			t.template AS v
		FROM notif_templates t
		WHERE t.notif_type = 'tel_check'::notif_types AND t.notif_provider = 'sms'
		LIMIT 1
	)	
	SELECT
		in_tel AS tel,
		coalesce(templates_text(
			ARRAY[
				ROW('key', in_key)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body
	;
$$;


ALTER FUNCTION public.sms_tel_check(in_tel text, in_key text) OWNER TO nails;

--
-- Name: specialist_documents_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_documents_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		DELETE FROM attachments WHERE id = OLD.template_att_id;
		DELETE FROM attachments WHERE id = OLD.document_att_id;
			
		RETURN OLD;
	END IF;
END;
$$;


ALTER FUNCTION public.specialist_documents_process() OWNER TO nails;

--
-- Name: specialist_period_salaries_fill(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_period_salaries_fill(in_specialist_period_salary_id integer) RETURNS void
    LANGUAGE sql
    AS $$
	DELETE FROM specialist_period_salary_details WHERE specialist_period_salary_id = in_specialist_period_salary_id;
	
	INSERT INTO specialist_period_salary_details
	(specialist_period_salary_id, specialist_id, studio_id, period,
	hours, agent_percent, work_total, work_total_salary, debet, kredit, rent_price, rent_total, total
	)
	WITH
	header AS (
		SELECT
			t.studio_id,
			t.period::date,
			(date_trunc('month', period) + '1 month'::interval - '1 day'::interval)::date period_end,
			std.hour_rent_price AS rent_price
			
		FROM specialist_period_salaries AS t
		LEFT JOIN studios AS std ON std.id = t.studio_id
		WHERE t.id = in_specialist_period_salary_id
	)
	SELECT
		in_specialist_period_salary_id,
		trans.specialist_id,
		(SELECT studio_id FROM header),
		(SELECT period FROM header),
		
		spt.agent_percent,
		
		sum(trans.len_hour) AS hours,
		sum(trans.amount) AS work_total,
		
		sum(trans.amount) - round(sum(trans.amount) * spt.agent_percent /100,2) AS work_total_salary,
		
		(SELECT
			sum(t.total)
		FROM specialist_salary_debets AS t
		WHERE t.specialist_id = trans.specialist_id AND (t.date_time::date BETWEEN (SELECT period FROM header) AND (SELECT period_end FROM header))
		) AS debet,
		
		(SELECT
			sum(t.total)
		FROM specialist_salary_kredits AS t
		WHERE t.specialist_id = trans.specialist_id AND (t.date_time::date BETWEEN (SELECT period FROM header) AND (SELECT period_end FROM header))
		) AS kredit,
		
		(SELECT rent_price FROM header) AS rent_price,
		(SELECT rent_price FROM header) * sum(trans.len_hour) AS rent_total,
		
		--work_total - 
		sum(trans.amount) - round(sum(trans.amount) * spt.agent_percent /100,2) - 
		(SELECT
			sum(t.total)
		FROM specialist_salary_debets AS t
		WHERE t.specialist_id = trans.specialist_id AND (t.date_time::date BETWEEN (SELECT period FROM header) AND (SELECT period_end FROM header))
		) - 		
		(SELECT
			sum(t.total)
		FROM specialist_salary_kredits AS t
		WHERE t.specialist_id = trans.specialist_id AND (t.date_time::date BETWEEN (SELECT period FROM header) AND (SELECT period_end FROM header))
		) - 
		((SELECT rent_price FROM header) * sum(trans.len_hour) )
		AS total
				
	FROM ycl_transactions_doc_all_list AS trans
	LEFT JOIN specialists AS sp ON sp.id = trans.specialist_id
	LEFT JOIN specialities AS spt ON spt.id = sp.speciality_id
	WHERE trans.date::date BETWEEN (SELECT period FROM header) AND (SELECT period_end FROM header)
		AND trans.specialist_id IS NOT NULL
	GROUP BY trans.specialist_id, spt.agent_percent	
	;
$$;


ALTER FUNCTION public.specialist_period_salaries_fill(in_specialist_period_salary_id integer) OWNER TO nails;

--
-- Name: specialist_period_salaries_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_period_salaries_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM specialist_period_salary_details WHERE specialist_period_salary_id = OLD.id;
			
		RETURN OLD;
	END IF;
END;
$$;


ALTER FUNCTION public.specialist_period_salaries_process() OWNER TO nails;

--
-- Name: specialist_period_salaries; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_period_salaries (
    id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    period date NOT NULL,
    total numeric(15,2) DEFAULT 0,
    work_total numeric(15,2) DEFAULT 0,
    hours integer DEFAULT 0,
    debet numeric(15,2) DEFAULT 0,
    kredit numeric(15,2) DEFAULT 0,
    rent_total numeric(15,2) DEFAULT 0,
    work_total_salary numeric(15,2) DEFAULT 0,
    studio_id integer NOT NULL
);


ALTER TABLE public.specialist_period_salaries OWNER TO nails;

--
-- Name: specialist_period_salaries_ref(public.specialist_period_salaries); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_period_salaries_ref(public.specialist_period_salaries) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.id || '(' || to_char($1.date_time, 'DD/MM/YY') || ', ' || month_period_rus($1.date_time::DATE)||')',
		'dataType','specialist_period_salaries'
	);
$_$;


ALTER FUNCTION public.specialist_period_salaries_ref(public.specialist_period_salaries) OWNER TO nails;

--
-- Name: specialist_period_salary_details_docs_to_bank(integer[]); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_period_salary_details_docs_to_bank(in_ids integer[]) RETURNS SETOF public.bank_payments
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_firm_cnt int;
BEGIN
	-- проверим, что нет разных организаций
	SELECT
		count(DISTINCT studios.firm_id)
	INTO 
		v_firm_cnt
	FROM specialist_period_salary_details AS t
	LEFT JOIN studios ON studios.id = t.studio_id
	WHERE t.id =ANY(in_ids);
	
	IF v_firm_cnt > 1 THEN
		RAISE EXCEPTION 'В списке документов есть разные организации';
	END IF;
	
	RETURN QUERY
		INSERT INTO bank_payments
		(document_date, document_num, document_total, document_comment,
		payer_acc, payer_bank_acc, payer_bank_bik, payer_bank, payer_bank_place, payer, payer_inn,
		rec_acc, rec_bank_acc, rec_bank_bik, rec_bank, rec_bank_place, rec, rec_inn,
		specialist_id, specialist_period_salary_detail_id
		)
		SELECT
			now(),
			coalesce((SELECT max(document_num) FROM bank_payments), 1) + 1,
			det.total,
			replace(
				replace(const_specialist_pay_comment_template_val(), '[sum]', trim(replace(to_char(det.total, '999999.99'), '.', '-')))
			,'[fio]', person_init(sp.name)),
			
			firms.bank_acc,
			payer_bn.korshet,
			firms.bank_bik,
			payer_bn.name,
			payer_bn.gor,
			firms.name_full,
			firms.inn,
			
			sp.bank_acc,
			rec_bn.korshet,
			sp.bank_bik,
			rec_bn.name,
			rec_bn.gor,
			sp.name,
			sp.inn,
			
			sp.id,
			det.id
			
		FROM specialist_period_salary_details AS det
		LEFT JOIN specialists AS sp ON sp.id = det.specialist_id
		LEFT JOIN studios ON studios.id = det.studio_id
		LEFT JOIN firms ON firms.id = studios.firm_id
		LEFT JOIN banks.banks AS payer_bn ON payer_bn.bik = firms.bank_bik
		LEFT JOIN banks.banks AS rec_bn ON rec_bn.bik = sp.bank_bik
		WHERE det.id =ANY(in_ids)
		RETURNING bank_payments.*
		;		
	
END;
$$;


ALTER FUNCTION public.specialist_period_salary_details_docs_to_bank(in_ids integer[]) OWNER TO nails;

--
-- Name: specialist_period_salary_details_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_period_salary_details_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN

		IF TG_OP = 'INSERT' THEN
			SELECT
				coalesce(MAX(t.line_num),0)+1
			INTO NEW.line_num
			FROM specialist_period_salary_details AS t
			WHERE t.specialist_period_salary_id = NEW.specialist_period_salary_id;
			
			--default values for studio/period
			SELECT
				sal.period,
				sal.studio_id
			INTO
				NEW.period,
				NEW.studio_id
			FROM specialist_period_salaries AS sal
			WHERE sal.id = NEW.specialist_period_salary_id;
		END IF;
		
		RETURN NEW;
	
	ELSIF TG_WHEN='AFTER' AND (TG_OP='UPDATE' OR TG_OP='INSERT') THEN
		
		--totals
		IF (TG_OP='INSERT' AND coalesce(NEW.total,0)<>0) OR ( TG_OP='UPDATE' AND (coalesce(NEW.total,0)<>coalesce(OLD.total,0)) )
		THEN
			UPDATE specialist_period_salaries SET
				total = sel.total,
				work_total = sel.work_total,
				work_total_salary = sel.work_total_salary,
				rent_total = sel.rent_total,
				hours = sel.hours,
				debet = sel.debet,
				kredit = sel.kredit				
			FROM (
				SELECT
					sum(coalesce(it.total)) AS total,
					sum(coalesce(it.work_total)) AS work_total,
					sum(coalesce(it.work_total_salary)) AS work_total_salary,
					sum(coalesce(it.rent_total)) AS rent_total,
					sum(coalesce(it.hours)) AS hours,
					sum(coalesce(it.debet)) AS debet,
					sum(coalesce(it.kredit)) AS kredit
				FROM specialist_period_salary_details AS it
				WHERE it.specialist_period_salary_id = NEW.specialist_period_salary_id
			) AS sel
			WHERE id = NEW.specialist_period_salary_id;			
		END IF;
		
		RETURN NEW;
	
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		DELETE FROM specialist_receipts WHERE specialist_period_salary_detail_id = OLD.id;
		DELETE FROM bank_payments WHERE specialist_period_salary_detail_id = OLD.id;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		
		UPDATE specialist_period_salaries SET
			total = total - OLD.total,
			work_total = work_total - OLD.work_total,
			work_total_salary = work_total_salary - OLD.work_total_salary,
			rent_total = rent_total - OLD.rent_total,
			hours = hours - OLD.hours,
			debet = debet - OLD.debet,
			kredit = kredit - OLD.kredit
		WHERE id = NEW.specialist_period_salary_id;
		
		RETURN OLD;
	END IF;
END;
$$;


ALTER FUNCTION public.specialist_period_salary_details_process() OWNER TO nails;

--
-- Name: specialist_period_salary_details; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_period_salary_details (
    id integer NOT NULL,
    specialist_period_salary_id integer NOT NULL,
    specialist_id integer NOT NULL,
    studio_id integer NOT NULL,
    period date NOT NULL,
    hours integer DEFAULT 0,
    work_total numeric(15,2) DEFAULT 0,
    debet numeric(15,2) DEFAULT 0,
    kredit numeric(15,2) DEFAULT 0,
    rent_price numeric(15,2) DEFAULT 0,
    rent_total numeric(15,2) DEFAULT 0,
    total numeric(15,2) DEFAULT 0,
    line_num integer NOT NULL,
    work_total_salary numeric(15,2) DEFAULT 0,
    agent_percent numeric(15,2) DEFAULT 0
);


ALTER TABLE public.specialist_period_salary_details OWNER TO nails;

--
-- Name: specialist_period_salary_details_ref(public.specialist_period_salary_details); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_period_salary_details_ref(public.specialist_period_salary_details) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr','Зарплата ' || (SELECT st.name FROM studios AS st WHERE st.id=$1.studio_id)||' '||month_period_rus($1.period),
		'dataType','specialist_period_salary_details'
	);
$_$;


ALTER FUNCTION public.specialist_period_salary_details_ref(public.specialist_period_salary_details) OWNER TO nails;

--
-- Name: specialist_receipts_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_receipts_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_spec text;
BEGIN
	IF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		DELETE FROM attachments WHERE (ref->'keys'->>'id')::int = OLD.id AND ref->>'dataType' = 'specialist_receipts';
			
		RETURN OLD;		
	END IF;
END;
$$;


ALTER FUNCTION public.specialist_receipts_process() OWNER TO nails;

--
-- Name: specialist_regs_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_regs_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM attachments WHERE (ref->'keys'->>'id')::int = OLD.id AND ref->>'dataType' = 'specialist_regs';
		DELETE FROM confirmation_status WHERE (ref->'keys'->>'id')::int = OLD.id AND ref->>'dataType' = 'specialist_regs';
			
		RETURN OLD;
		
	END IF;
END;
$$;


ALTER FUNCTION public.specialist_regs_process() OWNER TO nails;

--
-- Name: specialist_works_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialist_works_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM attachments WHERE (ref->'keys'->>'id')::int = OLD.id AND ref->>'dataType' = 'specialist_works';
			
		RETURN OLD;
		
	END IF;
END;
$$;


ALTER FUNCTION public.specialist_works_process() OWNER TO nails;

--
-- Name: specialists_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialists_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_spec text;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM specialist_statuses WHERE specialist_id = OLD.id;
		DELETE FROM specialist_documents WHERE specialist_id = OLD.id;
		DELETE FROM attachments WHERE (ref->'keys'->>'id')::int = OLD.id AND ref->>'dataType' = 'specialists';
		DELETE FROM entity_contacts WHERE entity_id = OLD.id AND entity_type = 'specialists';
		DELETE FROM entity_contacts WHERE entity_id = OLD.user_id AND entity_type = 'users';
		DELETE FROM ycl_transactions WHERE specialist_id = OLD.id;
			
		RETURN OLD;
		
	ELSIF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		DELETE FROM users WHERE id = OLD.user_id;
		RETURN OLD;
		
	ELSIF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN	
		SELECT ycl_staff.data->>'specialization' INTO v_spec FROM ycl_staff WHERE ycl_staff.id = NEW.ycl_staff_id;
		SELECT
			spt.id,
			spt.agent_percent
		INTO
			NEW.speciality_id,
			NEW.agent_percent
		FROM specialities AS spt
		WHERE spt.name = trim(v_spec);
		
		IF NEW.speciality_id IS NULL THEN
			RAISE EXCEPTION 'Не найдена специальность: %', v_spec;
		END IF;
		
		RETURN NEW;
		
	ELSIF TG_WHEN='AFTER' AND TG_OP='INSERT' THEN	
		UPDATE ycl_transactions SET amount=amount
		WHERE
			staff_id = NEW.ycl_staff_id
			AND specialist_id IS NULL;
					
		RETURN NEW;
	END IF;
END;
$$;


ALTER FUNCTION public.specialists_process() OWNER TO nails;

--
-- Name: specialists; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialists (
    id integer NOT NULL,
    name text NOT NULL,
    inn character varying(12) NOT NULL,
    bank_bik character varying(9),
    bank_acc character varying(20),
    studio_id integer NOT NULL,
    birthdate date,
    address_reg text,
    passport jsonb,
    user_id integer NOT NULL,
    equipments jsonb,
    ycl_staff_id integer,
    agent_percent numeric(15,2),
    speciality_id integer
);


ALTER TABLE public.specialists OWNER TO nails;

--
-- Name: specialists_ref(public.specialists); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialists_ref(public.specialists) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','specialists'
	);
$_$;


ALTER FUNCTION public.specialists_ref(public.specialists) OWNER TO nails;

--
-- Name: specialites_ref(public.posts); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialites_ref(public.posts) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','specialites'
	);
$_$;


ALTER FUNCTION public.specialites_ref(public.posts) OWNER TO nails;

--
-- Name: specialities; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialities (
    id integer NOT NULL,
    name text NOT NULL,
    equipments jsonb,
    agent_percent numeric(15,2)
);


ALTER TABLE public.specialities OWNER TO nails;

--
-- Name: specialities_ref(public.specialities); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.specialities_ref(public.specialities) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','specialities'
	);
$_$;


ALTER FUNCTION public.specialities_ref(public.specialities) OWNER TO nails;

--
-- Name: studios; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.studios (
    id integer NOT NULL,
    name text NOT NULL,
    firm_id integer NOT NULL,
    equipments jsonb,
    hour_rent_price numeric(15,2) DEFAULT 0
);


ALTER TABLE public.studios OWNER TO nails;

--
-- Name: studios_ref(public.studios); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.studios_ref(public.studios) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','studios'
	);
$_$;


ALTER FUNCTION public.studios_ref(public.studios) OWNER TO nails;

--
-- Name: template_batches; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.template_batches (
    id integer NOT NULL,
    name text,
    template_batch_type public.template_batch_types,
    studio_id integer
);


ALTER TABLE public.template_batches OWNER TO nails;

--
-- Name: template_batchs_ref(public.template_batches); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.template_batchs_ref(public.template_batches) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			    
			),	
		'descr',$1.name,
		'dataType','template_batches'
	);
$_$;


ALTER FUNCTION public.template_batchs_ref(public.template_batches) OWNER TO nails;

--
-- Name: templates_text(public.template_value[], text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.templates_text(public.template_value[], text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
   v_value template_value;
   v_text text;
BEGIN
	v_text = $2;
	FOREACH v_value IN ARRAY $1
	LOOP
		v_text = replace(v_text,
				'['||v_value.field||']',
				COALESCE(v_value.value,'')
		);
	END LOOP;
	
	RETURN v_text;
END
$_$;


ALTER FUNCTION public.templates_text(public.template_value[], text) OWNER TO nails;

--
-- Name: time_zone_locales; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.time_zone_locales (
    id integer NOT NULL,
    descr character varying(100) NOT NULL,
    name character varying(50) NOT NULL,
    hour_dif numeric(5,1) NOT NULL
);


ALTER TABLE public.time_zone_locales OWNER TO nails;

--
-- Name: time_zone_locales_ref(public.time_zone_locales); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.time_zone_locales_ref(public.time_zone_locales) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.descr,
		'dataType','time_zone_locales'
	);
$_$;


ALTER FUNCTION public.time_zone_locales_ref(public.time_zone_locales) OWNER TO nails;

--
-- Name: user_operations_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.user_operations_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF TG_OP='UPDATE' AND (
		 (coalesce(OLD.status,'')<>'end' AND coalesce(NEW.status,'')='end')
		 OR NEW.status='progress'
	)
	THEN		
		--md5(NEW.user_id::text||
		PERFORM pg_notify(
			'UserOperation.'||NEW.operation_id
			,json_build_object(
				'params',json_build_object(
					'status', NEW.status,
					'res', coalesce(NEW.error_text,'')='',
					'operation_id', NEW.operation_id
				)
			)::text
		);
	END IF;
	
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_operations_process() OWNER TO nails;

--
-- Name: users; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    name_full text,
    role_id public.role_types NOT NULL,
    pwd character varying(32),
    create_dt timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    banned boolean DEFAULT false,
    time_zone_locale_id integer,
    locale_id public.locales
);


ALTER TABLE public.users OWNER TO nails;

--
-- Name: users_ref(public.users); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.users_ref(public.users) RETURNS json
    LANGUAGE sql
    AS $_$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr', coalesce($1.name_full, $1.name::text),
		'dataType','users'
	);
$_$;


ALTER FUNCTION public.users_ref(public.users) OWNER TO nails;

--
-- Name: wa_docs_for_sign(integer); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.wa_docs_for_sign(in_specialist_id integer) RETURNS TABLE(tel text, body text)
    LANGUAGE sql
    AS $$
	WITH
	tmpl AS (SELECT
			t.template AS v
		FROM notif_templates t
		WHERE t.notif_type = 'docs_for_sign'::notif_types AND t.notif_provider = 'wa'
		LIMIT 1
	)	
	SELECT
		'7'||sp.tel AS tel,
		coalesce(templates_text(
			ARRAY[
				ROW('name', sp.name)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body
	FROM specialists_dialog AS sp
	WHERE sp.id = in_specialist_id
	;
$$;


ALTER FUNCTION public.wa_docs_for_sign(in_specialist_id integer) OWNER TO nails;

--
-- Name: wa_new_account(integer, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.wa_new_account(in_specialist_id integer, in_pwd text) RETURNS TABLE(tel text, body text)
    LANGUAGE sql
    AS $$
	WITH
	tmpl AS (SELECT
			t.template AS v
		FROM notif_templates t
		WHERE t.notif_type = 'new_account'::notif_types AND t.notif_provider = 'wa'
		LIMIT 1
	)	
	SELECT
		'7'||sp.tel AS tel,
		coalesce(templates_text(
			ARRAY[
				ROW('name', sp.name)::template_value,
				ROW('pwd', in_pwd)::template_value,
				ROW('login', '7'||u.name)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body
	FROM specialists_dialog AS sp
	LEFT JOIN users AS u ON u.id = (sp.users_ref->'keys'->>'id')::int
	WHERE sp.id = in_specialist_id
	;
$$;


ALTER FUNCTION public.wa_new_account(in_specialist_id integer, in_pwd text) OWNER TO nails;

--
-- Name: wa_new_specialist(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.wa_new_specialist() RETURNS TABLE(tel text, body text)
    LANGUAGE sql
    AS $$
	WITH
	tmpl AS (SELECT
			t.template AS v
		FROM notif_templates t
		WHERE t.notif_type = 'new_specialist'::notif_types AND t.notif_provider = 'wa'
		LIMIT 1
	)	
	SELECT
		'7'||ct.tel AS tel,
		coalesce(templates_text(
			ARRAY[
				ROW('name', u.name_full)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body
	FROM users AS u
	LEFT JOIN entity_contacts AS e_ct ON e_ct.entity_type = 'users' AND e_ct.entity_id = u.id
	LEFT JOIN contacts AS ct ON ct.id = e_ct.contact_id
	WHERE u.role_id = 'admin' AND coalesce(ct.tel, '') <>''
	;
$$;


ALTER FUNCTION public.wa_new_specialist() OWNER TO nails;

--
-- Name: wa_tel_check(text, text); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.wa_tel_check(in_tel text, in_key text) RETURNS TABLE(tel text, body text)
    LANGUAGE sql
    AS $$
	WITH
	tmpl AS (SELECT
			t.template AS v
		FROM notif_templates t
		WHERE t.notif_type = 'tel_check'::notif_types AND t.notif_provider = 'wa'
		LIMIT 1
	)	
	SELECT
		in_tel AS tel,
		coalesce(templates_text(
			ARRAY[
				ROW('key', in_key)::template_value
			],
			(SELECT v FROM tmpl)
		), '') AS body
	;
$$;


ALTER FUNCTION public.wa_tel_check(in_tel text, in_key text) OWNER TO nails;

--
-- Name: ycl_staff_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.ycl_staff_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' OR TG_OP='UPDATE' THEN
		IF NEW.data IS NOT NULL AND  coalesce(NEW.data->>'id', '')<> '' THEN
			NEW.id = (NEW.data->>'id')::int;
		END IF;
		
		IF NEW.data IS NOT NULL AND  coalesce(NEW.data->>'name', '')<> '' THEN
			NEW.name = NEW.data->>'name';
			
		ELSIF TG_OP='INSERT' THEN
			NEW.name = '<>';
		END IF;
		
		RETURN NEW;
		
	END IF;
END;
$$;


ALTER FUNCTION public.ycl_staff_process() OWNER TO nails;

--
-- Name: ycl_transactions_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.ycl_transactions_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
		BEGIN
			NEW.date = (NEW.data->>'date')::timestamp;
			NEW.amount = (NEW.data->>'amount')::numeric(15,2);
			NEW.seance_length = coalesce(NEW.data->'record'->>'seance_length', '0')::int;
			NEW.document_id = (NEW.data->>'document_id')::int;
			NEW.record_id = (NEW.data->>'record_id')::int;
			NEW.staff_id = (NEW.data->'record'->>'staff_id')::int;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
		
	
		SELECT
			sp.id
		INTO
			NEW.specialist_id
		FROM specialists AS sp
		WHERE sp.ycl_staff_id = NEW.staff_id
		;
		
		RETURN NEW;
		
	END IF;
END;
$$;


ALTER FUNCTION public.ycl_transactions_process() OWNER TO nails;

--
-- Name: ycl_visits_process(); Type: FUNCTION; Schema: public; Owner: nails
--

CREATE FUNCTION public.ycl_visits_process() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
		SELECT
			(SELECT sp.id
			FROM specialists AS sp
			WHERE sp.ycl_staff_id = (s.rec->>'staff_id')::int)
		INTO
			NEW.specialist_id
		FROM
		(SELECT jsonb_array_elements(NEW.data->'records') AS rec LIMIT 1) AS s;
			
		RETURN NEW;
		
	END IF;
END;
$$;


ALTER FUNCTION public.ycl_visits_process() OWNER TO nails;

--
-- Name: banks_group_list; Type: FOREIGN TABLE; Schema: banks; Owner: nails
--

CREATE FOREIGN TABLE banks.banks_group_list (
    bik character varying(9),
    codegr character varying(9),
    name text,
    korshet character varying(20),
    adres text,
    gor text,
    tgroup boolean
)
SERVER ms
OPTIONS (
    schema_name 'banks',
    table_name 'banks_group_list'
);
ALTER FOREIGN TABLE ONLY banks.banks_group_list ALTER COLUMN bik OPTIONS (
    column_name 'bik'
);
ALTER FOREIGN TABLE ONLY banks.banks_group_list ALTER COLUMN codegr OPTIONS (
    column_name 'codegr'
);
ALTER FOREIGN TABLE ONLY banks.banks_group_list ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE ONLY banks.banks_group_list ALTER COLUMN korshet OPTIONS (
    column_name 'korshet'
);
ALTER FOREIGN TABLE ONLY banks.banks_group_list ALTER COLUMN adres OPTIONS (
    column_name 'adres'
);
ALTER FOREIGN TABLE ONLY banks.banks_group_list ALTER COLUMN gor OPTIONS (
    column_name 'gor'
);
ALTER FOREIGN TABLE ONLY banks.banks_group_list ALTER COLUMN tgroup OPTIONS (
    column_name 'tgroup'
);


ALTER FOREIGN TABLE banks.banks_group_list OWNER TO nails;

--
-- Name: banks_list; Type: FOREIGN TABLE; Schema: banks; Owner: nails
--

CREATE FOREIGN TABLE banks.banks_list (
    bik character varying(9),
    codegr character varying(9),
    name text,
    korshet character varying(20),
    adres text,
    gor text,
    tgroup boolean,
    gr_descr text
)
SERVER ms
OPTIONS (
    schema_name 'banks',
    table_name 'banks_list'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN bik OPTIONS (
    column_name 'bik'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN codegr OPTIONS (
    column_name 'codegr'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN korshet OPTIONS (
    column_name 'korshet'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN adres OPTIONS (
    column_name 'adres'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN gor OPTIONS (
    column_name 'gor'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN tgroup OPTIONS (
    column_name 'tgroup'
);
ALTER FOREIGN TABLE ONLY banks.banks_list ALTER COLUMN gr_descr OPTIONS (
    column_name 'gr_descr'
);


ALTER FOREIGN TABLE banks.banks_list OWNER TO nails;

--
-- Name: dadata_cache; Type: FOREIGN TABLE; Schema: client_search; Owner: nails
--

CREATE FOREIGN TABLE client_search.dadata_cache (
    query text NOT NULL,
    response json
)
SERVER ms
OPTIONS (
    schema_name 'client_search',
    table_name 'dadata_cache'
);
ALTER FOREIGN TABLE ONLY client_search.dadata_cache ALTER COLUMN query OPTIONS (
    column_name 'query'
);
ALTER FOREIGN TABLE ONLY client_search.dadata_cache ALTER COLUMN response OPTIONS (
    column_name 'response'
);


ALTER FOREIGN TABLE client_search.dadata_cache OWNER TO nails;

--
-- Name: a1; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.a1 (
    id integer
);


ALTER TABLE public.a1 OWNER TO nails;

--
-- Name: a2; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.a2 (
    id integer
);


ALTER TABLE public.a2 OWNER TO nails;

--
-- Name: apps; Type: FOREIGN TABLE; Schema: public; Owner: nails
--

CREATE FOREIGN TABLE public.apps (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    comment_text text,
    tm_params jsonb,
    smtp_auth json,
    smsfeedback_params jsonb,
    mail_params jsonb,
    wa_qrcode bytea,
    provider_params jsonb,
    callback_url text,
    callback_key text,
    pwd character varying(32)
)
SERVER ms
OPTIONS (
    schema_name 'public',
    table_name 'apps'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN comment_text OPTIONS (
    column_name 'comment_text'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN tm_params OPTIONS (
    column_name 'tm_params'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN smtp_auth OPTIONS (
    column_name 'smtp_auth'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN smsfeedback_params OPTIONS (
    column_name 'smsfeedback_params'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN mail_params OPTIONS (
    column_name 'mail_params'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN wa_qrcode OPTIONS (
    column_name 'wa_qrcode'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN provider_params OPTIONS (
    column_name 'provider_params'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN callback_url OPTIONS (
    column_name 'callback_url'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN callback_key OPTIONS (
    column_name 'callback_key'
);
ALTER FOREIGN TABLE ONLY public.apps ALTER COLUMN pwd OPTIONS (
    column_name 'pwd'
);


ALTER FOREIGN TABLE public.apps OWNER TO nails;

--
-- Name: attachments; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.attachments (
    id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ref jsonb,
    content_info jsonb,
    content_data bytea,
    content_preview bytea
);


ALTER TABLE public.attachments OWNER TO nails;

--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attachments_id_seq OWNER TO nails;

--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: attachments_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.attachments_list AS
 SELECT t.id,
    t.date_time,
    t.ref,
    t.content_info,
    encode(t.content_preview, 'base64'::text) AS content_preview
   FROM public.attachments t
  ORDER BY t.date_time DESC;


ALTER VIEW public.attachments_list OWNER TO nails;

--
-- Name: bank_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.bank_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bank_payments_id_seq OWNER TO nails;

--
-- Name: bank_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.bank_payments_id_seq OWNED BY public.bank_payments.id;


--
-- Name: bank_payments_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.bank_payments_list AS
 SELECT t.id,
    t.date_time,
    t.document_date,
    t.document_num,
    t.document_total,
    t.document_comment,
    t.payer_acc,
    t.payer_bank_acc,
    t.payer_bank_bik,
    t.payer_bank,
    t.payer_bank_place,
    t.rec_acc,
    t.rec_bank_acc,
    t.rec_bank_bik,
    t.rec_bank,
    t.rec_bank_place,
    t.specialist_id,
    public.specialists_ref(specialists_ref_t.*) AS specialists_ref,
    t.specialist_period_salary_detail_id,
    public.specialist_period_salary_details_ref(specialist_period_salary_details_ref_t.*) AS specialist_period_salary_details_ref
   FROM ((public.bank_payments t
     LEFT JOIN public.specialists specialists_ref_t ON ((specialists_ref_t.id = t.specialist_id)))
     LEFT JOIN public.specialist_period_salary_details specialist_period_salary_details_ref_t ON ((specialist_period_salary_details_ref_t.id = t.specialist_period_salary_detail_id)))
  ORDER BY t.document_num DESC;


ALTER VIEW public.bank_payments_list OWNER TO nails;

--
-- Name: confirmation_status; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.confirmation_status (
    id integer NOT NULL,
    ref jsonb NOT NULL,
    field character varying(50) NOT NULL,
    secret text NOT NULL,
    confirmed boolean DEFAULT false NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    try_date_time timestamp with time zone,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.confirmation_status OWNER TO nails;

--
-- Name: confirmation_status_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.confirmation_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.confirmation_status_id_seq OWNER TO nails;

--
-- Name: confirmation_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.confirmation_status_id_seq OWNED BY public.confirmation_status.id;


--
-- Name: const_doc_per_page_count; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.const_doc_per_page_count (
    name text NOT NULL,
    descr text,
    val integer,
    val_type text,
    ctrl_class text,
    ctrl_options json,
    view_class text,
    view_options json
);


ALTER TABLE public.const_doc_per_page_count OWNER TO nails;

--
-- Name: const_doc_per_page_count_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.const_doc_per_page_count_view AS
 SELECT 'doc_per_page_count'::text AS id,
    t.name,
    t.descr,
    (t.val)::text AS val,
    t.val_type,
    t.ctrl_class,
    t.ctrl_options,
    t.view_class,
    t.view_options
   FROM public.const_doc_per_page_count t;


ALTER VIEW public.const_doc_per_page_count_view OWNER TO nails;

--
-- Name: const_email; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.const_email (
    name text NOT NULL,
    descr text,
    val jsonb,
    val_type text,
    ctrl_class text,
    ctrl_options json,
    view_class text,
    view_options json
);


ALTER TABLE public.const_email OWNER TO nails;

--
-- Name: const_email_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.const_email_view AS
 SELECT 'email'::text AS id,
    t.name,
    t.descr,
    (t.val)::text AS val,
    t.val_type,
    t.ctrl_class,
    t.ctrl_options,
    t.view_class,
    t.view_options
   FROM public.const_email t;


ALTER VIEW public.const_email_view OWNER TO nails;

--
-- Name: const_grid_refresh_interval; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.const_grid_refresh_interval (
    name text NOT NULL,
    descr text,
    val integer,
    val_type text,
    ctrl_class text,
    ctrl_options json,
    view_class text,
    view_options json
);


ALTER TABLE public.const_grid_refresh_interval OWNER TO nails;

--
-- Name: const_grid_refresh_interval_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.const_grid_refresh_interval_view AS
 SELECT 'grid_refresh_interval'::text AS id,
    t.name,
    t.descr,
    (t.val)::text AS val,
    t.val_type,
    t.ctrl_class,
    t.ctrl_options,
    t.view_class,
    t.view_options
   FROM public.const_grid_refresh_interval t;


ALTER VIEW public.const_grid_refresh_interval_view OWNER TO nails;

--
-- Name: const_join_contract; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.const_join_contract (
    name text NOT NULL,
    descr text,
    val text,
    val_type text,
    ctrl_class text,
    ctrl_options json,
    view_class text,
    view_options json
);


ALTER TABLE public.const_join_contract OWNER TO nails;

--
-- Name: const_join_contract_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.const_join_contract_view AS
 SELECT 'join_contract'::text AS id,
    t.name,
    t.descr,
    t.val,
    t.val_type,
    t.ctrl_class,
    t.ctrl_options,
    t.view_class,
    t.view_options
   FROM public.const_join_contract t;


ALTER VIEW public.const_join_contract_view OWNER TO nails;

--
-- Name: const_person_tax; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.const_person_tax (
    name text NOT NULL,
    descr text,
    val integer,
    val_type text,
    ctrl_class text,
    ctrl_options json,
    view_class text,
    view_options json
);


ALTER TABLE public.const_person_tax OWNER TO nails;

--
-- Name: const_person_tax_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.const_person_tax_view AS
 SELECT 'person_tax'::text AS id,
    t.name,
    t.descr,
    (t.val)::text AS val,
    t.val_type,
    t.ctrl_class,
    t.ctrl_options,
    t.view_class,
    t.view_options
   FROM public.const_person_tax t;


ALTER VIEW public.const_person_tax_view OWNER TO nails;

--
-- Name: const_specialist_pay_comment_template; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.const_specialist_pay_comment_template (
    name text NOT NULL,
    descr text,
    val text,
    val_type text,
    ctrl_class text,
    ctrl_options json,
    view_class text,
    view_options json
);


ALTER TABLE public.const_specialist_pay_comment_template OWNER TO nails;

--
-- Name: const_specialist_pay_comment_template_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.const_specialist_pay_comment_template_view AS
 SELECT 'specialist_pay_comment_template'::text AS id,
    t.name,
    t.descr,
    t.val,
    t.val_type,
    t.ctrl_class,
    t.ctrl_options,
    t.view_class,
    t.view_options
   FROM public.const_specialist_pay_comment_template t;


ALTER VIEW public.const_specialist_pay_comment_template_view OWNER TO nails;

--
-- Name: const_specialist_services; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.const_specialist_services (
    name text NOT NULL,
    descr text,
    val text,
    val_type text,
    ctrl_class text,
    ctrl_options json,
    view_class text,
    view_options json
);


ALTER TABLE public.const_specialist_services OWNER TO nails;

--
-- Name: const_specialist_services_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.const_specialist_services_view AS
 SELECT 'specialist_services'::text AS id,
    t.name,
    t.descr,
    t.val,
    t.val_type,
    t.ctrl_class,
    t.ctrl_options,
    t.view_class,
    t.view_options
   FROM public.const_specialist_services t;


ALTER VIEW public.const_specialist_services_view OWNER TO nails;

--
-- Name: constants_list_view; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.constants_list_view AS
 SELECT const_doc_per_page_count_view.id,
    const_doc_per_page_count_view.name,
    const_doc_per_page_count_view.descr,
    const_doc_per_page_count_view.val,
    const_doc_per_page_count_view.val_type,
    const_doc_per_page_count_view.ctrl_class,
    const_doc_per_page_count_view.ctrl_options,
    const_doc_per_page_count_view.view_class,
    const_doc_per_page_count_view.view_options
   FROM public.const_doc_per_page_count_view
UNION ALL
 SELECT const_grid_refresh_interval_view.id,
    const_grid_refresh_interval_view.name,
    const_grid_refresh_interval_view.descr,
    const_grid_refresh_interval_view.val,
    const_grid_refresh_interval_view.val_type,
    const_grid_refresh_interval_view.ctrl_class,
    const_grid_refresh_interval_view.ctrl_options,
    const_grid_refresh_interval_view.view_class,
    const_grid_refresh_interval_view.view_options
   FROM public.const_grid_refresh_interval_view
UNION ALL
 SELECT const_email_view.id,
    const_email_view.name,
    const_email_view.descr,
    const_email_view.val,
    const_email_view.val_type,
    const_email_view.ctrl_class,
    const_email_view.ctrl_options,
    const_email_view.view_class,
    const_email_view.view_options
   FROM public.const_email_view
UNION ALL
 SELECT const_join_contract_view.id,
    const_join_contract_view.name,
    const_join_contract_view.descr,
    const_join_contract_view.val,
    const_join_contract_view.val_type,
    const_join_contract_view.ctrl_class,
    const_join_contract_view.ctrl_options,
    const_join_contract_view.view_class,
    const_join_contract_view.view_options
   FROM public.const_join_contract_view
UNION ALL
 SELECT const_person_tax_view.id,
    const_person_tax_view.name,
    const_person_tax_view.descr,
    const_person_tax_view.val,
    const_person_tax_view.val_type,
    const_person_tax_view.ctrl_class,
    const_person_tax_view.ctrl_options,
    const_person_tax_view.view_class,
    const_person_tax_view.view_options
   FROM public.const_person_tax_view
UNION ALL
 SELECT const_specialist_services_view.id,
    const_specialist_services_view.name,
    const_specialist_services_view.descr,
    const_specialist_services_view.val,
    const_specialist_services_view.val_type,
    const_specialist_services_view.ctrl_class,
    const_specialist_services_view.ctrl_options,
    const_specialist_services_view.view_class,
    const_specialist_services_view.view_options
   FROM public.const_specialist_services_view
UNION ALL
 SELECT const_specialist_pay_comment_template_view.id,
    const_specialist_pay_comment_template_view.name,
    const_specialist_pay_comment_template_view.descr,
    const_specialist_pay_comment_template_view.val,
    const_specialist_pay_comment_template_view.val_type,
    const_specialist_pay_comment_template_view.ctrl_class,
    const_specialist_pay_comment_template_view.ctrl_options,
    const_specialist_pay_comment_template_view.view_class,
    const_specialist_pay_comment_template_view.view_options
   FROM public.const_specialist_pay_comment_template_view
  ORDER BY 2;


ALTER VIEW public.constants_list_view OWNER TO nails;

--
-- Name: contacts_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.contacts_dialog AS
 SELECT ct.id,
    ct.name,
    public.posts_ref(p.*) AS posts_ref,
    ct.email,
    ct.tel,
    ct.descr,
    ct.tel_ext,
    ct.comment_text,
    ct.email_confirmed,
    ct.tel_confirmed
   FROM (public.contacts ct
     LEFT JOIN public.posts p ON ((p.id = ct.post_id)))
  ORDER BY ct.name;


ALTER VIEW public.contacts_dialog OWNER TO nails;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO nails;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: contacts_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.contacts_list AS
 SELECT ct.id,
    ct.name,
    public.posts_ref(p.*) AS posts_ref,
    ct.email,
    ct.tel,
    ct.descr,
    ct.tel_ext,
    ct.comment_text
   FROM (public.contacts ct
     LEFT JOIN public.posts p ON ((p.id = ct.post_id)))
  ORDER BY ct.name;


ALTER VIEW public.contacts_list OWNER TO nails;

--
-- Name: document_templates_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.document_templates_dialog AS
 SELECT t.id,
    t.name,
    t.fields,
    t.sql_query,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text))) AS file_preview,
    t.need_signing,
    t.sign_image_name
   FROM (public.document_templates t
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'document_templates'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id))));


ALTER VIEW public.document_templates_dialog OWNER TO nails;

--
-- Name: document_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.document_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_templates_id_seq OWNER TO nails;

--
-- Name: document_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.document_templates_id_seq OWNED BY public.document_templates.id;


--
-- Name: document_templates_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.document_templates_list AS
 SELECT t.id,
    t.name,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text))) AS file_preview,
    t.need_signing
   FROM (public.document_templates t
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'document_templates'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id))))
  ORDER BY t.name;


ALTER VIEW public.document_templates_list OWNER TO nails;

--
-- Name: entity_contacts; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.entity_contacts (
    id integer NOT NULL,
    entity_type public.data_types NOT NULL,
    entity_id integer NOT NULL,
    contact_id integer NOT NULL,
    mod_date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.entity_contacts OWNER TO nails;

--
-- Name: entity_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.entity_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entity_contacts_id_seq OWNER TO nails;

--
-- Name: entity_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.entity_contacts_id_seq OWNED BY public.entity_contacts.id;


--
-- Name: entity_contacts_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.entity_contacts_list AS
 SELECT e_ct.id,
    e_ct.entity_type,
    e_ct.entity_id,
        CASE
            WHEN (e_ct.entity_type = 'users'::public.data_types) THEN public.users_ref(u.*)
            ELSE NULL::json
        END AS entities_ref,
    e_ct.contact_id,
    public.contacts_ref(ct.*) AS contacts_ref,
    json_build_object('name', ct.name, 'tel', ct.tel, 'email', ct.email, 'tel_ext', ct.tel_ext, 'post', p.name) AS contact_attrs,
    false AS tm_exists,
    false AS tm_activated
   FROM (((public.entity_contacts e_ct
     LEFT JOIN public.users u ON (((e_ct.entity_type = 'users'::public.data_types) AND (u.id = e_ct.entity_id))))
     LEFT JOIN public.contacts ct ON ((ct.id = e_ct.contact_id)))
     LEFT JOIN public.posts p ON ((p.id = ct.post_id)))
  ORDER BY e_ct.entity_type,
        CASE
            WHEN (e_ct.entity_type = 'users'::public.data_types) THEN (public.users_ref(u.*) ->> 'descr'::text)
            ELSE NULL::text
        END;


ALTER VIEW public.entity_contacts_list OWNER TO nails;

--
-- Name: equipment_types; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.equipment_types (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.equipment_types OWNER TO nails;

--
-- Name: equipment_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.equipment_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_types_id_seq OWNER TO nails;

--
-- Name: equipment_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.equipment_types_id_seq OWNED BY public.equipment_types.id;


--
-- Name: firms_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.firms_dialog AS
 SELECT t.id,
    t.name,
    t.inn,
    t.name_full,
    t.legal_address,
    t.post_address,
    t.kpp,
    t.ogrn,
    t.okpo,
    t.okved,
    t.bank_acc,
    banks.banks_ref(bnk.*) AS banks_ref
   FROM (public.firms t
     LEFT JOIN banks.banks bnk ON (((bnk.bik)::text = (t.bank_bik)::text)));


ALTER VIEW public.firms_dialog OWNER TO nails;

--
-- Name: firms_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.firms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.firms_id_seq OWNER TO nails;

--
-- Name: firms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.firms_id_seq OWNED BY public.firms.id;


--
-- Name: firms_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.firms_list AS
 SELECT t.id,
    t.name,
    t.inn,
    t.ogrn
   FROM public.firms t
  ORDER BY t.name;


ALTER VIEW public.firms_list OWNER TO nails;

--
-- Name: items; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name text NOT NULL,
    comment_text text,
    price numeric(15,2)
);


ALTER TABLE public.items OWNER TO nails;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.items_id_seq OWNER TO nails;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: logger; Type: FOREIGN TABLE; Schema: public; Owner: nails
--

CREATE FOREIGN TABLE public.logger (
    id integer NOT NULL,
    date_time timestamp without time zone NOT NULL,
    app_id integer NOT NULL,
    message text,
    level integer,
    section text,
    cnt integer
)
SERVER ms
OPTIONS (
    schema_name 'public',
    table_name 'logger'
);
ALTER FOREIGN TABLE ONLY public.logger ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE ONLY public.logger ALTER COLUMN date_time OPTIONS (
    column_name 'date_time'
);
ALTER FOREIGN TABLE ONLY public.logger ALTER COLUMN app_id OPTIONS (
    column_name 'app_id'
);
ALTER FOREIGN TABLE ONLY public.logger ALTER COLUMN message OPTIONS (
    column_name 'message'
);
ALTER FOREIGN TABLE ONLY public.logger ALTER COLUMN level OPTIONS (
    column_name 'level'
);
ALTER FOREIGN TABLE ONLY public.logger ALTER COLUMN section OPTIONS (
    column_name 'section'
);
ALTER FOREIGN TABLE ONLY public.logger ALTER COLUMN cnt OPTIONS (
    column_name 'cnt'
);


ALTER FOREIGN TABLE public.logger OWNER TO nails;

--
-- Name: login_device_bans; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.login_device_bans (
    user_id integer NOT NULL,
    hash character varying(32) NOT NULL,
    create_dt timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.login_device_bans OWNER TO nails;

--
-- Name: logins; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.logins (
    id integer NOT NULL,
    date_time_in timestamp with time zone,
    date_time_out timestamp with time zone,
    ip character varying(15),
    session_id character varying(128),
    user_id integer,
    pub_key character varying(15),
    set_date_time timestamp with time zone,
    headers jsonb,
    user_agent jsonb
);


ALTER TABLE public.logins OWNER TO nails;

--
-- Name: login_devices_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.login_devices_list AS
 SELECT t.user_id,
    u.name AS user_descr,
    max(t.date_time_in) AS date_time_in,
    public.login_devices_uniq(t.user_agent) AS user_agent,
        CASE
            WHEN (bn.user_id IS NULL) THEN false
            ELSE true
        END AS banned,
    md5(public.login_devices_uniq(t.user_agent)) AS ban_hash
   FROM ((public.logins t
     LEFT JOIN public.users u ON ((u.id = t.user_id)))
     LEFT JOIN public.login_device_bans bn ON (((bn.user_id = u.id) AND ((bn.hash)::text = md5(public.login_devices_uniq(t.user_agent))))))
  WHERE (public.login_devices_uniq(t.user_agent) IS NOT NULL)
  GROUP BY t.user_id, (public.login_devices_uniq(t.user_agent)), u.name, bn.user_id
  ORDER BY (max(t.date_time_in)) DESC;


ALTER VIEW public.login_devices_list OWNER TO nails;

--
-- Name: logins_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.logins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.logins_id_seq OWNER TO nails;

--
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.logins_id_seq OWNED BY public.logins.id;


--
-- Name: logins_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.logins_list AS
 SELECT t.id,
    t.date_time_in,
    t.date_time_out,
    t.ip,
    t.user_id,
    public.users_ref(u.*) AS users_ref,
    t.pub_key,
    t.set_date_time,
    public.logins_user_agent_descr(t.user_agent) AS user_agent_descr,
    t.user_agent,
    t.headers
   FROM (public.logins t
     LEFT JOIN public.users u ON ((u.id = t.user_id)))
  ORDER BY t.date_time_in DESC;


ALTER VIEW public.logins_list OWNER TO nails;

--
-- Name: mail_senders; Type: FOREIGN TABLE; Schema: public; Owner: nails
--

CREATE FOREIGN TABLE public.mail_senders (
    id integer NOT NULL,
    app_id integer,
    host text,
    user_name text,
    pwd text,
    from_addr text,
    from_name text,
    sender_addr text,
    sender_name text,
    reply_name text,
    reply_addr text
)
SERVER ms
OPTIONS (
    schema_name 'public',
    table_name 'mail_senders'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN app_id OPTIONS (
    column_name 'app_id'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN host OPTIONS (
    column_name 'host'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN user_name OPTIONS (
    column_name 'user_name'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN pwd OPTIONS (
    column_name 'pwd'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN from_addr OPTIONS (
    column_name 'from_addr'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN from_name OPTIONS (
    column_name 'from_name'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN sender_addr OPTIONS (
    column_name 'sender_addr'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN sender_name OPTIONS (
    column_name 'sender_name'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN reply_name OPTIONS (
    column_name 'reply_name'
);
ALTER FOREIGN TABLE ONLY public.mail_senders ALTER COLUMN reply_addr OPTIONS (
    column_name 'reply_addr'
);


ALTER FOREIGN TABLE public.mail_senders OWNER TO nails;

--
-- Name: main_menus; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.main_menus (
    id integer NOT NULL,
    role_id public.role_types NOT NULL,
    user_id integer,
    content text NOT NULL,
    model_content text
);


ALTER TABLE public.main_menus OWNER TO nails;

--
-- Name: main_menus_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.main_menus_dialog AS
 SELECT m.id,
    m.role_id,
    m.user_id,
    u.name AS user_descr,
    m.content
   FROM (public.main_menus m
     LEFT JOIN public.users u ON ((u.id = m.user_id)))
  ORDER BY m.role_id, u.name;


ALTER VIEW public.main_menus_dialog OWNER TO nails;

--
-- Name: main_menus_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.main_menus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.main_menus_id_seq OWNER TO nails;

--
-- Name: main_menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.main_menus_id_seq OWNED BY public.main_menus.id;


--
-- Name: main_menus_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.main_menus_list AS
 SELECT m.id,
    m.role_id,
    m.user_id,
    u.name AS user_descr
   FROM (public.main_menus m
     LEFT JOIN public.users u ON ((u.id = m.user_id)))
  ORDER BY m.role_id, u.name;


ALTER VIEW public.main_menus_list OWNER TO nails;

--
-- Name: notif_templates; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.notif_templates (
    id integer NOT NULL,
    notif_provider public.notif_providers NOT NULL,
    notif_type public.notif_types NOT NULL,
    template text NOT NULL,
    comment_text text NOT NULL,
    fields json NOT NULL,
    provider_values json
);


ALTER TABLE public.notif_templates OWNER TO nails;

--
-- Name: notif_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.notif_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notif_templates_id_seq OWNER TO nails;

--
-- Name: notif_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.notif_templates_id_seq OWNED BY public.notif_templates.id;


--
-- Name: notif_templates_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.notif_templates_list AS
 SELECT t.id,
    t.notif_provider,
    t.notif_type,
    t.template
   FROM public.notif_templates t
  ORDER BY t.notif_provider, t.notif_type;


ALTER VIEW public.notif_templates_list OWNER TO nails;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.permissions (
    rules json NOT NULL
);


ALTER TABLE public.permissions OWNER TO nails;

--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.posts_id_seq OWNER TO nails;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: salary_debets_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.salary_debets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salary_debets_id_seq OWNER TO nails;

--
-- Name: salary_debets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.salary_debets_id_seq OWNED BY public.salary_debets.id;


--
-- Name: salary_kredits_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.salary_kredits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salary_kredits_id_seq OWNER TO nails;

--
-- Name: salary_kredits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.salary_kredits_id_seq OWNED BY public.salary_kredits.id;


--
-- Name: session_vals; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.session_vals (
    id character(36) NOT NULL,
    accessed_time timestamp with time zone DEFAULT now(),
    create_time timestamp with time zone DEFAULT now(),
    val bytea
);


ALTER TABLE public.session_vals OWNER TO nails;

--
-- Name: specialist_documents; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_documents (
    id integer NOT NULL,
    specialist_id integer NOT NULL,
    template_att_id integer NOT NULL,
    document_att_id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sign_date_time timestamp with time zone,
    open_date_time timestamp with time zone,
    need_signing boolean,
    sign_img bytea,
    name text,
    document_template_id integer NOT NULL
);


ALTER TABLE public.specialist_documents OWNER TO nails;

--
-- Name: specialist_documents_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_documents_list AS
 SELECT t.id,
    t.specialist_id,
    public.specialists_ref(specialists_ref_t.*) AS specialists_ref,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text))) AS document_att_ref,
    t.date_time,
    t.sign_date_time,
    (t.sign_date_time IS NOT NULL) AS signed,
    t.open_date_time,
    (t.open_date_time IS NOT NULL) AS opened,
    t.need_signing,
    t.name
   FROM ((public.specialist_documents t
     LEFT JOIN public.specialists specialists_ref_t ON ((specialists_ref_t.id = t.specialist_id)))
     LEFT JOIN public.attachments att ON ((att.id = t.document_att_id)))
  ORDER BY t.specialist_id, t.date_time DESC;


ALTER VIEW public.specialist_documents_list OWNER TO nails;

--
-- Name: specialist_documents_for_sign_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_documents_for_sign_list AS
 SELECT t.id,
    t.specialist_id,
    sp.user_id,
    t.specialists_ref,
    t.document_att_ref,
    t.date_time,
    t.opened,
    t.name
   FROM (public.specialist_documents_list t
     LEFT JOIN public.specialists sp ON ((sp.id = t.id)))
  WHERE (t.need_signing AND (t.sign_date_time IS NULL))
  ORDER BY t.date_time DESC;


ALTER VIEW public.specialist_documents_for_sign_list OWNER TO nails;

--
-- Name: specialist_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_documents_id_seq OWNER TO nails;

--
-- Name: specialist_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_documents_id_seq OWNED BY public.specialist_documents.id;


--
-- Name: specialist_documents_on_register; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_documents_on_register (
    id integer NOT NULL,
    document_template_id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    need_signing boolean
);


ALTER TABLE public.specialist_documents_on_register OWNER TO nails;

--
-- Name: specialist_documents_on_register_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_documents_on_register_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_documents_on_register_id_seq OWNER TO nails;

--
-- Name: specialist_documents_on_register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_documents_on_register_id_seq OWNED BY public.specialist_documents_on_register.id;


--
-- Name: specialist_documents_on_register_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_documents_on_register_list AS
 SELECT t.id,
    public.document_templates_ref(document_templates_ref_t.*) AS document_templates_ref,
    t.date_time,
    t.need_signing
   FROM (public.specialist_documents_on_register t
     LEFT JOIN public.document_templates document_templates_ref_t ON ((document_templates_ref_t.id = t.document_template_id)))
  ORDER BY document_templates_ref_t.name;


ALTER VIEW public.specialist_documents_on_register_list OWNER TO nails;

--
-- Name: specialist_period_salaries_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_period_salaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_period_salaries_id_seq OWNER TO nails;

--
-- Name: specialist_period_salaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_period_salaries_id_seq OWNED BY public.specialist_period_salaries.id;


--
-- Name: specialist_period_salaries_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_period_salaries_list AS
 SELECT t.id,
    t.date_time,
    t.period,
    public.month_period_rus(t.period) AS period_descr,
    t.studio_id,
    public.studios_ref(st.*) AS studios_ref,
    t.work_total,
    t.work_total_salary,
    t.hours,
    t.debet,
    t.kredit,
    t.rent_total,
    t.total
   FROM (public.specialist_period_salaries t
     LEFT JOIN public.studios st ON ((st.id = t.studio_id)))
  ORDER BY t.period DESC;


ALTER VIEW public.specialist_period_salaries_list OWNER TO nails;

--
-- Name: specialist_period_salary_details_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_period_salary_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_period_salary_details_id_seq OWNER TO nails;

--
-- Name: specialist_period_salary_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_period_salary_details_id_seq OWNED BY public.specialist_period_salary_details.id;


--
-- Name: specialist_receipts; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_receipts (
    id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_date_time timestamp with time zone,
    document_total numeric(15,2) DEFAULT 0,
    document_parsed boolean DEFAULT false,
    specialist_id integer NOT NULL,
    specialist_period_salary_detail_id integer NOT NULL,
    document_error text,
    qrextr_request_id text,
    operation_id character varying(36),
    document_href text
);


ALTER TABLE public.specialist_receipts OWNER TO nails;

--
-- Name: specialist_period_salary_details_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_period_salary_details_list AS
 SELECT t.id,
    t.specialist_period_salary_id,
    t.line_num,
    t.specialist_id,
    public.specialists_ref(specialists_ref_t.*) AS specialists_ref,
    t.studio_id,
    public.studios_ref(studios_ref_t.*) AS studios_ref,
    t.period,
    public.month_period_rus(t.period) AS period_descr,
    t.hours,
    t.agent_percent,
    t.work_total,
    t.work_total_salary,
    t.debet,
    t.kredit,
    t.rent_price,
    t.rent_total,
    t.total,
    COALESCE(rct.receipt_total, (0)::numeric) AS receipt_total,
    rct.receipt_error,
    rct.receipt_photos,
    COALESCE(rct.receipt_checked, false) AS receipt_checked,
    rct.receipt_href,
    public.bank_payments_ref(pp.*) AS bank_payments_ref,
    ((public.person_init(specialists_ref_t.name) || ' '::text) || public.month_period_rus(t.period)) AS descr
   FROM ((((public.specialist_period_salary_details t
     LEFT JOIN public.specialists specialists_ref_t ON ((specialists_ref_t.id = t.specialist_id)))
     LEFT JOIN public.studios studios_ref_t ON ((studios_ref_t.id = t.studio_id)))
     LEFT JOIN public.bank_payments pp ON ((pp.specialist_period_salary_detail_id = t.id)))
     LEFT JOIN ( SELECT t_1.specialist_period_salary_detail_id,
            sum(t_1.document_total) AS receipt_total,
            string_agg(t_1.document_error, ', '::text) AS receipt_error,
            string_agg(t_1.document_href, ', '::text) AS receipt_href,
            jsonb_agg((att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text), 'receipt_id', t_1.id))) AS receipt_photos,
            bool_and(t_1.document_parsed) AS receipt_checked
           FROM (public.specialist_receipts t_1
             LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'specialist_receipts'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t_1.id))))
          GROUP BY t_1.specialist_period_salary_detail_id) rct ON ((rct.specialist_period_salary_detail_id = t.id)))
  ORDER BY t.specialist_period_salary_id, t.line_num;


ALTER VIEW public.specialist_period_salary_details_list OWNER TO nails;

--
-- Name: specialist_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_receipts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_receipts_id_seq OWNER TO nails;

--
-- Name: specialist_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_receipts_id_seq OWNED BY public.specialist_receipts.id;


--
-- Name: specialist_regs; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_regs (
    id integer NOT NULL,
    user_operation_id character varying(36) NOT NULL,
    name text NOT NULL,
    inn character varying(12) NOT NULL,
    studio_id integer,
    birthdate date,
    address_reg text,
    passport json,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    inn_checked boolean DEFAULT false NOT NULL,
    inn_fns_ok boolean DEFAULT false NOT NULL,
    banks_ref jsonb,
    name_full text,
    tel character varying(11),
    email character varying(50),
    bank_acc character varying(20),
    email_sent boolean DEFAULT false,
    tel_sent boolean DEFAULT false,
    passport_uploaded boolean DEFAULT false
);


ALTER TABLE public.specialist_regs OWNER TO nails;

--
-- Name: user_operations; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.user_operations (
    user_id integer NOT NULL,
    operation_id character varying(36) NOT NULL,
    operation text,
    status text,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    error_text text,
    comment_text text,
    date_time_end timestamp with time zone,
    end_wal_lsn text
);


ALTER TABLE public.user_operations OWNER TO nails;

--
-- Name: specialist_regs_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_regs_dialog AS
 SELECT t.id,
    t.user_operation_id,
    t.inn,
    t.banks_ref,
    t.bank_acc,
    t.name_full,
    t.tel,
    t.email,
    t.address_reg,
    t.birthdate,
    t.name,
    t.passport,
    t.date_time,
    t.inn_checked,
    t.inn_fns_ok,
    ( SELECT st.confirmed
           FROM public.confirmation_status st
          WHERE (((((st.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id) AND ((st.ref ->> 'dataType'::text) = 'specialist_regs'::text) AND ((st.field)::text = 'tel'::text))
         LIMIT 1) AS tel_confirmed,
    t.tel_sent,
    ( SELECT st.confirmed
           FROM public.confirmation_status st
          WHERE (((((st.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id) AND ((st.ref ->> 'dataType'::text) = 'specialist_regs'::text) AND ((st.field)::text = 'email'::text))
         LIMIT 1) AS email_confirmed,
    t.email_sent,
    ( SELECT jsonb_agg((att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text)))) AS jsonb_agg
           FROM public.attachments att
          WHERE (((att.ref ->> 'dataType'::text) = 'specialist_regs'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id))) AS passport_preview,
    t.passport_uploaded,
    ( SELECT
                CASE
                    WHEN ((op.status = 'end'::text) AND (COALESCE(op.error_text, ''::text) = ''::text)) THEN true
                    WHEN ((op.status = 'end'::text) AND (COALESCE(op.error_text, ''::text) <> ''::text)) THEN false
                    ELSE NULL::boolean
                END AS "case"
           FROM public.user_operations op
          WHERE ((op.operation_id)::text = (t.user_operation_id)::text)) AS operation_result
   FROM public.specialist_regs t;


ALTER VIEW public.specialist_regs_dialog OWNER TO nails;

--
-- Name: specialist_regs_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_regs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_regs_id_seq OWNER TO nails;

--
-- Name: specialist_regs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_regs_id_seq OWNED BY public.specialist_regs.id;


--
-- Name: specialist_regs_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_regs_list AS
 SELECT t.id,
    t.inn,
    t.name_full,
    t.tel,
    t.tel_sent,
    ( SELECT st.confirmed
           FROM public.confirmation_status st
          WHERE (((((st.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id) AND ((st.ref ->> 'dataType'::text) = 'specialist_regs'::text) AND ((st.field)::text = 'tel'::text))
         LIMIT 1) AS tel_confirmed,
    t.email,
    t.email_sent,
    ( SELECT st.confirmed
           FROM public.confirmation_status st
          WHERE (((((st.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id) AND ((st.ref ->> 'dataType'::text) = 'specialist_regs'::text) AND ((st.field)::text = 'email'::text))
         LIMIT 1) AS email_confirmed,
    t.date_time,
    t.inn_fns_ok,
    t.inn_checked,
    t.birthdate,
    t.banks_ref,
    t.bank_acc,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text))) AS passport_preview,
    ( SELECT
                CASE
                    WHEN ((op.status = 'end'::text) AND (COALESCE(op.error_text, ''::text) = ''::text)) THEN true
                    WHEN ((op.status = 'end'::text) AND (COALESCE(op.error_text, ''::text) <> ''::text)) THEN false
                    ELSE NULL::boolean
                END AS "case"
           FROM public.user_operations op
          WHERE ((op.operation_id)::text = (t.user_operation_id)::text)) AS operation_result
   FROM (public.specialist_regs t
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'specialist_regs'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id))))
  ORDER BY ( SELECT
                CASE
                    WHEN ((op.status = 'end'::text) AND (COALESCE(op.error_text, ''::text) = ''::text)) THEN true
                    WHEN ((op.status = 'end'::text) AND (COALESCE(op.error_text, ''::text) <> ''::text)) THEN false
                    ELSE NULL::boolean
                END AS "case"
           FROM public.user_operations op
          WHERE ((op.operation_id)::text = (t.user_operation_id)::text)), t.date_time DESC;


ALTER VIEW public.specialist_regs_list OWNER TO nails;

--
-- Name: specialist_salary_debets; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_salary_debets (
    id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    specialist_id integer NOT NULL,
    salary_debet_id integer NOT NULL,
    total numeric(15,2) NOT NULL
);


ALTER TABLE public.specialist_salary_debets OWNER TO nails;

--
-- Name: specialist_salary_debets_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_salary_debets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_salary_debets_id_seq OWNER TO nails;

--
-- Name: specialist_salary_debets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_salary_debets_id_seq OWNED BY public.specialist_salary_debets.id;


--
-- Name: specialist_salary_debets_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_salary_debets_list AS
 SELECT t.id,
    t.date_time,
    t.specialist_id,
    public.specialists_ref(specialists_ref_t.*) AS specialists_ref,
    public.salary_debets_ref(salary_debets_ref_t.*) AS salary_debets_ref,
    t.total
   FROM ((public.specialist_salary_debets t
     LEFT JOIN public.specialists specialists_ref_t ON ((specialists_ref_t.id = t.specialist_id)))
     LEFT JOIN public.salary_debets salary_debets_ref_t ON ((salary_debets_ref_t.id = t.salary_debet_id)))
  ORDER BY t.date_time DESC;


ALTER VIEW public.specialist_salary_debets_list OWNER TO nails;

--
-- Name: specialist_salary_kredits; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_salary_kredits (
    id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    specialist_id integer NOT NULL,
    salary_kredit_id integer NOT NULL,
    total numeric(15,2) NOT NULL
);


ALTER TABLE public.specialist_salary_kredits OWNER TO nails;

--
-- Name: specialist_salary_kredits_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_salary_kredits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_salary_kredits_id_seq OWNER TO nails;

--
-- Name: specialist_salary_kredits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_salary_kredits_id_seq OWNED BY public.specialist_salary_kredits.id;


--
-- Name: specialist_salary_kredits_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_salary_kredits_list AS
 SELECT t.id,
    t.date_time,
    t.specialist_id,
    public.specialists_ref(specialists_ref_t.*) AS specialists_ref,
    public.salary_kredits_ref(salary_kredits_ref_t.*) AS salary_kredits_ref,
    t.total
   FROM ((public.specialist_salary_kredits t
     LEFT JOIN public.specialists specialists_ref_t ON ((specialists_ref_t.id = t.specialist_id)))
     LEFT JOIN public.salary_kredits salary_kredits_ref_t ON ((salary_kredits_ref_t.id = t.salary_kredit_id)))
  ORDER BY t.date_time DESC;


ALTER VIEW public.specialist_salary_kredits_list OWNER TO nails;

--
-- Name: specialist_statuses; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_statuses (
    id integer NOT NULL,
    specialist_id integer NOT NULL,
    status_type public.specialist_status_types NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.specialist_statuses OWNER TO nails;

--
-- Name: specialist_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_statuses_id_seq OWNER TO nails;

--
-- Name: specialist_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_statuses_id_seq OWNED BY public.specialist_statuses.id;


--
-- Name: specialist_works; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.specialist_works (
    id integer NOT NULL,
    specialist_id integer NOT NULL,
    studio_id integer NOT NULL,
    date_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    admin_rate integer,
    ycl_document_id integer
);


ALTER TABLE public.specialist_works OWNER TO nails;

--
-- Name: specialist_works_for_rate_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_works_for_rate_list AS
 SELECT t.id,
    t.specialist_id,
    public.specialists_ref(sp.*) AS specialists_ref,
    t.studio_id,
    public.studios_ref(st.*) AS studios_ref,
    t.date_time,
    t.admin_rate,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_data, 'base64'::text))) AS photo
   FROM (((public.specialist_works t
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'specialist_works'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id))))
     LEFT JOIN public.specialists sp ON ((sp.id = t.specialist_id)))
     LEFT JOIN public.studios st ON ((st.id = t.studio_id)))
  WHERE (t.admin_rate IS NULL)
  ORDER BY t.date_time DESC;


ALTER VIEW public.specialist_works_for_rate_list OWNER TO nails;

--
-- Name: specialist_works_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialist_works_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialist_works_id_seq OWNER TO nails;

--
-- Name: specialist_works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialist_works_id_seq OWNED BY public.specialist_works.id;


--
-- Name: ycl_transactions; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.ycl_transactions (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    data jsonb,
    specialist_id integer,
    document_id integer,
    date timestamp with time zone,
    amount numeric(15,2),
    seance_length integer,
    record_id integer,
    staff_id integer,
    record_inf_updated boolean DEFAULT false
);


ALTER TABLE public.ycl_transactions OWNER TO nails;

--
-- Name: ycl_transactions_doc_all_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.ycl_transactions_doc_all_list AS
 SELECT t.document_id,
    t.date,
    sum(t.amount) AS amount,
    (((((t.data -> 'client'::text) ->> 'name'::text) || ' ('::text) || ((t.data -> 'client'::text) ->> 'phone'::text)) || ')'::text) AS client,
    t.specialist_id,
    public.specialists_ref(sp.*) AS specialists_ref,
    round(((t.seance_length / 3600))::numeric, 2) AS len_hour,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_data, 'base64'::text))) AS photo,
    sp_w.admin_rate
   FROM (((public.ycl_transactions t
     LEFT JOIN public.specialists sp ON ((sp.id = t.specialist_id)))
     LEFT JOIN public.specialist_works sp_w ON ((sp_w.ycl_document_id = ((t.data ->> 'document_id'::text))::integer)))
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'specialist_works'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = sp_w.id))))
  GROUP BY t.document_id, t.seance_length, t.date, (t.data -> 'client'::text), t.specialist_id, sp.*, att.content_info, att.content_data, sp_w.admin_rate
  ORDER BY t.document_id, t.date;


ALTER VIEW public.ycl_transactions_doc_all_list OWNER TO nails;

--
-- Name: specialist_works_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialist_works_list AS
 SELECT t.id,
    t.specialist_id,
    public.specialists_ref(sp.*) AS specialists_ref,
    t.studio_id,
    public.studios_ref(st.*) AS studios_ref,
    t.date_time,
    tr.admin_rate,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text))) AS photo,
    COALESCE(tr.len_hour, 0.0) AS hours,
    COALESCE(tr.amount, 0.0) AS amount
   FROM ((((public.specialist_works t
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'specialist_works'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id))))
     LEFT JOIN public.specialists sp ON ((sp.id = t.specialist_id)))
     LEFT JOIN public.studios st ON ((st.id = t.studio_id)))
     LEFT JOIN public.ycl_transactions_doc_all_list tr ON ((tr.document_id = t.ycl_document_id)))
  ORDER BY t.date_time DESC;


ALTER VIEW public.specialist_works_list OWNER TO nails;

--
-- Name: specialists_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialists_dialog AS
 SELECT t.id,
    t.name,
    t.inn,
    banks.banks_ref(bnk.*) AS banks_ref,
    t.bank_acc,
    t.studio_id,
    public.studios_ref(studios_ref_t.*) AS studios_ref,
    t.birthdate,
    t.address_reg,
    t.passport,
    ( SELECT st.status_type
           FROM public.specialist_statuses st
          WHERE (st.specialist_id = t.id)
          ORDER BY st.date_time DESC
         LIMIT 1) AS last_status_type,
    public.users_ref(( SELECT u.*::public.users AS u
           FROM public.users u
          WHERE (u.id = t.user_id))) AS users_ref,
    t.equipments,
    ( SELECT jsonb_agg((att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text)))) AS jsonb_agg
           FROM public.attachments att
          WHERE (((att.ref ->> 'dataType'::text) = 'specialists'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id) AND ((att.content_info ->> 'id'::text) = 'passport'::text))) AS passport_preview,
    ct.email,
    ct.tel,
    t.agent_percent,
    public.specialities_ref(spt.*) AS specialities_ref
   FROM (((((public.specialists t
     LEFT JOIN public.studios studios_ref_t ON ((studios_ref_t.id = t.studio_id)))
     LEFT JOIN banks.banks bnk ON (((bnk.bik)::text = (t.bank_bik)::text)))
     LEFT JOIN public.entity_contacts e_ct ON (((e_ct.entity_type = 'specialists'::public.data_types) AND (e_ct.entity_id = t.id))))
     LEFT JOIN public.contacts ct ON ((ct.id = e_ct.contact_id)))
     LEFT JOIN public.specialities spt ON ((spt.id = t.speciality_id)));


ALTER VIEW public.specialists_dialog OWNER TO nails;

--
-- Name: specialists_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialists_id_seq OWNER TO nails;

--
-- Name: specialists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialists_id_seq OWNED BY public.specialists.id;


--
-- Name: specialists_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialists_list AS
 SELECT t.id,
    t.name,
    t.inn,
    banks.banks_ref(bn.*) AS banks_ref,
    t.bank_acc,
    t.studio_id,
    public.studios_ref(studios_ref_t.*) AS studios_ref,
    ct.email,
    ct.tel,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text))) AS photo,
    public.specialities_ref(spt.*) AS specialities_ref
   FROM ((((((public.specialists t
     LEFT JOIN public.studios studios_ref_t ON ((studios_ref_t.id = t.studio_id)))
     LEFT JOIN banks.banks bn ON (((bn.bik)::text = (t.bank_bik)::text)))
     LEFT JOIN public.entity_contacts e_ct ON (((e_ct.entity_id = t.id) AND (e_ct.entity_type = 'specialists'::public.data_types))))
     LEFT JOIN public.contacts ct ON ((ct.id = e_ct.contact_id)))
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'users'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.user_id) AND ((att.content_info ->> 'id'::text) = 'photo'::text))))
     LEFT JOIN public.specialities spt ON ((spt.id = t.speciality_id)))
  ORDER BY t.name;


ALTER VIEW public.specialists_list OWNER TO nails;

--
-- Name: specialities_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialities_dialog AS
 SELECT t.id,
    t.name,
    t.equipments,
    t.agent_percent
   FROM public.specialities t;


ALTER VIEW public.specialities_dialog OWNER TO nails;

--
-- Name: specialities_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.specialities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialities_id_seq OWNER TO nails;

--
-- Name: specialities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.specialities_id_seq OWNED BY public.specialities.id;


--
-- Name: specialities_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.specialities_list AS
 SELECT t.id,
    t.name
   FROM public.specialities t
  ORDER BY t.name;


ALTER VIEW public.specialities_list OWNER TO nails;

--
-- Name: studios_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.studios_dialog AS
 SELECT t.id,
    t.name,
    t.firm_id,
    public.firms_ref(firms_ref_t.*) AS firms_ref,
    t.equipments,
    t.hour_rent_price
   FROM (public.studios t
     LEFT JOIN public.firms firms_ref_t ON ((firms_ref_t.id = t.firm_id)));


ALTER VIEW public.studios_dialog OWNER TO nails;

--
-- Name: studios_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.studios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.studios_id_seq OWNER TO nails;

--
-- Name: studios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.studios_id_seq OWNED BY public.studios.id;


--
-- Name: studios_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.studios_list AS
 SELECT t.id,
    t.name
   FROM public.studios t
  ORDER BY t.name;


ALTER VIEW public.studios_list OWNER TO nails;

--
-- Name: template_batch_items; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.template_batch_items (
    id integer NOT NULL,
    template_batch_id integer NOT NULL,
    template_id integer NOT NULL,
    studio_id integer
);


ALTER TABLE public.template_batch_items OWNER TO nails;

--
-- Name: template_batch_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.template_batch_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_batch_items_id_seq OWNER TO nails;

--
-- Name: template_batch_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.template_batch_items_id_seq OWNED BY public.template_batch_items.id;


--
-- Name: template_batch_items_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.template_batch_items_list AS
 SELECT t.id,
    t.template_batch_id,
    public.document_templates_ref(templates_ref_t.*) AS templates_ref,
    public.studios_ref(st.*) AS studios_ref
   FROM ((public.template_batch_items t
     LEFT JOIN public.document_templates templates_ref_t ON ((templates_ref_t.id = t.template_id)))
     LEFT JOIN public.studios st ON ((st.id = t.studio_id)))
  ORDER BY st.name, templates_ref_t.name;


ALTER VIEW public.template_batch_items_list OWNER TO nails;

--
-- Name: template_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.template_batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_batches_id_seq OWNER TO nails;

--
-- Name: template_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.template_batches_id_seq OWNED BY public.template_batches.id;


--
-- Name: time_zone_locales_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.time_zone_locales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.time_zone_locales_id_seq OWNER TO nails;

--
-- Name: time_zone_locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.time_zone_locales_id_seq OWNED BY public.time_zone_locales.id;


--
-- Name: user_operations_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.user_operations_dialog AS
 SELECT t.user_id,
    t.operation_id,
    t.operation,
    t.status,
    t.date_time,
    t.error_text,
    t.comment_text,
    t.date_time_end,
    t.end_wal_lsn
   FROM public.user_operations t;


ALTER VIEW public.user_operations_dialog OWNER TO nails;

--
-- Name: users_dialog; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.users_dialog AS
 SELECT t.id,
    t.name,
    t.name_full,
    t.role_id,
    t.create_dt,
    t.banned,
    public.time_zone_locales_ref(time_zone_locales_ref_t.*) AS time_zone_locales_ref,
    t.locale_id,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_data, 'base64'::text))) AS photo
   FROM ((public.users t
     LEFT JOIN public.time_zone_locales time_zone_locales_ref_t ON ((time_zone_locales_ref_t.id = t.time_zone_locale_id)))
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'users'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id))));


ALTER VIEW public.users_dialog OWNER TO nails;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO nails;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.users_list AS
 SELECT t.id,
    t.name,
    t.name_full,
    t.role_id,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_preview, 'base64'::text))) AS photo,
    ct.email,
    ct.tel
   FROM (((public.users t
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'users'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = t.id) AND ((att.content_info ->> 'id'::text) = 'photo'::text))))
     LEFT JOIN public.entity_contacts e_ct ON (((e_ct.entity_type = 'users'::public.data_types) AND (e_ct.entity_id = t.id))))
     LEFT JOIN public.contacts ct ON ((ct.id = e_ct.contact_id)))
  ORDER BY t.name;


ALTER VIEW public.users_list OWNER TO nails;

--
-- Name: users_login; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.users_login AS
 SELECT u.id,
    u.name,
    u.name_full,
    u.role_id,
    u.create_dt,
    u.banned,
    public.time_zone_locales_ref(tz.*) AS time_zone_locales_ref,
    u.locale_id,
    ( SELECT string_agg((bn.hash)::text, ','::text) AS string_agg
           FROM public.login_device_bans bn
          WHERE (bn.user_id = u.id)) AS ban_hash,
    u.pwd,
    encode(att.content_preview, 'base64'::text) AS photo
   FROM ((public.users u
     LEFT JOIN public.time_zone_locales tz ON ((tz.id = u.time_zone_locale_id)))
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'users'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = u.id) AND ((att.content_info ->> 'id'::text) = 'photo'::text))));


ALTER VIEW public.users_login OWNER TO nails;

--
-- Name: users_profile; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.users_profile AS
 SELECT u.id,
    u.name,
    u.name_full,
    u.locale_id,
    public.time_zone_locales_ref(tzl.*) AS time_zone_locales_ref,
    (att.content_info || jsonb_build_object('dataBase64', encode(att.content_data, 'base64'::text))) AS photo
   FROM ((public.users u
     LEFT JOIN public.time_zone_locales tzl ON ((tzl.id = u.time_zone_locale_id)))
     LEFT JOIN public.attachments att ON ((((att.ref ->> 'dataType'::text) = 'users'::text) AND ((((att.ref -> 'keys'::text) ->> 'id'::text))::integer = u.id) AND ((att.content_info ->> 'id'::text) = 'photo'::text))));


ALTER VIEW public.users_profile OWNER TO nails;

--
-- Name: views; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.views (
    id integer NOT NULL,
    c text,
    f text,
    t text,
    section text NOT NULL,
    descr text NOT NULL,
    limited boolean
);


ALTER TABLE public.views OWNER TO nails;

--
-- Name: views_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.views_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.views_id_seq OWNER TO nails;

--
-- Name: views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.views_id_seq OWNED BY public.views.id;


--
-- Name: views_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.views_list AS
 SELECT v.id,
    v.c,
    v.f,
    v.t,
    v.section,
    v.descr,
    v.limited,
    ((v.section || ' '::text) || v.descr) AS user_descr,
    (((
        CASE
            WHEN (v.c IS NOT NULL) THEN (('c="'::text || v.c) || '"'::text)
            ELSE ''::text
        END ||
        CASE
            WHEN (v.f IS NOT NULL) THEN (((
            CASE
                WHEN (v.c IS NULL) THEN ''::text
                ELSE ' '::text
            END || 'f="'::text) || v.f) || '"'::text)
            ELSE ''::text
        END) ||
        CASE
            WHEN (v.t IS NOT NULL) THEN (((
            CASE
                WHEN ((v.c IS NULL) AND (v.f IS NULL)) THEN ''::text
                ELSE ' '::text
            END || 't="'::text) || v.t) || '"'::text)
            ELSE ''::text
        END) ||
        CASE
            WHEN ((v.limited IS NOT NULL) AND v.limited) THEN (
            CASE
                WHEN ((v.c IS NULL) AND (v.f IS NULL) AND (v.t IS NULL)) THEN ''::text
                ELSE ' '::text
            END || 'limit="TRUE"'::text)
            ELSE ''::text
        END) AS href
   FROM public.views v
  ORDER BY v.section, v.descr;


ALTER VIEW public.views_list OWNER TO nails;

--
-- Name: ycl_staff; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.ycl_staff (
    id integer NOT NULL,
    name text,
    data jsonb
);


ALTER TABLE public.ycl_staff OWNER TO nails;

--
-- Name: ycl_staff_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.ycl_staff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ycl_staff_id_seq OWNER TO nails;

--
-- Name: ycl_staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.ycl_staff_id_seq OWNED BY public.ycl_staff.id;


--
-- Name: ycl_staff_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.ycl_staff_list AS
 SELECT t.id,
    t.name,
    (t.data ->> 'specialization'::text) AS specialization,
    (t.data ->> 'avatar'::text) AS avatar,
    (t.data ->> 'avatar_big'::text) AS avatar_big,
    ((t.data ->> 'rating'::text))::numeric(15,2) AS rating,
    ((t.data ->> 'votes_count'::text))::integer AS votes_count
   FROM public.ycl_staff t
  ORDER BY t.name;


ALTER VIEW public.ycl_staff_list OWNER TO nails;

--
-- Name: ycl_transactions_doc_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.ycl_transactions_doc_list AS
 SELECT t.document_id,
    t.date,
    sum(t.amount) AS amount,
    (((((t.data -> 'client'::text) ->> 'name'::text) || ' ('::text) || ((t.data -> 'client'::text) ->> 'phone'::text)) || ')'::text) AS client,
    t.specialist_id,
    t.seance_length
   FROM public.ycl_transactions t
  WHERE (NOT (EXISTS ( SELECT specialist_works.id
           FROM public.specialist_works
          WHERE (specialist_works.ycl_document_id = ((t.data ->> 'document_id'::text))::integer))))
  GROUP BY t.document_id, t.seance_length, t.date, (t.data -> 'client'::text), t.specialist_id
  ORDER BY t.document_id, t.date;


ALTER VIEW public.ycl_transactions_doc_list OWNER TO nails;

--
-- Name: ycl_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.ycl_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ycl_transactions_id_seq OWNER TO nails;

--
-- Name: ycl_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.ycl_transactions_id_seq OWNED BY public.ycl_transactions.id;


--
-- Name: ycl_transactions_list; Type: VIEW; Schema: public; Owner: nails
--

CREATE VIEW public.ycl_transactions_list AS
 SELECT t.id,
    t.document_id,
    t.date,
    t.amount,
    ((t.data -> 'client'::text) ->> 'name'::text) AS client,
    ((t.data -> 'client'::text) ->> 'phone'::text) AS client_phone,
    public.specialists_ref(specialists_ref_t.*) AS specialists_ref,
    json_build_object('keys', json_build_object('id', ycl_staff.id), 'descr', ycl_staff.name) AS ycl_staff_ref,
    t.specialist_id,
    t.seance_length
   FROM ((public.ycl_transactions t
     LEFT JOIN public.specialists specialists_ref_t ON ((specialists_ref_t.id = t.specialist_id)))
     LEFT JOIN public.ycl_staff ON ((ycl_staff.id = t.staff_id)))
  ORDER BY t.date DESC;


ALTER VIEW public.ycl_transactions_list OWNER TO nails;

--
-- Name: ycl_visits; Type: TABLE; Schema: public; Owner: nails
--

CREATE TABLE public.ycl_visits (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    data jsonb,
    specialist_id integer NOT NULL
);


ALTER TABLE public.ycl_visits OWNER TO nails;

--
-- Name: ycl_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: nails
--

CREATE SEQUENCE public.ycl_visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ycl_visits_id_seq OWNER TO nails;

--
-- Name: ycl_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nails
--

ALTER SEQUENCE public.ycl_visits_id_seq OWNED BY public.ycl_visits.id;


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: bank_payments id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.bank_payments ALTER COLUMN id SET DEFAULT nextval('public.bank_payments_id_seq'::regclass);


--
-- Name: confirmation_status id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.confirmation_status ALTER COLUMN id SET DEFAULT nextval('public.confirmation_status_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: document_templates id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.document_templates ALTER COLUMN id SET DEFAULT nextval('public.document_templates_id_seq'::regclass);


--
-- Name: entity_contacts id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.entity_contacts ALTER COLUMN id SET DEFAULT nextval('public.entity_contacts_id_seq'::regclass);


--
-- Name: equipment_types id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.equipment_types ALTER COLUMN id SET DEFAULT nextval('public.equipment_types_id_seq'::regclass);


--
-- Name: firms id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.firms ALTER COLUMN id SET DEFAULT nextval('public.firms_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: logins id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.logins ALTER COLUMN id SET DEFAULT nextval('public.logins_id_seq'::regclass);


--
-- Name: main_menus id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.main_menus ALTER COLUMN id SET DEFAULT nextval('public.main_menus_id_seq'::regclass);


--
-- Name: notif_templates id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.notif_templates ALTER COLUMN id SET DEFAULT nextval('public.notif_templates_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: salary_debets id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.salary_debets ALTER COLUMN id SET DEFAULT nextval('public.salary_debets_id_seq'::regclass);


--
-- Name: salary_kredits id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.salary_kredits ALTER COLUMN id SET DEFAULT nextval('public.salary_kredits_id_seq'::regclass);


--
-- Name: specialist_documents id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents ALTER COLUMN id SET DEFAULT nextval('public.specialist_documents_id_seq'::regclass);


--
-- Name: specialist_documents_on_register id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents_on_register ALTER COLUMN id SET DEFAULT nextval('public.specialist_documents_on_register_id_seq'::regclass);


--
-- Name: specialist_period_salaries id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salaries ALTER COLUMN id SET DEFAULT nextval('public.specialist_period_salaries_id_seq'::regclass);


--
-- Name: specialist_period_salary_details id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salary_details ALTER COLUMN id SET DEFAULT nextval('public.specialist_period_salary_details_id_seq'::regclass);


--
-- Name: specialist_receipts id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_receipts ALTER COLUMN id SET DEFAULT nextval('public.specialist_receipts_id_seq'::regclass);


--
-- Name: specialist_regs id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_regs ALTER COLUMN id SET DEFAULT nextval('public.specialist_regs_id_seq'::regclass);


--
-- Name: specialist_salary_debets id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_debets ALTER COLUMN id SET DEFAULT nextval('public.specialist_salary_debets_id_seq'::regclass);


--
-- Name: specialist_salary_kredits id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_kredits ALTER COLUMN id SET DEFAULT nextval('public.specialist_salary_kredits_id_seq'::regclass);


--
-- Name: specialist_statuses id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_statuses ALTER COLUMN id SET DEFAULT nextval('public.specialist_statuses_id_seq'::regclass);


--
-- Name: specialist_works id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_works ALTER COLUMN id SET DEFAULT nextval('public.specialist_works_id_seq'::regclass);


--
-- Name: specialists id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialists ALTER COLUMN id SET DEFAULT nextval('public.specialists_id_seq'::regclass);


--
-- Name: specialities id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialities ALTER COLUMN id SET DEFAULT nextval('public.specialities_id_seq'::regclass);


--
-- Name: studios id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.studios ALTER COLUMN id SET DEFAULT nextval('public.studios_id_seq'::regclass);


--
-- Name: template_batch_items id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batch_items ALTER COLUMN id SET DEFAULT nextval('public.template_batch_items_id_seq'::regclass);


--
-- Name: template_batches id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batches ALTER COLUMN id SET DEFAULT nextval('public.template_batches_id_seq'::regclass);


--
-- Name: time_zone_locales id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.time_zone_locales ALTER COLUMN id SET DEFAULT nextval('public.time_zone_locales_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: views id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.views ALTER COLUMN id SET DEFAULT nextval('public.views_id_seq'::regclass);


--
-- Name: ycl_staff id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_staff ALTER COLUMN id SET DEFAULT nextval('public.ycl_staff_id_seq'::regclass);


--
-- Name: ycl_transactions id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_transactions ALTER COLUMN id SET DEFAULT nextval('public.ycl_transactions_id_seq'::regclass);


--
-- Name: ycl_visits id; Type: DEFAULT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_visits ALTER COLUMN id SET DEFAULT nextval('public.ycl_visits_id_seq'::regclass);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: bank_payments bank_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.bank_payments
    ADD CONSTRAINT bank_payments_pkey PRIMARY KEY (id);


--
-- Name: confirmation_status confirmation_status_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.confirmation_status
    ADD CONSTRAINT confirmation_status_pkey PRIMARY KEY (id);


--
-- Name: const_doc_per_page_count const_doc_per_page_count_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.const_doc_per_page_count
    ADD CONSTRAINT const_doc_per_page_count_pkey PRIMARY KEY (name);


--
-- Name: const_email const_email_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.const_email
    ADD CONSTRAINT const_email_pkey PRIMARY KEY (name);


--
-- Name: const_grid_refresh_interval const_grid_refresh_interval_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.const_grid_refresh_interval
    ADD CONSTRAINT const_grid_refresh_interval_pkey PRIMARY KEY (name);


--
-- Name: const_join_contract const_join_contract_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.const_join_contract
    ADD CONSTRAINT const_join_contract_pkey PRIMARY KEY (name);


--
-- Name: const_person_tax const_person_tax_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.const_person_tax
    ADD CONSTRAINT const_person_tax_pkey PRIMARY KEY (name);


--
-- Name: const_specialist_pay_comment_template const_specialist_pay_comment_template_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.const_specialist_pay_comment_template
    ADD CONSTRAINT const_specialist_pay_comment_template_pkey PRIMARY KEY (name);


--
-- Name: const_specialist_services const_specialist_services_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.const_specialist_services
    ADD CONSTRAINT const_specialist_services_pkey PRIMARY KEY (name);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: document_templates document_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.document_templates
    ADD CONSTRAINT document_templates_pkey PRIMARY KEY (id);


--
-- Name: entity_contacts entity_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.entity_contacts
    ADD CONSTRAINT entity_contacts_pkey PRIMARY KEY (id);


--
-- Name: equipment_types equipment_types_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.equipment_types
    ADD CONSTRAINT equipment_types_pkey PRIMARY KEY (id);


--
-- Name: firms firms_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.firms
    ADD CONSTRAINT firms_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: login_device_bans login_device_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.login_device_bans
    ADD CONSTRAINT login_device_bans_pkey PRIMARY KEY (user_id, hash);


--
-- Name: logins logins_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.logins
    ADD CONSTRAINT logins_pkey PRIMARY KEY (id);


--
-- Name: main_menus main_menus_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.main_menus
    ADD CONSTRAINT main_menus_pkey PRIMARY KEY (id);


--
-- Name: notif_templates notif_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.notif_templates
    ADD CONSTRAINT notif_templates_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: salary_debets salary_debets_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.salary_debets
    ADD CONSTRAINT salary_debets_pkey PRIMARY KEY (id);


--
-- Name: salary_kredits salary_kredits_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.salary_kredits
    ADD CONSTRAINT salary_kredits_pkey PRIMARY KEY (id);


--
-- Name: session_vals session_vals_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.session_vals
    ADD CONSTRAINT session_vals_pkey PRIMARY KEY (id);


--
-- Name: specialist_documents_on_register specialist_documents_on_register_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents_on_register
    ADD CONSTRAINT specialist_documents_on_register_pkey PRIMARY KEY (id);


--
-- Name: specialist_documents specialist_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents
    ADD CONSTRAINT specialist_documents_pkey PRIMARY KEY (id);


--
-- Name: specialist_period_salaries specialist_period_salaries_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salaries
    ADD CONSTRAINT specialist_period_salaries_pkey PRIMARY KEY (id);


--
-- Name: specialist_period_salary_details specialist_period_salary_details_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salary_details
    ADD CONSTRAINT specialist_period_salary_details_pkey PRIMARY KEY (id);


--
-- Name: specialist_receipts specialist_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_receipts
    ADD CONSTRAINT specialist_receipts_pkey PRIMARY KEY (id);


--
-- Name: specialist_regs specialist_regs_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_regs
    ADD CONSTRAINT specialist_regs_pkey PRIMARY KEY (id);


--
-- Name: specialist_salary_debets specialist_salary_debets_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_debets
    ADD CONSTRAINT specialist_salary_debets_pkey PRIMARY KEY (id);


--
-- Name: specialist_salary_kredits specialist_salary_kredits_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_kredits
    ADD CONSTRAINT specialist_salary_kredits_pkey PRIMARY KEY (id);


--
-- Name: specialist_statuses specialist_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_statuses
    ADD CONSTRAINT specialist_statuses_pkey PRIMARY KEY (id);


--
-- Name: specialist_works specialist_works_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_works
    ADD CONSTRAINT specialist_works_pkey PRIMARY KEY (id);


--
-- Name: specialists specialists_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialists
    ADD CONSTRAINT specialists_pkey PRIMARY KEY (id);


--
-- Name: specialities specialities_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialities
    ADD CONSTRAINT specialities_pkey PRIMARY KEY (id);


--
-- Name: studios studios_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.studios
    ADD CONSTRAINT studios_pkey PRIMARY KEY (id);


--
-- Name: template_batch_items template_batch_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batch_items
    ADD CONSTRAINT template_batch_items_pkey PRIMARY KEY (id);


--
-- Name: template_batches template_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batches
    ADD CONSTRAINT template_batches_pkey PRIMARY KEY (id);


--
-- Name: time_zone_locales time_zone_locales_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.time_zone_locales
    ADD CONSTRAINT time_zone_locales_pkey PRIMARY KEY (id);


--
-- Name: user_operations user_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.user_operations
    ADD CONSTRAINT user_operations_pkey PRIMARY KEY (user_id, operation_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: views views_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT views_pkey PRIMARY KEY (id);


--
-- Name: ycl_staff ycl_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_staff
    ADD CONSTRAINT ycl_staff_pkey PRIMARY KEY (id);


--
-- Name: ycl_transactions ycl_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_transactions
    ADD CONSTRAINT ycl_transactions_pkey PRIMARY KEY (id);


--
-- Name: ycl_visits ycl_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_visits
    ADD CONSTRAINT ycl_visits_pkey PRIMARY KEY (id);


--
-- Name: attachments_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX attachments_idx ON public.attachments USING btree (((ref ->> 'dataType'::text)), ((((ref -> 'keys'::text) ->> 'id'::text))::integer), ((content_info ->> 'id'::text)));


--
-- Name: bank_payments_document_date_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX bank_payments_document_date_idx ON public.bank_payments USING btree (document_date);


--
-- Name: bank_payments_document_num_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX bank_payments_document_num_idx ON public.bank_payments USING btree (document_num);


--
-- Name: bank_payments_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX bank_payments_specialist_idx ON public.bank_payments USING btree (specialist_id);


--
-- Name: bank_payments_specialist_salary_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX bank_payments_specialist_salary_idx ON public.bank_payments USING btree (specialist_period_salary_detail_id);


--
-- Name: confirmation_status_ref_field_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX confirmation_status_ref_field_idx ON public.confirmation_status USING btree (field, ((ref ->> 'dataType'::text)), ((((ref -> 'keys'::text) ->> 'id'::text))::integer));


--
-- Name: contacts_descr_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX contacts_descr_idx ON public.contacts USING btree (lower(descr));


--
-- Name: contacts_tel_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX contacts_tel_idx ON public.contacts USING btree (tel);


--
-- Name: entity_contacts_contact_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX entity_contacts_contact_idx ON public.entity_contacts USING btree (entity_type, contact_id);


--
-- Name: entity_contacts_id_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX entity_contacts_id_idx ON public.entity_contacts USING btree (entity_type, entity_id, contact_id);


--
-- Name: firms_inn_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX firms_inn_idx ON public.firms USING btree (inn);


--
-- Name: firms_name_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX firms_name_idx ON public.studios USING btree (lower(name));


--
-- Name: firms_ogrn_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX firms_ogrn_idx ON public.firms USING btree (ogrn);


--
-- Name: items_name_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX items_name_idx ON public.items USING btree (lower(name));


--
-- Name: logins_pub_key_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX logins_pub_key_idx ON public.logins USING btree (pub_key);


--
-- Name: logins_session_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX logins_session_idx ON public.logins USING btree (session_id);


--
-- Name: logins_user_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX logins_user_idx ON public.logins USING btree (user_id);


--
-- Name: main_menus_role_user_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX main_menus_role_user_idx ON public.main_menus USING btree (role_id, user_id);


--
-- Name: notif_templates_type_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX notif_templates_type_idx ON public.notif_templates USING btree (notif_provider, notif_type);


--
-- Name: posts_name_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX posts_name_idx ON public.posts USING btree (lower((name)::text));


--
-- Name: specialist_documents_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_documents_specialist_idx ON public.specialist_documents USING btree (specialist_id, date_time);


--
-- Name: specialist_period_salaries_period_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX specialist_period_salaries_period_idx ON public.specialist_period_salary_details USING btree (specialist_period_salary_id, line_num);


--
-- Name: specialist_period_salaries_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_period_salaries_specialist_idx ON public.specialist_period_salary_details USING btree (specialist_id);


--
-- Name: specialist_period_salaries_studio_id_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_period_salaries_studio_id_idx ON public.specialist_period_salaries USING btree (studio_id);


--
-- Name: specialist_receipts_qrextr_request_id_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_receipts_qrextr_request_id_idx ON public.specialist_receipts USING btree (qrextr_request_id);


--
-- Name: specialist_receipts_salary_detail_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_receipts_salary_detail_idx ON public.specialist_receipts USING btree (specialist_period_salary_detail_id);


--
-- Name: specialist_receipts_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_receipts_specialist_idx ON public.specialist_receipts USING btree (specialist_id);


--
-- Name: specialist_regs_operation_id; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX specialist_regs_operation_id ON public.specialist_regs USING btree (user_operation_id);


--
-- Name: specialist_salary_kredits_date_time_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_salary_kredits_date_time_idx ON public.specialist_salary_kredits USING btree (date_time);


--
-- Name: specialist_salary_kredits_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_salary_kredits_specialist_idx ON public.specialist_salary_kredits USING btree (specialist_id);


--
-- Name: specialist_statuses_specialist; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX specialist_statuses_specialist ON public.specialist_statuses USING btree (specialist_id, date_time);


--
-- Name: specialist_works_date_time_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_works_date_time_idx ON public.specialist_works USING btree (date_time);


--
-- Name: specialist_works_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_works_specialist_idx ON public.specialist_works USING btree (specialist_id);


--
-- Name: specialist_works_studio_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_works_studio_idx ON public.specialist_works USING btree (studio_id);


--
-- Name: specialist_works_ycl_document_id_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX specialist_works_ycl_document_id_idx ON public.specialist_works USING btree (ycl_document_id);


--
-- Name: specialists_inn_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX specialists_inn_idx ON public.specialists USING btree (inn);


--
-- Name: specialists_ycl_staff_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX specialists_ycl_staff_idx ON public.specialists USING btree (ycl_staff_id);


--
-- Name: template_batch_items_template_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX template_batch_items_template_idx ON public.template_batch_items USING btree (template_batch_id, studio_id, template_id);


--
-- Name: users_name_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX users_name_idx ON public.users USING btree (lower((name)::text));


--
-- Name: users_name_index; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX users_name_index ON public.users USING btree (lower((name)::text));


--
-- Name: users_role_id_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX users_role_id_idx ON public.users USING btree (role_id);


--
-- Name: views_section_descr_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE UNIQUE INDEX views_section_descr_idx ON public.views USING btree (section, descr);


--
-- Name: ycl_staff_name_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX ycl_staff_name_idx ON public.ycl_staff USING btree (lower(name));


--
-- Name: ycl_transactions_date_time_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX ycl_transactions_date_time_idx ON public.ycl_transactions USING btree (date);


--
-- Name: ycl_transactions_document_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX ycl_transactions_document_idx ON public.ycl_transactions USING btree (document_id);


--
-- Name: ycl_transactions_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX ycl_transactions_specialist_idx ON public.ycl_transactions USING btree (specialist_id);


--
-- Name: ycl_visits_specialist_idx; Type: INDEX; Schema: public; Owner: nails
--

CREATE INDEX ycl_visits_specialist_idx ON public.ycl_visits USING btree (specialist_id, created_at);


--
-- Name: attachments attachments_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER attachments_trigger_after AFTER DELETE ON public.attachments FOR EACH ROW EXECUTE FUNCTION public.attachments_process();


--
-- Name: attachments attachments_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER attachments_trigger_before BEFORE INSERT OR UPDATE ON public.attachments FOR EACH ROW EXECUTE FUNCTION public.attachments_process();


--
-- Name: contacts contacts_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER contacts_trigger_before BEFORE INSERT OR UPDATE ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.contacts_process();


--
-- Name: document_templates document_templates_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER document_templates_trigger_before BEFORE DELETE ON public.document_templates FOR EACH ROW EXECUTE FUNCTION public.document_templates_process();


--
-- Name: permissions permissions_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER permissions_trigger_after AFTER INSERT OR DELETE OR UPDATE ON public.permissions FOR EACH ROW EXECUTE FUNCTION public.permissions_process();


--
-- Name: session_vals session_vals_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER session_vals_trigger_after AFTER DELETE ON public.session_vals FOR EACH ROW EXECUTE FUNCTION public.session_vals_process();


--
-- Name: specialist_documents specialist_documents_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialist_documents_trigger_after AFTER DELETE ON public.specialist_documents FOR EACH ROW EXECUTE FUNCTION public.specialist_documents_process();


--
-- Name: specialist_period_salaries specialist_period_salaries_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialist_period_salaries_trigger_before BEFORE DELETE ON public.specialist_period_salaries FOR EACH ROW EXECUTE FUNCTION public.specialist_period_salaries_process();


--
-- Name: specialist_period_salary_details specialist_period_salary_details_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialist_period_salary_details_trigger_after AFTER INSERT OR DELETE OR UPDATE ON public.specialist_period_salary_details FOR EACH ROW EXECUTE FUNCTION public.specialist_period_salary_details_process();


--
-- Name: specialist_period_salary_details specialist_period_salary_details_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialist_period_salary_details_trigger_before BEFORE INSERT OR DELETE OR UPDATE ON public.specialist_period_salary_details FOR EACH ROW EXECUTE FUNCTION public.specialist_period_salary_details_process();


--
-- Name: specialist_receipts specialist_receipts_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialist_receipts_trigger_after AFTER DELETE ON public.specialist_receipts FOR EACH ROW EXECUTE FUNCTION public.specialist_receipts_process();


--
-- Name: specialist_regs specialist_regs_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialist_regs_trigger_before BEFORE DELETE ON public.specialist_regs FOR EACH ROW EXECUTE FUNCTION public.specialist_regs_process();


--
-- Name: specialist_works specialist_works_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialist_works_trigger_before BEFORE DELETE ON public.specialist_works FOR EACH ROW EXECUTE FUNCTION public.specialist_works_process();


--
-- Name: specialists specialists_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialists_trigger_after AFTER INSERT OR DELETE ON public.specialists FOR EACH ROW EXECUTE FUNCTION public.specialists_process();


--
-- Name: specialists specialists_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER specialists_trigger_before BEFORE INSERT OR DELETE ON public.specialists FOR EACH ROW EXECUTE FUNCTION public.specialists_process();


--
-- Name: user_operations user_operations_trigger_after; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER user_operations_trigger_after AFTER UPDATE ON public.user_operations FOR EACH ROW EXECUTE FUNCTION public.user_operations_process();


--
-- Name: ycl_staff ycl_staff_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER ycl_staff_trigger_before BEFORE INSERT OR DELETE ON public.ycl_staff FOR EACH ROW EXECUTE FUNCTION public.ycl_staff_process();


--
-- Name: ycl_transactions ycl_transactions_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER ycl_transactions_trigger_before BEFORE INSERT OR UPDATE ON public.ycl_transactions FOR EACH ROW EXECUTE FUNCTION public.ycl_transactions_process();


--
-- Name: ycl_visits ycl_visits_trigger_before; Type: TRIGGER; Schema: public; Owner: nails
--

CREATE TRIGGER ycl_visits_trigger_before BEFORE INSERT OR DELETE ON public.ycl_visits FOR EACH ROW EXECUTE FUNCTION public.ycl_visits_process();


--
-- Name: bank_payments bank_payments_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.bank_payments
    ADD CONSTRAINT bank_payments_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: bank_payments bank_payments_specialist_period_salary_detail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.bank_payments
    ADD CONSTRAINT bank_payments_specialist_period_salary_detail_id_fkey FOREIGN KEY (specialist_period_salary_detail_id) REFERENCES public.specialist_period_salary_details(id);


--
-- Name: contacts contacts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: entity_contacts entity_contacts_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.entity_contacts
    ADD CONSTRAINT entity_contacts_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contacts(id);


--
-- Name: main_menus main_menus_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.main_menus
    ADD CONSTRAINT main_menus_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: specialist_documents specialist_documents_document_att_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents
    ADD CONSTRAINT specialist_documents_document_att_id_fkey FOREIGN KEY (document_att_id) REFERENCES public.attachments(id);


--
-- Name: specialist_documents specialist_documents_document_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents
    ADD CONSTRAINT specialist_documents_document_template_id_fkey FOREIGN KEY (document_template_id) REFERENCES public.document_templates(id);


--
-- Name: specialist_documents_on_register specialist_documents_on_register_document_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents_on_register
    ADD CONSTRAINT specialist_documents_on_register_document_template_id_fkey FOREIGN KEY (document_template_id) REFERENCES public.document_templates(id);


--
-- Name: specialist_documents specialist_documents_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents
    ADD CONSTRAINT specialist_documents_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: specialist_documents specialist_documents_template_att_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_documents
    ADD CONSTRAINT specialist_documents_template_att_id_fkey FOREIGN KEY (template_att_id) REFERENCES public.attachments(id);


--
-- Name: specialist_period_salaries specialist_period_salaries_studio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salaries
    ADD CONSTRAINT specialist_period_salaries_studio_id_fkey FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: specialist_period_salary_details specialist_period_salary_detai_specialist_period_salary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salary_details
    ADD CONSTRAINT specialist_period_salary_detai_specialist_period_salary_id_fkey FOREIGN KEY (specialist_period_salary_id) REFERENCES public.specialist_period_salaries(id);


--
-- Name: specialist_period_salary_details specialist_period_salary_details_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salary_details
    ADD CONSTRAINT specialist_period_salary_details_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: specialist_period_salary_details specialist_period_salary_details_studio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_period_salary_details
    ADD CONSTRAINT specialist_period_salary_details_studio_id_fkey FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: specialist_receipts specialist_receipts_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_receipts
    ADD CONSTRAINT specialist_receipts_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: specialist_receipts specialist_receipts_specialist_period_salary_detail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_receipts
    ADD CONSTRAINT specialist_receipts_specialist_period_salary_detail_id_fkey FOREIGN KEY (specialist_period_salary_detail_id) REFERENCES public.specialist_period_salary_details(id);


--
-- Name: specialist_regs specialist_regs_studio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_regs
    ADD CONSTRAINT specialist_regs_studio_id_fkey FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: specialist_salary_debets specialist_salary_debets_salary_debet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_debets
    ADD CONSTRAINT specialist_salary_debets_salary_debet_id_fkey FOREIGN KEY (salary_debet_id) REFERENCES public.salary_debets(id);


--
-- Name: specialist_salary_debets specialist_salary_debets_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_debets
    ADD CONSTRAINT specialist_salary_debets_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: specialist_salary_kredits specialist_salary_kredits_salary_kredit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_kredits
    ADD CONSTRAINT specialist_salary_kredits_salary_kredit_id_fkey FOREIGN KEY (salary_kredit_id) REFERENCES public.salary_kredits(id);


--
-- Name: specialist_salary_kredits specialist_salary_kredits_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_salary_kredits
    ADD CONSTRAINT specialist_salary_kredits_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: specialist_statuses specialist_statuses_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_statuses
    ADD CONSTRAINT specialist_statuses_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: specialist_works specialist_works_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_works
    ADD CONSTRAINT specialist_works_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: specialist_works specialist_works_studio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialist_works
    ADD CONSTRAINT specialist_works_studio_id_fkey FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: specialists specialists_speciality_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialists
    ADD CONSTRAINT specialists_speciality_id_fkey FOREIGN KEY (speciality_id) REFERENCES public.specialities(id);


--
-- Name: specialists specialists_studio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialists
    ADD CONSTRAINT specialists_studio_id_fkey FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: specialists specialists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialists
    ADD CONSTRAINT specialists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: specialists specialists_ycl_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.specialists
    ADD CONSTRAINT specialists_ycl_staff_id_fkey FOREIGN KEY (ycl_staff_id) REFERENCES public.ycl_staff(id);


--
-- Name: studios studios_firm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.studios
    ADD CONSTRAINT studios_firm_id_fkey FOREIGN KEY (firm_id) REFERENCES public.firms(id);


--
-- Name: template_batch_items template_batch_items_studio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batch_items
    ADD CONSTRAINT template_batch_items_studio_id_fkey FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: template_batch_items template_batch_items_template_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batch_items
    ADD CONSTRAINT template_batch_items_template_batch_id_fkey FOREIGN KEY (template_batch_id) REFERENCES public.template_batches(id);


--
-- Name: template_batch_items template_batch_items_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batch_items
    ADD CONSTRAINT template_batch_items_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.document_templates(id);


--
-- Name: template_batches template_batches_studio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.template_batches
    ADD CONSTRAINT template_batches_studio_id_fkey FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: users users_time_zone_locale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_time_zone_locale_id_fkey FOREIGN KEY (time_zone_locale_id) REFERENCES public.time_zone_locales(id);


--
-- Name: ycl_transactions ycl_transactions_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_transactions
    ADD CONSTRAINT ycl_transactions_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: ycl_visits ycl_visits_specialist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nails
--

ALTER TABLE ONLY public.ycl_visits
    ADD CONSTRAINT ycl_visits_specialist_id_fkey FOREIGN KEY (specialist_id) REFERENCES public.specialists(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: FOREIGN SERVER ms; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON FOREIGN SERVER ms TO nails;


--
-- Name: TABLE bank_payments; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.bank_payments TO test;


--
-- Name: TABLE contacts; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.contacts TO test;


--
-- Name: TABLE document_templates; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.document_templates TO test;


--
-- Name: TABLE firms; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.firms TO test;


--
-- Name: TABLE posts; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.posts TO test;


--
-- Name: TABLE salary_debets; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.salary_debets TO test;


--
-- Name: TABLE salary_kredits; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.salary_kredits TO test;


--
-- Name: TABLE specialist_period_salaries; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_period_salaries TO test;


--
-- Name: TABLE specialist_period_salary_details; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_period_salary_details TO test;


--
-- Name: TABLE specialists; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialists TO test;


--
-- Name: TABLE specialities; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialities TO test;


--
-- Name: TABLE studios; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.studios TO test;


--
-- Name: TABLE template_batches; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.template_batches TO test;


--
-- Name: TABLE time_zone_locales; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.time_zone_locales TO test;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.users TO test;


--
-- Name: TABLE apps; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.apps TO test;


--
-- Name: TABLE attachments; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.attachments TO test;


--
-- Name: TABLE attachments_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.attachments_list TO test;


--
-- Name: TABLE bank_payments_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.bank_payments_list TO test;


--
-- Name: TABLE confirmation_status; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.confirmation_status TO test;


--
-- Name: TABLE const_doc_per_page_count; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_doc_per_page_count TO test;


--
-- Name: TABLE const_doc_per_page_count_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_doc_per_page_count_view TO test;


--
-- Name: TABLE const_email; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_email TO test;


--
-- Name: TABLE const_email_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_email_view TO test;


--
-- Name: TABLE const_grid_refresh_interval; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_grid_refresh_interval TO test;


--
-- Name: TABLE const_grid_refresh_interval_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_grid_refresh_interval_view TO test;


--
-- Name: TABLE const_join_contract; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_join_contract TO test;


--
-- Name: TABLE const_join_contract_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_join_contract_view TO test;


--
-- Name: TABLE const_person_tax; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_person_tax TO test;


--
-- Name: TABLE const_person_tax_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_person_tax_view TO test;


--
-- Name: TABLE const_specialist_pay_comment_template; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_specialist_pay_comment_template TO test;


--
-- Name: TABLE const_specialist_pay_comment_template_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_specialist_pay_comment_template_view TO test;


--
-- Name: TABLE const_specialist_services; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_specialist_services TO test;


--
-- Name: TABLE const_specialist_services_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.const_specialist_services_view TO test;


--
-- Name: TABLE constants_list_view; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.constants_list_view TO test;


--
-- Name: TABLE contacts_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.contacts_dialog TO test;


--
-- Name: TABLE contacts_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.contacts_list TO test;


--
-- Name: TABLE document_templates_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.document_templates_dialog TO test;


--
-- Name: TABLE document_templates_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.document_templates_list TO test;


--
-- Name: TABLE entity_contacts; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.entity_contacts TO test;


--
-- Name: TABLE entity_contacts_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.entity_contacts_list TO test;


--
-- Name: TABLE equipment_types; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.equipment_types TO test;


--
-- Name: TABLE firms_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.firms_dialog TO test;


--
-- Name: TABLE firms_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.firms_list TO test;


--
-- Name: TABLE items; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.items TO test;


--
-- Name: TABLE logger; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.logger TO test;


--
-- Name: TABLE login_device_bans; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.login_device_bans TO test;


--
-- Name: TABLE logins; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.logins TO test;


--
-- Name: TABLE login_devices_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.login_devices_list TO test;


--
-- Name: TABLE logins_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.logins_list TO test;


--
-- Name: TABLE mail_senders; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.mail_senders TO test;


--
-- Name: TABLE main_menus; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.main_menus TO test;


--
-- Name: TABLE main_menus_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.main_menus_dialog TO test;


--
-- Name: TABLE main_menus_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.main_menus_list TO test;


--
-- Name: TABLE notif_templates; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.notif_templates TO test;


--
-- Name: TABLE notif_templates_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.notif_templates_list TO test;


--
-- Name: TABLE permissions; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.permissions TO test;


--
-- Name: TABLE session_vals; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.session_vals TO test;


--
-- Name: TABLE specialist_documents; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_documents TO test;


--
-- Name: TABLE specialist_documents_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_documents_list TO test;


--
-- Name: TABLE specialist_documents_for_sign_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_documents_for_sign_list TO test;


--
-- Name: TABLE specialist_documents_on_register; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_documents_on_register TO test;


--
-- Name: TABLE specialist_documents_on_register_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_documents_on_register_list TO test;


--
-- Name: TABLE specialist_period_salaries_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_period_salaries_list TO test;


--
-- Name: TABLE specialist_receipts; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_receipts TO test;


--
-- Name: TABLE specialist_period_salary_details_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_period_salary_details_list TO test;


--
-- Name: TABLE specialist_regs; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_regs TO test;


--
-- Name: TABLE user_operations; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.user_operations TO test;


--
-- Name: TABLE specialist_regs_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_regs_dialog TO test;


--
-- Name: TABLE specialist_regs_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_regs_list TO test;


--
-- Name: TABLE specialist_salary_debets; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_salary_debets TO test;


--
-- Name: TABLE specialist_salary_debets_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_salary_debets_list TO test;


--
-- Name: TABLE specialist_salary_kredits; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_salary_kredits TO test;


--
-- Name: TABLE specialist_salary_kredits_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_salary_kredits_list TO test;


--
-- Name: TABLE specialist_statuses; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_statuses TO test;


--
-- Name: TABLE specialist_works; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_works TO test;


--
-- Name: TABLE specialist_works_for_rate_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_works_for_rate_list TO test;


--
-- Name: TABLE ycl_transactions; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.ycl_transactions TO test;


--
-- Name: TABLE ycl_transactions_doc_all_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.ycl_transactions_doc_all_list TO test;


--
-- Name: TABLE specialist_works_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialist_works_list TO test;


--
-- Name: TABLE specialists_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialists_dialog TO test;


--
-- Name: TABLE specialists_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialists_list TO test;


--
-- Name: TABLE specialities_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialities_dialog TO test;


--
-- Name: TABLE specialities_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.specialities_list TO test;


--
-- Name: TABLE studios_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.studios_dialog TO test;


--
-- Name: TABLE studios_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.studios_list TO test;


--
-- Name: TABLE template_batch_items; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.template_batch_items TO test;


--
-- Name: TABLE template_batch_items_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.template_batch_items_list TO test;


--
-- Name: TABLE user_operations_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.user_operations_dialog TO test;


--
-- Name: TABLE users_dialog; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.users_dialog TO test;


--
-- Name: TABLE users_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.users_list TO test;


--
-- Name: TABLE users_login; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.users_login TO test;


--
-- Name: TABLE users_profile; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.users_profile TO test;


--
-- Name: TABLE views; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.views TO test;


--
-- Name: TABLE views_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.views_list TO test;


--
-- Name: TABLE ycl_staff; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.ycl_staff TO test;


--
-- Name: TABLE ycl_staff_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.ycl_staff_list TO test;


--
-- Name: TABLE ycl_transactions_doc_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.ycl_transactions_doc_list TO test;


--
-- Name: TABLE ycl_transactions_list; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.ycl_transactions_list TO test;


--
-- Name: TABLE ycl_visits; Type: ACL; Schema: public; Owner: nails
--

GRANT SELECT ON TABLE public.ycl_visits TO test;


--
-- PostgreSQL database dump complete
--

