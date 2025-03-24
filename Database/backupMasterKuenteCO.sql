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
-- Name: accounttype; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.accounttype AS ENUM (
    'individual',
    'business'
);


ALTER TYPE public.accounttype OWNER TO master;

--
-- Name: pay_method_info; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.pay_method_info AS (
	method character varying(50),
	details jsonb
);


ALTER TYPE public.pay_method_info OWNER TO master;

--
-- Name: state; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.state AS ENUM (
    'active',
    'inactive',
    'suspended'
);


ALTER TYPE public.state OWNER TO master;

--
-- Name: statedebt; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.statedebt AS ENUM (
    'active',
    'paid',
    'defeated',
    'refinanced',
    'in moratorium',
    'canceled'
);


ALTER TYPE public.statedebt OWNER TO master;

--
-- Name: stateinvestment; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.stateinvestment AS ENUM (
    'active',
    'inactive',
    'suspended',
    'finalized',
    'canceled'
);


ALTER TYPE public.stateinvestment OWNER TO master;

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
    SELECT assignedAmount INTO v_assigned_amount
    FROM Budget
    WHERE idCategory = NEW.idCategory;

    -- Calcular el total gastado en la categoría
    SELECT COALESCE(SUM(amount), 0) INTO v_total_spent
    FROM Transaction
    WHERE idCategory = NEW.idCategory;

    -- Verificar si se ha excedido el presupuesto
    IF v_total_spent > v_assigned_amount THEN
        -- Insertar una notificación
        INSERT INTO Notification (idAccount, dateSend, content)
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
    FROM exchangeRate
    WHERE baseCurrency = p_base_currency
      AND targetCurrency = p_target_currency
      AND lastUpdated = (SELECT MAX(lastUpdated) FROM exchangeRate);

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
        INSERT INTO Notification (idAccount, dateSend, content)
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
    base_currency TEXT;
    rates JSONB;
    target_currency TEXT;
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
    base_currency := response_json->>'base';
    rates := response_json->'rates';

    -- Verificar si las tasas de cambio están presentes
    IF rates IS NULL THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: No se encontraron tasas de cambio en la respuesta de la API.');
        RAISE EXCEPTION 'Error: No se encontraron tasas de cambio en la respuesta de la API.';
    END IF;

    -- Recorrer las tasas de cambio y actualizar la tabla
    FOR target_currency, rate IN SELECT * FROM jsonb_each(rates) LOOP
        -- Insertar o actualizar la tasa de cambio en la tabla
        INSERT INTO exchangeRate (baseCurrency, targetCurrency, rate, lastUpdated)
        VALUES (base_currency, target_currency, rate, now())
        ON CONFLICT (baseCurrency, targetCurrency)
        DO UPDATE SET rate = EXCLUDED.rate, lastUpdated = EXCLUDED.lastUpdated;
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
    iduser uuid,
    type public.accounttype DEFAULT 'individual'::public.accounttype,
    balance numeric DEFAULT 0,
    currency character varying(10),
    startdate timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.account OWNER TO master;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.account_id_seq OWNER TO master;

--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.account_id_seq OWNED BY public.account.id;


--
-- Name: budget; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.budget (
    id integer NOT NULL,
    idaccount integer,
    idcategory integer,
    name character varying(100),
    description character varying(255),
    assignedamount numeric NOT NULL,
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    finishdate timestamp without time zone NOT NULL,
    state public.state DEFAULT 'active'::public.state
);


ALTER TABLE public.budget OWNER TO master;

--
-- Name: budget_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.budget_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.budget_id_seq OWNER TO master;

--
-- Name: budget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.budget_id_seq OWNED BY public.budget.id;


--
-- Name: category; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.category (
    id integer NOT NULL,
    idaccount integer,
    name character varying(50),
    description jsonb,
    assignedbudget numeric,
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    finishdate timestamp without time zone NOT NULL,
    state public.state DEFAULT 'active'::public.state
);


ALTER TABLE public.category OWNER TO master;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.category_id_seq OWNER TO master;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;


--
-- Name: debt; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.debt (
    id integer NOT NULL,
    idaccount integer,
    name character varying(50),
    totalamount numeric,
    pendingamount numeric,
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    expirationdate timestamp without time zone NOT NULL,
    state public.statedebt DEFAULT 'active'::public.statedebt
);


ALTER TABLE public.debt OWNER TO master;

--
-- Name: debt_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.debt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.debt_id_seq OWNER TO master;

--
-- Name: debt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.debt_id_seq OWNED BY public.debt.id;


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
-- Name: exchangerate; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.exchangerate (
    id integer NOT NULL,
    basecurrency character varying(10) NOT NULL,
    targetcurrency character varying(10) NOT NULL,
    rate numeric NOT NULL,
    lastupdated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.exchangerate OWNER TO master;

--
-- Name: exchangerate_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.exchangerate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exchangerate_id_seq OWNER TO master;

--
-- Name: exchangerate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.exchangerate_id_seq OWNED BY public.exchangerate.id;


--
-- Name: investment; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.investment (
    id integer NOT NULL,
    idaccount integer,
    type character varying(50),
    initialamount numeric,
    profitability numeric,
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    state public.stateinvestment DEFAULT 'active'::public.stateinvestment
);


ALTER TABLE public.investment OWNER TO master;

--
-- Name: investment_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.investment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.investment_id_seq OWNER TO master;

--
-- Name: investment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.investment_id_seq OWNED BY public.investment.id;


--
-- Name: kuentecouser; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.kuentecouser (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(50) NOT NULL,
    password character varying(160) NOT NULL,
    registerdate timestamp without time zone DEFAULT now() NOT NULL,
    account public.state DEFAULT 'active'::public.state
);


ALTER TABLE public.kuentecouser OWNER TO master;

--
-- Name: notification; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.notification (
    id integer NOT NULL,
    idaccount integer,
    datesend timestamp without time zone DEFAULT now() NOT NULL,
    content jsonb
);


ALTER TABLE public.notification OWNER TO master;

--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_id_seq OWNER TO master;

--
-- Name: notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.notification_id_seq OWNED BY public.notification.id;


--
-- Name: paymenthistory; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.paymenthistory (
    id integer NOT NULL,
    idpaysubscription integer,
    details jsonb
);


ALTER TABLE public.paymenthistory OWNER TO master;

--
-- Name: paymenthistory_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.paymenthistory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paymenthistory_id_seq OWNER TO master;

--
-- Name: paymenthistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.paymenthistory_id_seq OWNED BY public.paymenthistory.id;


--
-- Name: paysubscription; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.paysubscription (
    id integer NOT NULL,
    idsubscription integer,
    amount numeric,
    paydate timestamp without time zone DEFAULT now() NOT NULL,
    paymethod public.pay_method_info
);


ALTER TABLE public.paysubscription OWNER TO master;

--
-- Name: paysubscription_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.paysubscription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paysubscription_id_seq OWNER TO master;

--
-- Name: paysubscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.paysubscription_id_seq OWNED BY public.paysubscription.id;


--
-- Name: subscription; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.subscription (
    id integer NOT NULL,
    idaccount integer,
    type character varying(50) NOT NULL,
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    expirationdate timestamp without time zone NOT NULL,
    state public.state DEFAULT 'inactive'::public.state
);


ALTER TABLE public.subscription OWNER TO master;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.subscription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subscription_id_seq OWNER TO master;

--
-- Name: subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.subscription_id_seq OWNED BY public.subscription.id;


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.transaction (
    id integer NOT NULL,
    idaccount integer,
    idcategory integer,
    type character varying(50),
    amount numeric,
    transactiondate timestamp without time zone DEFAULT now() NOT NULL,
    description jsonb
);


ALTER TABLE public.transaction OWNER TO master;

--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

CREATE SEQUENCE public.transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transaction_id_seq OWNER TO master;

--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: master
--

ALTER SEQUENCE public.transaction_id_seq OWNED BY public.transaction.id;


--
-- Name: vw_budget_vs_actual; Type: VIEW; Schema: public; Owner: master
--

CREATE VIEW public.vw_budget_vs_actual AS
 SELECT b.id AS budget_id,
    b.name AS budget_name,
    b.assignedamount AS assigned_amount,
    COALESCE(sum(t.amount), (0)::numeric) AS actual_spent,
    (b.assignedamount - COALESCE(sum(t.amount), (0)::numeric)) AS remaining_amount
   FROM (public.budget b
     LEFT JOIN public.transaction t ON ((b.idcategory = t.idcategory)))
  GROUP BY b.id, b.name, b.assignedamount;


ALTER VIEW public.vw_budget_vs_actual OWNER TO master;

--
-- Name: vw_transactions_by_category; Type: VIEW; Schema: public; Owner: master
--

CREATE VIEW public.vw_transactions_by_category AS
 SELECT c.name AS category_name,
    sum(t.amount) AS total_amount,
    count(t.id) AS transaction_count
   FROM (public.transaction t
     JOIN public.category c ON ((t.idcategory = c.id)))
  GROUP BY c.name;


ALTER VIEW public.vw_transactions_by_category OWNER TO master;

--
-- Name: account id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT nextval('public.account_id_seq'::regclass);


--
-- Name: budget id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.budget ALTER COLUMN id SET DEFAULT nextval('public.budget_id_seq'::regclass);


--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);


--
-- Name: debt id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.debt ALTER COLUMN id SET DEFAULT nextval('public.debt_id_seq'::regclass);


--
-- Name: exchange_rate_logs id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchange_rate_logs ALTER COLUMN id SET DEFAULT nextval('public.exchange_rate_logs_id_seq'::regclass);


--
-- Name: exchangerate id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchangerate ALTER COLUMN id SET DEFAULT nextval('public.exchangerate_id_seq'::regclass);


--
-- Name: investment id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.investment ALTER COLUMN id SET DEFAULT nextval('public.investment_id_seq'::regclass);


--
-- Name: notification id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.notification ALTER COLUMN id SET DEFAULT nextval('public.notification_id_seq'::regclass);


--
-- Name: paymenthistory id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.paymenthistory ALTER COLUMN id SET DEFAULT nextval('public.paymenthistory_id_seq'::regclass);


--
-- Name: paysubscription id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.paysubscription ALTER COLUMN id SET DEFAULT nextval('public.paysubscription_id_seq'::regclass);


--
-- Name: subscription id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.subscription ALTER COLUMN id SET DEFAULT nextval('public.subscription_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction ALTER COLUMN id SET DEFAULT nextval('public.transaction_id_seq'::regclass);


--
-- Data for Name: job; Type: TABLE DATA; Schema: cron; Owner: master
--

COPY cron.job (jobid, schedule, command, nodename, nodeport, database, username, active, jobname) FROM stdin;
1	0 */2 * * *	 CALL update_exchange_rates() 	localhost	5432	KuenteCO	master	t	UpdateRatesTo2Hours
3	0 */2 * * *	 SELECT update_exchange_rates() 	localhost	5432	KuenteCO	master	t	update-change-rates
\.


--
-- Data for Name: job_run_details; Type: TABLE DATA; Schema: cron; Owner: master
--

COPY cron.job_run_details (jobid, runid, job_pid, database, username, command, status, return_message, start_time, end_time) FROM stdin;
1	1	\N	KuenteCO	master	 CALL update_exchange_rates() 	failed	connection failed	2025-03-05 18:00:00.000285+00	2025-03-05 18:00:00.013175+00
3	2	\N	KuenteCO	master	 SELECT update_exchange_rates() 	failed	connection failed	2025-03-05 18:00:00.000285+00	2025-03-05 18:00:00.013624+00
\.


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.account (id, iduser, type, balance, currency, startdate) FROM stdin;
\.


--
-- Data for Name: budget; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.budget (id, idaccount, idcategory, name, description, assignedamount, startdate, finishdate, state) FROM stdin;
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.category (id, idaccount, name, description, assignedbudget, startdate, finishdate, state) FROM stdin;
\.


--
-- Data for Name: debt; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.debt (id, idaccount, name, totalamount, pendingamount, startdate, expirationdate, state) FROM stdin;
\.


--
-- Data for Name: exchange_rate_logs; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.exchange_rate_logs (id, log_message, log_timestamp) FROM stdin;
2	Tasas de cambio actualizadas correctamente.	2025-03-01 13:20:51.655934
3	Tasas de cambio actualizadas correctamente.	2025-03-05 17:45:45.491936
\.


--
-- Data for Name: exchangerate; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.exchangerate (id, basecurrency, targetcurrency, rate, lastupdated) FROM stdin;
1	USD	AED	3.67275	2025-03-05 17:45:45.491936
2	USD	AFN	72.50001	2025-03-05 17:45:45.491936
3	USD	ALL	92.754925	2025-03-05 17:45:45.491936
4	USD	AMD	393.383582	2025-03-05 17:45:45.491936
5	USD	ANG	1.799575	2025-03-05 17:45:45.491936
6	USD	AOA	914.5	2025-03-05 17:45:45.491936
7	USD	ARS	1063.2921	2025-03-05 17:45:45.491936
8	USD	AUD	1.584771	2025-03-05 17:45:45.491936
9	USD	AWG	1.8025	2025-03-05 17:45:45.491936
10	USD	AZN	1.7	2025-03-05 17:45:45.491936
11	USD	BAM	1.842869	2025-03-05 17:45:45.491936
12	USD	BBD	2	2025-03-05 17:45:45.491936
13	USD	BDT	121.325749	2025-03-05 17:45:45.491936
14	USD	BGN	1.814049	2025-03-05 17:45:45.491936
15	USD	BHD	0.376933	2025-03-05 17:45:45.491936
16	USD	BIF	2913.5	2025-03-05 17:45:45.491936
17	USD	BMD	1	2025-03-05 17:45:45.491936
18	USD	BND	1.334303	2025-03-05 17:45:45.491936
19	USD	BOB	6.899647	2025-03-05 17:45:45.491936
20	USD	BRL	5.8095	2025-03-05 17:45:45.491936
21	USD	BSD	1	2025-03-05 17:45:45.491936
22	USD	BTC	0.000011250418	2025-03-05 17:45:45.491936
23	USD	BTN	86.987551	2025-03-05 17:45:45.491936
24	USD	BWP	13.733529	2025-03-05 17:45:45.491936
25	USD	BYN	3.267648	2025-03-05 17:45:45.491936
26	USD	BZD	2.005657	2025-03-05 17:45:45.491936
27	USD	CAD	1.437808	2025-03-05 17:45:45.491936
28	USD	CDF	2876	2025-03-05 17:45:45.491936
29	USD	CHF	0.89003	2025-03-05 17:45:45.491936
30	USD	CLF	0.024517	2025-03-05 17:45:45.491936
31	USD	CLP	940.83	2025-03-05 17:45:45.491936
32	USD	CNH	7.236925	2025-03-05 17:45:45.491936
33	USD	CNY	7.2656	2025-03-05 17:45:45.491936
34	USD	COP	4125.254972	2025-03-05 17:45:45.491936
35	USD	CRC	501.549663	2025-03-05 17:45:45.491936
36	USD	CUC	1	2025-03-05 17:45:45.491936
37	USD	CUP	25.75	2025-03-05 17:45:45.491936
38	USD	CVE	105.15	2025-03-05 17:45:45.491936
39	USD	CZK	23.21155	2025-03-05 17:45:45.491936
40	USD	DJF	177.5	2025-03-05 17:45:45.491936
41	USD	DKK	6.927538	2025-03-05 17:45:45.491936
42	USD	DOP	62.45	2025-03-05 17:45:45.491936
43	USD	DZD	133.706648	2025-03-05 17:45:45.491936
44	USD	EGP	50.6754	2025-03-05 17:45:45.491936
45	USD	ERN	15	2025-03-05 17:45:45.491936
46	USD	ETB	128.5	2025-03-05 17:45:45.491936
47	USD	EUR	0.928755	2025-03-05 17:45:45.491936
48	USD	FJD	2.31115	2025-03-05 17:45:45.491936
49	USD	FKP	0.77755	2025-03-05 17:45:45.491936
50	USD	GBP	0.77755	2025-03-05 17:45:45.491936
51	USD	GEL	2.79	2025-03-05 17:45:45.491936
52	USD	GGP	0.77755	2025-03-05 17:45:45.491936
53	USD	GHS	15.51	2025-03-05 17:45:45.491936
54	USD	GIP	0.77755	2025-03-05 17:45:45.491936
55	USD	GMD	71.500005	2025-03-05 17:45:45.491936
56	USD	GNF	8655	2025-03-05 17:45:45.491936
57	USD	GTQ	7.70191	2025-03-05 17:45:45.491936
58	USD	GYD	208.913149	2025-03-05 17:45:45.491936
59	USD	HKD	7.771355	2025-03-05 17:45:45.491936
60	USD	HNL	25.71	2025-03-05 17:45:45.491936
61	USD	HRK	6.997061	2025-03-05 17:45:45.491936
62	USD	HTG	131.101697	2025-03-05 17:45:45.491936
63	USD	HUF	369.80879	2025-03-05 17:45:45.491936
64	USD	IDR	16290.872333	2025-03-05 17:45:45.491936
65	USD	ILS	3.61863	2025-03-05 17:45:45.491936
66	USD	IMP	0.77755	2025-03-05 17:45:45.491936
67	USD	INR	86.902463	2025-03-05 17:45:45.491936
68	USD	IQD	1310	2025-03-05 17:45:45.491936
69	USD	IRR	42100	2025-03-05 17:45:45.491936
70	USD	ISK	136.43	2025-03-05 17:45:45.491936
71	USD	JEP	0.77755	2025-03-05 17:45:45.491936
72	USD	JMD	156.779353	2025-03-05 17:45:45.491936
73	USD	JOD	0.7094	2025-03-05 17:45:45.491936
74	USD	JPY	148.8345	2025-03-05 17:45:45.491936
75	USD	KES	128.5	2025-03-05 17:45:45.491936
76	USD	KGS	87.45	2025-03-05 17:45:45.491936
77	USD	KHR	4010	2025-03-05 17:45:45.491936
78	USD	KMF	471.400127	2025-03-05 17:45:45.491936
79	USD	KPW	900	2025-03-05 17:45:45.491936
80	USD	KRW	1445.420801	2025-03-05 17:45:45.491936
81	USD	KWD	0.308547	2025-03-05 17:45:45.491936
82	USD	KYD	0.832083	2025-03-05 17:45:45.491936
83	USD	KZT	496.105907	2025-03-05 17:45:45.491936
84	USD	LAK	21685	2025-03-05 17:45:45.491936
85	USD	LBP	89550	2025-03-05 17:45:45.491936
86	USD	LKR	294.928582	2025-03-05 17:45:45.491936
87	USD	LRD	198.600003	2025-03-05 17:45:45.491936
88	USD	LSL	18.39384	2025-03-05 17:45:45.491936
89	USD	LYD	4.885	2025-03-05 17:45:45.491936
90	USD	MAD	9.803403	2025-03-05 17:45:45.491936
91	USD	MDL	18.458399	2025-03-05 17:45:45.491936
92	USD	MGA	4725	2025-03-05 17:45:45.491936
93	USD	MKD	57.508873	2025-03-05 17:45:45.491936
94	USD	MMK	2098	2025-03-05 17:45:45.491936
95	USD	MNT	3398	2025-03-05 17:45:45.491936
96	USD	MOP	7.993623	2025-03-05 17:45:45.491936
97	USD	MRU	39.965	2025-03-05 17:45:45.491936
98	USD	MUR	45.999999	2025-03-05 17:45:45.491936
99	USD	MVR	15.41	2025-03-05 17:45:45.491936
100	USD	MWK	1733.5	2025-03-05 17:45:45.491936
101	USD	MXN	20.38744	2025-03-05 17:45:45.491936
102	USD	MYR	4.4295	2025-03-05 17:45:45.491936
103	USD	MZN	63.899993	2025-03-05 17:45:45.491936
104	USD	NAD	18.393324	2025-03-05 17:45:45.491936
105	USD	NGN	1501.75	2025-03-05 17:45:45.491936
106	USD	NIO	36.75	2025-03-05 17:45:45.491936
107	USD	NOK	10.960535	2025-03-05 17:45:45.491936
108	USD	NPR	139.180436	2025-03-05 17:45:45.491936
109	USD	NZD	1.753063	2025-03-05 17:45:45.491936
110	USD	OMR	0.38499	2025-03-05 17:45:45.491936
111	USD	PAB	1	2025-03-05 17:45:45.491936
112	USD	PEN	3.664705	2025-03-05 17:45:45.491936
113	USD	PGK	4.0136	2025-03-05 17:45:45.491936
114	USD	PHP	57.177999	2025-03-05 17:45:45.491936
115	USD	PKR	279.8	2025-03-05 17:45:45.491936
116	USD	PLN	3.861284	2025-03-05 17:45:45.491936
117	USD	PYG	7906.689069	2025-03-05 17:45:45.491936
118	USD	QAR	3.6405	2025-03-05 17:45:45.491936
119	USD	RON	4.6226	2025-03-05 17:45:45.491936
120	USD	RSD	108.81	2025-03-05 17:45:45.491936
121	USD	RUB	89.901706	2025-03-05 17:45:45.491936
122	USD	RWF	1402.5	2025-03-05 17:45:45.491936
123	USD	SAR	3.750748	2025-03-05 17:45:45.491936
124	USD	SBD	8.436353	2025-03-05 17:45:45.491936
125	USD	SCR	14.372922	2025-03-05 17:45:45.491936
126	USD	SDG	601	2025-03-05 17:45:45.491936
127	USD	SEK	10.247805	2025-03-05 17:45:45.491936
128	USD	SGD	1.332035	2025-03-05 17:45:45.491936
129	USD	SHP	0.77755	2025-03-05 17:45:45.491936
130	USD	SLL	20969.5	2025-03-05 17:45:45.491936
131	USD	SOS	571.5	2025-03-05 17:45:45.491936
132	USD	SRD	35.7045	2025-03-05 17:45:45.491936
133	USD	SSP	130.26	2025-03-05 17:45:45.491936
134	USD	STD	22281.8	2025-03-05 17:45:45.491936
135	USD	STN	23.45	2025-03-05 17:45:45.491936
136	USD	SVC	8.737324	2025-03-05 17:45:45.491936
137	USD	SYP	13002	2025-03-05 17:45:45.491936
138	USD	SZL	18.380046	2025-03-05 17:45:45.491936
139	USD	THB	33.614	2025-03-05 17:45:45.491936
140	USD	TJS	10.883556	2025-03-05 17:45:45.491936
141	USD	TMT	3.51	2025-03-05 17:45:45.491936
142	USD	TND	3.1795	2025-03-05 17:45:45.491936
143	USD	TOP	2.40776	2025-03-05 17:45:45.491936
144	USD	TRY	36.441062	2025-03-05 17:45:45.491936
145	USD	TTD	6.778092	2025-03-05 17:45:45.491936
146	USD	TWD	32.854502	2025-03-05 17:45:45.491936
147	USD	TZS	2611.121763	2025-03-05 17:45:45.491936
148	USD	UAH	41.299469	2025-03-05 17:45:45.491936
149	USD	UGX	3666.295529	2025-03-05 17:45:45.491936
150	USD	USD	1	2025-03-05 17:45:45.491936
151	USD	UYU	42.545436	2025-03-05 17:45:45.491936
152	USD	UZS	12900	2025-03-05 17:45:45.491936
153	USD	VES	64.406851	2025-03-05 17:45:45.491936
154	USD	VND	25505	2025-03-05 17:45:45.491936
155	USD	VUV	118.722	2025-03-05 17:45:45.491936
156	USD	WST	2.8	2025-03-05 17:45:45.491936
157	USD	XAF	609.223573	2025-03-05 17:45:45.491936
158	USD	XAG	0.03075414	2025-03-05 17:45:45.491936
159	USD	XAU	0.0003421	2025-03-05 17:45:45.491936
160	USD	XCD	2.70255	2025-03-05 17:45:45.491936
161	USD	XDR	0.762797	2025-03-05 17:45:45.491936
162	USD	XOF	609.223573	2025-03-05 17:45:45.491936
163	USD	XPD	0.00106282	2025-03-05 17:45:45.491936
164	USD	XPF	110.829994	2025-03-05 17:45:45.491936
165	USD	XPT	0.00103009	2025-03-05 17:45:45.491936
166	USD	YER	246.85007	2025-03-05 17:45:45.491936
167	USD	ZAR	18.35397	2025-03-05 17:45:45.491936
168	USD	ZMW	28.631804	2025-03-05 17:45:45.491936
169	USD	ZWL	322	2025-03-05 17:45:45.491936
\.


--
-- Data for Name: investment; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.investment (id, idaccount, type, initialamount, profitability, startdate, state) FROM stdin;
\.


--
-- Data for Name: kuentecouser; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.kuentecouser (id, email, password, registerdate, account) FROM stdin;
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.notification (id, idaccount, datesend, content) FROM stdin;
\.


--
-- Data for Name: paymenthistory; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.paymenthistory (id, idpaysubscription, details) FROM stdin;
\.


--
-- Data for Name: paysubscription; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.paysubscription (id, idsubscription, amount, paydate, paymethod) FROM stdin;
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.subscription (id, idaccount, type, startdate, expirationdate, state) FROM stdin;
\.


--
-- Data for Name: transaction; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.transaction (id, idaccount, idcategory, type, amount, transactiondate, description) FROM stdin;
\.


--
-- Name: jobid_seq; Type: SEQUENCE SET; Schema: cron; Owner: master
--

SELECT pg_catalog.setval('cron.jobid_seq', 5, true);


--
-- Name: runid_seq; Type: SEQUENCE SET; Schema: cron; Owner: master
--

SELECT pg_catalog.setval('cron.runid_seq', 2, true);


--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.account_id_seq', 1, false);


--
-- Name: budget_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.budget_id_seq', 1, false);


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.category_id_seq', 1, false);


--
-- Name: debt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.debt_id_seq', 1, false);


--
-- Name: exchange_rate_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.exchange_rate_logs_id_seq', 3, true);


--
-- Name: exchangerate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.exchangerate_id_seq', 338, true);


--
-- Name: investment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.investment_id_seq', 1, false);


--
-- Name: notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.notification_id_seq', 1, false);


--
-- Name: paymenthistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.paymenthistory_id_seq', 1, false);


--
-- Name: paysubscription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.paysubscription_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.subscription_id_seq', 1, false);


--
-- Name: transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.transaction_id_seq', 1, false);


--
-- Name: exchange_rate_logs exchange_rate_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchange_rate_logs
    ADD CONSTRAINT exchange_rate_logs_pkey PRIMARY KEY (id);


--
-- Name: exchangerate exchangerate_basecurrency_targetcurrency_key; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchangerate
    ADD CONSTRAINT exchangerate_basecurrency_targetcurrency_key UNIQUE (basecurrency, targetcurrency);


--
-- Name: exchangerate exchangerate_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.exchangerate
    ADD CONSTRAINT exchangerate_pkey PRIMARY KEY (id);


--
-- Name: account pk_id_account; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT pk_id_account PRIMARY KEY (id);


--
-- Name: budget pk_id_budget; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT pk_id_budget PRIMARY KEY (id);


--
-- Name: debt pk_id_debt; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT pk_id_debt PRIMARY KEY (id);


--
-- Name: investment pk_id_investment; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.investment
    ADD CONSTRAINT pk_id_investment PRIMARY KEY (id);


--
-- Name: notification pk_id_notification; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT pk_id_notification PRIMARY KEY (id);


--
-- Name: paymenthistory pk_id_paymenthistory; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.paymenthistory
    ADD CONSTRAINT pk_id_paymenthistory PRIMARY KEY (id);


--
-- Name: paysubscription pk_id_paysubscription; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.paysubscription
    ADD CONSTRAINT pk_id_paysubscription PRIMARY KEY (id);


--
-- Name: subscription pk_id_subscription; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT pk_id_subscription PRIMARY KEY (id);


--
-- Name: transaction pk_id_transaction; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT pk_id_transaction PRIMARY KEY (id);


--
-- Name: kuentecouser pk_id_user; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.kuentecouser
    ADD CONSTRAINT pk_id_user PRIMARY KEY (id);


--
-- Name: category pk_idcategory; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT pk_idcategory PRIMARY KEY (id);


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
-- Name: account fk_account_user; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT fk_account_user FOREIGN KEY (iduser) REFERENCES public.kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: budget fk_budget_account; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT fk_budget_account FOREIGN KEY (idaccount) REFERENCES public.account(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: budget fk_budget_category; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT fk_budget_category FOREIGN KEY (idcategory) REFERENCES public.category(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: category fk_category_account; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT fk_category_account FOREIGN KEY (idaccount) REFERENCES public.account(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: debt fk_debt_account; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT fk_debt_account FOREIGN KEY (idaccount) REFERENCES public.account(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: investment fk_investment_account; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.investment
    ADD CONSTRAINT fk_investment_account FOREIGN KEY (idaccount) REFERENCES public.account(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: notification fk_notification_account; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT fk_notification_account FOREIGN KEY (idaccount) REFERENCES public.account(id) ON UPDATE RESTRICT;


--
-- Name: paymenthistory fk_paymenthistory_paysubscription; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.paymenthistory
    ADD CONSTRAINT fk_paymenthistory_paysubscription FOREIGN KEY (idpaysubscription) REFERENCES public.paysubscription(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: paysubscription fk_paysubscription_subscription; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.paysubscription
    ADD CONSTRAINT fk_paysubscription_subscription FOREIGN KEY (idsubscription) REFERENCES public.subscription(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: subscription fk_subscription_account; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT fk_subscription_account FOREIGN KEY (idaccount) REFERENCES public.account(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: transaction fk_transaction_account; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fk_transaction_account FOREIGN KEY (idaccount) REFERENCES public.account(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: transaction fk_transaction_category; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT fk_transaction_category FOREIGN KEY (idcategory) REFERENCES public.category(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

