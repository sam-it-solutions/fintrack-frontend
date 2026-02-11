--
-- PostgreSQL database dump
--

\restrict OyceqMIC7HuSjpNMKqsD21PgMAAHKxleqzqRgz5fbswhLw69flJU4OSkyO5QDhW

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
-- Dumped by pg_dump version 18.1

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_transactions (
    id uuid NOT NULL,
    amount numeric(19,4) NOT NULL,
    booking_date date,
    category character varying(255),
    created_at timestamp(6) with time zone NOT NULL,
    currency character varying(255) NOT NULL,
    description character varying(255),
    direction character varying(255) NOT NULL,
    external_id character varying(255),
    value_date date,
    account_id uuid NOT NULL,
    merchant_name character varying(255),
    provider_transaction_id character varying(255),
    status character varying(255),
    transaction_type character varying(255),
    category_confidence numeric(5,2),
    category_reason character varying(255),
    category_source character varying(255),
    counterparty_iban character varying(64),
    CONSTRAINT account_transactions_direction_check CHECK (((direction)::text = ANY ((ARRAY['IN'::character varying, 'OUT'::character varying])::text[])))
);


--
-- Name: category_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_overrides (
    id uuid NOT NULL,
    category character varying(255) NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    match_type character varying(255) NOT NULL,
    match_value character varying(255) NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    user_id uuid NOT NULL,
    match_mode character varying(20) DEFAULT 'CONTAINS'::character varying NOT NULL,
    CONSTRAINT category_overrides_match_type_check CHECK (((match_type)::text = ANY ((ARRAY['IBAN'::character varying, 'MERCHANT'::character varying, 'DESCRIPTION'::character varying])::text[])))
);


--
-- Name: connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.connections (
    id uuid NOT NULL,
    auto_sync_enabled boolean NOT NULL,
    created_at timestamp(6) with time zone,
    display_name character varying(255) NOT NULL,
    encrypted_config text,
    error_message text,
    external_id character varying(255),
    last_synced_at timestamp(6) with time zone,
    provider_id character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    updated_at timestamp(6) with time zone,
    user_id uuid NOT NULL,
    CONSTRAINT connections_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'ACTIVE'::character varying, 'ERROR'::character varying, 'DISABLED'::character varying])::text[]))),
    CONSTRAINT connections_type_check CHECK (((type)::text = ANY ((ARRAY['BANK'::character varying, 'CRYPTO'::character varying, 'INVESTMENT'::character varying])::text[])))
);


--
-- Name: financial_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.financial_accounts (
    id uuid NOT NULL,
    currency character varying(255) NOT NULL,
    current_balance numeric(19,4),
    external_id character varying(255),
    last_synced_at timestamp(6) with time zone,
    name character varying(255) NOT NULL,
    provider character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    connection_id uuid,
    user_id uuid NOT NULL,
    current_fiat_value numeric(19,4),
    fiat_currency character varying(255),
    account_number character varying(255),
    iban character varying(255),
    household_id uuid,
    label character varying(255),
    opening_balance numeric(19,4),
    CONSTRAINT financial_accounts_type_check CHECK (((type)::text = ANY ((ARRAY['BANK'::character varying, 'CRYPTO'::character varying])::text[])))
);


--
-- Name: household_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.household_members (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    role character varying(255) NOT NULL,
    household_id uuid NOT NULL,
    user_id uuid NOT NULL,
    CONSTRAINT household_members_role_check CHECK (((role)::text = ANY ((ARRAY['OWNER'::character varying, 'MEMBER'::character varying])::text[])))
);


--
-- Name: households; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.households (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    invite_code character varying(255) NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: passkey_challenges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passkey_challenges (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    options_json oid NOT NULL,
    challenge_type character varying(32) NOT NULL,
    user_id uuid
);


--
-- Name: passkey_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passkey_credentials (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    credential_id character varying(512) NOT NULL,
    last_used_at timestamp(6) with time zone,
    public_key_cose oid NOT NULL,
    signature_count bigint NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: savings_goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.savings_goals (
    id uuid NOT NULL,
    auto_enabled boolean NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    currency character varying(255) NOT NULL,
    current_amount numeric(19,4),
    last_applied_month character varying(255),
    monthly_contribution numeric(19,4),
    name character varying(255) NOT NULL,
    target_amount numeric(19,4) NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: transaction_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_categories (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    name character varying(80) NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL
);


--
-- Data for Name: account_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account_transactions (id, amount, booking_date, category, created_at, currency, description, direction, external_id, value_date, account_id, merchant_name, provider_transaction_id, status, transaction_type, category_confidence, category_reason, category_source, counterparty_iban) FROM stdin;
21c3a007-81a8-4506-bb01-36d03337a9c6	1.3900	2026-02-09	Inkomen	2026-02-10 17:15:58.555217+00	EUR	\N	IN	j211t	2026-02-07	0ce9b9e2-ac38-4607-a3ee-70b5c96275d3	\N	\N	BOOK	\N	0.90	Inkomende transactie	rule	\N
c1ea8c49-f0a1-41a7-a692-cfa3848075fc	5.2600	2026-02-09	Inkomen	2026-02-10 17:15:58.569187+00	EUR	\N	IN	skbsy	2026-02-07	0ce9b9e2-ac38-4607-a3ee-70b5c96275d3	\N	\N	BOOK	\N	0.90	Inkomende transactie	rule	\N
3ff47039-bdc7-41ec-af8f-5f90a7f67be0	4.7800	2026-02-09	Inkomen	2026-02-10 17:15:58.579784+00	EUR	\N	IN	b6nc8	2026-02-08	0ce9b9e2-ac38-4607-a3ee-70b5c96275d3	\N	\N	BOOK	\N	0.90	Inkomende transactie	rule	\N
ce202832-3fda-47ce-86ec-c9c9069608cf	9.6900	2026-02-09	Inkomen	2026-02-10 17:15:58.588937+00	EUR	\N	IN	sczp6	2026-02-09	0ce9b9e2-ac38-4607-a3ee-70b5c96275d3	\N	\N	BOOK	\N	0.90	Inkomende transactie	rule	\N
f833f6ea-5ef2-48bc-b0c1-2b6d63fd203d	9.0300	2026-02-09	Inkomen	2026-02-10 17:15:58.59859+00	EUR	\N	IN	1yjyh	2026-02-09	0ce9b9e2-ac38-4607-a3ee-70b5c96275d3	\N	\N	BOOK	\N	0.90	Inkomende transactie	rule	\N
11b89d2e-db5e-4d30-a048-d896b92720f7	150.0000	2026-01-06	Inkomen	2026-02-10 18:06:25.961921+00	EUR	HANNE LIETEN	IN	C6A06SRA003E70BP	2026-01-06	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGCTSRCR	0.90	Inkomende transactie	rule	\N
30a140cd-cb1b-4de0-b090-1c57b22ad450	4.0000	2026-01-02	Inkomen	2026-02-10 18:06:25.964791+00	EUR	SPORT VLAADEREN        HASSELT	IN	C6A02AG0R10002ES	2026-01-02	d9cd3b8e-724b-41dc-b065-a5561a6af21f	SPORT VLAADEREN        HASSELT	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
50bcc28e-6dea-4320-9330-ac45fb5a0013	3.6000	2026-01-02	Inkomen	2026-02-10 18:06:25.968044+00	EUR	Blauwe Boulevard       HASSELT	IN	C6A02AG0PY000124	2026-01-02	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Blauwe Boulevard       HASSELT	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
78d26035-c05d-48b2-bc91-d43aa0d78e77	0.1500	2025-12-31	Inkomen	2026-02-10 18:06:25.971203+00	EUR	\N	IN	C5L31INXV72YW25A	2026-01-01	d9cd3b8e-724b-41dc-b065-a5561a6af21f	\N	\N	BOOK	INGLOBAL	0.90	Inkomende transactie	rule	\N
bc076f9d-4594-46e8-ae10-01a941123cc3	1.5000	2025-12-29	Inkomen	2026-02-10 18:06:25.974014+00	EUR	Blauwe Boulevard       HASSELT	IN	C5L29AG15X0000BJ	2025-12-29	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Blauwe Boulevard       HASSELT	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
959795e8-fc16-4e9c-a3b6-f0d41407f4c6	36.4000	2025-12-29	Inkomen	2026-02-10 18:06:25.976992+00	EUR	SWEET COFFEE QUARTIER  HASSELT	IN	C5L29AG15V0000E7	2025-12-29	d9cd3b8e-724b-41dc-b065-a5561a6af21f	SWEET COFFEE QUARTIER  HASSELT	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
df2bf2e4-d472-4434-b6e1-81a90de86c65	271.7000	2025-12-29	Inkomen	2026-02-10 18:06:25.97997+00	EUR	Hotel on Booking.com   AMSTERDAM	IN	C5L29AG08N00007Z	2025-12-29	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Hotel on Booking.com   AMSTERDAM	\N	BOOK	NCCADBEC	0.90	Inkomende transactie	rule	\N
644007a0-e323-4915-954a-f1a2b01243f0	60.0000	2025-12-23	Inkomen	2026-02-10 18:06:25.983039+00	EUR	Cadeaubon embr	IN	C5L23PGTC37M70NR	2025-12-23	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Sam Poelmans	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
76fc260f-ef8c-4ef9-94e8-6ecd7e5d6883	36.0000	2025-12-22	Inkomen	2026-02-10 18:06:25.986346+00	EUR	Koersel kerst	IN	C5L22PGKKT1D8FZV	2025-12-22	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
5f454a00-ace6-48eb-8cd6-c4ceac70b1be	55.0000	2025-12-11	Inkomen	2026-02-10 18:06:25.989485+00	EUR	Knokke	IN	C5L11XKBS787K43J	2025-12-11	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Poelmans Sam	\N	BOOK	PGIPSTCR	0.90	Inkomende transactie	rule	\N
8eb685da-e193-4a4e-b2d4-0692574e5b4e	4.3200	2025-12-10	Inkomen	2026-02-10 18:06:25.992671+00	EUR	BVBA AD KOERSEL        KOERSEL	IN	C5L10AG0A300035I	2025-12-10	d9cd3b8e-724b-41dc-b065-a5561a6af21f	BVBA AD KOERSEL        KOERSEL	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
557fbaa7-c0f1-4e32-9165-9199c8912e37	150.0000	2025-12-08	Inkomen	2026-02-10 18:06:25.995739+00	EUR	HANNE LIETEN	IN	C5L08SRA00LF80GY	2025-12-08	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGCTSRCR	0.90	Inkomende transactie	rule	\N
7d6ea18a-d9b6-4b5a-a704-1e49f5014e7e	6.0000	2025-12-08	Inkomen	2026-02-10 18:06:25.998499+00	EUR	Blauwe Boulevard       HASSELT	IN	C5L08AG0QP0000I7	2025-12-08	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Blauwe Boulevard       HASSELT	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
916a24da-1871-4194-b711-f2629e4aa45b	9.2000	2025-12-08	Inkomen	2026-02-10 18:06:26.001377+00	EUR	sr-El Bocado Hasselt G HASSELT	IN	C5L08AG0PU00007W	2025-12-08	d9cd3b8e-724b-41dc-b065-a5561a6af21f	sr-El Bocado Hasselt G HASSELT	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
3740297c-6673-4d3b-9b5e-7e83c4024b65	12.0000	2025-12-08	Inkomen	2026-02-10 18:06:26.004814+00	EUR	Tennis	IN	C5L08PGPNH1DZUFG	2025-12-07	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
3debc42b-099f-4491-baad-35b5d7d1dec0	346.0000	2025-12-08	Inkomen	2026-02-10 18:06:26.007948+00	EUR	Zeetje met poelies	IN	C5L08PGCL419A96D	2025-12-06	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Poelmans Sam	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
c74d12d4-2c10-4b78-b432-41bf5d2067ca	17.5700	2025-12-08	Inkomen	2026-02-10 18:06:26.01059+00	EUR	VAN ZON INKOOPCENTRA   BERINGEN	IN	C5L08AG09D000286	2025-12-08	d9cd3b8e-724b-41dc-b065-a5561a6af21f	VAN ZON INKOOPCENTRA   BERINGEN	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
ee4377c0-e332-455d-80af-6e2188dd2733	150.0000	2025-12-05	Inkomen	2026-02-10 18:06:26.013168+00	EUR	Poelmans Sam	IN	C5L05XM02W001923	2025-12-05	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Poelmans Sam	\N	BOOK	PGCTSTCR	0.90	Inkomende transactie	rule	\N
ab5e6572-ee4d-4f2a-a77d-9872c6bf27e2	19.2000	2025-11-24	Inkomen	2026-02-10 18:06:26.016202+00	EUR	Toneel	IN	C5K24PGFR71TJ9F3	2025-11-24	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
c738bca7-9437-43d2-a33f-9f08de2630c0	15.6500	2025-11-17	Inkomen	2026-02-10 18:06:26.018991+00	EUR	VATHY BVBA             Beringen	IN	C5K17AG09N0000ZT	2025-11-17	d9cd3b8e-724b-41dc-b065-a5561a6af21f	VATHY BVBA             Beringen	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
b02fad2d-2283-42ff-8f11-86cb06a5db51	150.0000	2026-02-04	Transfer	2026-02-10 17:56:48.404265+00	EUR	DOORLOPENDE BETALINGSOPDRACHT 18114559 NAAR           BE74 9734 5105 7007 Poelmans - Lieten                 REF. : 0800723013354 VAL. 04-02                       	OUT	EUR_3945	2026-02-04	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans - Lieten	\N	BOOK	\N	0.92	Eigen rekening	rule	BE74973451057007
b7238c79-71d2-4a2b-ae87-eb7496a68dbe	500.0000	2026-02-03	Transfer	2026-02-10 17:56:48.411924+00	EUR	STORTING VAN BE80 0835 3027 7377 Poelmans Sam         REF. : 0905404123048 VAL. 03-02                       	IN	EUR_3943	2026-02-03	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans Sam	\N	BOOK	\N	0.92	Eigen rekening	rule	BE80083530277377
71d90823-6ad4-4455-a304-a6c45310b4f1	1000.0000	2026-02-03	Transfer	2026-02-10 17:56:48.419391+00	EUR	STORTING VAN BE80 0835 3027 7377 Poelmans Sam         REF. : 0905419723066 VAL. 03-02                       	IN	EUR_3941	2026-02-03	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans Sam	\N	BOOK	\N	0.92	Eigen rekening	rule	BE80083530277377
8446175f-80e5-420d-8711-c3615bbb0a2d	15.5000	2026-02-05	Inkomen	2026-02-10 17:56:48.372926+00	EUR	GELD ONTVANGEN VIA UW MOBILE BANKING APP OP 05/02/2026OP UW BETAALREKENING BE06 0635 0305 0422              REF. : 0905483325411 VAL. 05-02                       	IN	EUR_3952	2026-02-05	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	JORISSEN WIETSE	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE31777592949255
c58dc35a-2c2f-4d75-8b2d-f7d54c862e5a	56.8700	2026-01-12	Inkomen	2026-02-10 17:56:48.522798+00	EUR	INSTANT STORTING VAN BE33 7310 4316 2446 EYWA BV      tanken NAAR BE06 0635 0305 0422 Sam Poelmans          REF. : 080G71C121125 VAL. 12-01                        | tanken	IN	EUR_3920	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	EYWA BV	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE33731043162446
3e487c1e-37f0-4cdf-a6cb-dc8e8b82d888	20.0000	2026-01-12	Inkomen	2026-02-10 17:56:48.531059+00	EUR	INSTANT STORTING VAN BE90 9733 7436 1632 TOM SOEFFERS NAAR BE06 0635 0305 0422 Sam Poelmans                 REF. : 080G71B175453 VAL. 11-01                       	IN	EUR_3918	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	TOM SOEFFERS	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE90973374361632
0ae79117-e6aa-4996-b237-6fa52d6970bc	500.0000	2026-01-07	Transfer	2026-02-10 17:56:48.558976+00	EUR	STORTING VAN BE80 0835 3027 7377 Poelmans Sam         REF. : 0905479616910 VAL. 06-01                       	IN	EUR_3911	2026-01-07	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans Sam	\N	BOOK	\N	0.92	Eigen rekening	rule	BE80083530277377
7490c72d-a492-470d-bd27-50b07ec5169a	1000.0000	2026-02-06	Transfer	2026-02-10 17:56:48.36801+00	EUR	STORTING VAN BE80 0835 3027 7377 Poelmans Sam         REF. : 0905467025A39 VAL. 05-02                       	IN	EUR_3953	2026-02-06	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans Sam	\N	BOOK	\N	0.92	Eigen rekening	rule	BE80083530277377
87a6ac54-e6aa-413f-89d5-1f515ae6965b	45.0000	2026-02-06	Inkomen	2026-02-10 18:06:25.916776+00	EUR	Tennis	IN	C6B06PGMHX4AQ230	2026-02-06	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
91779410-6d09-45d0-972f-840959a24b6f	2.6000	2026-02-02	Inkomen	2026-02-10 18:06:25.934518+00	EUR	Viandelkullekes	IN	C6B02PGVK92828KI	2026-02-02	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Bente Poelmans	\N	BOOK	PGCTSTDB	0.90	Inkomende transactie	rule	\N
e5af0b12-1e29-480f-9dc3-6c105c195aac	14.5400	2026-01-19	Inkomen	2026-02-10 18:06:25.937802+00	EUR	CARREFOUR KNOKKE 17-01-2026 10:24 KNOKKE BE524784XXXXXX4307	IN	C6A19XN0DD000J79	2026-01-19	d9cd3b8e-724b-41dc-b065-a5561a6af21f	CARREFOUR KNOKKE	\N	BOOK	NCMCDBCM	0.90	Inkomende transactie	rule	\N
0ce4ac14-dcac-4596-a14d-adfc1ce0b626	10.8000	2026-01-19	Inkomen	2026-02-10 18:06:25.947154+00	EUR	LS bv falstaff         KNOKKE-HEIST	IN	C6A19AG0AQ0002YV	2026-01-19	d9cd3b8e-724b-41dc-b065-a5561a6af21f	LS bv falstaff         KNOKKE-HEIST	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
11eb319b-948d-49c1-81d2-f0d3455381ae	30.0000	2026-01-08	Inkomen	2026-02-10 18:06:25.955903+00	EUR	Cadeau rik	IN	C6A08PGVV50LWF1F	2026-01-08	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
43757215-8b7c-4637-bee4-1fade1f81059	0.0100	2026-02-10	Overig	2026-02-10 17:56:43.82291+00	EUR	INSTANT OVERSCHRIJVING BELFIUS MOBILE NAAR            BE38 9670 1889 6572 GoCardless Ltd GCPGNTQ            REF. : 090544792A289 VAL. 10-02                        | GCPGNTQ	OUT	EUR_205	2026-02-10	1fe953cf-4b83-4309-b479-ae04460a06b8	GoCardless Ltd	\N	BOOK	\N	0.40	Geen match	rule	BE38967018896572
23c49b14-494a-4097-a4f7-7dde9040c338	300.0000	2026-02-03	Inkomen	2026-02-10 17:56:43.860154+00	EUR	STORTING VAN BE15 0015 6080 0930 LEMMENS ENGINEERING  BV 202518 NAAR BE24 0637 5928 7238 Poelmans, Sam      REF. : 803174045 VAL. 03-02                            | 202518	IN	EUR_202	2026-02-03	1fe953cf-4b83-4309-b479-ae04460a06b8	LEMMENS ENGINEERING BV	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE15001560800930
ed878b76-51d1-4d8f-a479-001c23a3f991	790.0000	2026-01-09	Inkomen	2026-02-10 17:56:43.868895+00	EUR	INSTANT STORTING VAN BE31 7351 0660 0055 TANDEM VZW   202515 NAAR BE24 0637 5928 7238 SAM IT SOLUTIONS      REF. : 080G719068747 VAL. 09-01                        | 202515	IN	EUR_201	2026-01-09	1fe953cf-4b83-4309-b479-ae04460a06b8	TANDEM VZW	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE31735106600055
bc455718-8068-440e-aab2-ef1e7338feca	275.0000	2025-11-21	Inkomen	2026-02-10 17:56:43.914176+00	EUR	INSTANT STORTING VAN BE30 4581 0646 0111 LOENDERS     PASCALE 202517 NAAR BE24 0637 5928 7238 SAM IT        SOLUTIONS                                             REF. : 080G7BL221340 VAL. 21-11                        | 202517	IN	EUR_194	2025-11-21	1fe953cf-4b83-4309-b479-ae04460a06b8	LOENDERS PASCALE	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE30458106460111
4a083270-9d4a-4999-95ba-415ca869f52d	11.5000	2026-02-05	Inkomen	2026-02-10 17:56:48.377352+00	EUR	STORTING VIA WERO VAN BE63 0020 0430 2108 MENTENS LIAMWero Sam Poelmans REF. :                              8d69041fa03c4e47b05a98fa3b0e7137 NAAR                 BE06 0635 0305 0422 Sam Poelmans                      REF. : 080G725226696 VAL. 05-02        	IN	EUR_3951	2026-02-05	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	MENTENS LIAM	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE63002004302108
1beb1636-c292-4924-9e28-a45f461441ad	2522.8300	2026-02-04	Inkomen	2026-02-10 17:56:48.400245+00	EUR	STORTING VAN BE33 7310 4316 2446 EYWA BV /A/ BETALING LOON REF. : 1374425-1-13 NAAR BE06 0635 0305 0422     POELMANS SAM                                          REF. : 805121906 VAL. 04-02                            | /A/ BETALING LOON	IN	EUR_3946	2026-02-04	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	EYWA BV	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE33731043162446
8ccf66bb-5df9-41a8-acf4-b5fe65be6c28	20.0000	2026-01-12	Inkomen	2026-02-10 17:56:48.54291+00	EUR	INSTANT STORTING VAN BE56 0635 3988 7988 Goris Stef   NAAR BE06 0635 0305 0422 Sam Poelmans                 REF. : 090548561A517 VAL. 10-01                       	IN	EUR_3915	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Goris Stef	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE56063539887988
c66554e0-ed07-4674-b44d-f21595a5e0b9	150.0000	2026-02-06	Inkomen	2026-02-10 18:06:25.924133+00	EUR	HANNE LIETEN	IN	C6B06SRA003F90PZ	2026-02-06	d9cd3b8e-724b-41dc-b065-a5561a6af21f	HANNE LIETEN	\N	BOOK	PGCTSRCR	0.90	Inkomende transactie	rule	\N
c9b68f08-2cd2-4df7-ae09-d21249416b22	200.0000	2026-02-10	Inkomen	2026-02-10 12:58:45.179704+00	EUR	Virement	IN	c6041db1dd6e4bd0b8a446e7a255f885	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
9a2ce1fd-d3ef-42ed-82c7-251adf360909	200.0000	2026-01-10	Inkomen	2026-02-10 12:58:45.198113+00	EUR	Virement	IN	a3c6056191be44a3a26209659d213593	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
c39b1ed5-772e-4a72-900d-2c9b9203c62a	200.0000	2025-12-10	Inkomen	2026-02-10 12:58:45.204367+00	EUR	Virement	IN	8cfdc137dc354be6913e91b29af4ea4d	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
8e75287d-5efb-40e5-9376-c64d099c71c1	200.0000	2025-11-10	Inkomen	2026-02-10 12:58:45.20963+00	EUR	Virement	IN	b7c938b8e2a74ff087a4815f2b4eed79	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
7ccea996-6d77-477f-8a26-14a3a9395cbc	200.0000	2025-10-10	Inkomen	2026-02-10 12:58:45.217397+00	EUR	Virement	IN	07860272655c4427be2af5d465747088	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
d947adde-5732-48f1-be69-54466446082a	200.0000	2025-09-10	Inkomen	2026-02-10 12:58:45.222936+00	EUR	Virement	IN	0a50f1c836914c328a07896dee0e23ad	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
8da9de99-47a0-4c5e-b9b5-6a0be2ee2b10	200.0000	2025-08-10	Inkomen	2026-02-10 12:58:45.228802+00	EUR	Virement	IN	102db0cbf4cb4da08bc6d4fa180cbb5d	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
47ee183d-e620-4009-bbae-a8f271aca268	200.0000	2025-07-10	Inkomen	2026-02-10 12:58:45.235186+00	EUR	Virement	IN	bc9faee517bc45bd9225d4728565077a	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
09063f8b-438a-4a1e-85e9-253c3519a4f6	200.0000	2025-06-10	Inkomen	2026-02-10 12:58:45.242654+00	EUR	Virement	IN	55eb42ad42844e10afc9753c90de8fcc	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
8065abfd-62f9-491a-a647-e5e8c36bbd83	200.0000	2025-05-10	Inkomen	2026-02-10 12:58:45.248474+00	EUR	Virement	IN	550a433380f340fbaa3fd20f64f58c86	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
bdd046fd-646a-4f8b-96b8-3000ffc9cf2e	200.0000	2025-04-10	Inkomen	2026-02-10 12:58:45.253571+00	EUR	Virement	IN	813e848782244869b9e648a8c614be31	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
270b665b-5611-4976-9e32-c5445417f0c2	200.0000	2025-03-10	Inkomen	2026-02-10 12:58:45.257577+00	EUR	Virement	IN	ed4d638eaaa94cbda9731e4702822e4b	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
0202820f-59ea-41e0-99ae-fcd9c5856ebb	200.0000	2025-02-10	Inkomen	2026-02-10 12:58:45.2626+00	EUR	Virement	IN	d65ef4b4bab14328b62768b2eac9b682	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
fadc1a75-5c66-43b1-a2c1-6b4b0ce70b0f	200.0000	2025-01-10	Inkomen	2026-02-10 12:58:45.268402+00	EUR	Virement	IN	e5d5f418fba247d3bc63f35bdb1d9381	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
51ebc417-9dc3-424b-b235-3da1dcaf07e5	200.0000	2024-12-10	Inkomen	2026-02-10 12:58:45.272912+00	EUR	Virement	IN	5dab33059aea4f92bdb27eed3f3acf15	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
75c988a1-ed62-461c-bcaf-8fe8c4822d64	200.0000	2024-11-10	Inkomen	2026-02-10 12:58:45.277544+00	EUR	Virement	IN	29b94108d23b4a9b9af46e26af550c7f	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
b6ec4878-4be8-49a8-8f08-14e7a43b23df	200.0000	2024-10-10	Inkomen	2026-02-10 12:58:45.282412+00	EUR	Virement	IN	a1d19dcd92a14c1cae72ed6cc87ac8fb	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
59afc6ba-3e9f-4d39-b911-730e198316d8	200.0000	2024-09-10	Inkomen	2026-02-10 12:58:45.28719+00	EUR	Virement	IN	346d2470b26b40eba334648b03577c88	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
19bc38ff-87d2-4e64-8b75-809def2fc712	200.0000	2024-08-10	Inkomen	2026-02-10 12:58:45.292681+00	EUR	Virement	IN	e605224cd85e4d3484829979244e3381	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
78ceb203-9121-454c-890e-23d31d95d124	200.0000	2024-07-10	Inkomen	2026-02-10 12:58:45.298832+00	EUR	Virement	IN	f10f32b3a814406a84a2f7f14192a753	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
90f9fd23-0980-411e-b66c-5d6ade3681a0	200.0000	2024-06-10	Inkomen	2026-02-10 12:58:45.304408+00	EUR	Virement	IN	b69385742b2d47c1aa3de73af592972f	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
352c0a86-8d66-4d37-920c-4aac1b2d4812	200.0000	2024-05-10	Inkomen	2026-02-10 12:58:45.30982+00	EUR	Virement	IN	cf535580f3c14700aeb00a5faa6a7e92	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
1808c87c-0980-4a6a-92e2-1e343e28ddcc	200.0000	2024-04-10	Inkomen	2026-02-10 12:58:45.316092+00	EUR	Virement	IN	be0c869fa18e4eb3ba0c348b50e2d55a	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
5cbbf3ce-b504-446c-940e-447af8a63fa7	200.0000	2024-03-10	Inkomen	2026-02-10 12:58:45.321512+00	EUR	Virement	IN	1a98dc335a6b4609a9e02bb6c2841bbf	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
10f12b6a-1205-4652-b804-7de01a8f1f09	200.0000	2024-02-10	Inkomen	2026-02-10 12:58:45.326471+00	EUR	Virement	IN	22e65f39d2fd4cd3999f0e6b12e132fd	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
f6d6c3c0-6d7a-4b7d-b50e-9fb0437d995e	200.0000	2024-01-10	Inkomen	2026-02-10 12:58:45.332634+00	EUR	Virement	IN	afb0f0c3873f42369ead587be7f5af74	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
2d572c90-9ae8-4907-8bc6-0f0fa81fd02f	200.0000	2023-12-10	Inkomen	2026-02-10 12:58:45.337752+00	EUR	Virement	IN	fcb66ea0efd548eb8a6f67b956ec2674	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
19b11472-7895-40e1-8b1d-0c1bdfffe826	200.0000	2023-11-10	Inkomen	2026-02-10 12:58:45.342525+00	EUR	Virement	IN	22a81aa36bcc4296ae1031f807eb64fb	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
77ee95ed-0c12-4244-93f9-50592a29fb54	200.0000	2023-10-10	Inkomen	2026-02-10 12:58:45.348681+00	EUR	Virement	IN	aceb3ef2674646d197d8e20f30171ee4	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
8e5a9228-ac2a-4d98-95ec-8dfc38284493	200.0000	2023-09-10	Inkomen	2026-02-10 12:58:45.353003+00	EUR	Virement	IN	f900d17fd5ff4a888bbe9259b70e43c0	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
da842834-5451-40ef-956e-60fdcfada7dc	200.0000	2023-08-10	Inkomen	2026-02-10 12:58:45.35692+00	EUR	Virement	IN	3b8e9002ff2b46c79869ef4a892e07cd	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
3dfa903b-e988-446b-8e7a-ab5fba1536bc	200.0000	2023-07-10	Inkomen	2026-02-10 12:58:45.362373+00	EUR	Virement	IN	a0a7ab963cfc48dd9715c909ce9c6a6b	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
2fb76cd7-4681-4645-93ee-fccf546faa28	200.0000	2023-06-10	Inkomen	2026-02-10 12:58:45.369045+00	EUR	Virement	IN	8338c94fcad844548916be1552b2555d	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
9e394f72-af08-4dd7-8da9-4f25642ec050	200.0000	2023-05-10	Inkomen	2026-02-10 12:58:45.375528+00	EUR	Virement	IN	5f048d276ab349c4b93e81dc328f6ca9	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
0eb39ba0-ca69-4fea-8f9f-ead4e4fd5dd3	200.0000	2023-04-10	Inkomen	2026-02-10 12:58:45.380836+00	EUR	Virement	IN	a592619fe1b641edba240226a4b63f9d	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
bf951c1c-8391-4d4c-bffa-7ce287c9682e	200.0000	2023-03-10	Inkomen	2026-02-10 12:58:45.386191+00	EUR	Virement	IN	d0c8d4a0b42c43f9b44c8938afa87e8e	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
9fdcc0d3-2560-4ca4-98fb-fe3550782c01	200.0000	2023-02-10	Inkomen	2026-02-10 12:58:45.392993+00	EUR	Virement	IN	9a392d3bae4f4945bca5558278cbab05	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
5f25ffc3-ea17-4fd2-8a9f-fc01e9978c49	200.0000	2023-01-10	Inkomen	2026-02-10 12:58:45.399303+00	EUR	Virement	IN	5900f79880654a4ab623e8e668f60a87	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
25a5d4eb-6858-4c3a-b51e-af45195ec485	200.0000	2022-12-10	Inkomen	2026-02-10 12:58:45.406954+00	EUR	Virement	IN	3ae87b50c9bf4b1080d6b426b6599d14	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
a7ab73e7-e8c8-450d-8565-a7829be1feda	200.0000	2022-11-10	Inkomen	2026-02-10 12:58:45.417488+00	EUR	Virement	IN	68ea53daa78b4be682fe5f1a77d0b7d4	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
943ae649-0349-4cf0-bade-14e916384a0c	200.0000	2022-10-10	Inkomen	2026-02-10 12:58:45.423364+00	EUR	Virement	IN	efbf036959b0450d9d1b9f0cd16a787a	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
b5d2bcd1-de82-4158-8509-a7278c8b7f54	200.0000	2022-09-10	Inkomen	2026-02-10 12:58:45.428827+00	EUR	Virement	IN	0ee527cabdf34a319e7f407a4520d31d	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
a1943cee-a54b-47c5-aca2-38dc92b62867	150.0000	2026-02-05	Inkomen	2026-02-10 18:06:25.931497+00	EUR	Poelmans Sam	IN	C6B05XM028000083	2026-02-05	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Poelmans Sam	\N	BOOK	PGCTSTCR	0.90	Inkomende transactie	rule	\N
f0ff66da-1802-484a-b80e-cd5983caf117	200.0000	2022-08-10	Inkomen	2026-02-10 12:58:45.434594+00	EUR	Virement	IN	4f0f9eaa70774c25a49b1ea7ab69bee4	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
6497c144-12f4-48b3-a25d-69b95a411344	200.0000	2022-07-10	Inkomen	2026-02-10 12:58:45.439365+00	EUR	Virement	IN	8660c768f54246439b4b086c628fe3ba	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
dc36ae3e-657d-4da6-8d53-7c8e423f992c	200.0000	2022-06-10	Inkomen	2026-02-10 12:58:45.444385+00	EUR	Virement	IN	73a9d7c6754442279da4308913ac338b	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
067d4e46-e6bf-4f57-bd60-a5452981070a	200.0000	2022-05-10	Inkomen	2026-02-10 12:58:45.449342+00	EUR	Virement	IN	571abc4d24c24bd3a3d6eb0b9719a3d0	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
e1b5e12f-057f-4d24-9642-956290fb9803	200.0000	2022-04-10	Inkomen	2026-02-10 12:58:45.454762+00	EUR	Virement	IN	1353d04e2c064e1dbb8b943763fc9d3a	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
40450144-22ef-4f0d-bf1e-0fc6143e4c87	200.0000	2022-03-10	Inkomen	2026-02-10 12:58:45.461109+00	EUR	Virement	IN	2a6c4723b90244809d2e0844363b4d0f	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
b0bc074f-3e25-43d0-98d7-6f1f2454d1c8	200.0000	2022-02-10	Inkomen	2026-02-10 12:58:45.468916+00	EUR	Virement	IN	dae23ca9eade4f94829364c7d364fd3c	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
ec9bf783-5287-4820-842f-273fe40494cf	200.0000	2022-01-10	Inkomen	2026-02-10 12:58:45.475226+00	EUR	Virement	IN	8569ebf4486441f9b1552ae3bee05cbe	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
9b6af75c-f2aa-41b8-b621-235c01d82c9e	200.0000	2021-12-10	Inkomen	2026-02-10 12:58:45.481155+00	EUR	Virement	IN	bd8901d36dec4d96a171cfbac0042ffc	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
429d3016-f451-4ad5-afcb-cdb87e8ec1df	200.0000	2021-11-10	Inkomen	2026-02-10 12:58:45.486852+00	EUR	Virement	IN	4d5115d3297342d490a41bef64f0aa08	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
1c6e1d21-f0f8-4fc6-aa82-b9dc091817d0	200.0000	2021-10-10	Inkomen	2026-02-10 12:58:45.490469+00	EUR	Virement	IN	407c2e9aafe34c3ab237e18fcdb45983	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
f82bf43b-dc61-4ccc-b908-8e26e536e8fd	200.0000	2021-09-10	Inkomen	2026-02-10 12:58:45.494777+00	EUR	Virement	IN	cc7897d3ab5540f18761b0c66e75ef36	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
3606720a-dc04-4fa7-94fe-76adeac4c5f1	200.0000	2021-08-10	Inkomen	2026-02-10 12:58:45.49968+00	EUR	Virement	IN	d9aedcca2f7c4415aef825f8e602503a	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
a4bc0f57-7794-47f4-99ae-97850cc6c300	200.0000	2021-07-10	Inkomen	2026-02-10 12:58:45.504971+00	EUR	Virement	IN	1764919d5a4a49dfb1468125ced59345	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
64c2b537-2a06-47bf-b1c6-114a7d8d82af	200.0000	2021-06-10	Inkomen	2026-02-10 12:58:45.512422+00	EUR	Virement	IN	ab910918651446c5bb0036eb7318d32c	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
05e723b6-c73e-44d5-b8df-bdae02de0f52	200.0000	2021-05-10	Inkomen	2026-02-10 12:58:45.519633+00	EUR	Virement	IN	9b6d52bff36148ec81ee3528eb35975f	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
f2db529f-fd87-42af-a2bf-589a1579e169	200.0000	2021-04-10	Inkomen	2026-02-10 12:58:45.524801+00	EUR	Virement	IN	4df2e1e29f2144ccb2111959963c0c21	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
1b42b3aa-b984-4c0f-839a-d0362b3fe1ed	200.0000	2021-03-10	Inkomen	2026-02-10 12:58:45.531266+00	EUR	Virement	IN	30b070b7db774895a15ecbacbbe7dd0e	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
fb679c84-3ebb-430a-b359-ab2548b04842	200.0000	2021-02-10	Inkomen	2026-02-10 12:58:45.536914+00	EUR	Virement	IN	0689a807a0104c95948446afdde8b1ad	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
ab7ee869-7a8c-4968-856c-c5579da65b27	200.0000	2021-01-10	Inkomen	2026-02-10 12:58:45.543096+00	EUR	Virement	IN	8711403b91d24833949d319f2f6e574c	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
e83baa56-6bb3-4a80-be30-8da93f7adbc3	200.0000	2020-12-10	Inkomen	2026-02-10 12:58:45.548247+00	EUR	Virement	IN	51ef0bf65f5e48b18ccd1ef98fdb4006	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
c26a0160-eac6-41bd-a87d-d00d3a130a86	200.0000	2020-11-10	Inkomen	2026-02-10 12:58:45.552402+00	EUR	Virement	IN	99bfd1c958984236969a798d4074d060	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
b89ff4e0-4185-42cb-826d-abbea9d4be65	200.0000	2020-10-10	Inkomen	2026-02-10 12:58:45.557444+00	EUR	Virement	IN	abee9ce7d48a4de490e5ead9314642a8	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
2b2bb2bc-d9bc-4b86-a5df-cbae001d9428	200.0000	2020-09-10	Inkomen	2026-02-10 12:58:45.564635+00	EUR	Virement	IN	c3f3d3da27644933a6505dd264408a7f	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
a980479b-710a-4026-ac27-b829867c780f	200.0000	2020-08-10	Inkomen	2026-02-10 12:58:45.573834+00	EUR	Virement	IN	e4cffe70fe3947499927c25a6dcb3d97	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
009c57e3-e811-481b-b750-150df3890452	200.0000	2020-07-10	Inkomen	2026-02-10 12:58:45.581491+00	EUR	Virement	IN	231c5b9c51844ca98d0bb7f73b52085e	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
b71a71e0-77ff-4e65-b645-2e070fe4aaea	200.0000	2020-06-10	Inkomen	2026-02-10 12:58:45.586851+00	EUR	Virement	IN	e1a56cefd82543c4b731ea39c27476da	\N	1e3fedd8-cdfd-4d95-8a31-1261df0be18a	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
b4012ab5-d6bd-4bb0-bf78-356c5d06d4dd	200.0000	2026-02-10	Overig	2026-02-10 12:58:45.700647+00	EUR	Virement	OUT	6209211fd0524d0f9fd33cf0270d3e26	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
52ad7ac2-ccd9-427b-a7ad-a8f9170b310b	29.9900	2026-02-09	Boodschappen	2026-02-10 12:58:45.706062+00	EUR	Carrefour	OUT	885b66dd7a354bed97b7a349d670143c	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
cf1e4d2d-3530-4351-99ce-2021c99c3f1d	56.9800	2026-02-09	Shopping	2026-02-10 12:58:45.710344+00	EUR	Amazon	OUT	e702f812f27e48a1979d3021ff436aed	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'amazon'	rule	\N
f13d126b-cbad-4604-811b-66264b41752f	27.9000	2026-02-09	Transport	2026-02-10 12:58:45.714468+00	EUR	Sncb	OUT	f6cab2b236d043e7b856bb49fc1e428c	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
485ddb21-7ea9-454f-afc9-18acd7805142	2.4900	2026-02-05	Horeca	2026-02-10 12:58:45.718341+00	EUR	Starbucks	OUT	0063590b664945c8afeec6fa6c9dee1f	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
fdd1114a-25bf-4484-adce-7044789f5452	34.8500	2026-02-05	Overig	2026-02-10 12:58:45.722677+00	EUR	Ag Insurance	OUT	2d3684121c7f4d98b16a5d22cf0c4b0d	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
b2f54472-d63d-4651-bfb6-773e0b0b83c9	8.6800	2026-02-05	Overig	2026-02-10 12:58:45.727576+00	EUR	Hof Van Cleve	OUT	45790fb1eb4e410787d6805487383a29	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
074f9c06-fb74-4ea9-a08d-9518152c1b35	34.8500	2026-02-05	Overig	2026-02-10 12:58:45.732623+00	EUR	Ag Insurance	OUT	cddbae1056654b8dafc372cde8319098	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
2072492d-9f36-4939-9307-f842564b9703	27.6600	2026-02-03	Boodschappen	2026-02-10 12:58:45.73812+00	EUR	Ad Delhaize	OUT	5d10e392282f474b8bd08c79a9c03676	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'delhaize'	rule	\N
7cba5307-194b-4ad8-8cd0-d35120de899c	650.0000	2026-02-03	Overig	2026-02-10 12:58:45.743071+00	EUR	Loyer	OUT	f826d6a5d22f44b9add7fbe9692e8196	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
f0f9d493-1d2a-4621-84fc-f2a86f238851	1887.0300	2026-02-02	Inkomen	2026-02-10 12:58:45.747417+00	EUR	Salaire	IN	1e3ef2d7f7a143b69aceaf8966e012b0	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
d962b4d0-a7d8-47ba-abcb-8eba0a4ef560	29.9900	2026-02-02	Boodschappen	2026-02-10 12:58:45.751851+00	EUR	Carrefour	OUT	5eaed7aa9fad418fae9700d2851668ed	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
dd6292db-90da-4102-9e83-56c513636625	40.0000	2026-02-02	Overig	2026-02-10 12:58:45.756768+00	EUR	Esso	OUT	6664ab1939724c3d9213ec031528294b	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
78915304-55f8-4790-840e-9781a551c52a	27.9000	2026-02-02	Transport	2026-02-10 12:58:45.762071+00	EUR	Sncb	OUT	7ed37c9bfd7d40148f3cd2a60c7dbb01	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
16a6c9dc-88ef-4738-a356-454dd7259b3b	29.9900	2026-02-02	Overig	2026-02-10 12:58:45.767139+00	EUR	Be Optic	OUT	e0222550a1624516bf054fed57af3837	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
af3332df-ddd7-48b7-ac2f-158cdf67f8e2	17.9900	2026-02-01	Horeca	2026-02-10 12:58:45.772014+00	EUR	Kaffabar	OUT	56ed57e3db7a4ebebe0333fb3e26716d	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'bar'	rule	\N
1a3cf579-326f-478d-a1a1-94a74e063d1d	3.7200	2026-02-01	Inkomen	2026-02-10 12:58:45.777564+00	EUR	Versement D'intérêts	IN	a67374ee0e7e420cb32e3f9f861d7dec	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
b8c4fff6-9a7b-4ae5-94ed-763b3a4a8c2d	3.7900	2026-01-30	Overig	2026-02-10 12:58:45.783134+00	EUR	Neuhaus	OUT	ee3b17fd7c7847cb9038226c69e5b786	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
dbd0f35d-20c9-49eb-8630-febfdbd862d8	2.4900	2026-01-29	Horeca	2026-02-10 12:58:45.789537+00	EUR	Starbucks	OUT	b5fa1e36e88441228870532004b43873	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
7f04d966-007d-4bd8-8160-f55a0e3903bf	5.6900	2026-01-28	Overig	2026-02-10 12:58:45.793793+00	EUR	Mcdonalds	OUT	9ed7b1c0711145259a4c777a2e2bd619	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
24f4efc8-7e60-4ba1-9fc3-110d609113ba	23.9900	2026-01-28	Overig	2026-02-10 12:58:45.799184+00	EUR	Orange Belgium	OUT	c7f761fa5ba74592af0077b2ce3dac85	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
224a9f98-104d-47ef-ab9b-a79be9b708d2	27.9000	2026-01-26	Transport	2026-02-10 12:58:45.805806+00	EUR	Sncb	OUT	573ac55364884df899036be0ba535042	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
c0441f39-a8c6-499d-bf2b-0cf4902fda43	34.0000	2026-01-26	Utilities	2026-02-10 12:58:45.817562+00	EUR	Luminus	OUT	5f5fa5faccec454b836e10d232a8c60a	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'luminus'	rule	\N
0d3ab0db-4ce9-4883-b38c-c000b6dc335c	29.9900	2026-01-26	Boodschappen	2026-02-10 12:58:45.826529+00	EUR	Carrefour	OUT	988bce846a91486b8114ce93fdf43a73	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
db3af99f-cea9-4df4-aad4-02e7c8222bb3	97.7100	2026-01-26	Overig	2026-02-10 12:58:45.841254+00	EUR	Décathlon	OUT	c0454bd7bdde43fc8903beb7e073bcc1	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
308523f3-9b73-4332-bf12-886e6065f051	9.7900	2026-01-25	Overig	2026-02-10 12:58:45.854685+00	EUR	Galleria Inno	OUT	775cc09337974ad29fbe2d3a607667a4	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
d1388a5b-f7bc-4c4c-bd58-5535e4fc73c6	23.9900	2026-01-23	Overig	2026-02-10 12:58:45.864792+00	EUR	H&M	OUT	8874a0c3683341f6bdb1c2c4282461f5	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
d7c1438b-d29a-4661-b770-b2bbb0e8e3ff	2.4900	2026-01-22	Horeca	2026-02-10 12:58:45.876157+00	EUR	Starbucks	OUT	84ef5b2614f14aaabea4d7339a98ecc4	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
90cef2b8-1da7-4551-85c9-1b3c68c2cfe2	53.6600	2026-01-22	Overig	2026-02-10 12:58:45.882169+00	EUR	Le Petit Boudoir	OUT	85dc767026c04eeb8d99b08b06576fd2	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
320d92bf-256a-4972-a00a-20da6097899e	8.6800	2026-01-22	Overig	2026-02-10 12:58:45.889603+00	EUR	Hof Van Cleve	OUT	877417a7a40843af8d27d6a9435217d8	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
54b654b7-eeb2-432b-a303-32f115d47534	19.6700	2026-01-20	Overig	2026-02-10 12:58:45.8979+00	EUR	Veepee	OUT	4c7a0547289447deaef26768af15b70a	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
e305bbbf-6c65-471d-a419-b901664868ca	12.9000	2026-01-20	Overig	2026-02-10 12:58:45.910315+00	EUR	Flixbus	OUT	821493e2576245c0a9b4f700c1e7d3b8	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
a037f8a7-7984-4816-96b0-8cfae55a8609	27.9000	2026-01-19	Transport	2026-02-10 12:58:45.927539+00	EUR	Sncb	OUT	11c1cbcf49c445b5bf52daea25f131a4	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
be255c8c-127c-43bd-af4c-cb5c4ff1d2a6	29.9900	2026-01-19	Boodschappen	2026-02-10 12:58:45.938486+00	EUR	Carrefour	OUT	2b86c0e1cadf43c089d1fb3f92326f6b	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
d605623a-583e-4595-bc93-df6b67231be5	24.9600	2026-01-19	Overig	2026-02-10 12:58:45.950322+00	EUR	Le Pecheur Nord	OUT	2f76b8c155a741a690bbacb1c9012369	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
a3ce4a8b-58d7-4660-a31f-ff5e7d648820	40.0000	2026-01-19	Overig	2026-02-10 12:58:45.958481+00	EUR	Esso	OUT	fe6fa4234f964d729ab4e3548f46199e	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
19432e42-c6d6-4d10-aec3-b50ed902db88	13.9900	2026-01-17	Abonnementen	2026-02-10 12:58:45.965033+00	EUR	Spotify	OUT	8673fc6baad944579b55992a110bd4d9	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'spotify'	rule	\N
9b049b05-ec06-4af9-a012-ddfab8327c9d	3.7900	2026-01-17	Overig	2026-02-10 12:58:45.970864+00	EUR	Pharmacie	OUT	ea5cc0063f084aaf9a44ed1670d48839	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
b58c8ea9-3761-47b0-8883-58b4523dad33	129.9900	2026-01-16	Shopping	2026-02-10 12:58:45.975203+00	EUR	Coolblue	OUT	55fb546770ac4f41b1dc860c2e4248a7	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'coolblue'	rule	\N
eb9e9575-f180-4b7c-9b63-a79e4bca88e1	3.7900	2026-01-16	Overig	2026-02-10 12:58:45.98511+00	EUR	Neuhaus	OUT	599976134d5f4db5bf1d568c954be249	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
6c0be74e-c02f-407d-8df7-6a57265ee9bf	2.4900	2026-01-15	Horeca	2026-02-10 12:58:45.994789+00	EUR	Starbucks	OUT	366b068af65c4ff6bfe212988221c827	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
8297b94b-6804-41b3-b984-4be42f43aef7	17.3300	2026-01-15	Boodschappen	2026-02-10 12:58:46.000199+00	EUR	Spar	OUT	954ba7bd2d394467a1582c15279c1980	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'spar'	rule	\N
db99533c-87a3-4022-81eb-38d8c93d4834	15.9900	2026-01-12	Abonnementen	2026-02-10 12:58:46.006954+00	EUR	Netflix	OUT	12305bc1583142b69a391c2af9889221	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'netflix'	rule	\N
f6d7c663-f797-4425-9c10-ddd873860841	22.9900	2026-01-12	Overig	2026-02-10 12:58:46.020591+00	EUR	Tele2 Belgium	OUT	7c2c8cc5318a4e4c8b405afa2fe171d1	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
aabf43d5-6f5c-4305-8dd0-7b013809de62	20.0000	2026-01-12	Overig	2026-02-10 12:58:46.029101+00	EUR	Retrait D'espèces	OUT	82054e62fd5a41cf82ad07577e8bfe3e	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
21598c3f-2d47-4043-88c5-2a862e864657	27.9000	2026-01-12	Transport	2026-02-10 12:58:46.034807+00	EUR	Sncb	OUT	9983cdb532c24f3fb31a6f3852e91b69	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
098ca54c-c22e-46bc-b3d7-9acc3d6b5649	29.9900	2026-01-12	Boodschappen	2026-02-10 12:58:46.040227+00	EUR	Carrefour	OUT	f2c4f2ba32774f8c8c2021532468d795	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
1283f1a0-233e-4680-bf6e-2614471b6ab5	200.0000	2026-01-10	Overig	2026-02-10 12:58:46.046076+00	EUR	Virement	OUT	1b902433694f4426b19ac188a6e162e6	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
f2379321-8e26-4aed-8f79-53ff734d9e27	56.9800	2026-01-09	Shopping	2026-02-10 12:58:46.051764+00	EUR	Amazon	OUT	e651f4de89a74bc3a5f55593d3fdbf5f	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'amazon'	rule	\N
c8a8214f-12cb-49c5-908b-0b81f6a72c73	8.6800	2026-01-08	Overig	2026-02-10 12:58:46.067613+00	EUR	Hof Van Cleve	OUT	22513eb572fe40dd8da8a999f6793d3c	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
8c44bd0c-3142-437b-90ea-7d3d84cdd905	2.4900	2026-01-08	Horeca	2026-02-10 12:58:46.148963+00	EUR	Starbucks	OUT	b5572e28681245f9ab2968d54fb3debe	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
a28178d8-d8ec-4e31-b40e-5bb55458871a	27.9000	2026-01-05	Transport	2026-02-10 12:58:46.156912+00	EUR	Sncb	OUT	372fe7e8cabc45c3b12cf38f8ce1afb2	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
55f00678-9179-4784-aa98-e2081d8a6a1d	34.8500	2026-01-05	Overig	2026-02-10 12:58:46.173607+00	EUR	Ag Insurance	OUT	4d10f95935d04546a6bf4953ffb3bf36	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
544cbcce-ba17-40f2-9cfd-ad98d6149205	34.8500	2026-01-05	Overig	2026-02-10 12:58:46.182327+00	EUR	Ag Insurance	OUT	8293739075fe4c9e937cb2c4ed5d9a0a	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
cd16533f-1120-4fec-b346-e6323085620c	40.0000	2026-01-05	Overig	2026-02-10 12:58:46.191747+00	EUR	Esso	OUT	9d956d4005c546ffb3f9af27375da05d	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
b2a6a550-bf59-48c4-9fab-0243616fbcea	29.9900	2026-01-05	Boodschappen	2026-02-10 12:58:46.197783+00	EUR	Carrefour	OUT	c7afae56a3c34181930e995bce1053d8	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
f41c87c4-576c-4283-b598-9d4e8950fb03	650.0000	2026-01-03	Overig	2026-02-10 12:58:46.202924+00	EUR	Loyer	OUT	69f3a37c8e364645a94ba0000580ce10	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
edb33b52-8208-453a-8e38-8b038976f78a	27.6600	2026-01-03	Boodschappen	2026-02-10 12:58:46.213764+00	EUR	Ad Delhaize	OUT	dd07c431cdcf48558552fb7a09638926	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'delhaize'	rule	\N
76ce0342-776d-444d-8305-f25b886dc052	3.7900	2026-01-02	Overig	2026-02-10 12:58:46.227653+00	EUR	Neuhaus	OUT	1c6cbb2ef69540c299eb0ed663f39a36	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
85ae0986-1b14-46da-98f9-f12519e7d305	1887.0300	2026-01-02	Inkomen	2026-02-10 12:58:46.235824+00	EUR	Salaire	IN	4e247036738849408ad31204562ce8b3	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
ec1bd90d-9b3b-4081-b99a-97f904440f15	29.9900	2026-01-02	Overig	2026-02-10 12:58:46.241186+00	EUR	Be Optic	OUT	67db4ea3b21145d6a9b08abb7a1128b0	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
0adfe261-5182-4b6a-89f6-6d543d9d073a	2.4900	2026-01-01	Horeca	2026-02-10 12:58:46.246639+00	EUR	Starbucks	OUT	72a67ce1edbb4c5d889abb5f161130f6	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
4b42bb10-1620-4fdb-bfa4-debec23076fc	17.9900	2026-01-01	Horeca	2026-02-10 12:58:46.252438+00	EUR	Kaffabar	OUT	7336b797dda44c68986ec7009408f431	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'bar'	rule	\N
bae0f4a7-a2da-45e3-b38b-2b3d444358cb	3.7200	2026-01-01	Inkomen	2026-02-10 12:58:46.257524+00	EUR	Versement D'intérêts	IN	bd7d768e9aa44de7ada2bd75046ad97c	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.90	Inkomende transactie	rule	\N
777d79ba-e5dd-4277-96b9-2612dbbd5bca	27.9000	2025-12-29	Transport	2026-02-10 12:58:46.290201+00	EUR	Sncb	OUT	a8c66826670548958c3d7e5ad013cd79	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
139e1e3d-6f8c-4610-8375-a1b8d8f08cf4	29.9900	2025-12-29	Boodschappen	2026-02-10 12:58:46.297242+00	EUR	Carrefour	OUT	d6328905a7f143308044a10c1c765ecd	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
afabda52-a91d-4571-bdf5-06d007981905	5.6900	2025-12-28	Overig	2026-02-10 12:58:46.308782+00	EUR	Mcdonalds	OUT	1ecc50aaf6ba49aa8763e3ad4518ee1c	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
eb77eba6-dcfc-4deb-9252-ed0ed99433da	23.9900	2025-12-28	Overig	2026-02-10 12:58:46.316661+00	EUR	Orange Belgium	OUT	f50dec72027b4b5b80b8c76cd1966aa6	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
92ebc1d6-0d91-4e63-a244-b02e5ccdd35d	97.7100	2025-12-26	Overig	2026-02-10 12:58:46.322744+00	EUR	Décathlon	OUT	0410420ea78f4849843f6a8cc3f2b10e	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
4fc157ab-7113-41d1-bd2a-b4d2315d23a1	34.0000	2025-12-26	Utilities	2026-02-10 12:58:46.325643+00	EUR	Luminus	OUT	a1c898e83de74915be6c2f71eacd6a57	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'luminus'	rule	\N
4023f81c-6b95-4c77-942a-ab33c1f84e40	2.4900	2025-12-25	Horeca	2026-02-10 12:58:46.329096+00	EUR	Starbucks	OUT	0153916e7eda4225aea3764096b86f09	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
7721b810-f71c-464a-80c0-1405e1079e98	9.7900	2025-12-25	Overig	2026-02-10 12:58:46.331933+00	EUR	Galleria Inno	OUT	889bcdb141ea4008b606aafa9990a305	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
b3f0e3c6-ba6a-442d-8700-960d434690a4	8.6800	2025-12-25	Overig	2026-02-10 12:58:46.334807+00	EUR	Hof Van Cleve	OUT	a2cf260687ab413ab12fa80d05518ea6	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
d92e2652-2e70-40f5-90a7-c5c81075819c	23.9900	2025-12-23	Overig	2026-02-10 12:58:46.337539+00	EUR	H&M	OUT	384a98abfbd64ae598b1c74528f7a10e	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
3b0b9bb0-4a52-48de-a355-9a6022e9436c	27.9000	2025-12-22	Transport	2026-02-10 12:58:46.339862+00	EUR	Sncb	OUT	594c8173921d42f9901b84c820ca33b5	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
1f9ff97a-9926-4d4f-ba7c-09e0dc7c8567	53.6600	2025-12-22	Overig	2026-02-10 12:58:46.342126+00	EUR	Le Petit Boudoir	OUT	6c56083fa2dc4cb695e35f9fde7ed338	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
74f9ea2d-5a0a-4d43-9ae9-67eed6f749d9	40.0000	2025-12-22	Overig	2026-02-10 12:58:46.344589+00	EUR	Esso	OUT	a19aa6225bb9494da07e1c85899d739c	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
3e89d694-ce32-48d5-8948-39a566974007	29.9900	2025-12-22	Boodschappen	2026-02-10 12:58:46.348698+00	EUR	Carrefour	OUT	bf44858e826c4aaf93f57ca5cd9b76fa	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
c65aa880-9a59-44f0-a4c8-edffe9cb3661	12.9000	2025-12-20	Overig	2026-02-10 12:58:46.351377+00	EUR	Flixbus	OUT	4919e64e2c0a4e68800ddc3efc3771c6	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
48bd40c8-eb3e-4630-a03c-7d8357edc32d	19.6700	2025-12-20	Overig	2026-02-10 12:58:46.354212+00	EUR	Veepee	OUT	5dc885595ffa42fcbb62e1d420535baa	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
1c525dbf-bfa2-48ad-8e32-ff05596d896e	24.9600	2025-12-19	Overig	2026-02-10 12:58:46.357262+00	EUR	Le Pecheur Nord	OUT	21b7e2261ec1464584f605262aea8e79	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
c285289e-0b41-4b71-9849-d0a4a895c17a	3.7900	2025-12-19	Overig	2026-02-10 12:58:46.361221+00	EUR	Neuhaus	OUT	71e52d246aad4641a0a9f4e25d6c2cf5	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
127c32f7-f5a4-4b07-8d78-3a93a91eec63	2.4900	2025-12-18	Horeca	2026-02-10 12:58:46.366378+00	EUR	Starbucks	OUT	55bcae0dc7ad4f669f462f8a0f12aa93	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
de7e1e3d-4467-4dae-850c-d052b1257143	3.7900	2025-12-17	Overig	2026-02-10 12:58:46.36888+00	EUR	Pharmacie	OUT	0fd2b55a0ea041a8ab0d222009e042ad	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
f5e7cc8b-f916-4755-aa61-5ec0a8a77a57	13.9900	2025-12-17	Abonnementen	2026-02-10 12:58:46.371831+00	EUR	Spotify	OUT	c750c4aa9c6e40d591091aeb3cb0f5c0	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'spotify'	rule	\N
885e0ced-ff14-4d25-a2c2-a1a8b075083f	129.9900	2025-12-16	Shopping	2026-02-10 12:58:46.374298+00	EUR	Coolblue	OUT	2f68fc4225d1410897abde5203ed0c73	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'coolblue'	rule	\N
f62544a2-80b2-4811-a624-890ecb62eb3e	17.3300	2025-12-15	Boodschappen	2026-02-10 12:58:46.376355+00	EUR	Spar	OUT	120c132404584760a1c7e59d7eb610a4	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'spar'	rule	\N
63971623-bba4-4c7c-8660-7bd9f23d2121	29.9900	2025-12-15	Boodschappen	2026-02-10 12:58:46.379001+00	EUR	Carrefour	OUT	563ceb35201c427f81d3ed393351dd2f	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
a481691c-ada8-4ab1-a35e-43acf164f3da	27.9000	2025-12-15	Transport	2026-02-10 12:58:46.382026+00	EUR	Sncb	OUT	aaac033066d04f209e1911d84cdb8fe3	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
45570448-6b15-4fed-8ddd-dc116c24255e	20.0000	2025-12-12	Overig	2026-02-10 12:58:46.385143+00	EUR	Retrait D'espèces	OUT	20b1ab8f5c7d4bb8b9e1e93834a9a1dd	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
34fa1f21-fcba-4fa4-97ca-33f728259a1f	22.9900	2025-12-12	Overig	2026-02-10 12:58:46.388538+00	EUR	Tele2 Belgium	OUT	31016613c47b4cee9c865fd540b64242	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
23c32f67-77fa-49aa-b1a9-c6bf9166e8a7	15.9900	2025-12-12	Abonnementen	2026-02-10 12:58:46.390869+00	EUR	Netflix	OUT	f07908591ded416792e49f136ad44708	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'netflix'	rule	\N
04c5e8c1-f1df-4c61-a094-6e6c72c2748c	8.6800	2025-12-11	Overig	2026-02-10 12:58:46.392889+00	EUR	Hof Van Cleve	OUT	b66a9e8d2ead4e62bc65e6f2ce9373c0	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
95330c20-0e6c-4d90-8a2b-053f0fc1c24c	2.4900	2025-12-11	Horeca	2026-02-10 12:58:46.395149+00	EUR	Starbucks	OUT	f0402c455aeb4f1d9c92e85406d0fae8	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'starbucks'	rule	\N
59176283-d6d7-4e19-91ac-1c593565d931	200.0000	2025-12-10	Overig	2026-02-10 12:58:46.398039+00	EUR	Virement	OUT	472b6271b2f54e1da79ce92974381e14	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
41a495b8-08a5-404c-9830-fd2cc5b60429	56.9800	2025-12-09	Shopping	2026-02-10 12:58:46.40122+00	EUR	Amazon	OUT	02b21ee28f5d4b17808a6d461b3b6545	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'amazon'	rule	\N
4dec6cda-1501-4e74-835e-f22c1f24d0e9	40.0000	2025-12-08	Overig	2026-02-10 12:58:46.403445+00	EUR	Esso	OUT	104da740b6ae45ccbcae847649802408	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
1f59047f-0131-43bf-9ed8-c694114c5233	27.9000	2025-12-08	Transport	2026-02-10 12:58:46.405891+00	EUR	Sncb	OUT	a92f220910dd463d9d27655a4097484b	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'sncb'	rule	\N
7f148613-506e-4c2d-87b5-1cf61f97d786	29.9900	2025-12-08	Boodschappen	2026-02-10 12:58:46.408107+00	EUR	Carrefour	OUT	e6f2dfcb4dcd4dbda7d6b4e16455d88c	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.60	Match op 'carrefour'	rule	\N
2800d9cd-8561-43a2-970f-943cac21d079	34.8500	2025-12-05	Overig	2026-02-10 12:58:46.410301+00	EUR	Ag Insurance	OUT	15df699e61514fa3ac639ad5a268cc0f	\N	6094e2d1-18e0-4142-a9d4-1e8d579a77a1	\N	\N	\N	\N	0.40	Geen match	rule	\N
11d25c3e-250b-4396-ad07-2c5e469feaea	19936.9875	2025-09-22	Crypto	2026-02-11 12:40:01.825519+00	GALA	Bitvavo trade null	OUT	00000000-0000-0493-0000-00000017bf5a	\N	56f48477-85de-4e60-b746-2e57e7e3ab26	Bitvavo	00000000-0000-0493-0000-00000017bf5a	BOOKED	TRADE	0.95	Crypto account	rule	\N
605f058d-3dfb-4a8e-99ee-a2e28442936f	76.5000	2026-01-19	Inkomen	2026-02-10 18:06:25.941266+00	EUR	Zee - 30	IN	C6A19PGFNF0R15UG	2026-01-19	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Poelmans Sam	\N	BOOK	PGIPSTDB	0.90	Inkomende transactie	rule	\N
b573bfbd-13ed-461c-a4b9-0afd3af6717c	82.9000	2026-01-19	Inkomen	2026-02-10 18:06:25.944237+00	EUR	LA DAME BLANCHE 17-01-2026 20:53 KNOKKE-HEIST BE524784XXXXXX4307	IN	C6A19XN07H000I3Z	2026-01-18	d9cd3b8e-724b-41dc-b065-a5561a6af21f	LA DAME BLANCHE	\N	BOOK	NCMCDBCM	0.90	Inkomende transactie	rule	\N
ae53eae8-0b6d-4700-b973-bb0c7d72c5ba	13.8000	2026-01-19	Inkomen	2026-02-10 18:06:25.950066+00	EUR	STEENHUYSE DIRK BVBA   KNOKKE-HEIST	IN	C6A19AG07M0000LD	2026-01-19	d9cd3b8e-724b-41dc-b065-a5561a6af21f	STEENHUYSE DIRK BVBA   KNOKKE-HEIST	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
330cea19-c2e6-41ea-bc56-010db3d65412	26.8000	2026-01-16	Inkomen	2026-02-10 18:06:25.953045+00	EUR	CAFE DES NATIONS       KNOKKE-HEIST	IN	C6A16AG0HI0001HU	2026-01-16	d9cd3b8e-724b-41dc-b065-a5561a6af21f	CAFE DES NATIONS       KNOKKE-HEIST	\N	BOOK	NCCADBPV	0.90	Inkomende transactie	rule	\N
843e5d52-5b13-4c2d-9833-0bd84819a503	150.0000	2026-01-06	Inkomen	2026-02-10 18:06:25.958921+00	EUR	Poelmans Sam	IN	C6A06XM035001441	2026-01-06	d9cd3b8e-724b-41dc-b065-a5561a6af21f	Poelmans Sam	\N	BOOK	PGCTSTCR	0.90	Inkomende transactie	rule	\N
74b2fdfc-c900-46f3-923f-7ddb9791cb45	76.5000	2026-01-19	Transfer	2026-02-10 17:56:48.475476+00	EUR	INSTANT STORTING VAN BE74 9734 5105 7007 POELMANS -   LIETEN Zee - 30 NAAR BE06 0635 0305 0422 Poelmans Sam REF. : 080G71J140512 VAL. 19-01                        | Zee - 30	IN	EUR_3931	2026-01-19	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	POELMANS - LIETEN	\N	BOOK	\N	0.92	Eigen rekening	rule	BE74973451057007
b1e7df67-78e6-469f-be27-f3caa81fa06d	100.0000	2026-02-03	Huur/Hypotheek	2026-02-10 17:56:48.41567+00	EUR	DOORLOPENDE BETALINGSOPDRACHT 17748824 NAAR           BE16 7845 7763 9874 NYS - POELMANS Maandelijks geld   Sam                                                   REF. : 080071U245769 VAL. 03-02                        | Maandelijks geld Sam	OUT	EUR_3942	2026-02-03	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	NYS - POELMANS	\N	BOOK	\N	1.00	Gebruikersregel (IBAN)	override	BE16784577639874
3279424b-fb36-44ef-a920-bb5269f7ef03	17929.4086	2025-09-22	Crypto	2026-02-11 12:40:01.846233+00	GALA	Bitvavo trade null	OUT	00000000-0000-0493-0000-00000017bf59	\N	56f48477-85de-4e60-b746-2e57e7e3ab26	Bitvavo	00000000-0000-0493-0000-00000017bf59	BOOKED	TRADE	0.95	Crypto account	rule	\N
656f1b42-e6fb-410f-a7fe-05c6dbd42c4d	0.4404	2024-03-14	Crypto	2026-02-11 12:40:01.85539+00	SOL	Bitvavo trade null	IN	46d427b1-0936-40bb-89e7-63f2731705c4	\N	76d72d6f-37ef-46c8-87d3-e2ee73664953	Bitvavo	46d427b1-0936-40bb-89e7-63f2731705c4	BOOKED	TRADE	0.95	Crypto account	rule	\N
c0aae34e-4595-4d2d-81cb-694d32009d76	0.4404	2023-11-09	Crypto	2026-02-11 12:40:01.862709+00	SOL	Bitvavo trade null	OUT	c928a949-4202-4174-a844-6a8120f5fe66	\N	76d72d6f-37ef-46c8-87d3-e2ee73664953	Bitvavo	c928a949-4202-4174-a844-6a8120f5fe66	BOOKED	TRADE	0.95	Crypto account	rule	\N
bf9f56a6-ef2e-4593-ad3b-ac75234331d1	0.7810	2024-11-22	Crypto	2026-02-11 12:40:01.86971+00	ETH	Bitvavo trade null	OUT	7259d969-f1c8-4de2-8d37-f62040f2014d	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	7259d969-f1c8-4de2-8d37-f62040f2014d	BOOKED	TRADE	0.95	Crypto account	rule	\N
63fea741-1394-4f6f-a862-c3094f714aff	0.2131	2024-11-22	Crypto	2026-02-11 12:40:01.875924+00	ETH	Bitvavo trade null	OUT	2252a037-c969-4d50-b3cb-86b61e3aeed9	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	2252a037-c969-4d50-b3cb-86b61e3aeed9	BOOKED	TRADE	0.95	Crypto account	rule	\N
e5b6c9a6-b362-4e65-8caf-463020c3530d	0.0124	2024-11-22	Crypto	2026-02-11 12:40:01.883153+00	ETH	Bitvavo trade null	OUT	bc2b39d5-be5a-4644-975c-d550c9fee6b4	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	bc2b39d5-be5a-4644-975c-d550c9fee6b4	BOOKED	TRADE	0.95	Crypto account	rule	\N
713433b0-827b-452d-9915-0211ef5442a1	0.2803	2024-03-14	Crypto	2026-02-11 12:40:01.889177+00	ETH	Bitvavo trade null	IN	730136fc-8887-4b6c-9843-b532cd340845	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	730136fc-8887-4b6c-9843-b532cd340845	BOOKED	TRADE	0.95	Crypto account	rule	\N
3fa55d12-976c-41c4-bf31-27aa8135792a	0.6478	2024-03-14	Crypto	2026-02-11 12:40:01.895678+00	ETH	Bitvavo trade null	IN	17e148a8-f5a8-473e-9236-48f090f0af42	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	17e148a8-f5a8-473e-9236-48f090f0af42	BOOKED	TRADE	0.95	Crypto account	rule	\N
81de5075-343e-482a-8610-72f362ff4682	0.1240	2023-12-13	Crypto	2026-02-11 12:40:01.904538+00	ETH	Bitvavo trade null	OUT	d6e7bf87-21d1-43cd-9335-7394de8f1490	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	d6e7bf87-21d1-43cd-9335-7394de8f1490	BOOKED	TRADE	0.95	Crypto account	rule	\N
984d145c-f546-447b-8a47-b694130d7e2e	0.0544	2023-12-13	Crypto	2026-02-11 12:40:01.912672+00	ETH	Bitvavo trade null	OUT	2ed68ac0-aed8-4b9c-bdd1-c02adf0b37d0	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	2ed68ac0-aed8-4b9c-bdd1-c02adf0b37d0	BOOKED	TRADE	0.95	Crypto account	rule	\N
cc322691-66e7-42d1-b64b-b44880369d6b	0.3026	2023-12-13	Crypto	2026-02-11 12:40:01.919714+00	ETH	Bitvavo trade null	OUT	4b98b66a-13b5-498c-859f-e11046578a6b	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	4b98b66a-13b5-498c-859f-e11046578a6b	BOOKED	TRADE	0.95	Crypto account	rule	\N
3ba75315-0c22-4164-9ea0-cecf942b94bd	2.0000	2026-01-07	Overig	2026-02-10 17:56:43.876925+00	EUR	BIJDRAGE IN DE BEHEERSKOSTEN VAN UW BEATS STAR-       REKENING WAARVAN 1,93 EUR VOOR DE BETAALSERVICE VAN DEKREDIETKAART.                                         REF. : 0801W16756390 VAL. 01-01                       	OUT	EUR_200	2026-01-07	1fe953cf-4b83-4309-b479-ae04460a06b8	\N	\N	BOOK	\N	0.40	Geen match	rule	\N
a12d5188-70a8-4b05-94b3-0d76be395536	0.1695	2023-11-09	Crypto	2026-02-11 12:40:01.926938+00	ETH	Bitvavo trade null	OUT	c7b32c19-86b2-4c23-82df-f42427d860d0	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	c7b32c19-86b2-4c23-82df-f42427d860d0	BOOKED	TRADE	0.95	Crypto account	rule	\N
1942eb49-f24f-48b8-a15b-5b14129dc10b	0.0100	2023-11-09	Crypto	2026-02-11 12:40:01.933442+00	ETH	Bitvavo trade null	OUT	90148415-8d53-4c15-80e7-3a74bbed66a5	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	90148415-8d53-4c15-80e7-3a74bbed66a5	BOOKED	TRADE	0.95	Crypto account	rule	\N
a3d908ec-51c9-4ec1-ae28-65694ce6973e	1000.0000	2026-02-03	Crypto	2026-02-10 17:56:48.407954+00	EUR	BANCONTACT - AANKOOP - Bitvavo BV - 1017 CA Amsterdam NL - 03/02/26 06:59 - VIA INTERNET - KAART 5169 20XX  XXXX 2043 - Poelmans Sam                              REF. : 0440000402432 VAL. 03-02                        | NL   03/02/26 06:59                 	OUT	EUR_3944	2026-02-03	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Bitvavo BV	\N	BOOK	\N	0.85	Crypto exchange	rule	\N
d434f6e9-a612-4fd1-b490-b8ed02b05c67	261.4500	2026-01-05	Overig	2026-02-10 17:56:43.885512+00	EUR	MASTERCARD AFREKENING NUMMER 359                      REF. : 0807515114228 VAL. 05-01                        | MASTERCARD  359	OUT	EUR_199	2026-01-05	1fe953cf-4b83-4309-b479-ae04460a06b8	\N	\N	BOOK	\N	0.40	Geen match	rule	666000000483
33a3571a-9f6c-4389-a2a6-fe84010cdb27	392.4703	2025-09-25	Crypto	2026-02-11 12:40:01.975374+00	VIRTUAL	Bitvavo trade null	OUT	00000000-0000-059c-0000-000000072d0c	\N	607e8be0-c0f9-4629-ae09-9b62a034fb41	Bitvavo	00000000-0000-059c-0000-000000072d0c	BOOKED	TRADE	0.95	Crypto account	rule	\N
0e2e0484-4729-4836-b1df-142d31e4b232	297.2100	2026-01-12	Inkomen	2026-02-10 17:56:48.518981+00	EUR	STORTING VAN BE76 3751 1176 5095 FB VLABEL JOBBONUS   Jobbonus.BT-2024-000623988-1.01061826761 REF. :       24694965 NAAR BE06 0635 0305 0422 POELMANS, SAM       REF. : 777282574 VAL. 12-01                            | Jobbonus.BT-2024-000623988-1.0106182	IN	EUR_3921	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	FB VLABEL JOBBONUS	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE76375111765095
58031c58-06cd-487f-b510-75eb5bc89326	20.0000	2026-01-12	Inkomen	2026-02-10 17:56:48.546864+00	EUR	INSTANT STORTING VAN BE41 0636 0956 4910 VANHEES STEF Kado Jim mat NAAR BE06 0635 0305 0422 Poely           REF. : 090542101A505 VAL. 10-01                        | Kado Jim mat	IN	EUR_3914	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	VANHEES STEF	\N	BOOK	\N	0.90	Inkomende transactie	rule	BE41063609564910
f889e905-3bed-46b8-91ed-52a421099747	0.2676	2023-11-09	Crypto	2026-02-11 12:40:01.942938+00	ETH	Bitvavo trade null	OUT	02aab75d-9ec3-48c5-8e37-3f46b287015d	\N	aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	Bitvavo	02aab75d-9ec3-48c5-8e37-3f46b287015d	BOOKED	TRADE	0.95	Crypto account	rule	\N
f601897a-10a4-49f6-942c-6fb92026ffc3	682.9325	2025-09-25	Crypto	2026-02-11 12:40:01.959565+00	VIRTUAL	Bitvavo trade null	OUT	00000000-0000-059c-0000-000000072d0e	\N	607e8be0-c0f9-4629-ae09-9b62a034fb41	Bitvavo	00000000-0000-059c-0000-000000072d0e	BOOKED	TRADE	0.95	Crypto account	rule	\N
17104542-11f1-4587-9698-74e7db7a2e69	29.7782	2025-09-25	Crypto	2026-02-11 12:40:01.967298+00	VIRTUAL	Bitvavo trade null	OUT	00000000-0000-059c-0000-000000072d0d	\N	607e8be0-c0f9-4629-ae09-9b62a034fb41	Bitvavo	00000000-0000-059c-0000-000000072d0d	BOOKED	TRADE	0.95	Crypto account	rule	\N
62a6efa2-6138-48cd-8472-355ca73134d2	17.3000	2026-01-29	Overig	2026-02-10 17:56:48.423181+00	EUR	BANCONTACT-AANKOOP - GEMACO - 3600 GENK BE - 29/01/26 12:07 - CONTACTLOOS VIA WALLET APPLE PAY - KAART 5169 20XX XXXX 2043 - Poelmans Sam                         REF. : 0112314601266 VAL. 29-01                        | BE   29/01/26 12:07                 	OUT	EUR_3940	2026-01-29	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	GEMACO	\N	BOOK	\N	0.40	Geen match	rule	\N
b14f411a-3c0c-40d4-91d4-2b30e7d0771b	3.9900	2026-01-02	Overig	2026-02-10 17:56:43.892601+00	EUR	JAARPREMIE BELFIUS COVER VOOR REKENING NR.            BE24 0637 5928 7238 TOT 31 DECEMBER 2026.             REF. : 08155CV266095 VAL. 02-01                        | 1BE24063759287238                          2026 BELFIUS COVER                             	OUT	EUR_198	2026-01-02	1fe953cf-4b83-4309-b479-ae04460a06b8	\N	\N	BOOK	\N	0.40	Geen match	rule	\N
20e88fa8-9651-4e1e-9a9f-b6a2f78544ea	2.0000	2025-12-04	Overig	2026-02-10 17:56:43.909013+00	EUR	BIJDRAGE IN DE BEHEERSKOSTEN VAN UW BEATS STAR-       REKENING WAARVAN 1,93 EUR VOOR DE BETAALSERVICE VAN DEKREDIETKAART.                                         REF. : 0801WC3711687 VAL. 01-12                       	OUT	EUR_195	2025-12-04	1fe953cf-4b83-4309-b479-ae04460a06b8	\N	\N	BOOK	\N	0.40	Geen match	rule	\N
c9aa9e8b-c034-4881-9867-9c994dc3786b	1750.0000	2026-02-04	Transfer	2026-02-10 17:56:48.395681+00	EUR	DOORLOPENDE BETALINGSOPDRACHT 17748945 NAAR           BE80 0835 3027 7377 Poelmans Sam Spaarrekening        REF. : 080071U458931 VAL. 05-02                        | Spaarrekening	OUT	EUR_3947	2026-02-04	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans Sam	\N	BOOK	\N	0.92	Eigen rekening	rule	BE80083530277377
425abc9a-7285-40f2-80a5-0447b4cca7f0	39.4000	2026-01-23	Overig	2026-02-10 17:56:48.457814+00	EUR	BANCONTACT-AANKOOP - MC DONALDS GENK - 3600 GENK BE - 23/01/26 12:36 - CONTACTLOOS - KAART 5169 20XX XXXX   2043 - Poelmans Sam                                   REF. : 0050311961293 VAL. 23-01                        | BE   23/01/26 12:36                 	OUT	EUR_3935	2026-01-23	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	MC DONALDS GENK	\N	BOOK	\N	0.40	Geen match	rule	\N
4c0176f3-6317-416c-997b-6edaa57034bc	149.0000	2026-01-20	Overig	2026-02-10 17:56:48.470785+00	EUR	BANCONTACT-AANKOOP - LAB9 GENK - 3600 GENK BE -       20/01/26 12:40 - CONTACTLOOS VIA WALLET APPLE PAY -   KAART 5169 20XX XXXX 2043 - Poelmans Sam              REF. : 0031700551243 VAL. 20-01                        | BE   20/01/26 12:40                 	OUT	EUR_3932	2026-01-20	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	LAB9 GENK	\N	BOOK	\N	0.40	Geen match	rule	\N
75205b51-f83c-4775-99eb-d8608b13d105	13.9900	2026-01-19	Overig	2026-02-10 17:56:48.483735+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 17/01 M en M E-commerce 4 B LEUSDEN NL 13,99 EUR KAART NR 5169 2014  3823 2043 - Poelmans Sam                              REF. : 0801S1J561847 VAL. 19-01                        | 13,99           D         EUR     51	OUT	EUR_3929	2026-01-19	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	M en M E-commerce 4 B	\N	BOOK	\N	0.40	Geen match	rule	\N
4b419574-8cca-4bdb-897e-fb65f193e1ac	3.0000	2026-01-19	Overig	2026-02-10 17:56:48.496815+00	EUR	BANCONTACT-AANKOOP - SINT FRANCISKUSZIEKENH - 3550    HEUSDEN-ZOLDE BE - 18/01/26 17:29 - CONTACTLOOS VIA   WALLET APPLE PAY - KAART 5169 20XX XXXX 2043 -        Poelmans Sam                                          REF. : 0043228491741 VAL. 18-01        	OUT	EUR_3926	2026-01-19	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	SINT FRANCISKUSZIEKENH	\N	BOOK	\N	0.40	Geen match	rule	\N
918ed1d9-f20a-486e-a370-46ffa4d4cfa1	3.5000	2026-01-16	Overig	2026-02-10 17:56:48.510269+00	EUR	BANCONTACT-AANKOOP - DBH BIJ SOPHIE - 3980 TESSENDERLOBE - 16/01/26 12:46 - CONTACTLOOS VIA WALLET APPLE PAY- KAART 5169 20XX XXXX 2043 - Poelmans Sam            REF. : 0208859021239 VAL. 16-01                        | BE   16/01/26 12:46                 	OUT	EUR_3923	2026-01-16	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	DBH BIJ SOPHIE	\N	BOOK	\N	0.40	Geen match	rule	\N
40aa4034-2e86-4288-a380-59bc7d465c05	2.0000	2026-02-05	Overig	2026-02-10 17:56:43.839846+00	EUR	BIJDRAGE IN DE BEHEERSKOSTEN VAN UW BEATS STAR-       REKENING WAARVAN 1,93 EUR VOOR DE BETAALSERVICE VAN DEKREDIETKAART.                                         REF. : 0801W24527093 VAL. 01-02                       	OUT	EUR_204	2026-02-05	1fe953cf-4b83-4309-b479-ae04460a06b8	\N	\N	BOOK	\N	0.40	Geen match	rule	\N
e8e101ff-6da0-41ab-8d8f-fb3b693b3041	13.9200	2026-02-03	Overig	2026-02-10 17:56:43.850855+00	EUR	MASTERCARD AFREKENING NUMMER 025                      REF. : 0807523108320 VAL. 03-02                        | MASTERCARD  025	OUT	EUR_203	2026-02-03	1fe953cf-4b83-4309-b479-ae04460a06b8	\N	\N	BOOK	\N	0.40	Geen match	rule	666000000483
27d23d1a-148f-4e53-932f-e5753d08ca3c	1000.0000	2026-02-06	Crypto	2026-02-10 17:56:48.362742+00	EUR	BANCONTACT - AANKOOP - Bitvavo BV - 1017 CA Amsterdam NL - 05/02/26 21:45 - VIA INTERNET - KAART 5169 20XX  XXXX 2043 - Poelmans Sam                              REF. : 0440000402466 VAL. 05-02                        | NL   05/02/26 21:45                 	OUT	EUR_3954	2026-02-06	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Bitvavo BV	\N	BOOK	\N	0.85	Crypto exchange	rule	\N
62482801-2d5d-4e16-87ab-6f3fd9b5cd44	258.6400	2025-12-08	Overig	2026-02-10 17:56:43.898079+00	EUR	INSTANT OVERSCHRIJVING BELFIUS MOBILE NAAR            BE35 3631 7329 0237 Boekhouder 005/0234/23266   REF. : 09054493C6437 VAL. 06-12                        | 005023423266	OUT	EUR_197	2025-12-08	1fe953cf-4b83-4309-b479-ae04460a06b8	Boekhouder	\N	BOOK	\N	0.40	Geen match	rule	BE35363173290237
3f2ae9ec-d598-492c-b3ca-dc95e39fc698	57.0000	2026-01-26	Overig	2026-02-10 17:56:48.42692+00	EUR	OVERSCHRIJVING E-COMMERCE NAAR BE42 0689 0209 3054    Stichting Mollie Payments M19274787MQ53Z3D 25-01-2026 19:22 / 5613-W-7229 / Sam Poelmans                    REF. : 090546341P495 VAL. 25-01                        | M19274787MQ53Z3D 25-01-2026 19:22 / 	OUT	EUR_3939	2026-01-26	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Stichting Mollie Payments	\N	BOOK	\N	0.40	Geen match	rule	BE42068902093054
63adb66c-1292-4a51-b840-a3477396d0f1	9.6000	2026-01-26	Overig	2026-02-10 17:56:48.431045+00	EUR	BETALING VIA UW MOBILE BANKING APP AAN Vanhove LennertOP 24/01/2026 MET UW BETAALREKENING                   BE06 0635 0305 0422                                   REF. : 090546031O716 VAL. 24-01                       	OUT	EUR_3938	2026-01-26	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Vanhove Lennert	\N	BOOK	\N	0.40	Geen match	rule	BE88063717257441
9a2c2213-073a-4124-961c-c8725188e345	4.2000	2026-01-26	Overig	2026-02-10 17:56:48.447991+00	EUR	OVERSCHRIJVING VIA WERO BELFIUS MOBILE NAAR           BE44 0018 7652 7745 NOUWEN ELIAS                      a187b82c0b53486794a0f8680544b240                      REF. : 090544671N942 VAL. 23-01                       	OUT	EUR_3937	2026-01-26	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	NOUWEN ELIAS	\N	BOOK	\N	0.40	Geen match	rule	BE44001876527745
8ed35410-783d-4d7d-a6b8-6af58d0e9434	13.2000	2026-01-26	Overig	2026-02-10 17:56:48.453153+00	EUR	OVERSCHRIJVING VIA WERO BELFIUS MOBILE NAAR           BE44 0018 7652 7745 NOUWEN ELIAS                      c11f0af5008e4ecfb8cde4851497326b                      REF. : 090544961N931 VAL. 23-01                       	OUT	EUR_3936	2026-01-26	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	NOUWEN ELIAS	\N	BOOK	\N	0.40	Geen match	rule	BE44001876527745
9d401eb4-51e6-4cf5-98b2-a0aab25e3a7f	75.0000	2026-01-12	Overig	2026-02-10 17:56:48.53884+00	EUR	INSTANT OVERSCHRIJVING BELFIUS MOBILE NAAR            BE70 9795 2537 3425 HANNE LIETEN                      REF. : 090543221B086 VAL. 11-01                       	OUT	EUR_3916	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	HANNE LIETEN	\N	BOOK	\N	0.40	Geen match	rule	BE70979525373425
74584f9b-dd97-47d6-9e4c-4a7a7eaeabc4	40.0000	2026-02-09	Overig	2026-02-10 17:56:48.355989+00	EUR	BANCONTACT APP OF BELFIUS MOBILE APP - Jeffry P2P     MOBILE - 07/02/26 16:46 - KAART 5169 20XX XXXX 2043 - Poelmans Sam                                          REF. : 6664036581301 VAL. 07-02                        | BE   07/02/26 16:46                 	OUT	EUR_3955	2026-02-09	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Jeffry          P2P MOBILE	\N	BOOK	\N	0.40	Geen match	rule	\N
d5727f77-f670-4912-ab7f-922051dfd244	43.5200	2026-02-05	Overig	2026-02-10 17:56:48.382106+00	EUR	BANCONTACT-AANKOOP - GEMACO - 3600 GENK BE - 05/02/26 12:33 - CONTACTLOOS VIA WALLET APPLE PAY - KAART 5169 20XX XXXX 2043 - Poelmans Sam                         REF. : 0112314601239 VAL. 05-02                        | BE   05/02/26 12:33                 	OUT	EUR_3950	2026-02-05	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	GEMACO	\N	BOOK	\N	0.40	Geen match	rule	\N
0a1c68f5-cc89-4f19-8bf5-2da358222e49	0.9900	2026-01-23	Overig	2026-02-10 17:56:48.461904+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 22/01 APPLE.   COM BILL CORK IE 0,99 EUR KAART NR 5169 2014 3823 2043- Poelmans Sam                                        REF. : 0801S1N021285 VAL. 23-01                        | 0,99           D         EUR     516	OUT	EUR_3934	2026-01-23	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	APPLE.COM BILL	\N	BOOK	\N	0.40	Geen match	rule	\N
1a97cfff-3eb2-4654-9b72-fbd61ab8e39c	6.0000	2026-01-20	Overig	2026-02-10 17:56:48.46631+00	EUR	BANCONTACT-AANKOOP - TENNISCLUB KOERSEL - 3582 KOERSELBE - 20/01/26 18:55 - CONTACTLOOS VIA WALLET APPLE PAY- KAART 5169 20XX XXXX 2043 - Poelmans Sam            REF. : 0203311991889 VAL. 20-01                        | BE   20/01/26 18:55                 	OUT	EUR_3933	2026-01-20	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	TENNISCLUB KOERSEL	\N	BOOK	\N	0.40	Geen match	rule	\N
a969f44d-5c23-4c1e-bca2-d1873024a776	59.9500	2026-01-19	Overig	2026-02-10 17:56:48.479623+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 17/01 MD KNOKKELIPPENSLAAN KNOKKE BE 59,95 EUR KAART NR 5169 2014    3823 2043 - Poelmans Sam                              REF. : 0801S1JA17880 VAL. 19-01                        | 59,95           D         EUR     51	OUT	EUR_3930	2026-01-19	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	MD KNOKKE LIPPENSLAAN	\N	BOOK	\N	0.40	Geen match	rule	\N
1b6a3c94-6671-403f-8ff8-3ef906759607	150.0000	2026-01-05	Transfer	2026-02-10 17:56:48.567101+00	EUR	DOORLOPENDE BETALINGSOPDRACHT 18114559 NAAR           BE74 9734 5105 7007 Poelmans - Lieten                 REF. : 0800712023532 VAL. 05-01                       	OUT	EUR_3909	2026-01-05	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans - Lieten	\N	BOOK	\N	0.92	Eigen rekening	rule	BE74973451057007
f4e436cb-7c45-457b-bbcc-8569ba1fdc06	14.0000	2026-01-19	Overig	2026-02-10 17:56:48.492557+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 17/01          BRAINPOINT PAY BE Zaventem BE 14,00 EUR KAART NR 5169 2014 3823 2043 - Poelmans Sam                         REF. : 0801S1J666461 VAL. 19-01                        | 14,00           D         EUR     51	OUT	EUR_3927	2026-01-19	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	BRAINPOINT PAY BE	\N	BOOK	\N	0.40	Geen match	rule	\N
9f88d3fb-ebfb-4c5b-ad08-be02c7103282	34.9900	2026-01-19	Overig	2026-02-10 17:56:48.501035+00	EUR	BANCONTACT-AANKOOP - VANDEN BORRE 034 KNOKK - 8300    KNOKKE BE - 17/01/26 11:14 - CONTACTLOOS VIA WALLET   APPLE PAY - KAART 5169 20XX XXXX 2043 - Poelmans Sam  REF. : 0019659341105 VAL. 17-01                        | BE   17/01/26 11:14                 	OUT	EUR_3925	2026-01-19	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	VANDEN BORRE 034 KNOKK	\N	BOOK	\N	0.40	Geen match	rule	\N
382e3be8-b3c9-46fb-8e16-74a2ecdc0dcd	4.5500	2026-01-16	Overig	2026-02-10 17:56:48.505513+00	EUR	BANCONTACT-AANKOOP - BVBA AD KOERSEL - 3582 KOERSEL BE- 16/01/26 13:59 - CONTACTLOOS VIA WALLET APPLE PAY - KAART 5169 20XX XXXX 2043 - Poelmans Sam              REF. : 0046785351359 VAL. 16-01                        | BE   16/01/26 13:59                 	OUT	EUR_3924	2026-01-16	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	BVBA AD KOERSEL	\N	BOOK	\N	0.40	Geen match	rule	\N
36eaf91b-d7ae-4a3f-ad67-fb7dea87db20	4.5000	2026-01-12	Overig	2026-02-10 17:56:48.53481+00	EUR	BANCONTACT-AANKOOP - WEEZEVENT - 21000 DIJON FR -     11/01/26 14:04 - CONTACTLOOS - KAART 5169 20XX XXXX   2043 - Poelmans Sam                                   REF. : 0525786361322 VAL. 11-01                        | FR   11/01/26 14:04                 	OUT	EUR_3917	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	WEEZEVENT	\N	BOOK	\N	0.40	Geen match	rule	\N
8748db26-ef9f-4782-96d2-cfc4cf970a92	422.3600	2025-12-04	Overig	2026-02-10 17:56:43.903306+00	EUR	MASTERCARD AFREKENING NUMMER 329                      REF. : 08075C4111039 VAL. 04-12                        | MASTERCARD  329	OUT	EUR_196	2025-12-04	1fe953cf-4b83-4309-b479-ae04460a06b8	\N	\N	BOOK	\N	0.40	Geen match	rule	666000000483
dfc85592-99cf-4c9b-964e-5f0c05c0be7b	500.0000	2026-01-07	Crypto	2026-02-10 17:56:48.554995+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 06/01 Bitvavo  Amsterdam NL 500,00 EUR KAART NR 5169 2014 3823 2043 -Poelmans Sam                                          REF. : 0801S17198199 VAL. 07-01                        | 500,00           D         EUR     5	OUT	EUR_3912	2026-01-07	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Bitvavo	\N	BOOK	\N	0.85	Crypto exchange	rule	\N
5b125f50-d35e-4949-a57a-b6885fc8d8b7	20.0000	2026-01-12	Overig	2026-02-10 17:56:48.551004+00	EUR	INSTANT OVERSCHRIJVING BELFIUS MOBILE NAAR            BE07 7360 4275 7866 Siemen                            REF. : 090543461A200 VAL. 10-01                       	OUT	EUR_3913	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Siemen	\N	BOOK	\N	0.40	Geen match	rule	BE07736042757866
b9c65c58-1632-4716-8130-aa3844de2d72	4.0000	2026-02-10	Gezondheid	2026-02-10 17:56:48.333998+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 09/02 SumUp *  MedEC M3T4A032 As BE 4,00 EUR KAART NR 5169 2014 3823 2043 - Poelmans Sam                                   REF. : 0801T2A154956 VAL. 10-02                        | 4,00           D         EUR     516	OUT	EUR_3958	2026-02-10	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	SumUp  *MedEC M3T4A032	\N	BOOK	\N	0.98	Gebruikersregel	override	\N
8014b8d5-846a-413e-afe4-b273eff5b4ec	27.0000	2026-02-09	Overig	2026-02-10 17:56:48.348435+00	EUR	INSTANT OVERSCHRIJVING BELFIUS MOBILE NAAR            BE07 7360 4275 7866 Siemen                            REF. : 0905436028342 VAL. 08-02                       	OUT	EUR_3956	2026-02-09	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Siemen	\N	BOOK	\N	0.40	Geen match	rule	BE07736042757866
75dbefd3-f1f5-44f8-9472-e699e9e1fb59	119.8800	2026-02-04	Gezondheid	2026-02-10 17:56:48.391247+00	EUR	UW EUROPESE DOMICILIERING 120MUTD010618197M33001 VOOR Technical Entity MUT BYD CHRISTELIJKE MUTUALITEIT     MEDEDELING: 010618 267 61 Bijdrage van 01/01/2026 tot 31/12/2026 REFERTE SCHULDEISER: 806313505261          REF. : 0819624647727 VAL. 04-02        	OUT	EUR_3948	2026-02-04	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	CHRISTELIJKE MUTUALITEIT	\N	BOOK	\N	0.98	Gebruikersregel	override	BE79780585920833
1843844c-0ebc-405e-9826-5895c087cce9	31.7200	2026-01-16	Overig	2026-02-10 17:56:48.514813+00	EUR	INSTANT OVERSCHRIJVING BELFIUS MOBILE NAAR            BE43 7300 0420 0601 KBC Verzekeringen                 331/8475/82494                                  REF. : 090543731G151 VAL. 16-01                        | 331847582494	OUT	EUR_3922	2026-01-16	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	KBC Verzekeringen	\N	BOOK	\N	0.40	Geen match	rule	BE43730004200601
7c86d39c-8a9d-46e2-92aa-89cc1a72a335	1.7000	2026-01-19	Huur/Hypotheek	2026-02-10 17:56:48.488363+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 16/01 OPC      KNOKKE OW HERENT BE 1,70 EUR KAART NR 5169 2014 3823  2043 - Poelmans Sam                                   REF. : 0801S1J296331 VAL. 19-01                        | 1,70           D         EUR     516	OUT	EUR_3928	2026-01-19	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	OPC KNOKKE OW	\N	BOOK	\N	0.70	Match op 'rent'	rule	\N
5eca339b-b594-459c-a377-b01ee5a171cc	52.3000	2026-01-05	Utilities	2026-02-10 17:56:48.563014+00	EUR	DEBITMASTERCARD-BETALING VIA Apple Pay 02/01 DE       ORANGERIE HASSELT BE 52,30 EUR KAART NR 5169 2014 38232043 - Poelmans Sam                                   REF. : 0801S15069402 VAL. 05-01                        | 52,30           D         EUR     51	OUT	EUR_3910	2026-01-05	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	DE ORANGERIE	\N	BOOK	\N	0.70	Match op 'orange'	rule	\N
6f6b4586-c269-4904-8d5e-3be8fe97d575	87.5000	2026-01-12	Boodschappen	2026-02-10 17:56:48.526423+00	EUR	DOORLOPENDE BETALINGSOPDRACHT 18624219 NAAR           BE70 0593 1368 8625 Sam Poelmans PENSIOENSPAREN       REF. : 0800719205166 VAL. 12-01                        | PENSIOENSPAREN	OUT	EUR_3919	2026-01-12	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Sam Poelmans	\N	BOOK	\N	0.70	Match op 'spar'	rule	BE70059313688625
41acd46c-9ee0-40bd-8e77-4effbd0cc032	600.0000	2026-02-04	Transfer	2026-02-10 17:56:48.386891+00	EUR	OVERSCHRIJVING BELFIUS MOBILE NAAR BE72 0829 7614 9016Poelmans Sam Sparen                                   REF. : 0905448224353 VAL. 05-02                        | Sparen	OUT	EUR_3949	2026-02-04	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Poelmans Sam	\N	BOOK	\N	0.92	Eigen rekening	rule	BE72082976149016
439304ea-4f70-48b2-8eaa-5b798ae97877	87.5000	2026-02-10	Pensioensparen	2026-02-10 17:56:48.341355+00	EUR	DOORLOPENDE BETALINGSOPDRACHT 18624219 NAAR           BE70 0593 1368 8625 Sam Poelmans PENSIOENSPAREN       REF. : 0800729143110 VAL. 10-02                        | PENSIOENSPAREN	OUT	EUR_3957	2026-02-10	a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	Sam Poelmans	\N	BOOK	\N	1.00	Gebruikersregel (IBAN)	override	BE70059313688625
\.


--
-- Data for Name: category_overrides; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.category_overrides (id, category, created_at, match_type, match_value, updated_at, user_id, match_mode) FROM stdin;
07231d3c-2f6a-4781-ab9d-4b5f4b1f2ab7	Gezondheid	2026-02-11 10:20:37.821466+00	MERCHANT	medec	2026-02-11 10:20:37.821466+00	a6e06fec-691f-459c-85b4-098a8cb2a786	CONTAINS
f45f22de-2ef4-42f8-a045-54a0a7762067	Crypto	2026-02-11 10:20:54.369971+00	MERCHANT	bitvavo	2026-02-11 10:20:54.369971+00	a6e06fec-691f-459c-85b4-098a8cb2a786	CONTAINS
9a06eb39-5326-4cc9-9aaf-fd48ad7aecab	Gezondheid	2026-02-11 10:21:19.146966+00	MERCHANT	mutualiteit	2026-02-11 10:21:19.146966+00	a6e06fec-691f-459c-85b4-098a8cb2a786	CONTAINS
8dfc26f6-e793-4388-bca8-7368e1b8b2db	Pensioensparen	2026-02-11 10:51:22.466327+00	IBAN	be70059313688625	2026-02-11 10:51:22.466331+00	a6e06fec-691f-459c-85b4-098a8cb2a786	EXACT
d5771948-6989-4baf-8406-cc64abd8be48	Huur/Hypotheek	2026-02-11 10:52:23.313423+00	IBAN	be16784577639874	2026-02-11 10:52:23.313424+00	a6e06fec-691f-459c-85b4-098a8cb2a786	EXACT
\.


--
-- Data for Name: connections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.connections (id, auto_sync_enabled, created_at, display_name, encrypted_config, error_message, external_id, last_synced_at, provider_id, status, type, updated_at, user_id) FROM stdin;
ec95c46a-fc58-4882-884b-e8493f144a75	f	2026-02-10 11:48:42.600981+00	Belfius	XOLroejqpCFxtPxZ:aGPFKKaLXCgjmA2QsHerpjT2c1v/m0DZBtNEBY7E3Ocjm3wO0vtmTMtjq0U5ZXTLXd4CfRnT1PP/v1qvnXJw5poWvaq77idIByTsJUDkchD1cU48hWL911AnNCQXQnNeNl+1XTKQ9cyKRHwpx6ZTykxHj6zvU7AGfYjx+I/5KowhNq6Ftawf/FWZZk9UeiaqwFa2Dg3fLZfjBJ6bpxwQLsyuwcKw4knrnILgznqa9PTT3XeVgWUT1fohw6g7+ji38/6AHzAdGzdN0FQuNZ7oHbhDwRyGJauu9i4hQ8hVdvs+ZpPg9iE13aGlj7MikM5SJpSVGLptCcctHAS7eRa18NjVGDIGjxchtRugAIGYC62gyaruDSV0HBPiijAon4IJ1EzrjX7d4XyE4nFGSCOemZsB9/5HBdQ0wx5cLBP3vFq6yAoU/ML2MsoLBwexXB9fiyIeda2gASl2CESfhfrDMoU9DLy6KaB+MJkpp3Tlb36C5wU/MeVIELvmXOgZIK11tfkTufk04wvcdJfaB3K8Kti4UD1b7LiqYH+BIbJfqHa1/+5UUZw+HLnuljikdoDwsDkbw3W4VeeAltVC3scOzCZRybGF/pUuJLtCKBnBH2uoLyThb+CCX5jnfP+XXpHoD6vQ174y4IoPJ3GmsZUOQbf/+mHTtWckbUljZ3dfRjABI9CrLj8Pxx5voA6eAOtFlN+OMgAXkJXQGQt3v/C9Zp2ver13XJO2K9co9R3pGpOMSOaABYA/hLQoxJwK25aaADIY7enN1cr0GVRxBOHQ/HeeBUVNJzOVccz44mpZHvOklsVyA/oJfwP4FccdlmkJr1iKqbWw6Le2i2PXVii2Up+IjDN45UfmHkpz8NCoU1TXOyW2NL+wyaOx0ktEknK+tqRrwfKoMPIjg0CqjcyX9jhPdfRF1nICrx4l1znFM6lWGATxT+6vp5yVdcuqwyhFDlPPZanY0GbA///OQ6jTW39yozFlABA7HqSNsPvOUST7EozMv8MdLj5sIDgwr4UmwxhTvjU8fqRQc5fseawmbszH1b/lFpFWSht2wSlgw6sFVg7ll+D9AE+lO2quaW/AaLOjM83JANuk0W7ssQhfWtXYgX2f00l94PZ/BJoOX4ANgFUOsw==	\N	ec95c46a-fc58-4882-884b-e8493f144a75	2026-02-10 11:54:55.638476+00	tink	DISABLED	BANK	2026-02-10 12:14:43.331597+00	a6e06fec-691f-459c-85b4-098a8cb2a786
1998b50b-02f6-41f7-9af0-eb15a1f68962	f	2026-02-10 11:56:16.190094+00	Argenta	SYF9XS4rtLMM5l1t:tPo+EqfwKPb4lFGMeL9+vEVoyxZwPKdCM0k3XnytOljiFy7uK1A3l0wdzhwNqXzqTU7Z3Gl1sYg+AhfYPM57uwiacwqIOVvfoukuYQu0guhSb/lAoSfnHsyh04X3SIKXEAxCBRmAZdX8MmmIhwxkDJnIf8pnCUCYOw4OC5Er5AehRUmF5614iZYdMeLAVswn4KaxpcebNEbNXgk7ImyT0jKpMvoqBV4YYynNIeanr/EA6s1VvU+Cn8BKTBOvjSbQcj/P+I9z1qc/bOc5ceC+KlA4BDmE73jBeAfRaKrwf1iDX6PV9jHaatXsoAu6VmHC13y7r2NyMaRWsRcS0Kmj09OBkfEa5lsol5Efa3YFZytXDAM4jpKUuEKylwk5nxNO74wK2uqEMdfZaCqUd8rgIPNAjzcNwm0fpp0M39ECQoDnQ3LqXt3k5YuuBXpW+XcOpKgRhj87agl1FgJKsDqWTrc/ZUDlYrmpXIPzV7tArxNAtk/eoB2ybCHOvKVEOUWyL3OMfYC1AkOdRBIN7H18SFIvZ4GpnoFVaprDR1aCOV6pai05PMtRHpBkjdgrFBxwcg/93/J7CLj0IAIjoyN+/rgvtkKhKdcvOzTyXvYbB/MALoUEgBNHLpmnGJGwm/heFc6M8nVupazW0V8aJNpGW+FQt4phyvl0fSxfH2qlSH91N3Fp18Otgqtco3lwT7ZAACGEQlSOvs5a3cj6gpFGs57tFTlRg8UJQITBYDODrA5zF1G3cOPJd2cnCHahzDsyWPNaKF1GqP1hePpBg+RnkGO29igLGrWFEIu1QOhi2ue25HxPz/1LLpA53tGoYOrKortmiKGHPTL8Kl9zXeWjak0kPKe28pUm6iMs/9+H4J5HSvvQE1NEszoCanVHc0y/uj4LeXNfb8IyzO70a12IvYo/d6BcM1u7MFlGEwd8KLpTdqQUUxJ7+OlX7goIMQCWW47x21i9vfK/g5NPaXcmMbhS5gg0ZQPwMKmL2Dn6CmZmI8WcXmSHxCm+pRQ66QJab+FY5vm3GZ2IfFQ3+NvxydliU94JTPvieRx815YXSkWA6cGicU0FRQBecBb+5arTcSpx576ZkMyIvss593CwbFVLpb/VVfycA094yb75+ncM5j3Tvw==	\N	1998b50b-02f6-41f7-9af0-eb15a1f68962	\N	tink	DISABLED	BANK	2026-02-10 11:56:40.975728+00	a6e06fec-691f-459c-85b4-098a8cb2a786
1ffcecff-7fa0-4b0f-8313-cd80ca7a65c0	f	2026-02-10 12:03:41.517762+00	Argenta	lDAqo9Nm9O1wKVFl:RiOn/tD851TZyw61G02syUXp1kNLpHql6SqlaMWU8aaDD6+Pp4vlGjv52wADclbyTJM+F3Ivc+EVvWrFwB59+KvYaqRGdtLjkCg7sqIB6xxxolQi5uzrymw=	\N	1ffcecff-7fa0-4b0f-8313-cd80ca7a65c0	\N	tink	DISABLED	BANK	2026-02-10 12:04:31.931728+00	a6e06fec-691f-459c-85b4-098a8cb2a786
d09afd53-674a-411d-a2a5-b9a507560e87	f	2026-02-10 12:14:59.030495+00	Belfius	g9W/BNCV+AvyPpz8:y1HqZNoUYG+Mh+7wx/qD0VnEWu5HIvIORlB4BqO/yrnh5JnJ6CdilOhaGm2HsJvB3bduui30nbp9bn4IhsqlcBMq0dTpgyWl4agAqhMlIlPfGlgk+ikx/GFhmzz+jL2FB8XeS1jgy0U0ybZ+miPY89lvrfQe0ROYU2kGpP6gomZWBpyl80OLQyHCfBEYmbkLFWk5f8Kl0MK0WSRJinIghvivxiK9Vpj6xJX59TNTxzdJN+UQZ9NOWPibl3IPgEN9WMrXQaZbssqOaeVKv3wE7SYD9haZErwkGNZ9iiB4pjKmaukH8ooLEAO/hxJS30hrph/etNfYCchQoWRzQdM8B5DGkpf9vNFW7IGT5ePhQHGM5Oc0GQ/KaESF02u+RoKUQ59o3fB6rBM+qhVO2gFbsor/Ye1UvpcCix9MuCbKj4c3Ad3i3Z3phoBmZAj3DebCuwnNXdJSaPXdYzZW7dbi0/WQE5UAVGxOpVf9TW0G6v7g1SMWleTL2nsSBVR0OCc1PRjRzSUpV7HAuKxeGzg+/n1J7L6My33/2KZZT/9haSXFbNddTT3UTgAd7VdUUtkomS58AjDTKOFC+qu49fD1YXOO0j+7iliELx2SgG3RDDzSyoQMTDnwv43NqjXZEpMYZZJFfHlwZ4cYsWSEauGeVcPgbTzA0GdMSa3hZTDxJ4zoni/a6AAkHWEXr1xNSgjTn6L57hHTuF+TLfARYKbdMLS0jVaybSqZ+MWoIFw9WKMxZUYTVOglFg5ZabidyMEVlkxzWG/j8ilabCqMSlrkPVynmdue2SWJEnMOoCJ7RfA3TLptzhHLvKRSZ2kdx10ZijX6R5hcWhGzGnzO50yAtX500R7rPBD9GtSttJ2iYqPG6/QV192D/QHrUOsV86zJyG+WkYwXSBRLitL6ZpeOB5WNmHTLlfiMRJdnn755zZsYisNx8wUteWYaykzuu6Cn+7gosuXVLEhsFHx6yktpyIdqnAkOZBGsfaqlKBxt/qShpEQ9V2ed3fBpl8OjpMRpJAKoIE2t5KMGGpxHWstHTQZTEhx98HW1AjOJ3FlxFPOQTRYP35P6Rn+0QC0w11gaDNpMJDcPJSUjwrRNcAMWe4RAt4AxPEHVxmdlMRkKvD6QRyu4eg==	\N	d09afd53-674a-411d-a2a5-b9a507560e87	\N	tink	DISABLED	BANK	2026-02-10 12:15:58.272727+00	a6e06fec-691f-459c-85b4-098a8cb2a786
98a885c7-7247-4f7e-9e23-4c123324bbf1	t	2026-02-10 12:08:26.108939+00	Bitvavo	BfQZv239tQcjb7IL:tehKYkYKXC/aneQ5Fwe5d2zzqgN7SCwoNT2zNSdKP5EVOJQrEQd1gHRKappp8eCIoVRO8JHYjDY9YhpFIcIR/UPhIBPYC3r0HDlUrn09/Obsz1N7y5sNxilxoFvnZAhPQUtXZoyUm2aMN4BvBPM0GIOsKSa3OhCSLxR40nb2WMoQTbe6GC8EP7MIHzB7qEGIo+aSnbOKG7YpzqzYaemSyxNlZOj58+4ItnA50Gcc+VYSkSeAyo+32C6Lub9jl5cyL7ZmenHSNmsSRJmVabyykEHsj7/oK1puqwu3BmB6zHVzEDixKnppBo3mKFM=	\N	\N	2026-02-11 14:15:33.087075+00	bitvavo	ACTIVE	CRYPTO	2026-02-11 14:15:33.08812+00	a6e06fec-691f-459c-85b4-098a8cb2a786
51dc1d8f-ae90-4008-af84-c5e7ef8adfe4	f	2026-02-10 17:06:04.808418+00	Mock ASPSP	knbDy//enWNRtRhs:5+Tew+TGKwLER+ZQoa7oD8/5ivqiVT9TFOPYpstcvdjM/onIGLozFtG9ZUnosYQRh0id51Xmu/qr0icvqYXAWTCCtuhjshWLR/+P2vn3XX1iVUlt5G+33gV9UI+Iny3XCXy87jU0pTRM3HxVllv5xkhh/5E136rhBk+Fxk+xtDQcoutMbYvA5elRr/ii4OMdQRzgOGgrDVd3woqDbSY+JSQQIwdVXUuS3O0xP3xp29Qm8wiKi7cZ+Iw7oh45whq56VnceRVIQaBi/skNstKJGu3SwFWmcOUcpZg79Zrkfjs=	\N	b2934270-1f15-44ab-841b-d457505fa98e	2026-02-10 17:07:23.784316+00	enablebanking	DISABLED	BANK	2026-02-10 17:08:10.545198+00	a6e06fec-691f-459c-85b4-098a8cb2a786
7cbe371f-1f1a-4f8f-9bc4-3392c9da31f3	f	2026-02-10 12:16:30.188609+00	Belfius	vuUprBp21idhp9JK:7WsZ+/7OAp4H2oFAalPX9Hx7LCQotgIX0St1i+M9jbQ5Sy4lPM7wmOdZRal1ZLi6ZC7oebPcXiI9x9Kio4cqHLkc+V0uM2bN19x5Rul8komQTlrbALA6d34SY6ZvZhyXCPHvd52LwQ8pJPTdr/ryaeylTDmBm6a+vPDlnw+lNTNi6rO1ur2BA8tQ4+ryrRzK4L2lHt2SUafRHCMsKyK7CqZrIBPgiI0KPPEHZ2b/RS1wTmmmdDaY9YFucbXCbwouJaITLAEri4mfXauOo1kuSpIjVqZRicOBAeidi1ZMtGh8Cvibmt1GpGXAw9qe5PcjvrC4VDorz8ECFClFOTwiFfydBXCgoVTxXJZEJsG8RLtgKwJXWe4hCPtNfzJnmQBDjbVNlswFGxrTmNusGfXQl0me6abVnH+Am/1919Nh9C8rlVtMTfYAk8cv02SulqjTEDBO3ez9YmeMfzXB8Jqz6RTZq6t4sMQN7E6Cm4O587Oh81q3GlVZjKAGBvzETGwzV4GsWWqSMKRk/zrIV2kz1xSYNM/83jcvqpEaG5KKYcVlMmq2fLlBdHflEvzxDjzwQrL4Jgkr3q1uDWfWw7dM+xbovOaH1WoEW73fRB/CZ2i6IiNfh+JK4OMz09YVwlsDA49gq7KfgMebc3b/fCHI+MBJkpjyQvkpZzpjRcNnDwdSrDa4fBRrgi+M85QMPF/gMjfdJwM8K6oGKRDPDgvQ+CjJoq2MN4i7cT2yV45pLoCiWPAidapUoiboS5zdmYeB7oV16i3o9wPRE7+8OlA3UWgyBlNdnT+Nyz/rdoYVEVrRYgH4K1npdFNsP5y1y/th4w9Hm3E5eNWJ+GcTc2YInvA3w2uZfgMMzXwdhSnV5pKIUfaD+YANpg+D/IMNllGdqfoev+c2wJOILLWf8Wcif37H46m49JaP9Cc576kUZQPbsMQhJOQ5/+iHrk7zqjsxWGaA7d6YiQi4kCpP0YiYJsydsc1FHbMk6m0Yd2m4oQKNQpqL7WsM1RPa7TNYnRmD0SctSE2DDKabBFecq/06DT0qHI3cwRCCxlNZgUWbx0VcgXW82e6SGcQMNTjWz0rEGWw8KV71EsJ/dBbhr4Dhhqdz4AKG4wUd2zo1rXaSkNXcQeoH9Q==	400 Bad Request: "{"code":3,"message":"Invalid page token","details":[]}"	7cbe371f-1f1a-4f8f-9bc4-3392c9da31f3	2026-02-10 13:03:44.068492+00	tink	DISABLED	BANK	2026-02-10 16:44:54.626236+00	a6e06fec-691f-459c-85b4-098a8cb2a786
7c229a50-4d89-4087-bbcd-e9ee17976a88	f	2026-02-10 18:04:49.68357+00	Argenta	VD0xH7qS8Qes+E3G:ArPd0pEXPzkaaQGAHzb1j27DbX4KjeVj7USv1i4ZnsjdAkFgz59BTzodzOrs1eN+YCE+VvrQrGeOBL26T7B66NTBd+13nBkS9uL7ISwK185vnPcMf66k0xd2AkRy1N4VEAD43kG5kklXxKkQ/rHFjk9fabjO7EJPZH1cLGGvFxhTJJfHZaeFnhX9ka1mepy66AFQpQTrXj9tjmrt8Wr/crhLy740PrBFZ0OlomTl0NXfiNbviIGMvR9ihQ9ZKidMD9MCv0t4ymOXAm96RE1CsI+F6S6SWHBhb50NnVwLqMb69v2MTQTNvma3nuZ+vuWQIM5as+Tavnt8jj3Sf1LFCK14S7Wyi/keAp2E9wpmD3v4	Rate limit actief. Probeer opnieuw na 2026-02-11T18:32:44.798403Z	b9c98179-c84d-46a2-9c30-efdeba8f3af2	2026-02-10 18:32:44.798403+00	enablebanking	ERROR	BANK	2026-02-11 11:10:54.649543+00	a6e06fec-691f-459c-85b4-098a8cb2a786
a8839f0a-bcfa-46e9-b050-94ace28c2093	f	2026-02-10 17:08:28.210834+00	Mock ASPSP	qlHPuW/HsuNnfrEH:MaM0Z1oeizJ8FqenlJFSa1dzR8hKUIsHIQfTcFoTrhA7gfWNTUcXMMsPA0OP1dsQDfld/uRLQQBcLBqJwU9FSGnkpWtICdcVDo97IqMfgOIIEgIhWwy3PaBmtzZxgVhXA1xlyIA+iPN4MAL58McYGi8x/FE8VUF2TmLULGdZguoDlujLA3rk5+6F1g4+9CUyURV6Xf32dcO51yzjrhV46oS0kArt9LglzsFEFa1uc0MKKJC+6/a04VFFxcNvbz2FcfVXFpEEeU9k/twfUCVYEgDh0mS8v5QdMH8pd8JgCzY=	404 Not Found: "{"code":404,"message":"No session found matching provided id","error":"SESSION_DOES_NOT_EXIST","detail":null}"	f48f4e8f-31b5-4813-924b-fae25424860b	2026-02-10 17:15:58.603674+00	enablebanking	DISABLED	BANK	2026-02-10 17:24:44.306016+00	a6e06fec-691f-459c-85b4-098a8cb2a786
45c893de-849d-4705-b0ae-5a836604913b	f	2026-02-10 16:52:05.378568+00	BBVA	pHmczfnXF9MYR3Tt:vO8KjM/lYCfz3mDT+pwTsX+zCK340TlK2reGqWvLgF81cIhlHMQvKGpQk4qQCr//fKTk1fsZ02y7LJKDAgwrDnw59CO2ud74i8+4UETL+sPk5YrL8jpxswIVePBbM4bbmQgEO34wQcKgHLt7Z43/oLGG1nNm5SI2WzY3PDGNctbbWxQMBcJFxe7Hy6mBDde+pXbaG+MXzLs7t3MPjWleBxGxWmdjV2iIwgFoxPFWjX52V/H2z4Gvoj1C3MjLfcu5cdw5alojztGT4MrMI0wMTsdPdXQONIgLJg0=	\N	3e28ce00-b276-4e2c-ad91-a1a460cd0f77	2026-02-10 17:03:45.821445+00	enablebanking	DISABLED	BANK	2026-02-10 17:05:55.1084+00	a6e06fec-691f-459c-85b4-098a8cb2a786
fdcd1c75-d29f-409a-9f98-b6eb723e9c78	f	2026-02-10 17:25:07.136724+00	Belfius	WQZBR8wZ84xszIPS:UDgt17j7Q9c+I1aEJVCanK8xUXauGz1i/Zw+FZblYygjKyuMQA0lMGNz/nW3FVIVGt9oFqnjdB+CzyHuJ2nHOoThb3onSdc9zu2mRrCNf541KU5dXx0D7/jLbTVgXYZZqGndGhKhYEZNawYQL0Ud9HD4ogauTouu	Missing Enable Banking session. Complete the consent flow first.	\N	\N	enablebanking	DISABLED	BANK	2026-02-10 17:27:09.997717+00	a6e06fec-691f-459c-85b4-098a8cb2a786
320c6b64-fa65-44b9-b92e-0f7365ea1432	f	2026-02-10 17:54:24.844977+00	Belfius	zad+gN0G6NzbCOyo:IkjqAGIJo4uDug+cGoHeTaBivh6COMqDJRrz6DoGJrJ70v/H0uz58rV/0Ztf2/iLOdT5KK5xhc+8iBtVDG8gjCMZajTZ5MjbxSFQhofkX35hCGOtGMIdoen/61EA2VhnOnYssidGW19erEICsJMp2JvP8wpX2Qyjc30QuAnemltG6GgMp5mA3djuZduw0AMEto92zd6ipVEeox5I/ERXeCSzrS+YhRgO2zfx+JWW1BTluawQxUcijVYNThU8iATeB+ouAvSUj9LBnIZb57q+2D7cEtEVhgu+L9ZfjAy3LxWCwJ0f8gjGzfY2h4h768KXA5W2/LokEEAW7beAllET7RpINGvHgU6iE9+noLn9YXYB9MsY+BB3o+4z2ByQ5t1yoe4pBu7Cgwub3Dtgi7CX70u0jALBlw==	\N	30f1dea6-3791-4feb-b8b4-3a33fb927f95	2026-02-11 10:35:36.805914+00	enablebanking	ACTIVE	BANK	2026-02-11 10:35:36.807098+00	a6e06fec-691f-459c-85b4-098a8cb2a786
\.


--
-- Data for Name: financial_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.financial_accounts (id, currency, current_balance, external_id, last_synced_at, name, provider, type, connection_id, user_id, current_fiat_value, fiat_currency, account_number, iban, household_id, label, opening_balance) FROM stdin;
28199791-e786-4ca8-b47b-5d6d7c7c9f41	EUR	\N	4eceafaf77fa489eadbfd79b4cfd6f94	2026-02-10 11:54:55.419373+00	Checking Account	Tink	BANK	ec95c46a-fc58-4882-884b-e8493f144a75	a6e06fec-691f-459c-85b4-098a8cb2a786	\N	\N	\N	\N	\N	\N	\N
958d8836-45e5-48fb-9404-65f1a12683e6	EUR	\N	148289354c9b4e3380028f277cd2cf70	2026-02-10 11:54:55.503519+00	Shared Account	Tink	BANK	ec95c46a-fc58-4882-884b-e8493f144a75	a6e06fec-691f-459c-85b4-098a8cb2a786	\N	\N	\N	\N	\N	\N	\N
baddda74-0ebb-4b22-bd0b-b742e677df07	EUR	1200.0000	\N	2026-02-11 14:40:10.690212+00	Sam Spaarrekening Flow	Manual	BANK	\N	a6e06fec-691f-459c-85b4-098a8cb2a786	1200.0000	EUR	\N	BE72082976149016	\N	Sam Spaarrekening Flow	1200.0000
d9cd3b8e-724b-41dc-b065-a5561a6af21f	EUR	304.4800	6daf4559-f1ff-4465-b942-fadfbe7b80f5	2026-02-10 18:32:43.503514+00	POELMANS - LIETEN	Enable Banking	BANK	7c229a50-4d89-4087-bbcd-e9ee17976a88	a6e06fec-691f-459c-85b4-098a8cb2a786	304.4800	EUR	\N	BE74973451057007	\N	\N	\N
9f07c2f1-3306-4576-8dd8-b07423c94868	SUI	0.0035	SUI	2026-02-11 14:15:31.997902+00	SUI	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	0.0027	EUR	\N	\N	\N	\N	\N
e450bf5f-b5fb-40ac-9d13-3bbfac36a244	FIL	1299.7794	FIL	2026-02-11 14:15:32.006847+00	FIL	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	991.0818	EUR	\N	\N	\N	\N	\N
56f48477-85de-4e60-b746-2e57e7e3ab26	GALA	115820.2915	GALA	2026-02-11 14:15:32.013962+00	GALA	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	381.1414	EUR	\N	\N	\N	\N	\N
76d72d6f-37ef-46c8-87d3-e2ee73664953	SOL	0.1588	SOL	2026-02-11 14:15:32.020257+00	SOL	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	11.0789	EUR	\N	\N	\N	\N	\N
9b57f77a-0d3a-4bd9-8cbc-8c7335d30b88	FET	10401.0895	FET	2026-02-11 14:15:32.025474+00	FET	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	1394.6821	EUR	\N	\N	\N	\N	\N
75139c1d-9e44-4bdf-812a-0dc5c4c9c220	SLP	546495.2971	SLP	2026-02-11 14:15:32.034037+00	SLP	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	285.9263	EUR	\N	\N	\N	\N	\N
2216586e-70b0-473a-a624-97363464b469	ICP	255.6806	ICP	2026-02-11 14:15:32.039832+00	ICP	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	507.0403	EUR	\N	\N	\N	\N	\N
0ce9b9e2-ac38-4607-a3ee-70b5c96275d3	EUR	17.8700	ca51e8bc-8158-4161-bd85-628cd87b518d	2026-02-10 17:15:58.030583+00	Aino Hämäläinen	Enable Banking	BANK	a8839f0a-bcfa-46e9-b050-94ace28c2093	a6e06fec-691f-459c-85b4-098a8cb2a786	17.8700	EUR	\N	\N	\N	\N	\N
aa04fc99-2f1b-46f6-92e6-e67e6a2dda79	ETH	0.5040	ETH	2026-02-11 14:15:32.045091+00	ETH	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	850.5931	EUR	\N	\N	\N	\N	\N
a68475e7-9622-43c1-a0d9-2e20026ed0b4	AXS	918.9915	AXS	2026-02-11 14:15:32.049086+00	AXS	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	1157.6536	EUR	\N	\N	\N	\N	\N
1e3fedd8-cdfd-4d95-8a31-1261df0be18a	EUR	1.3800	e4cd12cdce8c4515b7e28014caaae47b	2026-02-10 13:56:50.234117+00	Compte épargne	Tink	BANK	7cbe371f-1f1a-4f8f-9bc4-3392c9da31f3	a6e06fec-691f-459c-85b4-098a8cb2a786	1.3800	EUR	BE08102629414840	BE08102629414840	\N	\N	\N
6094e2d1-18e0-4142-a9d4-1e8d579a77a1	EUR	-1422.8600	2651d4bd496e4a2bbaaad667007c0511	2026-02-10 13:56:50.626571+00	Compte courant	Tink	BANK	7cbe371f-1f1a-4f8f-9bc4-3392c9da31f3	a6e06fec-691f-459c-85b4-098a8cb2a786	-1422.8600	EUR	BE39433754154146	BE39433754154146	\N	\N	\N
71f8607e-4160-438e-8da3-64d1e17363ec	STRK	6512.1599	STRK	2026-02-11 14:15:32.053294+00	STRK	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	252.8346	EUR	\N	\N	\N	\N	\N
607e8be0-c0f9-4629-ae09-9b62a034fb41	VIRTUAL	3203.3649	VIRTUAL	2026-02-11 14:15:32.057194+00	VIRTUAL	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	1478.8654	EUR	\N	\N	\N	\N	\N
6cda918a-fb08-4c8d-a20b-65574e093a3a	THETA	9235.5069	THETA	2026-02-11 14:15:32.061744+00	THETA	Bitvavo	CRYPTO	98a885c7-7247-4f7e-9e23-4c123324bbf1	a6e06fec-691f-459c-85b4-098a8cb2a786	1571.0336	EUR	\N	\N	\N	\N	\N
1fe953cf-4b83-4309-b479-ae04460a06b8	EUR	1130.3600	6ae2a89d-7b1a-4e0c-a0a5-b15edc170221	2026-02-11 10:35:28.252132+00	Sam Poelmans	Enable Banking	BANK	320c6b64-fa65-44b9-b92e-0f7365ea1432	a6e06fec-691f-459c-85b4-098a8cb2a786	1130.3600	EUR	\N	BE24063759287238	\N	Sam IT Solutions	\N
a5fce093-28ab-4fd4-aa1b-6f4b070a8d9e	EUR	208.9300	75f45d3d-23e8-4d91-918e-aed8cce3acaa	2026-02-11 10:35:33.41024+00	Sam Poelmans	Enable Banking	BANK	320c6b64-fa65-44b9-b92e-0f7365ea1432	a6e06fec-691f-459c-85b4-098a8cb2a786	208.9300	EUR	\N	BE06063503050422	\N	\N	\N
43fa03c5-5ac7-49c8-93e7-0de58cc57718	EUR	2404.3000	\N	2026-02-11 14:40:10.716735+00	Sam Spaarrekening	Manual	BANK	\N	a6e06fec-691f-459c-85b4-098a8cb2a786	2404.3000	EUR	\N	BE80083530277377	\N	Sam Spaarrekening	2404.3000
\.


--
-- Data for Name: household_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.household_members (id, created_at, role, household_id, user_id) FROM stdin;
c3a97289-5084-4e9e-af60-7e91fddf9208	2026-02-10 13:36:10.215364+00	OWNER	dcc412fd-0ce6-4967-b8d7-1f6b9332d6e5	a6e06fec-691f-459c-85b4-098a8cb2a786
df224930-6e1b-49e7-bfb7-af44c0c1ddcb	2026-02-11 00:23:28.642359+00	MEMBER	dcc412fd-0ce6-4967-b8d7-1f6b9332d6e5	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
\.


--
-- Data for Name: households; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.households (id, created_at, invite_code, name) FROM stdin;
dcc412fd-0ce6-4967-b8d7-1f6b9332d6e5	2026-02-10 13:36:10.205588+00	96114BD1	Poelmans
\.


--
-- Data for Name: passkey_challenges; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.passkey_challenges (id, created_at, options_json, challenge_type, user_id) FROM stdin;
\.


--
-- Data for Name: passkey_credentials; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.passkey_credentials (id, created_at, credential_id, last_used_at, public_key_cose, signature_count, user_id) FROM stdin;
\.


--
-- Data for Name: savings_goals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.savings_goals (id, auto_enabled, created_at, currency, current_amount, last_applied_month, monthly_contribution, name, target_amount, updated_at, user_id) FROM stdin;
\.


--
-- Data for Name: transaction_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transaction_categories (id, created_at, name, updated_at, user_id) FROM stdin;
a71e8816-38a4-4b51-8286-59974195a4d4	2026-02-10 23:58:01.395376+00	Boodschappen	2026-02-10 23:58:01.395376+00	a6e06fec-691f-459c-85b4-098a8cb2a786
125fbd43-c000-4240-98da-ee9e0494c749	2026-02-10 23:58:01.41926+00	Horeca	2026-02-10 23:58:01.41926+00	a6e06fec-691f-459c-85b4-098a8cb2a786
6732779f-1743-4e2c-8864-659c8acc9028	2026-02-10 23:58:01.427343+00	Transport	2026-02-10 23:58:01.427343+00	a6e06fec-691f-459c-85b4-098a8cb2a786
d00a4dba-8a65-4159-a322-a25ec3fd5eed	2026-02-10 23:58:01.434009+00	Shopping	2026-02-10 23:58:01.434009+00	a6e06fec-691f-459c-85b4-098a8cb2a786
1890d5a8-a078-485f-9f1c-5a1940eb452c	2026-02-10 23:58:01.437741+00	Abonnementen	2026-02-10 23:58:01.437741+00	a6e06fec-691f-459c-85b4-098a8cb2a786
36ec6d5e-6c03-4afd-a0ab-c0b2da93f937	2026-02-10 23:58:01.442126+00	Utilities	2026-02-10 23:58:01.442126+00	a6e06fec-691f-459c-85b4-098a8cb2a786
77ce04d4-91c7-4273-a1b5-b57b667d79f3	2026-02-10 23:58:01.446597+00	Huur/Hypotheek	2026-02-10 23:58:01.446597+00	a6e06fec-691f-459c-85b4-098a8cb2a786
0f493840-4e28-4654-b96e-1609f9b3c606	2026-02-10 23:58:01.45271+00	Gezondheid	2026-02-10 23:58:01.45271+00	a6e06fec-691f-459c-85b4-098a8cb2a786
4651f698-a496-4a1a-b0e5-c75b58283859	2026-02-10 23:58:01.45872+00	Onderwijs	2026-02-10 23:58:01.45872+00	a6e06fec-691f-459c-85b4-098a8cb2a786
a1798417-5fa6-4edb-b2a6-570501a387bb	2026-02-10 23:58:01.462823+00	Cash	2026-02-10 23:58:01.462823+00	a6e06fec-691f-459c-85b4-098a8cb2a786
a85423df-51d3-4619-aecf-2044bb03b212	2026-02-10 23:58:01.46643+00	Transfer	2026-02-10 23:58:01.46643+00	a6e06fec-691f-459c-85b4-098a8cb2a786
2fa0fb56-d097-4864-b4f2-6e9d515ddd5f	2026-02-10 23:58:01.470133+00	Inkomen	2026-02-10 23:58:01.470133+00	a6e06fec-691f-459c-85b4-098a8cb2a786
2f608ad9-19fc-492a-9058-a4ff804b6527	2026-02-10 23:58:01.473522+00	Crypto	2026-02-10 23:58:01.473522+00	a6e06fec-691f-459c-85b4-098a8cb2a786
c63e719a-2dae-46ed-bb67-95bffe969b7e	2026-02-10 23:58:01.476038+00	Overig	2026-02-10 23:58:01.476038+00	a6e06fec-691f-459c-85b4-098a8cb2a786
9e131dad-4e5e-42ac-9277-b2d702a7cf00	2026-02-11 00:00:27.504164+00	Sparen	2026-02-11 00:00:27.504164+00	a6e06fec-691f-459c-85b4-098a8cb2a786
2f62ca06-17e1-49df-befd-9652f2f1749a	2026-02-11 00:00:37.271141+00	Pensioensparen	2026-02-11 00:00:37.271141+00	a6e06fec-691f-459c-85b4-098a8cb2a786
29efe0e0-1601-49ab-9ba7-ed3bcfc6bd76	2026-02-11 00:22:31.694944+00	Boodschappen	2026-02-11 00:22:31.694944+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
2a8036a1-cded-4c27-92bf-c78e6a7de2e5	2026-02-11 00:22:31.730512+00	Horeca	2026-02-11 00:22:31.730512+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
91f828b5-7ea4-4d8b-b3c2-fdad185fb697	2026-02-11 00:22:31.738795+00	Transport	2026-02-11 00:22:31.738795+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
27e883c7-e126-4266-b904-43850c29a3bd	2026-02-11 00:22:31.752604+00	Shopping	2026-02-11 00:22:31.752604+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
9459b1c0-c2d5-4b2f-8e31-22d3ca1fa69d	2026-02-11 00:22:31.762329+00	Abonnementen	2026-02-11 00:22:31.762329+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
46b58bc0-5c64-4b9a-8559-5502661fd4d0	2026-02-11 00:22:31.77297+00	Utilities	2026-02-11 00:22:31.77297+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
1ab1a0b4-d216-4964-83e4-c2e8432ee6f7	2026-02-11 00:22:31.785219+00	Huur/Hypotheek	2026-02-11 00:22:31.785219+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
13804a89-0c01-4985-8361-79c5a22320ba	2026-02-11 00:22:31.826309+00	Gezondheid	2026-02-11 00:22:31.826309+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
dd47fc0b-8e99-4a2d-94a5-c5916aec1fc5	2026-02-11 00:22:31.866265+00	Onderwijs	2026-02-11 00:22:31.866265+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
0575639f-fea5-4eed-b89d-d2df1ccb4db0	2026-02-11 00:22:31.876418+00	Cash	2026-02-11 00:22:31.876418+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
bfdc77e8-8c42-45af-be21-766c1fd09891	2026-02-11 00:22:31.883983+00	Transfer	2026-02-11 00:22:31.883983+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
faac2019-86bd-4b1a-9ca6-eba6ca024bd6	2026-02-11 00:22:31.88703+00	Inkomen	2026-02-11 00:22:31.88703+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
81c0d742-7c83-4787-aa14-dcdc4f729167	2026-02-11 00:22:31.892849+00	Crypto	2026-02-11 00:22:31.892849+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
b8524546-a8f6-4aac-974a-961490ac72f9	2026-02-11 00:22:31.898756+00	Overig	2026-02-11 00:22:31.898756+00	a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, created_at, email, password_hash) FROM stdin;
a6e06fec-691f-459c-85b4-098a8cb2a786	2026-02-10 10:10:20.534132+00	sampoelmans@gmail.com	$2a$10$u9LUtNjcDPHYGilGOmUE3ue8XfT8FtGCIYxg50rtMqFzH1cyiZLPW
a0d3a806-2a5d-428a-b2bd-c5ce6d6fe3e0	2026-02-11 00:22:31.614141+00	hanne.lieten@gmail.com	$2a$10$.BTyUpKK9CMBSjQC7iwikeGdcNejMbDOEPmYnvVt0npNOILs2fIeO
\.


--
-- Name: account_transactions account_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_transactions
    ADD CONSTRAINT account_transactions_pkey PRIMARY KEY (id);


--
-- Name: category_overrides category_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_overrides
    ADD CONSTRAINT category_overrides_pkey PRIMARY KEY (id);


--
-- Name: connections connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_pkey PRIMARY KEY (id);


--
-- Name: financial_accounts financial_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_accounts
    ADD CONSTRAINT financial_accounts_pkey PRIMARY KEY (id);


--
-- Name: household_members household_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.household_members
    ADD CONSTRAINT household_members_pkey PRIMARY KEY (id);


--
-- Name: households households_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.households
    ADD CONSTRAINT households_pkey PRIMARY KEY (id);


--
-- Name: passkey_challenges passkey_challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_challenges
    ADD CONSTRAINT passkey_challenges_pkey PRIMARY KEY (id);


--
-- Name: passkey_credentials passkey_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_credentials
    ADD CONSTRAINT passkey_credentials_pkey PRIMARY KEY (id);


--
-- Name: savings_goals savings_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.savings_goals
    ADD CONSTRAINT savings_goals_pkey PRIMARY KEY (id);


--
-- Name: transaction_categories transaction_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_categories
    ADD CONSTRAINT transaction_categories_pkey PRIMARY KEY (id);


--
-- Name: transaction_categories uk3p3nay8js0mp8mex6wmbggojv; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_categories
    ADD CONSTRAINT uk3p3nay8js0mp8mex6wmbggojv UNIQUE (user_id, name);


--
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- Name: households uk_8icf8sy14mocagr0qdqido5cs; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.households
    ADD CONSTRAINT uk_8icf8sy14mocagr0qdqido5cs UNIQUE (invite_code);


--
-- Name: passkey_credentials uk_qenmfnuyo3mltfys67t14xel2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_credentials
    ADD CONSTRAINT uk_qenmfnuyo3mltfys67t14xel2 UNIQUE (credential_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: household_members fk1qcyeyx7v52432f6hyswues69; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.household_members
    ADD CONSTRAINT fk1qcyeyx7v52432f6hyswues69 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: passkey_credentials fk2x8cssws56ojkswnt4i40gajm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_credentials
    ADD CONSTRAINT fk2x8cssws56ojkswnt4i40gajm FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: savings_goals fkcxl8rfkv17sumgm83nx0pl2x8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.savings_goals
    ADD CONSTRAINT fkcxl8rfkv17sumgm83nx0pl2x8 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: financial_accounts fkgdvrepwrjv07epsiqn7jdl5b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_accounts
    ADD CONSTRAINT fkgdvrepwrjv07epsiqn7jdl5b2 FOREIGN KEY (household_id) REFERENCES public.households(id);


--
-- Name: financial_accounts fkhgd0xu9pvj7o8drppke555u2w; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_accounts
    ADD CONSTRAINT fkhgd0xu9pvj7o8drppke555u2w FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: household_members fkits4dus4oxqsobbp02l23iw8x; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.household_members
    ADD CONSTRAINT fkits4dus4oxqsobbp02l23iw8x FOREIGN KEY (household_id) REFERENCES public.households(id);


--
-- Name: connections fkltpo1ymtaafd67hx5tls1db6u; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT fkltpo1ymtaafd67hx5tls1db6u FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: category_overrides fkn9ts6f948n4sbfrt44k4fw37g; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_overrides
    ADD CONSTRAINT fkn9ts6f948n4sbfrt44k4fw37g FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: transaction_categories fkrm96re41tsk3wa4layfpqevvi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_categories
    ADD CONSTRAINT fkrm96re41tsk3wa4layfpqevvi FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: account_transactions fks9edunf00y0aak9w863lc2b4o; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_transactions
    ADD CONSTRAINT fks9edunf00y0aak9w863lc2b4o FOREIGN KEY (account_id) REFERENCES public.financial_accounts(id);


--
-- Name: financial_accounts fksqsw97ywddd8enc53ke2m6nfi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_accounts
    ADD CONSTRAINT fksqsw97ywddd8enc53ke2m6nfi FOREIGN KEY (connection_id) REFERENCES public.connections(id);


--
-- Name: passkey_challenges fkyi4ab5euqt781ls63q3uco7k; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passkey_challenges
    ADD CONSTRAINT fkyi4ab5euqt781ls63q3uco7k FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict OyceqMIC7HuSjpNMKqsD21PgMAAHKxleqzqRgz5fbswhLw69flJU4OSkyO5QDhW

