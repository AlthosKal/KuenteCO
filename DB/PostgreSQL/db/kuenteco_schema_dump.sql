--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

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
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: http; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA public;


--
-- Name: EXTENSION http; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION http IS 'HTTP client for PostgreSQL, allows web page retrieval inside the database.';


--
-- Name: check_budget_limit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_budget_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
v_category_budget NUMERIC;    -- Presupuesto asignado a la categoría
    v_total_spent NUMERIC;        -- Total gastado en la categoría
    v_category_name TEXT;         -- Nombre de la categoría
    v_owner_user_id TEXT;         -- ID del propietario usuario (UUID)
    v_budget_id INTEGER;          -- ID del presupuesto
BEGIN
    -- Solo procesar gastos
    IF (NEW.description->>'type')::text != 'EXPENSE' THEN
        RETURN NEW;
END IF;

    -- Verificar que existe una categoría
    IF NEW.id_category IS NULL THEN
        RETURN NEW;
END IF;

    -- Obtener información de la categoría y su presupuesto asociado
SELECT c.description->>'name',
    c.id_user,
    c.id_budget,
    b.total_budget
INTO v_category_name,
    v_owner_user_id,
    v_budget_id,
    v_category_budget
FROM category c
    LEFT JOIN budget b ON c.id_budget = b.id
WHERE c.id = NEW.id_category;

-- Si no hay presupuesto asignado o asociado, no hacer nada
IF v_category_budget IS NULL OR v_category_budget = 0 OR v_budget_id IS NULL THEN
        RETURN NEW;
END IF;

    -- Calcular el total gastado en la categoría (solo gastos)
SELECT COALESCE(SUM(t.amount), 0) INTO v_total_spent
FROM transaction t
WHERE t.id_category = NEW.id_category
  AND (t.description->>'type')::text = 'EXPENSE';

-- Verificar si se ha excedido el presupuesto
IF v_total_spent > v_category_budget THEN
        -- Insertar una notificación
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
            INSERT INTO notification (id_user, id_profile, date_send, content)
            VALUES (
                v_owner_user_id,
                NULL,
                NOW(),
                jsonb_build_object(
                    'title', 'Presupuesto Excedido',
                    'body', 'Has excedido el presupuesto asignado para la categoría ' ||
                           COALESCE(v_category_name, 'Sin nombre') ||
                           '. Gastado: $' || v_total_spent ||
                           ', Presupuesto: $' || v_category_budget,
                    'date', NOW()::text
                )
            );
END IF;
    -- Verificar si está cerca del límite (90%)
    ELSIF v_total_spent > (v_category_budget * 0.9) THEN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
            INSERT INTO notification (id_user, id_profile, date_send, content)
            VALUES (
                v_owner_user_id,
                NULL,
                NOW(),
                jsonb_build_object(
                    'title', 'Presupuesto Casi Agotado',
                    'body', 'Has usado el 90% del presupuesto para la categoría ' ||
                           COALESCE(v_category_name, 'Sin nombre') ||
                           '. Gastado: $' || v_total_spent ||
                           ', Presupuesto: $' || v_category_budget,
                    'date', NOW()::text
                )
            );
END IF;
END IF;

RETURN NEW;
END;
$_$;


--
-- Name: convert_currency(numeric, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.convert_currency(p_amount numeric, p_base_currency character varying, p_target_currency character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_rate NUMERIC;
BEGIN
    -- Obtener la tasa de cambio más reciente
    SELECT rate INTO v_rate
    FROM exchange_rate
    WHERE base_currency = p_base_currency
      AND target_currency = p_target_currency
      AND last_updated = (SELECT MAX(last_updated) FROM exchange_rate);

    -- Si no se encuentra la tasa de cambio, lanzar un error
    IF v_rate IS NULL THEN
        RAISE EXCEPTION 'Tasa de cambio no encontrada para % a %', p_base_currency, p_target_currency;
    END IF;

    -- Retornar la cantidad convertida
    RETURN p_amount * v_rate;
END;
$$;


--
-- Name: log_audit_user_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_audit_user_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
v_log_message TEXT;
    v_user_id TEXT; -- UUID como TEXT
    v_record_id INTEGER;
BEGIN
    -- Determinar el ID del usuario y construir mensaje
    IF TG_OP = 'DELETE' THEN
        v_user_id := OLD.id;
        v_log_message := 'DELETE on kuentecouser: ID=' || OLD.id ||
                         ', Email=' || COALESCE(OLD.email, 'NULL') ||
                         ', Username=' || COALESCE(OLD.username, 'NULL') ||
                         ', Action by: SYSTEM';
ELSE
        v_user_id := NEW.id;
        IF TG_OP = 'UPDATE' THEN
            v_log_message := 'UPDATE on kuentecouser: ID=' || NEW.id ||
                           ', Email=' || COALESCE(NEW.email, 'NULL') ||
                           ', Username=' || COALESCE(NEW.username, 'NULL') ||
                           ', State=' || COALESCE(NEW.account_state::text, 'NULL') ||
                           ', Type=' || COALESCE(NEW.type::text, 'NULL');

            -- Agregar información de cambios específicos
            IF OLD.email != NEW.email THEN
                v_log_message := v_log_message || ', Email changed from ' ||
                               COALESCE(OLD.email, 'NULL') || ' to ' || COALESCE(NEW.email, 'NULL');
END IF;

            IF OLD.account_state != NEW.account_state THEN
                v_log_message := v_log_message || ', State changed from ' ||
                               COALESCE(OLD.account_state::text, 'NULL') || ' to ' ||
                               COALESCE(NEW.account_state::text, 'NULL');
END IF;
ELSE
            v_log_message := 'INSERT on kuentecouser: ID=' || NEW.id ||
                           ', Email=' || COALESCE(NEW.email, 'NULL') ||
                           ', Username=' || COALESCE(NEW.username, 'NULL') ||
                           ', State=' || COALESCE(NEW.account_state::text, 'NULL') ||
                           ', Type=' || COALESCE(NEW.type::text, 'NULL');
END IF;
END IF;

    -- Generar un ID entero basado en el hash del UUID
    v_record_id := abs(hashtext(v_user_id));

    -- Registrar el cambio en la tabla de auditoría
INSERT INTO audit_logs (table_name, operation, record_id, log_message, log_timestamp)
VALUES (
           'kuentecouser',
           TG_OP,
           v_record_id,
           v_log_message,
           NOW()
       );

IF TG_OP = 'DELETE' THEN
        RETURN OLD;
END IF;

RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, registrar en logs pero no fallar la transacción principal
        RAISE WARNING 'Error en trigger de auditoría para usuario %: %', v_user_id, SQLERRM;

        -- Intentar registrar el error en los logs
BEGIN
INSERT INTO audit_logs (table_name, operation, record_id, log_message, log_timestamp)
VALUES (
           'kuentecouser',
           'ERROR',
           COALESCE(v_record_id, 0),
           'Error en trigger de auditoría: ' || SQLERRM,
           NOW()
       );
EXCEPTION
            WHEN OTHERS THEN
                -- Si incluso esto falla, solo registrar el warning
                RAISE WARNING 'Error crítico en trigger de auditoría: %', SQLERRM;
END;

        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
END IF;
RETURN NEW;
END;
$$;


--
-- Name: send_debt_reminder(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.send_debt_reminder() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    -- Verificar si la deuda está próxima a vencer (en 3 días) y está activa
    IF NEW.expiration_date <= NOW() + INTERVAL '3 days'
        AND NEW.expiration_date > NOW()
        AND NEW.state = 'ACTIVE' THEN

        -- Insertar notificación solo para usuario (Debt solo tiene id_user)
        IF NEW.id_user IS NOT NULL THEN
            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
                INSERT INTO notification (id_user, id_profile, date_send, content)
                VALUES (
                    NEW.id_user,
                    NULL,
                    NOW(),
                    jsonb_build_object(
                        'title', 'Recordatorio de Deuda',
                        'body', 'Tu deuda "' || NEW.name || '" vence el ' ||
                               TO_CHAR(NEW.expiration_date, 'DD/MM/YYYY') ||
                               '. Monto pendiente: $' || NEW.pending_amount ||
                               '. Por favor, realiza el pago.',
                        'date', NOW()::text
                    )
                );
END IF;
END IF;
END IF;

    -- Verificar si la deuda ya venció
    IF NEW.expiration_date < NOW() AND NEW.state = 'ACTIVE' THEN
        -- Actualizar estado a vencida
UPDATE debt SET state = 'DEFEATED' WHERE id = NEW.id;

-- Insertar notificación de deuda vencida
IF NEW.id_user IS NOT NULL THEN
            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
                INSERT INTO notification (id_user, id_profile, date_send, content)
                VALUES (
                    NEW.id_user,
                    NULL,
                    NOW(),
                    jsonb_build_object(
                        'title', 'Deuda Vencida',
                        'body', 'Tu deuda "' || NEW.name || '" ha vencido. ' ||
                               'Monto pendiente: $' || NEW.pending_amount,
                        'date', NOW()::text
                    )
                );
END IF;
END IF;
END IF;

RETURN NEW;
END;
$_$;


--
-- Name: update_exchange_rates(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_exchange_rates() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    api_url TEXT;
    api_key TEXT := '1d3914b3aff44c30b1bb9bf4d8e302f0'; -- Reemplaza con tu API key de Open Exchange Rates
    response RECORD; -- Cambiamos el tipo a RECORD para manejar la respuesta compuesta
    response_body TEXT; -- Almacenará el cuerpo de la respuesta
    response_json JSONB;
    api_base_currency TEXT;
    rates JSONB;
    api_target_currency TEXT;
    rate NUMERIC;
BEGIN
    -- Construir la URL de la API
    api_url := 'https://openexchangerates.org/api/latest.json?app_id=' || api_key;

    -- Hacer la solicitud HTTP a la API
    response := http_get(api_url);

    -- Extraer el cuerpo de la respuesta
    response_body := response.content;

    -- Verificar si la respuesta es nula o está vacía
    IF response_body IS NULL OR response_body = '' THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: La respuesta de la API está vacía o es nula.');
        RAISE EXCEPTION 'Error: La respuesta de la API está vacía o es nula.';
    END IF;

    -- Intentar convertir el cuerpo de la respuesta a JSON
    BEGIN
        response_json := response_body::JSONB;
    EXCEPTION WHEN others THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: La respuesta de la API no es un JSON válido: ' || response_body);
        RAISE EXCEPTION 'Error: La respuesta de la API no es un JSON válido: %', response_body;
    END;

    -- Verificar si la respuesta contiene un error
    IF response_json->>'error' IS NOT NULL THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error en la API: ' || response_json->>'error');
        RAISE EXCEPTION 'Error en la API: %', response_json->>'error';
    END IF;

    -- Extraer la moneda base y las tasas de cambio
    api_base_currency := response_json->>'base';
    rates := response_json->'rates';

    -- Verificar si las tasas de cambio están presentes
    IF rates IS NULL THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: No se encontraron tasas de cambio en la respuesta de la API.');
        RAISE EXCEPTION 'Error: No se encontraron tasas de cambio en la respuesta de la API.';
    END IF;

    -- Recorrer las tasas de cambio y actualizar la tabla
    FOR api_target_currency, rate IN SELECT * FROM jsonb_each(rates) LOOP
            -- Insertar o actualizar la tasa de cambio en la tabla
            INSERT INTO exchange_rate (base_currency, target_currency, rate, last_updated)
            VALUES (api_base_currency, api_target_currency, rate, now())
            ON CONFLICT (base_currency, target_currency)
                DO UPDATE SET rate = EXCLUDED.rate, last_updated = EXCLUDED.last_updated;
        END LOOP;

    -- Registrar éxito en la tabla de logs
    INSERT INTO exchange_rate_logs (log_message)
    VALUES ('Tasas de cambio actualizadas correctamente.');
END;
$$;


--
-- Name: update_remaining_budget_on_transaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_remaining_budget_on_transaction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
v_budget_id INTEGER;
    v_amount NUMERIC := 0;
    v_transaction_type TEXT;
BEGIN
    -- Obtener información de la transacción
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        v_budget_id := NEW.id_budget;
        v_amount := NEW.amount;
        v_transaction_type := NEW.description->>'type';
END IF;

    IF TG_OP = 'DELETE' THEN
        v_budget_id := OLD.id_budget;
        v_amount := OLD.amount;
        v_transaction_type := OLD.description->>'type';
END IF;

    -- Solo procesar si hay un presupuesto asociado
    IF v_budget_id IS NOT NULL THEN
        -- Para INSERT/UPDATE: aplicar la transacción
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
            IF v_transaction_type = 'EXPENSE' THEN
                -- Restar del presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget - v_amount
WHERE id = v_budget_id;
ELSIF v_transaction_type = 'INCOME' THEN
                -- Sumar al presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget + v_amount
WHERE id = v_budget_id;
END IF;
END IF;

        -- Para DELETE: revertir la operación
        IF TG_OP = 'DELETE' THEN
            IF v_transaction_type = 'EXPENSE' THEN
                -- Devolver al presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget + v_amount
WHERE id = v_budget_id;
ELSIF v_transaction_type = 'INCOME' THEN
                -- Quitar del presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget - v_amount
WHERE id = v_budget_id;
END IF;
END IF;

        -- Para UPDATE: si cambió el presupuesto, revertir en el anterior
        IF TG_OP = 'UPDATE' AND OLD.id_budget IS NOT NULL AND OLD.id_budget != NEW.id_budget THEN
            v_transaction_type := OLD.description->>'type';
            IF v_transaction_type = 'EXPENSE' THEN
UPDATE budget
SET remaining_budget = remaining_budget + OLD.amount
WHERE id = OLD.id_budget;
ELSIF v_transaction_type = 'INCOME' THEN
UPDATE budget
SET remaining_budget = remaining_budget - OLD.amount
WHERE id = OLD.id_budget;
END IF;
END IF;
END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
END IF;

RETURN NEW;
END;
$$;


--
-- Name: verify_budget_integrity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verify_budget_integrity() RETURNS TABLE(budget_id integer, calculated_remaining numeric, stored_remaining numeric, difference numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT
    b.id as budget_id,
    (b.total_budget - COALESCE(expense_sum.total_expenses, 0) + COALESCE(income_sum.total_income, 0)) as calculated_remaining,
    b.remaining_budget as stored_remaining,
    (b.remaining_budget - (b.total_budget - COALESCE(expense_sum.total_expenses, 0) + COALESCE(income_sum.total_income, 0))) as difference
FROM budget b
         LEFT JOIN (
    SELECT
        id_budget,
        SUM(amount) as total_expenses
    FROM transaction
    WHERE description->>'type' = 'EXPENSE'
      AND id_budget IS NOT NULL
    GROUP BY id_budget
) expense_sum ON b.id = expense_sum.id_budget
         LEFT JOIN (
    SELECT
        id_budget,
        SUM(amount) as total_income
    FROM transaction
    WHERE description->>'type' = 'INCOME'
      AND id_budget IS NOT NULL
    GROUP BY id_budget
) income_sum ON b.id = income_sum.id_budget
WHERE ABS(b.remaining_budget - (b.total_budget - COALESCE(expense_sum.total_expenses, 0) + COALESCE(income_sum.total_income, 0))) > 0.01;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    table_name character varying(100) NOT NULL,
    operation character varying(10) NOT NULL,
    record_id integer,
    log_message text,
    log_timestamp timestamp without time zone DEFAULT now()
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: bancolombia_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bancolombia_token (
    id bigint NOT NULL,
    access_token text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    expires_in bigint,
    is_active boolean NOT NULL,
    refresh_token text,
    scope character varying(255),
    token_type character varying(50)
);


--
-- Name: bancolombia_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.bancolombia_token ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.bancolombia_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: budget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget (
    id integer NOT NULL,
    name character varying(255),
    remaining_budget numeric(38,2),
    total_budget numeric(38,2),
    id_user character varying(255)
);


--
-- Name: budget_enrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_enrollment (
    id integer NOT NULL,
    enrollment_date timestamp(6) without time zone,
    id_budget integer,
    id_profile integer,
    id_user character varying(255)
);


--
-- Name: budget_enrollment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.budget_enrollment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.budget_enrollment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: budget_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.budget ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.budget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category (
    id integer NOT NULL,
    description jsonb,
    name character varying(255),
    register_date timestamp(6) without time zone,
    id_budget integer,
    id_user character varying(255) NOT NULL
);


--
-- Name: category_enrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_enrollment (
    id integer NOT NULL,
    enrollment_date timestamp(6) without time zone,
    id_category integer,
    id_profile integer,
    id_user character varying(255)
);


--
-- Name: category_enrollment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.category_enrollment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.category_enrollment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.category ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: debt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debt (
    id integer NOT NULL,
    expiration_date timestamp(6) without time zone,
    name character varying(255),
    pending_amount numeric(38,2),
    start_date timestamp(6) without time zone,
    state character varying(255),
    total_amount numeric(38,2),
    id_user character varying(255),
    CONSTRAINT debt_state_check CHECK (((state)::text = ANY ((ARRAY['ACTIVE'::character varying, 'PAID'::character varying, 'DEFEATED'::character varying, 'REFINANCED'::character varying, 'IN_MORATIUM'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- Name: debt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.debt ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.debt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: exchange_rate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rate (
    id integer NOT NULL,
    base_currency character varying(255),
    last_updated timestamp(6) without time zone,
    rate numeric(38,2),
    target_currency character varying(255)
);


--
-- Name: exchange_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.exchange_rate ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.exchange_rate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: exchange_rate_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rate_logs (
    id integer NOT NULL,
    log_message text,
    log_timestamp timestamp without time zone DEFAULT now()
);


--
-- Name: exchange_rate_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exchange_rate_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exchange_rate_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exchange_rate_logs_id_seq OWNED BY public.exchange_rate_logs.id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


--
-- Name: image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image (
    id integer NOT NULL,
    id_image character varying(255),
    url_image character varying(255),
    name character varying(255)
);


--
-- Name: image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.image ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: kuentecouser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kuentecouser (
    id character varying(255) NOT NULL,
    email character varying(255),
    password character varying(255),
    account_state character varying(255),
    type character varying(255),
    username character varying(255),
    version integer,
    id_image integer,
    id_role integer NOT NULL,
    CONSTRAINT kuentecouser_account_state_check CHECK (((account_state)::text = ANY ((ARRAY['PENDING'::character varying, 'ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT kuentecouser_type_check CHECK (((type)::text = ANY ((ARRAY['PERSONAL'::character varying, 'BUSINESS'::character varying])::text[])))
);


--
-- Name: mercadopago_payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mercadopago_payment (
    id integer NOT NULL,
    authorization_code character varying(255),
    currency_id character varying(255),
    date_approved timestamp(6) without time zone,
    date_created timestamp(6) without time zone,
    date_last_updated timestamp(6) without time zone,
    description character varying(255),
    external_reference character varying(255),
    payment_id character varying(255),
    payment_method_id character varying(255),
    payment_type_id character varying(255),
    status character varying(255),
    status_detail character varying(255),
    transaction_amount numeric(10,2),
    id_preapproval integer NOT NULL,
    CONSTRAINT mercadopago_payment_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'DECLINED'::character varying, 'VOIDED'::character varying, 'ERROR'::character varying])::text[])))
);


--
-- Name: mercadopago_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.mercadopago_payment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.mercadopago_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mercadopago_preapproval; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mercadopago_preapproval (
    id integer NOT NULL,
    auto_recurring_currency_id character varying(255),
    auto_recurring_frequency integer,
    auto_recurring_frequency_type character varying(255),
    auto_recurring_transaction_amount numeric(10,2),
    back_url character varying(255),
    card_brand character varying(255),
    card_last_four_digits character varying(255),
    date_created timestamp(6) without time zone,
    external_reference character varying(255),
    init_point character varying(255),
    last_modified timestamp(6) without time zone,
    next_payment_date timestamp(6) without time zone,
    payer_email character varying(255),
    payment_method_id character varying(255),
    preapproval_id character varying(255),
    reason character varying(255),
    status character varying(255),
    id_user character varying(255) NOT NULL,
    CONSTRAINT mercadopago_preapproval_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'AUTHORIZED'::character varying, 'PAUSED'::character varying, 'CANCELLED'::character varying, 'REJECTED'::character varying, 'FINISHED'::character varying])::text[])))
);


--
-- Name: mercadopago_preapproval_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.mercadopago_preapproval ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.mercadopago_preapproval_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification (
    id integer NOT NULL,
    content jsonb,
    date_send timestamp(6) without time zone,
    title character varying(255),
    id_profile integer,
    id_user character varying(255),
    CONSTRAINT notification_check CHECK ((((id_profile IS NOT NULL) AND (id_user IS NULL)) OR ((id_profile IS NULL) AND (id_user IS NOT NULL))))
);


--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.notification ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile (
    id integer NOT NULL,
    email character varying(255),
    password character varying(255),
    start_date timestamp(6) without time zone,
    username character varying(255),
    id_image integer,
    id_role integer NOT NULL,
    id_user character varying(255) NOT NULL
);


--
-- Name: profile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.profile ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    CONSTRAINT role_name_check CHECK (((name)::text = ANY ((ARRAY['ROLE_USER'::character varying, 'ROLE_PROFILE'::character varying])::text[])))
);


--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.role ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: subscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription (
    id integer NOT NULL,
    created_at timestamp(6) without time zone,
    expiration_date timestamp(6) without time zone,
    is_auto_renewable boolean,
    start_date timestamp(6) without time zone,
    state character varying(255),
    type character varying(255),
    updated_at timestamp(6) without time zone,
    id_mercadopago_preapproval integer,
    id_user character varying(255) NOT NULL,
    CONSTRAINT subscription_state_check CHECK (((state)::text = ANY ((ARRAY['PENDING'::character varying, 'ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT subscription_type_check CHECK (((type)::text = ANY ((ARRAY['BASIC'::character varying, 'STANDARD'::character varying, 'PREMIUM'::character varying])::text[])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.subscription ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction (
    id integer NOT NULL,
    amount numeric(38,2),
    description jsonb,
    name character varying(255),
    transaction_date timestamp(6) without time zone,
    id_budget integer,
    id_category integer,
    id_debt integer,
    id_profile integer,
    id_user character varying(255),
    CONSTRAINT transaction_check CHECK ((((id_profile IS NOT NULL) AND (id_user IS NULL)) OR ((id_profile IS NULL) AND (id_user IS NOT NULL))))
);


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.transaction ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_budget_enrollments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_budget_enrollments AS
 SELECT array_agg(be.id) AS budget_enrollment_ids,
    b.id_user AS owner_user_id,
    b.name AS budget_name,
    p.username AS profile_name,
    count(DISTINCT be.id) AS total_enrollments,
    min(be.enrollment_date) AS first_enrollment_date,
    max(be.enrollment_date) AS last_enrollment_date
   FROM ((public.budget b
     JOIN public.budget_enrollment be ON ((b.id = be.id_budget)))
     LEFT JOIN public.profile p ON ((be.id_profile = p.id)))
  WHERE (be.id IS NOT NULL)
  GROUP BY b.id, b.name, b.id_user, p.username
  ORDER BY (count(DISTINCT be.id)) DESC;


--
-- Name: vw_budget_summary_by_user; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_budget_summary_by_user AS
 SELECT u.id AS owner_user_id,
    u.username,
    count(DISTINCT b.id) AS total_budgets,
    sum(b.total_budget) AS total_budget_amount,
    sum(b.remaining_budget) AS total_remaining_amount,
    sum((b.total_budget - b.remaining_budget)) AS total_spent_amount,
        CASE
            WHEN (sum(b.total_budget) > (0)::numeric) THEN round(((sum((b.total_budget - b.remaining_budget)) / sum(b.total_budget)) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS overall_percentage_used
   FROM (public.kuentecouser u
     LEFT JOIN public.budget b ON (((u.id)::text = (b.id_user)::text)))
  GROUP BY u.id, u.username
  ORDER BY (sum(b.total_budget)) DESC;


--
-- Name: vw_budget_vs_actual; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_budget_vs_actual AS
 SELECT b.id_user AS owner_user_id,
    c.id AS category_id,
    b.id AS budget_id,
    COALESCE(c.name, 'Sin nombre'::character varying) AS category_name,
    b.name AS budget_name,
    b.total_budget AS assigned_amount,
    b.remaining_budget,
    COALESCE(sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
            ELSE (0)::numeric
        END), (0)::numeric) AS actual_spent,
    (COALESCE(b.total_budget, (0)::numeric) - COALESCE(sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
            ELSE (0)::numeric
        END), (0)::numeric)) AS calculated_remaining,
        CASE
            WHEN (b.total_budget > (0)::numeric) THEN round(((COALESCE(sum(
            CASE
                WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
                ELSE (0)::numeric
            END), (0)::numeric) / b.total_budget) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS percentage_used,
        CASE
            WHEN ((b.total_budget IS NULL) OR (b.total_budget = (0)::numeric)) THEN 'SIN_PRESUPUESTO'::text
            WHEN (COALESCE(sum(
            CASE
                WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
                ELSE (0)::numeric
            END), (0)::numeric) > b.total_budget) THEN 'EXCEDIDO'::text
            WHEN (COALESCE(sum(
            CASE
                WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
                ELSE (0)::numeric
            END), (0)::numeric) > (b.total_budget * 0.9)) THEN 'CERCA_LIMITE'::text
            ELSE 'NORMAL'::text
        END AS budget_status
   FROM (((public.category c
     JOIN public.budget b ON ((c.id_budget = b.id)))
     LEFT JOIN public.transaction t ON ((c.id = t.id_category)))
     LEFT JOIN public.profile p ON ((t.id_profile = p.id)))
  WHERE ((b.total_budget IS NOT NULL) AND (b.total_budget > (0)::numeric) AND (b.id IS NOT NULL))
  GROUP BY c.id, c.name, b.id, b.name, b.total_budget, b.remaining_budget, b.id_user
  ORDER BY
        CASE
            WHEN (b.total_budget > (0)::numeric) THEN round(((COALESCE(sum(
            CASE
                WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
                ELSE (0)::numeric
            END), (0)::numeric) / b.total_budget) * (100)::numeric), 2)
            ELSE (0)::numeric
        END DESC;


--
-- Name: vw_category_enrollments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_category_enrollments AS
 SELECT array_agg(ce.id) AS category_enrollment_ids,
    c.id_user AS owner_user_id,
    c.name AS category_name,
    p.username AS profile_name,
    count(DISTINCT ce.id) AS total_enrollments,
    min(ce.enrollment_date) AS first_enrollment_date,
    max(ce.enrollment_date) AS last_enrollment_date,
    c.register_date AS category_register_date,
    ((c.description ->> 'assignedBudget'::text))::numeric AS assigned_budget,
    (c.description ->> 'state'::text) AS category_state
   FROM ((public.category c
     JOIN public.category_enrollment ce ON ((c.id = ce.id_category)))
     LEFT JOIN public.profile p ON ((ce.id_profile = p.id)))
  WHERE (ce.id IS NOT NULL)
  GROUP BY c.id, c.name, c.description, c.id_user, c.register_date, p.username
  ORDER BY (count(DISTINCT ce.id)) DESC;


--
-- Name: vw_debt_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_debt_summary AS
 SELECT u.id AS owner_user_id,
    u.username,
    count(*) AS total_debts,
    count(
        CASE
            WHEN ((d.state)::text = 'ACTIVE'::text) THEN 1
            ELSE NULL::integer
        END) AS active_debts,
    count(
        CASE
            WHEN ((d.state)::text = 'PAID'::text) THEN 1
            ELSE NULL::integer
        END) AS paid_debts,
    count(
        CASE
            WHEN ((d.state)::text = 'DEFEATED'::text) THEN 1
            ELSE NULL::integer
        END) AS overdue_debts,
    count(
        CASE
            WHEN ((d.state)::text = 'REFINANCED'::text) THEN 1
            ELSE NULL::integer
        END) AS refinanced_debts,
    count(
        CASE
            WHEN ((d.state)::text = 'IN_MORATIUM'::text) THEN 1
            ELSE NULL::integer
        END) AS in_moratium_debts,
    count(
        CASE
            WHEN ((d.state)::text = 'CANCELLED'::text) THEN 1
            ELSE NULL::integer
        END) AS cancelled_debts,
    sum(d.total_amount) AS total_debt_amount,
    sum(d.pending_amount) AS total_pending_amount,
    sum(
        CASE
            WHEN ((d.state)::text = 'ACTIVE'::text) THEN d.pending_amount
            ELSE (0)::numeric
        END) AS active_pending_amount,
    min(
        CASE
            WHEN ((d.state)::text = 'ACTIVE'::text) THEN d.expiration_date
            ELSE NULL::timestamp without time zone
        END) AS next_due_date,
    count(
        CASE
            WHEN (((d.state)::text = 'ACTIVE'::text) AND (d.expiration_date < now())) THEN 1
            ELSE NULL::integer
        END) AS expired_active_debts
   FROM (public.kuentecouser u
     LEFT JOIN public.debt d ON (((u.id)::text = (d.id_user)::text)))
  GROUP BY u.id, u.username
  ORDER BY (sum(
        CASE
            WHEN ((d.state)::text = 'ACTIVE'::text) THEN d.pending_amount
            ELSE (0)::numeric
        END)) DESC;


--
-- Name: vw_transactions_by_category; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_transactions_by_category AS
 SELECT c.id AS category_id,
    COALESCE(c.name, 'Sin nombre'::character varying) AS category_name,
        CASE
            WHEN (t.id_user IS NOT NULL) THEN t.id_user
            WHEN (t.id_profile IS NOT NULL) THEN p.id_user
            ELSE c.id_user
        END AS owner_user_id,
    sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'INCOME'::text) THEN t.amount
            ELSE (0)::numeric
        END) AS total_income,
    sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
            ELSE (0)::numeric
        END) AS total_expenses,
    sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'INCOME'::text) THEN t.amount
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN (- t.amount)
            ELSE (0)::numeric
        END) AS net_amount,
    count(t.id) AS transaction_count,
    count(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'INCOME'::text) THEN 1
            ELSE NULL::integer
        END) AS income_count,
    count(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN 1
            ELSE NULL::integer
        END) AS expense_count
   FROM ((public.category c
     LEFT JOIN public.transaction t ON ((c.id = t.id_category)))
     LEFT JOIN public.profile p ON ((t.id_profile = p.id)))
  WHERE (t.id IS NOT NULL)
  GROUP BY c.id, c.name, c.id_user,
        CASE
            WHEN (t.id_user IS NOT NULL) THEN t.id_user
            WHEN (t.id_profile IS NOT NULL) THEN p.id_user
            ELSE c.id_user
        END
  ORDER BY (sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
            ELSE (0)::numeric
        END)) DESC;


--
-- Name: vw_transactions_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_transactions_summary AS
 SELECT
        CASE
            WHEN (t.id_user IS NOT NULL) THEN t.id_user
            WHEN (t.id_profile IS NOT NULL) THEN p.id_user
            ELSE NULL::character varying
        END AS owner_user_id,
    t.id_profile,
    t.id,
        CASE
            WHEN (t.id_user IS NOT NULL) THEN 'USER'::text
            WHEN (t.id_profile IS NOT NULL) THEN 'PROFILE'::text
            ELSE 'UNKNOWN'::text
        END AS transaction_owner_type,
    COALESCE(t.name, 'Sin nombre'::character varying) AS transaction_name,
    COALESCE(c.name, 'Sin categoría'::character varying) AS category_name,
    COALESCE(b.name, 'Sin presupuesto'::character varying) AS budget_name,
    COALESCE(d.name, 'Sin deuda'::character varying) AS debt_name,
    count(*) AS transaction_count,
    count(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'INCOME'::text) THEN 1
            ELSE NULL::integer
        END) AS income_count,
    count(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN 1
            ELSE NULL::integer
        END) AS expense_count,
    sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'INCOME'::text) THEN t.amount
            ELSE (0)::numeric
        END) AS total_income,
    sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN t.amount
            ELSE (0)::numeric
        END) AS total_expenses,
    sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'INCOME'::text) THEN t.amount
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN (- t.amount)
            ELSE (0)::numeric
        END) AS net_amount,
    min(t.transaction_date) AS first_transaction_date,
    max(t.transaction_date) AS last_transaction_date
   FROM ((((public.transaction t
     LEFT JOIN public.profile p ON ((t.id_profile = p.id)))
     LEFT JOIN public.category c ON ((t.id_category = c.id)))
     LEFT JOIN public.budget b ON ((t.id_budget = b.id)))
     LEFT JOIN public.debt d ON ((t.id_debt = d.id)))
  GROUP BY
        CASE
            WHEN (t.id_user IS NOT NULL) THEN t.id_user
            WHEN (t.id_profile IS NOT NULL) THEN p.id_user
            ELSE NULL::character varying
        END,
        CASE
            WHEN (t.id_user IS NOT NULL) THEN 'USER'::text
            WHEN (t.id_profile IS NOT NULL) THEN 'PROFILE'::text
            ELSE 'UNKNOWN'::text
        END, t.id_profile, t.id, t.name, c.name, b.name, d.name
  ORDER BY (sum(
        CASE
            WHEN ((t.description ->> 'type'::text) = 'INCOME'::text) THEN t.amount
            WHEN ((t.description ->> 'type'::text) = 'EXPENSE'::text) THEN (- t.amount)
            ELSE (0)::numeric
        END)) DESC;


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: exchange_rate_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rate_logs ALTER COLUMN id SET DEFAULT nextval('public.exchange_rate_logs_id_seq'::regclass);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bancolombia_token bancolombia_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bancolombia_token
    ADD CONSTRAINT bancolombia_token_pkey PRIMARY KEY (id);


--
-- Name: budget_enrollment budget_enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_enrollment
    ADD CONSTRAINT budget_enrollment_pkey PRIMARY KEY (id);


--
-- Name: budget budget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_pkey PRIMARY KEY (id);


--
-- Name: category_enrollment category_enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_enrollment
    ADD CONSTRAINT category_enrollment_pkey PRIMARY KEY (id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: debt debt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate_logs exchange_rate_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rate_logs
    ADD CONSTRAINT exchange_rate_logs_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate exchange_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rate
    ADD CONSTRAINT exchange_rate_pkey PRIMARY KEY (id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: kuentecouser kuentecouser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT kuentecouser_pkey PRIMARY KEY (id);


--
-- Name: mercadopago_payment mercadopago_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mercadopago_payment
    ADD CONSTRAINT mercadopago_payment_pkey PRIMARY KEY (id);


--
-- Name: mercadopago_preapproval mercadopago_preapproval_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mercadopago_preapproval
    ADD CONSTRAINT mercadopago_preapproval_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: kuentecouser uk1mnqrhn6gtybin2c8vkatp4b0; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT uk1mnqrhn6gtybin2c8vkatp4b0 UNIQUE (id_image);


--
-- Name: mercadopago_preapproval uk413g3vooaquwwjxee01ty3gk5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mercadopago_preapproval
    ADD CONSTRAINT uk413g3vooaquwwjxee01ty3gk5 UNIQUE (preapproval_id);


--
-- Name: profile uk9d5dpsf2ufa6rjbi3y0elkdcd; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT uk9d5dpsf2ufa6rjbi3y0elkdcd UNIQUE (email);


--
-- Name: exchange_rate uk_exchange_rate_currencies; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rate
    ADD CONSTRAINT uk_exchange_rate_currencies UNIQUE (base_currency, target_currency);


--
-- Name: profile ukbyvq5gfk58sc5ng6s68ucwbcc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT ukbyvq5gfk58sc5ng6s68ucwbcc UNIQUE (id_image);


--
-- Name: mercadopago_payment ukf7mt14u65t19ngeobgdg1e8kn; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mercadopago_payment
    ADD CONSTRAINT ukf7mt14u65t19ngeobgdg1e8kn UNIQUE (payment_id);


--
-- Name: kuentecouser ukhd8nejk7idsclqax3gqup1s8u; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT ukhd8nejk7idsclqax3gqup1s8u UNIQUE (username);


--
-- Name: kuentecouser uklltag847emv0e2oifpvw6l4ri; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT uklltag847emv0e2oifpvw6l4ri UNIQUE (email);


--
-- Name: subscription ukndcjk2a0l0vgu5asher4qk173; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT ukndcjk2a0l0vgu5asher4qk173 UNIQUE (id_mercadopago_preapproval);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: idx_audit_logs_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_record_id ON public.audit_logs USING btree (record_id);


--
-- Name: idx_audit_logs_table_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_table_name ON public.audit_logs USING btree (table_name);


--
-- Name: idx_audit_logs_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_timestamp ON public.audit_logs USING btree (log_timestamp);


--
-- Name: idx_image_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_image_image_id ON public.image USING btree (id_image);


--
-- Name: idx_image_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_image_url ON public.image USING btree (url_image);


--
-- Name: idx_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_email ON public.kuentecouser USING btree (email);


--
-- Name: idx_user_name_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_name_email ON public.kuentecouser USING btree (username, email);


--
-- Name: idx_user_password; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_password ON public.kuentecouser USING btree (password);


--
-- Name: idx_user_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_username ON public.kuentecouser USING btree (username);


--
-- Name: transaction trg_check_budget_limit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_check_budget_limit AFTER INSERT OR UPDATE ON public.transaction FOR EACH ROW EXECUTE FUNCTION public.check_budget_limit();


--
-- Name: kuentecouser trg_log_audit_user_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_log_audit_user_changes AFTER INSERT OR DELETE OR UPDATE ON public.kuentecouser FOR EACH ROW EXECUTE FUNCTION public.log_audit_user_changes();


--
-- Name: debt trg_send_debt_reminder; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_send_debt_reminder AFTER INSERT OR UPDATE ON public.debt FOR EACH ROW EXECUTE FUNCTION public.send_debt_reminder();


--
-- Name: transaction trg_update_remaining_budget_on_transaction; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_update_remaining_budget_on_transaction AFTER INSERT OR DELETE OR UPDATE ON public.transaction FOR EACH ROW EXECUTE FUNCTION public.update_remaining_budget_on_transaction();


--
-- Name: budget_enrollment fk_budget; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_enrollment
    ADD CONSTRAINT fk_budget FOREIGN KEY (id_budget) REFERENCES public.budget(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: category fk_budget; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT fk_budget FOREIGN KEY (id_budget) REFERENCES public.budget(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: transaction fk_budget; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fk_budget FOREIGN KEY (id_budget) REFERENCES public.budget(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: category_enrollment fk_category; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_enrollment
    ADD CONSTRAINT fk_category FOREIGN KEY (id_category) REFERENCES public.category(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: transaction fk_category; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fk_category FOREIGN KEY (id_category) REFERENCES public.category(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: transaction fk_debt; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fk_debt FOREIGN KEY (id_debt) REFERENCES public.debt(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: mercadopago_payment fk_preapproval; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mercadopago_payment
    ADD CONSTRAINT fk_preapproval FOREIGN KEY (id_preapproval) REFERENCES public.mercadopago_preapproval(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: budget_enrollment fk_profile; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_enrollment
    ADD CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES public.profile(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: category_enrollment fk_profile; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_enrollment
    ADD CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES public.profile(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: notification fk_profile; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES public.profile(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: transaction fk_profile; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES public.profile(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: budget fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: budget_enrollment fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_enrollment
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: category fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: category_enrollment fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_enrollment
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: debt fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: mercadopago_preapproval fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mercadopago_preapproval
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: notification fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: profile fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: subscription fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: transaction fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: subscription fkagen0a42e0n1io0f3aoamsyj2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT fkagen0a42e0n1io0f3aoamsyj2 FOREIGN KEY (id_mercadopago_preapproval) REFERENCES public.mercadopago_preapproval(id);


--
-- Name: kuentecouser fkdon9ipl5er2qh2o2r89ns9iek; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT fkdon9ipl5er2qh2o2r89ns9iek FOREIGN KEY (id_role) REFERENCES public.role(id);


--
-- Name: kuentecouser fkl11v6nubr4f8o23upxllfhbby; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT fkl11v6nubr4f8o23upxllfhbby FOREIGN KEY (id_image) REFERENCES public.image(id);


--
-- Name: profile fkm5edwxtkjcrfjklwlj51rs884; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT fkm5edwxtkjcrfjklwlj51rs884 FOREIGN KEY (id_role) REFERENCES public.role(id);


--
-- Name: profile fkp47h5upprwpx5yvrlie5f8sjs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT fkp47h5upprwpx5yvrlie5f8sjs FOREIGN KEY (id_image) REFERENCES public.image(id);


--
-- PostgreSQL database dump complete
--

