--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-08-26 18:28:16

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS public;


--
-- TOC entry 4943 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 24717)
-- Name: calendario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendario (
    fecha date NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 24685)
-- Name: detalle_venta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detalle_venta (
    id integer NOT NULL,
    venta_id integer,
    nombre text NOT NULL,
    cantidad integer NOT NULL,
    precio numeric NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 24684)
-- Name: detalle_venta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.detalle_venta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4944 (class 0 OID 0)
-- Dependencies: 221
-- Name: detalle_venta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.detalle_venta_id_seq OWNED BY public.detalle_venta.id;


--
-- TOC entry 226 (class 1259 OID 24709)
-- Name: egresos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.egresos (
    id integer NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 225 (class 1259 OID 24708)
-- Name: egresos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.egresos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4945 (class 0 OID 0)
-- Dependencies: 225
-- Name: egresos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.egresos_id_seq OWNED BY public.egresos.id;


--
-- TOC entry 218 (class 1259 OID 24619)
-- Name: productos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.productos (
    id integer NOT NULL,
    nombre character varying(255),
    precio numeric(5,2),
    descripcion text,
    codigo character varying(50),
    stock integer,
    status boolean DEFAULT true
);


--
-- TOC entry 217 (class 1259 OID 24618)
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4946 (class 0 OID 0)
-- Dependencies: 217
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- TOC entry 224 (class 1259 OID 24699)
-- Name: reportes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reportes (
    id integer NOT NULL,
    productos jsonb NOT NULL,
    total numeric NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 223 (class 1259 OID 24698)
-- Name: reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4947 (class 0 OID 0)
-- Dependencies: 223
-- Name: reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reportes_id_seq OWNED BY public.reportes.id;


--
-- TOC entry 220 (class 1259 OID 24675)
-- Name: ventas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ventas (
    id integer NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    total numeric NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 24722)
-- Name: resumen_mensual; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.resumen_mensual AS
 WITH ventas_por_mes AS (
         SELECT (date_trunc('month'::text, ventas.fecha))::date AS mes_inicio,
            sum(ventas.total) AS ingresos,
            count(DISTINCT (ventas.fecha)::date) AS dias_con_ventas
           FROM public.ventas
          GROUP BY ((date_trunc('month'::text, ventas.fecha))::date)
        ), egresos_por_mes AS (
         SELECT (date_trunc('month'::text, egresos.fecha))::date AS mes_inicio,
            sum(egresos.monto) AS egresos
           FROM public.egresos
          GROUP BY ((date_trunc('month'::text, egresos.fecha))::date)
        ), dias_totales_por_mes AS (
         SELECT (date_trunc('month'::text, (calendario.fecha)::timestamp with time zone))::date AS mes_inicio,
            count(*) AS dias_en_mes
           FROM public.calendario
          GROUP BY ((date_trunc('month'::text, (calendario.fecha)::timestamp with time zone))::date)
        )
 SELECT to_char((vpm.mes_inicio)::timestamp with time zone, 'YYYY-MM'::text) AS mes,
    vpm.ingresos,
    COALESCE(epm.egresos, (0)::numeric) AS egresos,
    dtpm.dias_en_mes,
    vpm.dias_con_ventas,
    (dtpm.dias_en_mes - vpm.dias_con_ventas) AS dias_no_trabajados,
    (vpm.ingresos - COALESCE(epm.egresos, (0)::numeric)) AS ganancia
   FROM ((ventas_por_mes vpm
     JOIN dias_totales_por_mes dtpm ON ((dtpm.mes_inicio = vpm.mes_inicio)))
     LEFT JOIN egresos_por_mes epm ON ((epm.mes_inicio = vpm.mes_inicio)))
  ORDER BY vpm.mes_inicio DESC
  WITH NO DATA;


--
-- TOC entry 219 (class 1259 OID 24674)
-- Name: ventas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ventas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4948 (class 0 OID 0)
-- Dependencies: 219
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- TOC entry 4774 (class 2604 OID 24688)
-- Name: detalle_venta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_venta ALTER COLUMN id SET DEFAULT nextval('public.detalle_venta_id_seq'::regclass);


--
-- TOC entry 4777 (class 2604 OID 24712)
-- Name: egresos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egresos ALTER COLUMN id SET DEFAULT nextval('public.egresos_id_seq'::regclass);


--
-- TOC entry 4770 (class 2604 OID 24622)
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- TOC entry 4775 (class 2604 OID 24702)
-- Name: reportes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes ALTER COLUMN id SET DEFAULT nextval('public.reportes_id_seq'::regclass);


--
-- TOC entry 4772 (class 2604 OID 24678)
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- TOC entry 4790 (class 2606 OID 24721)
-- Name: calendario calendario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendario
    ADD CONSTRAINT calendario_pkey PRIMARY KEY (fecha);


--
-- TOC entry 4784 (class 2606 OID 24692)
-- Name: detalle_venta detalle_venta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_venta
    ADD CONSTRAINT detalle_venta_pkey PRIMARY KEY (id);


--
-- TOC entry 4788 (class 2606 OID 24715)
-- Name: egresos egresos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egresos
    ADD CONSTRAINT egresos_pkey PRIMARY KEY (id);


--
-- TOC entry 4780 (class 2606 OID 24624)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- TOC entry 4786 (class 2606 OID 24707)
-- Name: reportes reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_pkey PRIMARY KEY (id);


--
-- TOC entry 4782 (class 2606 OID 24683)
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- TOC entry 4791 (class 2606 OID 24693)
-- Name: detalle_venta detalle_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_venta
    ADD CONSTRAINT detalle_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id);


-- Completed on 2025-08-26 18:28:16

--
-- PostgreSQL database dump complete
--

