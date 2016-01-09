--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- Name: env_raise_exception(text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_raise_exception(p_errcode text, res_code text, param01 text DEFAULT NULL::text, param02 text DEFAULT NULL::text, param03 text DEFAULT NULL::text, param04 text DEFAULT NULL::text, param05 text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql STABLE COST 5
    AS $$
begin
  -- возбуждает исключение, заданное кодом p_errcode с текстом, заданным по коду сообщения res_code
  raise exception using message = env_resource_text_format(res_code, param01, param02, param03, param04, param05), ERRCODE = p_errcode;
end;
$$;


ALTER FUNCTION public.env_raise_exception(p_errcode text, res_code text, param01 text, param02 text, param03 text, param04 text, param05 text) OWNER TO postgres;

--
-- Name: FUNCTION env_raise_exception(p_errcode text, res_code text, param01 text, param02 text, param03 text, param04 text, param05 text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_raise_exception(p_errcode text, res_code text, param01 text, param02 text, param03 text, param04 text, param05 text) IS 'возбуждает исключение, заданное кодом p_errcode с текстом, заданным по коду сообщения res_code';


--
-- Name: env_raise_exception(integer, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_raise_exception(p_level integer, p_errcode text, res_code text, param01 text DEFAULT NULL::text, param02 text DEFAULT NULL::text, param03 text DEFAULT NULL::text, param04 text DEFAULT NULL::text, param05 text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql STABLE COST 5
    AS $$
declare
  r record;
begin
  -- возбуждает исключение или создает сообщение другого указанного уровня важности с текстом, заданным по коду сообщения
  -- DEBUG, LOG, INFO, NOTICE, WARNING, EXCEPTION
  select "DEBUG", "LOG", "INFO", "NOTICE", "WARNING", "EXCEPTION" into r from env_severity_level();
  case p_level
    when r."EXCEPTION" then 
      raise exception using message = env_resource_text_format(res_code, param01, param02, param03, param04, param05), ERRCODE = p_errcode;
    when r."WARNING" then 
      raise warning using message = env_resource_text_format(res_code, param01, param02, param03, param04, param05), ERRCODE = p_errcode;
    when r."NOTICE" then 
      raise notice using message = env_resource_text_format(res_code, param01, param02, param03, param04, param05), ERRCODE = p_errcode;
    when r."INFO" then 
      raise info using message = env_resource_text_format(res_code, param01, param02, param03, param04, param05), ERRCODE = p_errcode;
    when r."LOG" then 
      raise log using message = env_resource_text_format(res_code, param01, param02, param03, param04, param05), ERRCODE = p_errcode;
    when r."DEBUG" then 
      raise debug using message = env_resource_text_format(res_code, param01, param02, param03, param04, param05), ERRCODE = p_errcode;
    else
      -- 'ENV00001', 'unknown severity level %s'
      raise exception using message = env_resource_text_format('ENV00001', p_level::text), ERRCODE = p_errcode;
  end case;
end;
$$;


ALTER FUNCTION public.env_raise_exception(p_level integer, p_errcode text, res_code text, param01 text, param02 text, param03 text, param04 text, param05 text) OWNER TO postgres;

--
-- Name: FUNCTION env_raise_exception(p_level integer, p_errcode text, res_code text, param01 text, param02 text, param03 text, param04 text, param05 text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_raise_exception(p_level integer, p_errcode text, res_code text, param01 text, param02 text, param03 text, param04 text, param05 text) IS 'возбуждает исключение или создает сообщение другого указанного уровня важности с текстом, заданным по коду сообщения';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: i18_language; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE i18_language (
    id integer NOT NULL,
    name character varying(100),
    alpha2code character(2),
    alpha3code character(3),
    scope smallint
);


ALTER TABLE public.i18_language OWNER TO postgres;

--
-- Name: TABLE i18_language; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE i18_language IS 'Языки
http://www-01.sil.org/iso639-3/documentation.asp?id=aplha3code';


--
-- Name: COLUMN i18_language.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN i18_language.name IS 'Наименование языка';


--
-- Name: COLUMN i18_language.alpha2code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN i18_language.alpha2code IS 'ISO 639-1 alpha 2 code';


--
-- Name: COLUMN i18_language.alpha3code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN i18_language.alpha3code IS 'ISO 639-3 alpha 3 code';


--
-- Name: COLUMN i18_language.scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN i18_language.scope IS 'Scope of denotation for language identifiers
1=Individual languages
2=Macrolanguages
-Collections of languages
-Dialects
';


--
-- Name: i18_language_find_by_a2c(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_language_find_by_a2c(p_alpha2code character) RETURNS i18_language
    LANGUAGE plpgsql STABLE COST 5
    AS $$
declare
  res i18_language;
begin
  select *
    into strict res
   from i18_language
  where alpha2code = p_alpha2code;
  return res;
exception
  when NO_DATA_FOUND then
    --I1800001='language alpha2code=% not found (in i18_language)'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800001', p_alpha2code);
  when TOO_MANY_ROWS then
    --I1800002='language alpha2code=% not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800002', p_alpha2code);
end;
$$;


ALTER FUNCTION public.i18_language_find_by_a2c(p_alpha2code character) OWNER TO postgres;

--
-- Name: FUNCTION i18_language_find_by_a2c(p_alpha2code character); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_language_find_by_a2c(p_alpha2code character) IS 'возвращает строку языка по его 2-х символьному коду';


--
-- Name: env_resource_text; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE env_resource_text (
    id integer NOT NULL,
    content text,
    code character varying(10) NOT NULL,
    language_id integer DEFAULT (i18_language_find_by_a2c('en'::bpchar)).id NOT NULL
);


ALTER TABLE public.env_resource_text OWNER TO postgres;

--
-- Name: TABLE env_resource_text; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE env_resource_text IS 'тексты сообщений, предупреждений, ошибок системы';


--
-- Name: COLUMN env_resource_text.content; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN env_resource_text.content IS 'текст сообщения';


--
-- Name: COLUMN env_resource_text.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN env_resource_text.code IS 'символьный код сообщения';


--
-- Name: COLUMN env_resource_text.language_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN env_resource_text.language_id IS 'код языка';


--
-- Name: env_resource_text_create(character varying, text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_resource_text_create(p_code character varying, p_content text, p_language_id integer DEFAULT NULL::integer, p_id integer DEFAULT NULL::integer) RETURNS env_resource_text
    LANGUAGE plpgsql COST 1
    AS $$
declare
  --вставляет текст сообщения и возвращает вставленноую строку
  res  env_resource_text;
begin
  -- вставляем заголовок ресурса
  insert into env_resource (id, resource_kind_id)
  values (coalesce(p_id, nextval('env_resource_id_seq'::regclass)), 1) -- 1=текст
  returning id into res.id;
  -- вставляем тело текстового ресурса
  insert into env_resource_text (id, code, language_id, content)
  values (res.id, p_code, coalesce(p_language_id, (i18_language_find_by_a2c('en')::i18_language).id), p_content)
  returning * into res;
  return res;
end;
$$;


ALTER FUNCTION public.env_resource_text_create(p_code character varying, p_content text, p_language_id integer, p_id integer) OWNER TO postgres;

--
-- Name: FUNCTION env_resource_text_create(p_code character varying, p_content text, p_language_id integer, p_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_resource_text_create(p_code character varying, p_content text, p_language_id integer, p_id integer) IS 'вставляет текст сообщения и возвращает вставленноую строку';


--
-- Name: env_resource_text_find_by_code(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_resource_text_find_by_code(res_code text) RETURNS integer
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  res  integer;
begin
  select id
    into strict res
   from env_resource_text
  where code = res_code;
  return res;
exception
  when NO_DATA_FOUND then
    raise exception 'resource code=% not found (in env_resource_text)', res_code;
  when TOO_MANY_ROWS then
    raise exception 'resource code=% not unique', res_code;
end;

  
$$;


ALTER FUNCTION public.env_resource_text_find_by_code(res_code text) OWNER TO postgres;

--
-- Name: FUNCTION env_resource_text_find_by_code(res_code text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_resource_text_find_by_code(res_code text) IS 'возвращает идентификатор сообщения по его коду';


--
-- Name: env_resource_text_format(integer, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_resource_text_format(res_id integer, param01 text DEFAULT NULL::text, param02 text DEFAULT NULL::text, param03 text DEFAULT NULL::text, param04 text DEFAULT NULL::text, param05 text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  res_txt env_resource_text;
begin
  select *
    into strict res_txt
   from env_resource_text
  where id = res_id;
  return format(res_txt.content, param01, param02, param03, param04, param05);
exception
  when NO_DATA_FOUND then
    raise exception 'resource id=% not found (in env_resource_text). can not format resource text', res_id;
  when TOO_MANY_ROWS then
    raise exception 'resource id=% not unique', res_id;
end;

  
$$;


ALTER FUNCTION public.env_resource_text_format(res_id integer, param01 text, param02 text, param03 text, param04 text, param05 text) OWNER TO postgres;

--
-- Name: FUNCTION env_resource_text_format(res_id integer, param01 text, param02 text, param03 text, param04 text, param05 text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_resource_text_format(res_id integer, param01 text, param02 text, param03 text, param04 text, param05 text) IS 'возвращает текст сообщения по его коду и подставляет значения параметров вместо символов подстановки';


--
-- Name: env_resource_text_format(text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_resource_text_format(res_code text, param01 text DEFAULT NULL::text, param02 text DEFAULT NULL::text, param03 text DEFAULT NULL::text, param04 text DEFAULT NULL::text, param05 text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  res_txt env_resource_text;
begin
  select *
    into strict res_txt
   from env_resource_text
  where code = res_code;
  return format(res_txt.content, param01, param02, param03, param04, param05);
exception
  when NO_DATA_FOUND then
    raise exception 'resource code=% not found (in env_resource_text). can not format resource text', res_code;
  when TOO_MANY_ROWS then
    raise exception 'resource code=% not unique', res_code;
end;

  
$$;


ALTER FUNCTION public.env_resource_text_format(res_code text, param01 text, param02 text, param03 text, param04 text, param05 text) OWNER TO postgres;

--
-- Name: FUNCTION env_resource_text_format(res_code text, param01 text, param02 text, param03 text, param04 text, param05 text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_resource_text_format(res_code text, param01 text, param02 text, param03 text, param04 text, param05 text) IS 'возвращает текст сообщения по его коду и подставляет значения параметров вместо символов подстановки';


--
-- Name: env_resource_text_update(integer, character varying, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_resource_text_update(p_id integer, p_code character varying, p_language_id integer, p_content text) RETURNS env_resource_text
    LANGUAGE plpgsql COST 1
    AS $$
declare
  --обновляет текст сообщения и возвращает обновленную строку
  res  env_resource_text;
begin
  -- вставляем тело текстового ресурса
  update env_resource_text 
     set code = p_code, 
         language_id = p_language_id, 
         content = p_content
   where id = p_id
  returning * into res;
  return res;
end;
$$;


ALTER FUNCTION public.env_resource_text_update(p_id integer, p_code character varying, p_language_id integer, p_content text) OWNER TO postgres;

--
-- Name: FUNCTION env_resource_text_update(p_id integer, p_code character varying, p_language_id integer, p_content text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_resource_text_update(p_id integer, p_code character varying, p_language_id integer, p_content text) IS 'обновляет текст сообщения и возвращает обновленную строку';


--
-- Name: env_severity_level(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_severity_level(OUT "DEBUG" smallint, OUT "LOG" smallint, OUT "INFO" smallint, OUT "NOTICE" smallint, OUT "WARNING" smallint, OUT "EXCEPTION" smallint) RETURNS record
    LANGUAGE plpgsql IMMUTABLE COST 1
    AS $$
begin
  -- возвращает константные значения уровней важности сообщений
  -- DEBUG, LOG, INFO, NOTICE, WARNING, EXCEPTION
  "EXCEPTION" := 0;
  "WARNING" := 1;
  "NOTICE" := 2;
  "INFO" := 3;
  "LOG" := 4;
  "DEBUG" := 5;
  return;
end;
$$;


ALTER FUNCTION public.env_severity_level(OUT "DEBUG" smallint, OUT "LOG" smallint, OUT "INFO" smallint, OUT "NOTICE" smallint, OUT "WARNING" smallint, OUT "EXCEPTION" smallint) OWNER TO postgres;

--
-- Name: FUNCTION env_severity_level(OUT "DEBUG" smallint, OUT "LOG" smallint, OUT "INFO" smallint, OUT "NOTICE" smallint, OUT "WARNING" smallint, OUT "EXCEPTION" smallint); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_severity_level(OUT "DEBUG" smallint, OUT "LOG" smallint, OUT "INFO" smallint, OUT "NOTICE" smallint, OUT "WARNING" smallint, OUT "EXCEPTION" smallint) IS 'возвращает константные значения уровней важности сообщений';


--
-- Name: env_text_similar(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION env_text_similar(word1 text, word2 text, min_sim_len integer DEFAULT 5) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE COST 2
    AS $_$declare
  -- сравнивает две строки (word1, word2) на сходство (без учета регистра символов). возвращает true, если две строки схожи и false - в противном случае.
  -- строки считаются схожими, если у них есть общие части текста (последовательность символов не менее min_len символов)
begin
  if (word1 is not null) and (word2 is not null) then
    -- сравниваем без учета регистра символов
    word1 := lower(word1);
    word2 := lower(word2);
    -- ищем вхождение фрагментов строки word1 в строке word2
    for i in 1 .. char_length(word1)-min_sim_len loop
      -- если вхождение найдено
      if position(substring(word1 from i for min_sim_len) in word2) > 0 then
        -- 'RES00003', 'text "%1$s" is similar to "%2$s"'
        return env_resource_text_find_by_code('RES00003');
      end if;
    end loop;
    -- ищем вхождение фрагментов строки word2 в строке word1
    for i in 1 .. char_length(word2)-min_sim_len loop
      -- если вхождение найдено
      if position(substring(word2 from i for min_sim_len) in word1) > 0 then
        -- 'RES00003', 'text "%1$s" is similar to "%2$s"'
        return env_resource_text_find_by_code('RES00003');
      end if;
    end loop;
  end if;
  -- 'RES00004', 'text "%1$s" is not similar to "%2$s"'
  return env_resource_text_find_by_code('RES00004');
end;
$_$;


ALTER FUNCTION public.env_text_similar(word1 text, word2 text, min_sim_len integer) OWNER TO postgres;

--
-- Name: FUNCTION env_text_similar(word1 text, word2 text, min_sim_len integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION env_text_similar(word1 text, word2 text, min_sim_len integer) IS 'сравнивает две строки (word1, word2) на сходство (без учета регистра символов). возвращает true, если две строки схожи и false - в противном случае.
строки считаются схожими, если у них есть общие части текста (последовательность символов не менее min_len символов)';


--
-- Name: i18_country; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE i18_country (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    number3code integer,
    alpha2code character(2),
    alpha3code character(3)
);


ALTER TABLE public.i18_country OWNER TO postgres;

--
-- Name: TABLE i18_country; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE i18_country IS 'Страны';


--
-- Name: COLUMN i18_country.number3code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN i18_country.number3code IS 'ISO 3166 Number3 code';


--
-- Name: COLUMN i18_country.alpha2code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN i18_country.alpha2code IS 'ISO 3166 Alpha2 code';


--
-- Name: COLUMN i18_country.alpha3code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN i18_country.alpha3code IS 'ISO 3166 Alpha3 code';


--
-- Name: i18_country_find_by_a23c(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_country_find_by_a23c(p_alpha23code character) RETURNS i18_country
    LANGUAGE plpgsql STABLE COST 5
    AS $$
-- возвращает строку страны по её 2-3 символьному коду ISO 3166 Alpha2/Alpha3 code
declare
  res i18_country;
begin
  select *
    into strict res
   from i18_country
  where p_alpha23code in (alpha2code, alpha3code);
  return res;
exception
  when NO_DATA_FOUND then
    --'I1800013', 'country alpha2code or alpha3code "%s" not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800013', p_alpha23code);
  when TOO_MANY_ROWS then
    --'I1800014', 'country alpha2code or alpha3code "%s" not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800014', p_alpha23code);
end;
$$;


ALTER FUNCTION public.i18_country_find_by_a23c(p_alpha23code character) OWNER TO postgres;

--
-- Name: FUNCTION i18_country_find_by_a23c(p_alpha23code character); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_country_find_by_a23c(p_alpha23code character) IS 'возвращает строку страны по её 2-3 символьному коду ISO 3166 Alpha2/Alpha3 code';


--
-- Name: i18_country_find_by_a2c(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_country_find_by_a2c(p_alpha2code character) RETURNS i18_country
    LANGUAGE plpgsql STABLE COST 5
    AS $$
-- возвращает строку страны по её 2-х символьному коду ISO 3166 Alpha2 code
declare
  res i18_country;
begin
  select *
    into strict res
   from i18_country
  where alpha2code = p_alpha2code;
  return res;
exception
  when NO_DATA_FOUND then
    --'I1800005', 'country alpha2code=%s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800005', p_alpha2code);
  when TOO_MANY_ROWS then
    --'I1800006', 'country alpha2code=%s not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800006', p_alpha2code);
end;
$$;


ALTER FUNCTION public.i18_country_find_by_a2c(p_alpha2code character) OWNER TO postgres;

--
-- Name: FUNCTION i18_country_find_by_a2c(p_alpha2code character); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_country_find_by_a2c(p_alpha2code character) IS 'возвращает строку страны по её 2-х символьному коду ISO 3166 Alpha2 code';


--
-- Name: i18_country_find_by_a3c(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_country_find_by_a3c(p_alpha3code character) RETURNS i18_country
    LANGUAGE plpgsql STABLE COST 5
    AS $$
-- возвращает строку страны по её 3-х символьному коду ISO 3166 Alpha3 code
declare
  res i18_country;
begin
  select *
    into strict res
   from i18_country
  where alpha3code = p_alpha3code;
  return res;
exception
  when NO_DATA_FOUND then
    --'I1800007', 'country alpha3code=%s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800007', p_alpha3code);
  when TOO_MANY_ROWS then
    --'I1800008', 'country alpha3code=%s not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800008', p_alpha3code);
end;
$$;


ALTER FUNCTION public.i18_country_find_by_a3c(p_alpha3code character) OWNER TO postgres;

--
-- Name: FUNCTION i18_country_find_by_a3c(p_alpha3code character); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_country_find_by_a3c(p_alpha3code character) IS 'возвращает строку страны по её 3-х символьному коду ISO 3166 Alpha3 code';


--
-- Name: i18_country_find_by_n3c(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_country_find_by_n3c(p_number3code integer) RETURNS i18_country
    LANGUAGE plpgsql STABLE COST 5
    AS $$
-- возвращает строку страны по её 3-х значному цифровому коду ISO 3166 Number3 code
declare
  res i18_country;
begin
  select *
    into strict res
   from i18_country
  where number3code = p_number3code;
  return res;
exception
  when NO_DATA_FOUND then
    --'I1800009', 'country number3code=%s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800009', p_number3code::text);
  when TOO_MANY_ROWS then
    --'I1800010', 'country number3code=%s not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800010', p_number3code::text);
end;
$$;


ALTER FUNCTION public.i18_country_find_by_n3c(p_number3code integer) OWNER TO postgres;

--
-- Name: FUNCTION i18_country_find_by_n3c(p_number3code integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_country_find_by_n3c(p_number3code integer) IS 'возвращает строку страны по её 3-х значному цифровому коду ISO 3166 Number3 code';


--
-- Name: i18_country_find_by_name(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_country_find_by_name(p_name text) RETURNS i18_country
    LANGUAGE plpgsql STABLE COST 5
    AS $$
-- возвращает строку страны по её наименованию
declare
  res i18_country;
begin
  select *
    into strict res
   from i18_country
  where upper(trim(both from name)) = upper(trim(both from p_name));
  return res;
exception
  when NO_DATA_FOUND then
    --'I1800011', 'country name=%s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800011', p_name);
  when TOO_MANY_ROWS then
    --'I1800012', 'country name=%s not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800012', p_name);
end;
$$;


ALTER FUNCTION public.i18_country_find_by_name(p_name text) OWNER TO postgres;

--
-- Name: FUNCTION i18_country_find_by_name(p_name text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_country_find_by_name(p_name text) IS 'возвращает строку страны по её наименованию';


--
-- Name: i18_language_find_by_a23c(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_language_find_by_a23c(p_alpha23code character) RETURNS i18_language
    LANGUAGE plpgsql STABLE COST 5
    AS $$
declare
  res i18_language;
begin
  select *
    into strict res
   from i18_language
  where p_alpha23code in (alpha2code, alpha3code);
  return res;
exception
  when NO_DATA_FOUND then
    --'I1800015', 'language alpha2code or alpha3code "%s" not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800015', p_alpha23code);
  when TOO_MANY_ROWS then
    --'I1800016', 'language alpha2code or alpha3code "%s" not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800016', p_alpha23code);
end;
$$;


ALTER FUNCTION public.i18_language_find_by_a23c(p_alpha23code character) OWNER TO postgres;

--
-- Name: FUNCTION i18_language_find_by_a23c(p_alpha23code character); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_language_find_by_a23c(p_alpha23code character) IS 'возвращает строку языка по его 2-3 символьному коду';


--
-- Name: i18_language_find_by_a3c(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION i18_language_find_by_a3c(p_alpha3code character) RETURNS i18_language
    LANGUAGE plpgsql STABLE COST 5
    AS $$
declare
  res i18_language;
begin
  select *
    into strict res
   from i18_language
  where alpha3code = p_alpha3code;
  return res;
exception
  when NO_DATA_FOUND then
    -- 'I1800003', 'language alpha3code=% not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('I1800003', p_alpha3code);
  when TOO_MANY_ROWS then
    -- 'I1800004', 'language alpha3code=% not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('I1800004', p_alpha3code);
end;
$$;


ALTER FUNCTION public.i18_language_find_by_a3c(p_alpha3code character) OWNER TO postgres;

--
-- Name: FUNCTION i18_language_find_by_a3c(p_alpha3code character); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION i18_language_find_by_a3c(p_alpha3code character) IS 'возвращает строку языка по его 3-х символьному коду';


--
-- Name: lml_event; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE lml_event (
    id integer NOT NULL,
    name text,
    class_id integer NOT NULL
);


ALTER TABLE public.lml_event OWNER TO postgres;

--
-- Name: COLUMN lml_event.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN lml_event.id IS 'идентификатор события';


--
-- Name: COLUMN lml_event.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN lml_event.name IS 'наименование';


--
-- Name: COLUMN lml_event.class_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN lml_event.class_id IS 'тип класса/сущности';


--
-- Name: lml_event(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION lml_event(p_class_name text, p_event_name text) RETURNS lml_event
    LANGUAGE plpgsql COST 1
    AS $_$
declare
  -- ищет код события по его имени и имени класса
  res      lml_event;
begin
  select e.*
    into strict res
    from lml_class c,
         lml_event e
   where e.class_id = c.id
     and c.name = p_class_name
     and e.name = p_event_name;
  return res;
exception
  when NO_DATA_FOUND then
    -- 'ENV00002', 'event %2$s not found in class %1$s'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('ENV00002', p_class_name, p_event_name);
    --execute env_raise_exception('P0002', 'ENV00002', p_class_name, p_event_name);
  when TOO_MANY_ROWS then
    -- 'ENV00003', 'event %2$s not unique in class %1$s'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('ENV00003', p_class_name, p_event_name);
    --execute env_raise_exception('23505', 'ENV00003', p_class_name, p_event_name);
end;
$_$;


ALTER FUNCTION public.lml_event(p_class_name text, p_event_name text) OWNER TO postgres;

--
-- Name: lml_event_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION lml_event_status(OUT "STARTED" smallint, OUT "PROCESSING" smallint, OUT "ENDED" smallint) RETURNS record
    LANGUAGE plpgsql IMMUTABLE COST 1
    AS $$
begin
  -- возвращает константные значения статусов событий
  -- STARTED, PROCESSED, ENDED
  "STARTED" := 1;
  "PROCESSING" := 2;
  "ENDED" := 3;
  return;
end;
$$;


ALTER FUNCTION public.lml_event_status(OUT "STARTED" smallint, OUT "PROCESSING" smallint, OUT "ENDED" smallint) OWNER TO postgres;

--
-- Name: FUNCTION lml_event_status(OUT "STARTED" smallint, OUT "PROCESSING" smallint, OUT "ENDED" smallint); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION lml_event_status(OUT "STARTED" smallint, OUT "PROCESSING" smallint, OUT "ENDED" smallint) IS 'возвращает константные значения статусов событий';


--
-- Name: mdd_class_del(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mdd_class_del("pCLASSID" bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
  c mdd_class;
begin
  delete from mdd_class_extention
   where class_id = "pCLASSID";
  --
  delete from mdd_class 
   where id = "pCLASSID"
  returning * into c;
  --
  return c.ID;
end;$$;


ALTER FUNCTION public.mdd_class_del("pCLASSID" bigint) OWNER TO postgres;

--
-- Name: mdd_class_ins(bigint, bigint, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mdd_class_ins("pCLASSID" bigint, "pBASECLASSID" bigint, "pNAME" character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
  c mdd_class;
begin
  insert into mdd_class (id, name)
  values (coalesce("pCLASSID", nextval('mdd_class_sq')), "pNAME")
  returning * into c;
  --
  if ("pBASECLASSID" is not null) then
    insert into mdd_class_extention (class_id, base_class_id)
    values (c.ID, "pBASECLASSID");
  end if;
  --
  return c.ID;
end;$$;


ALTER FUNCTION public.mdd_class_ins("pCLASSID" bigint, "pBASECLASSID" bigint, "pNAME" character varying) OWNER TO postgres;

--
-- Name: mdd_class_upd(bigint, bigint, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mdd_class_upd("pCLASSID" bigint, "pBASECLASSID" bigint, "pNAME" character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
  c mdd_class;
begin
  update mdd_class 
     set name = "pNAME"
   where id = "pCLASSID"
  returning * into c;
  --
  update mdd_class_extention
     set base_class_id = "pBASECLASSID"
   where class_id = "pCLASSID";
  --
  return c.ID;
end;$$;


ALTER FUNCTION public.mdd_class_upd("pCLASSID" bigint, "pBASECLASSID" bigint, "pNAME" character varying) OWNER TO postgres;

--
-- Name: prs_person; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE prs_person (
    id integer NOT NULL,
    citizenship_country_id integer,
    language_id integer,
    person_kind_id smallint
);


ALTER TABLE public.prs_person OWNER TO postgres;

--
-- Name: TABLE prs_person; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE prs_person IS 'физ. и юр.лица';


--
-- Name: COLUMN prs_person.citizenship_country_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person.citizenship_country_id IS 'гражданство, национальная принадлежность, подданство';


--
-- Name: COLUMN prs_person.language_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person.language_id IS 'родной (основной) язык для общения';


--
-- Name: COLUMN prs_person.person_kind_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person.person_kind_id IS 'тип персоны';


--
-- Name: prs_person_create(integer, text, smallint, character, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION prs_person_create(p_session_id integer, p_name text, p_person_kind_id smallint DEFAULT NULL::smallint, p_citizenship_country_alpha23code character DEFAULT NULL::character(1), p_language_alpha23code character DEFAULT NULL::character(1)) RETURNS prs_person
    LANGUAGE plpgsql COST 30
    AS $$declare
  -- создание персоны (физ./юр. лица)
  l_person  prs_person;
  ok        boolean;
begin
  -- тип физ./юр. лица по умолчанию - "не указано"
  select id into l_person.person_kind_id from prs_person_kind_find_by_id(coalesce(p_person_kind_id, (prs_person_kind())."UNDEFINED"));
  -- гражданство, национальная принадлежность, подданство страна физ./юр. лица по умолчанию - Россия
  select id into l_person.citizenship_country_id from i18_country_find_by_a23c(coalesce(p_citizenship_country_alpha23code, 'RUS'));
  -- родной (основной) язык для физ./юр. лица по умолчанию - русский
  select id into l_person.language_id from i18_language_find_by_a23c(coalesce(p_language_alpha23code, 'rus'));
  -- наличие полномочий на выполнение операции
  select sec_session_has_permission(p_session_id, 'prs_person.create') into ok;
  if (not ok) then
    -- нет полномочий 
    -- 'SEC00004', 'access denied. has no permission (%s)'
    raise exception insufficient_privilege using message = env_resource_text_format('SEC00004', 'prs_person.create');
  end if;
  -- полномочий достаточно
  insert into prs_person (id, person_kind_id, language_id, citizenship_country_id)
  values (default, l_person.person_kind_id, l_person.language_id, l_person.citizenship_country_id)
  returning * into l_person;
  if (l_person.person_kind_id = (prs_person_kind())."INDIVIDUAL") then -- физическое лицо
    insert into prs_person_individual (person_id, last_name, middle_name, first_name, birthdate)
    values (l_person.id, null, null, p_name, null);
  elsif (l_person.person_kind_id = (prs_person_kind())."LEGAL") then -- юридическое лицо
    insert into prs_person_legal (person_id, name_short, name_long)
    values (l_person.id, p_name, p_name);
  end if;
  return l_person;
end;
$$;


ALTER FUNCTION public.prs_person_create(p_session_id integer, p_name text, p_person_kind_id smallint, p_citizenship_country_alpha23code character, p_language_alpha23code character) OWNER TO postgres;

--
-- Name: FUNCTION prs_person_create(p_session_id integer, p_name text, p_person_kind_id smallint, p_citizenship_country_alpha23code character, p_language_alpha23code character); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION prs_person_create(p_session_id integer, p_name text, p_person_kind_id smallint, p_citizenship_country_alpha23code character, p_language_alpha23code character) IS 'создание персоны (физ./юр. лица)';


--
-- Name: prs_person_kind(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION prs_person_kind(OUT "UNDEFINED" smallint, OUT "INDIVIDUAL" smallint, OUT "LEGAL" smallint) RETURNS record
    LANGUAGE plpgsql IMMUTABLE COST 1
    AS $$
begin
  -- возвращает константные значения типа персоны (физ./юр. лицо)
  "UNDEFINED" := 0; -- не указано
  "INDIVIDUAL" := 1; -- физическое лицо
  "LEGAL" := 2; -- юридическое лицо
  return;
end;
$$;


ALTER FUNCTION public.prs_person_kind(OUT "UNDEFINED" smallint, OUT "INDIVIDUAL" smallint, OUT "LEGAL" smallint) OWNER TO postgres;

--
-- Name: FUNCTION prs_person_kind(OUT "UNDEFINED" smallint, OUT "INDIVIDUAL" smallint, OUT "LEGAL" smallint); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION prs_person_kind(OUT "UNDEFINED" smallint, OUT "INDIVIDUAL" smallint, OUT "LEGAL" smallint) IS 'возвращает константные значения типа персоны (физ./юр. лицо)';


--
-- Name: prs_person_kind; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE prs_person_kind (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.prs_person_kind OWNER TO postgres;

--
-- Name: TABLE prs_person_kind; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE prs_person_kind IS 'тип персоны (физ./юр. лица)';


--
-- Name: COLUMN prs_person_kind.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_kind.id IS 'идентификатор';


--
-- Name: COLUMN prs_person_kind.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_kind.name IS 'наименование';


--
-- Name: prs_person_kind_find_by_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION prs_person_kind_find_by_id(p_id integer) RETURNS prs_person_kind
    LANGUAGE plpgsql STABLE COST 5
    AS $$
-- возвращает тип персоны по его коду. 
declare
  res prs_person_kind;
begin
  select *
    into strict res
   from prs_person_kind
  where id = p_id;
  return res;
exception
  when NO_DATA_FOUND then
    --'PRS00001', 'person kind id=%s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('PRS00001', p_id::text);
  when TOO_MANY_ROWS then
    --'PRS00002', 'person kind id=%s not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('PRS00002', p_id::text);
end;
$$;


ALTER FUNCTION public.prs_person_kind_find_by_id(p_id integer) OWNER TO postgres;

--
-- Name: FUNCTION prs_person_kind_find_by_id(p_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION prs_person_kind_find_by_id(p_id integer) IS 'возвращает тип персоны по его коду.';


--
-- Name: sec_authentication_kind_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sec_authentication_kind_id_seq
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_authentication_kind_id_seq OWNER TO postgres;

--
-- Name: sec_authentication_kind; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_authentication_kind (
    id integer DEFAULT nextval('sec_authentication_kind_id_seq'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(25)
);


ALTER TABLE public.sec_authentication_kind OWNER TO postgres;

--
-- Name: TABLE sec_authentication_kind; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sec_authentication_kind IS 'схемы, виды аутентификации';


--
-- Name: sec_authentication_kind_add(integer, sec_authentication_kind); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_authentication_kind_add(p_session_id integer, p_row sec_authentication_kind) RETURNS sec_authentication_kind
    LANGUAGE plpgsql COST 5
    AS $$declare
  -- добавление схемы аутентификации. возвращает добавленную строку.
  res  sec_authentication_kind;
begin
  -- проверка полномочий на выполнение операции
  perform sec_session_require_permission(p_session_id, 'sec_authentication_kind.add');
  -- регистрируем событие
  perform sec_event_log_start(p_session_id, 'sec_authentication_kind', 'add', xmlforest(p_row));
  -- добавляем строку
  p_row.id := coalesce(p_row.id, nextval('sec_authentication_kind_id_seq'::regclass));
  insert into sec_authentication_kind 
  values (p_row.*)
  returning * into res;
  return res;
end;
$$;


ALTER FUNCTION public.sec_authentication_kind_add(p_session_id integer, p_row sec_authentication_kind) OWNER TO postgres;

--
-- Name: FUNCTION sec_authentication_kind_add(p_session_id integer, p_row sec_authentication_kind); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_authentication_kind_add(p_session_id integer, p_row sec_authentication_kind) IS 'добавление схемы аутентификации. возвращает добавленную строку.';


--
-- Name: sec_authentication_kind_by_code(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_authentication_kind_by_code(p_code text) RETURNS sec_authentication_kind
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  -- поиск схемы аутентификации по её коду. возвращает строку, если такая найдена.
  -- если не найдена или найдено несколько с таким кодом, возбуждает исключение
  res  sec_authentication_kind;
begin
  select *
    into STRICT res
    from sec_authentication_kind
   where upper(code) = upper(trim(both from p_code));
   return res;
exception
  when NO_DATA_FOUND then
    -- 'SEC00033', 'authentication kind not found by code "%s"'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00033', p_code);
  when TOO_MANY_ROWS then
    -- 'SEC00034', 'authentication kind not unique by code "%s"'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('SEC00034', p_code);
end;
$$;


ALTER FUNCTION public.sec_authentication_kind_by_code(p_code text) OWNER TO postgres;

--
-- Name: FUNCTION sec_authentication_kind_by_code(p_code text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_authentication_kind_by_code(p_code text) IS 'поиск схемы аутентификации по её коду. возвращает строку, если такая найдена. если не найдена или найдено несколько с таким кодом, возбуждает исключение';


--
-- Name: sec_authentication_kind_by_name(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_authentication_kind_by_name(p_name text) RETURNS sec_authentication_kind
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  -- поиск схемы аутентификации по её имени. возвращает строку, если такая найдена.
  -- если не найдена или найдено несколько с таким именем, возбуждает исключение
  res  sec_authentication_kind;
begin
  select *
    into STRICT res
    from sec_authentication_kind
   where upper(u.name) = upper(trim(both from p_name));
   return res;
exception
  when NO_DATA_FOUND then
    -- 'SEC00031', 'authentication kind not found by name "%s"'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00031', p_name);
  when TOO_MANY_ROWS then
    -- 'SEC00032', 'authentication kind not unique by name "%s"'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('SEC00032', p_name);
end;
$$;


ALTER FUNCTION public.sec_authentication_kind_by_name(p_name text) OWNER TO postgres;

--
-- Name: FUNCTION sec_authentication_kind_by_name(p_name text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_authentication_kind_by_name(p_name text) IS 'поиск схемы аутентификации по её имени. возвращает строку, если такая найдена. если не найдена или найдено несколько с таким именем, возбуждает исключение';


--
-- Name: sec_authentication_kind_del(integer, sec_authentication_kind); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_authentication_kind_del(p_session_id integer, p_row sec_authentication_kind) RETURNS sec_authentication_kind
    LANGUAGE plpgsql COST 5
    AS $$declare
  -- удаление схемы аутентификации. возвращает удаленную строку.
  res  sec_authentication_kind;
begin
  -- проверка полномочий на выполнение операции
  perform sec_session_require_permission(p_session_id, 'sec_authentication_kind.del');
  -- регистрируем событие
  perform sec_event_log_start(p_session_id, 'sec_authentication_kind', 'del', xmlforest(p_row));
  -- удаляем строку
  delete from sec_authentication_kind 
   where id = p_row.id
  returning * into res;
  return res;
end;
$$;


ALTER FUNCTION public.sec_authentication_kind_del(p_session_id integer, p_row sec_authentication_kind) OWNER TO postgres;

--
-- Name: FUNCTION sec_authentication_kind_del(p_session_id integer, p_row sec_authentication_kind); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_authentication_kind_del(p_session_id integer, p_row sec_authentication_kind) IS 'удаление схемы аутентификации. возвращает удаленную строку.';


--
-- Name: sec_authentication_kind_upd(integer, sec_authentication_kind); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_authentication_kind_upd(p_session_id integer, p_row sec_authentication_kind) RETURNS sec_authentication_kind
    LANGUAGE plpgsql COST 5
    AS $$declare
  -- обновление схемы аутентификации. возвращает обновленную строку.
  res  sec_authentication_kind;
begin
  -- проверка полномочий на выполнение операции
  perform sec_session_require_permission(p_session_id, 'sec_authentication_kind.upd');
  -- регистрируем событие
  perform sec_event_log_start(p_session_id, 'sec_authentication_kind', 'upd', xmlforest(p_row));
  -- обновляем строку
  update sec_authentication_kind 
     set name = p_row.name,
         code = p_row.code
   where id = p_row.id
  returning * into res;
  return res;
end;
$$;


ALTER FUNCTION public.sec_authentication_kind_upd(p_session_id integer, p_row sec_authentication_kind) OWNER TO postgres;

--
-- Name: FUNCTION sec_authentication_kind_upd(p_session_id integer, p_row sec_authentication_kind); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_authentication_kind_upd(p_session_id integer, p_row sec_authentication_kind) IS 'обновление схемы аутентификации. возвращает обновленную строку.';


--
-- Name: sec_authentication_path; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_authentication_path (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    authentication_kind_id integer NOT NULL,
    credential_kind character varying(50),
    application_id integer,
    credential_hash_kind text
);


ALTER TABLE public.sec_authentication_path OWNER TO postgres;

--
-- Name: TABLE sec_authentication_path; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sec_authentication_path IS 'методы, способы и источники проверки аутентификации';


--
-- Name: COLUMN sec_authentication_path.application_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_authentication_path.application_id IS 'id приложения';


--
-- Name: COLUMN sec_authentication_path.credential_hash_kind; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_authentication_path.credential_hash_kind IS 'Вид хеша учетных данных';


--
-- Name: sec_authentication_path_by_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_authentication_path_by_id(p_auth_path_id integer) RETURNS sec_authentication_path
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  -- возвращает строку по идентификатору
  l_ap       sec_authentication_path;
begin
  select *
    into strict l_ap
    from sec_authentication_path ap
   where id = p_auth_path_id;
  return l_ap;
exception
  when NO_DATA_FOUND then
    -- 'SEC00011', 'authentication path id (%s) found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00011', p_auth_path_id::text);
  when TOO_MANY_ROWS then
    -- 'SEC00012', 'authentication path id (%s) not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('SEC00012', p_auth_path_id::text);
end;
$$;


ALTER FUNCTION public.sec_authentication_path_by_id(p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_authentication_path_by_id(p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_authentication_path_by_id(p_auth_path_id integer) IS 'возвращает строку по идентификатору';


--
-- Name: sec_event_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_event_log (
    whenfired timestamp with time zone NOT NULL,
    event_kind integer NOT NULL,
    event_status integer NOT NULL,
    session_id integer NOT NULL,
    context xml,
    user_name text,
    auth_path_id integer,
    tokenvalue text
);


ALTER TABLE public.sec_event_log OWNER TO postgres;

--
-- Name: COLUMN sec_event_log.whenfired; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_event_log.whenfired IS 'дата/вермя начала события';


--
-- Name: COLUMN sec_event_log.event_kind; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_event_log.event_kind IS 'тип события';


--
-- Name: COLUMN sec_event_log.event_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_event_log.event_status IS 'статус события';


--
-- Name: COLUMN sec_event_log.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_event_log.session_id IS 'идентификатор сессии';


--
-- Name: COLUMN sec_event_log.context; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_event_log.context IS 'контекст (аттрибуты, параметры) события';


--
-- Name: COLUMN sec_event_log.user_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_event_log.user_name IS 'имя учетной записи';


--
-- Name: COLUMN sec_event_log.auth_path_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_event_log.auth_path_id IS 'источник аутентификации';


--
-- Name: sec_event_log_start(integer, text, text, xml, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_event_log_start(p_session_id integer, p_class_name text, p_event_name text, p_context xml DEFAULT NULL::xml, p_user_name text DEFAULT NULL::text, p_auth_path_id integer DEFAULT NULL::integer, p_tokenvalue text DEFAULT NULL::text) RETURNS sec_event_log
    LANGUAGE plpgsql COST 3
    AS $$
declare
  -- регистрирует начало события с указанным именем и именем класса
  res  sec_event_log;
begin
--  BEGIN SUBTRANSACTION;
  insert into sec_event_log (session_id, whenfired, event_kind, event_status, context, user_name, auth_path_id, tokenvalue)
  values (p_session_id, clock_timestamp(), (lml_event(p_class_name, p_event_name)).id, (lml_event_status())."STARTED", p_context, p_user_name, p_auth_path_id, p_tokenvalue)
  returning * into res;
--  COMMIT SUBTRANSACTION;
  return res;
end;
$$;


ALTER FUNCTION public.sec_event_log_start(p_session_id integer, p_class_name text, p_event_name text, p_context xml, p_user_name text, p_auth_path_id integer, p_tokenvalue text) OWNER TO postgres;

--
-- Name: FUNCTION sec_event_log_start(p_session_id integer, p_class_name text, p_event_name text, p_context xml, p_user_name text, p_auth_path_id integer, p_tokenvalue text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_event_log_start(p_session_id integer, p_class_name text, p_event_name text, p_context xml, p_user_name text, p_auth_path_id integer, p_tokenvalue text) IS 'регистрирует начало события с указанным именем и именем класса';


--
-- Name: sec_token; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_token (
    id integer NOT NULL,
    localvalue text NOT NULL,
    credential text,
    auth_path_id integer,
    session_id integer NOT NULL,
    validfrom timestamp with time zone NOT NULL,
    validtill timestamp with time zone,
    originvalue text
);


ALTER TABLE public.sec_token OWNER TO postgres;

--
-- Name: TABLE sec_token; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sec_token IS 'токены безопасности, полученные от соответствующих источников аутентификации';


--
-- Name: COLUMN sec_token.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.id IS 'идентификатор токена';


--
-- Name: COLUMN sec_token.localvalue; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.localvalue IS 'локализованное (уникальное) значение токена';


--
-- Name: COLUMN sec_token.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.credential IS 'Учетные данные, использованные при аутентификации';


--
-- Name: COLUMN sec_token.auth_path_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.auth_path_id IS 'источник аутентификации';


--
-- Name: COLUMN sec_token.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.session_id IS 'идентификатор сессии';


--
-- Name: COLUMN sec_token.validfrom; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.validfrom IS 'момент (включительно) начала действия токена';


--
-- Name: COLUMN sec_token.validtill; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.validtill IS 'момент (включительно) окончания действия токена';


--
-- Name: COLUMN sec_token.originvalue; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token.originvalue IS 'исходное оригинальное значение токена, полученное от источника аутентификации';


--
-- Name: sec_login(text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_login(p_tokenvalue text, p_auth_path_id integer, p_user_name text) RETURNS sec_token
    LANGUAGE plpgsql COST 10
    AS $_$declare
  -- регистрация токена, предоставленного доверенным источником аутентификации. возвращает зарегистрированный токен безопасности. если пользователь не найден, возвращает null.
  l_user     sec_user;
  l_uac      sec_user_authcred;
  l_session  sec_session;
  l_token    sec_token;
begin
  -- ищем учетную запись по имени
  select * into l_user from sec_user_by_name(p_user_name);
  if (found) then
    -- учетная запись найдена, создаем сессию
    insert into sec_session (id, user_id, whenstarted)
    values (default, l_user.id, clock_timestamp())
    returning * into l_session;
    insert into sec_session_log (id, user_id, whenstarted, when_logged)
    values (l_session.id, l_session.user_id, l_session.whenstarted, clock_timestamp());
    l_token.originvalue := p_tokenvalue;
    l_token := sec_token_localvalue(l_token);
    insert into sec_token(id, originvalue, localvalue, credential, auth_path_id, session_id, validfrom, validtill)
    values (l_token.id, p_tokenvalue, l_token.localvalue, null, p_auth_path_id, l_session.id, clock_timestamp(), null)
    returning * into l_token;
    insert into sec_token_log (id, originvalue, localvalue, credential, auth_path_id, session_id, validfrom, validtill, when_logged)
    values (l_token.id, l_token.originvalue, l_token.localvalue, l_token.credential, l_token.auth_path_id, l_token.session_id, l_token.validfrom, l_token.validtill, clock_timestamp());
    -- регистрируем событие логина
    perform sec_event_log_start(l_session.id, 'sec_session', 'login_succeded', xmlforest(l_token), p_user_name, p_auth_path_id);
    -- возвращаем строку токена
    return l_token;
  else 
    -- учетная запись не найдена
    -- регистрируем событие неудачной попытки логина
    l_session.id := nextval('sec_session_id_seq');
    perform sec_event_log_start(l_session.id, 'sec_session', 'login_failed', xml(format('<user_name>%1$s</user_name><auth_path_id>%2$s</auth_path_id><tokenvalue>%3$s</tokenvalue>', p_user_name, p_auth_path_id, p_tokenvalue)), p_user_name, p_auth_path_id, p_tokenvalue);
    -- 'SEC00007', 'login failed. wrong or unknown username (%s) or credential/authentication path'
    raise warning invalid_password using message = env_resource_text_format('SEC00007', p_user_name);
    return null;
  end if;
end;
$_$;


ALTER FUNCTION public.sec_login(p_tokenvalue text, p_auth_path_id integer, p_user_name text) OWNER TO postgres;

--
-- Name: FUNCTION sec_login(p_tokenvalue text, p_auth_path_id integer, p_user_name text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_login(p_tokenvalue text, p_auth_path_id integer, p_user_name text) IS 'регистрация токена, предоставленного доверенным источником аутентификации. возвращает зарегистрированный токен безопасности. если пользователь не найден, возвращает null.';


--
-- Name: sec_login(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_login(p_user_name text, p_credential text, p_auth_path_id integer DEFAULT NULL::integer) RETURNS sec_token
    LANGUAGE plpgsql COST 10
    AS $_$declare
  -- аутентификация. возвращает токен безопасности, если аутентификация выполнена успешно. в противном случае возвращает NULL
  l_uac      sec_user_authcred;
  l_session  sec_session;
  l_token    sec_token;
begin
  -- проверка указанных учетных данных
  select * into l_uac from sec_user_authcred_accepted(p_user_name, p_credential, p_auth_path_id) limit 1;
  if (found) then
    -- учетные данные приняты, создаем сессию
    insert into sec_session (id, user_id, whenstarted)
    values (default, l_uac.user_id, clock_timestamp())
    returning * into l_session;
    insert into sec_session_log (id, user_id, whenstarted, when_logged)
    values (l_session.id, l_session.user_id, l_session.whenstarted, clock_timestamp());
    l_token.originvalue := uuid_generate();
    l_token := sec_token_localvalue(l_token);
    insert into sec_token(id, originvalue, localvalue, credential, auth_path_id, session_id, validfrom, validtill)
    values (l_token.id, l_token.originvalue, l_token.localvalue, l_uac.credential, l_uac.auth_path_id, l_session.id, clock_timestamp(), null)
    returning * into l_token;
    insert into sec_token_log (id, originvalue, localvalue, credential, auth_path_id, session_id, validfrom, validtill, when_logged)
    values (l_token.id, l_token.originvalue, l_token.localvalue, l_token.credential, l_token.auth_path_id, l_token.session_id, l_token.validfrom, l_token.validtill, clock_timestamp());
    -- регистрируем событие логина
    perform sec_event_log_start(l_session.id, 'sec_session', 'login_succeded', xmlforest(l_token), p_user_name, p_auth_path_id);
    -- возвращаем строку токена
    return l_token;
  else 
    -- учетные данные не приняты
    -- регистрируем событие неудачной попытки логина
    l_session.id := nextval('sec_session_id_seq');
    perform sec_event_log_start(l_session.id, 'sec_session', 'login_failed', xml(format('<user_name>%1$s</user_name><auth_path_id>%2$s</auth_path_id><credential>%3$s</credential>', p_user_name, p_auth_path_id, p_credential)), p_user_name, p_auth_path_id, p_credential);
    -- 'SEC00007', 'login failed. wrong or unknown username (%s) or credential/authentication path'
    raise warning invalid_password using message = env_resource_text_format('SEC00007', p_user_name);
    -- TODO: блокирование (перенос действия на некоторое время в будущее) учетных данных при достижении критического порога неудачных попыток логина
    return null;
  end if;
end;
$_$;


ALTER FUNCTION public.sec_login(p_user_name text, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_login(p_user_name text, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_login(p_user_name text, p_credential text, p_auth_path_id integer) IS 'аутентификация. возвращает идентификатор сессии, если аутентификация выполнена успешно. в противном случае возвращает NULL';


--
-- Name: sec_logout(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_logout(p_tokenvalue text) RETURNS sec_token
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- завершает сессию с указанным токеном. возвращает строку токена, если сессия завершена успешно. в противном случае возвращает null
  l_token    sec_token; -- токен
  l_session  sec_session; -- сессия
  l_user     sec_user; -- учетная запись
begin
  -- проверка действительности токена
  select * into l_token from sec_token_valid(p_tokenvalue);
  if (found) then
    -- токен действителен, завершаем его
    l_token := sec_token_stale(l_token, true);
    -- проверка действительности сессии
    l_session := sec_session_valid(l_token.session_id);
    -- учетная запись сессии
    l_user := sec_user_by_id(l_session.user_id);
    -- сессия действительна, завершаем её
    l_session := sec_session_stale(l_session, true);
    -- регистрируем событие логаута
    perform sec_event_log_start(l_token.session_id, 'sec_session', 'logout_succeded', xmlforest(l_token), l_user.name, l_token.auth_path_id, p_tokenvalue);
    -- возвращаем строку токена
    return l_token;
  else 
    -- 'SEC00026', 'token "%s" not found'
    raise warning invalid_password using message = env_resource_text_format('SEC00026', p_tokenvalue);
    return null;
  end if;
end;
$$;


ALTER FUNCTION public.sec_logout(p_tokenvalue text) OWNER TO postgres;

--
-- Name: FUNCTION sec_logout(p_tokenvalue text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_logout(p_tokenvalue text) IS 'завершает сессию с указанным токеном. возвращает строку токена, если сессия завершена успешно. в противном случае возвращает null';


--
-- Name: sec_session; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_session (
    user_id integer NOT NULL,
    whenstarted timestamp with time zone NOT NULL,
    whenended timestamp with time zone,
    id integer NOT NULL
);


ALTER TABLE public.sec_session OWNER TO postgres;

--
-- Name: TABLE sec_session; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sec_session IS 'сессии пользователей';


--
-- Name: COLUMN sec_session.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session.user_id IS 'код пользователя';


--
-- Name: COLUMN sec_session.whenstarted; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session.whenstarted IS 'дата/время начала сессии';


--
-- Name: COLUMN sec_session.whenended; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session.whenended IS 'дата/время завершения сессии (если была завершена явным образом)';


--
-- Name: COLUMN sec_session.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session.id IS 'идентификатор сессии';


--
-- Name: sec_session_find_by_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_session_find_by_id(p_session_id integer) RETURNS sec_session
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- поиск сессии по её идентификатору. возвращает строку сессии, если такая найдена.
  -- если сессия не найдена, возбуждает исключение
  res  sec_session%rowtype;
begin
  select s.* 
    into strict res
    from sec_session s 
   where s.id = p_session_id;
  return res;
exception
  when NO_DATA_FOUND then
    raise exception 'session_id % not found', p_session_id::text;
end;
$$;


ALTER FUNCTION public.sec_session_find_by_id(p_session_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_session_find_by_id(p_session_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_session_find_by_id(p_session_id integer) IS 'поиск сессии по её идентификатору. возвращает строку сессии, если такая найдена. если сессия не найдена, возбуждает исключение';


--
-- Name: sec_session_has_permission(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_session_has_permission(p_session_id integer, p_permission_name text) RETURNS boolean
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- возвращает наличие указанного разрешения в указанной сессии
  l_session sec_session; -- текущая сессия
begin
  -- текущая сессия
  select * into l_session from sec_session_find_by_id(p_session_id);
  -- TODO заменить на осмысленную проверку наличия разрешения
  return true;
end;
$$;


ALTER FUNCTION public.sec_session_has_permission(p_session_id integer, p_permission_name text) OWNER TO postgres;

--
-- Name: FUNCTION sec_session_has_permission(p_session_id integer, p_permission_name text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_session_has_permission(p_session_id integer, p_permission_name text) IS 'возвращает наличие указанного разрешения в указанной сессии';


--
-- Name: sec_session_has_role(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_session_has_role(p_session_id integer, p_role_name text) RETURNS boolean
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- возвращает наличие указанной роли в указанной сессии
  l_session sec_session; -- текущая сессия
begin
  -- текущая сессия
  select * into l_session from sec_session_find_by_id(p_session_id);
  -- TODO заменить на осмысленную проверку наличия роли
  return true;
end;
$$;


ALTER FUNCTION public.sec_session_has_role(p_session_id integer, p_role_name text) OWNER TO postgres;

--
-- Name: FUNCTION sec_session_has_role(p_session_id integer, p_role_name text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_session_has_role(p_session_id integer, p_role_name text) IS 'возвращает наличие указанной роли в указанной сессии';


--
-- Name: sec_session_require_permission(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_session_require_permission(p_session_id integer, p_permission_name text) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- проверяет наличие указанного разрешения в указанной сессии. если разрешение отсутствует, генерирует исключение
begin
  -- текущая сессия
  if (not sec_session_has_permission(p_session_id, p_permission_name)) then
    -- 'SEC00004', 'access denied. has no permission (%s)'
    raise exception insufficient_privilege using message = env_resource_text_format('SEC00004', p_permission_name);
  end if;
end;
$$;


ALTER FUNCTION public.sec_session_require_permission(p_session_id integer, p_permission_name text) OWNER TO postgres;

--
-- Name: FUNCTION sec_session_require_permission(p_session_id integer, p_permission_name text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_session_require_permission(p_session_id integer, p_permission_name text) IS 'проверяет наличие указанного разрешения в указанной сессии. если разрешение отсутствует, генерирует исключение';


--
-- Name: sec_session_stale(sec_session, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_session_stale(p_session sec_session, p_force boolean DEFAULT false) RETURNS sec_session
    LANGUAGE plpgsql COST 10
    AS $$
declare
  -- устаревание сессии пользователей
  now      timestamp with time zone;
begin
  -- если устаревание не принудительное, то проверяем сессию на валидность
  if (not p_force) then
    begin
      select * into p_session from sec_session_valid(p_session.id);
    exception
      when NO_DATA_FOUND or TOO_MANY_ROWS then p_force := true; -- если сессия не валидна, старим её принудительно
    end;
  end if;
  -- если сессия не валидна или если устаревание принудительное
  if p_force then
    -- текущее дата/время
    now := clock_timestamp();
    -- если сессия не была ограничена по времени действия, ограничим её текущим моментом
    p_session.whenended := coalesce(p_session.whenended, now);
    -- обновим журнал
    update sec_session_log
       set user_id = p_session.user_id, 
           whenstarted = p_session.whenstarted, 
           whenended = p_session.whenended,
           when_logged = now
     where id = p_session.id;
    -- если в журнале не было этой сессии, добавим её туда
    if (not found) then
      insert into sec_session_log (id, user_id, whenstarted, whenended, when_logged)
      values (p_session.id, p_session.user_id, p_session.whenstarted, p_session.whenended, now);
    end if;
    -- удалим токен из оперативной таблицы
    delete from sec_session where id = p_session.id;
  end if;
  return p_session;
end;
$$;


ALTER FUNCTION public.sec_session_stale(p_session sec_session, p_force boolean) OWNER TO postgres;

--
-- Name: FUNCTION sec_session_stale(p_session sec_session, p_force boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_session_stale(p_session sec_session, p_force boolean) IS 'устаревание сессии пользователей';


--
-- Name: sec_session_valid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_session_valid(p_session_id integer) RETURNS sec_session
    LANGUAGE plpgsql STABLE COST 10
    AS $$
declare
  -- проверки валидности сессии
  l_session  sec_session; -- текущая сессия
  now        timestamp with time zone;
begin
  -- текущая сессия
  select * into l_session from sec_session_find_by_id(p_session_id);
  if (found) then
    -- сессия найдена
    now := clock_timestamp();
    if (l_session.whenstarted > now) or (coalesce(l_session.whenended, now) < now) then
      -- период действия сессии ещё не наступил или уже окончен
      -- 'SEC00006', 'session %s expired'
      raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00006', p_session_id::text);
    end if;
    return l_session;
  else
    -- сессия не найдена
    -- 'SEC00005', 'session %s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00005', p_session_id::text);
  end if;
end;
$$;


ALTER FUNCTION public.sec_session_valid(p_session_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_session_valid(p_session_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_session_valid(p_session_id integer) IS 'проверки валидности сессии';


--
-- Name: sec_token_find_by_value(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_token_find_by_value(p_tokenvalue text) RETURNS sec_token
    LANGUAGE plpgsql STABLE COST 5
    AS $_$declare
  -- поиск токена по его локальному (уникальному) текстовому содержимому. возвращает строку токена, если такой найден.
  -- если токен не найден, возбуждает исключение
  res  sec_token;
begin
  select st.* 
    into strict res
    from sec_token st 
   where st.localvalue = p_tokenvalue;
     --and clock_timestamp() between validfrom and validtill
  return res;
exception
  when NO_DATA_FOUND then
    -- 'SEC00027', 'token value "%1$s" not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00027', p_tokenvalue);
  when TOO_MANY_ROWS then
    -- 'SEC00028', 'token value "%1$s" not unique'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00028', p_tokenvalue);
end;
$_$;


ALTER FUNCTION public.sec_token_find_by_value(p_tokenvalue text) OWNER TO postgres;

--
-- Name: FUNCTION sec_token_find_by_value(p_tokenvalue text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_token_find_by_value(p_tokenvalue text) IS 'поиск токена по его локальному (уникальному) текстовому содержимому. возвращает строку токена, если такой найден. если токен не найден, возбуждает исключение';


--
-- Name: sec_token_localvalue(sec_token); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_token_localvalue(p_token sec_token) RETURNS sec_token
    LANGUAGE plpgsql COST 5
    AS $_$declare
  -- возвращает строку токена с заполненным локальным (уникальным) текстовым содержимым токена.
begin
  if (p_token.originvalue is not null) then
    if (p_token.id is null) then
      p_token.id = nextval('sec_token_id_seq');
    end if;
    p_token.localvalue := p_token.id || '#' || p_token.originvalue;
    return p_token;
  else
    -- 'SEC00035', 'value "%2$s" of "%1$s" must be not null'
    raise exception null_value_not_allowed using message = env_resource_text_format('SEC00035', 'token', 'originvalue');
  end if;
end;
$_$;


ALTER FUNCTION public.sec_token_localvalue(p_token sec_token) OWNER TO postgres;

--
-- Name: FUNCTION sec_token_localvalue(p_token sec_token); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_token_localvalue(p_token sec_token) IS 'возвращает строку токена с заполненным локальным (уникальным) текстовым содержимым токена.';


--
-- Name: sec_token_stale(sec_token, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_token_stale(p_token sec_token, p_force boolean DEFAULT false) RETURNS sec_token
    LANGUAGE plpgsql COST 10
    AS $$
declare
  -- устаревание токена безопасности
  now      timestamp with time zone;
begin
  -- если устаревание не принудительное, то проверяем токен на валидность
  if (not p_force) then
    begin
      select * into p_token from sec_token_valid(p_token.localvalue);
    exception
      when NO_DATA_FOUND or TOO_MANY_ROWS then p_force := true; -- если токен не валиден, старим его принудительно
    end;
  end if;
  -- если токен не валиден или если устаревание принудительное
  if p_force then
    -- текущее дата/время
    now := clock_timestamp();
    -- если токен не был ограничен по времени действия, ограничим его текущим моментом
    p_token.validtill := coalesce(p_token.validtill, now);
    -- обновим журнал
    update sec_token_log
       set localvalue = p_token.localvalue, 
           originvalue = p_token.originvalue, 
           credential = p_token.credential, 
           auth_path_id = p_token.auth_path_id, 
           session_id = p_token.session_id, 
           validfrom = p_token.validfrom, 
           validtill = p_token.validtill,
           when_logged = now
     where id = p_token.id;
    -- если в журнале не было этого токена, добавим его туда
    if (not found) then
      insert into sec_token_log (id, localvalue, originvalue, credential, auth_path_id, session_id, validfrom, validtill, when_logged)
      values (p_token.id, p_token.localvalue, p_token.originvalue, p_token.credential, p_token.auth_path_id, p_token.session_id, p_token.validfrom, p_token.validtill, now);
    end if;
    -- удалим токен из оперативной таблицы
    delete from sec_token where id = p_token.id;
  end if;
  return p_token;
end;
$$;


ALTER FUNCTION public.sec_token_stale(p_token sec_token, p_force boolean) OWNER TO postgres;

--
-- Name: FUNCTION sec_token_stale(p_token sec_token, p_force boolean); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_token_stale(p_token sec_token, p_force boolean) IS 'устаревание токена безопасности';


--
-- Name: sec_token_valid(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_token_valid(p_tokenvalue text) RETURNS sec_token
    LANGUAGE plpgsql STABLE COST 10
    AS $$
declare
  -- проверки валидности токена безопасности
  l_token  sec_token; -- токен
  now      timestamp with time zone;
begin
  -- ищем токен по его значению 
  select * into l_token from sec_token_find_by_value(p_tokenvalue);
  if (found) then
    -- токен найден
    now := clock_timestamp();
    if (l_token.validfrom > now) or (coalesce(l_token.validtill, now) < now) then
      -- период действия токена ещё не наступил или уже окончен
      -- 'SEC00025', 'token "%s" expired'
      raise exception TOO_MANY_ROWS using message = env_resource_text_format('SEC00025', p_tokenvalue);
    end if;
    return l_token;
  else
    -- токен не найден
    -- 'SEC00026', 'token "%s" not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00026', p_tokenvalue);
  end if;
end;
$$;


ALTER FUNCTION public.sec_token_valid(p_tokenvalue text) OWNER TO postgres;

--
-- Name: FUNCTION sec_token_valid(p_tokenvalue text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_token_valid(p_tokenvalue text) IS 'проверки валидности токена безопасности';


--
-- Name: sec_user_authcred; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_user_authcred (
    user_id integer NOT NULL,
    auth_path_id integer NOT NULL,
    credential character varying(511),
    valid_from timestamp with time zone NOT NULL,
    valid_till timestamp with time zone NOT NULL,
    credential_hash text
);


ALTER TABLE public.sec_user_authcred OWNER TO postgres;

--
-- Name: TABLE sec_user_authcred; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sec_user_authcred IS 'Учетные данные для аутентификации';


--
-- Name: COLUMN sec_user_authcred.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred.user_id IS 'код пользователя';


--
-- Name: COLUMN sec_user_authcred.auth_path_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred.auth_path_id IS 'источник аутентификации';


--
-- Name: COLUMN sec_user_authcred.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred.credential IS 'Учетные данные (хеш пароля, сертификат, идентификатор во внешней доверенной системе и т.п.)';


--
-- Name: COLUMN sec_user_authcred.valid_from; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred.valid_from IS 'момент начала действия (включительно)';


--
-- Name: COLUMN sec_user_authcred.valid_till; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred.valid_till IS 'момент окончания действия (включительно)';


--
-- Name: COLUMN sec_user_authcred.credential_hash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred.credential_hash IS 'Хеш учетных данных';


--
-- Name: sec_user_authcred_accepted(integer, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_accepted(p_user_id integer, p_credential text, p_auth_path_id integer DEFAULT NULL::integer) RETURNS SETOF sec_user_authcred
    LANGUAGE sql COST 10
    AS $_$
  -- проверка учетных данных. возвращает набор, для которых учетные данные приняты (подтверждены).
  -- если учетные данные не приняты, возвращает пустой набор
  select /* sec_0001 */
         acr.*
    from sec_user_authcred acr,
         sec_authentication_path ap,
         sec_authentication_kind ak
   where (acr.user_id = $1) -- id учетной записи
     and (acr.auth_path_id = $3 or $3 is null) -- источник (поставщик) аутентификации
     and (clock_timestamp() between acr.valid_from and acr.valid_till) --срок действия учетных данных
     and (ap.id = acr.auth_path_id)
     and (ak.id = ap.authentication_kind_id)
         -- собственно, проверка самих учетных данных разными источниками (поставщиками) аутентификации
     and case -- при появлении новых видов аутентификации их обработку надо добавить сюда
           when (ak.code = 'pg_crypt') and (crypt($2, acr.credential) = acr.credential) then true 
           else false
         end;
$_$;


ALTER FUNCTION public.sec_user_authcred_accepted(p_user_id integer, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_accepted(p_user_id integer, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_accepted(p_user_id integer, p_credential text, p_auth_path_id integer) IS 'проверка учетных данных. возвращает набор, для которых учетные данные приняты (подтверждены). если учетные данные не приняты, возвращает пустой набор';


--
-- Name: sec_user_authcred_accepted(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_accepted(p_user_name text, p_credential text, p_auth_path_id integer DEFAULT NULL::integer) RETURNS SETOF sec_user_authcred
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- проверка учетных данных. возвращает набор, для которых учетные данные приняты (подтверждены).
  -- если учетные данные не приняты, возвращает пустой набор
  l_user_id  integer;
begin
  select /* sec_0002 */ id into l_user_id from sec_user_by_name(p_user_name);
  return query select /* sec_0003 */ * from sec_user_authcred_accepted(l_user_id, p_credential, p_auth_path_id);
end;
$$;


ALTER FUNCTION public.sec_user_authcred_accepted(p_user_name text, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_accepted(p_user_name text, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_accepted(p_user_name text, p_credential text, p_auth_path_id integer) IS 'проверка учетных данных. возвращает набор, для которых учетные данные приняты (подтверждены). если учетные данные не приняты, возвращает пустой набор';


--
-- Name: sec_user_authcred_by_pk(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_by_pk(p_user_id integer, p_auth_path_id integer) RETURNS sec_user_authcred
    LANGUAGE plpgsql STABLE COST 5
    AS $_$declare
  -- поиск учетных данных по идентификатору учетной записи и источнику аутентификации. возвращает строку учетных данных, если такая найдена.
  -- если не найдена или найдено несколько, возбуждает исключение
  res  sec_user_authcred;
begin
  select *
    into STRICT res
    from sec_user_authcred
   where user_id = p_user_id
     and auth_path_id = p_auth_path_id;
     --and (clock_timestamp() between valid_from and valid_till); --срок действия учетных данных
   return res;
exception
  when NO_DATA_FOUND then
    -- 'SEC00029', 'authentication credential not found for user id "%1$s" and authentication path id "%2$s"'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00029', p_user_id::text, p_auth_path_id::text);
  when TOO_MANY_ROWS then
    -- 'SEC00030', 'authentication credential not unique for user id "%1$s" and authentication path id "%2$s"'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('SEC00030', p_user_id::text, p_auth_path_id::text);
end;
$_$;


ALTER FUNCTION public.sec_user_authcred_by_pk(p_user_id integer, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_by_pk(p_user_id integer, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_by_pk(p_user_id integer, p_auth_path_id integer) IS 'поиск учетных данных по идентификатору учетной записи и источнику аутентификации. возвращает строку учетных данных, если такая найдена. если не найдена или найдено несколько, возбуждает исключение';


--
-- Name: sec_user_authcred_comply_policy(integer, integer, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_comply_policy(p_session_id integer, p_user_id integer, p_old_credential text, p_credential text, p_auth_path_id integer) RETURNS integer
    LANGUAGE plpgsql STABLE COST 30
    AS $_$declare
  -- проверка соответствия политике учетных данных.
  -- p_session_id - текущая сессия, p_user_id - учетная запись, для которой проверяются учетные данные на сответствие политике
  -- p_old_credential "старые" (текущие) учетные данные, p_credential - "новые" учетные данные, p_auth_path_id - способ аутентификации
  l_session  sec_session; -- текущая сессия
  l_uac      sec_user_authcred;
  ok         boolean;
  l_user     sec_user;
  moment     timestamp with time zone;
  res        integer;
  l_similarity  constant integer := 5; -- требуемая точность сходства
  l_min_length  constant integer := 8; -- минимальная длина учетных данных
  l_authcred_log_depth constant integer := 100; -- глубина просмотра журнала истории учетных данных
  l_digit    constant text := '[0-9]'; -- регулярное выражение для поиска цифр
  l_alpha_ci constant text := '[a-zа-яA-ZА-Я]'; -- регулярное выражение для поиска букв без учета регистра символов
  l_alpha_lc constant text := '[a-zа-я]'; -- регулярное выражение для поиска букв в нижнем регистре
  l_alpha_uc constant text := '[A-ZА-Я]'; -- регулярное выражение для поиска букв в верхнем регистре
  l_punctuation constant text := '[^a-zA-Zа-яА-Я0-9]'; -- регулярное выражение для поиска знаков препинания и спецсимволов
  l_min_cred_age constant interval := '1 day'; -- сколько дней нельзя менять учетные данные (минимальный срок жизни учетных данных)
  l_max_cred_age constant interval := '100 day'; -- сколько дней нельзя использовать такие-же учетные данные (максимальный срок жизни учетных данных)
  l_text_is_similar integer; -- результат, при котором тексты считаются похожими
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  -- наличие полномочий на проверку чужих учетных данных или попытка проверить свои
  select (l_session.user_id = p_user_id) or sec_session_has_permission(p_session_id, 'sec_user_authcred.comply_policy') into ok;
  if (ok) then -- либо проверяем свои данные, либо есть полномочия на проверку чужих
    -- проверка "старых" (текущих) учетных данных для указанного пользователя
    select * into l_uac from sec_user_authcred_accepted(p_user_id, p_old_credential, p_auth_path_id) limit 1;
    if (found) then -- "старые" (текущие) учетные данные действительны
      l_user := sec_user_by_id(p_user_id);
      -- минимальная длина 'SEC00015', 'credential length (%1$s) less than minimum allowed (%2$s)'
      if (p_credential is null) or (char_length(p_credential) < l_min_length) then
        return env_resource_text_find_by_code('SEC00015', char_length(p_credential)::text, l_min_length::text);
      end if;
      -- сложность (большие, маленькие буквы, цифры, знаки)
      if regexp_matches(p_credential, l_digit) is null then -- не содержит цифр
        -- 'SEC00016', 'credential must contain at least one digit'
        return env_resource_text_find_by_code('SEC00016');
      end if;
      if regexp_matches(p_credential, l_alpha_ci) is null then -- не содержит букв
        -- 'SEC00017', 'credential must contain at least one letter'
        return env_resource_text_find_by_code('SEC00017');
      end if;
      if regexp_matches(p_credential, l_alpha_lc) is null then -- не содержит букв в нижнем регистре
        -- 'SEC00018', 'credential must contain at least one lower case letter'
        return env_resource_text_find_by_code('SEC00018');
      end if;
      if regexp_matches(p_credential, l_alpha_uc) is null then -- не содержит букв в верхнем регистре
        -- 'SEC00019', 'credential must contain at least one upper case letter'
        return env_resource_text_find_by_code('SEC00019');
      end if;
      if regexp_matches(p_credential, l_punctuation) is null then -- не содержит знаков препинания и спецсимволов
        -- 'SEC00020', 'credential must contain at least one punctuation character'
        return env_resource_text_find_by_code('SEC00020');
      end if;
      l_text_is_similar := env_resource_text_find_by_code('RES00003');
      -- если имя учетной записи и новые учетные данные похожи сточностью до 5 общих символов подряд
      if env_text_similar(l_user.name, p_credential, l_similarity) = l_text_is_similar then 
        -- 'SEC00021', 'credential must not be similar to user name'
        return env_resource_text_find_by_code('SEC00021');
      end if;
      -- если старые и новые учетные данные похожи сточностью до 5 общих символов подряд
      if env_text_similar(p_old_credential, p_credential, l_similarity) = l_text_is_similar then 
        -- 'SEC00022', 'credential must not be similar to previous one'
        return env_resource_text_find_by_code('SEC00022');
      end if;
      -- менялись ли учетные данные в течении послених N дней
      -- для исключения быстрой смены N паролей и возвращения к ранее использованным учетным данным
      select cl.when_logged
        into moment
        from sec_user_authcred_log cl
       where cl.user_id = p_user_id 
         and cl.auth_path_id = l_uac.auth_path_id
         and cl.credential_hash <> sec_user_authcred_hash(p_session_id, p_user_id, p_credential, l_uac.auth_path_id)
         and cl.when_logged > clock_timestamp() - l_min_cred_age -- сколько дней нельзя менять учетные данные
       order by cl.when_logged desc
       limit 1;
      if (found) then -- учетные данные менялись в течении послених N дней
        -- 'SEC00023', 'credential must not be changed "%1$s" after previos changes at "%2$s"'
        return env_resource_text_find_by_code('SEC00023');
      end if;
      -- поиск совпадений новых учетных данных со старыми во всей истории из 
      -- журнала изменений учетных данных или с ограничением глубины анализа истории
      -- TODO: переделать. надо считать кол-во смен паролей, а не кол-во строк
      select count(1)
        into res
        from (
              select row_number() over (order by cl.when_logged desc) as rn
                from sec_user_authcred_log cl
               where cl.user_id = p_user_id 
                 and cl.auth_path_id = l_uac.auth_path_id
                 and cl.credential_hash = sec_user_authcred_hash(p_session_id, p_user_id, p_credential, l_uac.auth_path_id)
                 and cl.when_logged > clock_timestamp() - l_max_cred_age -- сколько дней нельзя использовать такие-же учетные данные
             ) s
       where rn < l_authcred_log_depth; -- глубина просмотра журнала истории
      if (res > 0) then -- совпадения найдены
        return env_resource_text_find_by_code('-----');
      end if;

      -- TODO: проверка на совпадение со словарным словом
      -- TODO: проверка на схожесть с одной из предсказуемых последовательностей символов

      -- "ANY00001", "ok (no errors)"
      return env_resource_text_find_by_code('ANY00001');
    else 
      -- 'SEC00009', 'no valid credentials found for user (%s) and authentication path id (%s)'
      return env_resource_text_find_by_code('SEC00009');
    end if;
  else 
    -- код ошибки SEC00004, "access denied. has no permission (%s)"
    return env_resource_text_find_by_code('SEC00004');
  end if;
  return res;
end;
$_$;


ALTER FUNCTION public.sec_user_authcred_comply_policy(p_session_id integer, p_user_id integer, p_old_credential text, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_comply_policy(p_session_id integer, p_user_id integer, p_old_credential text, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_comply_policy(p_session_id integer, p_user_id integer, p_old_credential text, p_credential text, p_auth_path_id integer) IS 'проверка соответствия политике учетных данных';


--
-- Name: sec_user_authcred_encrypt(integer, integer, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_encrypt(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer) RETURNS text
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- возвращает учетные данные в форме, предназначенной для хранения. для паролей это обычно хеш пароля с солью
  l_session  sec_session; -- текущая сессия
  l_user     sec_user;
  ok         boolean;
  res  text;
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  -- указанная учетная запись
  select * into l_user from sec_user_by_id(p_user_id);
  --наличие полномочий на операцию с чужими учетными данными или на свои
  select sec_session_has_permission(p_session_id, 'sec_user_authcred.encrypt') or (l_session.user_id = l_user.id) into ok;
  if (not ok) then
    -- 'SEC00004', 'access denied. has no permission (%s)'
    raise exception insufficient_privilege using message = env_resource_text_format('SEC00004', 'sec_user_authcred.encrypt');
  end if;
  select case -- обработка разных типов аутентификации и разновидностей учетных данных.
           -- при добавлении новых видов аутентификации их обработку надо добавить сюда
           when (ak.code = 'pg_crypt') then crypt(p_credential, gen_salt(ap.credential_kind))
           else null
         end
    into strict res
    from sec_user_authcred acr,
         sec_authentication_path ap,
         sec_authentication_kind ak
   where (acr.user_id = p_user_id)
     and (acr.auth_path_id = p_auth_path_id)
     and (ap.id = acr.auth_path_id)
     and (ak.id = ap.authentication_kind_id);
  return res;
exception
  when NO_DATA_FOUND then
    raise exception 'user_id (%) and/or auth_path_id (%) not found', p_user_id, p_auth_path_id;
  when TOO_MANY_ROWS then
    raise exception 'user_id (%) and auth_path_id (%) are not unique', p_user_id, p_auth_path_id;
end;
$$;


ALTER FUNCTION public.sec_user_authcred_encrypt(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_encrypt(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_encrypt(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer) IS 'возвращает учетные данные в форме, предназначенной для хранения. для паролей это обычно хеш пароля с солью';


--
-- Name: sec_user_authcred_hash(integer, integer, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_hash(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer) RETURNS text
    LANGUAGE plpgsql STABLE COST 30
    AS $$declare
  -- возвращает хеш учетных данных
  l_session  sec_session; -- текущая сессия
  l_user     sec_user;
  ok         boolean;
  l_ap       sec_authentication_path;
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  -- указанная учетная запись
  select * into l_user from sec_user_by_id(p_user_id);
  --наличие полномочий на операцию с чужими учетными данными или на свои
  select sec_session_has_permission(p_session_id, 'sec_user_authcred.hash') or (l_session.user_id = l_user.id) into ok;
  if (not ok) then
    -- 'SEC00004', 'access denied. has no permission (%s)'
    raise exception insufficient_privilege using message = env_resource_text_format('SEC00004', 'sec_user_authcred.hash');
  end if;
  l_ap := sec_authentication_path_by_id(p_auth_path_id);
  return encode(digest(l_user.name||p_credential, l_ap.credential_hash_kind), 'hex');
end;
$$;


ALTER FUNCTION public.sec_user_authcred_hash(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_hash(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_hash(p_session_id integer, p_user_id integer, p_credential text, p_auth_path_id integer) IS 'возвращает хеш учетных данных';


--
-- Name: sec_user_authcred_is_valid(integer, sec_user_authcred); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_is_valid(p_session_id integer, p_uac sec_user_authcred) RETURNS boolean
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  -- проверка периода действия учетных данных
  l_session  sec_session; -- текущая сессия
  l_user     sec_user;
  ok         boolean;
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  --наличие полномочий на операцию с чужими учетными данными или на свои
  select sec_session_has_permission(p_session_id, 'sec_user_authcred.is_valid') or (l_session.user_id = p_uac.user_id) into ok;
  if (not ok) then
    -- 'SEC00004', 'access denied. has no permission (%s)'
    raise exception insufficient_privilege using message = env_resource_text_format('SEC00004', 'sec_user_authcred.is_valid');
  end if;
  return (clock_timestamp() between p_uac.valid_from and p_uac.valid_till); --срок действия учетных данных
end;
$$;


ALTER FUNCTION public.sec_user_authcred_is_valid(p_session_id integer, p_uac sec_user_authcred) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_is_valid(p_session_id integer, p_uac sec_user_authcred); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_is_valid(p_session_id integer, p_uac sec_user_authcred) IS 'проверка периода действия учетных данных';


--
-- Name: sec_user_authcred_reset(integer, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_reset(p_session_id integer, p_old_credential text, p_credential text, p_auth_path_id integer) RETURNS integer
    LANGUAGE plpgsql COST 30
    AS $$declare
  -- смена своих учетных данных (пароля)
  l_session  sec_session; -- текущая сессия
  l_uac      sec_user_authcred;
  ok_res     integer;
  res        integer;
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  -- проверка текущих учетных данных
  select * into l_uac from sec_user_authcred_accepted(l_session.user_id, p_old_credential, p_auth_path_id) limit 1;
  if (found) then
    -- наличие полномочий на смену своих учетных данных. если нет - исключение
    perform sec_session_require_permission(p_session_id, 'sec_user_authcred.reset');
    ok_res := env_resource_text_find_by_code('ANY00001');
    -- проверка соответствия политике учетных данных
    res := sec_user_authcred_comply_policy(p_session_id, l_session.user_id, p_old_credential, p_credential, p_auth_path_id);
    if (res <> ok_res) then
      --raise exception NO_DATA_FOUND using message = 'sec_user_authcred_comply_policy() failed. res='||res::text;
      return res;
    end if;
    -- сохраняем текщие учетные данные в журнал изменений
    insert into sec_user_authcred_log (log_id, when_logged, user_id, auth_path_id, credential, credential_hash, valid_from, valid_till)
    values (default, clock_timestamp(), l_uac.user_id, l_uac.auth_path_id, l_uac.credential, l_uac.credential_hash, l_uac.valid_from, l_uac.valid_till);
    -- меняем учетные данные
    update sec_user_authcred acr
       set credential = sec_user_authcred_encrypt(l_session.id, l_session.user_id, p_credential, auth_path_id),
           credential_hash = sec_user_authcred_hash(l_session.id, l_session.user_id, p_credential, p_auth_path_id)
     where user_id = l_session.user_id
       and auth_path_id = p_auth_path_id;
    -- если учетные данные изменены
    return ok_res;
  else
    -- "SEC00007", "wrong or unknown username (%s) or credential/authentication path"
    return env_resource_text_find_by_code('SEC00007');
  end if;
end;
$$;


ALTER FUNCTION public.sec_user_authcred_reset(p_session_id integer, p_old_credential text, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_reset(p_session_id integer, p_old_credential text, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_reset(p_session_id integer, p_old_credential text, p_credential text, p_auth_path_id integer) IS 'смена своих учетных данных (пароля)';


--
-- Name: sec_user_authcred_reset_any(integer, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_reset_any(p_session_id integer, p_user_name text, p_credential text, p_auth_path_id integer) RETURNS integer
    LANGUAGE plpgsql COST 30
    AS $$declare
  -- смена учетных данных (p_credential) для указанной учетной записи (p_user_name)
  l_session  sec_session; -- текущая сессия
  l_user     sec_user; -- учетная запись, для которого меняются учетные данные
  ok         boolean;
  l_uac      sec_user_authcred;
  ok_res     integer;
  res        integer;
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  -- указанная учетная запись
  select * into l_user from sec_user_by_name(p_user_name);
  --наличие полномочий на смену чужих учетных данных или попытка сменить свои
  select sec_session_has_permission(p_session_id, 'sec_user_authcred.reset_any') or (l_session.user_id = l_user.id) into ok;
  if (not ok) then -- полномочий не достаточно
    raise WARNING insufficient_privilege using message = env_resource_text_format('SEC00004', 'sec_user_authcred.reset_any');
    return env_resource_text_find_by_code('SEC00004');
  end if;
  l_uac := sec_user_authcred_by_pk(l_user.id, p_auth_path_id);
  ok_res := env_resource_text_find_by_code('ANY00001');
  -- проверка соответствия политике учетных данных НЕ НУЖНА, если сброс учетных данных выполняет админ
  /*
  res := sec_user_authcred_comply_policy(p_session_id, l_user.id, p_old_credential, p_credential, p_auth_path_id);
  if (res <> ok_res) then
    --raise exception NO_DATA_FOUND using message = 'sec_user_authcred_comply_policy() failed. res='||res::text;
    return res;
  end if;
  */
  -- сохраняем текщие учетные данные в журнал изменений
  insert into sec_user_authcred_log (log_id, when_logged, user_id, auth_path_id, credential, credential_hash, valid_from, valid_till)
  values (default, clock_timestamp(), l_uac.user_id, l_uac.auth_path_id, l_uac.credential, l_uac.credential_hash, l_uac.valid_from, l_uac.valid_till);
  -- меняем учетные данные
  update sec_user_authcred
     set credential = sec_user_authcred_encrypt(l_session.id, l_user.id, p_credential, auth_path_id),
         credential_hash = sec_user_authcred_hash(l_session.id, l_user.id, p_credential, p_auth_path_id)
   where user_id = l_user.id
     and auth_path_id = l_uac.auth_path_id;
  -- если учетные данные изменены
  return ok_res;
end;
$$;


ALTER FUNCTION public.sec_user_authcred_reset_any(p_session_id integer, p_user_name text, p_credential text, p_auth_path_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_reset_any(p_session_id integer, p_user_name text, p_credential text, p_auth_path_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_reset_any(p_session_id integer, p_user_name text, p_credential text, p_auth_path_id integer) IS 'смена учетных данных (p_credential) для указанной учетной записи (p_user_name)';


--
-- Name: sec_user_authcred_set_valid_period(integer, integer, integer, timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_authcred_set_valid_period(p_session_id integer, p_user_id integer, p_auth_path_id integer, p_valid_from timestamp with time zone, p_valid_till timestamp with time zone) RETURNS sec_user_authcred
    LANGUAGE plpgsql COST 5
    AS $$declare
  -- блокировка указанных учетных данных.
  l_session  sec_session; -- текущая сессия
  l_user     sec_user;
  ok         boolean;
  l_uac      sec_user_authcred;
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  -- проверка наличия полномочий. если полномочий нет, - ошибка
  perform sec_session_require_permission(p_session_id, 'sec_user_authcred.set_valid_period');
  -- полномочий достаточно
  l_user := sec_user_by_id(p_user_id);
  l_uac := sec_user_authcred_by_pk(l_user.id, p_auth_path_id);
  -- сохраняем текщие учетные данные в журнал изменений
  insert into sec_user_authcred_log (log_id, when_logged, user_id, auth_path_id, credential, credential_hash, valid_from, valid_till)
  values (default, clock_timestamp(), l_uac.user_id, l_uac.auth_path_id, l_uac.credential, l_uac.credential_hash, l_uac.valid_from, l_uac.valid_till);
  -- ограничиваем срок действия указанных учетных данных
  update sec_user_authcred acr
     set valid_from = coalesce(p_valid_from, valid_from),
         valid_till = coalesce(p_valid_till, valid_till)
   where user_id = l_user.id
     and auth_path_id = p_auth_path_id
  returning * into l_uac;
  return l_uac;
end;
$$;


ALTER FUNCTION public.sec_user_authcred_set_valid_period(p_session_id integer, p_user_id integer, p_auth_path_id integer, p_valid_from timestamp with time zone, p_valid_till timestamp with time zone) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_authcred_set_valid_period(p_session_id integer, p_user_id integer, p_auth_path_id integer, p_valid_from timestamp with time zone, p_valid_till timestamp with time zone); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_authcred_set_valid_period(p_session_id integer, p_user_id integer, p_auth_path_id integer, p_valid_from timestamp with time zone, p_valid_till timestamp with time zone) IS 'блокировка указанных учетных данных.';


SET default_with_oids = true;

--
-- Name: sec_user; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_user (
    id integer NOT NULL,
    person_id integer,
    name character varying(50) NOT NULL,
    time_zone timestamp with time zone
);


ALTER TABLE public.sec_user OWNER TO postgres;

--
-- Name: TABLE sec_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sec_user IS 'учетные записи пользователей';


--
-- Name: COLUMN sec_user.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user.id IS 'идентификатор учетной записи';


--
-- Name: COLUMN sec_user.person_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user.person_id IS 'идентификатор персоны, ассоциированной с этой учетной записью';


--
-- Name: COLUMN sec_user.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user.name IS 'имя (логин, ник) учетной записи';


--
-- Name: COLUMN sec_user.time_zone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user.time_zone IS 'часовой пояс';


--
-- Name: sec_user_by_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_by_id(p_id integer) RETURNS sec_user
    LANGUAGE plpgsql STABLE COST 5
    AS $$declare
  -- поиск учетной записи по её идентификатору. возвращает строку учетной записи, если такая найдена.
  -- если учетная запись не найдена или найдено несколько учетных записей с таким идентификатором, возбуждает исключение
  res  sec_user;
begin
  select u.*
    into STRICT res
    from sec_user u
   where id = p_id;
   return res;
exception
  when NO_DATA_FOUND then
    -- 'SEC00013', 'user id %s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00013', p_id::text);
  when TOO_MANY_ROWS then
    -- 'SEC00014', 'user id %s not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('SEC00014', p_id::text);
end;
$$;


ALTER FUNCTION public.sec_user_by_id(p_id integer) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_by_id(p_id integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_by_id(p_id integer) IS 'поиск учетной записи по её идентификатору. возвращает строку учетной записи, если такая найдена. если учетная запись не найдена или найдено несколько учетных записей с таким идентификатором, возбуждает исключение';


--
-- Name: sec_user_by_name(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_by_name(p_user_name text) RETURNS sec_user
    LANGUAGE plpgsql STABLE COST 10
    AS $_$declare
  -- поиск учетной записи по её имени. возвращает строку учетной записи, если такая найдена.
  -- если учетная запись не найдена или найдено несколько учетных записей с таким именем, возбуждает исключение
  res  sec_user%rowtype;
begin
  select u.*
    into STRICT res
    from sec_user u
   where upper(u.name) = upper($1);
   return res;
exception
  when NO_DATA_FOUND then
    -- 'SEC00001', 'user %s not found'
    raise exception NO_DATA_FOUND using message = env_resource_text_format('SEC00001', p_user_name);
    --execute env_raise_exception('P0002', 'SEC00001', p_user_name);
  when TOO_MANY_ROWS then
    -- 'SEC00002', 'user %s not unique'
    raise exception TOO_MANY_ROWS using message = env_resource_text_format('SEC00002', p_user_name);
    --execute env_raise_exception('23505', 'SEC00002', p_user_name);
end;
$_$;


ALTER FUNCTION public.sec_user_by_name(p_user_name text) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_by_name(p_user_name text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_by_name(p_user_name text) IS 'поиск учетной записи по её имени. возвращает строку учетной записи, если такая найдена. если учетная запись не найдена или найдено несколько учетных записей с таким именем, возбуждает исключение';


--
-- Name: sec_user_create(integer, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_create(p_session_id integer, p_name text, p_auth_path_id integer, p_credential text) RETURNS sec_user
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- создание учетной записи
  l_person  prs_person;
  l_user    sec_user;
begin
  select * into l_person from prs_person_create(p_session_id, p_name, (prs_person_kind())."INDIVIDUAL", null, null);
  select * into l_user from sec_user_create(p_session_id, l_person.id, p_name, p_auth_path_id, p_credential);
  return l_user;
end;
$$;


ALTER FUNCTION public.sec_user_create(p_session_id integer, p_name text, p_auth_path_id integer, p_credential text) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_create(p_session_id integer, p_name text, p_auth_path_id integer, p_credential text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_create(p_session_id integer, p_name text, p_auth_path_id integer, p_credential text) IS 'создание учетной записи';


--
-- Name: sec_user_create(integer, integer, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sec_user_create(p_session_id integer, p_person_id integer, p_name text, p_auth_path_id integer, p_credential text) RETURNS sec_user
    LANGUAGE plpgsql COST 10
    AS $$declare
  -- создание учетной записи
  l_session  sec_session; -- текущая сессия
  l_user     sec_user;
  res        integer;
  l_person   prs_person;
  l_uac      sec_user_authcred;
begin
  -- текущая сессия
  select * into l_session from sec_session_valid(p_session_id);
  -- поиск существующей учетной записи с таким именем
  begin
    select * into l_user from sec_user_by_name(p_name);
  exception
    when NO_DATA_FOUND then null;
  end;
  if (l_user.id is not null) then
    -- 'SEC00003', 'user %s already exists'
    raise exception unique_violation using message = env_resource_text_format('SEC00003', p_name);
  end if;
  -- проверка полномочий на выполнение операции
  perform sec_session_require_permission(p_session_id, 'sec_user.create');
  -- полномочий достаточно
  if (p_person_id is null) then
    l_person := prs_person_create(p_name, (prs_person_kind())."INDIVIDUAL", null, null);
    p_person_id := l_person.id;
  end if;
  insert into sec_user (id, person_id, name)
  values (default, p_person_id, p_name)
  returning * into l_user;
  insert into sec_user_authcred(user_id, auth_path_id, credential, credential_hash, valid_from, valid_till) 
  values (l_user.id, p_auth_path_id, null, null, clock_timestamp(), clock_timestamp()+interval '1 month')
  returning * into l_uac;
  -- регистрируем событие
  perform sec_event_log_start(p_session_id, 'sec_user', 'create', xmlforest(l_user));
  -- проверка учетных данных (пароля) на соответствие политике. 
  /*
  select * into res from sec_user_authcred_comply_policy(p_session_id, l_user.id, null, p_credential, p_auth_path_id);
  if (res <> env_resource_text_find_by_code('ANY00001')) then
    raise exception unique_violation using message = env_resource_text_format(res);
  end if;
  */
  -- Готовим учетные данные к хранению (хеш пароля, сертификат, идентификатор во внешней доверенной системе и т.п.)
  update sec_user_authcred
     set credential = sec_user_authcred_encrypt(p_session_id, l_user.id, p_credential, p_auth_path_id),
	 credential_hash = sec_user_authcred_hash(p_session_id, l_user.id, p_credential, p_auth_path_id)
   where user_id = l_user.id
     and auth_path_id = p_auth_path_id
  returning * into l_uac;
  -- сохраняем текущие учетные данные в журнал изменений
  insert into sec_user_authcred_log (log_id, when_logged, user_id, auth_path_id, credential, credential_hash, valid_from, valid_till)
  values (default, clock_timestamp(), l_uac.user_id, l_uac.auth_path_id, l_uac.credential, l_uac.credential_hash, l_uac.valid_from, l_uac.valid_till);
  return l_user;
end;
$$;


ALTER FUNCTION public.sec_user_create(p_session_id integer, p_person_id integer, p_name text, p_auth_path_id integer, p_credential text) OWNER TO postgres;

--
-- Name: FUNCTION sec_user_create(p_session_id integer, p_person_id integer, p_name text, p_auth_path_id integer, p_credential text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION sec_user_create(p_session_id integer, p_person_id integer, p_name text, p_auth_path_id integer, p_credential text) IS 'создание учетной записи';


--
-- Name: test_env(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION test_env() RETURNS boolean
    LANGUAGE plpgsql COST 10
    AS $$
declare
  -- модульные тесты проверки функций окружения 
  l_text  env_resource_text.content%type;
begin
  select env_resource_text_format('I1800001', 'zz') into l_text;
  if (l_text is null) then
    raise exception NO_DATA_FOUND using message = 'failed to format message with code I1800001';
  end if;
  return true;
end;
$$;


ALTER FUNCTION public.test_env() OWNER TO postgres;

--
-- Name: FUNCTION test_env(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION test_env() IS 'модульные тесты проверки функций окружения';


--
-- Name: test_sec(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION test_sec() RETURNS boolean
    LANGUAGE plpgsql COST 10
    AS $_$declare
  -- модульные тесты проверки операций над учетными записями и учетными данными
  c_auth_path_id  constant integer := 1; -- источник аутентификации админа (подойдет код любого существующего источника)
  l_root_token    sec_token;
  l_root_session  sec_session;
  c_auth_kind     constant text := 'pg_crypt';
  l_ak            sec_authentication_kind;
  l_ap            sec_authentication_path;
  c_user_name     constant text := 'test-001';
  c_credential    constant text := 'te$t-creDential#001';
  l_user          sec_user;
  l_token         sec_token;
  l_session       sec_session;
  l_cnt           integer;
  l_ok            integer;
  l_res           integer;
  l_uac           sec_user_authcred;
begin
  -- создаем сессию админа
  l_root_token := sec_login(uuid_generate()::text, c_auth_path_id, 'root');
  -- проверяем валидность созданной сессии
  l_root_session := sec_session_valid(l_root_token.session_id);
  -- поиск сессии
  select * into l_session from sec_session_find_by_id(l_root_token.session_id);
  -- схемы, виды аутентификации
  begin
    l_ak := sec_authentication_kind_by_code(c_auth_kind);
  exception
    when NO_DATA_FOUND then 
      l_ak := sec_authentication_kind_add(l_root_token.session_id, row(null, c_auth_kind, c_auth_kind));
  end;
  -- методы, способы и источники проверки аутентификации
  select * into l_ap
    from sec_authentication_path
   where authentication_kind_id = l_ak.id;
  -- поиск пользователя
  begin
    select * into l_user from sec_user_by_name(c_user_name);
  exception
    when NO_DATA_FOUND then
      l_user := sec_user_create(l_root_session.id, c_user_name, l_ap.id, c_credential);
  end;
  -- создаем сессию юзера
  l_token := sec_login(c_user_name, c_credential, l_ap.id);
  if (l_token is null) then
    raise warning NO_DATA_FOUND using message = 'sec_login failed. resulted token is NULL';
    -- сброс своего пароля
    if (not sec_user_authcred_reset_any(l_root_session.id, c_user_name, c_credential, l_ap.id)) then
      raise exception NO_DATA_FOUND using message = 'authcred NOT reseted';
    end if;
    l_token := sec_login(c_user_name, c_credential, l_ap.id);
  end if;
  if (l_token is null) then
    raise notice 'sec_login failed. resulted token is NULL';
  else
    raise notice using message = 'sec_login succeded. resulted token is NOT NULL. l_token.id='||l_token.id;
  end if;
  -- проверяем валидность созданной сессии
  l_session := sec_session_valid(l_token.session_id);
  -- проверка наличия валидных учетных данных для аутентификации
  select * into l_uac from sec_user_authcred_by_pk(l_session.user_id, l_token.auth_path_id);
  -- проверка учетных данных при аутентификации
  select count(*) into l_cnt from sec_user_authcred_accepted(l_session.user_id, c_credential, l_token.auth_path_id);
  if (l_cnt = 0) then
    raise exception NO_DATA_FOUND using message = 'authcred NOT accepted';
  end if;
  -- проверка учетных данных при аутентификации
  select count(*) into l_cnt from sec_user_authcred_accepted(c_user_name, c_credential, l_token.auth_path_id);
  if (l_cnt = 0) then
    raise exception NO_DATA_FOUND using message = 'authcred NOT accepted';
  end if;
  select * into l_ok from env_resource_text_find_by_code('ANY00001');
  if (l_ok is null) then
    raise exception NO_DATA_FOUND using message = 'env_resource_text_find_by_code failed to find resource with code "ANY00001"';
  end if;
  -- проверка на некорректные учетные данные
  select count(*) into l_cnt from sec_user_authcred_accepted(c_user_name, '-'||c_credential||'+', l_token.auth_path_id);
  if (l_cnt = 0) then
    raise notice 'wrong user_authcred not accepted';
  else 
    raise exception 'wrong user_authcred ACCEPTED';
  end if;

  -- период действия учетных данных - до сегодняшней полуночи
  select * into l_uac from sec_user_authcred_set_valid_period(l_root_session.id, l_uac.user_id, l_uac.auth_path_id, 'yesterday', 'today');
  -- проверка учетных данных при аутентификации
  select count(*) into l_cnt from sec_user_authcred_accepted(c_user_name, c_credential, l_token.auth_path_id);
  if (l_cnt = 0) then
    raise notice 'block out user_authcred. authcred not accepted';
  end if;
  -- период действия учетных данных - c сегодняшней полуночи до бексонечности
  select * into l_uac from sec_user_authcred_set_valid_period(l_root_session.id, l_uac.user_id, l_uac.auth_path_id, 'today', 'infinity');
  -- проверка учетных данных при аутентификации
  select count(*) into l_cnt from sec_user_authcred_accepted(c_user_name, c_credential, l_token.auth_path_id);
  if (l_cnt = 0) then
    raise exception 'unblock user_authcred. authcred NOT accepted';
  end if;
    -- завершаем сессию юзера
  l_token := sec_logout(l_token.localvalue);
  -- завершаем сессию админа
  l_root_token := sec_logout(l_root_token.localvalue);
  return true;
end;
$_$;


ALTER FUNCTION public.test_sec() OWNER TO postgres;

--
-- Name: FUNCTION test_sec(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION test_sec() IS 'модульные тесты проверки операций над учетными записями и учетными данными';


--
-- Name: uuid_generate(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION uuid_generate() RETURNS uuid
    LANGUAGE plpgsql COST 5
    AS $$declare
  l_result uuid;
begin
  -- random UUID generation 
  select md5(random()::text || clock_timestamp()::text)::uuid into l_result;
  return l_result;
end;
$$;


ALTER FUNCTION public.uuid_generate() OWNER TO postgres;

--
-- Name: FUNCTION uuid_generate(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION uuid_generate() IS 'random UUID generation';


SET default_with_oids = false;

--
-- Name: env_application; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE env_application (
    id integer NOT NULL,
    code character varying(50),
    name text
);


ALTER TABLE public.env_application OWNER TO postgres;

--
-- Name: TABLE env_application; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE env_application IS 'приложения, подсистемы, модули';


--
-- Name: env_application_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE env_application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.env_application_id_seq OWNER TO postgres;

--
-- Name: env_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE env_application_id_seq OWNED BY env_application.id;


--
-- Name: env_application_relation; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE env_application_relation (
    id integer NOT NULL,
    related_to_id integer NOT NULL
);


ALTER TABLE public.env_application_relation OWNER TO postgres;

--
-- Name: TABLE env_application_relation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE env_application_relation IS 'взаимозависимости приложений, подсистем, модулей';


--
-- Name: COLUMN env_application_relation.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN env_application_relation.id IS 'id приложения, подсистемы, модуля';


--
-- Name: COLUMN env_application_relation.related_to_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN env_application_relation.related_to_id IS 'id приложения, с которым связано данное';


--
-- Name: env_resource; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE env_resource (
    id integer NOT NULL,
    resource_kind_id integer NOT NULL
);


ALTER TABLE public.env_resource OWNER TO postgres;

--
-- Name: TABLE env_resource; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE env_resource IS 'ресурсы приложения - строки, изображения, и т.п.';


--
-- Name: env_resource_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE env_resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.env_resource_id_seq OWNER TO postgres;

--
-- Name: env_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE env_resource_id_seq OWNED BY env_resource.id;


--
-- Name: env_resource_kind; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE env_resource_kind (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.env_resource_kind OWNER TO postgres;

--
-- Name: TABLE env_resource_kind; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE env_resource_kind IS 'типы ресурсов приожения';


--
-- Name: env_resource_kind_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE env_resource_kind_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.env_resource_kind_id_seq OWNER TO postgres;

--
-- Name: env_resource_kind_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE env_resource_kind_id_seq OWNED BY env_resource_kind.id;


--
-- Name: env_severity_level; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE env_severity_level (
    id smallint NOT NULL,
    name character varying(10) NOT NULL
);


ALTER TABLE public.env_severity_level OWNER TO postgres;

--
-- Name: TABLE env_severity_level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE env_severity_level IS 'уровни важности сообщений';


--
-- Name: COLUMN env_severity_level.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN env_severity_level.id IS 'код';


--
-- Name: COLUMN env_severity_level.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN env_severity_level.name IS 'наименование';


--
-- Name: i18_country_depend; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE i18_country_depend (
    number3code integer NOT NULL,
    dependent_text character(50)
);


ALTER TABLE public.i18_country_depend OWNER TO postgres;

--
-- Name: TABLE i18_country_depend; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE i18_country_depend IS 'Принадлежность / подчиненность стран';


--
-- Name: i18_country_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE i18_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.i18_country_id_seq OWNER TO postgres;

--
-- Name: i18_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE i18_country_id_seq OWNED BY i18_country.id;


--
-- Name: i18_country_phoneprefix; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE i18_country_phoneprefix (
    number3code integer NOT NULL,
    prefix character(5) NOT NULL
);


ALTER TABLE public.i18_country_phoneprefix OWNER TO postgres;

--
-- Name: TABLE i18_country_phoneprefix; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE i18_country_phoneprefix IS 'телефонные коды стран';


--
-- Name: i18_currency; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE i18_currency (
    id integer NOT NULL,
    name character varying(250),
    alpha3code character(3),
    numeric3code smallint,
    minor_unit smallint,
    is_fund boolean
);


ALTER TABLE public.i18_currency OWNER TO postgres;

--
-- Name: TABLE i18_currency; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE i18_currency IS 'валюты
ISO 4217
http://www.currency-iso.org/en/home/tables/table-a1.html
';


--
-- Name: i18_currency_country; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE i18_currency_country (
    alpha3code character(3) NOT NULL,
    entity character varying(250) NOT NULL
);


ALTER TABLE public.i18_currency_country OWNER TO postgres;

--
-- Name: TABLE i18_currency_country; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE i18_currency_country IS 'валюты стран
ISO 4217
http://www.currency-iso.org/en/home/tables/table-a1.html
';


--
-- Name: i18_currency_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE i18_currency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.i18_currency_id_seq OWNER TO postgres;

--
-- Name: i18_currency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE i18_currency_id_seq OWNED BY i18_currency.id;


--
-- Name: i18_language_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE i18_language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.i18_language_id_seq OWNER TO postgres;

--
-- Name: i18_language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE i18_language_id_seq OWNED BY i18_language.id;


--
-- Name: lml_class; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE lml_class (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.lml_class OWNER TO postgres;

--
-- Name: TABLE lml_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE lml_class IS 'типы сущностей, классы объектов приложения и предметной области';


--
-- Name: COLUMN lml_class.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN lml_class.name IS 'наименование';


--
-- Name: lml_class_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE lml_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lml_class_id_seq OWNER TO postgres;

--
-- Name: lml_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE lml_class_id_seq OWNED BY lml_class.id;


--
-- Name: lml_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE lml_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lml_event_id_seq OWNER TO postgres;

--
-- Name: lml_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE lml_event_id_seq OWNED BY lml_event.id;


--
-- Name: lml_event_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE lml_event_status (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.lml_event_status OWNER TO postgres;

--
-- Name: TABLE lml_event_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE lml_event_status IS 'статус события';


--
-- Name: COLUMN lml_event_status.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN lml_event_status.name IS 'наименование события';


--
-- Name: lml_event_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE lml_event_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lml_event_status_id_seq OWNER TO postgres;

--
-- Name: lml_event_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE lml_event_status_id_seq OWNED BY lml_event_status.id;


--
-- Name: mdd_datatype; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mdd_datatype (
    id bigint NOT NULL,
    name character varying(128)
);


ALTER TABLE public.mdd_datatype OWNER TO postgres;

--
-- Name: TABLE mdd_datatype; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE mdd_datatype IS 'Типы данных';


--
-- Name: mdd_class; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mdd_class (
)
INHERITS (mdd_datatype);


ALTER TABLE public.mdd_class OWNER TO postgres;

--
-- Name: TABLE mdd_class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE mdd_class IS 'Классы';


--
-- Name: mdd_class_extention; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mdd_class_extention (
    class_id bigint NOT NULL,
    base_class_id bigint NOT NULL
);


ALTER TABLE public.mdd_class_extention OWNER TO postgres;

--
-- Name: TABLE mdd_class_extention; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE mdd_class_extention IS 'Наследование классов';


--
-- Name: mdd_class_sq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mdd_class_sq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mdd_class_sq OWNER TO postgres;

--
-- Name: mdd_datatype_sized; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mdd_datatype_sized (
    datasize bigint
)
INHERITS (mdd_datatype);


ALTER TABLE public.mdd_datatype_sized OWNER TO postgres;

--
-- Name: mdd_datatype_sq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mdd_datatype_sq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mdd_datatype_sq OWNER TO postgres;

--
-- Name: opn_operation; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE opn_operation (
    id integer NOT NULL,
    operation_kind_id integer NOT NULL,
    modified_on timestamp with time zone NOT NULL,
    modified_by integer NOT NULL,
    applied_on timestamp with time zone,
    applied_by integer,
    applied_order integer
);


ALTER TABLE public.opn_operation OWNER TO postgres;

--
-- Name: TABLE opn_operation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE opn_operation IS 'журнал бизнес-операций';


--
-- Name: COLUMN opn_operation.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation.id IS 'идентификатор';


--
-- Name: COLUMN opn_operation.operation_kind_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation.operation_kind_id IS 'код типа бизнес-операции';


--
-- Name: COLUMN opn_operation.modified_on; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation.modified_on IS 'дата / время создания или последней модификации';


--
-- Name: COLUMN opn_operation.modified_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation.modified_by IS 'пользователь, создавший запись или внесший в нее последнюю модификацию';


--
-- Name: COLUMN opn_operation.applied_on; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation.applied_on IS 'дата / время применения (выполнения) операции';


--
-- Name: COLUMN opn_operation.applied_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation.applied_by IS 'пользователь, применивший (выполнивший) операцию';


--
-- Name: COLUMN opn_operation.applied_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation.applied_order IS 'порядковый номер выполнения (применения) операции';


--
-- Name: opn_operation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE opn_operation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.opn_operation_id_seq OWNER TO postgres;

--
-- Name: opn_operation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE opn_operation_id_seq OWNED BY opn_operation.id;


--
-- Name: opn_operation_kind; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE opn_operation_kind (
    id integer NOT NULL,
    name character varying(255),
    class_id integer NOT NULL
);


ALTER TABLE public.opn_operation_kind OWNER TO postgres;

--
-- Name: TABLE opn_operation_kind; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE opn_operation_kind IS 'типы бизнес-операций';


--
-- Name: COLUMN opn_operation_kind.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation_kind.id IS 'идентификатор';


--
-- Name: COLUMN opn_operation_kind.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation_kind.name IS 'наименование';


--
-- Name: COLUMN opn_operation_kind.class_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_operation_kind.class_id IS 'код целевого класса объекта для операции';


--
-- Name: opn_operation_kind_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE opn_operation_kind_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.opn_operation_kind_id_seq OWNER TO postgres;

--
-- Name: opn_operation_kind_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE opn_operation_kind_id_seq OWNED BY opn_operation_kind.id;


--
-- Name: opn_person; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE opn_person (
    operation_id integer NOT NULL,
    person_id integer NOT NULL,
    citizenship_country_id integer,
    language_id integer,
    person_kind_id smallint
);


ALTER TABLE public.opn_person OWNER TO postgres;

--
-- Name: TABLE opn_person; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE opn_person IS 'операция по созданию/модификации/удалению физ. и юр.лица';


--
-- Name: COLUMN opn_person.operation_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person.operation_id IS 'код операции';


--
-- Name: COLUMN opn_person.person_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person.person_id IS 'код физ. / юр.лица';


--
-- Name: COLUMN opn_person.citizenship_country_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person.citizenship_country_id IS 'гражданство, национальная принадлежность, подданство';


--
-- Name: COLUMN opn_person.language_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person.language_id IS 'родной (основной) язык для общения';


--
-- Name: COLUMN opn_person.person_kind_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person.person_kind_id IS 'тип персоны';


--
-- Name: opn_person_individual; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE opn_person_individual (
    operation_id integer NOT NULL,
    person_id integer NOT NULL,
    last_name character varying(255),
    middle_name character varying(255),
    first_name character varying(255),
    birthdate date
);


ALTER TABLE public.opn_person_individual OWNER TO postgres;

--
-- Name: TABLE opn_person_individual; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE opn_person_individual IS 'операция по созданию/модификации/удалению физического лица';


--
-- Name: COLUMN opn_person_individual.operation_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_individual.operation_id IS 'код операции';


--
-- Name: COLUMN opn_person_individual.person_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_individual.person_id IS 'код физ.лица';


--
-- Name: COLUMN opn_person_individual.last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_individual.last_name IS 'Фамилия';


--
-- Name: COLUMN opn_person_individual.middle_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_individual.middle_name IS 'Отчество';


--
-- Name: COLUMN opn_person_individual.first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_individual.first_name IS 'Имя';


--
-- Name: COLUMN opn_person_individual.birthdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_individual.birthdate IS 'Дата рождения';


--
-- Name: opn_person_legal; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE opn_person_legal (
    operation_id integer NOT NULL,
    person_id integer NOT NULL,
    name_short character varying(255),
    name_long character varying(511)
);


ALTER TABLE public.opn_person_legal OWNER TO postgres;

--
-- Name: TABLE opn_person_legal; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE opn_person_legal IS 'операция по созданию/модификации/удалению юридического лица';


--
-- Name: COLUMN opn_person_legal.operation_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_legal.operation_id IS 'код операции';


--
-- Name: COLUMN opn_person_legal.person_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_legal.person_id IS 'код юр.лица';


--
-- Name: COLUMN opn_person_legal.name_short; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_legal.name_short IS 'Краткое наименование';


--
-- Name: COLUMN opn_person_legal.name_long; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN opn_person_legal.name_long IS 'Полное наименование';


--
-- Name: prs_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE prs_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prs_person_id_seq OWNER TO postgres;

--
-- Name: prs_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE prs_person_id_seq OWNED BY prs_person.id;


--
-- Name: prs_person_individual; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE prs_person_individual (
    person_id integer NOT NULL,
    last_name character varying(255),
    middle_name character varying(255),
    first_name character varying(255),
    birthdate date
);


ALTER TABLE public.prs_person_individual OWNER TO postgres;

--
-- Name: TABLE prs_person_individual; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE prs_person_individual IS 'Физические лица';


--
-- Name: COLUMN prs_person_individual.last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_individual.last_name IS 'Фамилия';


--
-- Name: COLUMN prs_person_individual.middle_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_individual.middle_name IS 'Отчество';


--
-- Name: COLUMN prs_person_individual.first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_individual.first_name IS 'Имя';


--
-- Name: COLUMN prs_person_individual.birthdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_individual.birthdate IS 'Дата рождения';


--
-- Name: prs_person_kind_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE prs_person_kind_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prs_person_kind_id_seq OWNER TO postgres;

--
-- Name: prs_person_kind_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE prs_person_kind_id_seq OWNED BY prs_person_kind.id;


--
-- Name: prs_person_legal; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE prs_person_legal (
    person_id integer NOT NULL,
    name_short character varying(255),
    name_long character varying(511)
);


ALTER TABLE public.prs_person_legal OWNER TO postgres;

--
-- Name: COLUMN prs_person_legal.name_short; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_legal.name_short IS 'Краткое наименование';


--
-- Name: COLUMN prs_person_legal.name_long; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN prs_person_legal.name_long IS 'Полное наименование';


--
-- Name: sec_authentication_path_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sec_authentication_path_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_authentication_path_id_seq OWNER TO postgres;

--
-- Name: sec_authentication_path_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sec_authentication_path_id_seq OWNED BY sec_authentication_path.id;


--
-- Name: sec_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sec_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_session_id_seq OWNER TO postgres;

--
-- Name: sec_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sec_session_id_seq OWNED BY sec_session.id;


--
-- Name: sec_session_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_session_log (
    user_id integer NOT NULL,
    whenstarted timestamp with time zone NOT NULL,
    whenended timestamp with time zone,
    id integer NOT NULL,
    when_logged timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.sec_session_log OWNER TO postgres;

--
-- Name: COLUMN sec_session_log.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session_log.user_id IS 'код пользователя';


--
-- Name: COLUMN sec_session_log.whenstarted; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session_log.whenstarted IS 'дата/время начала сессии';


--
-- Name: COLUMN sec_session_log.whenended; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session_log.whenended IS 'дата/время завершения сессии (если была завершена явным образом)';


--
-- Name: COLUMN sec_session_log.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_session_log.id IS 'идентификатор сессии';


--
-- Name: sec_token_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sec_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_token_id_seq OWNER TO postgres;

--
-- Name: sec_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sec_token_id_seq OWNED BY sec_token.id;


--
-- Name: sec_token_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_token_log (
    id integer NOT NULL,
    localvalue text NOT NULL,
    credential text,
    auth_path_id integer,
    session_id integer NOT NULL,
    validfrom timestamp with time zone NOT NULL,
    validtill timestamp with time zone,
    originvalue text,
    when_logged timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.sec_token_log OWNER TO postgres;

--
-- Name: COLUMN sec_token_log.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.id IS 'идентификатор токена';


--
-- Name: COLUMN sec_token_log.localvalue; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.localvalue IS 'локализованное (уникальное) значение токена';


--
-- Name: COLUMN sec_token_log.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.credential IS 'Учетные данные, использованные при аутентификации';


--
-- Name: COLUMN sec_token_log.auth_path_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.auth_path_id IS 'источник аутентификации';


--
-- Name: COLUMN sec_token_log.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.session_id IS 'идентификатор сессии';


--
-- Name: COLUMN sec_token_log.validfrom; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.validfrom IS 'момент (включительно) начала действия токена';


--
-- Name: COLUMN sec_token_log.validtill; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.validtill IS 'момент (включительно) окончания действия токена';


--
-- Name: COLUMN sec_token_log.originvalue; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_log.originvalue IS 'исходное оригинальное значение токена, полученное от источника аутентификации';


--
-- Name: sec_token_session; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW sec_token_session AS
SELECT t.id, t.localvalue, t.credential, t.auth_path_id, t.session_id, t.validfrom, t.validtill, t.originvalue, s.user_id, s.whenstarted AS whensessionstarted, s.whenended AS whensessionended FROM (sec_token t JOIN sec_session s ON ((s.id = t.session_id)));


ALTER TABLE public.sec_token_session OWNER TO postgres;

--
-- Name: VIEW sec_token_session; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW sec_token_session IS 'сессии пользователей и ассоциированные с ними токены безопасности';


--
-- Name: COLUMN sec_token_session.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.id IS 'идентификатор токена';


--
-- Name: COLUMN sec_token_session.localvalue; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.localvalue IS 'локализованное (уникальное) значение токена';


--
-- Name: COLUMN sec_token_session.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.credential IS 'Учетные данные, использованные при аутентификации';


--
-- Name: COLUMN sec_token_session.auth_path_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.auth_path_id IS 'источник аутентификации';


--
-- Name: COLUMN sec_token_session.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.session_id IS 'идентификатор сессии';


--
-- Name: COLUMN sec_token_session.validfrom; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.validfrom IS 'момент (включительно) начала действия токена';


--
-- Name: COLUMN sec_token_session.validtill; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.validtill IS 'момент (включительно) окончания действия токена';


--
-- Name: COLUMN sec_token_session.originvalue; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.originvalue IS 'исходное оригинальное значение токена, полученное от источника аутентификации';


--
-- Name: COLUMN sec_token_session.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.user_id IS 'код пользователя';


--
-- Name: COLUMN sec_token_session.whensessionstarted; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.whensessionstarted IS 'дата/время начала сессии';


--
-- Name: COLUMN sec_token_session.whensessionended; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_token_session.whensessionended IS 'дата/время завершения сессии (если была завершена явным образом)';


--
-- Name: sec_user_authcred_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sec_user_authcred_log (
    log_id integer NOT NULL,
    user_id integer NOT NULL,
    auth_path_id integer NOT NULL,
    credential character varying(511),
    valid_from timestamp with time zone NOT NULL,
    valid_till timestamp with time zone NOT NULL,
    credential_hash text,
    when_logged timestamp with time zone NOT NULL
);


ALTER TABLE public.sec_user_authcred_log OWNER TO postgres;

--
-- Name: TABLE sec_user_authcred_log; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sec_user_authcred_log IS 'Журнал изменений учетныx данныx для аутентификации';


--
-- Name: COLUMN sec_user_authcred_log.log_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.log_id IS 'идентификатор строки журнала';


--
-- Name: COLUMN sec_user_authcred_log.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.user_id IS 'код пользователя';


--
-- Name: COLUMN sec_user_authcred_log.auth_path_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.auth_path_id IS 'источник аутентификации';


--
-- Name: COLUMN sec_user_authcred_log.credential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.credential IS 'Учетные данные (хеш пароля, сертификат, идентификатор во внешней доверенной системе и т.п.)';


--
-- Name: COLUMN sec_user_authcred_log.valid_from; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.valid_from IS 'момент начала действия (включительно)';


--
-- Name: COLUMN sec_user_authcred_log.valid_till; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.valid_till IS 'момент окончания действия (включительно)';


--
-- Name: COLUMN sec_user_authcred_log.credential_hash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.credential_hash IS 'Хеш учетных данных';


--
-- Name: COLUMN sec_user_authcred_log.when_logged; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sec_user_authcred_log.when_logged IS 'Момент занесения в журнад';


--
-- Name: sec_user_authcred_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sec_user_authcred_log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_user_authcred_log_log_id_seq OWNER TO postgres;

--
-- Name: sec_user_authcred_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sec_user_authcred_log_log_id_seq OWNED BY sec_user_authcred_log.log_id;


--
-- Name: sec_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sec_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_user_id_seq OWNER TO postgres;

--
-- Name: sec_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sec_user_id_seq OWNED BY sec_user.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_application ALTER COLUMN id SET DEFAULT nextval('env_application_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_resource ALTER COLUMN id SET DEFAULT nextval('env_resource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_resource_kind ALTER COLUMN id SET DEFAULT nextval('env_resource_kind_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY i18_country ALTER COLUMN id SET DEFAULT nextval('i18_country_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY i18_currency ALTER COLUMN id SET DEFAULT nextval('i18_currency_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY i18_language ALTER COLUMN id SET DEFAULT nextval('i18_language_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lml_class ALTER COLUMN id SET DEFAULT nextval('lml_class_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lml_event ALTER COLUMN id SET DEFAULT nextval('lml_event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lml_event_status ALTER COLUMN id SET DEFAULT nextval('lml_event_status_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_operation ALTER COLUMN id SET DEFAULT nextval('opn_operation_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_operation_kind ALTER COLUMN id SET DEFAULT nextval('opn_operation_kind_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY prs_person ALTER COLUMN id SET DEFAULT nextval('prs_person_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY prs_person_kind ALTER COLUMN id SET DEFAULT nextval('prs_person_kind_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_authentication_path ALTER COLUMN id SET DEFAULT nextval('sec_authentication_path_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_session ALTER COLUMN id SET DEFAULT nextval('sec_session_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_token ALTER COLUMN id SET DEFAULT nextval('sec_token_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_user ALTER COLUMN id SET DEFAULT nextval('sec_user_id_seq'::regclass);


--
-- Name: log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_user_authcred_log ALTER COLUMN log_id SET DEFAULT nextval('sec_user_authcred_log_log_id_seq'::regclass);


--
-- Data for Name: env_application; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY env_application (id, code, name) FROM stdin;
1	MDD	Master data dictionary
2	test01	test application #1
\.


--
-- Name: env_application_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('env_application_id_seq', 2, true);


--
-- Data for Name: env_application_relation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY env_application_relation (id, related_to_id) FROM stdin;
\.


--
-- Data for Name: env_resource; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY env_resource (id, resource_kind_id) FROM stdin;
1	1
2	1
3	1
4	1
6	1
8	1
9	1
10	1
11	1
12	1
13	1
14	1
15	1
16	1
17	1
18	1
19	1
20	1
21	1
5	1
22	1
23	1
24	1
25	1
26	1
27	1
28	1
29	1
30	1
31	1
32	1
33	1
34	1
35	1
36	1
37	1
38	1
39	1
40	1
41	1
42	1
43	1
44	1
45	1
46	1
47	1
48	1
49	1
50	1
51	1
52	1
53	1
54	1
55	1
56	1
57	1
58	1
59	1
60	1
61	1
\.


--
-- Name: env_resource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('env_resource_id_seq', 62, true);


--
-- Data for Name: env_resource_kind; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY env_resource_kind (id, name) FROM stdin;
1	текст
2	изображение
\.


--
-- Name: env_resource_kind_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('env_resource_kind_id_seq', 2, true);


--
-- Data for Name: env_resource_text; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY env_resource_text (id, content, code, language_id) FROM stdin;
1	resource id=%1$s not found (in env_resource_text). can not format resource text	RES00001	45
2	resource id=%1$s not unique	RES00002	45
4	language alpha2code=%s not unique	I1800002	45
3	language alpha2code=%s not found	I1800001	45
6	language alpha3code=%s not found	I1800003	45
8	language alpha3code=%s not unique	I1800004	45
9	user %s not found	SEC00001	45
10	user %s not unique	SEC00002	45
11	unknown severity level (%s)	ENV00001	45
12	user %s already exists	SEC00003	45
13	access denied. has no permission (%s)	SEC00004	45
14	session %s not found	SEC00005	45
15	session %s expired	SEC00006	45
17	event %2$s not found in class %1$s	ENV00002	45
18	event %2$s not unique in class %1$s	ENV00003	45
20	no valid credentials found for user (%s) and authentication path id (%s)	SEC00009	45
21	authentication path id is not defined or user (%s) has more than one different authentication paths	SEC00010	45
5	ok (no errors)	ANY00001	45
23	authentication path id (%s) not unique	SEC00012	45
16	wrong or unknown username (%s) or credential/authentication path	SEC00007	45
19	session id (%s) not found	SEC00008	45
24	user id %s not found	SEC00013	45
25	user id %s not unique	SEC00014	45
26	text "%1$s" looks similar to "%2$s"	RES00003	45
27	text "%1$s" is not similar to "%2$s"	RES00004	45
22	authentication path id (%s) not found	SEC00011	45
28	credential length (%1$s) less than minimum allowed (%2$s)	SEC00015	45
29	credential must contain at least one digit	SEC00016	45
30	credential must contain at least one letter	SEC00017	45
31	credential must contain at least one lower case letter	SEC00018	45
32	credential must contain at least one upper case letter	SEC00019	45
33	credential must contain at least one punctuation character	SEC00020	45
34	credential must not be similar to previous one	SEC00022	45
35	credential must not be changed "%1$s" after previos changes at "%2$s"	SEC00023	45
36	token "%s" expired	SEC00025	45
37	token "%s" not found	SEC00026	45
40	country alpha2code=%s not found	I1800005	45
41	country alpha2code=%s not unique	I1800006	45
42	country alpha3code=%s not found	I1800007	45
43	country alpha3code=%s not unique	I1800008	45
44	country number3code=%s not found	I1800009	45
45	country number3code=%s not unique	I1800010	45
46	country name=%s not found	I1800011	45
47	country name=%s not unique	I1800012	45
48	person kind id=%s not found	PRS00001	45
49	person kind id=%s not unique	PRS00002	45
50	country alpha2code or alpha3code "%s" not found	I1800013	45
51	country alpha2code or alpha3code "%s" not unique	I1800014	45
52	language alpha2code or alpha3code "%s" not found	I1800015	45
53	language alpha2code or alpha3code "%s" not unique	I1800016	45
54	authentication credential not found for user id "%1$s" and authentication path id "%2$s"	SEC00029	45
55	authentication credential not unique for user id "%1$s" and authentication path id "%2$s"	SEC00030	45
56	authentication kind not found by name "%s"	SEC00031	45
57	authentication kind not unique by name "%s"	SEC00032	45
58	authentication kind not found by code "%s"	SEC00033	45
59	authentication kind not unique by code "%s"	SEC00034	45
39	token value "%1$s" not unique	SEC00028	45
60	value "%2$s" of "%1$s" must be not null	SEC00035	45
38	token value "%1$s" not found	SEC00027	45
61	credential must not be similar to user name	SEC00021	45
\.


--
-- Data for Name: env_severity_level; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY env_severity_level (id, name) FROM stdin;
0	EXCEPTION
1	WARNING
2	NOTICE
3	INFO
4	LOG
5	DEBUG
\.


--
-- Data for Name: i18_country; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY i18_country (id, name, number3code, alpha2code, alpha3code) FROM stdin;
1	Afghanistan	4	AF	AFG
2	Åland	248	AX	ALA
3	Albania	8	AL	ALB
4	Algeria	12	DZ	DZA
5	American Samoa	16	AS	ASM
6	Andorra	20	AD	AND
7	Angola	24	AO	AGO
8	Anguilla	660	AI	AIA
9	Antarctica	10	AQ	ATA
10	Antigua and Barbuda	28	AG	ATG
11	Argentina	32	AR	ARG
12	Armenia	51	AM	ARM
13	Aruba	533	AW	ABW
14	Australia	36	AU	AUS
15	Austria	40	AT	AUT
16	Azerbaijan	31	AZ	AZE
17	Bahamas	44	BS	BHS
18	Bahrain	48	BH	BHR
19	Bangladesh	50	BD	BGD
20	Barbados	52	BB	BRB
21	Belarus	112	BY	BLR
22	Belgium	56	BE	BEL
23	Belize	84	BZ	BLZ
24	Benin	204	BJ	BEN
25	Bermuda	60	BM	BMU
26	Bhutan	64	BT	BTN
27	Bolivia	68	BO	BOL
28	Bonaire, Sint Eustatiusand Saba	535	BQ	BES
29	Bosnia and Herzegovina	70	BA	BIH
30	Botswana	72	BW	BWA
31	Bouvet Island	74	BV	BVT
32	Brazil	76	BR	BRA
33	British Indian OceanTerritory	86	IO	IOT
34	Brunei Darussalam	96	BN	BRN
35	Bulgaria	100	BG	BGR
36	Burkina Faso	854	BF	BFA
37	Burundi	108	BI	BDI
38	Cambodia	116	KH	KHM
39	Cameroon	120	CM	CMR
40	Canada	124	CA	CAN
41	Cape Verde	132	CV	CPV
42	Cayman Islands	136	KY	CYM
43	Central African Republic	140	CF	CAF
44	Chad	148	TD	TCD
45	Chile	152	CL	CHL
46	China	156	CN	CHN
47	Christmas Island	162	CX	CXR
48	Cocos (Keeling) Islands	166	CC	CCK
49	Colombia	170	CO	COL
50	Comoros	174	KM	COM
51	Congo (Brazzaville)	178	CG	COG
52	Congo (Kinshasa)	180	CD	COD
53	Cook Islands	184	CK	COK
54	Costa Rica	188	CR	CRI
55	Côte d`Ivoire	384	CI	CIV
56	Croatia	191	HR	HRV
57	Cuba	192	CU	CUB
58	Curaçao	531	CW	CUW
59	Cyprus	196	CY	CYP
60	Czech Republic	203	CZ	CZE
61	Denmark	208	DK	DNK
62	Djibouti	262	DJ	DJI
63	Dominica	212	DM	DMA
64	Dominican Republic	214	DO	DOM
65	Ecuador	218	EC	ECU
66	Egypt	818	EG	EGY
67	El Salvador	222	SV	SLV
68	Equatorial Guinea	226	GQ	GNQ
69	Eritrea	232	ER	ERI
70	Estonia	233	EE	EST
71	Ethiopia	231	ET	ETH
72	Falkland Islands	238	FK	FLK
73	Faroe Islands	234	FO	FRO
74	Fiji	242	FJ	FJI
75	Finland	246	FI	FIN
76	France	250	FR	FRA
77	French Guiana	254	GF	GUF
78	French Polynesia	258	PF	PYF
79	French Southern Lands	260	TF	ATF
80	Gabon	266	GA	GAB
81	Gambia	270	GM	GMB
82	Georgia	268	GE	GEO
83	Germany	276	DE	DEU
84	Ghana	288	GH	GHA
85	Gibraltar	292	GI	GIB
86	Greece	300	GR	GRC
87	Greenland	304	GL	GRL
88	Grenada	308	GD	GRD
89	Guadeloupe	312	GP	GLP
90	Guam	316	GU	GUM
91	Guatemala	320	GT	GTM
92	Guernsey	831	GG	GGY
93	Guinea	324	GN	GIN
94	Guinea-Bissau	624	GW	GNB
95	Guyana	328	GY	GUY
96	Haiti	332	HT	HTI
97	Heard and McDonald Islands	334	HM	HMD
98	Honduras	340	HN	HND
99	Hong Kong	344	HK	HKG
100	Hungary	348	HU	HUN
101	Iceland	352	IS	ISL
102	India	356	IN	IND
103	Indonesia	360	ID	IDN
104	Iran	364	IR	IRN
105	Iraq	368	IQ	IRQ
106	Ireland	372	IE	IRL
107	Isle of Man	833	IM	IMN
108	Israel	376	IL	ISR
109	Italy	380	IT	ITA
110	Jamaica	388	JM	JAM
111	Japan	392	JP	JPN
112	Jersey	832	JE	JEY
113	Jordan	400	JO	JOR
114	Kazakhstan	398	KZ	KAZ
115	Kenya	404	KE	KEN
116	Kiribati	296	KI	KIR
117	Korea, North	408	KP	PRK
118	Korea, South	410	KR	KOR
119	Kuwait	414	KW	KWT
120	Kyrgyzstan	417	KG	KGZ
121	Laos	418	LA	LAO
122	Latvia	428	LV	LVA
123	Lebanon	422	LB	LBN
124	Lesotho	426	LS	LSO
125	Liberia	430	LR	LBR
126	Libya	434	LY	LBY
127	Liechtenstein	438	LI	LIE
128	Lithuania	440	LT	LTU
129	Luxembourg	442	LU	LUX
130	Macau	446	MO	MAC
131	Macedonia	807	MK	MKD
132	Madagascar	450	MG	MDG
133	Malawi	454	MW	MWI
134	Malaysia	458	MY	MYS
135	Maldives	462	MV	MDV
136	Mali	466	ML	MLI
137	Malta	470	MT	MLT
138	Marshall Islands	584	MH	MHL
139	Martinique	474	MQ	MTQ
140	Mauritania	478	MR	MRT
141	Mauritius	480	MU	MUS
142	Mayotte	175	YT	MYT
143	Mexico	484	MX	MEX
144	Micronesia	583	FM	FSM
145	Moldova	498	MD	MDA
146	Monaco	492	MC	MCO
147	Mongolia	496	MN	MNG
148	Montenegro	499	ME	MNE
149	Montserrat	500	MS	MSR
150	Morocco	504	MA	MAR
151	Mozambique	508	MZ	MOZ
152	Myanmar	104	MM	MMR
153	Namibia	516	NA	NAM
154	Nauru	520	NR	NRU
155	Nepal	524	NP	NPL
156	Netherlands	528	NL	NLD
157	New Caledonia	540	NC	NCL
158	New Zealand	554	NZ	NZL
159	Nicaragua	558	NI	NIC
160	Niger	562	NE	NER
161	Nigeria	566	NG	NGA
162	Niue	570	NU	NIU
163	Norfolk Island	574	NF	NFK
164	Northern Mariana Islands	580	MP	MNP
165	Norway	578	NO	NOR
166	Oman	512	OM	OMN
167	Pakistan	586	PK	PAK
168	Palau	585	PW	PLW
169	Palestine	275	PS	PSE
170	Panama	591	PA	PAN
171	Papua New Guinea	598	PG	PNG
172	Paraguay	600	PY	PRY
173	Peru	604	PE	PER
174	Philippines	608	PH	PHL
175	Pitcairn	612	PN	PCN
176	Poland	616	PL	POL
177	Portugal	620	PT	PRT
178	Puerto Rico	630	PR	PRI
179	Qatar	634	QA	QAT
180	Reunion	638	RE	REU
181	Romania	642	RO	ROU
182	Russian Federation	643	RU	RUS
183	Rwanda	646	RW	RWA
184	Saint Barthélemy	652	BL	BLM
185	Saint Helena	654	SH	SHN
186	Saint Kitts and Nevis	659	KN	KNA
187	Saint Lucia	662	LC	LCA
188	Saint Martin (French part)	663	MF	MAF
189	Saint Pierre and Miquelon	666	PM	SPM
190	Saint Vincent and theGrenadines	670	VC	VCT
191	Samoa	882	WS	WSM
192	San Marino	674	SM	SMR
193	Sao Tome and Principe	678	ST	STP
194	Saudi Arabia	682	SA	SAU
195	Senegal	686	SN	SEN
196	Serbia	688	RS	SRB
197	Seychelles	690	SC	SYC
198	Sierra Leone	694	SL	SLE
199	Singapore	702	SG	SGP
200	Sint Maarten	534	SX	SXM
201	Slovakia	703	SK	SVK
202	Slovenia	705	SI	SVN
203	Solomon Islands	90	SB	SLB
204	Somalia	706	SO	SOM
205	South Africa	710	ZA	ZAF
206	South Georgia and SouthSandwich Islands	239	GS	SGS
207	South Sudan	728	SS	SSD
208	Spain	724	ES	ESP
209	Sri Lanka	144	LK	LKA
210	Sudan	729	SD	SDN
211	Suriname	740	SR	SUR
212	Svalbard and Jan MayenIslands	744	SJ	SJM
213	Swaziland	748	SZ	SWZ
214	Sweden	752	SE	SWE
215	Switzerland	756	CH	CHE
216	Syria	760	SY	SYR
217	Taiwan	158	TW	TWN
218	Tajikistan	762	TJ	TJK
219	Tanzania	834	TZ	TZA
220	Thailand	764	TH	THA
221	Timor-Leste	626	TL	TLS
222	Togo	768	TG	TGO
223	Tokelau	772	TK	TKL
224	Tonga	776	TO	TON
225	Trinidad and Tobago	780	TT	TTO
226	Tunisia	788	TN	TUN
227	Turkey	792	TR	TUR
228	Turkmenistan	795	TM	TKM
229	Turks and Caicos Islands	796	TC	TCA
230	Tuvalu	798	TV	TUV
231	Uganda	800	UG	UGA
232	Ukraine	804	UA	UKR
233	United Arab Emirates	784	AE	ARE
234	United Kingdom	826	GB	GBR
235	United States MinorOutlying Islands	581	UM	UMI
236	United States of America	840	US	USA
237	Uruguay	858	UY	URY
238	Uzbekistan	860	UZ	UZB
239	Vanuatu	548	VU	VUT
240	Vatican City	336	VA	VAT
241	Venezuela	862	VE	VEN
242	Vietnam	704	VN	VNM
243	Virgin Islands, British	92	VG	VGB
244	Virgin Islands, U.S.	850	VI	VIR
245	Wallis and Futuna Islands	876	WF	WLF
246	Western Sahara	732	EH	ESH
247	Yemen	887	YE	YEM
248	Zambia	894	ZM	ZMB
249	Zimbabwe	716	ZW	ZWE
\.


--
-- Data for Name: i18_country_depend; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY i18_country_depend (number3code, dependent_text) FROM stdin;
248	Part of FI                                        
16	Territory of US                                   
660	Territory of GB                                   
10	International                                     
533	Part of NL                                        
60	Territory of GB                                   
535	Part of NL                                        
74	Territory of NO                                   
86	Territory of GB                                   
136	Territory of GB                                   
162	Territory of AU                                   
166	Territory of AU                                   
184	Associated with NZ                                
531	Part of NL                                        
238	Territory of GB                                   
234	Part of DK                                        
254	Part of FR                                        
258	Territory of FR                                   
260	Territory of FR                                   
292	Territory of GB                                   
304	Part of DK                                        
312	Part of FR                                        
316	Territory of US                                   
831	Crown dependency of GB                            
334	Territory of AU                                   
344	Part of CN                                        
833	Crown dependency of GB                            
832	Crown dependency of GB                            
446	Part of CN                                        
474	Part of FR                                        
175	Part of FR                                        
500	Territory of GB                                   
540	Territory of FR                                   
570	Associated with NZ                                
574	Territory of AU                                   
580	Commonwealth of US                                
275	In contention                                     
612	Territory of GB                                   
630	Commonwealth of US                                
638	Part of FR                                        
652	Part of FR                                        
654	Territory of GB                                   
663	Part of FR                                        
666	Part of FR                                        
534	Part of NL                                        
239	Territory of GB                                   
744	Territory of NO                                   
772	Territory of NZ                                   
796	Territory of GB                                   
581	Territories of US                                 
92	Territory of GB                                   
850	Territory of US                                   
876	Territory of FR                                   
732	In contention                                     
\.


--
-- Name: i18_country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('i18_country_id_seq', 249, true);


--
-- Data for Name: i18_country_phoneprefix; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY i18_country_phoneprefix (number3code, prefix) FROM stdin;
4	93   
248	358  
8	355  
12	213  
16	1-684
20	376  
24	244  
660	1-264
10	672  
28	1-268
32	54   
51	374  
533	297  
36	61   
40	43   
31	994  
44	1-242
48	973  
50	880  
52	1-246
112	375  
56	32   
84	501  
204	229  
60	1-441
64	975  
68	591  
535	599  
70	387  
72	267  
74	47   
76	55   
86	246  
96	673  
100	359  
854	226  
108	257  
116	855  
120	237  
124	1    
132	238  
136	1-345
140	236  
148	235  
152	56   
156	86   
162	61   
166	61   
170	57   
174	269  
178	242  
180	243  
184	682  
188	506  
384	225  
191	385  
192	53   
531	599  
196	357  
203	420  
208	45   
262	253  
212	1-767
214	1-809
214	1-829
214	1-849
218	593  
818	20   
222	503  
226	240  
232	291  
233	372  
231	251  
238	500  
234	298  
242	679  
246	358  
250	33   
254	594  
258	689  
260	262  
266	241  
270	220  
268	995  
276	49   
288	233  
292	350  
300	30   
304	299  
308	1-473
312	590  
316	1-671
320	502  
831	44   
324	224  
624	245  
328	592  
332	509  
334	672  
340	504  
344	852  
348	36   
352	354  
356	91   
360	62   
364	98   
368	964  
372	353  
833	44   
376	972  
380	39   
388	1-876
392	81   
832	44   
400	962  
398	7    
404	254  
296	686  
408	850  
410	82   
414	965  
417	996  
418	856  
428	371  
422	961  
426	266  
430	231  
434	218  
438	423  
440	370  
442	352  
446	853  
807	389  
450	261  
454	265  
458	60   
462	960  
466	223  
470	356  
584	692  
474	596  
478	222  
480	230  
175	262  
484	52   
583	691  
498	373  
492	377  
496	976  
499	382  
500	1-664
504	212  
508	258  
104	95   
516	264  
520	674  
524	977  
528	31   
540	687  
554	64   
558	505  
562	227  
566	234  
570	683  
574	672  
580	1-670
578	47   
512	968  
586	92   
585	680  
275	970  
591	507  
598	675  
600	595  
604	51   
608	63   
612	870  
616	48   
620	351  
630	1    
634	974  
638	262  
642	40   
643	7    
646	250  
652	590  
654	290  
659	1-869
662	1-758
663	590  
666	508  
670	1-784
882	685  
674	378  
678	239  
682	966  
686	221  
688	381 p
690	248  
694	232  
702	65   
534	1-721
703	421  
705	386  
90	677  
706	252  
710	27   
239	500  
728	211  
724	34   
144	94   
729	249  
740	597  
744	47   
748	268  
752	46   
756	41   
760	963  
158	886  
762	992  
834	255  
764	66   
626	670  
768	228  
772	690  
776	676  
780	1-868
788	216  
792	90   
795	993  
796	1-649
798	688  
800	256  
804	380  
784	971  
826	44   
840	1    
858	598  
860	998  
548	678  
336	39-06
862	58   
704	84   
92	1-284
850	1-340
876	681  
732	212  
887	967  
894	260  
716	263  
\.


--
-- Data for Name: i18_currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY i18_currency (id, name, alpha3code, numeric3code, minor_unit, is_fund) FROM stdin;
1	UAE Dirham	AED	784	2	f
2	Afghani	AFN	971	2	f
3	Lek	ALL	8	2	f
4	Armenian Dram	AMD	51	2	f
5	Netherlands Antillean Guilder	ANG	532	2	f
6	Kwanza	AOA	973	2	f
7	Argentine Peso	ARS	32	2	f
8	Australian Dollar	AUD	36	2	f
9	Aruban Florin	AWG	533	2	f
10	Azerbaijanian Manat	AZN	944	2	f
11	Convertible Mark	BAM	977	2	f
12	Barbados Dollar	BBD	52	2	f
13	Taka	BDT	50	2	f
14	Bulgarian Lev	BGN	975	2	f
15	Bahraini Dinar	BHD	48	3	f
16	Burundi Franc	BIF	108	0	f
17	Bermudian Dollar	BMD	60	2	f
18	Brunei Dollar	BND	96	2	f
19	Boliviano	BOB	68	2	f
20	Mvdol	BOV	984	2	t
21	Brazilian Real	BRL	986	2	f
22	Bahamian Dollar	BSD	44	2	f
23	Ngultrum	BTN	64	2	f
24	Pula	BWP	72	2	f
25	Belarussian Ruble	BYR	974	0	f
26	Belize Dollar	BZD	84	2	f
27	Canadian Dollar	CAD	124	2	f
28	Congolese Franc	CDF	976	2	f
29	WIR Euro	CHE	947	2	t
30	Swiss Franc	CHF	756	2	f
31	WIR Franc	CHW	948	2	t
32	Unidad de Fomento	CLF	990	4	t
33	Chilean Peso	CLP	152	0	f
34	Yuan Renminbi	CNY	156	2	f
35	Colombian Peso	COP	170	2	f
36	Unidad de Valor Real	COU	970	2	t
37	Costa Rican Colon	CRC	188	2	f
38	Peso Convertible	CUC	931	2	f
39	Cuban Peso	CUP	192	2	f
40	Cabo Verde Escudo	CVE	132	2	f
41	Czech Koruna	CZK	203	2	f
42	Djibouti Franc	DJF	262	0	f
43	Danish Krone	DKK	208	2	f
44	Dominican Peso	DOP	214	2	f
45	Algerian Dinar	DZD	12	2	f
46	Egyptian Pound	EGP	818	2	f
47	Nakfa	ERN	232	2	f
48	Ethiopian Birr	ETB	230	2	f
49	Euro	EUR	978	2	f
50	Fiji Dollar	FJD	242	2	f
51	Falkland Islands Pound	FKP	238	2	f
52	Pound Sterling	GBP	826	2	f
53	Lari	GEL	981	2	f
54	Ghana Cedi	GHS	936	2	f
55	Gibraltar Pound	GIP	292	2	f
56	Dalasi	GMD	270	2	f
57	Guinea Franc	GNF	324	0	f
58	Quetzal	GTQ	320	2	f
59	Guyana Dollar	GYD	328	2	f
60	Hong Kong Dollar	HKD	344	2	f
61	Lempira	HNL	340	2	f
62	Kuna	HRK	191	2	f
63	Gourde	HTG	332	2	f
64	Forint	HUF	348	2	f
65	Rupiah	IDR	360	2	f
66	New Israeli Sheqel	ILS	376	2	f
67	Indian Rupee	INR	356	2	f
68	Iraqi Dinar	IQD	368	3	f
69	Iranian Rial	IRR	364	2	f
70	Iceland Krona	ISK	352	0	f
71	Jamaican Dollar	JMD	388	2	f
72	Jordanian Dinar	JOD	400	3	f
73	Yen	JPY	392	0	f
74	Kenyan Shilling	KES	404	2	f
75	Som	KGS	417	2	f
76	Riel	KHR	116	2	f
77	Comoro Franc	KMF	174	0	f
78	North Korean Won	KPW	408	2	f
79	Won	KRW	410	0	f
80	Kuwaiti Dinar	KWD	414	3	f
81	Cayman Islands Dollar	KYD	136	2	f
82	Tenge	KZT	398	2	f
83	Kip	LAK	418	2	f
84	Lebanese Pound	LBP	422	2	f
85	Sri Lanka Rupee	LKR	144	2	f
86	Liberian Dollar	LRD	430	2	f
87	Loti	LSL	426	2	f
88	Libyan Dinar	LYD	434	3	f
89	Moroccan Dirham	MAD	504	2	f
90	Moldovan Leu	MDL	498	2	f
91	Malagasy Ariary	MGA	969	2	f
92	Denar	MKD	807	2	f
93	Kyat	MMK	104	2	f
94	Tugrik	MNT	496	2	f
95	Pataca	MOP	446	2	f
96	Ouguiya	MRO	478	2	f
97	Mauritius Rupee	MUR	480	2	f
98	Rufiyaa	MVR	462	2	f
99	Kwacha	MWK	454	2	f
100	Mexican Peso	MXN	484	2	f
101	Mexican Unidad de Inversion (UDI)	MXV	979	2	t
102	Malaysian Ringgit	MYR	458	2	f
103	Mozambique Metical	MZN	943	2	f
104	Namibia Dollar	NAD	516	2	f
105	Naira	NGN	566	2	f
106	Cordoba Oro	NIO	558	2	f
107	Norwegian Krone	NOK	578	2	f
108	Nepalese Rupee	NPR	524	2	f
109	New Zealand Dollar	NZD	554	2	f
110	Rial Omani	OMR	512	3	f
111	Balboa	PAB	590	2	f
112	Nuevo Sol	PEN	604	2	f
113	Kina	PGK	598	2	f
114	Philippine Peso	PHP	608	2	f
115	Pakistan Rupee	PKR	586	2	f
116	Zloty	PLN	985	2	f
117	Guarani	PYG	600	0	f
118	Qatari Rial	QAR	634	2	f
119	Romanian Leu	RON	946	2	f
120	Serbian Dinar	RSD	941	2	f
121	Russian Ruble	RUB	643	2	f
122	Rwanda Franc	RWF	646	0	f
123	Saudi Riyal	SAR	682	2	f
124	Solomon Islands Dollar	SBD	90	2	f
125	Seychelles Rupee	SCR	690	2	f
126	Sudanese Pound	SDG	938	2	f
127	Swedish Krona	SEK	752	2	f
128	Singapore Dollar	SGD	702	2	f
129	Saint Helena Pound	SHP	654	2	f
130	Leone	SLL	694	2	f
131	Somali Shilling	SOS	706	2	f
132	Surinam Dollar	SRD	968	2	f
133	South Sudanese Pound	SSP	728	2	f
134	Dobra	STD	678	2	f
135	El Salvador Colon	SVC	222	2	f
136	Syrian Pound	SYP	760	2	f
137	Lilangeni	SZL	748	2	f
138	Baht	THB	764	2	f
139	Somoni	TJS	972	2	f
140	Turkmenistan New Manat	TMT	934	2	f
141	Tunisian Dinar	TND	788	3	f
142	Pa’anga	TOP	776	2	f
143	Turkish Lira	TRY	949	2	f
144	Trinidad and Tobago Dollar	TTD	780	2	f
145	New Taiwan Dollar	TWD	901	2	f
146	Tanzanian Shilling	TZS	834	2	f
147	Hryvnia	UAH	980	2	f
148	Uganda Shilling	UGX	800	0	f
149	US Dollar	USD	840	2	f
150	US Dollar (Next day)	USN	997	2	t
151	Uruguay Peso en Unidades Indexadas (URUIURUI)	UYI	940	0	t
152	Peso Uruguayo	UYU	858	2	f
153	Uzbekistan Sum	UZS	860	2	f
154	Bolivar	VEF	937	2	f
155	Dong	VND	704	0	f
156	Vatu	VUV	548	0	f
157	Tala	WST	882	2	f
158	CFA Franc BEAC	XAF	950	0	f
159	Silver	XAG	961	\N	f
160	Gold	XAU	959	\N	f
161	Bond Markets Unit European Composite Unit (EURCO)	XBA	955	\N	f
162	Bond Markets Unit European Monetary Unit (E.M.U.-6)	XBB	956	\N	f
163	Bond Markets Unit European Unit of Account 9 (E.U.A.-9)	XBC	957	\N	f
164	Bond Markets Unit European Unit of Account 17 (E.U.A.-17)	XBD	958	\N	f
165	East Caribbean Dollar	XCD	951	2	f
166	SDR (Special Drawing Right)	XDR	960	\N	f
167	CFA Franc BCEAO	XOF	952	0	f
168	Palladium	XPD	964	\N	f
169	CFP Franc	XPF	953	0	f
170	Platinum	XPT	962	\N	f
171	Sucre	XSU	994	\N	f
172	Codes specifically reserved for testing purposes	XTS	963	\N	f
173	ADB Unit of Account	XUA	965	\N	f
174	The codes assigned for transactions where no currency is involved	XXX	999	\N	f
175	Yemeni Rial	YER	886	2	f
176	Rand	ZAR	710	2	f
177	Zambian Kwacha	ZMW	967	2	f
178	Zimbabwe Dollar	ZWL	932	2	f
\.


--
-- Data for Name: i18_currency_country; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY i18_currency_country (alpha3code, entity) FROM stdin;
AFN	AFGHANISTAN
EUR	ÅLAND ISLANDS
ALL	ALBANIA
DZD	ALGERIA
USD	AMERICAN SAMOA
EUR	ANDORRA
AOA	ANGOLA
XCD	ANGUILLA
XCD	ANTIGUA AND BARBUDA
ARS	ARGENTINA
AMD	ARMENIA
AWG	ARUBA
AUD	AUSTRALIA
EUR	AUSTRIA
AZN	AZERBAIJAN
BSD	BAHAMAS (THE)
BHD	BAHRAIN
BDT	BANGLADESH
BBD	BARBADOS
BYR	BELARUS
EUR	BELGIUM
BZD	BELIZE
XOF	BENIN
BMD	BERMUDA
BTN	BHUTAN
INR	BHUTAN
BOB	BOLIVIA (PLURINATIONAL STATE OF)
BOV	BOLIVIA (PLURINATIONAL STATE OF)
USD	BONAIRE, SINT EUSTATIUS AND SABA
BAM	BOSNIA AND HERZEGOVINA
BWP	BOTSWANA
NOK	BOUVET ISLAND
BRL	BRAZIL
USD	BRITISH INDIAN OCEAN TERRITORY (THE)
BND	BRUNEI DARUSSALAM
BGN	BULGARIA
XOF	BURKINA FASO
BIF	BURUNDI
CVE	CABO VERDE
KHR	CAMBODIA
XAF	CAMEROON
CAD	CANADA
KYD	CAYMAN ISLANDS (THE)
XAF	CENTRAL AFRICAN REPUBLIC (THE)
XAF	CHAD
CLF	CHILE
CLP	CHILE
CNY	CHINA
AUD	CHRISTMAS ISLAND
AUD	COCOS (KEELING) ISLANDS (THE)
COP	COLOMBIA
COU	COLOMBIA
KMF	COMOROS (THE)
CDF	CONGO (THE DEMOCRATIC REPUBLIC OF THE)
XAF	CONGO (THE)
NZD	COOK ISLANDS (THE)
CRC	COSTA RICA
XOF	CÔTE D`IVOIRE
HRK	CROATIA
CUC	CUBA
CUP	CUBA
ANG	CURAÇAO
EUR	CYPRUS
CZK	CZECH REPUBLIC (THE)
DKK	DENMARK
DJF	DJIBOUTI
XCD	DOMINICA
DOP	DOMINICAN REPUBLIC (THE)
USD	ECUADOR
EGP	EGYPT
SVC	EL SALVADOR
USD	EL SALVADOR
XAF	EQUATORIAL GUINEA
ERN	ERITREA
EUR	ESTONIA
ETB	ETHIOPIA
EUR	EUROPEAN UNION
FKP	FALKLAND ISLANDS (THE) [MALVINAS]
DKK	FAROE ISLANDS (THE)
FJD	FIJI
EUR	FINLAND
EUR	FRANCE
EUR	FRENCH GUIANA
XPF	FRENCH POLYNESIA
EUR	FRENCH SOUTHERN TERRITORIES (THE)
XAF	GABON
GMD	GAMBIA (THE)
GEL	GEORGIA
EUR	GERMANY
GHS	GHANA
GIP	GIBRALTAR
EUR	GREECE
DKK	GREENLAND
XCD	GRENADA
EUR	GUADELOUPE
USD	GUAM
GTQ	GUATEMALA
GBP	GUERNSEY
GNF	GUINEA
XOF	GUINEA-BISSAU
GYD	GUYANA
HTG	HAITI
USD	HAITI
AUD	HEARD ISLAND AND McDONALD ISLANDS
EUR	HOLY SEE (THE)
HNL	HONDURAS
HKD	HONG KONG
HUF	HUNGARY
ISK	ICELAND
INR	INDIA
IDR	INDONESIA
XDR	INTERNATIONAL MONETARY FUND (IMF) 
IRR	IRAN (ISLAMIC REPUBLIC OF)
IQD	IRAQ
EUR	IRELAND
GBP	ISLE OF MAN
ILS	ISRAEL
EUR	ITALY
JMD	JAMAICA
JPY	JAPAN
GBP	JERSEY
JOD	JORDAN
KZT	KAZAKHSTAN
KES	KENYA
AUD	KIRIBATI
KPW	KOREA (THE DEMOCRATIC PEOPLE’S REPUBLIC OF)
KRW	KOREA (THE REPUBLIC OF)
KWD	KUWAIT
KGS	KYRGYZSTAN
LAK	LAO PEOPLE’S DEMOCRATIC REPUBLIC (THE)
EUR	LATVIA
LBP	LEBANON
LSL	LESOTHO
ZAR	LESOTHO
LRD	LIBERIA
LYD	LIBYA
CHF	LIECHTENSTEIN
EUR	LITHUANIA
EUR	LUXEMBOURG
MOP	MACAO
MKD	MACEDONIA (THE FORMER YUGOSLAV REPUBLIC OF)
MGA	MADAGASCAR
MWK	MALAWI
MYR	MALAYSIA
MVR	MALDIVES
XOF	MALI
EUR	MALTA
USD	MARSHALL ISLANDS (THE)
EUR	MARTINIQUE
MRO	MAURITANIA
MUR	MAURITIUS
EUR	MAYOTTE
XUA	MEMBER COUNTRIES OF THE AFRICAN DEVELOPMENT BANK GROUP
MXN	MEXICO
MXV	MEXICO
USD	MICRONESIA (FEDERATED STATES OF)
MDL	MOLDOVA (THE REPUBLIC OF)
EUR	MONACO
MNT	MONGOLIA
EUR	MONTENEGRO
XCD	MONTSERRAT
MAD	MOROCCO
MZN	MOZAMBIQUE
MMK	MYANMAR
NAD	NAMIBIA
ZAR	NAMIBIA
AUD	NAURU
NPR	NEPAL
EUR	NETHERLANDS (THE)
XPF	NEW CALEDONIA
NZD	NEW ZEALAND
NIO	NICARAGUA
XOF	NIGER (THE)
NGN	NIGERIA
NZD	NIUE
AUD	NORFOLK ISLAND
USD	NORTHERN MARIANA ISLANDS (THE)
NOK	NORWAY
OMR	OMAN
PKR	PAKISTAN
USD	PALAU
PAB	PANAMA
USD	PANAMA
PGK	PAPUA NEW GUINEA
PYG	PARAGUAY
PEN	PERU
PHP	PHILIPPINES (THE)
NZD	PITCAIRN
PLN	POLAND
EUR	PORTUGAL
USD	PUERTO RICO
QAR	QATAR
EUR	RÉUNION
RON	ROMANIA
RUB	RUSSIAN FEDERATION (THE)
RWF	RWANDA
EUR	SAINT BARTHÉLEMY
SHP	SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA
XCD	SAINT KITTS AND NEVIS
XCD	SAINT LUCIA
EUR	SAINT MARTIN (FRENCH PART)
EUR	SAINT PIERRE AND MIQUELON
XCD	SAINT VINCENT AND THE GRENADINES
WST	SAMOA
EUR	SAN MARINO
STD	SAO TOME AND PRINCIPE
SAR	SAUDI ARABIA
XOF	SENEGAL
RSD	SERBIA
SCR	SEYCHELLES
SLL	SIERRA LEONE
SGD	SINGAPORE
ANG	SINT MAARTEN (DUTCH PART)
XSU	SISTEMA UNITARIO DE COMPENSACION REGIONAL DE PAGOS "SUCRE"
EUR	SLOVAKIA
EUR	SLOVENIA
SBD	SOLOMON ISLANDS
SOS	SOMALIA
ZAR	SOUTH AFRICA
SSP	SOUTH SUDAN
EUR	SPAIN
LKR	SRI LANKA
SDG	SUDAN (THE)
SRD	SURINAME
NOK	SVALBARD AND JAN MAYEN
SZL	SWAZILAND
SEK	SWEDEN
CHE	SWITZERLAND
CHF	SWITZERLAND
CHW	SWITZERLAND
SYP	SYRIAN ARAB REPUBLIC
TWD	TAIWAN (PROVINCE OF CHINA)
TJS	TAJIKISTAN
TZS	TANZANIA, UNITED REPUBLIC OF
THB	THAILAND
USD	TIMOR-LESTE
XOF	TOGO
NZD	TOKELAU
TOP	TONGA
TTD	TRINIDAD AND TOBAGO
TND	TUNISIA
TRY	TURKEY
TMT	TURKMENISTAN
USD	TURKS AND CAICOS ISLANDS (THE)
AUD	TUVALU
UGX	UGANDA
UAH	UKRAINE
AED	UNITED ARAB EMIRATES (THE)
GBP	UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND (THE)
USD	UNITED STATES MINOR OUTLYING ISLANDS (THE)
USD	UNITED STATES OF AMERICA (THE)
USN	UNITED STATES OF AMERICA (THE)
UYI	URUGUAY
UYU	URUGUAY
UZS	UZBEKISTAN
VUV	VANUATU
VEF	VENEZUELA (BOLIVARIAN REPUBLIC OF)
VND	VIET NAM
USD	VIRGIN ISLANDS (BRITISH)
USD	VIRGIN ISLANDS (U.S.)
XPF	WALLIS AND FUTUNA
MAD	WESTERN SAHARA
YER	YEMEN
ZMW	ZAMBIA
ZWL	ZIMBABWE
XBA	ZZ01_Bond Markets Unit European_EURCO
XBB	ZZ02_Bond Markets Unit European_EMU-6
XBC	ZZ03_Bond Markets Unit European_EUA-9
XBD	ZZ04_Bond Markets Unit European_EUA-17
XTS	ZZ06_Testing_Code
XXX	ZZ07_No_Currency
XAU	ZZ08_Gold
XPD	ZZ09_Palladium
XPT	ZZ10_Platinum
XAG	ZZ11_Silver
\.


--
-- Name: i18_currency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('i18_currency_id_seq', 178, true);


--
-- Data for Name: i18_language; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY i18_language (id, name, alpha2code, alpha3code, scope) FROM stdin;
11	Afar	aa	aar	1
12	Abkhazian	ab	abk	1
13	Afrikaans	af	afr	1
14	Akan	ak	aka	2
15	Amharic	am	amh	1
16	Aragonese	an	arg	1
17	Arabic	ar	ara	2
18	Assamese	as	asm	1
19	Avaric	av	ava	1
20	Aymara	ay	aym	2
21	Azerbaijani	az	aze	2
22	Bashkir	ba	bak	1
23	Belarusian	be	bel	1
24	Bulgarian	bg	bul	1
25	Bislama	bi	bis	1
26	Bambara	bm	bam	1
27	Bengali	bn	ben	1
28	Tibetan	bo	bod	1
29	Breton	br	bre	1
30	Bosnian	bs	bos	1
31	Catalan	ca	cat	1
32	Chechen	ce	che	1
33	Chamorro	ch	cha	1
34	Corsican	co	cos	1
35	Cree	cr	cre	2
36	Czech	cs	ces	1
37	Chuvash	cv	chv	1
38	Welsh	cy	cym	1
39	Danish	da	dan	1
40	German	de	deu	1
41	Dhivehi	dv	div	1
42	Dzongkha	dz	dzo	1
43	Ewe	ee	ewe	1
44	Modern Greek (1453-)	el	ell	1
45	English	en	eng	1
46	Spanish	es	spa	1
47	Estonian	et	est	2
48	Basque	eu	eus	1
49	Persian	fa	fas	2
50	Fulah	ff	ful	2
51	Finnish	fi	fin	1
52	Fijian	fj	fij	1
53	Faroese	fo	fao	1
54	French	fr	fra	1
55	Western Frisian	fy	fry	1
56	Irish	ga	gle	1
57	Scottish Gaelic	gd	gla	1
58	Galician	gl	glg	1
59	Guarani	gn	grn	2
60	Gujarati	gu	guj	1
61	Manx	gv	glv	1
62	Hausa	ha	hau	1
63	Hebrew	he	heb	1
64	Hindi	hi	hin	1
65	Hiri Motu	ho	hmo	1
66	Croatian	hr	hrv	1
67	Haitian	ht	hat	1
68	Hungarian	hu	hun	1
69	Armenian	hy	hye	1
70	Herero	hz	her	1
71	Indonesian	id	ind	1
72	Igbo	ig	ibo	1
73	Sichuan Yi	ii	iii	1
74	Inupiaq	ik	ipk	2
75	Icelandic	is	isl	1
76	Italian	it	ita	1
77	Inuktitut	iu	iku	2
78	Japanese	ja	jpn	1
79	Javanese	jv	jav	1
80	Georgian	ka	kat	1
81	Kongo	kg	kon	2
82	Kikuyu	ki	kik	1
83	Kuanyama	kj	kua	1
84	Kazakh	kk	kaz	1
85	Kalaallisut	kl	kal	1
86	Central Khmer	km	khm	1
87	Kannada	kn	kan	1
88	Korean	ko	kor	1
89	Kanuri	kr	kau	2
90	Kashmiri	ks	kas	1
91	Kurdish	ku	kur	2
92	Komi	kv	kom	2
93	Cornish	kw	cor	1
94	Kirghiz	ky	kir	1
95	Luxembourgish	lb	ltz	1
96	Ganda	lg	lug	1
97	Limburgan	li	lim	1
98	Lingala	ln	lin	1
99	Lao	lo	lao	1
100	Lithuanian	lt	lit	1
101	Luba-Katanga	lu	lub	1
102	Latvian	lv	lav	2
103	Malagasy	mg	mlg	2
104	Marshallese	mh	mah	1
105	Maori	mi	mri	1
106	Macedonian	mk	mkd	1
107	Malayalam	ml	mal	1
108	Mongolian	mn	mon	2
109	Marathi	mr	mar	1
110	Malay (macrolanguage)	ms	msa	2
111	Maltese	mt	mlt	1
112	Burmese	my	mya	1
113	Nauru	na	nau	1
114	Norwegian Bokmål	nb	nob	1
115	North Ndebele	nd	nde	1
116	Nepali (macrolanguage)	ne	nep	2
117	Ndonga	ng	ndo	1
118	Dutch	nl	nld	1
119	Norwegian Nynorsk	nn	nno	1
120	Norwegian	no	nor	2
121	South Ndebele	nr	nbl	1
122	Navajo	nv	nav	1
123	Nyanja	ny	nya	1
124	Occitan (post 1500)	oc	oci	1
125	Ojibwa	oj	oji	2
126	Oromo	om	orm	2
127	Oriya (macrolanguage)	or	ori	2
128	Ossetian	os	oss	1
129	Panjabi	pa	pan	1
130	Polish	pl	pol	1
131	Pushto	ps	pus	2
132	Portuguese	pt	por	1
133	Quechua	qu	que	2
134	Romansh	rm	roh	1
135	Rundi	rn	run	1
136	Romanian	ro	ron	1
137	Russian	ru	rus	1
138	Kinyarwanda	rw	kin	1
139	Sardinian	sc	srd	2
140	Sindhi	sd	snd	1
141	Northern Sami	se	sme	1
142	Sango	sg	sag	1
143	Sinhala	si	sin	1
144	Slovak	sk	slk	1
145	Slovenian	sl	slv	1
146	Samoan	sm	smo	1
147	Shona	sn	sna	1
148	Somali	so	som	1
149	Albanian	sq	sqi	2
150	Serbian	sr	srp	1
151	Swati	ss	ssw	1
152	Southern Sotho	st	sot	1
153	Sundanese	su	sun	1
154	Swedish	sv	swe	1
155	Swahili (macrolanguage)	sw	swa	2
156	Tamil	ta	tam	1
157	Telugu	te	tel	1
158	Tajik	tg	tgk	1
159	Thai	th	tha	1
160	Tigrinya	ti	tir	1
161	Turkmen	tk	tuk	1
162	Tagalog	tl	tgl	1
163	Tswana	tn	tsn	1
164	Tonga (Tonga Islands)	to	ton	1
165	Turkish	tr	tur	1
166	Tsonga	ts	tso	1
167	Tatar	tt	tat	1
168	Twi	tw	twi	1
169	Tahitian	ty	tah	1
170	Uighur	ug	uig	1
171	Ukrainian	uk	ukr	1
172	Urdu	ur	urd	1
173	Uzbek	uz	uzb	2
174	Venda	ve	ven	1
175	Vietnamese	vi	vie	1
176	Walloon	wa	wln	1
177	Wolof	wo	wol	1
178	Xhosa	xh	xho	1
179	Yiddish	yi	yid	2
180	Yoruba	yo	yor	1
181	Zhuang	za	zha	2
182	Chinese	zh	zho	2
183	Zulu	zu	zul	1
\.


--
-- Name: i18_language_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('i18_language_id_seq', 183, true);


--
-- Data for Name: lml_class; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lml_class (id, name) FROM stdin;
1	sec_session
2	sec_authentication_kind
3	sec_user
\.


--
-- Name: lml_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('lml_class_id_seq', 3, true);


--
-- Data for Name: lml_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lml_event (id, name, class_id) FROM stdin;
1	login_succeded	1
2	login_failed	1
4	logout_succeded	1
5	logout_failed	1
6	add	2
7	upd	2
8	del	2
9	create	3
\.


--
-- Name: lml_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('lml_event_id_seq', 9, true);


--
-- Data for Name: lml_event_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lml_event_status (id, name) FROM stdin;
1	началось
2	в процессе
3	окончено
\.


--
-- Name: lml_event_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('lml_event_status_id_seq', 1, false);


--
-- Data for Name: mdd_class; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY mdd_class (id, name) FROM stdin;
1	test1
2	test2
3	test3
4	test4
5	test5
6	test1-1
7	test2-1
8	test3-1
9	test4-1
10	test5-1
11	test1-1-1
12	test2-1-1
13	test3-1-1
14	test4-1-1
15	test5-1-1
17	test1-2
18	test2-1
19	test2-2
20	test2-3
\.


--
-- Data for Name: mdd_class_extention; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY mdd_class_extention (class_id, base_class_id) FROM stdin;
6	1
7	2
8	3
9	4
10	5
11	6
12	7
13	8
14	9
15	10
17	1
18	2
19	2
20	2
\.


--
-- Name: mdd_class_sq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('mdd_class_sq', 20, true);


--
-- Data for Name: mdd_datatype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY mdd_datatype (id, name) FROM stdin;
\.


--
-- Data for Name: mdd_datatype_sized; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY mdd_datatype_sized (id, name, datasize) FROM stdin;
\.


--
-- Name: mdd_datatype_sq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('mdd_datatype_sq', 1, false);


--
-- Data for Name: opn_operation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY opn_operation (id, operation_kind_id, modified_on, modified_by, applied_on, applied_by, applied_order) FROM stdin;
\.


--
-- Name: opn_operation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('opn_operation_id_seq', 1, false);


--
-- Data for Name: opn_operation_kind; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY opn_operation_kind (id, name, class_id) FROM stdin;
\.


--
-- Name: opn_operation_kind_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('opn_operation_kind_id_seq', 1, false);


--
-- Data for Name: opn_person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY opn_person (operation_id, person_id, citizenship_country_id, language_id, person_kind_id) FROM stdin;
\.


--
-- Data for Name: opn_person_individual; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY opn_person_individual (operation_id, person_id, last_name, middle_name, first_name, birthdate) FROM stdin;
\.


--
-- Data for Name: opn_person_legal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY opn_person_legal (operation_id, person_id, name_short, name_long) FROM stdin;
\.


--
-- Data for Name: prs_person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY prs_person (id, citizenship_country_id, language_id, person_kind_id) FROM stdin;
1	182	137	1
2	182	137	1
3	182	137	1
24	182	137	1
27	182	137	1
\.


--
-- Name: prs_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('prs_person_id_seq', 27, true);


--
-- Data for Name: prs_person_individual; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY prs_person_individual (person_id, last_name, middle_name, first_name, birthdate) FROM stdin;
1	root	root	root	\N
24	\N	\N	test-001	\N
27	\N	\N	user01	\N
\.


--
-- Data for Name: prs_person_kind; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY prs_person_kind (id, name) FROM stdin;
0	не указано
1	физическое лицо
2	юридическое лицо
\.


--
-- Name: prs_person_kind_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('prs_person_kind_id_seq', 1, false);


--
-- Data for Name: prs_person_legal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY prs_person_legal (person_id, name_short, name_long) FROM stdin;
\.


--
-- Data for Name: sec_authentication_kind; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_authentication_kind (id, name, code) FROM stdin;
2	ldap	ldap
1	pg_crypt	pg_crypt
3	yandex.passport	yandex.passport
\.


--
-- Name: sec_authentication_kind_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sec_authentication_kind_id_seq', 3, true);


--
-- Data for Name: sec_authentication_path; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_authentication_path (id, name, authentication_kind_id, credential_kind, application_id, credential_hash_kind) FROM stdin;
1	Пароль	1	bf	\N	sha512
\.


--
-- Name: sec_authentication_path_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sec_authentication_path_id_seq', 2, true);


--
-- Data for Name: sec_event_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_event_log (whenfired, event_kind, event_status, session_id, context, user_name, auth_path_id, tokenvalue) FROM stdin;
2015-12-15 00:11:09.36655+03	1	1	1	\N	\N	\N	\N
2015-12-15 00:22:28.786236+03	1	1	1	\N	\N	\N	\N
2016-01-02 01:24:55.282399+03	1	1	13	\N	\N	\N	\N
2016-01-02 01:25:49.405492+03	1	1	14	\N	\N	\N	\N
2016-01-02 01:57:27.32688+03	1	1	21	\N	\N	\N	\N
2016-01-02 01:57:27.331835+03	4	1	21	\N	\N	\N	\N
2016-01-03 01:25:07.938859+03	1	1	28	\N	\N	\N	\N
2016-01-03 01:25:07.940722+03	6	1	28	\N	\N	\N	\N
2016-01-04 01:51:20.030701+03	1	1	31	<l_token>(25,25#b82c08eb-472c-f985-1732-64d5d07639c3,,1,31,"2016-01-04 01:51:20.030188+03",,b82c08eb-472c-f985-1732-64d5d07639c3)</l_token>	\N	\N	\N
2016-01-04 01:51:20.038502+03	4	1	31	<l_token>(25,25#b82c08eb-472c-f985-1732-64d5d07639c3,,1,31,"2016-01-04 01:51:20.030188+03",,b82c08eb-472c-f985-1732-64d5d07639c3)</l_token>	\N	\N	\N
2016-01-06 02:04:12.736708+03	1	1	32	<l_token>(26,26#e45c6c27-e576-ab7f-9db1-890f472bf109,,1,32,"2016-01-06 02:04:12.731973+03",,e45c6c27-e576-ab7f-9db1-890f472bf109)</l_token>	\N	\N	\N
2016-01-06 02:04:12.753878+03	4	1	32	<l_token>(26,26#e45c6c27-e576-ab7f-9db1-890f472bf109,,1,32,"2016-01-06 02:04:12.731973+03",,e45c6c27-e576-ab7f-9db1-890f472bf109)</l_token>	\N	\N	\N
2016-01-06 02:04:15.204013+03	1	1	33	<l_token>(27,27#5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca,,1,33,"2016-01-06 02:04:15.203489+03",,5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca)</l_token>	\N	\N	\N
2016-01-06 02:04:15.206454+03	4	1	33	<l_token>(27,27#5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca,,1,33,"2016-01-06 02:04:15.203489+03",,5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca)</l_token>	\N	\N	\N
2016-01-06 02:17:42.78917+03	1	1	37	<l_token>(31,31#0e8fc585-9bbf-77ad-bc9f-40855c29d089,,1,37,"2016-01-06 02:17:42.788536+03",,0e8fc585-9bbf-77ad-bc9f-40855c29d089)</l_token>	\N	\N	\N
2016-01-06 02:17:42.806943+03	1	1	38	<l_token>(32,32#88a21ecd-bfb9-f482-8085-53daac48054c,$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q,1,38,"2016-01-06 02:17:42.805899+03",,88a21ecd-bfb9-f482-8085-53daac48054c)</l_token>	\N	\N	\N
2016-01-06 02:17:42.809273+03	4	1	38	<l_token>(32,32#88a21ecd-bfb9-f482-8085-53daac48054c,$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q,1,38,"2016-01-06 02:17:42.805899+03",,88a21ecd-bfb9-f482-8085-53daac48054c)</l_token>	\N	\N	\N
2016-01-06 02:17:42.811355+03	4	1	37	<l_token>(31,31#0e8fc585-9bbf-77ad-bc9f-40855c29d089,,1,37,"2016-01-06 02:17:42.788536+03",,0e8fc585-9bbf-77ad-bc9f-40855c29d089)</l_token>	\N	\N	\N
2016-01-06 02:24:43.052282+03	1	1	39	<l_token>(33,33#c87f6b71-35e8-b89a-762d-75fe29bc76ef,,1,39,"2016-01-06 02:24:43.050827+03",,c87f6b71-35e8-b89a-762d-75fe29bc76ef)</l_token>	\N	\N	\N
2016-01-06 02:24:43.071437+03	1	1	40	<l_token>(34,34#f9e5420a-2f16-1296-f4a7-eb7e3d70c59e,$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q,1,40,"2016-01-06 02:24:43.070376+03",,f9e5420a-2f16-1296-f4a7-eb7e3d70c59e)</l_token>	\N	\N	\N
2016-01-06 02:24:43.086799+03	4	1	40	<l_token>(34,34#f9e5420a-2f16-1296-f4a7-eb7e3d70c59e,$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q,1,40,"2016-01-06 02:24:43.070376+03",,f9e5420a-2f16-1296-f4a7-eb7e3d70c59e)</l_token>	\N	\N	\N
2016-01-06 02:24:43.089401+03	4	1	39	<l_token>(33,33#c87f6b71-35e8-b89a-762d-75fe29bc76ef,,1,39,"2016-01-06 02:24:43.050827+03",,c87f6b71-35e8-b89a-762d-75fe29bc76ef)</l_token>	\N	\N	\N
2016-01-06 02:30:12.135674+03	1	1	41	<l_token>(35,35#e749c61b-0daa-da66-55d2-da7affe6d025,,1,41,"2016-01-06 02:30:12.134964+03",,e749c61b-0daa-da66-55d2-da7affe6d025)</l_token>	\N	\N	\N
2016-01-06 02:30:12.151579+03	1	1	42	<l_token>(36,36#b54cbbb7-fcee-d6c6-3892-43fb3d17b146,$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q,1,42,"2016-01-06 02:30:12.150998+03",,b54cbbb7-fcee-d6c6-3892-43fb3d17b146)</l_token>	\N	\N	\N
2016-01-06 02:30:12.178142+03	4	1	42	<l_token>(36,36#b54cbbb7-fcee-d6c6-3892-43fb3d17b146,$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q,1,42,"2016-01-06 02:30:12.150998+03",,b54cbbb7-fcee-d6c6-3892-43fb3d17b146)</l_token>	\N	\N	\N
2016-01-06 02:30:12.179986+03	4	1	41	<l_token>(35,35#e749c61b-0daa-da66-55d2-da7affe6d025,,1,41,"2016-01-06 02:30:12.134964+03",,e749c61b-0daa-da66-55d2-da7affe6d025)</l_token>	\N	\N	\N
2016-01-07 01:52:23.634667+03	1	1	113	<l_token>(89,89#6ce09d29-b92f-82b5-d90f-8909c1f76e2e,,1,113,"2016-01-07 01:52:23.629269+03",,6ce09d29-b92f-82b5-d90f-8909c1f76e2e)</l_token>	\N	\N	\N
2016-01-07 01:52:23.666879+03	1	1	114	<l_token>(90,90#3b906d68-16cd-7ed9-fed7-34f4ed9f52f8,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,114,"2016-01-07 01:52:23.665754+03",,3b906d68-16cd-7ed9-fed7-34f4ed9f52f8)</l_token>	\N	\N	\N
2016-01-07 01:52:23.746212+03	4	1	114	<l_token>(90,90#3b906d68-16cd-7ed9-fed7-34f4ed9f52f8,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,114,"2016-01-07 01:52:23.665754+03",,3b906d68-16cd-7ed9-fed7-34f4ed9f52f8)</l_token>	\N	\N	\N
2016-01-07 01:52:23.74879+03	4	1	113	<l_token>(89,89#6ce09d29-b92f-82b5-d90f-8909c1f76e2e,,1,113,"2016-01-07 01:52:23.629269+03",,6ce09d29-b92f-82b5-d90f-8909c1f76e2e)</l_token>	\N	\N	\N
2016-01-07 01:56:34.430223+03	2	1	116	<user_name>test-001</user_name><auth_path_id>1</auth_path_id><credential>-te$t-creDential#001</credential>	test-001	1	-te$t-creDential#001
2016-01-07 01:58:05.439068+03	2	1	117	<user_name>test-001</user_name><auth_path_id>1</auth_path_id><credential>-te$t-creDential#001</credential>	test-001	1	-te$t-creDential#001
2016-01-07 01:58:06.388337+03	2	1	118	<user_name>test-001</user_name><auth_path_id>1</auth_path_id><credential>-te$t-creDential#001</credential>	test-001	1	-te$t-creDential#001
2016-01-07 01:58:11.870454+03	1	1	119	<l_token>(92,92#44e08338-b209-5369-8960-f3635240ffda,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,119,"2016-01-07 01:58:11.869799+03",,44e08338-b209-5369-8960-f3635240ffda)</l_token>	\N	\N	\N
2016-01-07 01:59:24.26542+03	1	1	120	<l_token>(93,93#f6399685-3ea0-2714-cb84-c1279eb398cf,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,120,"2016-01-07 01:59:24.264296+03",,f6399685-3ea0-2714-cb84-c1279eb398cf)</l_token>	test-001	1	\N
2016-01-06 23:48:35.365023+03	1	1	94	<l_token>(73,73#4a82bf3b-4be4-a096-1f3b-132c56926384,,1,94,"2016-01-06 23:48:35.364557+03",,4a82bf3b-4be4-a096-1f3b-132c56926384)</l_token>	\N	\N	\N
2016-01-06 23:48:35.379242+03	2	1	95	\N	\N	\N	\N
2016-01-06 23:48:35.406568+03	1	1	96	<l_token>(74,74#0c263ba6-0cbb-31ef-492e-44f57596bf2b,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,96,"2016-01-06 23:48:35.406108+03",,0c263ba6-0cbb-31ef-492e-44f57596bf2b)</l_token>	\N	\N	\N
2016-01-06 23:48:35.443956+03	4	1	96	<l_token>(74,74#0c263ba6-0cbb-31ef-492e-44f57596bf2b,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,96,"2016-01-06 23:48:35.406108+03",,0c263ba6-0cbb-31ef-492e-44f57596bf2b)</l_token>	\N	\N	\N
2016-01-06 23:48:35.445828+03	4	1	94	<l_token>(73,73#4a82bf3b-4be4-a096-1f3b-132c56926384,,1,94,"2016-01-06 23:48:35.364557+03",,4a82bf3b-4be4-a096-1f3b-132c56926384)</l_token>	\N	\N	\N
2016-01-07 02:00:38.076476+03	2	1	121	<user_name>test-001</user_name><auth_path_id>1</auth_path_id><credential>-te$t-creDential#001</credential>	test-001	1	-te$t-creDential#001
2016-01-07 00:23:49.705787+03	1	1	103	<l_token>(79,79#417fe44e-1597-6ad2-97d0-b49fac29c5de,,1,103,"2016-01-07 00:23:49.705234+03",,417fe44e-1597-6ad2-97d0-b49fac29c5de)</l_token>	\N	\N	\N
2016-01-07 00:23:49.719995+03	1	1	104	<l_token>(80,80#21d72e94-72d4-6838-7c3d-39724d7cb075,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,104,"2016-01-07 00:23:49.719499+03",,21d72e94-72d4-6838-7c3d-39724d7cb075)</l_token>	\N	\N	\N
2016-01-07 00:23:49.7633+03	4	1	104	<l_token>(80,80#21d72e94-72d4-6838-7c3d-39724d7cb075,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,104,"2016-01-07 00:23:49.719499+03",,21d72e94-72d4-6838-7c3d-39724d7cb075)</l_token>	\N	\N	\N
2016-01-07 00:23:49.766135+03	4	1	103	<l_token>(79,79#417fe44e-1597-6ad2-97d0-b49fac29c5de,,1,103,"2016-01-07 00:23:49.705234+03",,417fe44e-1597-6ad2-97d0-b49fac29c5de)</l_token>	\N	\N	\N
2016-01-07 00:23:59.739603+03	1	1	105	<l_token>(81,81#05fe16d3-fed4-a04d-acdd-5fd91fc4a607,,1,105,"2016-01-07 00:23:59.739078+03",,05fe16d3-fed4-a04d-acdd-5fd91fc4a607)</l_token>	\N	\N	\N
2016-01-07 00:23:59.754356+03	1	1	106	<l_token>(82,82#cc0ed478-605f-e14f-a7c6-841804218044,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,106,"2016-01-07 00:23:59.753777+03",,cc0ed478-605f-e14f-a7c6-841804218044)</l_token>	\N	\N	\N
2016-01-07 00:23:59.796591+03	4	1	106	<l_token>(82,82#cc0ed478-605f-e14f-a7c6-841804218044,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,106,"2016-01-07 00:23:59.753777+03",,cc0ed478-605f-e14f-a7c6-841804218044)</l_token>	\N	\N	\N
2016-01-07 00:23:59.798158+03	4	1	105	<l_token>(81,81#05fe16d3-fed4-a04d-acdd-5fd91fc4a607,,1,105,"2016-01-07 00:23:59.739078+03",,05fe16d3-fed4-a04d-acdd-5fd91fc4a607)</l_token>	\N	\N	\N
2016-01-07 00:25:13.281201+03	1	1	107	<l_token>(83,83#d737370a-ede2-6146-c1e4-de0ddd50b4af,,1,107,"2016-01-07 00:25:13.280645+03",,d737370a-ede2-6146-c1e4-de0ddd50b4af)</l_token>	\N	\N	\N
2016-01-07 00:25:13.296332+03	1	1	108	<l_token>(84,84#b748be7c-3888-34bd-d886-4af78b5ef96b,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,108,"2016-01-07 00:25:13.295651+03",,b748be7c-3888-34bd-d886-4af78b5ef96b)</l_token>	\N	\N	\N
2016-01-07 00:25:13.341614+03	4	1	108	<l_token>(84,84#b748be7c-3888-34bd-d886-4af78b5ef96b,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,108,"2016-01-07 00:25:13.295651+03",,b748be7c-3888-34bd-d886-4af78b5ef96b)</l_token>	\N	\N	\N
2016-01-07 00:25:13.343414+03	4	1	107	<l_token>(83,83#d737370a-ede2-6146-c1e4-de0ddd50b4af,,1,107,"2016-01-07 00:25:13.280645+03",,d737370a-ede2-6146-c1e4-de0ddd50b4af)</l_token>	\N	\N	\N
2016-01-07 00:25:13.921266+03	1	1	109	<l_token>(85,85#871b3ec3-3d5b-8ec0-1c52-9e774b862355,,1,109,"2016-01-07 00:25:13.92078+03",,871b3ec3-3d5b-8ec0-1c52-9e774b862355)</l_token>	\N	\N	\N
2016-01-07 00:25:13.935663+03	1	1	110	<l_token>(86,86#05743ed8-9af1-6bba-691d-686d65952624,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,110,"2016-01-07 00:25:13.935198+03",,05743ed8-9af1-6bba-691d-686d65952624)</l_token>	\N	\N	\N
2016-01-07 00:25:13.977675+03	4	1	110	<l_token>(86,86#05743ed8-9af1-6bba-691d-686d65952624,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,110,"2016-01-07 00:25:13.935198+03",,05743ed8-9af1-6bba-691d-686d65952624)</l_token>	\N	\N	\N
2016-01-07 00:25:13.979444+03	4	1	109	<l_token>(85,85#871b3ec3-3d5b-8ec0-1c52-9e774b862355,,1,109,"2016-01-07 00:25:13.92078+03",,871b3ec3-3d5b-8ec0-1c52-9e774b862355)</l_token>	\N	\N	\N
2016-01-07 00:28:58.358323+03	1	1	111	<l_token>(87,87#bb1fdb5d-0959-3785-df5e-90f52acc62e1,,1,111,"2016-01-07 00:28:58.357735+03",,bb1fdb5d-0959-3785-df5e-90f52acc62e1)</l_token>	\N	\N	\N
2016-01-07 00:28:58.374968+03	1	1	112	<l_token>(88,88#e9c59acb-4a72-c6fb-4eb8-8612121493dd,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,112,"2016-01-07 00:28:58.374353+03",,e9c59acb-4a72-c6fb-4eb8-8612121493dd)</l_token>	\N	\N	\N
2016-01-07 00:28:58.435643+03	4	1	112	<l_token>(88,88#e9c59acb-4a72-c6fb-4eb8-8612121493dd,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,112,"2016-01-07 00:28:58.374353+03",,e9c59acb-4a72-c6fb-4eb8-8612121493dd)</l_token>	\N	\N	\N
2016-01-07 00:28:58.437633+03	4	1	111	<l_token>(87,87#bb1fdb5d-0959-3785-df5e-90f52acc62e1,,1,111,"2016-01-07 00:28:58.357735+03",,bb1fdb5d-0959-3785-df5e-90f52acc62e1)</l_token>	\N	\N	\N
2016-01-07 01:56:08.160469+03	1	1	115	<l_token>(91,91#4242bffa-1e38-9019-ff60-1834c32dab2e,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,115,"2016-01-07 01:56:08.15582+03",,4242bffa-1e38-9019-ff60-1834c32dab2e)</l_token>	\N	\N	\N
2016-01-07 02:18:15.188902+03	1	1	122	<l_token>(94,94#f8aefc8b-ec66-f03f-8428-915049b2661b,,1,122,"2016-01-07 02:18:15.186978+03",,f8aefc8b-ec66-f03f-8428-915049b2661b)</l_token>	root	1	\N
2016-01-07 02:18:15.20858+03	1	1	123	<l_token>(95,95#ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,123,"2016-01-07 02:18:15.206935+03",,ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4)</l_token>	test-001	1	\N
2016-01-07 02:18:15.265306+03	4	1	123	<l_token>(95,95#ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,123,"2016-01-07 02:18:15.206935+03",,ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4)</l_token>	\N	\N	\N
2016-01-07 02:18:15.267328+03	4	1	122	<l_token>(94,94#f8aefc8b-ec66-f03f-8428-915049b2661b,,1,122,"2016-01-07 02:18:15.186978+03",,f8aefc8b-ec66-f03f-8428-915049b2661b)</l_token>	\N	\N	\N
2016-01-07 02:37:13.142611+03	1	1	124	<l_token>(96,96#96db80c0-db13-4d02-a019-d7826e6a71a1,,1,124,"2016-01-07 02:37:13.138332+03",,96db80c0-db13-4d02-a019-d7826e6a71a1)</l_token>	root	1	\N
2016-01-07 02:37:13.172616+03	1	1	125	<l_token>(97,97#99a3d341-bc54-4a5f-d12e-35ac435318a1,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,125,"2016-01-07 02:37:13.171555+03",,99a3d341-bc54-4a5f-d12e-35ac435318a1)</l_token>	test-001	1	\N
2016-01-07 02:37:13.249158+03	4	1	125	<l_token>(97,97#99a3d341-bc54-4a5f-d12e-35ac435318a1,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,125,"2016-01-07 02:37:13.171555+03","2016-01-07 02:37:13.243156+03",99a3d341-bc54-4a5f-d12e-35ac435318a1)</l_token>	test-001	1	97#99a3d341-bc54-4a5f-d12e-35ac435318a1
2016-01-07 02:37:13.251456+03	4	1	124	<l_token>(96,96#96db80c0-db13-4d02-a019-d7826e6a71a1,,1,124,"2016-01-07 02:37:13.138332+03","2016-01-07 02:37:13.250308+03",96db80c0-db13-4d02-a019-d7826e6a71a1)</l_token>	root	1	96#96db80c0-db13-4d02-a019-d7826e6a71a1
2016-01-07 02:37:23.025914+03	2	1	126	<user_name>test-001</user_name><auth_path_id>1</auth_path_id><credential>-te$t-creDential#001</credential>	test-001	1	-te$t-creDential#001
2016-01-09 00:55:34.730322+03	1	1	141	<l_token>(112,112#71ba20e2-e05d-d687-4c6c-4cf21ab6aa88,,1,141,"2016-01-09 00:55:34.729662+03",,71ba20e2-e05d-d687-4c6c-4cf21ab6aa88)</l_token>	root	1	\N
2016-01-09 00:55:34.739363+03	9	1	141	<l_user>(28,27,user01,)</l_user>	\N	\N	\N
2016-01-09 01:16:43.452998+03	1	1	142	<l_token>(113,113#2af0dafd-e441-ea1b-483a-ed077f55cc2c,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,142,"2016-01-09 01:16:43.448419+03",,2af0dafd-e441-ea1b-483a-ed077f55cc2c)</l_token>	user01	\N	\N
2016-01-09 01:29:03.411384+03	1	1	143	<l_token>(114,114#8e691d77-858a-2de6-793a-411329cd9963,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,143,"2016-01-09 01:29:03.410791+03",,8e691d77-858a-2de6-793a-411329cd9963)</l_token>	user01	\N	\N
2016-01-09 01:29:15.806844+03	1	1	144	<l_token>(115,115#9467e5ee-7ee5-e70f-1976-a3a14b31d233,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,144,"2016-01-09 01:29:15.806359+03",,9467e5ee-7ee5-e70f-1976-a3a14b31d233)</l_token>	user01	\N	\N
2016-01-09 01:32:54.508606+03	1	1	145	<l_token>(116,116#38e7414f-ec5f-a201-168f-7ac561d36036,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,145,"2016-01-09 01:32:54.508011+03",,38e7414f-ec5f-a201-168f-7ac561d36036)</l_token>	user01	\N	\N
2016-01-09 01:34:34.129806+03	1	1	146	<l_token>(117,117#c26e0c0c-2022-fb86-8c2d-06693182c650,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,146,"2016-01-09 01:34:34.129369+03",,c26e0c0c-2022-fb86-8c2d-06693182c650)</l_token>	user01	\N	\N
2016-01-09 01:35:36.45861+03	1	1	147	<l_token>(118,118#9f29bd5d-0451-92ad-465c-f61f5ff8d60b,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,147,"2016-01-09 01:35:36.458133+03",,9f29bd5d-0451-92ad-465c-f61f5ff8d60b)</l_token>	user01	\N	\N
2016-01-09 01:45:41.039833+03	1	1	148	<l_token>(119,119#2c496ac2-5dcb-328f-c039-eab47ed50f79,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,148,"2016-01-09 01:45:41.034459+03",,2c496ac2-5dcb-328f-c039-eab47ed50f79)</l_token>	user01	\N	\N
2016-01-09 01:45:52.235221+03	1	1	149	<l_token>(120,120#e25edb80-97dc-8af7-c276-7365831a3a15,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,149,"2016-01-09 01:45:52.234485+03",,e25edb80-97dc-8af7-c276-7365831a3a15)</l_token>	user01	\N	\N
2016-01-09 01:51:33.608745+03	1	1	150	<l_token>(121,121#6d7b83fb-d9e5-63c7-bd9e-bb112832efe7,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,150,"2016-01-09 01:51:33.608134+03",,6d7b83fb-d9e5-63c7-bd9e-bb112832efe7)</l_token>	user01	\N	\N
2016-01-09 01:52:46.799723+03	1	1	151	<l_token>(122,122#14c00e50-58a7-f6b6-5b95-b1203b8fae6d,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,151,"2016-01-09 01:52:46.799275+03",,14c00e50-58a7-f6b6-5b95-b1203b8fae6d)</l_token>	user01	\N	\N
2016-01-09 18:31:37.167301+03	2	1	152	<user_name>user01</user_name><auth_path_id></auth_path_id><credential>[C@77b52d12</credential>	user01	\N	[C@77b52d12
2016-01-09 18:35:19.75424+03	2	1	153	<user_name>user01</user_name><auth_path_id></auth_path_id><credential>[C@77b52d12</credential>	user01	\N	[C@77b52d12
2016-01-09 19:56:11.269936+03	2	1	154	<user_name>user01</user_name><auth_path_id></auth_path_id><credential>[C@2d554825</credential>	user01	\N	[C@2d554825
2016-01-09 20:57:56.655705+03	1	1	155	<l_token>(123,123#9f695e90-9961-61ad-dab2-a4466db15940,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,155,"2016-01-09 20:57:56.650502+03",,9f695e90-9961-61ad-dab2-a4466db15940)</l_token>	user01	\N	\N
2016-01-09 22:05:49.79034+03	1	1	156	<l_token>(124,124#8aa0a06a-9e9b-424b-9957-2e45df87f392,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,156,"2016-01-09 22:05:49.750204+03",,8aa0a06a-9e9b-424b-9957-2e45df87f392)</l_token>	user01	\N	\N
2016-01-09 22:10:23.175824+03	1	1	157	<l_token>(125,125#9a4f7abc-2c71-7b7d-9198-a454a80f7df4,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,157,"2016-01-09 22:10:23.17104+03",,9a4f7abc-2c71-7b7d-9198-a454a80f7df4)</l_token>	user01	\N	\N
2016-01-09 22:12:12.230232+03	1	1	158	<l_token>(126,126#e8630caf-e714-eb2b-9c34-f14994a7ffaa,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,158,"2016-01-09 22:12:12.226035+03",,e8630caf-e714-eb2b-9c34-f14994a7ffaa)</l_token>	user01	\N	\N
2016-01-09 22:20:30.917295+03	1	1	159	<l_token>(127,127#1cf50438-4588-45f8-3f45-231485415efc,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,159,"2016-01-09 22:20:30.912302+03",,1cf50438-4588-45f8-3f45-231485415efc)</l_token>	user01	\N	\N
2016-01-09 22:20:31.025235+03	1	1	160	<l_token>(128,128#ae358825-83b3-bb71-8f6f-cb24a62d0878,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,160,"2016-01-09 22:20:31.02479+03",,ae358825-83b3-bb71-8f6f-cb24a62d0878)</l_token>	user01	\N	\N
2016-01-09 22:20:31.076494+03	1	1	161	<l_token>(129,129#278497a1-8127-93c0-6862-dee2fe04c903,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,161,"2016-01-09 22:20:31.076026+03",,278497a1-8127-93c0-6862-dee2fe04c903)</l_token>	user01	\N	\N
2016-01-09 22:25:15.01291+03	1	1	162	<l_token>(130,130#8a7289a6-cad5-ae79-1153-8d65422b9918,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,162,"2016-01-09 22:25:15.00859+03",,8a7289a6-cad5-ae79-1153-8d65422b9918)</l_token>	user01	\N	\N
2016-01-09 22:25:15.114369+03	1	1	163	<l_token>(131,131#0444d0c9-dbb1-8430-fb22-a197040b7137,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,163,"2016-01-09 22:25:15.11393+03",,0444d0c9-dbb1-8430-fb22-a197040b7137)</l_token>	user01	\N	\N
2016-01-09 22:25:15.165052+03	1	1	164	<l_token>(132,132#427acde3-7306-926b-5889-3ceafcaf7b14,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,164,"2016-01-09 22:25:15.164586+03",,427acde3-7306-926b-5889-3ceafcaf7b14)</l_token>	user01	\N	\N
2016-01-09 22:33:01.323846+03	1	1	165	<l_token>(133,133#7271476d-d416-c15d-00b9-c236aba1a8d1,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,165,"2016-01-09 22:33:01.319191+03",,7271476d-d416-c15d-00b9-c236aba1a8d1)</l_token>	user01	\N	\N
2016-01-09 22:33:01.409737+03	1	1	166	<l_token>(134,134#597562df-3f9e-b0ca-228d-c321e8bbf9e1,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,166,"2016-01-09 22:33:01.409283+03",,597562df-3f9e-b0ca-228d-c321e8bbf9e1)</l_token>	user01	\N	\N
2016-01-09 22:33:01.469589+03	1	1	167	<l_token>(135,135#1b0cfa55-337d-1aa0-6c51-3eaddeb120d3,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,,167,"2016-01-09 22:33:01.469152+03",,1b0cfa55-337d-1aa0-6c51-3eaddeb120d3)</l_token>	user01	\N	\N
2016-01-09 23:29:03.38648+03	1	1	168	<l_token>(136,136#74e5a8a3-91cb-1ded-08dd-5fa75a01c5a4,,1,168,"2016-01-09 23:29:03.381336+03",,74e5a8a3-91cb-1ded-08dd-5fa75a01c5a4)</l_token>	root	1	\N
2016-01-09 23:29:03.425304+03	1	1	169	<l_token>(137,137#4f2baaa5-ffa1-049d-f740-98decbdae84f,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,169,"2016-01-09 23:29:03.424256+03",,4f2baaa5-ffa1-049d-f740-98decbdae84f)</l_token>	test-001	1	\N
2016-01-09 23:29:03.556784+03	4	1	169	<l_token>(137,137#4f2baaa5-ffa1-049d-f740-98decbdae84f,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,169,"2016-01-09 23:29:03.424256+03","2016-01-09 23:29:03.551041+03",4f2baaa5-ffa1-049d-f740-98decbdae84f)</l_token>	test-001	1	137#4f2baaa5-ffa1-049d-f740-98decbdae84f
2016-01-09 23:29:03.559189+03	4	1	168	<l_token>(136,136#74e5a8a3-91cb-1ded-08dd-5fa75a01c5a4,,1,168,"2016-01-09 23:29:03.381336+03","2016-01-09 23:29:03.55794+03",74e5a8a3-91cb-1ded-08dd-5fa75a01c5a4)</l_token>	root	1	136#74e5a8a3-91cb-1ded-08dd-5fa75a01c5a4
2016-01-09 23:38:12.939989+03	1	1	170	<l_token>(138,138#06758c01-0d9f-0335-7fad-0b6f095ed62c,,1,170,"2016-01-09 23:38:12.938618+03",,06758c01-0d9f-0335-7fad-0b6f095ed62c)</l_token>	root	1	\N
2016-01-09 23:38:12.955881+03	1	1	171	<l_token>(139,139#1b27fb3c-2ab3-7b3f-b854-cda90a6bba53,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,171,"2016-01-09 23:38:12.955286+03",,1b27fb3c-2ab3-7b3f-b854-cda90a6bba53)</l_token>	test-001	1	\N
2016-01-09 23:38:13.013841+03	4	1	171	<l_token>(139,139#1b27fb3c-2ab3-7b3f-b854-cda90a6bba53,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,171,"2016-01-09 23:38:12.955286+03","2016-01-09 23:38:13.011094+03",1b27fb3c-2ab3-7b3f-b854-cda90a6bba53)</l_token>	test-001	1	139#1b27fb3c-2ab3-7b3f-b854-cda90a6bba53
2016-01-09 23:38:13.015958+03	4	1	170	<l_token>(138,138#06758c01-0d9f-0335-7fad-0b6f095ed62c,,1,170,"2016-01-09 23:38:12.938618+03","2016-01-09 23:38:13.014671+03",06758c01-0d9f-0335-7fad-0b6f095ed62c)</l_token>	root	1	138#06758c01-0d9f-0335-7fad-0b6f095ed62c
2016-01-09 23:40:26.620667+03	1	1	172	<l_token>(140,140#7a35ddee-6a6b-789b-3ef6-59855c084466,,1,172,"2016-01-09 23:40:26.620172+03",,7a35ddee-6a6b-789b-3ef6-59855c084466)</l_token>	root	1	\N
2016-01-09 23:40:26.634701+03	1	1	173	<l_token>(141,141#0ad4a78d-456b-3c6b-a6c0-c80da63b8f12,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,173,"2016-01-09 23:40:26.634162+03",,0ad4a78d-456b-3c6b-a6c0-c80da63b8f12)</l_token>	test-001	1	\N
2016-01-09 23:40:26.689414+03	4	1	173	<l_token>(141,141#0ad4a78d-456b-3c6b-a6c0-c80da63b8f12,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,173,"2016-01-09 23:40:26.634162+03","2016-01-09 23:40:26.688194+03",0ad4a78d-456b-3c6b-a6c0-c80da63b8f12)</l_token>	test-001	1	141#0ad4a78d-456b-3c6b-a6c0-c80da63b8f12
2016-01-09 23:40:26.691625+03	4	1	172	<l_token>(140,140#7a35ddee-6a6b-789b-3ef6-59855c084466,,1,172,"2016-01-09 23:40:26.620172+03","2016-01-09 23:40:26.690403+03",7a35ddee-6a6b-789b-3ef6-59855c084466)</l_token>	root	1	140#7a35ddee-6a6b-789b-3ef6-59855c084466
2016-01-09 23:45:09.188403+03	1	1	174	<l_token>(142,142#e3854bb8-6787-57a3-0e74-34575ff9c6ca,,1,174,"2016-01-09 23:45:09.187727+03",,e3854bb8-6787-57a3-0e74-34575ff9c6ca)</l_token>	root	1	\N
2016-01-09 23:45:09.204292+03	1	1	175	<l_token>(143,143#c59ec12b-66c5-58c7-5ec9-f087e58fda7d,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,175,"2016-01-09 23:45:09.203799+03",,c59ec12b-66c5-58c7-5ec9-f087e58fda7d)</l_token>	test-001	1	\N
2016-01-09 23:45:09.263084+03	4	1	175	<l_token>(143,143#c59ec12b-66c5-58c7-5ec9-f087e58fda7d,$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6,1,175,"2016-01-09 23:45:09.203799+03","2016-01-09 23:45:09.261665+03",c59ec12b-66c5-58c7-5ec9-f087e58fda7d)</l_token>	test-001	1	143#c59ec12b-66c5-58c7-5ec9-f087e58fda7d
2016-01-09 23:45:09.265309+03	4	1	174	<l_token>(142,142#e3854bb8-6787-57a3-0e74-34575ff9c6ca,,1,174,"2016-01-09 23:45:09.187727+03","2016-01-09 23:45:09.264133+03",e3854bb8-6787-57a3-0e74-34575ff9c6ca)</l_token>	root	1	142#e3854bb8-6787-57a3-0e74-34575ff9c6ca
2016-01-10 00:57:24.288623+03	1	1	176	<l_token>(144,144#e5054dc9-97a8-893f-59b8-0423a9d3d525,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,1,176,"2016-01-10 00:57:24.282888+03",,e5054dc9-97a8-893f-59b8-0423a9d3d525)</l_token>	user01	\N	\N
2016-01-10 00:57:24.408084+03	1	1	177	<l_token>(145,145#4fd98f50-417e-8dd6-7c08-281afc690d2c,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,1,177,"2016-01-10 00:57:24.40739+03",,4fd98f50-417e-8dd6-7c08-281afc690d2c)</l_token>	user01	\N	\N
2016-01-10 00:57:24.461242+03	1	1	178	<l_token>(146,146#f8ba9888-4feb-d924-da74-1bf27b06f209,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,1,178,"2016-01-10 00:57:24.460666+03",,f8ba9888-4feb-d924-da74-1bf27b06f209)</l_token>	user01	\N	\N
2016-01-10 02:39:50.935031+03	1	1	179	<l_token>(147,147#f39fe393-4f57-c784-f532-800e41e49c95,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,1,179,"2016-01-10 02:39:50.930098+03",,f39fe393-4f57-c784-f532-800e41e49c95)</l_token>	user01	\N	\N
2016-01-10 02:40:35.770845+03	2	1	180	<user_name>user01</user_name><auth_path_id></auth_path_id><credential>123</credential>	user01	\N	123
2016-01-10 02:40:54.518281+03	1	1	181	<l_token>(148,148#53ee20c2-196d-dde5-c3b4-f8aa75d24511,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,1,181,"2016-01-10 02:40:54.517627+03",,53ee20c2-196d-dde5-c3b4-f8aa75d24511)</l_token>	user01	\N	\N
2016-01-10 02:46:34.105846+03	1	1	182	<l_token>(149,149#b286c9e1-6d6b-c823-7a7a-6099dc82768e,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,1,182,"2016-01-10 02:46:34.099967+03",,b286c9e1-6d6b-c823-7a7a-6099dc82768e)</l_token>	user01	\N	\N
2016-01-10 02:46:51.267864+03	1	1	183	<l_token>(150,150#01636c88-a5c1-488d-8417-a4d0750c70c5,$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO,1,183,"2016-01-10 02:46:51.267352+03",,01636c88-a5c1-488d-8417-a4d0750c70c5)</l_token>	user01	\N	\N
\.


--
-- Data for Name: sec_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_session (user_id, whenstarted, whenended, id) FROM stdin;
1	2015-12-03 00:00:00+03	\N	1
1	2015-12-03 23:29:42.324451+03	\N	2
1	2015-12-03 23:23:01.995911+03	\N	3
1	2015-12-03 23:19:51.317474+03	\N	4
1	2015-12-03 23:47:48.062573+03	\N	5
1	2015-12-14 23:07:15.094859+03	\N	6
1	2016-01-02 01:24:55.281193+03	\N	13
1	2016-01-02 01:25:49.402142+03	\N	14
1	2016-01-02 01:57:27.326147+03	2016-01-02 01:57:27.331323+03	21
1	2016-01-03 01:25:07.938238+03	\N	28
1	2016-01-04 01:51:20.02965+03	\N	31
1	2016-01-06 02:04:12.727039+03	\N	32
1	2016-01-06 02:04:15.202962+03	\N	33
1	2016-01-06 02:17:42.788032+03	\N	37
25	2016-01-06 02:17:42.80454+03	\N	38
1	2016-01-06 02:24:43.049245+03	\N	39
25	2016-01-06 02:24:43.068885+03	\N	40
1	2016-01-06 02:30:12.134391+03	\N	41
25	2016-01-06 02:30:12.150434+03	\N	42
1	2016-01-06 23:48:35.364139+03	\N	94
25	2016-01-06 23:48:35.40549+03	\N	96
1	2016-01-07 00:23:49.704738+03	\N	103
25	2016-01-07 00:23:49.718982+03	\N	104
1	2016-01-07 00:23:59.738338+03	\N	105
25	2016-01-07 00:23:59.75326+03	\N	106
1	2016-01-07 00:25:13.28023+03	\N	107
25	2016-01-07 00:25:13.295131+03	\N	108
1	2016-01-07 00:25:13.920181+03	\N	109
25	2016-01-07 00:25:13.934574+03	\N	110
1	2016-01-07 00:28:58.357206+03	\N	111
25	2016-01-07 00:28:58.373675+03	\N	112
1	2016-01-07 01:52:23.623494+03	\N	113
25	2016-01-07 01:52:23.664417+03	\N	114
25	2016-01-07 01:56:08.150061+03	\N	115
25	2016-01-07 01:58:11.868894+03	\N	119
25	2016-01-07 01:59:24.262703+03	\N	120
1	2016-01-07 02:18:15.185377+03	\N	122
25	2016-01-07 02:18:15.205314+03	\N	123
1	2016-01-09 00:55:34.729155+03	\N	141
28	2016-01-09 01:16:43.441397+03	\N	142
28	2016-01-09 01:29:03.410103+03	\N	143
28	2016-01-09 01:29:15.805794+03	\N	144
28	2016-01-09 01:32:54.507324+03	\N	145
28	2016-01-09 01:34:34.128808+03	\N	146
28	2016-01-09 01:35:36.457574+03	\N	147
28	2016-01-09 01:45:41.028018+03	\N	148
28	2016-01-09 01:45:52.233841+03	\N	149
28	2016-01-09 01:51:33.607498+03	\N	150
28	2016-01-09 01:52:46.79857+03	\N	151
28	2016-01-09 20:57:56.644271+03	\N	155
28	2016-01-09 22:05:49.701876+03	\N	156
28	2016-01-09 22:10:23.165061+03	\N	157
28	2016-01-09 22:12:12.220141+03	\N	158
28	2016-01-09 22:20:30.905989+03	\N	159
28	2016-01-09 22:20:31.024201+03	\N	160
28	2016-01-09 22:20:31.075383+03	\N	161
28	2016-01-09 22:25:15.002686+03	\N	162
28	2016-01-09 22:25:15.113387+03	\N	163
28	2016-01-09 22:25:15.164035+03	\N	164
28	2016-01-09 22:33:01.312814+03	\N	165
28	2016-01-09 22:33:01.408674+03	\N	166
28	2016-01-09 22:33:01.468608+03	\N	167
28	2016-01-10 00:57:24.276094+03	\N	176
28	2016-01-10 00:57:24.406559+03	\N	177
28	2016-01-10 00:57:24.460031+03	\N	178
28	2016-01-10 02:39:50.924094+03	\N	179
28	2016-01-10 02:40:54.516947+03	\N	181
28	2016-01-10 02:46:34.093781+03	\N	182
28	2016-01-10 02:46:51.2668+03	\N	183
\.


--
-- Name: sec_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sec_session_id_seq', 183, true);


--
-- Data for Name: sec_session_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_session_log (user_id, whenstarted, whenended, id, when_logged) FROM stdin;
1	2016-01-04 01:51:20.02965+03	\N	31	2016-01-04 01:51:20.029931+03
1	2016-01-06 02:04:12.727039+03	\N	32	2016-01-06 02:04:12.729061+03
1	2016-01-06 02:04:15.202962+03	\N	33	2016-01-06 02:04:15.203181+03
1	2016-01-06 02:17:42.788032+03	\N	37	2016-01-06 02:17:42.788318+03
25	2016-01-06 02:17:42.80454+03	\N	38	2016-01-06 02:17:42.804958+03
1	2016-01-06 02:24:43.049245+03	\N	39	2016-01-06 02:24:43.049846+03
25	2016-01-06 02:24:43.068885+03	\N	40	2016-01-06 02:24:43.069305+03
1	2016-01-06 02:30:12.134391+03	\N	41	2016-01-06 02:30:12.134687+03
25	2016-01-06 02:30:12.150434+03	\N	42	2016-01-06 02:30:12.150643+03
1	2016-01-06 23:48:35.364139+03	\N	94	2016-01-06 23:48:35.364353+03
25	2016-01-06 23:48:35.40549+03	\N	96	2016-01-06 23:48:35.405787+03
1	2016-01-07 00:23:49.704738+03	\N	103	2016-01-07 00:23:49.705009+03
25	2016-01-07 00:23:49.718982+03	\N	104	2016-01-07 00:23:49.71919+03
1	2016-01-07 00:23:59.738338+03	\N	105	2016-01-07 00:23:59.738695+03
25	2016-01-07 00:23:59.75326+03	\N	106	2016-01-07 00:23:59.753469+03
1	2016-01-07 00:25:13.28023+03	\N	107	2016-01-07 00:25:13.280443+03
25	2016-01-07 00:25:13.295131+03	\N	108	2016-01-07 00:25:13.295342+03
1	2016-01-07 00:25:13.920181+03	\N	109	2016-01-07 00:25:13.920487+03
25	2016-01-07 00:25:13.934574+03	\N	110	2016-01-07 00:25:13.934878+03
1	2016-01-07 00:28:58.357206+03	\N	111	2016-01-07 00:28:58.357484+03
25	2016-01-07 00:28:58.373675+03	\N	112	2016-01-07 00:28:58.374031+03
1	2016-01-07 01:52:23.623494+03	\N	113	2016-01-07 01:52:23.625809+03
25	2016-01-07 01:52:23.664417+03	\N	114	2016-01-07 01:52:23.66488+03
25	2016-01-07 01:56:08.150061+03	\N	115	2016-01-07 01:56:08.151782+03
25	2016-01-07 01:58:11.868894+03	\N	119	2016-01-07 01:58:11.869415+03
25	2016-01-07 01:59:24.262703+03	\N	120	2016-01-07 01:59:24.263229+03
1	2016-01-07 02:18:15.185377+03	\N	122	2016-01-07 02:18:15.186075+03
25	2016-01-07 02:18:15.205314+03	\N	123	2016-01-07 02:18:15.205836+03
25	2016-01-07 02:37:13.170203+03	2016-01-07 02:37:13.246044+03	125	2016-01-07 02:37:13.246044+03
1	2016-01-07 02:37:13.13398+03	2016-01-07 02:37:13.250909+03	124	2016-01-07 02:37:13.250909+03
1	2016-01-09 00:55:34.729155+03	\N	141	2016-01-09 00:55:34.729431+03
28	2016-01-09 01:16:43.441397+03	\N	142	2016-01-09 01:16:43.443531+03
28	2016-01-09 01:29:03.410103+03	\N	143	2016-01-09 01:29:03.410392+03
28	2016-01-09 01:29:15.805794+03	\N	144	2016-01-09 01:29:15.806027+03
28	2016-01-09 01:32:54.507324+03	\N	145	2016-01-09 01:32:54.507595+03
28	2016-01-09 01:34:34.128808+03	\N	146	2016-01-09 01:34:34.129036+03
28	2016-01-09 01:35:36.457574+03	\N	147	2016-01-09 01:35:36.457801+03
28	2016-01-09 01:45:41.028018+03	\N	148	2016-01-09 01:45:41.029855+03
28	2016-01-09 01:45:52.233841+03	\N	149	2016-01-09 01:45:52.234128+03
28	2016-01-09 01:51:33.607498+03	\N	150	2016-01-09 01:51:33.607778+03
28	2016-01-09 01:52:46.79857+03	\N	151	2016-01-09 01:52:46.798912+03
28	2016-01-09 20:57:56.644271+03	\N	155	2016-01-09 20:57:56.64601+03
28	2016-01-09 22:05:49.701876+03	\N	156	2016-01-09 22:05:49.703747+03
28	2016-01-09 22:10:23.165061+03	\N	157	2016-01-09 22:10:23.166921+03
28	2016-01-09 22:12:12.220141+03	\N	158	2016-01-09 22:12:12.221855+03
28	2016-01-09 22:20:30.905989+03	\N	159	2016-01-09 22:20:30.907839+03
28	2016-01-09 22:20:31.024201+03	\N	160	2016-01-09 22:20:31.024423+03
28	2016-01-09 22:20:31.075383+03	\N	161	2016-01-09 22:20:31.075606+03
28	2016-01-09 22:25:15.002686+03	\N	162	2016-01-09 22:25:15.004459+03
28	2016-01-09 22:25:15.113387+03	\N	163	2016-01-09 22:25:15.11361+03
28	2016-01-09 22:25:15.164035+03	\N	164	2016-01-09 22:25:15.164259+03
28	2016-01-09 22:33:01.312814+03	\N	165	2016-01-09 22:33:01.314779+03
28	2016-01-09 22:33:01.408674+03	\N	166	2016-01-09 22:33:01.408955+03
28	2016-01-09 22:33:01.468608+03	\N	167	2016-01-09 22:33:01.468829+03
25	2016-01-09 23:29:03.423017+03	2016-01-09 23:29:03.553968+03	169	2016-01-09 23:29:03.553968+03
1	2016-01-09 23:29:03.376409+03	2016-01-09 23:29:03.558536+03	168	2016-01-09 23:29:03.558536+03
25	2016-01-09 23:38:12.954501+03	2016-01-09 23:38:13.01201+03	171	2016-01-09 23:38:13.01201+03
1	2016-01-09 23:38:12.93724+03	2016-01-09 23:38:13.015304+03	170	2016-01-09 23:38:13.015304+03
25	2016-01-09 23:40:26.633649+03	2016-01-09 23:40:26.688813+03	173	2016-01-09 23:40:26.688813+03
1	2016-01-09 23:40:26.619721+03	2016-01-09 23:40:26.691037+03	172	2016-01-09 23:40:26.691037+03
25	2016-01-09 23:45:09.203283+03	2016-01-09 23:45:09.262287+03	175	2016-01-09 23:45:09.262287+03
1	2016-01-09 23:45:09.187182+03	2016-01-09 23:45:09.264717+03	174	2016-01-09 23:45:09.264717+03
28	2016-01-10 00:57:24.276094+03	\N	176	2016-01-10 00:57:24.277824+03
28	2016-01-10 00:57:24.406559+03	\N	177	2016-01-10 00:57:24.406886+03
28	2016-01-10 00:57:24.460031+03	\N	178	2016-01-10 00:57:24.460257+03
28	2016-01-10 02:39:50.924094+03	\N	179	2016-01-10 02:39:50.92584+03
28	2016-01-10 02:40:54.516947+03	\N	181	2016-01-10 02:40:54.51724+03
28	2016-01-10 02:46:34.093781+03	\N	182	2016-01-10 02:46:34.095662+03
28	2016-01-10 02:46:51.2668+03	\N	183	2016-01-10 02:46:51.267029+03
\.


--
-- Data for Name: sec_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_token (id, localvalue, credential, auth_path_id, session_id, validfrom, validtill, originvalue) FROM stdin;
7	85d135d1-1368-7737-f668-997aedd00c4c	\N	1	13	2016-01-02 01:24:55.281817+03	\N	\N
8	6a54e86b-4510-9df6-c6a7-1cef1a94cbcd	\N	1	14	2016-01-02 01:25:49.403274+03	\N	\N
15	a1ef75db-9e64-e9b7-8145-19c226ed9f4b	\N	1	21	2016-01-02 01:57:27.326467+03	2016-01-02 01:57:27.330516+03	\N
22	56780b26-c475-d68a-c922-710ff64e9f32	\N	1	28	2016-01-03 01:25:07.938485+03	\N	\N
25	25#b82c08eb-472c-f985-1732-64d5d07639c3	\N	1	31	2016-01-04 01:51:20.030188+03	\N	b82c08eb-472c-f985-1732-64d5d07639c3
26	26#e45c6c27-e576-ab7f-9db1-890f472bf109	\N	1	32	2016-01-06 02:04:12.731973+03	\N	e45c6c27-e576-ab7f-9db1-890f472bf109
27	27#5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca	\N	1	33	2016-01-06 02:04:15.203489+03	\N	5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca
31	31#0e8fc585-9bbf-77ad-bc9f-40855c29d089	\N	1	37	2016-01-06 02:17:42.788536+03	\N	0e8fc585-9bbf-77ad-bc9f-40855c29d089
32	32#88a21ecd-bfb9-f482-8085-53daac48054c	$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q	1	38	2016-01-06 02:17:42.805899+03	\N	88a21ecd-bfb9-f482-8085-53daac48054c
33	33#c87f6b71-35e8-b89a-762d-75fe29bc76ef	\N	1	39	2016-01-06 02:24:43.050827+03	\N	c87f6b71-35e8-b89a-762d-75fe29bc76ef
34	34#f9e5420a-2f16-1296-f4a7-eb7e3d70c59e	$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q	1	40	2016-01-06 02:24:43.070376+03	\N	f9e5420a-2f16-1296-f4a7-eb7e3d70c59e
35	35#e749c61b-0daa-da66-55d2-da7affe6d025	\N	1	41	2016-01-06 02:30:12.134964+03	\N	e749c61b-0daa-da66-55d2-da7affe6d025
36	36#b54cbbb7-fcee-d6c6-3892-43fb3d17b146	$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q	1	42	2016-01-06 02:30:12.150998+03	\N	b54cbbb7-fcee-d6c6-3892-43fb3d17b146
73	73#4a82bf3b-4be4-a096-1f3b-132c56926384	\N	1	94	2016-01-06 23:48:35.364557+03	\N	4a82bf3b-4be4-a096-1f3b-132c56926384
74	74#0c263ba6-0cbb-31ef-492e-44f57596bf2b	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	96	2016-01-06 23:48:35.406108+03	\N	0c263ba6-0cbb-31ef-492e-44f57596bf2b
79	79#417fe44e-1597-6ad2-97d0-b49fac29c5de	\N	1	103	2016-01-07 00:23:49.705234+03	\N	417fe44e-1597-6ad2-97d0-b49fac29c5de
80	80#21d72e94-72d4-6838-7c3d-39724d7cb075	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	104	2016-01-07 00:23:49.719499+03	\N	21d72e94-72d4-6838-7c3d-39724d7cb075
81	81#05fe16d3-fed4-a04d-acdd-5fd91fc4a607	\N	1	105	2016-01-07 00:23:59.739078+03	\N	05fe16d3-fed4-a04d-acdd-5fd91fc4a607
82	82#cc0ed478-605f-e14f-a7c6-841804218044	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	106	2016-01-07 00:23:59.753777+03	\N	cc0ed478-605f-e14f-a7c6-841804218044
83	83#d737370a-ede2-6146-c1e4-de0ddd50b4af	\N	1	107	2016-01-07 00:25:13.280645+03	\N	d737370a-ede2-6146-c1e4-de0ddd50b4af
84	84#b748be7c-3888-34bd-d886-4af78b5ef96b	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	108	2016-01-07 00:25:13.295651+03	\N	b748be7c-3888-34bd-d886-4af78b5ef96b
85	85#871b3ec3-3d5b-8ec0-1c52-9e774b862355	\N	1	109	2016-01-07 00:25:13.92078+03	\N	871b3ec3-3d5b-8ec0-1c52-9e774b862355
86	86#05743ed8-9af1-6bba-691d-686d65952624	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	110	2016-01-07 00:25:13.935198+03	\N	05743ed8-9af1-6bba-691d-686d65952624
87	87#bb1fdb5d-0959-3785-df5e-90f52acc62e1	\N	1	111	2016-01-07 00:28:58.357735+03	\N	bb1fdb5d-0959-3785-df5e-90f52acc62e1
88	88#e9c59acb-4a72-c6fb-4eb8-8612121493dd	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	112	2016-01-07 00:28:58.374353+03	\N	e9c59acb-4a72-c6fb-4eb8-8612121493dd
89	89#6ce09d29-b92f-82b5-d90f-8909c1f76e2e	\N	1	113	2016-01-07 01:52:23.629269+03	\N	6ce09d29-b92f-82b5-d90f-8909c1f76e2e
90	90#3b906d68-16cd-7ed9-fed7-34f4ed9f52f8	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	114	2016-01-07 01:52:23.665754+03	\N	3b906d68-16cd-7ed9-fed7-34f4ed9f52f8
91	91#4242bffa-1e38-9019-ff60-1834c32dab2e	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	115	2016-01-07 01:56:08.15582+03	\N	4242bffa-1e38-9019-ff60-1834c32dab2e
92	92#44e08338-b209-5369-8960-f3635240ffda	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	119	2016-01-07 01:58:11.869799+03	\N	44e08338-b209-5369-8960-f3635240ffda
93	93#f6399685-3ea0-2714-cb84-c1279eb398cf	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	120	2016-01-07 01:59:24.264296+03	\N	f6399685-3ea0-2714-cb84-c1279eb398cf
94	94#f8aefc8b-ec66-f03f-8428-915049b2661b	\N	1	122	2016-01-07 02:18:15.186978+03	\N	f8aefc8b-ec66-f03f-8428-915049b2661b
95	95#ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	123	2016-01-07 02:18:15.206935+03	\N	ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4
112	112#71ba20e2-e05d-d687-4c6c-4cf21ab6aa88	\N	1	141	2016-01-09 00:55:34.729662+03	\N	71ba20e2-e05d-d687-4c6c-4cf21ab6aa88
113	113#2af0dafd-e441-ea1b-483a-ed077f55cc2c	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	142	2016-01-09 01:16:43.448419+03	\N	2af0dafd-e441-ea1b-483a-ed077f55cc2c
114	114#8e691d77-858a-2de6-793a-411329cd9963	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	143	2016-01-09 01:29:03.410791+03	\N	8e691d77-858a-2de6-793a-411329cd9963
115	115#9467e5ee-7ee5-e70f-1976-a3a14b31d233	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	144	2016-01-09 01:29:15.806359+03	\N	9467e5ee-7ee5-e70f-1976-a3a14b31d233
116	116#38e7414f-ec5f-a201-168f-7ac561d36036	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	145	2016-01-09 01:32:54.508011+03	\N	38e7414f-ec5f-a201-168f-7ac561d36036
117	117#c26e0c0c-2022-fb86-8c2d-06693182c650	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	146	2016-01-09 01:34:34.129369+03	\N	c26e0c0c-2022-fb86-8c2d-06693182c650
118	118#9f29bd5d-0451-92ad-465c-f61f5ff8d60b	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	147	2016-01-09 01:35:36.458133+03	\N	9f29bd5d-0451-92ad-465c-f61f5ff8d60b
119	119#2c496ac2-5dcb-328f-c039-eab47ed50f79	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	148	2016-01-09 01:45:41.034459+03	\N	2c496ac2-5dcb-328f-c039-eab47ed50f79
120	120#e25edb80-97dc-8af7-c276-7365831a3a15	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	149	2016-01-09 01:45:52.234485+03	\N	e25edb80-97dc-8af7-c276-7365831a3a15
121	121#6d7b83fb-d9e5-63c7-bd9e-bb112832efe7	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	150	2016-01-09 01:51:33.608134+03	\N	6d7b83fb-d9e5-63c7-bd9e-bb112832efe7
122	122#14c00e50-58a7-f6b6-5b95-b1203b8fae6d	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	151	2016-01-09 01:52:46.799275+03	\N	14c00e50-58a7-f6b6-5b95-b1203b8fae6d
123	123#9f695e90-9961-61ad-dab2-a4466db15940	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	155	2016-01-09 20:57:56.650502+03	\N	9f695e90-9961-61ad-dab2-a4466db15940
124	124#8aa0a06a-9e9b-424b-9957-2e45df87f392	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	156	2016-01-09 22:05:49.750204+03	\N	8aa0a06a-9e9b-424b-9957-2e45df87f392
125	125#9a4f7abc-2c71-7b7d-9198-a454a80f7df4	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	157	2016-01-09 22:10:23.17104+03	\N	9a4f7abc-2c71-7b7d-9198-a454a80f7df4
126	126#e8630caf-e714-eb2b-9c34-f14994a7ffaa	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	158	2016-01-09 22:12:12.226035+03	\N	e8630caf-e714-eb2b-9c34-f14994a7ffaa
127	127#1cf50438-4588-45f8-3f45-231485415efc	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	159	2016-01-09 22:20:30.912302+03	\N	1cf50438-4588-45f8-3f45-231485415efc
128	128#ae358825-83b3-bb71-8f6f-cb24a62d0878	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	160	2016-01-09 22:20:31.02479+03	\N	ae358825-83b3-bb71-8f6f-cb24a62d0878
129	129#278497a1-8127-93c0-6862-dee2fe04c903	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	161	2016-01-09 22:20:31.076026+03	\N	278497a1-8127-93c0-6862-dee2fe04c903
130	130#8a7289a6-cad5-ae79-1153-8d65422b9918	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	162	2016-01-09 22:25:15.00859+03	\N	8a7289a6-cad5-ae79-1153-8d65422b9918
131	131#0444d0c9-dbb1-8430-fb22-a197040b7137	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	163	2016-01-09 22:25:15.11393+03	\N	0444d0c9-dbb1-8430-fb22-a197040b7137
132	132#427acde3-7306-926b-5889-3ceafcaf7b14	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	164	2016-01-09 22:25:15.164586+03	\N	427acde3-7306-926b-5889-3ceafcaf7b14
133	133#7271476d-d416-c15d-00b9-c236aba1a8d1	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	165	2016-01-09 22:33:01.319191+03	\N	7271476d-d416-c15d-00b9-c236aba1a8d1
134	134#597562df-3f9e-b0ca-228d-c321e8bbf9e1	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	166	2016-01-09 22:33:01.409283+03	\N	597562df-3f9e-b0ca-228d-c321e8bbf9e1
135	135#1b0cfa55-337d-1aa0-6c51-3eaddeb120d3	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	167	2016-01-09 22:33:01.469152+03	\N	1b0cfa55-337d-1aa0-6c51-3eaddeb120d3
144	144#e5054dc9-97a8-893f-59b8-0423a9d3d525	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	176	2016-01-10 00:57:24.282888+03	\N	e5054dc9-97a8-893f-59b8-0423a9d3d525
145	145#4fd98f50-417e-8dd6-7c08-281afc690d2c	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	177	2016-01-10 00:57:24.40739+03	\N	4fd98f50-417e-8dd6-7c08-281afc690d2c
146	146#f8ba9888-4feb-d924-da74-1bf27b06f209	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	178	2016-01-10 00:57:24.460666+03	\N	f8ba9888-4feb-d924-da74-1bf27b06f209
147	147#f39fe393-4f57-c784-f532-800e41e49c95	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	179	2016-01-10 02:39:50.930098+03	\N	f39fe393-4f57-c784-f532-800e41e49c95
148	148#53ee20c2-196d-dde5-c3b4-f8aa75d24511	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	181	2016-01-10 02:40:54.517627+03	\N	53ee20c2-196d-dde5-c3b4-f8aa75d24511
149	149#b286c9e1-6d6b-c823-7a7a-6099dc82768e	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	182	2016-01-10 02:46:34.099967+03	\N	b286c9e1-6d6b-c823-7a7a-6099dc82768e
150	150#01636c88-a5c1-488d-8417-a4d0750c70c5	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	183	2016-01-10 02:46:51.267352+03	\N	01636c88-a5c1-488d-8417-a4d0750c70c5
\.


--
-- Name: sec_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sec_token_id_seq', 150, true);


--
-- Data for Name: sec_token_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_token_log (id, localvalue, credential, auth_path_id, session_id, validfrom, validtill, originvalue, when_logged) FROM stdin;
25	25#b82c08eb-472c-f985-1732-64d5d07639c3	\N	1	31	2016-01-04 01:51:20.030188+03	\N	b82c08eb-472c-f985-1732-64d5d07639c3	2016-01-04 01:51:20.030506+03
26	26#e45c6c27-e576-ab7f-9db1-890f472bf109	\N	1	32	2016-01-06 02:04:12.731973+03	\N	e45c6c27-e576-ab7f-9db1-890f472bf109	2016-01-06 02:04:12.734575+03
27	27#5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca	\N	1	33	2016-01-06 02:04:15.203489+03	\N	5edd8b37-9d7b-d2ea-1831-0e4418a4e7ca	2016-01-06 02:04:15.203818+03
31	31#0e8fc585-9bbf-77ad-bc9f-40855c29d089	\N	1	37	2016-01-06 02:17:42.788536+03	\N	0e8fc585-9bbf-77ad-bc9f-40855c29d089	2016-01-06 02:17:42.788962+03
32	32#88a21ecd-bfb9-f482-8085-53daac48054c	$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q	1	38	2016-01-06 02:17:42.805899+03	\N	88a21ecd-bfb9-f482-8085-53daac48054c	2016-01-06 02:17:42.806483+03
33	33#c87f6b71-35e8-b89a-762d-75fe29bc76ef	\N	1	39	2016-01-06 02:24:43.050827+03	\N	c87f6b71-35e8-b89a-762d-75fe29bc76ef	2016-01-06 02:24:43.051806+03
34	34#f9e5420a-2f16-1296-f4a7-eb7e3d70c59e	$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q	1	40	2016-01-06 02:24:43.070376+03	\N	f9e5420a-2f16-1296-f4a7-eb7e3d70c59e	2016-01-06 02:24:43.07103+03
35	35#e749c61b-0daa-da66-55d2-da7affe6d025	\N	1	41	2016-01-06 02:30:12.134964+03	\N	e749c61b-0daa-da66-55d2-da7affe6d025	2016-01-06 02:30:12.135383+03
36	36#b54cbbb7-fcee-d6c6-3892-43fb3d17b146	$2a$06$SWPXTUjLxFh0vUpKj3vSVeEqNE8re1vigqalEKOhRPnyswbZWx.3q	1	42	2016-01-06 02:30:12.150998+03	\N	b54cbbb7-fcee-d6c6-3892-43fb3d17b146	2016-01-06 02:30:12.151386+03
73	73#4a82bf3b-4be4-a096-1f3b-132c56926384	\N	1	94	2016-01-06 23:48:35.364557+03	\N	4a82bf3b-4be4-a096-1f3b-132c56926384	2016-01-06 23:48:35.364846+03
74	74#0c263ba6-0cbb-31ef-492e-44f57596bf2b	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	96	2016-01-06 23:48:35.406108+03	\N	0c263ba6-0cbb-31ef-492e-44f57596bf2b	2016-01-06 23:48:35.406394+03
79	79#417fe44e-1597-6ad2-97d0-b49fac29c5de	\N	1	103	2016-01-07 00:23:49.705234+03	\N	417fe44e-1597-6ad2-97d0-b49fac29c5de	2016-01-07 00:23:49.705584+03
80	80#21d72e94-72d4-6838-7c3d-39724d7cb075	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	104	2016-01-07 00:23:49.719499+03	\N	21d72e94-72d4-6838-7c3d-39724d7cb075	2016-01-07 00:23:49.719818+03
81	81#05fe16d3-fed4-a04d-acdd-5fd91fc4a607	\N	1	105	2016-01-07 00:23:59.739078+03	\N	05fe16d3-fed4-a04d-acdd-5fd91fc4a607	2016-01-07 00:23:59.739421+03
82	82#cc0ed478-605f-e14f-a7c6-841804218044	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	106	2016-01-07 00:23:59.753777+03	\N	cc0ed478-605f-e14f-a7c6-841804218044	2016-01-07 00:23:59.754143+03
83	83#d737370a-ede2-6146-c1e4-de0ddd50b4af	\N	1	107	2016-01-07 00:25:13.280645+03	\N	d737370a-ede2-6146-c1e4-de0ddd50b4af	2016-01-07 00:25:13.281017+03
84	84#b748be7c-3888-34bd-d886-4af78b5ef96b	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	108	2016-01-07 00:25:13.295651+03	\N	b748be7c-3888-34bd-d886-4af78b5ef96b	2016-01-07 00:25:13.296137+03
85	85#871b3ec3-3d5b-8ec0-1c52-9e774b862355	\N	1	109	2016-01-07 00:25:13.92078+03	\N	871b3ec3-3d5b-8ec0-1c52-9e774b862355	2016-01-07 00:25:13.921088+03
86	86#05743ed8-9af1-6bba-691d-686d65952624	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	110	2016-01-07 00:25:13.935198+03	\N	05743ed8-9af1-6bba-691d-686d65952624	2016-01-07 00:25:13.935492+03
87	87#bb1fdb5d-0959-3785-df5e-90f52acc62e1	\N	1	111	2016-01-07 00:28:58.357735+03	\N	bb1fdb5d-0959-3785-df5e-90f52acc62e1	2016-01-07 00:28:58.358106+03
88	88#e9c59acb-4a72-c6fb-4eb8-8612121493dd	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	112	2016-01-07 00:28:58.374353+03	\N	e9c59acb-4a72-c6fb-4eb8-8612121493dd	2016-01-07 00:28:58.374648+03
89	89#6ce09d29-b92f-82b5-d90f-8909c1f76e2e	\N	1	113	2016-01-07 01:52:23.629269+03	\N	6ce09d29-b92f-82b5-d90f-8909c1f76e2e	2016-01-07 01:52:23.631981+03
90	90#3b906d68-16cd-7ed9-fed7-34f4ed9f52f8	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	114	2016-01-07 01:52:23.665754+03	\N	3b906d68-16cd-7ed9-fed7-34f4ed9f52f8	2016-01-07 01:52:23.666406+03
91	91#4242bffa-1e38-9019-ff60-1834c32dab2e	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	115	2016-01-07 01:56:08.15582+03	\N	4242bffa-1e38-9019-ff60-1834c32dab2e	2016-01-07 01:56:08.157933+03
92	92#44e08338-b209-5369-8960-f3635240ffda	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	119	2016-01-07 01:58:11.869799+03	\N	44e08338-b209-5369-8960-f3635240ffda	2016-01-07 01:58:11.870196+03
93	93#f6399685-3ea0-2714-cb84-c1279eb398cf	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	120	2016-01-07 01:59:24.264296+03	\N	f6399685-3ea0-2714-cb84-c1279eb398cf	2016-01-07 01:59:24.264922+03
94	94#f8aefc8b-ec66-f03f-8428-915049b2661b	\N	1	122	2016-01-07 02:18:15.186978+03	\N	f8aefc8b-ec66-f03f-8428-915049b2661b	2016-01-07 02:18:15.187727+03
95	95#ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	123	2016-01-07 02:18:15.206935+03	\N	ce585f5b-387b-4c4e-a64b-7b5e3c36b8d4	2016-01-07 02:18:15.207823+03
97	97#99a3d341-bc54-4a5f-d12e-35ac435318a1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	125	2016-01-07 02:37:13.171555+03	2016-01-07 02:37:13.243156+03	99a3d341-bc54-4a5f-d12e-35ac435318a1	2016-01-07 02:37:13.243156+03
96	96#96db80c0-db13-4d02-a019-d7826e6a71a1	\N	1	124	2016-01-07 02:37:13.138332+03	2016-01-07 02:37:13.250308+03	96db80c0-db13-4d02-a019-d7826e6a71a1	2016-01-07 02:37:13.250308+03
112	112#71ba20e2-e05d-d687-4c6c-4cf21ab6aa88	\N	1	141	2016-01-09 00:55:34.729662+03	\N	71ba20e2-e05d-d687-4c6c-4cf21ab6aa88	2016-01-09 00:55:34.730067+03
113	113#2af0dafd-e441-ea1b-483a-ed077f55cc2c	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	142	2016-01-09 01:16:43.448419+03	\N	2af0dafd-e441-ea1b-483a-ed077f55cc2c	2016-01-09 01:16:43.450245+03
114	114#8e691d77-858a-2de6-793a-411329cd9963	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	143	2016-01-09 01:29:03.410791+03	\N	8e691d77-858a-2de6-793a-411329cd9963	2016-01-09 01:29:03.411131+03
115	115#9467e5ee-7ee5-e70f-1976-a3a14b31d233	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	144	2016-01-09 01:29:15.806359+03	\N	9467e5ee-7ee5-e70f-1976-a3a14b31d233	2016-01-09 01:29:15.80661+03
116	116#38e7414f-ec5f-a201-168f-7ac561d36036	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	145	2016-01-09 01:32:54.508011+03	\N	38e7414f-ec5f-a201-168f-7ac561d36036	2016-01-09 01:32:54.50835+03
117	117#c26e0c0c-2022-fb86-8c2d-06693182c650	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	146	2016-01-09 01:34:34.129369+03	\N	c26e0c0c-2022-fb86-8c2d-06693182c650	2016-01-09 01:34:34.12962+03
118	118#9f29bd5d-0451-92ad-465c-f61f5ff8d60b	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	147	2016-01-09 01:35:36.458133+03	\N	9f29bd5d-0451-92ad-465c-f61f5ff8d60b	2016-01-09 01:35:36.458422+03
119	119#2c496ac2-5dcb-328f-c039-eab47ed50f79	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	148	2016-01-09 01:45:41.034459+03	\N	2c496ac2-5dcb-328f-c039-eab47ed50f79	2016-01-09 01:45:41.036909+03
120	120#e25edb80-97dc-8af7-c276-7365831a3a15	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	149	2016-01-09 01:45:52.234485+03	\N	e25edb80-97dc-8af7-c276-7365831a3a15	2016-01-09 01:45:52.23493+03
121	121#6d7b83fb-d9e5-63c7-bd9e-bb112832efe7	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	150	2016-01-09 01:51:33.608134+03	\N	6d7b83fb-d9e5-63c7-bd9e-bb112832efe7	2016-01-09 01:51:33.608486+03
122	122#14c00e50-58a7-f6b6-5b95-b1203b8fae6d	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	151	2016-01-09 01:52:46.799275+03	\N	14c00e50-58a7-f6b6-5b95-b1203b8fae6d	2016-01-09 01:52:46.799538+03
123	123#9f695e90-9961-61ad-dab2-a4466db15940	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	155	2016-01-09 20:57:56.650502+03	\N	9f695e90-9961-61ad-dab2-a4466db15940	2016-01-09 20:57:56.653027+03
124	124#8aa0a06a-9e9b-424b-9957-2e45df87f392	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	156	2016-01-09 22:05:49.750204+03	\N	8aa0a06a-9e9b-424b-9957-2e45df87f392	2016-01-09 22:05:49.75208+03
125	125#9a4f7abc-2c71-7b7d-9198-a454a80f7df4	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	157	2016-01-09 22:10:23.17104+03	\N	9a4f7abc-2c71-7b7d-9198-a454a80f7df4	2016-01-09 22:10:23.173067+03
126	126#e8630caf-e714-eb2b-9c34-f14994a7ffaa	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	158	2016-01-09 22:12:12.226035+03	\N	e8630caf-e714-eb2b-9c34-f14994a7ffaa	2016-01-09 22:12:12.22786+03
127	127#1cf50438-4588-45f8-3f45-231485415efc	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	159	2016-01-09 22:20:30.912302+03	\N	1cf50438-4588-45f8-3f45-231485415efc	2016-01-09 22:20:30.91468+03
128	128#ae358825-83b3-bb71-8f6f-cb24a62d0878	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	160	2016-01-09 22:20:31.02479+03	\N	ae358825-83b3-bb71-8f6f-cb24a62d0878	2016-01-09 22:20:31.025054+03
129	129#278497a1-8127-93c0-6862-dee2fe04c903	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	161	2016-01-09 22:20:31.076026+03	\N	278497a1-8127-93c0-6862-dee2fe04c903	2016-01-09 22:20:31.076306+03
130	130#8a7289a6-cad5-ae79-1153-8d65422b9918	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	162	2016-01-09 22:25:15.00859+03	\N	8a7289a6-cad5-ae79-1153-8d65422b9918	2016-01-09 22:25:15.010336+03
131	131#0444d0c9-dbb1-8430-fb22-a197040b7137	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	163	2016-01-09 22:25:15.11393+03	\N	0444d0c9-dbb1-8430-fb22-a197040b7137	2016-01-09 22:25:15.114186+03
132	132#427acde3-7306-926b-5889-3ceafcaf7b14	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	164	2016-01-09 22:25:15.164586+03	\N	427acde3-7306-926b-5889-3ceafcaf7b14	2016-01-09 22:25:15.164842+03
133	133#7271476d-d416-c15d-00b9-c236aba1a8d1	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	165	2016-01-09 22:33:01.319191+03	\N	7271476d-d416-c15d-00b9-c236aba1a8d1	2016-01-09 22:33:01.321155+03
134	134#597562df-3f9e-b0ca-228d-c321e8bbf9e1	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	166	2016-01-09 22:33:01.409283+03	\N	597562df-3f9e-b0ca-228d-c321e8bbf9e1	2016-01-09 22:33:01.409538+03
135	135#1b0cfa55-337d-1aa0-6c51-3eaddeb120d3	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	\N	167	2016-01-09 22:33:01.469152+03	\N	1b0cfa55-337d-1aa0-6c51-3eaddeb120d3	2016-01-09 22:33:01.469409+03
137	137#4f2baaa5-ffa1-049d-f740-98decbdae84f	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	169	2016-01-09 23:29:03.424256+03	2016-01-09 23:29:03.551041+03	4f2baaa5-ffa1-049d-f740-98decbdae84f	2016-01-09 23:29:03.551041+03
136	136#74e5a8a3-91cb-1ded-08dd-5fa75a01c5a4	\N	1	168	2016-01-09 23:29:03.381336+03	2016-01-09 23:29:03.55794+03	74e5a8a3-91cb-1ded-08dd-5fa75a01c5a4	2016-01-09 23:29:03.55794+03
139	139#1b27fb3c-2ab3-7b3f-b854-cda90a6bba53	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	171	2016-01-09 23:38:12.955286+03	2016-01-09 23:38:13.011094+03	1b27fb3c-2ab3-7b3f-b854-cda90a6bba53	2016-01-09 23:38:13.011094+03
138	138#06758c01-0d9f-0335-7fad-0b6f095ed62c	\N	1	170	2016-01-09 23:38:12.938618+03	2016-01-09 23:38:13.014671+03	06758c01-0d9f-0335-7fad-0b6f095ed62c	2016-01-09 23:38:13.014671+03
141	141#0ad4a78d-456b-3c6b-a6c0-c80da63b8f12	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	173	2016-01-09 23:40:26.634162+03	2016-01-09 23:40:26.688194+03	0ad4a78d-456b-3c6b-a6c0-c80da63b8f12	2016-01-09 23:40:26.688194+03
140	140#7a35ddee-6a6b-789b-3ef6-59855c084466	\N	1	172	2016-01-09 23:40:26.620172+03	2016-01-09 23:40:26.690403+03	7a35ddee-6a6b-789b-3ef6-59855c084466	2016-01-09 23:40:26.690403+03
143	143#c59ec12b-66c5-58c7-5ec9-f087e58fda7d	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	1	175	2016-01-09 23:45:09.203799+03	2016-01-09 23:45:09.261665+03	c59ec12b-66c5-58c7-5ec9-f087e58fda7d	2016-01-09 23:45:09.261665+03
142	142#e3854bb8-6787-57a3-0e74-34575ff9c6ca	\N	1	174	2016-01-09 23:45:09.187727+03	2016-01-09 23:45:09.264133+03	e3854bb8-6787-57a3-0e74-34575ff9c6ca	2016-01-09 23:45:09.264133+03
144	144#e5054dc9-97a8-893f-59b8-0423a9d3d525	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	176	2016-01-10 00:57:24.282888+03	\N	e5054dc9-97a8-893f-59b8-0423a9d3d525	2016-01-10 00:57:24.285575+03
145	145#4fd98f50-417e-8dd6-7c08-281afc690d2c	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	177	2016-01-10 00:57:24.40739+03	\N	4fd98f50-417e-8dd6-7c08-281afc690d2c	2016-01-10 00:57:24.407797+03
146	146#f8ba9888-4feb-d924-da74-1bf27b06f209	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	178	2016-01-10 00:57:24.460666+03	\N	f8ba9888-4feb-d924-da74-1bf27b06f209	2016-01-10 00:57:24.461045+03
147	147#f39fe393-4f57-c784-f532-800e41e49c95	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	179	2016-01-10 02:39:50.930098+03	\N	f39fe393-4f57-c784-f532-800e41e49c95	2016-01-10 02:39:50.932464+03
148	148#53ee20c2-196d-dde5-c3b4-f8aa75d24511	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	181	2016-01-10 02:40:54.517627+03	\N	53ee20c2-196d-dde5-c3b4-f8aa75d24511	2016-01-10 02:40:54.518024+03
149	149#b286c9e1-6d6b-c823-7a7a-6099dc82768e	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	182	2016-01-10 02:46:34.099967+03	\N	b286c9e1-6d6b-c823-7a7a-6099dc82768e	2016-01-10 02:46:34.103057+03
150	150#01636c88-a5c1-488d-8417-a4d0750c70c5	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	1	183	2016-01-10 02:46:51.267352+03	\N	01636c88-a5c1-488d-8417-a4d0750c70c5	2016-01-10 02:46:51.267674+03
\.


--
-- Data for Name: sec_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_user (id, person_id, name, time_zone) FROM stdin;
1	1	root	\N
25	24	test-001	\N
28	27	user01	\N
\.


--
-- Data for Name: sec_user_authcred; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_user_authcred (user_id, auth_path_id, credential, valid_from, valid_till, credential_hash) FROM stdin;
1	1	$2a$06$G1H4HN1PEDgNPyBtwGiTDesLv7jQxw06RPTJj4KSRdnLk7E3rDmiu	1900-01-01 00:00:00+02:30:17	2999-12-31 00:00:00+03	\N
28	1	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	2016-01-09 00:55:34.738635+03	2016-02-09 00:55:34.738637+03	b4ed7f379028178b96f966a95dcaab20b6b1005e57235fbe9a5b2b354af3c29e3c7c543608ef06d35cf37bfd440a82731d07536cd38bd7183beeb73c8630dd3d
25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-09 00:00:00+03	infinity	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088
\.


--
-- Data for Name: sec_user_authcred_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sec_user_authcred_log (log_id, user_id, auth_path_id, credential, valid_from, valid_till, credential_hash, when_logged) FROM stdin;
38	28	1	$2a$06$BiNlWj/pnc3lpP.Ukz157utjx945pULBZpaycUF.UUnyZi1mKMQOO	2016-01-09 00:55:34.738635+03	2016-02-09 00:55:34.738637+03	b4ed7f379028178b96f966a95dcaab20b6b1005e57235fbe9a5b2b354af3c29e3c7c543608ef06d35cf37bfd440a82731d07536cd38bd7183beeb73c8630dd3d	2016-01-09 00:55:34.877367+03
39	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-07 00:00:00+03	infinity	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:29:03.505173+03
40	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-08 00:00:00+03	2016-01-09 00:00:00+03	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:29:03.532551+03
41	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-09 00:00:00+03	infinity	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:38:12.994246+03
42	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-08 00:00:00+03	2016-01-09 00:00:00+03	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:38:12.997463+03
43	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-09 00:00:00+03	infinity	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:40:26.672406+03
44	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-08 00:00:00+03	2016-01-09 00:00:00+03	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:40:26.675504+03
45	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-09 00:00:00+03	infinity	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:45:09.244499+03
46	25	1	$2a$06$lxfinbkwy2l54QSoQzkS9uF2uh4BPQtnWpycuuO147egN1RFIAEE6	2016-01-08 00:00:00+03	2016-01-09 00:00:00+03	f46774d8efffa3d8ad5e1d32a5d2607d768436b7c7f7b6e3b2771fda43303911789731c1d73155a166b99caab11c311403a6046c3b338ab9fa2ee5c1a73d8088	2016-01-09 23:45:09.248302+03
\.


--
-- Name: sec_user_authcred_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sec_user_authcred_log_log_id_seq', 46, true);


--
-- Name: sec_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sec_user_id_seq', 28, true);


--
-- Name: mdd_class_extention_pk1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mdd_class_extention
    ADD CONSTRAINT mdd_class_extention_pk1 PRIMARY KEY (class_id, base_class_id);


--
-- Name: mdd_class_pk1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mdd_class
    ADD CONSTRAINT mdd_class_pk1 PRIMARY KEY (id);


--
-- Name: mdd_datatype_pk1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mdd_datatype
    ADD CONSTRAINT mdd_datatype_pk1 PRIMARY KEY (id);


--
-- Name: mdd_datatype_sized_pk1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mdd_datatype_sized
    ADD CONSTRAINT mdd_datatype_sized_pk1 PRIMARY KEY (id);


--
-- Name: pk_country01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_country
    ADD CONSTRAINT pk_country01 PRIMARY KEY (id);


--
-- Name: pk_env_application01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_application
    ADD CONSTRAINT pk_env_application01 PRIMARY KEY (id);


--
-- Name: pk_env_application_relation01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_application_relation
    ADD CONSTRAINT pk_env_application_relation01 PRIMARY KEY (id, related_to_id);


--
-- Name: pk_env_event; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY lml_event
    ADD CONSTRAINT pk_env_event PRIMARY KEY (id);


--
-- Name: pk_env_resource; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_resource
    ADD CONSTRAINT pk_env_resource PRIMARY KEY (id);


--
-- Name: pk_env_resource_kind; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_resource_kind
    ADD CONSTRAINT pk_env_resource_kind PRIMARY KEY (id);


--
-- Name: pk_env_resource_text; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_resource_text
    ADD CONSTRAINT pk_env_resource_text PRIMARY KEY (id, language_id);


--
-- Name: pk_env_severity_level; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_severity_level
    ADD CONSTRAINT pk_env_severity_level PRIMARY KEY (id);


--
-- Name: pk_i18_country_depend01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_country_depend
    ADD CONSTRAINT pk_i18_country_depend01 PRIMARY KEY (number3code);


--
-- Name: pk_i18_country_phoneprefix01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_country_phoneprefix
    ADD CONSTRAINT pk_i18_country_phoneprefix01 PRIMARY KEY (number3code, prefix);


--
-- Name: pk_i18_currency; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_currency
    ADD CONSTRAINT pk_i18_currency PRIMARY KEY (id);


--
-- Name: pk_i18_currency_country; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_currency_country
    ADD CONSTRAINT pk_i18_currency_country PRIMARY KEY (alpha3code, entity);


--
-- Name: pk_i18_language01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_language
    ADD CONSTRAINT pk_i18_language01 PRIMARY KEY (id);


--
-- Name: pk_lml_class; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY lml_class
    ADD CONSTRAINT pk_lml_class PRIMARY KEY (id);


--
-- Name: pk_lml_event_status; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY lml_event_status
    ADD CONSTRAINT pk_lml_event_status PRIMARY KEY (id);


--
-- Name: pk_opn_operation; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY opn_operation
    ADD CONSTRAINT pk_opn_operation PRIMARY KEY (id);


--
-- Name: pk_opn_operation_kind; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY opn_operation_kind
    ADD CONSTRAINT pk_opn_operation_kind PRIMARY KEY (id);


--
-- Name: pk_opn_person01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY opn_person
    ADD CONSTRAINT pk_opn_person01 PRIMARY KEY (operation_id);


--
-- Name: pk_opn_person_individual; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY opn_person_individual
    ADD CONSTRAINT pk_opn_person_individual PRIMARY KEY (operation_id);


--
-- Name: pk_opn_person_legal; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY opn_person_legal
    ADD CONSTRAINT pk_opn_person_legal PRIMARY KEY (operation_id);


--
-- Name: pk_prs_person01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY prs_person
    ADD CONSTRAINT pk_prs_person01 PRIMARY KEY (id);


--
-- Name: pk_prs_person_individual; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY prs_person_individual
    ADD CONSTRAINT pk_prs_person_individual PRIMARY KEY (person_id);


--
-- Name: pk_prs_person_kind; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY prs_person_kind
    ADD CONSTRAINT pk_prs_person_kind PRIMARY KEY (id);


--
-- Name: pk_prs_person_legal; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY prs_person_legal
    ADD CONSTRAINT pk_prs_person_legal PRIMARY KEY (person_id);


--
-- Name: pk_sec_authentication_kind; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_authentication_kind
    ADD CONSTRAINT pk_sec_authentication_kind PRIMARY KEY (id);


--
-- Name: pk_sec_authentication_path; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_authentication_path
    ADD CONSTRAINT pk_sec_authentication_path PRIMARY KEY (id);


--
-- Name: pk_sec_event_logs; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_event_log
    ADD CONSTRAINT pk_sec_event_logs PRIMARY KEY (session_id, whenfired, event_kind, event_status);


--
-- Name: pk_sec_session; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_session
    ADD CONSTRAINT pk_sec_session PRIMARY KEY (id);


--
-- Name: pk_sec_session_log; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_session_log
    ADD CONSTRAINT pk_sec_session_log PRIMARY KEY (id);


--
-- Name: pk_sec_token; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_token
    ADD CONSTRAINT pk_sec_token PRIMARY KEY (id);


--
-- Name: pk_sec_token_log; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_token_log
    ADD CONSTRAINT pk_sec_token_log PRIMARY KEY (id);


--
-- Name: pk_sec_user; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_user
    ADD CONSTRAINT pk_sec_user PRIMARY KEY (id);


--
-- Name: pk_sec_user_authcred; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_user_authcred
    ADD CONSTRAINT pk_sec_user_authcred PRIMARY KEY (user_id, auth_path_id);


--
-- Name: pk_sec_user_authcred_log; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_user_authcred_log
    ADD CONSTRAINT pk_sec_user_authcred_log PRIMARY KEY (log_id);


--
-- Name: uk_env_application01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_application
    ADD CONSTRAINT uk_env_application01 UNIQUE (code);


--
-- Name: uk_env_resource_text01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_resource_text
    ADD CONSTRAINT uk_env_resource_text01 UNIQUE (code, language_id);


--
-- Name: uk_i18_country01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_country
    ADD CONSTRAINT uk_i18_country01 UNIQUE (number3code);


--
-- Name: uk_i18_country02; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_country
    ADD CONSTRAINT uk_i18_country02 UNIQUE (alpha2code);


--
-- Name: uk_i18_country03; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_country
    ADD CONSTRAINT uk_i18_country03 UNIQUE (alpha3code);


--
-- Name: uk_i18_currency01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_currency
    ADD CONSTRAINT uk_i18_currency01 UNIQUE (alpha3code);


--
-- Name: uk_i18_currency02; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_currency
    ADD CONSTRAINT uk_i18_currency02 UNIQUE (numeric3code);


--
-- Name: uk_i18_language01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_language
    ADD CONSTRAINT uk_i18_language01 UNIQUE (alpha2code);


--
-- Name: uk_i18_language02; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY i18_language
    ADD CONSTRAINT uk_i18_language02 UNIQUE (alpha3code);


--
-- Name: uk_sec_token01; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sec_token
    ADD CONSTRAINT uk_sec_token01 UNIQUE (localvalue);


--
-- Name: fk_env_application_relation01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_application_relation
    ADD CONSTRAINT fk_env_application_relation01 FOREIGN KEY (id) REFERENCES env_application(id);


--
-- Name: fk_env_application_relation02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_application_relation
    ADD CONSTRAINT fk_env_application_relation02 FOREIGN KEY (related_to_id) REFERENCES env_application(id);


--
-- Name: fk_env_resource01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_resource
    ADD CONSTRAINT fk_env_resource01 FOREIGN KEY (resource_kind_id) REFERENCES env_resource_kind(id);


--
-- Name: fk_env_resource_text01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_resource_text
    ADD CONSTRAINT fk_env_resource_text01 FOREIGN KEY (id) REFERENCES env_resource(id);


--
-- Name: fk_env_resource_text02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY env_resource_text
    ADD CONSTRAINT fk_env_resource_text02 FOREIGN KEY (language_id) REFERENCES i18_language(id);


--
-- Name: fk_i18_country_depend01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY i18_country_depend
    ADD CONSTRAINT fk_i18_country_depend01 FOREIGN KEY (number3code) REFERENCES i18_country(number3code);


--
-- Name: fk_i18_country_phoneprefix01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY i18_country_phoneprefix
    ADD CONSTRAINT fk_i18_country_phoneprefix01 FOREIGN KEY (number3code) REFERENCES i18_country(number3code);


--
-- Name: fk_i18_currency_country01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY i18_currency_country
    ADD CONSTRAINT fk_i18_currency_country01 FOREIGN KEY (alpha3code) REFERENCES i18_currency(alpha3code);


--
-- Name: fk_lml_event01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lml_event
    ADD CONSTRAINT fk_lml_event01 FOREIGN KEY (class_id) REFERENCES lml_class(id);


--
-- Name: fk_opn_operation01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_operation
    ADD CONSTRAINT fk_opn_operation01 FOREIGN KEY (operation_kind_id) REFERENCES opn_operation_kind(id);


--
-- Name: fk_opn_operation02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_operation
    ADD CONSTRAINT fk_opn_operation02 FOREIGN KEY (modified_by) REFERENCES sec_user(id);


--
-- Name: fk_opn_operation03; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_operation
    ADD CONSTRAINT fk_opn_operation03 FOREIGN KEY (applied_by) REFERENCES sec_user(id);


--
-- Name: fk_opn_operation_kind01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_operation_kind
    ADD CONSTRAINT fk_opn_operation_kind01 FOREIGN KEY (class_id) REFERENCES lml_class(id);


--
-- Name: fk_opn_person01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person
    ADD CONSTRAINT fk_opn_person01 FOREIGN KEY (operation_id) REFERENCES opn_operation(id);


--
-- Name: fk_opn_person02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person
    ADD CONSTRAINT fk_opn_person02 FOREIGN KEY (person_id) REFERENCES prs_person(id);


--
-- Name: fk_opn_person03; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person
    ADD CONSTRAINT fk_opn_person03 FOREIGN KEY (citizenship_country_id) REFERENCES i18_country(id);


--
-- Name: fk_opn_person04; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person
    ADD CONSTRAINT fk_opn_person04 FOREIGN KEY (language_id) REFERENCES i18_language(id);


--
-- Name: fk_opn_person05; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person
    ADD CONSTRAINT fk_opn_person05 FOREIGN KEY (person_kind_id) REFERENCES prs_person_kind(id);


--
-- Name: fk_opn_person_individual01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person_individual
    ADD CONSTRAINT fk_opn_person_individual01 FOREIGN KEY (operation_id) REFERENCES opn_operation(id);


--
-- Name: fk_opn_person_individual02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person_individual
    ADD CONSTRAINT fk_opn_person_individual02 FOREIGN KEY (person_id) REFERENCES prs_person(id);


--
-- Name: fk_opn_person_legal01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person_legal
    ADD CONSTRAINT fk_opn_person_legal01 FOREIGN KEY (operation_id) REFERENCES opn_operation(id);


--
-- Name: fk_opn_person_legal02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY opn_person_legal
    ADD CONSTRAINT fk_opn_person_legal02 FOREIGN KEY (person_id) REFERENCES prs_person(id);


--
-- Name: fk_prs_person01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY prs_person
    ADD CONSTRAINT fk_prs_person01 FOREIGN KEY (citizenship_country_id) REFERENCES i18_country(id);


--
-- Name: fk_prs_person02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY prs_person
    ADD CONSTRAINT fk_prs_person02 FOREIGN KEY (language_id) REFERENCES i18_language(id);


--
-- Name: fk_prs_person03; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY prs_person
    ADD CONSTRAINT fk_prs_person03 FOREIGN KEY (person_kind_id) REFERENCES prs_person_kind(id);


--
-- Name: fk_prs_person_individual01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY prs_person_individual
    ADD CONSTRAINT fk_prs_person_individual01 FOREIGN KEY (person_id) REFERENCES prs_person(id);


--
-- Name: fk_prs_person_legal01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY prs_person_legal
    ADD CONSTRAINT fk_prs_person_legal01 FOREIGN KEY (person_id) REFERENCES prs_person(id);


--
-- Name: fk_sec_authentication_path01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_authentication_path
    ADD CONSTRAINT fk_sec_authentication_path01 FOREIGN KEY (authentication_kind_id) REFERENCES sec_authentication_kind(id);


--
-- Name: fk_sec_authentication_path02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_authentication_path
    ADD CONSTRAINT fk_sec_authentication_path02 FOREIGN KEY (application_id) REFERENCES env_application(id);


--
-- Name: fk_sec_event_log01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_event_log
    ADD CONSTRAINT fk_sec_event_log01 FOREIGN KEY (event_kind) REFERENCES lml_event(id);


--
-- Name: fk_sec_event_log02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_event_log
    ADD CONSTRAINT fk_sec_event_log02 FOREIGN KEY (event_status) REFERENCES lml_event_status(id);


--
-- Name: fk_sec_session01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_session
    ADD CONSTRAINT fk_sec_session01 FOREIGN KEY (user_id) REFERENCES sec_user(id);


--
-- Name: fk_sec_token01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_token
    ADD CONSTRAINT fk_sec_token01 FOREIGN KEY (auth_path_id) REFERENCES sec_authentication_path(id);


--
-- Name: fk_sec_token02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_token
    ADD CONSTRAINT fk_sec_token02 FOREIGN KEY (session_id) REFERENCES sec_session(id);


--
-- Name: fk_sec_user01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_user
    ADD CONSTRAINT fk_sec_user01 FOREIGN KEY (person_id) REFERENCES prs_person(id);


--
-- Name: fk_sec_user_authcred01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_user_authcred
    ADD CONSTRAINT fk_sec_user_authcred01 FOREIGN KEY (user_id) REFERENCES sec_user(id);


--
-- Name: fk_sec_user_authcred02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_user_authcred
    ADD CONSTRAINT fk_sec_user_authcred02 FOREIGN KEY (auth_path_id) REFERENCES sec_authentication_path(id);


--
-- Name: fk_sec_user_authcred_log01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_user_authcred_log
    ADD CONSTRAINT fk_sec_user_authcred_log01 FOREIGN KEY (user_id) REFERENCES sec_user(id);


--
-- Name: fk_sec_user_authcred_log02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sec_user_authcred_log
    ADD CONSTRAINT fk_sec_user_authcred_log02 FOREIGN KEY (auth_path_id) REFERENCES sec_authentication_path(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

