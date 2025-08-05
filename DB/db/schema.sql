Password: 
--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.4 (Debian 17.4-1.pgdg120+2)

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
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: http; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA public;


--
-- Name: EXTENSION http; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION http IS 'HTTP client for PostgreSQL, allows web page retrieval inside the database.';


--
-- Name: check_budget_limit(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.check_budget_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_assigned_amount NUMERIC; -- Monto asignado al presupuesto
    v_total_spent NUMERIC;     -- Total gastado en la categoría
BEGIN
    -- Obtener el monto asignado al presupuesto
    SELECT assigned_amount INTO v_assigned_amount
    FROM Budget
    WHERE id_category = NEW.idCategory;

    -- Calcular el total gastado en la categoría
    SELECT COALESCE(SUM(amount), 0) INTO v_total_spent
    FROM Transaction
    WHERE id_category = NEW.idCategory;

    -- Verificar si se ha excedido el presupuesto
    IF v_total_spent > v_assigned_amount THEN
        -- Insertar una notificación
        INSERT INTO Notification (id_account, date_send, content)
        VALUES (
            NEW.idAccount,
            NOW(),
            jsonb_build_object(
                'message', 'Has excedido el presupuesto asignado para la categoría ' || (SELECT name FROM Category WHERE id = NEW.idCategory),
                'type', 'budget_exceeded'
            )
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_budget_limit() OWNER TO master;

--
-- Name: convert_currency(numeric, character varying, character varying); Type: FUNCTION; Schema: public; Owner: master
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


ALTER FUNCTION public.convert_currency(p_amount numeric, p_base_currency character varying, p_target_currency character varying) OWNER TO master;

--
-- Name: log_audit_user_changes(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.log_audit_user_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Registrar el cambio en una tabla de auditoría
    INSERT INTO exchange_rate_logs (log_message, log_timestamp)
    VALUES (
        TG_OP || ' on KuenteCOUser: ' || NEW.id,
        NOW()
    );

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_audit_user_changes() OWNER TO master;

--
-- Name: send_debt_reminder(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.send_debt_reminder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verificar si la deuda está próxima a vencer (por ejemplo, en 3 días)
    IF NEW.expirationDate <= NOW() + INTERVAL '3 days' THEN
        -- Insertar una notificación
        INSERT INTO Notification (id_account, date_send, content)
        VALUES (
            NEW.idAccount,
            NOW(),
            jsonb_build_object(
                'message', 'Tu deuda "' || NEW.name || '" vence el ' || NEW.expirationDate || '. Por favor, realiza el pago.',
                'type', 'debt_reminder'
            )
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.send_debt_reminder() OWNER TO master;

--
-- Name: update_balance_on_transaction(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.update_balance_on_transaction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Si es una inserción
    IF TG_OP = 'INSERT' THEN
        UPDATE Account
        SET balance = balance + NEW.amount
        WHERE id = NEW.idAccount;
    END IF;

    -- Si es una actualización
    IF TG_OP = 'UPDATE' THEN
        -- Revertir el saldo anterior
        UPDATE Account
        SET balance = balance - OLD.amount
        WHERE id = OLD.idAccount;

        -- Aplicar el nuevo saldo
        UPDATE Account
        SET balance = balance + NEW.amount
        WHERE id = NEW.idAccount;
    END IF;

    -- Si es una eliminación
    IF TG_OP = 'DELETE' THEN
        UPDATE Account
        SET balance = balance - OLD.amount
        WHERE id = OLD.idAccount;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_balance_on_transaction() OWNER TO master;

--
-- Name: update_exchange_rates(); Type: FUNCTION; Schema: public; Owner: master
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


ALTER FUNCTION public.update_exchange_rates() OWNER TO master;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.account (
    id integer NOT NULL,
    balance numeric(38,2),
    currency character varying(255),
    name character varying(255),
    start_date timestamp(6) without time zone,
    type character varying(255),
    id_user character varying(255) NOT NULL,
    id_image integer,
    CONSTRAINT account_type_check CHECK (((type)::text = ANY ((ARRAY['PERSONAL'::character varying, 'BUSINESS'::character varying])::text[])))
);


ALTER TABLE public.account OWNER TO master;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.account ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: asset; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.asset (
    id integer NOT NULL,
    name character varying(255),
    type character varying(255),
    value numeric(38,2),
    id_account integer
);


ALTER TABLE public.asset OWNER TO master;

--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.asset ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: budget; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.budget (
    id integer NOT NULL,
    assigned_amount numeric(38,2),
    description character varying(255),
    finish_date timestamp(6) without time zone,
    name character varying(255),
    start_date timestamp(6) without time zone,
    state character varying(255),
    id_account integer,
    id_category integer,
    remaining_budget numeric(38,2),
    total_budget numeric(38,2),
    CONSTRAINT budget_state_check CHECK (((state)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying])::text[])))
);


ALTER TABLE public.budget OWNER TO master;

--
-- Name: budget_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: category; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.category (
    id integer NOT NULL,
    assigned_budget numeric(38,2) NOT NULL,
    description character varying(255),
    finish_date timestamp(6) without time zone,
    name character varying(255),
    start_date timestamp(6) without time zone,
    state character varying(255),
    id_account integer,
    id_budget integer,
    id_asset integer,
    CONSTRAINT category_state_check CHECK (((state)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying])::text[])))
);


ALTER TABLE public.category OWNER TO master;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: debt; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.debt (
    id integer NOT NULL,
    expiration_date timestamp(6) without time zone,
    name character varying(255),
    pending_amount numeric(38,2),
    start_date timestamp(6) without time zone,
    state character varying(255),
    total_amount numeric(38,2),
    id_account integer,
    CONSTRAINT debt_state_check CHECK (((state)::text = ANY ((ARRAY['ACTIVE'::character varying, 'PAID'::character varying, 'DEFEATED'::character varying, 'REFINANCED'::character varying, 'IN_MORATIUM'::character varying, 'CANCELLED'::character varying])::text[])))
);


ALTER TABLE public.debt OWNER TO master;

--
-- Name: debt_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: exchange_rate; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.exchange_rate (
    id integer NOT NULL,
    base_currency character varying(255),
    last_updated timestamp(6) without time zone,
    rate numeric(38,2),
    target_currency character varying(255)
);


ALTER TABLE public.exchange_rate OWNER TO master;

--
-- Name: exchange_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: exchange_rate_logs; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.exchange_rate_logs (
    id integer NOT NULL,
    log_message text,
    log_timestamp timestamp without time zone DEFAULT now()
);


ALTER TABLE public.exchange_rate_logs OWNER TO master;

--
-- Name: exchange_rate_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.exchange_rate_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exchange_rate_logs_id_seq OWNER TO master;

--
-- Name: exchange_rate_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.exchange_rate_logs_id_seq OWNED BY public.exchange_rate_logs.id;


--
-- Name: goal; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.goal (
    id integer NOT NULL,
    assigned_amount numeric(38,2),
    description character varying(255),
    finish_date timestamp(6) without time zone,
    goaltype character varying(255),
    name character varying(255),
    start_date timestamp(6) without time zone,
    state character varying(255),
    id_account integer,
    id_category integer,
    goal_type character varying(255),
    CONSTRAINT goal_goal_type_check CHECK (((goal_type)::text = ANY ((ARRAY['SAVINGS'::character varying, 'INVESTMENT'::character varying, 'EXPENSE'::character varying, 'EMERGENCY'::character varying, 'DEBT_PAYMENT'::character varying, 'EDUCATION'::character varying, 'RETIREMENT'::character varying, 'OTHER'::character varying])::text[]))),
    CONSTRAINT goal_goaltype_check CHECK (((goaltype)::text = ANY ((ARRAY['SAVINGS'::character varying, 'INVESTMENT'::character varying, 'EXPENSE'::character varying, 'EMERGENCY'::character varying, 'DEBT_PAYMENT'::character varying, 'EDUCATION'::character varying, 'RETIREMENT'::character varying, 'OTHER'::character varying])::text[]))),
    CONSTRAINT goal_state_check CHECK (((state)::text = ANY ((ARRAY['PENDING'::character varying, 'ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying])::text[])))
);


ALTER TABLE public.goal OWNER TO master;

--
-- Name: goal_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.goal ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.goal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: image; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.image (
    id integer NOT NULL,
    id_image character varying(255) NOT NULL,
    imageurl character varying(255) NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.image OWNER TO master;

--
-- Name: image_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: investment; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.investment (
    id integer NOT NULL,
    initial_amount numeric(38,2),
    profitability numeric(38,2),
    start_date timestamp(6) without time zone,
    state character varying(255),
    type character varying(255),
    id_account integer,
    CONSTRAINT investment_state_check CHECK (((state)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying, 'FINALIZED'::character varying, 'CANCELED'::character varying])::text[])))
);


ALTER TABLE public.investment OWNER TO master;

--
-- Name: investment_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.investment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.investment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: kuentecouser; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.kuentecouser (
    id character varying(255) NOT NULL,
    account character varying(255),
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    id_role integer NOT NULL,
    account_state character varying(255),
    version integer,
    name character varying(255) NOT NULL,
    id_image integer,
    CONSTRAINT kuentecouser_account_check CHECK (((account)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying])::text[]))),
    CONSTRAINT kuentecouser_account_state_check CHECK (((account_state)::text = ANY ((ARRAY['PENDING'::character varying, 'ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying])::text[])))
);


ALTER TABLE public.kuentecouser OWNER TO master;

--
-- Name: notification; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.notification (
    id integer NOT NULL,
    content jsonb,
    date_send timestamp(6) without time zone,
    id_account integer
);


ALTER TABLE public.notification OWNER TO master;

--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: pay_subscription; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.pay_subscription (
    id integer NOT NULL,
    amount numeric(38,2),
    pay_date timestamp(6) without time zone,
    details jsonb,
    method character varying(255),
    id_subscription integer,
    card_last_four character varying(4),
    payment_email character varying(255)
);


ALTER TABLE public.pay_subscription OWNER TO master;

--
-- Name: pay_subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.pay_subscription ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pay_subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payment_history; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.payment_history (
    id integer NOT NULL,
    details jsonb,
    id_pay_subscription integer
);


ALTER TABLE public.payment_history OWNER TO master;

--
-- Name: payment_history_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.payment_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.payment_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: role; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    CONSTRAINT role_name_check CHECK (((name)::text = ANY ((ARRAY['ROLE_USER'::character varying, 'ROLE_ADMIN'::character varying])::text[])))
);


ALTER TABLE public.role OWNER TO master;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: subscription; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.subscription (
    id integer NOT NULL,
    expiration_date timestamp(6) without time zone,
    start_date timestamp(6) without time zone,
    state character varying(255),
    type character varying(255),
    id_account integer,
    CONSTRAINT subscription_state_check CHECK (((state)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying])::text[])))
);


ALTER TABLE public.subscription OWNER TO master;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: tax_report; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.tax_report (
    id integer NOT NULL,
    generated_date timestamp(6) without time zone,
    report_url character varying(255),
    status character varying(255),
    tax_year integer,
    id_account integer
);


ALTER TABLE public.tax_report OWNER TO master;

--
-- Name: tax_report_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.tax_report ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tax_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.transaction (
    id integer NOT NULL,
    amount numeric(38,2),
    description jsonb,
    transaction_date timestamp(6) without time zone,
    type character varying(255),
    id_account integer,
    id_category integer,
    id_exchange_rate integer,
    id_debt integer,
    id_goal integer
);


ALTER TABLE public.transaction OWNER TO master;

--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: master
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
-- Name: vw_budget_vs_actual; Type: VIEW; Schema: public; Owner: master
--

CREATE VIEW public.vw_budget_vs_actual AS
 SELECT b.id AS budget_id,
    b.name AS budget_name,
    b.assigned_amount,
    COALESCE(sum(t.amount), (0)::numeric) AS actual_spent,
    (b.assigned_amount - COALESCE(sum(t.amount), (0)::numeric)) AS remaining_amount
   FROM (public.budget b
     LEFT JOIN public.transaction t ON ((b.id_category = t.id_category)))
  GROUP BY b.id, b.name, b.assigned_amount;


ALTER VIEW public.vw_budget_vs_actual OWNER TO master;

--
-- Name: vw_transactions_by_category; Type: VIEW; Schema: public; Owner: master
--

CREATE VIEW public.vw_transactions_by_category AS
 SELECT c.name AS category_name,
    sum(t.amount) AS total_amount,
    count(t.id) AS transaction_count
   FROM (public.transaction t
     JOIN public.category c ON ((t.id_category = c.id)))
  GROUP BY c.name;


ALTER VIEW public.vw_transactions_by_category OWNER TO master;

--
-- Name: exchange_rate_logs id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchange_rate_logs ALTER COLUMN id SET DEFAULT nextval('public.exchange_rate_logs_id_seq'::regclass);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: asset asset_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- Name: budget budget_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_pkey PRIMARY KEY (id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: debt debt_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate_logs exchange_rate_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchange_rate_logs
    ADD CONSTRAINT exchange_rate_logs_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate exchange_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchange_rate
    ADD CONSTRAINT exchange_rate_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate exchange_rate_unique; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchange_rate
    ADD CONSTRAINT exchange_rate_unique UNIQUE (base_currency, target_currency);


--
-- Name: goal goal_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.goal
    ADD CONSTRAINT goal_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: investment investment_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.investment
    ADD CONSTRAINT investment_pkey PRIMARY KEY (id);


--
-- Name: kuentecouser kuentecouser_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT kuentecouser_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: pay_subscription pay_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.pay_subscription
    ADD CONSTRAINT pay_subscription_pkey PRIMARY KEY (id);


--
-- Name: payment_history payment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (id);


--
-- Name: tax_report tax_report_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.tax_report
    ADD CONSTRAINT tax_report_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: kuentecouser uk1mnqrhn6gtybin2c8vkatp4b0; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT uk1mnqrhn6gtybin2c8vkatp4b0 UNIQUE (id_image);


--
-- Name: account ukepnjvbebxtshcjj96dtgvr3v9; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT ukepnjvbebxtshcjj96dtgvr3v9 UNIQUE (id_image);


--
-- Name: kuentecouser uklltag847emv0e2oifpvw6l4ri; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT uklltag847emv0e2oifpvw6l4ri UNIQUE (email);


--
-- Name: kuentecouser ukojtc508b9sw124tt3el2v2smx; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT ukojtc508b9sw124tt3el2v2smx UNIQUE (name);


--
-- Name: pay_subscription ukqborkarwyf79596j3780j0x8d; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.pay_subscription
    ADD CONSTRAINT ukqborkarwyf79596j3780j0x8d UNIQUE (id_subscription);


--
-- Name: transaction trg_check_budget_limit; Type: TRIGGER; Schema: public; Owner: master
--

CREATE TRIGGER trg_check_budget_limit AFTER INSERT OR UPDATE ON public.transaction FOR EACH ROW EXECUTE FUNCTION public.check_budget_limit();


--
-- Name: kuentecouser trg_log_audit_user_changes; Type: TRIGGER; Schema: public; Owner: master
--

CREATE TRIGGER trg_log_audit_user_changes AFTER INSERT OR DELETE OR UPDATE ON public.kuentecouser FOR EACH ROW EXECUTE FUNCTION public.log_audit_user_changes();


--
-- Name: debt trg_send_debt_reminder; Type: TRIGGER; Schema: public; Owner: master
--

CREATE TRIGGER trg_send_debt_reminder AFTER INSERT OR UPDATE ON public.debt FOR EACH ROW EXECUTE FUNCTION public.send_debt_reminder();


--
-- Name: transaction trg_update_balance_on_transaction; Type: TRIGGER; Schema: public; Owner: master
--

CREATE TRIGGER trg_update_balance_on_transaction AFTER INSERT OR DELETE OR UPDATE ON public.transaction FOR EACH ROW EXECUTE FUNCTION public.update_balance_on_transaction();


--
-- Name: notification fk10kjqa3c2i0d2j7gokgru42ul; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT fk10kjqa3c2i0d2j7gokgru42ul FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: debt fk1ga55hm9wog60hja3pfuvnggg; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT fk1ga55hm9wog60hja3pfuvnggg FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: tax_report fk2gvv0l7kfsvhj1dtxf3h5vbxx; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.tax_report
    ADD CONSTRAINT fk2gvv0l7kfsvhj1dtxf3h5vbxx FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: category fk6qjcaktwi84h9kobesoj4ktfl; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT fk6qjcaktwi84h9kobesoj4ktfl FOREIGN KEY (id_budget) REFERENCES public.budget(id);


--
-- Name: budget fk7jq6lh5x4qo4jypsilxvsvilx; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT fk7jq6lh5x4qo4jypsilxvsvilx FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: account fkbe1lm29t1uduyx8schuleimiu; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT fkbe1lm29t1uduyx8schuleimiu FOREIGN KEY (id_user) REFERENCES public.kuentecouser(id);


--
-- Name: account fkc5nesbc3lhkhsr15cd3v4lt00; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT fkc5nesbc3lhkhsr15cd3v4lt00 FOREIGN KEY (id_image) REFERENCES public.image(id);


--
-- Name: kuentecouser fkdon9ipl5er2qh2o2r89ns9iek; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT fkdon9ipl5er2qh2o2r89ns9iek FOREIGN KEY (id_role) REFERENCES public.role(id);


--
-- Name: investment fke5ap7yy0bs7m63m2y1l2ofik9; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.investment
    ADD CONSTRAINT fke5ap7yy0bs7m63m2y1l2ofik9 FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: pay_subscription fkeu16ps80ltd8ot53tn26bwwks; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.pay_subscription
    ADD CONSTRAINT fkeu16ps80ltd8ot53tn26bwwks FOREIGN KEY (id_subscription) REFERENCES public.subscription(id);


--
-- Name: transaction fkfdy2s2qxjhc84611xwahd7oic; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fkfdy2s2qxjhc84611xwahd7oic FOREIGN KEY (id_goal) REFERENCES public.goal(id);


--
-- Name: transaction fkhp000uknj257felelkrgv2k64; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fkhp000uknj257felelkrgv2k64 FOREIGN KEY (id_category) REFERENCES public.category(id);


--
-- Name: category fkidbfpcrt66hpkj2rjdoqpboqt; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT fkidbfpcrt66hpkj2rjdoqpboqt FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: category fkiugsyvbuq9nniupprns7ta6sq; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT fkiugsyvbuq9nniupprns7ta6sq FOREIGN KEY (id_asset) REFERENCES public.asset(id);


--
-- Name: subscription fkj6t70mdjjv92vddowrcdveep2; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT fkj6t70mdjjv92vddowrcdveep2 FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: asset fkjmcp8ltc4bu38og82n1std0gh; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT fkjmcp8ltc4bu38og82n1std0gh FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: goal fkk495fhja02ote29b142hwdtr9; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.goal
    ADD CONSTRAINT fkk495fhja02ote29b142hwdtr9 FOREIGN KEY (id_category) REFERENCES public.category(id);


--
-- Name: category fkkfon7toadusu4gnilq6djg3pk; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT fkkfon7toadusu4gnilq6djg3pk FOREIGN KEY (id_budget) REFERENCES public.asset(id);


--
-- Name: transaction fkkgpuehmmok9j5yjoaf3xbbl0r; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fkkgpuehmmok9j5yjoaf3xbbl0r FOREIGN KEY (id_exchange_rate) REFERENCES public.exchange_rate(id);


--
-- Name: kuentecouser fkl11v6nubr4f8o23upxllfhbby; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT fkl11v6nubr4f8o23upxllfhbby FOREIGN KEY (id_image) REFERENCES public.image(id);


--
-- Name: budget fkp23sqyb2uww21t3cyub3360vh; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT fkp23sqyb2uww21t3cyub3360vh FOREIGN KEY (id_category) REFERENCES public.category(id);


--
-- Name: transaction fkqougs4kxpidm8i9514o13rfdk; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fkqougs4kxpidm8i9514o13rfdk FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: goal fkqtoavg3gmnq9jgr5y6p05a4dt; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.goal
    ADD CONSTRAINT fkqtoavg3gmnq9jgr5y6p05a4dt FOREIGN KEY (id_account) REFERENCES public.account(id);


--
-- Name: transaction fkr6e2t2umurfia7g4d336xhx6v; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fkr6e2t2umurfia7g4d336xhx6v FOREIGN KEY (id_debt) REFERENCES public.debt(id);


--
-- Name: payment_history fktercbdqh27qlb0ql3hitrf5tu; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT fktercbdqh27qlb0ql3hitrf5tu FOREIGN KEY (id_pay_subscription) REFERENCES public.pay_subscription(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO replicator;


--
-- Name: TABLE account; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.account TO replicator;


--
-- Name: TABLE asset; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.asset TO replicator;


--
-- Name: TABLE budget; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.budget TO replicator;


--
-- Name: TABLE category; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.category TO replicator;


--
-- Name: TABLE debt; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.debt TO replicator;


--
-- Name: TABLE exchange_rate; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.exchange_rate TO replicator;


--
-- Name: TABLE exchange_rate_logs; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.exchange_rate_logs TO replicator;


--
-- Name: TABLE goal; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.goal TO replicator;


--
-- Name: TABLE image; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.image TO replicator;


--
-- Name: TABLE investment; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.investment TO replicator;


--
-- Name: TABLE kuentecouser; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.kuentecouser TO replicator;


--
-- Name: TABLE notification; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.notification TO replicator;


--
-- Name: TABLE pay_subscription; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.pay_subscription TO replicator;


--
-- Name: TABLE payment_history; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.payment_history TO replicator;


--
-- Name: TABLE role; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.role TO replicator;


--
-- Name: TABLE subscription; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.subscription TO replicator;


--
-- Name: TABLE tax_report; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.tax_report TO replicator;


--
-- Name: TABLE transaction; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.transaction TO replicator;


--
-- Name: TABLE vw_budget_vs_actual; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.vw_budget_vs_actual TO replicator;


--
-- Name: TABLE vw_transactions_by_category; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT ON TABLE public.vw_transactions_by_category TO replicator;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: master
--

ALTER DEFAULT PRIVILEGES FOR ROLE master IN SCHEMA public GRANT SELECT ON TABLES TO replicator;


--
-- PostgreSQL database dump complete
--

