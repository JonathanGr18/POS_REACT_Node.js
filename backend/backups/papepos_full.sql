--
-- PostgreSQL database dump
--

\restrict gFR3BnNzaSspxBj2Y6RAyTQ9ga4WeaF4RX73OS3pGelGPfSJBweGRQrEOXc45wY

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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

ALTER TABLE IF EXISTS ONLY public.tienda_productos DROP CONSTRAINT IF EXISTS tienda_productos_tienda_id_fkey;
ALTER TABLE IF EXISTS ONLY public.lista_compras DROP CONSTRAINT IF EXISTS lista_compras_tienda_id_fkey;
ALTER TABLE IF EXISTS ONLY public.detalle_venta DROP CONSTRAINT IF EXISTS detalle_venta_venta_id_fkey;
DROP INDEX IF EXISTS public.idx_ventas_metodo_pago;
DROP INDEX IF EXISTS public.idx_ventas_fecha;
DROP INDEX IF EXISTS public.idx_tienda_productos_tienda_id;
DROP INDEX IF EXISTS public.idx_productos_stock;
DROP INDEX IF EXISTS public.idx_productos_codigo;
DROP INDEX IF EXISTS public.idx_productos_categoria;
DROP INDEX IF EXISTS public.idx_lista_compras_tienda_id;
DROP INDEX IF EXISTS public.idx_egresos_fecha;
DROP INDEX IF EXISTS public.idx_detalle_venta_venta_id;
DROP INDEX IF EXISTS public.idx_detalle_venta_nombre;
ALTER TABLE IF EXISTS ONLY public.ventas DROP CONSTRAINT IF EXISTS ventas_pkey;
ALTER TABLE IF EXISTS ONLY public.tiendas DROP CONSTRAINT IF EXISTS tiendas_pkey;
ALTER TABLE IF EXISTS ONLY public.tienda_productos DROP CONSTRAINT IF EXISTS tienda_productos_pkey;
ALTER TABLE IF EXISTS ONLY public.productos DROP CONSTRAINT IF EXISTS productos_pkey;
ALTER TABLE IF EXISTS ONLY public.productos DROP CONSTRAINT IF EXISTS productos_codigo_key;
ALTER TABLE IF EXISTS ONLY public.lista_compras DROP CONSTRAINT IF EXISTS lista_compras_pkey;
ALTER TABLE IF EXISTS ONLY public.egresos DROP CONSTRAINT IF EXISTS egresos_pkey;
ALTER TABLE IF EXISTS ONLY public.detalle_venta DROP CONSTRAINT IF EXISTS detalle_venta_pkey;
ALTER TABLE IF EXISTS public.ventas ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tiendas ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tienda_productos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.productos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.lista_compras ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.egresos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.detalle_venta ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.ventas_id_seq;
DROP TABLE IF EXISTS public.ventas;
DROP SEQUENCE IF EXISTS public.tiendas_id_seq;
DROP TABLE IF EXISTS public.tiendas;
DROP SEQUENCE IF EXISTS public.tienda_productos_id_seq;
DROP TABLE IF EXISTS public.tienda_productos;
DROP SEQUENCE IF EXISTS public.productos_id_seq;
DROP TABLE IF EXISTS public.productos;
DROP SEQUENCE IF EXISTS public.lista_compras_id_seq;
DROP TABLE IF EXISTS public.lista_compras;
DROP SEQUENCE IF EXISTS public.egresos_id_seq;
DROP TABLE IF EXISTS public.egresos;
DROP SEQUENCE IF EXISTS public.detalle_venta_id_seq;
DROP TABLE IF EXISTS public.detalle_venta;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: detalle_venta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detalle_venta (
    id integer NOT NULL,
    venta_id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    cantidad integer NOT NULL,
    precio numeric(10,2) NOT NULL
);


--
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
-- Name: detalle_venta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.detalle_venta_id_seq OWNED BY public.detalle_venta.id;


--
-- Name: egresos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.egresos (
    id integer NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    concepto text
);


--
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
-- Name: egresos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.egresos_id_seq OWNED BY public.egresos.id;


--
-- Name: lista_compras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lista_compras (
    id integer NOT NULL,
    tienda_id integer,
    nombre_producto character varying(200) NOT NULL,
    cantidad integer DEFAULT 1 NOT NULL,
    precio_ref numeric(10,2),
    notas text,
    completado boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: lista_compras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lista_compras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lista_compras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lista_compras_id_seq OWNED BY public.lista_compras.id;


--
-- Name: productos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.productos (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    precio numeric(10,2) NOT NULL,
    descripcion text DEFAULT 'Sin descripcion'::text,
    codigo character varying(100) NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    status boolean DEFAULT true,
    imagen_url character varying(500),
    categoria character varying(100) DEFAULT 'General'::character varying,
    precio_costo numeric(10,2) DEFAULT 0,
    stock_minimo integer DEFAULT 15
);


--
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
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- Name: tienda_productos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tienda_productos (
    id integer NOT NULL,
    tienda_id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    precio numeric(10,2),
    notas text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: tienda_productos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tienda_productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tienda_productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tienda_productos_id_seq OWNED BY public.tienda_productos.id;


--
-- Name: tiendas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tiendas (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    direccion text,
    telefono character varying(50),
    notas text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: tiendas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tiendas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tiendas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tiendas_id_seq OWNED BY public.tiendas.id;


--
-- Name: ventas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ventas (
    id integer NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    total numeric(10,2) NOT NULL,
    descuento numeric(10,2) DEFAULT 0,
    monto_recibido numeric(10,2) DEFAULT 0,
    metodo_pago character varying(20) DEFAULT 'efectivo'::character varying NOT NULL
);


--
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
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- Name: detalle_venta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_venta ALTER COLUMN id SET DEFAULT nextval('public.detalle_venta_id_seq'::regclass);


--
-- Name: egresos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egresos ALTER COLUMN id SET DEFAULT nextval('public.egresos_id_seq'::regclass);


--
-- Name: lista_compras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lista_compras ALTER COLUMN id SET DEFAULT nextval('public.lista_compras_id_seq'::regclass);


--
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- Name: tienda_productos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tienda_productos ALTER COLUMN id SET DEFAULT nextval('public.tienda_productos_id_seq'::regclass);


--
-- Name: tiendas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tiendas ALTER COLUMN id SET DEFAULT nextval('public.tiendas_id_seq'::regclass);


--
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- Data for Name: detalle_venta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.detalle_venta (id, venta_id, nombre, cantidad, precio) FROM stdin;
5	5	Impresion	1	2.00
6	6	Impresion 	1	15.00
7	6	Impresion	2	10.00
13	9	Impresion B/N	4	2.00
16	11	Impresion B/N	4	2.00
17	12	Impresion B/N	7	2.00
18	13	Impresion B/N	7	2.00
19	14	Impresion B/N	1	2.00
20	15	Impresion B/N	9	2.00
25	19	Impresion B/N	8	2.00
27	21	Impresion B/N	2	2.00
28	22	Impresion B/N	1	2.00
34	24	Impresion B/N	1	2.00
35	25	Impresion B/N	2	2.00
42	28	Impresion B/N	8	2.00
49	33	Impresion B/N	6	2.00
51	34	Cartulina	1	7.00
54	34	Impresion B/N	1	2.00
57	37	Impresion B/N	1	2.00
59	39	Impresion B/N	4	2.00
61	40	Impresion B/N	9	2.00
62	41	Impresion B/N	1	2.00
68	45	Cartulina	1	7.00
73	48	estrella mediana	2	20.00
79	51	hoja color	1	1.50
80	51	hoja color	2	1.50
81	51	hoja color	1	1.50
82	51	hoja color	1	1.50
83	51	hoja color	1	1.50
84	51	hoja color	1	1.50
85	51	hoja color	1	1.50
86	51	hoja color	1	1.50
87	51	hoja color	1	1.50
88	51	hoja color	2	1.50
94	55	Impresion B/N	4	2.00
95	56	marcador pizarron	2	20.00
96	56	hoja color	1	32.00
104	60	cuaderno profecionl cocido	1	75.00
109	63	hoja color	3	1.50
110	63	hoja color	2	1.50
111	63	hoja color	2	1.50
114	64	fomi t/carta	2	4.50
115	64	fomi t/carta	2	4.50
118	64	cubo 15x15	1	45.00
122	66	Impresion B/N	9	2.00
123	67	Impresion B/N	11	2.00
127	69	Cartulina	1	7.00
129	69	Impresion B/N	4	2.00
141	76	Impresion B/N	3	2.00
152	82	bolsa grande	1	28.00
154	83	Impresion B/N	2	2.00
160	86	Impresion B/N	2	2.00
162	87	moño 	1	28.00
165	90	bolsa grande	1	28.00
167	91	Cartulina	1	7.00
168	91	Impresion B/N	1	2.00
170	93	papel regalo	1	9.00
171	93	bolsa jumbo	1	45.00
192	102	moño 	1	28.00
215	110	tijera zic zac	1	25.00
216	110	fomi t/carta	2	4.50
218	110	estrella grande	2	20.00
220	112	Impresion B/N	1	2.00
231	119	Impresion B/N	6	2.00
234	120	hoja color	2	1.50
247	127	Cartulina	1	7.00
253	130	hoja color	2	1.50
258	133	marcador  agua 	1	15.00
264	136	Cartulina	1	7.00
268	139	Impresion B/N	3	2.00
271	141	Impresion B/N	1	2.00
282	146	Impresion B/N	8	2.00
299	157	Impresion B/N	1	2.00
301	158	papel regalo	1	9.00
306	161	Impresion B/N	3	2.00
317	168	Impresion B/N	2	2.00
334	178	papel regalo	2	9.00
336	179	Cartulina	1	7.00
338	180	Impresion B/N	1	2.00
342	181	hoja color	1	1.50
344	183	Impresion B/N	13	2.00
351	186	libreta mini	1	20.00
355	188	papel regalo	1	9.00
363	193	Impresion B/N	1	2.00
364	194	Impresion B/N	2	2.00
409	213	hoja color	1	1.50
410	213	hoja color	1	1.50
416	216	Impresion B/N	2	2.00
423	219	Impresion B/N	5	2.00
427	221	Impresion B/N	2	2.00
432	223	libreta mini	1	20.00
445	228	bolsa regalo	1	28.00
446	229	Cartulina	1	7.00
465	239	broche retractil	1	25.00
466	239	Cartulina	5	7.00
469	241	Impresion B/N	3	2.00
474	244	hoja blanca	1	13.00
480	246	Impresion B/N	1	2.00
490	250	Impresion B/N	4	2.00
495	252	Impresion B/N	1	2.00
496	253	Impresion B/N	6	2.00
509	261	Cartulina	4	7.00
525	268	Impresion B/N	1	2.00
540	273	Impresion B/N	2	2.00
546	276	rosa infinita	1	90.00
549	277	Impresion B/N	4	2.00
554	279	hoja color	4	1.50
555	279	hoja color	4	1.50
556	279	hoja color	4	1.50
559	280	hoja color	3	1.50
560	280	hoja color	3	1.50
562	281	Impresion B/N	1	2.00
564	282	Impresion B/N	3	2.00
566	282	Cartulina	1	7.00
570	284	Impresion B/N	7	2.00
572	285	Impresion B/N	4	2.00
573	286	Impresion B/N	10	2.00
586	293	hoja blanca	1	13.00
594	299	hoja color	1	1.50
595	299	hoja color	1	1.50
601	299	Barra Silicon	4	4.00
627	313	hoja color	1	1.50
628	313	hoja color	1	1.50
629	313	hoja color	1	1.50
630	313	hoja color	1	1.50
631	313	hoja color	1	1.50
632	313	hoja color	1	1.50
633	313	hoja color	1	1.50
634	313	hoja color	1	1.50
635	313	hoja color	1	1.50
636	313	hoja color	1	1.50
637	313	hoja color	1	1.50
638	313	hoja color	1	1.50
639	313	hoja color	1	1.50
640	313	hoja color	1	1.50
641	313	hoja color	1	1.50
642	313	hoja color	1	1.50
643	313	hoja color	1	1.50
644	313	hoja color	1	1.50
645	313	hoja color	1	1.50
646	313	hoja color	1	1.50
654	318	Impresion B/N	26	2.00
657	319	Impresion B/N	1	2.00
662	322	Impresion B/N	1	2.00
665	325	Impresion B/N	1	2.00
666	326	Cartulina	2	7.00
675	328	Impresion B/N	6	2.00
681	332	hoja color	1	1.50
682	332	hoja color	1	1.50
683	332	hoja color	1	1.50
684	332	hoja color	1	1.50
685	332	hoja color	1	1.50
686	332	hoja color	1	1.50
687	332	hoja color	1	1.50
688	332	hoja color	1	1.50
689	332	hoja color	1	1.50
690	332	hoja color	1	1.50
692	333	Cartulina	1	7.00
694	335	Cartulina	5	7.00
701	340	Impresion B/N	1	2.00
708	343	hoja color	1	1.50
709	343	hoja color	1	1.50
710	343	hoja color	1	1.50
711	343	Cartulina	1	7.00
716	346	hoja blanca 	50	1.00
727	347	hoja color	2	1.50
728	347	hoja color	2	1.50
729	347	hoja color	2	1.50
738	349	Impresion B/N	3	2.00
746	352	hoja color	2	1.50
747	352	hoja color	2	1.50
756	355	Cartulina	1	7.00
757	356	Cartulina	1	15.00
759	356	hoja color	1	1.50
760	356	hoja color	1	1.50
761	356	hoja color	1	1.50
762	356	hoja color	1	1.50
763	356	hoja color	1	1.50
764	356	hoja color	1	1.50
767	358	Cartulina	1	7.00
770	360	Cartulina	1	7.00
782	366	Impresion B/N	3	2.00
794	371	Impresion B/N	3	2.00
798	373	Cartulina	1	7.00
806	378	Cartulina	1	7.00
807	379	hoja mantequilla	1	3.50
812	382	cuaderno frances cocido	1	55.00
819	384	Impresion B/N	1	2.00
821	385	colmilo kit	1	25.00
823	386	Impresion B/N	1	2.00
824	387	cuaderno frances	1	35.00
828	388	Impresion B/N	1	2.00
830	389	Impresion B/N	7	2.00
835	392	Impresion B/N	3	2.00
841	394	hoja color	1	1.50
845	397	Impresion B/N	2	2.00
848	398	hoja color	2	1.50
849	398	hoja color	2	1.50
850	398	hoja blanca	1	13.00
862	401	pluma c/8 colores	1	25.00
869	405	Impresion B/N	8	2.00
870	406	Impresion B/N	4	2.00
877	409	hoja recopilador	1	60.00
878	409	Cartulina	1	7.00
885	413	Cartulina	1	7.00
893	418	Barra Silicon	2	4.00
897	420	Cartulina	1	15.00
902	422	hoja color	1	1.50
903	422	hoja color	1	1.50
904	422	hoja color	2	1.50
905	422	hoja color	1	1.50
907	423	telaraña	1	60.00
916	427	hoja color	10	1.50
919	430	Impresion B/N	3	2.00
933	438	vela electrica	2	12.00
936	440	Impresion B/N	1	2.00
937	441	vela electrica	1	12.00
961	453	broche retractil	1	25.00
964	456	Cartulina	1	15.00
965	456	hoja color	3	1.50
966	456	hoja color	3	1.50
967	456	hoja color	3	1.50
970	457	calaverita de azucar	1	25.00
982	464	marcador  agua 	1	15.00
983	464	marcador  agua 	1	15.00
1000	471	Impresion B/N	5	2.00
1005	473	Barra Silicon	1	4.00
1007	474	hoja blanca	1	25.00
1020	481	Impresion B/N	3	2.00
1021	482	Impresion B/N	2	2.00
1023	483	Cartulina	1	15.00
1031	487	Impresion B/N	8	2.00
1033	489	set pedicure	1	40.00
1038	490	pluma c/8 colores	1	25.00
1048	493	Impresion B/N	5	2.00
1051	495	Impresion B/N	1	2.00
1056	497	Impresion B/N	25	2.00
1057	497	vela electrica	1	12.00
1058	497	calabaza electica 	2	25.00
1059	497	Barra Silicon	5	4.00
1071	500	tira decorada	1	45.00
1072	501	calaverita de azucar	3	25.00
1073	502	hoja mantequilla	2	3.50
1083	506	Cartulina	2	15.00
1084	506	hoja color	4	1.50
1085	506	hoja color	4	1.50
1113	521	Barra Silicon	1	4.00
1120	525	Impresion B/N	6	2.00
1123	527	estrella grande	1	20.00
1125	529	Impresion B/N	1	2.00
1126	530	estrella grande	1	20.00
1137	536	porto gafet	1	35.00
1139	537	Impresion B/N	6	2.00
1143	539	Impresion B/N	4	2.00
1155	548	vela electrica	3	12.00
1163	553	Impresion B/N	11	2.00
1164	554	Impresion B/N	9	2.00
1165	555	Impresion B/N	5	2.00
1174	560	Impresion B/N	6	2.00
1177	561	hoja color	2	1.50
1178	561	hoja color	2	1.50
1179	561	hoja color	2	1.50
1180	561	hoja color	2	1.50
1205	568	Barra Silicon	5	4.00
1207	570	Impresion B/N	3	2.00
1213	574	Cartulina	1	15.00
1214	574	Cartulina	2	15.00
1221	575	Barra Silicon	1	4.00
1238	582	Impresion B/N	25	2.00
1242	584	hoja color	4	1.50
1243	585	Impresion B/N	2	2.00
1257	589	Impresion B/N	4	2.00
1281	595	hoja color	2	1.50
1282	596	hoja color	3	1.50
1288	599	Barra Silicon	5	4.00
1290	599	tijera zic zac	1	25.00
1318	614	hoja color	1	1.50
1330	620	Impresion B/N	3	2.00
1343	625	Barra Silicon	2	4.00
1356	626	Impresion B/N	1	2.00
1357	627	hoja color	1	1.50
1358	627	hoja color	1	1.50
1359	627	hoja color	1	1.50
1360	627	hoja color	1	1.50
1361	627	hoja color	1	1.50
1363	627	Barra Silicon	2	4.00
1396	641	Cartulina	1	15.00
1403	645	Impresion B/N	2	2.00
1406	646	Impresion B/N	12	2.00
1408	647	Impresion B/N	6	2.00
1425	655	Impresion B/N	8	2.00
1433	659	cepillo	1	40.00
1438	662	Impresion B/N	4	2.00
1446	667	calaverita de azucar	2	25.00
1450	668	monedero  kity	1	40.00
1451	668	monedero oso	1	35.00
1454	670	pluma color	8	4.00
1455	670	pluma color	7	2.00
1465	676	Impresion B/N	13	2.00
1468	678	Impresion B/N	5	2.00
1471	680	calabaza electrica	1	35.00
1492	687	Impresion B/N	13	2.00
1504	690	opalina 	3	5.00
1508	692	Cartulina	1	15.00
1514	695	Impresion B/N	1	2.00
1503	690	Silbato	1	17.00
1523	698	Impresion B/N	1	2.00
1527	701	Impresion B/N	2	2.00
1529	702	Impresion B/N	1	2.00
1533	704	Impresion B/N	3	2.00
1549	710	Barra Silicon	3	4.00
1561	716	Impresion B/N	1	2.00
1563	717	Cartulina	1	15.00
1576	720	Barra Silicon	5	4.00
1581	722	Impresion B/N	3	2.00
1582	723	hoja color	1	1.50
1583	723	hoja color	1	1.50
1586	724	Impresion B/N	5	2.00
1589	726	Impresion B/N	8	2.00
1593	727	Impresion B/N	1	2.00
1610	733	tijera zic zac	1	25.00
1613	735	marcador  agua 	1	15.00
1614	735	marcador  agua 	2	10.00
1622	739	hoja color	2	1.50
1623	739	hoja color	2	1.50
1624	739	hoja color	2	1.50
1632	745	tira decorada	1	45.00
1643	751	Impresion B/N	2	2.00
1666	762	hoja color	10	1.50
1687	772	hoja color	1	1.50
1688	772	hoja color	1	1.50
1689	772	hoja color	1	1.50
1690	772	hoja color	1	1.50
1694	773	Barra Silicon	2	10.00
1715	781	Impresion B/N	10	2.00
1716	782	Cartulina	1	15.00
1730	784	Barra Silicon	1	4.00
1731	785	cuaderno frances	1	35.00
1736	785	calcamonias	1	35.00
1742	789	Impresion B/N	14	2.00
1749	792	Impresion B/N	5	2.00
1755	795	cuaderno frances	1	35.00
1764	799	Impresion B/N	2	2.00
1700	776	Enmicado	7	25.00
1773	803	cuaderno frances	1	35.00
1776	804	Impresion B/N	9	2.00
1783	809	Impresion B/N	14	2.00
1789	812	Barra Silicon	3	4.00
1791	814	hoja blanca	2	45.00
1793	815	Barra Silicon	4	4.00
1794	816	hoja color	2	1.50
1800	817	papel picado 	1	20.00
1810	819	Impresion B/N	1	2.00
1814	821	calabaza electica 	2	25.00
1815	821	calabaza electrica	1	35.00
1817	821	vela electrica	1	12.00
1818	821	vaso hallowen	5	20.00
1819	822	vaso hallowen	2	20.00
1836	827	Cartulina	1	15.00
1843	830	Impresion B/N	11	2.00
1845	831	Impresion B/N	4	2.00
1851	832	papel picado 	1	20.00
1858	834	Impresion B/N	16	2.00
1867	836	Barra Silicon	4	4.00
1873	836	calaverita de azucar	2	25.00
1883	840	Impresion B/N	2	2.00
1886	843	Impresion B/N	17	2.00
1889	845	Impresion B/N	2	2.00
1900	850	calaverita de azucar	1	25.00
1901	851	Barra Silicon	4	4.00
1908	853	Impresion B/N	1	2.00
1913	854	Impresion B/N	3	2.00
1916	856	pluma tactil	1	15.00
1921	858	Impresion B/N	2	2.00
1925	860	hoja blanca	1	13.00
1930	862	Barra Silicon	5	4.00
1941	869	Impresion B/N	1	2.00
1947	873	papel picado 	2	20.00
1969	882	Impresion B/N	1	2.00
1981	888	papel picado 	1	20.00
1983	889	Barra Silicon	3	4.00
1995	896	Impresion B/N	1	2.00
1998	898	Barra Silicon	2	4.00
2000	899	Impresion B/N	2	2.00
2010	902	Impresion B/N	12	2.00
2011	903	Impresion B/N	11	2.00
2013	903	libreta chica y mediana	1	15.00
2021	905	Impresion B/N	12	2.00
2026	908	Barra Silicon	2	10.00
2035	913	Impresion B/N	1	2.00
2040	915	papel picado 	1	20.00
2046	916	hoja color	1	1.50
2047	916	hoja color	1	1.50
2050	919	papel picado 	1	20.00
2053	920	liga colores	2	10.00
2056	922	calaverita de azucar	1	25.00
2060	925	Impresion B/N	10	2.00
2074	930	Cartulina	1	15.00
2079	932	Impresion B/N	1	2.00
2085	935	Impresion B/N	10	2.00
2092	938	Barra Silicon	2	4.00
2103	946	papel picado 	1	20.00
2139	962	Impresion B/N	1	2.00
2145	963	papel picado 	1	20.00
2168	972	hoja color	1	1.50
2169	972	hoja color	1	1.50
2170	972	hoja color	1	1.50
2172	974	Impresion B/N	16	2.00
2188	978	Barra Silicon	2	4.00
2199	983	Barra Silicon	2	4.00
2220	986	Impresion B/N	1	2.00
2222	987	Impresion B/N	17	2.00
2224	989	Cartulina	2	15.00
2225	989	Impresion B/N	18	2.00
2235	992	papel picado 	1	20.00
2238	993	Impresion B/N	2	2.00
2241	994	Barra Silicon	4	4.00
2246	996	Barra Silicon	6	4.00
2247	996	hoja blanca	1	13.00
2251	999	Barra Silicon	3	4.00
2255	1001	raquetita	1	15.00
2256	1002	hoja color	4	1.50
2266	1008	estrella chica	1	20.00
2268	1009	estrella grande	1	20.00
2269	1010	Impresion B/N	28	2.00
2279	1016	hoja blanca	1	45.00
2281	1016	hoja color	3	1.50
2282	1017	calaverita de azucar	3	25.00
2288	1019	papel picado 	1	20.00
2296	1021	Barra Silicon	2	4.00
2315	1027	Impresion B/N	34	2.00
2316	1027	Cartulina	2	15.00
2323	1029	mascara 	1	25.00
2348	1037	Barra Silicon	2	4.00
2359	1043	Cartulina	2	15.00
2360	1043	hoja color	1	1.50
2362	1043	hoja color	2	1.50
2368	1048	papel picado 	1	20.00
2375	1050	papel picado 	1	20.00
2378	1050	Barra Silicon	3	4.00
2384	1052	Impresion B/N	3	2.00
2391	1055	hoja color	2	1.50
2392	1055	hoja color	2	1.50
2395	1057	Impresion B/N	7	2.00
2399	1058	Cartulina	1	15.00
2400	1059	Impresion B/N	5	2.00
2406	1061	hoja color	8	1.50
2422	1066	Impresion B/N	6	2.00
2428	1069	Cartulina	2	15.00
2429	1069	hoja color	2	1.50
2430	1069	Barra Silicon	3	4.00
2431	1070	Impresion B/N	9	2.00
2434	1071	Impresion B/N	31	2.00
2436	1071	hoja color	12	1.50
2439	1073	Barra Silicon	1	4.00
2452	1077	cuaderno frances cocido	1	55.00
2456	1081	Impresion B/N	3	2.00
2461	1083	papel picado 	4	20.00
2497	1117	Barra Silicon	2	4.00
2501	1118	papel picado 	1	20.00
2509	1120	papel picado 	1	20.00
2511	1121	Barra Silicon	3	4.00
2513	1122	hoja color	3	1.50
2515	1124	papel picado 	2	20.00
2517	1126	papel picado 	2	20.00
2522	1129	papel picado 	1	20.00
2523	1130	Barra Silicon	4	4.00
2530	1134	diadema	1	25.00
2536	1136	Impresion B/N	5	2.00
2542	1138	Barra Silicon	2	4.00
2548	1140	Barra Silicon	3	4.00
2583	1151	papel picado 	1	20.00
2592	1154	papel picado 	1	20.00
2596	1156	tira decorada	1	45.00
2597	1156	papel picado 	2	20.00
2605	1160	Impresion B/N	1	2.00
2606	1161	Impresion B/N	15	2.00
2608	1162	Impresion B/N	3	2.00
2609	1163	Barra Silicon	3	4.00
2623	1170	Impresion B/N	9	2.00
2661	1191	Impresion B/N	5	2.00
2666	1192	hoja color	1	1.50
2670	1195	Impresion B/N	3	2.00
2694	1207	Impresion B/N	4	2.00
2695	1208	Impresion B/N	2	2.00
2698	1210	Impresion B/N	5	2.00
2706	1211	Impresion B/N	1	2.00
2708	1212	hoja blanca	1	13.00
2716	1215	porto gafet	1	35.00
2718	1215	Impresion B/N	1	2.00
2721	1217	Impresion B/N	3	2.00
2722	1218	Impresion B/N	3	2.00
2725	1219	Impresion B/N	6	2.00
2728	1221	Impresion B/N	22	2.00
2732	1224	hoja color	1	1.50
2733	1224	hoja color	1	1.50
2739	1227	Barra Silicon	2	4.00
2756	1233	hoja color	2	1.50
2757	1233	hoja color	1	1.50
2758	1234	hoja color	1	1.50
2759	1234	hoja color	1	1.50
2760	1234	hoja color	1	1.50
2762	1236	Impresion B/N	5	2.00
2764	1237	hoja color	2	1.50
2765	1237	hoja color	2	1.50
2766	1237	hoja color	2	1.50
2767	1237	hoja color	1	1.50
2770	1239	Impresion B/N	1	2.00
2784	1248	Impresion B/N	2	2.00
2787	1251	Impresion B/N	32	2.00
2794	1254	hoja color	2	1.50
2796	1254	Barra Silicon	2	4.00
2798	1256	Impresion B/N	5	2.00
2799	1257	Barra Silicon	1	4.00
2805	1259	Impresion B/N	10	2.00
2811	1263	Cartulina	1	15.00
2814	1265	Impresion B/N	4	2.00
2818	1267	Impresion B/N	1	2.00
2822	1271	marcador pizarron	1	20.00
2828	1274	Impresion B/N	4	2.00
2829	1275	Impresion B/N	10	2.00
2834	1278	Impresion B/N	1	2.00
2835	1279	Impresion B/N	9	2.00
2840	1282	Impresion B/N	1	2.00
2843	1283	Impresion B/N	2	2.00
2850	1287	Impresion B/N	2	2.00
2856	1291	Impresion B/N	3	2.00
2858	1293	Impresion B/N	8	2.00
2865	1297	Impresion B/N	13	2.00
2866	1298	Impresion B/N	6	2.00
2899	1314	Impresion B/N	12	2.00
2901	1315	hoja milimetrica	5	1.50
2902	1316	Impresion B/N	2	2.00
2910	1319	cuaderno frances	1	35.00
2919	1323	trompo con luz	1	20.00
2927	1327	Barra Silicon	4	4.00
2963	1347	hoja color	2	1.50
2964	1347	hoja color	2	1.50
2965	1347	hoja blanca	1	13.00
2967	1347	Barra Silicon	5	4.00
2968	1348	hoja color	2	1.50
2969	1348	hoja color	2	1.50
2970	1348	hoja color	2	1.50
2971	1348	hoja color	2	1.50
2972	1348	hoja color	1	1.50
2973	1348	hoja color	2	1.50
2984	1354	Impresion B/N	17	2.00
2993	1357	hoja color	2	1.50
2994	1357	hoja color	2	1.50
2995	1357	hoja color	2	1.50
2996	1357	hoja color	2	1.50
2997	1357	hoja color	2	1.50
2998	1357	hoja color	2	1.50
2999	1357	hoja color	2	1.50
3000	1357	hoja color	2	1.50
3009	1360	hoja color	1	1.50
3016	1364	Cartulina	1	15.00
3017	1365	Impresion B/N	5	2.00
3020	1367	Barra Silicon	3	4.00
3022	1368	Impresion B/N	1	2.00
3037	1376	Impresion B/N	6	2.00
3050	1385	rimel	1	55.00
3052	1386	hoja color	1	1.50
3053	1386	hoja color	2	1.50
3057	1390	cuaderno frances	1	35.00
3075	1397	pluma jumbo	1	40.00
3081	1401	Impresion B/N	3	2.00
3087	1403	hoja color	1	1.50
3088	1403	hoja color	1	1.50
3089	1403	hoja color	1	1.50
3092	1406	hoja color	1	1.50
3093	1406	hoja color	1	1.50
3094	1406	hoja color	1	1.50
3095	1406	hoja color	1	1.50
3096	1406	hoja color	1	1.50
3097	1406	hoja color	1	1.50
3098	1406	hoja color	1	1.50
3103	1409	Impresion B/N	1	2.00
3124	1417	Impresion B/N	5	2.00
3134	1420	Impresion B/N	2	2.00
3135	1421	Impresion B/N	7	2.00
3138	1422	Cartulina	1	15.00
3144	1425	Impresion B/N	1	2.00
3158	1434	Impresion B/N	6	2.00
3178	1438	Impresion B/N	26	2.00
3183	1440	Impresion B/N	3	2.00
3189	1443	Cartulina	3	15.00
3194	1447	decoracion navideña	1	25.00
3195	1448	decoracion navideña	1	25.00
3225	1460	Impresion B/N	1	2.00
3226	1461	Barra Silicon	5	4.00
3228	1461	hoja color	1	1.50
3229	1461	hoja color	1	1.50
3234	1462	Impresion B/N	3	2.00
3235	1463	Impresion B/N	3	2.00
3241	1465	Impresion B/N	11	2.00
3244	1467	hoja blanca	1	13.00
3264	1472	Impresion B/N	11	2.00
3274	1475	Impresion B/N	7	2.00
3280	1477	Impresion B/N	2	2.00
3302	1489	Impresion B/N	2	2.00
3304	1491	Impresion B/N	3	2.00
3209	1451	Borrador	1	8.00
3317	1496	Cartulina	1	15.00
3324	1496	hoja color	2	1.50
3325	1496	hoja color	2	1.50
3326	1496	Barra Silicon	2	4.00
3330	1499	Impresion B/N	13	2.00
3331	1500	Impresion B/N	3	2.00
3333	1502	Cartulina	1	15.00
3336	1504	pluma color	5	4.00
3345	1507	Impresion B/N	1	2.00
3356	1513	Impresion B/N	2	2.00
3359	1514	Impresion B/N	8	2.00
3366	1518	Barra Silicon	1	4.00
3377	1523	Impresion B/N	4	2.00
3379	1523	hoja color	1	1.50
3380	1523	hoja color	1	1.50
3381	1523	hoja color	1	1.50
3382	1524	Impresion B/N	3	2.00
3394	1528	Barra Silicon	5	4.00
3397	1530	hoja color	1	1.50
3398	1530	hoja color	1	1.50
3399	1531	Impresion B/N	1	2.00
3400	1532	Impresion B/N	2	2.00
3402	1533	Impresion B/N	1	2.00
3407	1535	Impresion B/N	6	2.00
3412	1539	Impresion B/N	5	2.00
3418	1542	hoja color	10	1.50
3419	1543	Impresion B/N	5	2.00
3425	1545	hoja color	10	1.50
3428	1546	Impresion B/N	2	2.00
3433	1550	Impresion B/N	5	2.00
3440	1553	hoja color	2	1.50
3441	1553	hoja color	2	1.50
3446	1554	Impresion B/N	12	2.00
3448	1555	Impresion B/N	2	2.00
3454	1559	Impresion B/N	2	2.00
3455	1560	hoja blanca	1	13.00
3470	1565	Impresion B/N	1	2.00
3477	1568	Barra Silicon	5	4.00
3482	1569	Impresion B/N	1	2.00
3484	1571	Impresion B/N	7	2.00
3528	1590	Impresion B/N	2	2.00
3530	1591	Impresion B/N	2	2.00
3537	1594	Cartulina	1	15.00
3541	1597	Impresion B/N	1	2.00
3549	1601	hoja color	1	1.50
3578	1611	cuaderno frances	1	35.00
3585	1613	Barra Silicon	1	4.00
3611	1625	Impresion B/N	2	2.00
3616	1628	Impresion B/N	11	2.00
3617	1629	Impresion B/N	4	2.00
3633	1631	Barra Silicon	3	4.00
3643	1634	hoja color	1	1.50
3644	1634	hoja color	1	1.50
3650	1636	Impresion B/N	1	2.00
3655	1641	Impresion B/N	4	2.00
3661	1646	Impresion B/N	23	2.00
3666	1649	Impresion B/N	10	2.00
3667	1650	hoja blanca	1	25.00
3673	1652	Impresion B/N	9	2.00
3681	1655	hoja mantequilla	4	3.50
3683	1656	hoja color	1	1.50
3684	1656	hoja color	1	1.50
3685	1656	hoja color	1	1.50
3690	1658	Impresion B/N	1	2.00
3693	1660	Cartulina	2	15.00
3701	1664	Cartulina	1	15.00
3707	1667	hoja color	3	1.50
3708	1667	hoja color	3	1.50
3709	1667	hoja color	3	1.50
3715	1670	Impresion B/N	10	2.00
3736	1679	Cartulina	1	15.00
3741	1683	Impresion B/N	1	2.00
3742	1684	Impresion B/N	14	2.00
3744	1685	Impresion B/N	33	2.00
3746	1686	Impresion B/N	2	2.00
3755	1694	calcamonias	1	35.00
3759	1697	Barra Silicon	2	4.00
3764	1700	Cartulina	1	15.00
3776	1703	Impresion B/N	2	2.00
3782	1706	Impresion B/N	12	2.00
3795	1711	Barra Silicon	4	4.00
3799	1713	cuaderno frances	1	35.00
3800	1713	Impresion B/N	3	2.00
3801	1714	hoja blanca	1	13.00
3807	1718	hoja color	20	1.50
3808	1718	hoja color	20	1.50
3820	1722	Impresion B/N	3	2.00
3826	1727	Impresion B/N	2	2.00
3830	1729	hoja color	1	1.50
3831	1729	hoja color	1	1.50
3839	1732	Impresion B/N	4	2.00
3841	1733	Cartulina	1	15.00
3854	1741	Barra Silicon	5	4.00
3855	1742	sobre de aire	1	42.00
3867	1749	Impresion B/N	2	2.00
3870	1750	Impresion B/N	1	2.00
3874	1752	hoja color	1	1.50
3881	1755	Barra Silicon	1	4.00
3890	1761	envoltura por caja ( con papel )	6	60.00
3891	1761	envoltura por caja ( sin papel )	2	20.00
3906	1765	Impresion B/N	3	2.00
3911	1768	Impresion B/N	2	2.00
3912	1769	Impresion B/N	8	2.00
3921	1773	Impresion B/N	1	2.00
3926	1776	hoja blanca	1	25.00
3927	1776	hoja color	1	60.00
3935	1779	Impresion B/N	11	2.00
3936	1780	Impresion B/N	3	2.00
3943	1783	Impresion B/N	2	2.00
3945	1784	Cartulina	1	15.00
3964	1789	Impresion B/N	2	2.00
3966	1790	Impresion B/N	2	2.00
3971	1793	Impresion B/N	4	2.00
3985	1796	hoja color	1	1.50
3999	1800	Impresion B/N	11	2.00
4001	1801	Impresion B/N	12	2.00
4003	1802	Impresion B/N	7	2.00
4019	1810	Impresion B/N	3	2.00
4022	1812	hoja blanca	1	13.00
4023	1812	hoja color	1	1.50
4027	1812	hoja color	1	1.50
4047	1824	Impresion B/N	2	2.00
4048	1825	Impresion B/N	14	2.00
4061	1831	Impresion B/N	5	2.00
4064	1832	Barra Silicon	3	4.00
4065	1833	Impresion B/N	4	2.00
4097	1850	Impresion B/N	1	2.00
4098	1851	Impresion B/N	1	2.00
4137	1874	hoja color	1	1.50
4149	1879	Impresion B/N	2	2.00
4151	1880	hoja color	5	1.50
4152	1880	hoja blanca	1	13.00
4168	1888	Uno	1	50.00
4187	1899	Impresion B/N	2	2.00
4189	1900	Impresion B/N	17	2.00
4199	1905	Barra Silicon	2	10.00
4209	1911	Impresion B/N	14	2.00
4213	1914	Impresion B/N	10	2.00
4233	1925	Impresion B/N	16	2.00
4296	1963	Impresion B/N	10	2.00
4298	1964	Impresion B/N	2	2.00
4301	1965	Impresion B/N	1	2.00
4306	1969	Impresion B/N	80	2.00
4308	1970	Impresion B/N	1	2.00
4313	1974	Impresion B/N	19	2.00
4317	1976	Impresion B/N	14	2.00
4318	1977	Impresion B/N	2	2.00
4319	1978	Impresion B/N	6	2.00
4321	1980	Impresion B/N	6	2.00
4328	1983	Impresion B/N	4	2.00
4331	1985	Impresion B/N	1	2.00
4335	1987	libretas kitty	1	40.00
4338	1988	hoja color	1	1.50
4339	1988	hoja color	1	1.50
4344	1991	Impresion B/N	19	2.00
4349	1992	hoja color	1	1.50
4356	1996	Impresion B/N	6	2.00
4363	2001	Impresion B/N	16	2.00
4364	2002	Impresion B/N	24	2.00
4368	2003	libreta chica y mediana	1	15.00
4375	2006	Impresion B/N	2	2.00
4377	2008	Impresion B/N	2	2.00
4395	2014	cuaderno frances	1	36.00
4398	2017	hoja color	2	1.50
4399	2017	hoja color	2	1.50
4400	2017	hoja color	2	1.50
4405	2018	hoja color	2	1.50
4406	2018	hoja color	2	1.50
4407	2018	hoja color	2	1.50
4408	2018	hoja blanca	1	13.00
4410	2020	Impresion B/N	3	2.00
4419	2025	hoja color	5	1.50
4420	2025	hoja color	5	1.50
4421	2025	hoja color	5	1.50
4422	2025	hoja color	5	1.50
4423	2025	hoja color	5	1.50
4424	2025	hoja color	5	1.50
4425	2025	hoja color	5	1.50
4429	2027	Impresion B/N	2	2.00
4437	2031	Impresion B/N	2	2.00
4438	2032	Impresion B/N	6	2.00
4441	2033	Impresion B/N	2	2.00
4446	2036	hoja color	1	1.50
4447	2036	hoja color	1	1.50
4448	2036	hoja color	1	1.50
4453	2038	Impresion B/N	6	2.00
4454	2038	hoja blanca	1	13.00
4457	2040	Impresion B/N	1	2.00
4474	2049	Barra Silicon	4	4.00
4475	2050	Impresion B/N	45	2.00
4478	2051	hoja color	1	1.50
4479	2052	Impresion B/N	1	2.00
4480	2053	Impresion B/N	1	2.00
4481	2054	Impresion B/N	2	2.00
4482	2055	Impresion B/N	6	2.00
4488	2059	pluma jumbo	1	40.00
4502	2066	Impresion B/N	7	2.00
4504	2068	Impresion B/N	7	2.00
4524	2079	Impresion B/N	8	2.00
4529	2081	Impresion B/N	4	2.00
4537	2086	Impresion B/N	2	2.00
4546	2090	Impresion B/N	7	2.00
4548	2092	Impresion B/N	10	2.00
4556	2097	Impresion B/N	1	2.00
4561	2100	Impresion B/N	8	2.00
4562	2101	Impresion B/N	1	2.00
4563	2102	Impresion B/N	4	2.00
4581	2111	Impresion B/N	3	2.00
4584	2113	Impresion B/N	13	2.00
4593	2116	Impresion B/N	5	2.00
4595	2118	cuaderno frances	1	36.00
4596	2119	Impresion B/N	1	2.00
4606	2125	Impresion B/N	10	2.00
4610	2125	Barra Silicon	1	4.00
4611	2126	Impresion B/N	2	2.00
4615	2128	Impresion B/N	3	2.00
4616	2129	Impresion B/N	36	2.00
4618	2130	Impresion B/N	7	2.00
4622	2132	Impresion B/N	10	2.00
4629	2136	liga colores	1	10.00
4645	2144	Impresion B/N	1	2.00
4647	2145	hoja recopilador	1	70.00
4650	2146	hoja recopilador	1	70.00
4654	2148	Impresion B/N	4	2.00
4663	2154	Impresion B/N	9	2.00
4664	2155	Impresion B/N	5	2.00
4667	2158	Impresion B/N	4	2.00
4670	2159	Impresion B/N	3	2.00
4671	2160	Impresion B/N	11	2.00
4677	2164	Impresion B/N	2	2.00
4690	2171	Impresion B/N	16	2.00
4692	2173	Impresion B/N	1	2.00
4694	2174	Impresion B/N	4	2.00
4700	2177	Impresion B/N	2	2.00
4701	2178	Impresion B/N	1	2.00
4708	2180	Impresion B/N	5	2.00
4714	2183	Impresion B/N	1	2.00
4720	2186	Barra Silicon	1	4.00
4724	2187	Impresion B/N	1	2.00
4726	2189	Impresion B/N	10	2.00
4727	2190	hoja blanca	1	13.00
4728	2190	hoja color	2	1.50
4734	2194	Cartulina	1	15.00
4739	2198	Impresion B/N	1	2.00
4741	2200	Impresion B/N	1	2.00
4742	2201	pluma jumbo	1	40.00
4746	2203	Impresion B/N	6	2.00
4747	2204	Impresion B/N	2	2.00
4755	2207	Impresion B/N	4	2.00
4757	2208	hoja recopilador	1	70.00
4765	2212	Impresion B/N	2	2.00
4769	2214	hoja color	1	1.50
4770	2214	hoja color	1	1.50
4771	2215	Impresion B/N	6	2.00
4774	2216	Impresion B/N	16	2.00
4781	2219	Impresion B/N	18	2.00
4787	2225	Impresion B/N	2	2.00
4792	2226	hoja color	1	1.50
4793	2226	hoja color	1	1.50
4794	2226	hoja color	1	1.50
4800	2227	Cartulina	1	15.00
4802	2229	hoja blanca	1	45.00
4809	2232	Impresion B/N	9	2.00
4828	2237	Cartulina	1	15.00
4852	2244	Impresion B/N	7	2.00
4861	2248	Impresion B/N	1	2.00
4866	2252	Impresion B/N	1	2.00
4867	2252	tijera maped,mae	1	70.00
4872	2255	cuaderno frances	1	36.00
4881	2260	Impresion B/N	1	2.00
4882	2261	Impresion B/N	2	2.00
4886	2261	Cartulina	1	15.00
4887	2262	Impresion B/N	22	2.00
4890	2263	hoja color	2	1.50
4898	2267	Impresion B/N	1	2.00
4909	2272	Impresion B/N	15	2.00
4910	2273	Impresion B/N	6	2.00
4914	2275	Barra Silicon	6	4.00
4917	2276	hoja color	2	1.50
4918	2276	hoja color	2	1.50
4924	2278	hoja color	2	1.50
4925	2279	Impresion B/N	5	2.00
4934	2282	Impresion B/N	7	2.00
4935	2283	Impresion B/N	10	2.00
4939	2287	Impresion B/N	1	2.00
4961	2294	Cartulina	1	15.00
4962	2294	Cartulina	1	15.00
4967	2297	Impresion B/N	83	2.00
4979	2303	Impresion B/N	2	2.00
4982	2306	Impresion B/N	5	2.00
4992	2309	Impresion B/N	11	2.00
4993	2310	Impresion B/N	4	2.00
4994	2311	cuaderno frances	1	36.00
5001	2314	cuaderno frances	1	36.00
5010	2320	hoja recopilador	1	60.00
5011	2320	hoja recopilador	1	60.00
5015	2321	libreta chica y mediana	1	15.00
5023	2327	Impresion B/N	2	2.00
5025	2329	Impresion B/N	1	2.00
5027	2331	Impresion B/N	3	2.00
5032	2332	Impresion B/N	4	2.00
5053	2344	hoja blanca	1	13.00
5055	2345	Impresion B/N	2	2.00
5076	2352	hoja blanca	1	13.00
5079	2353	hoja blanca	1	13.00
5080	2354	Impresion B/N	4	2.00
5083	2355	estrella mediana	1	20.00
5084	2356	Impresion B/N	3	2.00
5088	2357	Impresion B/N	6	2.00
5091	2358	Barra Silicon	4	4.00
5094	2359	Impresion B/N	4	2.00
5096	2361	Impresion B/N	1	2.00
5099	2364	liga colores	1	10.00
5113	2371	Impresion B/N	3	2.00
5135	2380	Impresion B/N	1	2.00
5139	2383	Barra Silicon	2	4.00
5142	2386	Impresion B/N	14	2.00
5144	2387	agenda 2026 	1	90.00
5149	2389	Impresion B/N	28	2.00
5151	2390	estilografo	1	100.00
5160	2393	Impresion B/N	12	2.00
5164	2394	Impresion B/N	3	2.00
5166	2395	cuaderno frances cocido	1	55.00
5168	2396	Impresion B/N	13	2.00
5170	2398	Impresion B/N	3	2.00
5174	2399	Impresion B/N	5	2.00
5175	2400	Impresion B/N	7	2.00
5176	2401	hoja blanca	1	25.00
5177	2401	hoja blanca 	2	1.00
5179	2402	Impresion B/N	1	2.00
5182	2404	Impresion B/N	2	2.00
5189	2409	hoja milimetrica	1	1.50
5190	2410	hoja blanca	1	13.00
5191	2410	hoja color	2	1.50
5199	2412	Impresion B/N	1	2.00
5216	2420	hoja color	1	1.50
5218	2421	Impresion B/N	1	2.00
5229	2423	Impresion B/N	2	2.00
5234	2426	Impresion B/N	16	2.00
5237	2427	Impresion B/N	6	2.00
5241	2428	Impresion B/N	2	2.00
5242	2429	Impresion B/N	2	2.00
5243	2430	Impresion B/N	7	2.00
5245	2431	libreta chica y mediana	1	15.00
5246	2432	Impresion B/N	6	2.00
5247	2433	Impresion B/N	17	2.00
5251	2434	Impresion B/N	2	2.00
5257	2436	Impresion B/N	19	2.00
5258	2437	Impresion B/N	6	2.00
5262	2439	Impresion B/N	2	2.00
5263	2440	Impresion B/N	1	2.00
5266	2442	hoja blanca	1	13.00
5267	2443	Impresion B/N	8	2.00
5268	2444	Impresion B/N	20	2.00
5273	2448	hoja recopilador	1	60.00
5275	2449	Impresion B/N	4	2.00
5287	2453	hoja color	2	1.50
5288	2453	hoja color	2	1.50
5289	2453	hoja color	2	1.50
5290	2453	hoja color	2	1.50
5291	2453	hoja color	2	1.50
5299	2456	Impresion B/N	2	2.00
5310	2463	Cartulina	1	15.00
5337	2478	Barra Silicon	2	4.00
5350	2482	Impresion B/N	27	2.00
5360	2485	Barra Silicon	4	4.00
5361	2486	hoja blanca	1	13.00
5379	2495	Impresion B/N	10	2.00
5385	2497	hoja color	2	1.50
5386	2497	hoja color	2	1.50
5394	2503	Impresion B/N	4	2.00
5407	2507	raquetita	1	15.00
5414	2511	Impresion B/N	5	2.00
5418	2512	Impresion B/N	2	2.00
5428	2516	Impresion B/N	1	2.00
5442	2521	Impresion B/N	186	2.00
5445	2522	Impresion B/N	2	2.00
5460	2528	Impresion B/N	5	2.00
5463	2531	Impresion B/N	3	2.00
5464	2531	hoja blanca	1	13.00
5474	2535	hoja color	1	1.50
5486	2543	Impresion B/N	50	2.00
5488	2544	hoja color	5	1.50
5489	2544	hoja color	5	1.50
5508	2550	Impresion B/N	1	2.00
5522	2559	Impresion B/N	3	2.00
5528	2562	hoja color	1	1.50
5529	2562	hoja color	1	1.50
5530	2562	Impresion B/N	1	2.00
5533	2564	Impresion B/N	8	2.00
5535	2565	Impresion B/N	1	2.00
5544	2566	Barra Silicon	2	4.00
5550	2570	Impresion B/N	1	2.00
5551	2570	hoja color	1	1.50
5556	2575	Impresion B/N	9	2.00
5557	2576	Impresion B/N	18	2.00
5562	2579	Impresion B/N	2	2.00
5563	2579	hoja milimetrica	1	1.50
5572	2583	Impresion B/N	21	2.00
5582	2589	Barra Silicon	5	4.00
5585	2591	Impresion B/N	15	2.00
5586	2592	Impresion B/N	1	2.00
5589	2593	Impresion B/N	1	2.00
5592	2595	Impresion B/N	7	2.00
5598	2597	Impresion B/N	5	2.00
5600	2598	Impresion B/N	5	2.00
5608	2604	Impresion B/N	25	2.00
5613	2606	hoja blanca	1	13.00
5614	2606	hoja color	1	1.50
5615	2606	hoja color	3	1.50
5616	2606	hoja color	1	1.50
5627	2610	pistola	2	35.00
5631	2611	cuaderno frances	1	36.00
5633	2612	hoja color	1	1.50
5634	2613	Impresion B/N	3	2.00
5636	2613	hoja color	1	1.50
5637	2613	hoja color	1	1.50
5641	2615	hoja color	2	1.50
5646	2618	hoja color	3	1.50
5654	2621	hoja color	3	1.50
5660	2623	Impresion B/N	6	2.00
5662	2624	Impresion B/N	2	2.00
5664	2626	Impresion B/N	9	2.00
5668	2628	Barra Silicon	1	4.00
5680	2632	Impresion B/N	6	2.00
5691	2637	Impresion B/N	25	2.00
5700	2640	Barra Silicon	1	4.00
5706	2641	Impresion B/N	8	2.00
5710	2643	hoja color	3	1.50
5711	2644	Impresion B/N	52	2.00
5717	2646	mini libreta	7	12.00
5728	2652	hoja color	2	1.50
5729	2652	hoja color	2	1.50
5738	2658	Barra Silicon	2	4.00
5747	2665	hoja recopilador	1	70.00
5763	2673	Impresion B/N	3	2.00
5769	2677	hoja color	2	1.50
5770	2677	hoja color	1	1.50
5773	2678	hoja color	2	1.50
5774	2678	hoja color	2	1.50
5777	2679	Impresion B/N	2	2.00
5779	2680	hoja color	10	1.50
5780	2681	Impresion B/N	1	2.00
5784	2683	Impresion B/N	7	2.00
5787	2685	Impresion B/N	6	2.00
5788	2686	hoja color	5	1.50
5789	2686	hoja color	5	1.50
5790	2686	hoja color	5	1.50
5791	2687	hoja color	2	1.50
5792	2687	hoja color	3	1.50
5793	2687	hoja color	5	1.50
5794	2687	hoja color	5	1.50
5799	2690	hoja color	2	1.50
5809	2694	hoja color	4	1.50
5810	2694	hoja color	4	1.50
5811	2694	hoja color	4	1.50
5824	2698	hoja color	1	1.50
5833	2701	Impresion B/N	11	2.00
5862	2708	hoja color	1	1.50
5863	2708	hoja color	1	1.50
5869	2711	pistola	1	35.00
5891	2717	Barra Silicon	2	4.00
5898	2721	hoja color	10	1.50
5902	2722	Impresion B/N	2	2.00
5910	2725	Impresion B/N	1	2.00
5913	2727	Impresion B/N	3	2.00
5798	2690	Borrador	2	15.00
5921	2732	Impresion B/N	1	2.00
5925	2734	Impresion B/N	1	2.00
5928	2734	hoja blanca	1	13.00
5934	2738	Cartulina	1	15.00
5935	2739	Impresion B/N	37	2.00
5943	2742	hoja color	2	1.50
5948	2745	Impresion B/N	4	2.00
5957	2748	Impresion B/N	14	2.00
5959	2749	Impresion B/N	1	2.00
5968	2754	hoja blanca	1	45.00
5972	2756	Impresion B/N	3	2.00
5992	2766	Impresion B/N	5	2.00
5998	2770	Impresion B/N	2	2.00
5999	2771	Impresion B/N	8	2.00
6014	2777	Impresion B/N	4	2.00
6021	2781	cuaderno frances	2	36.00
6023	2782	hoja blanca	1	13.00
6035	2786	hoja color	1	1.50
6036	2786	hoja color	1	1.50
6046	2789	hoja blanca	1	13.00
6059	2796	Cartulina	1	15.00
6063	2799	Impresion B/N	10	2.00
6064	2800	Impresion B/N	3	2.00
6065	2801	hoja color	5	1.50
6071	2803	Impresion B/N	2	2.00
6073	2804	Impresion B/N	21	2.00
6076	2805	Impresion B/N	2	2.00
6078	2807	Cartulina	1	15.00
6079	2807	Cartulina	1	15.00
6080	2807	Cartulina	2	15.00
6086	2809	hoja color	1	1.50
6087	2809	hoja color	1	1.50
6089	2809	hoja color	1	1.50
6090	2810	Impresion B/N	15	2.00
6093	2813	Impresion B/N	2	2.00
6095	2814	Barra Silicon	2	4.00
6096	2815	Impresion B/N	3	2.00
6101	2817	Impresion B/N	5	2.00
6104	2819	hoja color	1	1.50
6105	2819	hoja color	1	1.50
6108	2821	hoja blanca	1	13.00
6117	2825	liga colores	1	10.00
6121	2827	Cartulina	2	15.00
6125	2827	Impresion B/N	7	2.00
6138	2832	Impresion B/N	4	2.00
6139	2833	Impresion B/N	15	2.00
6150	2837	Impresion B/N	10	2.00
6164	2845	Impresion B/N	28	2.00
6168	2849	Impresion B/N	2	2.00
6175	2851	Impresion B/N	2	2.00
6176	2852	Impresion B/N	4	2.00
6177	2853	Impresion B/N	7	2.00
6178	2854	Impresion B/N	2	2.00
6184	2858	Impresion B/N	2	2.00
6185	2859	Impresion B/N	5	2.00
6186	2860	Impresion B/N	5	2.00
6187	2861	hoja blanca	1	13.00
6188	2862	Impresion B/N	11	2.00
6191	2864	hoja blanca	1	45.00
6192	2864	hoja color	1	32.00
6198	2865	Impresion B/N	5	2.00
6202	2867	Impresion B/N	2	2.00
6208	2871	Impresion B/N	16	2.00
6210	2872	Impresion B/N	39	2.00
6218	2875	Barra Silicon	1	4.00
6220	2876	Impresion B/N	3	2.00
6221	2877	Impresion B/N	3	2.00
6224	2878	Impresion B/N	4	2.00
6237	2881	Impresion B/N	10	2.00
6241	2883	Impresion B/N	3	2.00
6245	2884	Impresion B/N	1	2.00
6248	2886	Impresion B/N	8	2.00
6249	2886	hoja color	1	1.50
6250	2886	hoja color	1	1.50
6252	2887	Impresion B/N	2	2.00
6253	2888	Impresion B/N	18	2.00
6263	2895	Impresion B/N	7	2.00
6267	2897	Impresion B/N	15	2.00
6271	2899	Impresion B/N	4	2.00
6276	2903	Impresion B/N	6	2.00
6278	2904	Impresion B/N	18	2.00
6279	2905	Impresion B/N	2	2.00
6290	2907	Impresion B/N	3	2.00
6291	2908	Impresion B/N	8	2.00
6292	2909	Impresion B/N	19	2.00
6298	2913	Impresion B/N	9	2.00
6301	2914	hoja recopilador	1	70.00
6307	2916	Impresion B/N	1	2.00
6309	2917	Impresion B/N	1	2.00
6311	2918	Impresion B/N	3	2.00
6313	2919	Impresion B/N	6	2.00
6330	2928	Impresion B/N	4	2.00
6335	2932	Impresion B/N	7	2.00
6338	2933	Impresion B/N	6	2.00
6341	2933	hoja color	1	32.00
6346	2934	Impresion B/N	8	2.00
6358	2940	Impresion B/N	7	2.00
6365	2945	Cartulina	3	15.00
6371	2948	Impresion B/N	3	2.00
6373	2950	Impresion B/N	3	2.00
6381	2955	Impresion B/N	17	2.00
6387	2959	hoja color	1	32.00
6391	2960	Impresion B/N	1	2.00
6392	2961	Cartulina	1	15.00
6393	2961	Barra Silicon	10	4.00
6398	2964	Impresion B/N	57	2.00
6400	2965	hoja blanca	1	25.00
6401	2965	hoja blanca 	28	1.00
6402	2965	agenda 2026 	1	90.00
6410	2967	Impresion B/N	6	2.00
6418	2969	Impresion B/N	4	2.00
6421	2970	Impresion B/N	8	2.00
6422	2971	Impresion B/N	26	2.00
6430	2974	Impresion B/N	30	2.00
6431	2975	hoja color	3	1.50
6432	2975	hoja color	1	1.50
6433	2975	hoja color	1	1.50
6446	2983	Impresion B/N	2	2.00
6451	2985	Cartulina	1	15.00
6452	2986	Impresion B/N	1	2.00
6460	2990	Barra Silicon	3	4.00
6475	2998	Impresion B/N	4	2.00
6478	2999	Impresion B/N	4	2.00
6483	3001	Impresion B/N	2	2.00
6491	3003	Impresion B/N	5	2.00
6523	3020	Impresion B/N	19	2.00
6540	3026	Impresion B/N	14	2.00
6549	3030	Impresion B/N	3	2.00
6552	3032	Impresion B/N	11	2.00
6558	3036	Barra Silicon	6	4.00
6570	3041	Impresion B/N	6	2.00
6579	3045	Barra Silicon	6	4.00
6591	3051	Impresion B/N	4	2.00
6593	3052	Impresion B/N	4	2.00
6609	3058	Impresion B/N	4	2.00
6616	3063	Cartulina	1	15.00
6620	3066	Impresion B/N	10	2.00
6621	3067	Impresion B/N	12	2.00
6624	3069	Impresion B/N	2	2.00
6633	3075	Impresion B/N	12	2.00
6638	3078	Impresion B/N	9	2.00
6664	3091	Impresion B/N	11	2.00
6671	3094	BOL	2	7.00
6689	3102	Impresion B/N	2	2.00
6691	3103	Impresion B/N	4	2.00
6693	3104	Impresion B/N	4	2.00
6714	3115	Impresion B/N	6	2.00
6715	3116	Impresion B/N	17	2.00
6718	3118	Impresion B/N	12	2.00
6721	3119	Impresion B/N	3	2.00
6749	3129	tijera zic zac	1	25.00
6753	3131	Impresion B/N	1	2.00
6757	3134	Impresion B/N	6	2.00
6767	3140	Barra Silicon	2	4.00
6768	3140	Barra Silicon	2	10.00
6790	3144	Barra Silicon	2	4.00
6805	3150	Impresion B/N	1	2.00
6815	3155	Barra Silicon	5	4.00
6825	3159	Impresion B/N	2	2.00
6826	3160	Cartulina	1	15.00
6827	3161	Impresion B/N	8	2.00
6841	3166	Cartulina	1	15.00
6848	3167	Impresion B/N	2	2.00
6854	3170	Impresion B/N	5	2.00
6858	3172	Impresion B/N	1	2.00
6859	3173	Impresion B/N	3	2.00
6860	3174	Impresion B/N	1	2.00
6862	3175	Cartulina	1	15.00
6877	3182	Cartulina	1	15.00
6885	3188	Impresion B/N	1	2.00
6887	3190	Impresion B/N	10	2.00
6893	3193	Impresion B/N	7	2.00
6915	3199	Cartulina	1	15.00
6916	3199	Barra Silicon	4	4.00
6921	3202	Barra Silicon	2	4.00
6922	3203	Impresion B/N	10	2.00
6929	3207	Cartulina	1	15.00
6948	3215	Barra Silicon	4	4.00
6959	3219	Cartulina	1	15.00
6960	3219	Cartulina	1	15.00
6961	3219	Barra Silicon	4	4.00
6970	3222	Impresion B/N	20	2.00
6976	3226	Impresion B/N	16	2.00
6987	3229	Impresion B/N	4	2.00
6988	3230	Cartulina	2	15.00
7014	3239	Barra Silicon	4	4.00
7020	3240	Impresion B/N	18	2.00
7025	3243	Impresion B/N	1	2.00
7033	3247	Impresion B/N	2	2.00
7034	3248	Impresion B/N	1	2.00
7038	3251	Impresion B/N	10	2.00
7040	3252	Impresion B/N	3	2.00
6957	3218	Corona	1	40.00
7051	3262	Impresion B/N	3	2.00
7060	3267	Impresion B/N	2	2.00
7063	3269	Impresion B/N	8	2.00
7082	3276	Impresion B/N	2	2.00
7093	3278	Impresion B/N	7	2.00
7101	3281	Barra Silicon	1	4.00
7139	3292	Cartulina	2	15.00
7143	3294	Impresion B/N	18	2.00
7145	3296	Impresion B/N	1	2.00
7152	3301	Impresion B/N	6	2.00
7168	3309	Impresion B/N	4	2.00
7171	3312	Impresion B/N	8	2.00
7183	3316	Barra Silicon	4	4.00
7186	3318	Impresion B/N	20	2.00
7193	3320	Impresion B/N	3	2.00
7196	3322	Impresion B/N	4	2.00
7197	3323	Impresion B/N	4	2.00
7198	3324	Impresion B/N	6	2.00
7200	3325	Impresion B/N	15	2.00
7212	3332	Impresion B/N	2	2.00
7220	3337	Impresion B/N	7	2.00
7226	3340	Impresion B/N	5	2.00
7234	3344	Impresion B/N	3	2.00
7244	3351	Impresion B/N	3	2.00
7245	3352	Impresion B/N	9	2.00
7256	3356	Impresion B/N	1	2.00
7257	3357	Barra Silicon	1	4.00
7260	3360	Impresion B/N	2	2.00
7267	3363	Barra Silicon	5	4.00
7286	3372	Impresion B/N	9	2.00
7293	3376	Impresion B/N	15	2.00
7311	3383	Barra Silicon	2	4.00
7312	3384	Impresion B/N	74	2.00
7326	3389	Cartulina	1	15.00
7337	3393	Barra Silicon	7	4.00
7340	3395	Impresion B/N	8	2.00
7349	3399	Impresion B/N	17	2.00
7352	3400	Impresion B/N	5	2.00
7353	3400	Barra Silicon	5	4.00
7358	3403	Impresion B/N	5	2.00
7363	3406	Impresion B/N	2	2.00
7366	3407	Impresion B/N	1	2.00
1394	641	Collar	1	25.00
6155	2839	Collar	1	50.00
3934	1778	Lluvia	1	3.00
6947	3215	Lluvia	4	3.00
6958	3219	Lluvia	6	3.00
99	58	Bandera Chica	1	15.00
186	97	Bandera Chica	1	15.00
1473	682	Tabla de Multilicar	1	25.00
3106	1410	Tabla de Multilicar	1	25.00
1511	693	Tabla Vocales	1	25.00
240	124	Borrador	1	35.00
359	190	Borrador	1	10.00
361	191	Borrador	1	5.00
387	205	Borrador	1	5.00
659	321	Borrador	1	8.00
673	327	Borrador	1	8.00
1089	506	Borrador	1	7.00
1142	539	Borrador	1	7.00
1211	573	Borrador	1	7.00
1271	592	Borrador	1	8.00
1272	592	Borrador	1	10.00
1461	674	Borrador	1	7.00
1803	817	Borrador	1	10.00
2009	901	Borrador	1	8.00
2078	932	Borrador	1	8.00
2389	1054	Borrador	1	7.00
2612	1165	Borrador	1	8.00
2642	1181	Borrador	1	10.00
2673	1196	Borrador	2	7.00
2727	1220	Borrador	1	7.00
2907	1317	Borrador	3	7.00
2911	1319	Borrador	1	7.00
3041	1378	Borrador	1	7.00
3149	1428	Borrador	1	8.00
3281	1477	Borrador	2	8.00
3349	1509	Borrador	1	8.00
3569	1608	Borrador	3	5.00
3603	1621	Borrador	1	8.00
3769	1701	Borrador	1	7.00
4510	2073	Borrador	1	10.00
4522	2077	Borrador	1	8.00
4533	2083	Borrador	2	7.00
4554	2097	Borrador	2	7.00
4583	2112	Borrador	1	8.00
4733	2193	Borrador	1	8.00
4778	2217	Borrador	1	10.00
4832	2237	Borrador	1	7.00
4859	2248	Borrador	2	7.00
4893	2264	Borrador	1	8.00
4964	2294	Borrador	2	5.00
5008	2318	Borrador	1	7.00
5132	2379	Borrador	1	7.00
5297	2455	Borrador	1	10.00
5307	2462	Borrador	1	10.00
5433	2517	Borrador	2	5.00
5434	2518	Borrador	2	10.00
5448	2523	Borrador	2	10.00
5639	2614	Borrador	1	15.00
5645	2618	Borrador	1	15.00
5672	2629	Borrador	2	5.00
5715	2645	Borrador	2	15.00
5724	2651	Borrador	1	15.00
5731	2653	Borrador	1	15.00
5861	2708	Borrador	1	5.00
5923	2732	Borrador	1	10.00
6032	2785	Borrador	2	10.00
6240	2882	Borrador	1	10.00
6244	2884	Borrador	1	10.00
6321	2924	Borrador	2	10.00
6409	2966	Borrador	3	15.00
6536	3025	Borrador	1	15.00
6665	3092	Borrador	1	10.00
6688	3102	Borrador	1	10.00
6742	3126	Borrador	1	10.00
6751	3129	Borrador	1	10.00
6779	3142	Borrador	1	7.00
7342	3396	Borrador	2	10.00
14	9	Impresion Color	2	5.00
29	23	Impresion Color	2	15.00
36	25	Impresion Color	1	10.00
37	25	Impresion Color	1	15.00
43	28	Impresion Color	3	5.00
44	29	Impresion Color	1	5.00
56	36	Impresion Color	1	5.00
58	38	Impresion Color	4	10.00
63	41	Impresion Color	3	5.00
66	43	Impresion Color	3	5.00
89	52	Impresion Color	1	5.00
102	59	Impresion Color	4	10.00
212	108	Impresion Color	2	15.00
249	128	Impresion Color	1	15.00
257	132	Impresion Color	1	10.00
259	134	Impresion Color	1	15.00
277	144	Impresion Color	1	5.00
302	159	Impresion Color	2	5.00
303	159	Impresion Color	1	10.00
308	162	Impresion Color	1	5.00
312	164	Impresion Color	6	5.00
319	169	Impresion Color	4	5.00
371	197	Impresion Color	3	10.00
372	197	Impresion Color	1	5.00
414	215	Impresion Color	1	10.00
421	218	Impresion Color	1	5.00
478	246	Impresion Color	7	10.00
479	246	Impresion Color	1	15.00
499	255	Impresion Color	1	10.00
500	256	Impresion Color	3	15.00
514	264	Impresion Color	3	10.00
553	279	Impresion Color	1	10.00
561	281	Impresion Color	2	10.00
565	282	Impresion Color	2	10.00
571	284	Impresion Color	1	5.00
574	286	Impresion Color	10	5.00
613	305	Impresion Color	1	10.00
655	319	Impresion Color	1	10.00
667	327	Impresion Color	1	5.00
677	329	Impresion Color	2	10.00
679	331	Impresion Color	2	5.00
680	332	Impresion Color	1	10.00
702	340	Impresion Color	1	10.00
737	348	Impresion Color	2	10.00
748	352	Impresion Color	4	10.00
751	353	Impresion Color	1	5.00
769	360	Impresion Color	3	10.00
778	365	Impresion Color	2	15.00
779	365	Impresion Color	1	10.00
780	365	Impresion Color	1	5.00
783	366	Impresion Color	1	5.00
784	366	Impresion Color	1	15.00
789	369	Impresion Color	2	10.00
796	372	Impresion Color	1	10.00
797	372	Impresion Color	1	15.00
820	384	Impresion Color	1	5.00
822	386	Impresion Color	3	5.00
829	388	Impresion Color	1	10.00
834	392	Impresion Color	1	5.00
836	392	Impresion Color	1	15.00
837	392	Impresion Color	2	10.00
842	395	Impresion Color	1	15.00
874	408	Impresion Color	2	15.00
876	408	Impresion Color	1	10.00
886	414	Impresion Color	1	10.00
894	419	Impresion Color	1	10.00
895	419	Impresion Color	1	5.00
924	435	Impresion Color	7	5.00
934	439	Impresion Color	1	10.00
991	467	Impresion Color	1	10.00
1030	487	Impresion Color	7	5.00
1052	495	Impresion Color	1	10.00
1054	496	Impresion Color	3	10.00
1066	498	Impresion Color	1	5.00
1067	498	Impresion Color	1	10.00
1108	518	Impresion Color	3	10.00
1110	520	Impresion Color	1	15.00
1121	525	Impresion Color	1	5.00
1135	535	Impresion Color	1	10.00
1145	541	Impresion Color	2	15.00
1167	557	Impresion Color	5	10.00
1194	564	Impresion Color	1	15.00
1202	566	Impresion Color	1	5.00
1204	567	Impresion Color	1	10.00
1285	599	Impresion Color	17	10.00
1289	599	Impresion Color	3	5.00
1294	601	Impresion Color	42	5.00
1302	604	Impresion Color	2	10.00
1306	606	Impresion Color	2	5.00
1317	614	Impresion Color	1	5.00
1369	629	Impresion Color	1	10.00
1392	640	Impresion Color	1	15.00
1412	649	Impresion Color	3	5.00
1413	649	Impresion Color	1	10.00
1415	650	Impresion Color	3	5.00
1423	654	Impresion Color	1	5.00
1426	656	Impresion Color	1	10.00
1434	660	Impresion Color	2	10.00
1439	663	Impresion Color	1	5.00
1442	666	Impresion Color	3	10.00
1456	671	Impresion Color	3	10.00
1459	673	Impresion Color	1	5.00
1462	674	Impresion Color	1	5.00
1470	679	Impresion Color	4	10.00
1476	682	Impresion Color	1	10.00
1486	686	Impresion Color	1	5.00
1489	686	Impresion Color	1	10.00
1520	697	Impresion Color	3	10.00
1522	698	Impresion Color	1	10.00
1525	699	Impresion Color	1	5.00
1538	706	Impresion Color	1	10.00
1540	707	Impresion Color	2	10.00
1542	708	Impresion Color	2	5.00
1554	712	Impresion Color	1	15.00
1556	714	Impresion Color	1	10.00
1562	717	Impresion Color	6	10.00
1590	726	Impresion Color	7	10.00
1618	738	Impresion Color	1	5.00
1660	761	Impresion Color	2	10.00
1679	769	Impresion Color	1	10.00
1681	769	Impresion Color	2	15.00
1723	782	Impresion Color	1	10.00
1739	787	Impresion Color	1	5.00
1750	792	Impresion Color	1	5.00
1780	807	Impresion Color	1	5.00
1781	807	Impresion Color	1	10.00
1787	811	Impresion Color	1	5.00
1835	827	Impresion Color	1	15.00
1839	828	Impresion Color	1	5.00
1844	830	Impresion Color	11	5.00
1860	835	Impresion Color	1	10.00
1887	843	Impresion Color	1	5.00
1894	848	Impresion Color	1	15.00
1907	853	Impresion Color	1	15.00
1909	853	Impresion Color	1	5.00
1922	859	Impresion Color	1	10.00
1923	859	Impresion Color	1	5.00
1936	866	Impresion Color	1	5.00
1952	877	Impresion Color	1	10.00
1968	882	Impresion Color	1	5.00
1978	887	Impresion Color	2	10.00
1979	887	Impresion Color	1	5.00
1980	887	Impresion Color	1	15.00
1982	889	Impresion Color	3	5.00
1996	897	Impresion Color	7	15.00
1997	897	Impresion Color	2	10.00
1999	899	Impresion Color	2	5.00
2022	906	Impresion Color	2	15.00
2024	907	Impresion Color	1	10.00
2057	922	Impresion Color	1	5.00
2082	934	Impresion Color	1	10.00
2165	972	Impresion Color	2	10.00
2230	991	Impresion Color	2	15.00
2231	991	Impresion Color	1	5.00
2234	992	Impresion Color	1	15.00
2254	1001	Impresion Color	1	10.00
2332	1032	Impresion Color	3	15.00
2356	1040	Impresion Color	10	10.00
2381	1051	Impresion Color	3	10.00
2382	1051	Impresion Color	1	5.00
2393	1056	Impresion Color	2	5.00
2394	1057	Impresion Color	2	5.00
2432	1070	Impresion Color	2	5.00
2451	1076	Impresion Color	2	5.00
2525	1132	Impresion Color	1	15.00
2532	1135	Impresion Color	1	15.00
2614	1166	Impresion Color	1	15.00
2620	1168	Impresion Color	6	10.00
2622	1170	Impresion Color	1	5.00
2646	1183	Impresion Color	1	5.00
2699	1210	Impresion Color	1	15.00
2701	1210	Impresion Color	2	10.00
2717	1215	Impresion Color	1	5.00
2751	1231	Impresion Color	1	10.00
2752	1231	Impresion Color	1	5.00
2761	1235	Impresion Color	1	15.00
2783	1248	Impresion Color	3	10.00
2797	1255	Impresion Color	6	10.00
2800	1257	Impresion Color	1	15.00
2804	1258	Impresion Color	1	5.00
2817	1267	Impresion Color	6	5.00
2819	1268	Impresion Color	1	15.00
2833	1278	Impresion Color	4	5.00
2844	1283	Impresion Color	1	5.00
2845	1284	Impresion Color	7	10.00
2847	1285	Impresion Color	1	5.00
2848	1285	Impresion Color	1	10.00
2849	1286	Impresion Color	1	10.00
2895	1312	Impresion Color	5	5.00
2903	1316	Impresion Color	1	5.00
2931	1329	Impresion Color	2	5.00
2932	1330	Impresion Color	2	10.00
2952	1339	Impresion Color	1	10.00
2956	1342	Impresion Color	2	5.00
2966	1347	Impresion Color	5	10.00
2980	1352	Impresion Color	6	5.00
2985	1354	Impresion Color	1	10.00
2987	1354	Impresion Color	13	5.00
3002	1358	Impresion Color	2	5.00
3003	1358	Impresion Color	1	10.00
3011	1362	Impresion Color	2	10.00
3012	1362	Impresion Color	1	5.00
3023	1368	Impresion Color	1	10.00
3034	1373	Impresion Color	1	10.00
3035	1374	Impresion Color	3	10.00
3036	1375	Impresion Color	8	5.00
3048	1384	Impresion Color	1	5.00
3049	1384	Impresion Color	4	10.00
3064	1393	Impresion Color	1	15.00
3065	1394	Impresion Color	6	5.00
3073	1396	Impresion Color	4	5.00
3091	1405	Impresion Color	1	5.00
3099	1406	Impresion Color	1	15.00
3104	1409	Impresion Color	1	5.00
3107	1410	Impresion Color	1	5.00
3115	1412	Impresion Color	3	10.00
3131	1419	Impresion Color	2	15.00
3132	1419	Impresion Color	9	5.00
3143	1424	Impresion Color	2	10.00
3156	1432	Impresion Color	3	10.00
3184	1440	Impresion Color	1	10.00
3192	1445	Impresion Color	1	5.00
3200	1449	Impresion Color	3	15.00
3201	1449	Impresion Color	1	5.00
3278	1476	Impresion Color	2	5.00
3290	1484	Impresion Color	5	5.00
3291	1484	Impresion Color	2	10.00
3292	1485	Impresion Color	5	5.00
3300	1487	Impresion Color	2	10.00
3346	1508	Impresion Color	4	10.00
3378	1523	Impresion Color	1	5.00
3408	1536	Impresion Color	1	5.00
3447	1555	Impresion Color	1	10.00
3453	1559	Impresion Color	1	10.00
3489	1575	Impresion Color	9	5.00
3529	1590	Impresion Color	1	10.00
3534	1593	Impresion Color	2	10.00
3612	1625	Impresion Color	1	5.00
3618	1629	Impresion Color	1	10.00
3636	1633	Impresion Color	7	15.00
3641	1634	Impresion Color	2	10.00
3642	1634	Impresion Color	1	5.00
3654	1640	Impresion Color	5	15.00
3671	1652	Impresion Color	4	10.00
3675	1652	Impresion Color	1	15.00
3679	1654	Impresion Color	1	15.00
3713	1668	Impresion Color	3	15.00
3716	1670	Impresion Color	8	5.00
3720	1671	Impresion Color	1	15.00
3722	1673	Impresion Color	1	15.00
3745	1686	Impresion Color	4	5.00
3766	1701	Impresion Color	4	10.00
3780	1705	Impresion Color	1	5.00
3781	1705	Impresion Color	2	10.00
3788	1709	Impresion Color	2	10.00
3803	1715	Impresion Color	5	10.00
3804	1716	Impresion Color	1	10.00
3815	1721	Impresion Color	1	10.00
3816	1721	Impresion Color	1	5.00
3821	1722	Impresion Color	2	5.00
3822	1723	Impresion Color	1	5.00
3827	1728	Impresion Color	1	10.00
3840	1732	Impresion Color	1	5.00
3843	1735	Impresion Color	1	5.00
3878	1754	Impresion Color	1	10.00
3884	1758	Impresion Color	1	5.00
3907	1765	Impresion Color	9	5.00
3908	1766	Impresion Color	6	5.00
3937	1781	Impresion Color	6	15.00
3968	1791	Impresion Color	1	10.00
3998	1800	Impresion Color	4	5.00
4004	1802	Impresion Color	6	5.00
4010	1805	Impresion Color	3	5.00
4020	1811	Impresion Color	2	15.00
4054	1828	Impresion Color	9	10.00
4059	1830	Impresion Color	1	10.00
4062	1831	Impresion Color	1	5.00
4081	1839	Impresion Color	1	10.00
4136	1874	Impresion Color	2	10.00
4150	1879	Impresion Color	24	5.00
4194	1903	Impresion Color	2	5.00
4201	1906	Impresion Color	1	5.00
4214	1914	Impresion Color	2	5.00
4229	1922	Impresion Color	1	15.00
4273	1949	Impresion Color	2	10.00
4297	1963	Impresion Color	1	5.00
4302	1965	Impresion Color	1	5.00
4332	1985	Impresion Color	1	5.00
4336	1987	Impresion Color	1	10.00
4340	1989	Impresion Color	8	5.00
4343	1990	Impresion Color	1	5.00
4351	1994	Impresion Color	4	10.00
4362	2000	Impresion Color	1	5.00
4374	2005	Impresion Color	13	5.00
4409	2019	Impresion Color	5	10.00
4414	2022	Impresion Color	2	5.00
4431	2028	Impresion Color	3	5.00
4439	2032	Impresion Color	1	5.00
4440	2033	Impresion Color	2	5.00
4459	2041	Impresion Color	3	10.00
4477	2051	Impresion Color	6	10.00
4484	2057	Impresion Color	5	5.00
4486	2059	Impresion Color	1	10.00
4501	2065	Impresion Color	1	10.00
4503	2067	Impresion Color	1	5.00
4525	2080	Impresion Color	1	5.00
4527	2081	Impresion Color	2	10.00
4528	2081	Impresion Color	3	5.00
4549	2093	Impresion Color	1	10.00
4569	2104	Impresion Color	1	10.00
4570	2105	Impresion Color	1	10.00
4580	2110	Impresion Color	1	10.00
4587	2115	Impresion Color	1	5.00
4597	2120	Impresion Color	1	10.00
4638	2142	Impresion Color	2	10.00
4659	2152	Impresion Color	1	10.00
4686	2169	Impresion Color	1	10.00
4702	2178	Impresion Color	1	10.00
4703	2178	Impresion Color	1	5.00
4764	2211	Impresion Color	1	5.00
4789	2225	Impresion Color	1	10.00
4839	2238	Impresion Color	1	10.00
4865	2251	Impresion Color	1	15.00
4877	2259	Impresion Color	1	5.00
4884	2261	Impresion Color	6	5.00
4888	2263	Impresion Color	1	15.00
4891	2264	Impresion Color	1	10.00
4912	2275	Impresion Color	1	10.00
4913	2275	Impresion Color	1	5.00
4921	2277	Impresion Color	17	10.00
4931	2281	Impresion Color	1	5.00
4952	2291	Impresion Color	1	5.00
4971	2300	Impresion Color	1	10.00
4981	2305	Impresion Color	1	15.00
4983	2306	Impresion Color	1	10.00
5005	2317	Impresion Color	1	10.00
5021	2325	Impresion Color	2	10.00
5026	2330	Impresion Color	1	5.00
5028	2331	Impresion Color	3	10.00
5029	2331	Impresion Color	6	5.00
5049	2343	Impresion Color	1	10.00
5050	2343	Impresion Color	2	5.00
5056	2345	Impresion Color	1	5.00
5063	2350	Impresion Color	1	10.00
5081	2354	Impresion Color	1	10.00
5085	2356	Impresion Color	4	15.00
5095	2360	Impresion Color	1	5.00
5107	2368	Impresion Color	1	10.00
5152	2391	Impresion Color	1	10.00
5153	2391	Impresion Color	1	5.00
5208	2416	Impresion Color	10	10.00
5228	2422	Impresion Color	1	10.00
5235	2426	Impresion Color	10	5.00
5236	2427	Impresion Color	1	5.00
5270	2445	Impresion Color	10	5.00
5283	2451	Impresion Color	1	10.00
5300	2456	Impresion Color	1	10.00
5347	2480	Impresion Color	1	5.00
5380	2496	Impresion Color	1	10.00
5381	2496	Impresion Color	1	5.00
5397	2505	Impresion Color	3	5.00
5423	2514	Impresion Color	1	5.00
5478	2538	Impresion Color	1	5.00
5487	2543	Impresion Color	2	5.00
5490	2545	Impresion Color	1	15.00
5491	2545	Impresion Color	3	10.00
5496	2548	Impresion Color	4	5.00
5534	2564	Impresion Color	1	10.00
5561	2579	Impresion Color	1	10.00
5569	2581	Impresion Color	1	5.00
5580	2588	Impresion Color	1	5.00
5587	2592	Impresion Color	1	10.00
5590	2593	Impresion Color	1	5.00
5593	2596	Impresion Color	2	10.00
5602	2600	Impresion Color	1	5.00
5607	2604	Impresion Color	6	5.00
5623	2610	Impresion Color	7	5.00
5640	2615	Impresion Color	1	10.00
5661	2624	Impresion Color	2	5.00
5707	2641	Impresion Color	8	5.00
5742	2662	Impresion Color	5	10.00
5808	2694	Impresion Color	1	10.00
5816	2696	Impresion Color	1	10.00
5823	2697	Impresion Color	4	15.00
5851	2705	Impresion Color	3	15.00
5858	2708	Impresion Color	1	5.00
5859	2708	Impresion Color	1	10.00
5886	2717	Impresion Color	1	10.00
5919	2731	Impresion Color	1	10.00
5936	2739	Impresion Color	2	15.00
5937	2739	Impresion Color	1	5.00
5956	2748	Impresion Color	1	5.00
5986	2763	Impresion Color	1	10.00
5994	2768	Impresion Color	1	10.00
5995	2768	Impresion Color	2	5.00
6004	2772	Impresion Color	1	5.00
6007	2773	Impresion Color	7	5.00
6013	2776	Impresion Color	3	5.00
6017	2779	Impresion Color	1	10.00
6072	2804	Impresion Color	1	10.00
6075	2805	Impresion Color	1	5.00
6097	2816	Impresion Color	1	5.00
6100	2817	Impresion Color	2	15.00
6113	2824	Impresion Color	1	15.00
6127	2828	Impresion Color	2	15.00
6169	2849	Impresion Color	1	10.00
6170	2849	Impresion Color	1	5.00
6205	2869	Impresion Color	2	10.00
6274	2902	Impresion Color	3	10.00
6331	2929	Impresion Color	2	5.00
6349	2935	Impresion Color	6	10.00
6350	2936	Impresion Color	1	5.00
6370	2947	Impresion Color	1	5.00
6388	2959	Impresion Color	1	10.00
6390	2960	Impresion Color	2	5.00
6453	2986	Impresion Color	2	5.00
6472	2997	Impresion Color	1	5.00
6476	2998	Impresion Color	1	5.00
6479	2999	Impresion Color	1	15.00
6482	3001	Impresion Color	2	5.00
6493	3003	Impresion Color	1	5.00
6494	3004	Impresion Color	1	15.00
6495	3004	Impresion Color	5	10.00
6501	3007	Impresion Color	2	10.00
6527	3023	Impresion Color	2	15.00
6547	3029	Impresion Color	8	10.00
6551	3031	Impresion Color	6	5.00
6592	3052	Impresion Color	1	5.00
6606	3057	Impresion Color	1	5.00
6612	3060	Impresion Color	1	10.00
6622	3068	Impresion Color	1	5.00
6625	3069	Impresion Color	1	5.00
6637	3077	Impresion Color	1	5.00
6662	3089	Impresion Color	1	10.00
6705	3108	Impresion Color	1	5.00
6711	3113	Impresion Color	2	5.00
6713	3115	Impresion Color	3	5.00
6719	3118	Impresion Color	6	5.00
6722	3119	Impresion Color	1	15.00
6725	3121	Impresion Color	1	5.00
6735	3124	Impresion Color	5	10.00
6746	3127	Impresion Color	2	5.00
6750	3129	Impresion Color	6	5.00
6759	3135	Impresion Color	1	10.00
6786	3143	Impresion Color	1	5.00
6796	3146	Impresion Color	2	5.00
6801	3149	Impresion Color	3	5.00
6844	3166	Impresion Color	1	5.00
6875	3182	Impresion Color	3	15.00
6876	3182	Impresion Color	1	5.00
6913	3198	Impresion Color	1	15.00
6936	3209	Impresion Color	2	5.00
6937	3209	Impresion Color	2	10.00
6964	3220	Impresion Color	1	5.00
6971	3222	Impresion Color	7	5.00
7032	3247	Impresion Color	2	5.00
7047	3258	Impresion Color	9	5.00
7048	3259	Impresion Color	4	10.00
7052	3262	Impresion Color	6	5.00
7053	3263	Impresion Color	2	10.00
7057	3266	Impresion Color	2	5.00
7064	3269	Impresion Color	6	10.00
7065	3269	Impresion Color	1	15.00
7085	3276	Impresion Color	1	5.00
7119	3285	Impresion Color	2	15.00
7129	3291	Impresion Color	1	15.00
7157	3304	Impresion Color	2	15.00
7190	3319	Impresion Color	8	5.00
7209	3330	Impresion Color	1	5.00
7216	3334	Impresion Color	1	5.00
7218	3336	Impresion Color	4	15.00
7233	3343	Impresion Color	2	10.00
7243	3350	Impresion Color	3	5.00
7298	3377	Impresion Color	1	5.00
7317	3387	Impresion Color	1	10.00
7336	3393	Impresion Color	9	5.00
7355	3401	Impresion Color	1	10.00
7359	3403	Impresion Color	2	5.00
7360	3404	Impresion Color	2	10.00
7364	3406	Impresion Color	1	10.00
7365	3406	Impresion Color	1	5.00
10	9	Engargolado	2	35.00
133	72	Engargolado	1	60.00
237	122	Engargolado	1	60.00
296	156	Engargolado	1	45.00
297	156	Engargolado	1	35.00
354	187	Engargolado	1	100.00
463	238	Engargolado	1	60.00
1012	476	Engargolado	1	35.00
1162	552	Engargolado	1	35.00
1173	560	Engargolado	1	35.00
1779	806	Engargolado	1	45.00
1888	844	Engargolado	1	35.00
2249	997	Engargolado	1	45.00
2986	1354	Engargolado	1	35.00
2991	1357	Engargolado	1	60.00
3260	1471	Engargolado	1	60.00
3277	1476	Engargolado	1	45.00
3422	1545	Engargolado	1	35.00
4401	2017	Engargolado	1	45.00
4476	2050	Engargolado	1	45.00
4535	2084	Engargolado	1	35.00
4843	2240	Engargolado	1	45.00
5043	2340	Engargolado	1	35.00
5105	2368	Engargolado	1	35.00
5324	2472	Engargolado	1	45.00
5443	2521	Engargolado	1	60.00
5573	2583	Engargolado	1	35.00
5692	2637	Engargolado	1	35.00
5912	2726	Engargolado	1	35.00
5976	2758	Engargolado	3	45.00
6212	2872	Engargolado	1	45.00
6268	2897	Engargolado	1	35.00
6362	2943	Engargolado	1	35.00
6372	2949	Engargolado	1	35.00
6386	2958	Engargolado	1	35.00
6399	2964	Engargolado	1	45.00
6888	3191	Engargolado	1	35.00
7294	3376	Engargolado	1	35.00
12	9	Enmicado	1	20.00
38	25	Enmicado	1	20.00
40	27	Enmicado	2	17.00
90	53	Enmicado	1	15.00
105	61	Enmicado	5	25.00
140	75	Enmicado	1	25.00
142	77	Enmicado	1	25.00
151	81	Enmicado	1	20.00
161	86	Enmicado	1	25.00
260	134	Enmicado	1	25.00
276	144	Enmicado	1	25.00
291	151	Enmicado	2	25.00
309	162	Enmicado	1	25.00
311	164	Enmicado	3	25.00
489	249	Enmicado	1	25.00
512	263	Enmicado	1	25.00
524	267	Enmicado	2	25.00
589	296	Enmicado	2	25.00
614	305	Enmicado	1	25.00
658	320	Enmicado	2	15.00
739	350	Enmicado	3	17.00
843	396	Enmicado	1	25.00
901	421	Enmicado	1	15.00
923	434	Enmicado	1	15.00
925	435	Enmicado	4	15.00
1036	490	Enmicado	1	20.00
1068	499	Enmicado	2	15.00
1076	503	Enmicado	1	20.00
1116	522	Enmicado	1	35.00
1117	522	Enmicado	1	25.00
1134	535	Enmicado	1	25.00
1188	563	Enmicado	2	15.00
1209	572	Enmicado	1	25.00
1414	650	Enmicado	3	15.00
1418	651	Enmicado	1	25.00
1484	684	Enmicado	2	15.00
1510	692	Enmicado	1	35.00
1530	703	Enmicado	9	25.00
1532	704	Enmicado	2	25.00
1588	725	Enmicado	1	20.00
1597	729	Enmicado	1	25.00
1784	810	Enmicado	1	25.00
1879	838	Enmicado	1	15.00
2083	934	Enmicado	1	15.00
2119	955	Enmicado	1	20.00
2253	1001	Enmicado	1	25.00
2320	1028	Enmicado	1	15.00
2390	1054	Enmicado	1	15.00
2449	1075	Enmicado	1	17.00
2815	1266	Enmicado	1	25.00
2816	1267	Enmicado	2	17.00
3056	1389	Enmicado	1	25.00
3066	1394	Enmicado	1	20.00
3108	1410	Enmicado	1	25.00
3186	1442	Enmicado	1	25.00
3303	1490	Enmicado	1	20.00
3350	1510	Enmicado	1	25.00
3437	1552	Enmicado	1	20.00
3600	1619	Enmicado	1	17.00
3689	1658	Enmicado	1	25.00
3737	1680	Enmicado	1	25.00
3751	1690	Enmicado	1	15.00
3879	1754	Enmicado	1	25.00
3986	1797	Enmicado	1	15.00
4341	1989	Enmicado	1	20.00
4342	1990	Enmicado	1	25.00
4547	2091	Enmicado	2	25.00
4559	2098	Enmicado	1	25.00
4568	2104	Enmicado	1	25.00
4575	2107	Enmicado	1	17.00
4612	2127	Enmicado	1	25.00
4626	2134	Enmicado	1	25.00
4644	2144	Enmicado	1	25.00
4672	2161	Enmicado	3	25.00
4678	2165	Enmicado	1	25.00
4760	2209	Enmicado	2	25.00
4776	2217	Enmicado	1	25.00
5185	2407	Enmicado	1	25.00
5594	2596	Enmicado	3	25.00
5624	2610	Enmicado	7	25.00
6005	2772	Enmicado	1	25.00
6203	2868	Enmicado	1	20.00
6385	2957	Enmicado	1	25.00
6577	3044	Enmicado	1	15.00
6611	3060	Enmicado	1	25.00
6654	3085	Enmicado	1	20.00
6731	3123	Enmicado	1	25.00
6732	3123	Enmicado	1	15.00
6745	3127	Enmicado	1	25.00
6766	3139	Enmicado	2	15.00
6816	3155	Enmicado	1	25.00
7158	3304	Enmicado	2	25.00
7224	3339	Enmicado	1	25.00
7350	3399	Enmicado	1	20.00
7105	3281	Limpiapipas	1	1.00
209	108	Limpiapipas	24	1.00
210	108	Limpiapipas	30	1.00
211	108	Limpiapipas	30	1.00
222	114	Limpiapipas	14	1.00
223	115	Limpiapipas	5	1.00
224	115	Limpiapipas	3	1.00
225	116	Limpiapipas	30	1.00
226	116	Limpiapipas	10	1.00
227	116	Limpiapipas	5	1.00
261	135	Limpiapipas	30	1.00
262	135	Limpiapipas	5	1.00
263	135	Limpiapipas	5	1.00
597	299	Limpiapipas	2	1.00
598	299	Limpiapipas	2	1.00
1734	785	Limpiapipas	2	1.00
2191	980	Limpiapipas	17	1.00
3151	1429	Limpiapipas	3	1.00
3166	1437	Limpiapipas	20	1.00
3230	1461	Limpiapipas	5	1.00
3465	1562	Limpiapipas	10	1.00
3466	1562	Limpiapipas	5	1.00
3516	1585	Limpiapipas	1	1.00
3517	1585	Limpiapipas	4	1.00
3565	1606	Limpiapipas	5	1.00
3832	1729	Limpiapipas	5	1.00
5471	2535	Limpiapipas	1	1.00
5472	2535	Limpiapipas	1	1.00
5473	2535	Limpiapipas	1	1.00
5620	2609	Limpiapipas	20	1.00
5621	2609	Limpiapipas	20	1.00
5622	2609	Limpiapipas	20	1.00
6394	2961	Limpiapipas	35	1.00
6564	3037	Limpiapipas	2	1.00
6791	3144	Limpiapipas	2	1.00
6792	3144	Limpiapipas	2	1.00
7015	3239	Limpiapipas	2	1.00
7016	3239	Limpiapipas	2	1.00
7102	3281	Limpiapipas	1	1.00
7103	3281	Limpiapipas	1	1.00
7104	3281	Limpiapipas	1	1.00
7106	3281	Limpiapipas	2	1.00
599	299	Limpiaipas	2	1.00
596	299	Limpiapias	2	1.00
2808	1262	Rafia	1	30.00
2809	1262	Rafia	1	30.00
2810	1262	Rafia	1	30.00
5211	2417	Disco	2	10.00
134	73	Bigote	1	10.00
159	86	Bigote	1	10.00
193	102	Bigote	1	10.00
244	127	Pintura Digital/Tactil	1	22.00
245	127	Pintura Digital/Tactil	1	22.00
246	127	Pintura Digital/Tactil	1	22.00
755	355	Pintura Digital/Tactil	1	22.00
2944	1335	Pintura Textil	1	28.00
6736	3125	Pintura Textil	1	30.00
1252	588	Lapiz	1	15.00
1253	588	Lapiz	1	15.00
6585	3048	Lapiz	1	15.00
6586	3048	Lapiz	1	15.00
2724	1219	Hilo Dorado	1	4.00
930	438	Aguja	1	3.00
931	438	Aguja	2	4.00
932	438	Aguja	2	5.00
3246	1467	Aguja	1	10.00
4174	1892	Aguja	2	2.50
4312	1973	Aguja	1	10.00
4695	2175	Aguja	3	2.50
5123	2376	Aguja	1	2.50
5329	2473	Aguja	2	2.50
5924	2733	Aguja	1	2.50
335	179	Velcro X Mt.	1	15.00
6758	3135	Velcro X Mt.	1	15.00
6788	3144	Velcro X Mt.	1	15.00
428	222	Alfileres	1	13.00
1075	502	Alfileres	1	20.00
2744	1228	Alfileres	1	20.00
3395	1529	Alfileres	1	20.00
4469	2047	Alfileres	5	13.00
6674	3097	Alfileres	1	20.00
581	291	Hilo	1	20.00
1707	777	Hilo	1	20.00
1759	796	Hilo	1	20.00
3245	1467	Hilo	1	20.00
3836	1731	Hilo	1	20.00
4037	1818	Hilo	1	20.00
4038	1818	Hilo	1	20.00
4039	1818	Hilo	1	20.00
4175	1892	Hilo	1	20.00
4219	1917	Hilo	1	20.00
4696	2175	Hilo	3	20.00
4697	2175	Hilo	1	20.00
5124	2376	Hilo	1	20.00
5909	2724	Hilo	1	20.00
6296	2911	Hilo	1	20.00
8	7	Contac	2	18.00
9	8	Contac	3	15.00
24	18	Contac	2	18.00
52	34	Contac	6	15.00
175	94	Contac	6	15.00
190	100	Contac	5	15.00
252	130	Contac	1	18.00
407	213	Contac	4	18.00
530	270	Contac	1	18.00
1141	538	Contac	1	18.00
1371	631	Contac	2	18.00
1410	648	Contac	1	18.00
1432	658	Contac	1	18.00
1509	692	Contac	1	18.00
1840	829	Contac	2	18.00
2674	1197	Contac	4	15.00
2890	1308	Contac	1	18.00
3040	1378	Contac	1	18.00
3551	1602	Contac	1	18.00
4495	2062	Contac	1	18.00
4642	2143	Contac	2	18.00
4871	2255	Contac	1	10.00
4908	2271	Contac	1	18.00
5231	2425	Contac	1	10.00
5377	2494	Contac	2	18.00
6018	2779	Contac	1	10.00
6094	2814	Contac	1	18.00
6163	2844	Contac	1	18.00
6183	2857	Contac	1	18.00
6300	2913	Contac	1	18.00
116	64	Lapiz	1	7.00
179	94	Lapiz	1	7.00
434	224	Lapiz	1	7.00
494	252	Lapiz	1	7.00
648	314	Lapiz	1	10.00
674	327	Lapiz	1	10.00
773	363	Lapiz	2	7.00
800	374	Lapiz	1	7.00
866	403	Lapiz	1	10.00
890	416	Lapiz	1	7.00
1309	609	Lapiz	2	10.00
1381	635	Lapiz	1	7.00
1607	733	Lapiz	1	7.00
1705	777	Lapiz	1	10.00
1714	781	Lapiz	1	7.00
1802	817	Lapiz	1	10.00
2107	947	Lapiz	1	7.00
2173	974	Lapiz	1	7.00
2197	982	Lapiz	1	7.00
2298	1022	Lapiz	1	7.00
2342	1036	Lapiz	3	10.00
2611	1165	Lapiz	1	7.00
2689	1203	Lapiz	1	10.00
2720	1217	Lapiz	2	10.00
3101	1407	Lapiz	3	10.00
3105	1409	Lapiz	1	7.00
3148	1428	Lapiz	1	7.00
3162	1434	Lapiz	1	7.00
3247	1468	Lapiz	1	7.00
3312	1494	Lapiz	2	10.00
3368	1520	Lapiz	1	7.00
3409	1537	Lapiz	1	7.00
3547	1600	Lapiz	1	7.00
3548	1601	Lapiz	1	7.00
3608	1622	Lapiz	1	7.00
3670	1651	Lapiz	2	10.00
3778	1704	Lapiz	1	7.00
4471	2048	Lapiz	1	10.00
4489	2060	Lapiz	1	10.00
4500	2064	Lapiz	1	10.00
4512	2073	Lapiz	2	10.00
4517	2074	Lapiz	1	7.00
4634	2139	Lapiz	1	7.00
4704	2179	Lapiz	1	10.00
4775	2216	Lapiz	1	7.00
4777	2217	Lapiz	2	7.00
4812	2233	Lapiz	1	7.00
4860	2248	Lapiz	2	7.00
5064	2350	Lapiz	2	7.00
5145	2387	Lapiz	1	7.00
5167	2396	Lapiz	1	7.00
5625	2610	Lapiz	4	10.00
6109	2821	Lapiz	1	10.00
6136	2831	Lapiz	2	7.00
6145	2834	Lapiz	1	10.00
6406	2966	Lapiz	2	7.00
6434	2976	Lapiz	1	7.00
6522	3019	Lapiz	1	7.00
6535	3025	Lapiz	1	7.00
6545	3028	Lapiz	1	7.00
6566	3037	Lapiz	2	7.00
6627	3071	Lapiz	1	7.00
6686	3102	Lapiz	1	7.00
6687	3102	Lapiz	1	10.00
6709	3111	Lapiz	2	7.00
6808	3152	Lapiz	1	7.00
6849	3168	Lapiz	1	10.00
6878	3182	Lapiz	2	7.00
6981	3227	Lapiz	1	10.00
6985	3228	Lapiz	2	10.00
7056	3265	Lapiz	2	7.00
7076	3271	Lapiz	1	10.00
7127	3289	Lapiz	2	7.00
7128	3290	Lapiz	4	7.00
7324	3388	Lapiz	3	10.00
15	10	Copia B/N	5	2.00
23	17	Copia B/N	4	2.00
93	54	Copia B/N	7	2.00
156	85	Copia B/N	3	2.00
157	85	Copia B/N	2	3.00
194	103	Copia B/N	2	2.00
241	125	Copia B/N	2	2.00
242	126	Copia B/N	1	2.00
255	132	Copia B/N	10	2.00
266	137	Copia B/N	3	2.00
273	143	Copia B/N	15	2.00
284	147	Copia B/N	3	2.00
293	153	Copia B/N	1	3.00
294	154	Copia B/N	4	2.00
305	160	Copia B/N	19	2.00
307	161	Copia B/N	2	2.00
313	165	Copia B/N	4	2.00
324	172	Copia B/N	5	2.00
327	173	Copia B/N	1	2.00
330	176	Copia B/N	1	2.00
337	180	Copia B/N	6	2.00
345	183	Copia B/N	4	2.00
352	186	Copia B/N	8	2.00
353	187	Copia B/N	103	2.00
358	189	Copia B/N	9	2.00
366	196	Copia B/N	2	2.00
379	201	Copia B/N	3	2.00
388	206	Copia B/N	8	3.00
400	211	Copia B/N	2	2.00
402	213	Copia B/N	8	2.00
411	214	Copia B/N	6	2.00
412	214	Copia B/N	1	3.00
459	236	Copia B/N	1	3.00
460	236	Copia B/N	3	2.00
526	268	Copia B/N	2	2.00
577	288	Copia B/N	2	2.00
583	292	Copia B/N	7	2.00
585	293	Copia B/N	2	2.00
587	294	Copia B/N	12	2.00
590	297	Copia B/N	5	2.00
661	322	Copia B/N	6	2.00
663	323	Copia B/N	2	2.00
678	330	Copia B/N	4	2.00
700	339	Copia B/N	2	2.00
703	340	Copia B/N	3	2.00
706	341	Copia B/N	16	2.00
713	345	Copia B/N	1	3.00
736	347	Copia B/N	3	2.00
750	353	Copia B/N	2	2.00
754	354	Copia B/N	4	2.00
787	368	Copia B/N	3	2.00
792	369	Copia B/N	1	2.00
813	382	Copia B/N	7	2.00
831	390	Copia B/N	12	2.00
968	457	Copia B/N	1	2.00
971	458	Copia B/N	1	2.00
974	460	Copia B/N	7	2.00
1013	476	Copia B/N	10	2.00
1044	492	Copia B/N	2	2.00
1081	504	Copia B/N	2	2.00
1082	505	Copia B/N	1	2.00
1118	523	Copia B/N	2	2.00
1129	532	Copia B/N	2	2.00
1197	565	Copia B/N	35	3.00
1307	607	Copia B/N	5	2.00
1308	608	Copia B/N	2	3.00
1314	613	Copia B/N	4	2.00
1390	639	Copia B/N	4	2.00
1485	685	Copia B/N	3	2.00
1512	694	Copia B/N	5	2.00
1519	696	Copia B/N	3	2.00
1535	705	Copia B/N	2	3.00
1570	719	Copia B/N	1	2.00
1587	725	Copia B/N	3	2.00
1617	737	Copia B/N	2	2.00
1627	742	Copia B/N	3	2.00
1644	751	Copia B/N	1	3.00
1659	760	Copia B/N	4	2.00
1813	820	Copia B/N	4	2.00
1862	836	Copia B/N	7	2.00
1915	855	Copia B/N	16	2.00
2039	914	Copia B/N	2	2.00
2058	923	Copia B/N	2	2.00
2059	924	Copia B/N	4	2.00
2118	954	Copia B/N	1	2.00
2245	996	Copia B/N	3	2.00
2336	1034	Copia B/N	13	2.00
2337	1034	Copia B/N	32	3.00
2343	1036	Copia B/N	4	2.00
2388	1054	Copia B/N	10	2.00
2411	1062	Copia B/N	1	2.00
2637	1179	Copia B/N	1	2.00
2649	1185	Copia B/N	4	2.00
2656	1188	Copia B/N	1	2.00
2668	1193	Copia B/N	2	2.00
2669	1194	Copia B/N	4	2.00
2688	1203	Copia B/N	3	2.00
2709	1213	Copia B/N	1	2.00
2729	1222	Copia B/N	2	2.00
2730	1223	Copia B/N	1	2.00
2773	1242	Copia B/N	2	2.00
2785	1249	Copia B/N	1	2.00
2789	1252	Copia B/N	6	2.00
2791	1253	Copia B/N	5	2.00
2792	1253	Copia B/N	5	3.00
2870	1300	Copia B/N	7	2.00
2875	1303	Copia B/N	2	2.00
2906	1317	Copia B/N	2	2.00
2930	1328	Copia B/N	2	2.00
2943	1334	Copia B/N	2	2.00
2947	1337	Copia B/N	2	2.00
3025	1368	Copia B/N	2	2.00
3072	1396	Copia B/N	2	3.00
3074	1397	Copia B/N	1	2.00
3090	1404	Copia B/N	3	2.00
3102	1408	Copia B/N	6	2.00
3146	1426	Copia B/N	2	2.00
3163	1435	Copia B/N	4	2.00
3193	1446	Copia B/N	8	3.00
3269	1473	Copia B/N	4	2.00
3282	1478	Copia B/N	4	3.00
3316	1496	Copia B/N	2	2.00
3364	1517	Copia B/N	1	2.00
3411	1538	Copia B/N	3	2.00
3430	1547	Copia B/N	4	2.00
3431	1548	Copia B/N	1	2.00
3432	1549	Copia B/N	1	2.00
3434	1551	Copia B/N	4	2.00
3438	1552	Copia B/N	4	2.00
3449	1556	Copia B/N	3	2.00
3487	1573	Copia B/N	2	2.00
3494	1578	Copia B/N	16	3.00
3613	1626	Copia B/N	3	2.00
3614	1627	Copia B/N	2	2.00
3721	1672	Copia B/N	8	2.00
3732	1677	Copia B/N	15	2.00
3758	1696	Copia B/N	4	2.00
3783	1707	Copia B/N	2	2.00
3823	1724	Copia B/N	3	2.00
3824	1725	Copia B/N	4	2.00
3825	1726	Copia B/N	20	2.00
3844	1736	Copia B/N	3	3.00
3877	1753	Copia B/N	9	2.00
4000	1800	Copia B/N	4	2.00
4117	1865	Copia B/N	5	2.00
4325	1982	Copia B/N	3	2.00
4334	1986	Copia B/N	6	2.00
4380	2010	Copia B/N	1	2.00
4397	2016	Copia B/N	3	2.00
4412	2022	Copia B/N	12	2.00
4413	2022	Copia B/N	2	3.00
4417	2024	Copia B/N	8	2.00
4443	2033	Copia B/N	2	2.00
4444	2034	Copia B/N	9	2.00
4445	2035	Copia B/N	2	2.00
4451	2037	Copia B/N	4	2.00
4518	2075	Copia B/N	2	2.00
4538	2086	Copia B/N	2	2.00
4543	2088	Copia B/N	5	2.00
4550	2094	Copia B/N	1	2.00
4564	2102	Copia B/N	6	2.00
4582	2112	Copia B/N	6	2.00
4627	2134	Copia B/N	1	2.00
4681	2166	Copia B/N	1	3.00
4682	2166	Copia B/N	5	2.00
4683	2167	Copia B/N	3	3.00
4684	2168	Copia B/N	7	2.00
4709	2181	Copia B/N	6	2.00
4718	2185	Copia B/N	5	3.00
4719	2185	Copia B/N	4	2.00
4745	2202	Copia B/N	6	2.00
4759	2209	Copia B/N	1	2.00
4785	2223	Copia B/N	4	2.00
4786	2224	Copia B/N	2	2.00
4797	2227	Copia B/N	9	2.00
4801	2228	Copia B/N	1	2.00
4810	2232	Copia B/N	5	2.00
4825	2236	Copia B/N	11	2.00
4836	2237	Copia B/N	2	2.00
4856	2246	Copia B/N	2	2.00
4966	2296	Copia B/N	5	2.00
4969	2299	Copia B/N	8	2.00
4976	2302	Copia B/N	8	2.00
5035	2334	Copia B/N	1	2.00
5038	2336	Copia B/N	2	2.00
5039	2337	Copia B/N	16	2.00
5061	2348	Copia B/N	2	2.00
5109	2370	Copia B/N	7	2.00
5137	2382	Copia B/N	2	2.00
5162	2394	Copia B/N	3	2.00
5186	2407	Copia B/N	2	2.00
5238	2427	Copia B/N	5	2.00
5303	2458	Copia B/N	3	2.00
5304	2459	Copia B/N	7	2.00
5305	2460	Copia B/N	2	2.00
5323	2471	Copia B/N	4	2.00
5332	2475	Copia B/N	13	2.00
5333	2476	Copia B/N	4	2.00
5342	2479	Copia B/N	13	2.00
5366	2489	Copia B/N	3	2.00
5367	2489	Copia B/N	1	3.00
5395	2504	Copia B/N	5	2.00
5413	2510	Copia B/N	10	2.00
5465	2532	Copia B/N	4	2.00
5546	2567	Copia B/N	19	2.00
5552	2571	Copia B/N	7	2.00
5553	2572	Copia B/N	3	2.00
5564	2580	Copia B/N	2	3.00
5576	2585	Copia B/N	2	2.00
5591	2594	Copia B/N	1	2.00
5687	2634	Copia B/N	4	2.00
5712	2644	Copia B/N	10	2.00
5720	2649	Copia B/N	4	2.00
5722	2650	Copia B/N	15	2.00
5730	2653	Copia B/N	3	2.00
5740	2660	Copia B/N	2	2.00
5744	2664	Copia B/N	4	2.00
5748	2666	Copia B/N	3	2.00
5757	2670	Copia B/N	27	2.00
5785	2684	Copia B/N	1	2.00
5786	2684	Copia B/N	2	3.00
5805	2692	Copia B/N	1	2.00
5883	2715	Copia B/N	2	2.00
5894	2718	Copia B/N	2	2.00
5905	2724	Copia B/N	3	2.00
5911	2725	Copia B/N	14	2.00
5914	2728	Copia B/N	3	2.00
5930	2735	Copia B/N	2	2.00
5931	2736	Copia B/N	5	2.00
5932	2737	Copia B/N	1	2.00
5965	2752	Copia B/N	7	2.00
5966	2753	Copia B/N	3	2.00
5977	2759	Copia B/N	3	2.00
6012	2775	Copia B/N	6	2.00
6026	2783	Copia B/N	14	2.00
6053	2792	Copia B/N	3	2.00
6074	2805	Copia B/N	6	2.00
6137	2832	Copia B/N	3	2.00
6161	2843	Copia B/N	3	2.00
6280	2906	Copia B/N	5	3.00
6281	2906	Copia B/N	30	2.00
6310	2918	Copia B/N	4	2.00
6353	2937	Copia B/N	5	2.00
6439	2979	Copia B/N	6	2.00
6615	3062	Copia B/N	5	2.00
6643	3079	Copia B/N	18	2.00
6655	3085	Copia B/N	7	2.00
6707	3110	Copia B/N	13	2.00
6708	3111	Copia B/N	6	3.00
6724	3120	Copia B/N	8	2.00
6755	3133	Copia B/N	4	3.00
6765	3139	Copia B/N	4	2.00
6793	3145	Copia B/N	1	2.00
6797	3147	Copia B/N	4	2.00
6800	3149	Copia B/N	20	2.00
6868	3177	Copia B/N	4	2.00
7023	3242	Copia B/N	3	2.00
7037	3250	Copia B/N	5	2.00
7077	3272	Copia B/N	3	2.00
7079	3273	Copia B/N	2	2.00
7080	3274	Copia B/N	1	2.00
7097	3279	Copia B/N	6	3.00
7109	3282	Copia B/N	9	3.00
7117	3283	Copia B/N	1	2.00
7120	3286	Copia B/N	3	2.00
7124	3288	Copia B/N	13	3.00
7125	3288	Copia B/N	22	2.00
7148	3297	Copia B/N	27	2.00
7149	3298	Copia B/N	9	2.00
7150	3299	Copia B/N	3	2.00
7182	3315	Copia B/N	2	2.00
7205	3328	Copia B/N	3	2.00
7207	3330	Copia B/N	9	2.00
7219	3336	Copia B/N	4	2.00
7247	3353	Copia B/N	2	2.00
7295	3377	Copia B/N	6	2.00
7347	3397	Copia B/N	3	2.00
7348	3398	Copia B/N	1	2.00
7356	3402	Copia B/N	6	2.00
7368	3408	Copia B/N	1	2.00
11	9	Opalina	5	3.50
33	23	Opalina	2	3.50
101	59	Opalina	6	3.50
124	68	Opalina	2	5.00
145	79	Opalina	2	5.00
146	79	Opalina	3	3.50
228	117	Opalina	5	2.50
229	117	Opalina	5	3.50
292	152	Opalina	4	3.50
367	197	Opalina	3	3.50
488	248	Opalina	1	3.50
515	264	Opalina	3	3.50
717	347	Opalina	7	3.50
790	369	Opalina	2	3.50
847	398	Opalina	2	3.50
868	405	Opalina	1	3.50
1065	498	Opalina	2	5.00
1109	519	Opalina	1	3.50
1452	669	Opalina	3	3.50
1521	697	Opalina	1	2.50
1584	723	Opalina	2	3.50
1661	761	Opalina	2	3.50
1678	769	Opalina	2	3.50
1861	835	Opalina	1	3.50
1924	859	Opalina	1	3.50
1932	863	Opalina	1	3.50
1935	866	Opalina	1	3.50
2117	953	Opalina	1	3.50
2218	985	Opalina	4	3.50
2396	1057	Opalina	6	2.50
2663	1192	Opalina	1	3.50
2681	1201	Opalina	5	3.50
2700	1210	Opalina	3	3.50
2801	1257	Opalina	1	3.50
3076	1398	Opalina	2	3.50
3114	1412	Opalina	3	3.50
3155	1432	Opalina	3	3.50
3416	1541	Opalina	3	3.50
3421	1545	Opalina	15	3.50
3665	1648	Opalina	6	3.50
3917	1771	Opalina	1	3.50
3967	1791	Opalina	1	3.50
4021	1811	Opalina	6	3.50
4091	1845	Opalina	8	5.00
4124	1868	Opalina	1	3.50
4220	1917	Opalina	2	3.50
4487	2059	Opalina	2	3.50
4530	2081	Opalina	2	3.50
4631	2138	Opalina	2	3.50
4636	2141	Opalina	5	3.50
4767	2213	Opalina	1	3.50
4768	2214	Opalina	6	3.50
4838	2238	Opalina	2	3.50
4889	2263	Opalina	1	3.50
4991	2308	Opalina	2	3.50
5031	2331	Opalina	1	3.50
5058	2346	Opalina	3	5.00
5492	2545	Opalina	1	3.50
5897	2721	Opalina	5	3.50
6084	2809	Opalina	1	5.00
6085	2809	Opalina	1	3.50
6348	2934	Opalina	2	3.50
6513	3016	Opalina	1	3.50
6528	3023	Opalina	5	3.50
6542	3026	Opalina	1	3.50
6966	3220	Opalina	1	3.50
7232	3343	Opalina	2	3.50
7318	3387	Opalina	1	3.50
182	96	Etiqueta	1	12.00
531	270	Etiqueta	1	12.00
1270	592	Etiqueta	1	12.00
2019	904	Etiqueta	1	12.00
4519	2076	Etiqueta	1	12.00
4641	2143	Etiqueta	1	12.00
4796	2226	Etiqueta	1	12.00
5960	2750	Etiqueta	1	12.00
6982	3227	Etiqueta	1	12.00
7230	3342	Etiqueta	1	12.00
50	33	Impresion B/N	8	5.00
664	324	Impresion B/N	1	5.00
781	366	Impresion B/N	1	10.00
795	371	Impresion B/N	1	10.00
884	413	Impresion B/N	1	10.00
1004	472	Impresion B/N	1	10.00
1009	475	Impresion B/N	8	5.00
1098	512	Impresion B/N	1	10.00
1555	713	Impresion B/N	2	5.00
1699	776	Impresion B/N	7	10.00
2217	985	Impresion B/N	1	5.00
2771	1240	Impresion B/N	1	10.00
3077	1398	Impresion B/N	2	5.00
3198	1449	Impresion B/N	4	5.00
3301	1488	Impresion B/N	1	5.00
3328	1498	Impresion B/N	1	10.00
3332	1501	Impresion B/N	2	5.00
3383	1524	Impresion B/N	2	5.00
3987	1797	Impresion B/N	1	5.00
4221	1917	Impresion B/N	2	5.00
4555	2097	Impresion B/N	2	5.00
4605	2124	Impresion B/N	1	10.00
4623	2132	Impresion B/N	1	5.00
4766	2213	Impresion B/N	1	10.00
4826	2236	Impresion B/N	1	5.00
4883	2261	Impresion B/N	1	5.00
4970	2300	Impresion B/N	1	5.00
5163	2394	Impresion B/N	1	5.00
5187	2408	Impresion B/N	1	5.00
5252	2435	Impresion B/N	1	5.00
5351	2482	Impresion B/N	1	5.00
5515	2553	Impresion B/N	3	5.00
5601	2599	Impresion B/N	1	5.00
5609	2605	Impresion B/N	1	5.00
5946	2744	Impresion B/N	2	10.00
5947	2744	Impresion B/N	2	5.00
6131	2830	Impresion B/N	2	10.00
6157	2840	Impresion B/N	1	10.00
6159	2841	Impresion B/N	2	5.00
6211	2872	Impresion B/N	1	10.00
6389	2959	Impresion B/N	1	10.00
6396	2963	Impresion B/N	3	5.00
6550	3030	Impresion B/N	1	10.00
6571	3041	Impresion B/N	1	5.00
6574	3042	Impresion B/N	1	5.00
6694	3104	Impresion B/N	1	5.00
6845	3166	Impresion B/N	6	5.00
6914	3198	Impresion B/N	1	5.00
6974	3224	Impresion B/N	1	10.00
7083	3276	Impresion B/N	1	5.00
7108	3281	Impresion B/N	3	10.00
7172	3312	Impresion B/N	1	5.00
7325	3389	Impresion B/N	1	10.00
195	103	Copia Color	2	5.00
256	132	Copia Color	1	5.00
274	143	Copia Color	4	5.00
403	213	Copia Color	3	5.00
584	292	Copia Color	1	5.00
653	317	Copia Color	1	5.00
768	359	Copia Color	3	5.00
772	362	Copia Color	2	5.00
814	382	Copia Color	13	5.00
1078	504	Copia Color	8	5.00
1227	577	Copia Color	2	5.00
1376	632	Copia Color	1	5.00
1863	836	Copia Color	10	5.00
2248	997	Copia Color	67	5.00
2412	1062	Copia Color	2	5.00
2686	1202	Copia Color	27	5.00
2687	1203	Copia Color	2	5.00
2876	1304	Copia Color	1	5.00
2897	1313	Copia Color	1	5.00
2960	1345	Copia Color	3	5.00
3315	1496	Copia Color	3	5.00
4326	1982	Copia Color	2	5.00
4514	2074	Copia Color	16	5.00
4551	2094	Copia Color	6	5.00
5110	2370	Copia Color	3	5.00
5520	2557	Copia Color	6	5.00
6162	2844	Copia Color	3	5.00
7081	3275	Copia Color	4	5.00
348	185	Globo #6	5	1.50
989	466	Globo #6	2	1.50
1229	578	Globo #6	2	1.50
1273	593	Globo #6	1	1.50
1572	720	Globo #6	2	1.50
6119	2825	Globo #6	2	1.50
76	49	Globo #7	8	2.00
349	185	Globo #7	2	2.00
1255	588	Globo #7	10	2.00
1274	593	Globo #7	2	2.00
1573	720	Globo #7	2	2.00
1729	784	Globo #7	4	2.00
2049	918	Globo #7	1	24.00
2650	1185	Globo #7	6	2.00
3424	1545	Globo #7	2	2.00
3872	1751	Globo #7	1	40.00
4183	1895	Globo #7	1	24.00
4348	1992	Globo #7	2	2.00
5536	2565	Globo #7	3	2.00
6266	2896	Globo #7	7	2.00
6927	3206	Globo #7	1	24.00
6928	3206	Globo #7	6	2.00
426	220	Globo #9	1	45.00
988	466	Globo #9	3	2.50
1049	494	Globo #9	1	2.50
1131	534	Globo #9	3	2.50
1245	585	Globo #9	1	2.50
1574	720	Globo #9	2	2.50
1719	782	Globo #9	2	2.50
1767	799	Globo #9	4	2.50
1792	815	Globo #9	4	2.50
1902	851	Globo #9	3	2.50
2265	1007	Globo #9	1	45.00
2823	1272	Globo #9	3	2.50
3262	1472	Globo #9	1	45.00
5285	2452	Globo #9	2	2.50
5415	2512	Globo #9	1	45.00
5670	2628	Globo #9	2	2.50
5830	2700	Globo #9	1	80.00
6118	2825	Globo #9	2	2.50
6265	2896	Globo #9	3	2.50
6318	2923	Globo #9	4	2.50
6555	3033	Globo #9	1	45.00
6575	3043	Globo #9	4	2.50
6944	3213	Globo #9	5	2.50
6945	3214	Globo #9	3	2.50
714	345	Globo #12	2	3.00
1230	579	Globo #12	2	3.00
1244	585	Globo #12	1	3.00
1372	631	Globo #12	2	3.00
1571	720	Globo #12	2	3.00
1656	758	Globo #12	4	3.00
1775	803	Globo #12	1	3.00
2549	1141	Globo #12	1	25.00
3467	1562	Globo #12	2	3.00
4840	2239	Globo #12	10	3.00
534	272	Curli	4	1.00
544	275	Curli	12	1.00
2463	1084	Curli	5	1.00
3637	1633	Curli	8	1.00
3961	1788	Curli	4	1.00
3970	1793	Curli	10	1.00
4011	1806	Curli	3	1.00
4077	1838	Curli	16	1.00
4104	1857	Curli	18	1.00
4232	1924	Curli	8	1.00
4271	1948	Curli	5	1.00
4383	2011	Curli	4	1.00
4920	2276	Curli	4	1.00
4944	2287	Curli	5	1.00
5321	2470	Curli	2	1.00
5829	2699	Curli	3	1.00
5831	2700	Curli	20	1.00
5837	2703	Curli	4	1.00
6214	2873	Curli	6	1.00
6644	3079	Curli	2	1.00
1670	764	Curli	15	1.50
2462	1084	Curli	5	1.50
3188	1443	Curli	2	1.50
4169	1888	Curli	3	1.50
4277	1951	Curli	5	1.50
5737	2657	Curli	5	1.50
5840	2703	Curli	4	1.50
6499	3006	Curli	6	1.50
6891	3192	Curli	10	1.50
147	80	Pom Pom	12	2.50
350	186	Pom Pom	1	2.50
3423	1545	Pom Pom	1	1.50
3853	1740	Pom Pom	1	3.00
4106	1859	Pom Pom	12	1.00
6197	2865	Pom Pom	5	0.50
6789	3144	Pom Pom	2	1.50
374	198	Estambre	1	42.00
510	262	Estambre	1	42.00
2259	1003	Estambre	2	42.00
2625	1172	Estambre	1	42.00
5867	2709	Estambre	1	42.00
503	256	Estambre	1	15.00
6115	2824	Estambre	1	15.00
41	27	Cordon P/Gafet	2	6.00
91	53	Cordon P/Gafet	1	6.00
126	69	Cordon P/Gafet	1	6.00
742	350	Cordon P/Gafet	1	6.00
3698	1662	Cordon P/Gafet	1	6.00
67	44	Porta Gafet	1	25.00
265	136	Porta Gafet	1	25.00
1933	864	Porta Gafet	1	25.00
2159	968	Porta Gafet	1	25.00
5326	2472	Porta Gafet	1	40.00
5499	2549	Porta Gafet	1	25.00
5188	2408	Cinta Negra	1	15.00
438	226	Cinta Gruesa	1	35.00
578	289	Cinta Gruesa	1	35.00
920	431	Cinta Gruesa	1	55.00
921	432	Cinta Gruesa	1	35.00
1411	649	Cinta Gruesa	1	35.00
2223	988	Cinta Gruesa	1	35.00
3817	1722	Cinta Gruesa	1	35.00
4462	2043	Cinta Gruesa	1	35.00
4463	2044	Cinta Gruesa	1	35.00
4784	2222	Cinta Gruesa	1	35.00
5181	2404	Cinta Gruesa	1	35.00
5493	2546	Cinta Gruesa	2	35.00
6272	2900	Cinta Gruesa	1	35.00
6477	2999	Cinta Gruesa	1	35.00
6573	3041	Cinta Gruesa	1	35.00
7061	3268	Cinta Gruesa	1	35.00
7357	3402	Cinta Gruesa	1	35.00
1050	494	Hilaza	1	24.00
1606	733	Hilaza	1	24.00
2171	973	Hilaza	1	24.00
4155	1881	Hilaza	1	24.00
5736	2656	Hilaza	1	24.00
1342	624	Cinta Doble Cara	1	24.00
2415	1062	Cinta Doble Cara	1	24.00
3218	1454	Cinta Doble Cara	1	55.00
3557	1604	Cinta Doble Cara	1	70.00
5628	2610	Cinta Doble Cara	1	24.00
5667	2628	Cinta Doble Cara	1	24.00
6581	3047	Cinta Doble Cara	2	55.00
818	383	Cinta Maskitape	1	50.00
1478	683	Cinta Maskitape	1	30.00
2184	977	Cinta Maskitape	1	15.00
2512	1122	Cinta Maskitape	1	40.00
2900	1315	Cinta Maskitape	1	28.00
2909	1318	Cinta Maskitape	1	28.00
3620	1629	Cinta Maskitape	1	40.00
3952	1785	Cinta Maskitape	1	40.00
3988	1798	Cinta Maskitape	1	10.00
3989	1798	Cinta Maskitape	1	30.00
4186	1898	Cinta Maskitape	1	50.00
4228	1921	Cinta Maskitape	1	30.00
5047	2341	Cinta Maskitape	1	30.00
5689	2636	Cinta Maskitape	1	50.00
5874	2711	Cinta Maskitape	1	45.00
385	204	Juego Geometria	1	90.00
4557	2098	Juego Geometria	1	70.00
6437	2978	Juego de Escuadras	1	40.00
2837	1280	Flauta	1	75.00
532	271	Regla	1	8.00
917	428	Regla	1	12.00
1080	504	Regla	1	12.00
1493	687	Regla	1	35.00
2012	903	Regla	1	35.00
2679	1199	Regla	1	30.00
3284	1480	Regla	1	12.00
3355	1512	Regla	1	30.00
3586	1614	Regla	1	30.00
4381	2011	Regla	1	12.00
4526	2081	Regla	1	30.00
5256	2435	Regla	1	30.00
5642	2616	Regla	1	30.00
5644	2618	Regla	1	30.00
5694	2638	Regla	1	35.00
5920	2731	Regla	1	30.00
5944	2743	Regla	1	30.00
5952	2746	Regla	1	12.00
6061	2798	Regla	1	12.00
6865	3176	Regla	1	12.00
7140	3293	Regla	1	8.00
4369	2004	Regla	1	20.00
879	410	Cutter	1	25.00
990	466	Cutter	1	15.00
1186	562	Cutter	1	25.00
2054	920	Cutter	1	70.00
2335	1033	Cutter	2	15.00
2527	1133	Cutter	1	25.00
2992	1357	Cutter	1	15.00
5516	2554	Cutter	1	25.00
6464	2994	Cutter	1	25.00
7170	3311	Cutter	1	15.00
243	126	Solicitud de Empleo	2	2.50
269	140	Solicitud de Empleo	3	2.50
508	260	Solicitud de Empleo	7	2.50
620	309	Solicitud de Empleo	4	2.50
1094	508	Solicitud de Empleo	4	2.50
1153	547	Solicitud de Empleo	2	2.50
1310	610	Solicitud de Empleo	4	2.50
1383	636	Solicitud de Empleo	3	2.50
1472	681	Solicitud de Empleo	3	2.50
2433	1070	Solicitud de Empleo	1	2.50
2746	1229	Solicitud de Empleo	3	2.50
2948	1338	Solicitud de Empleo	1	2.50
3160	1434	Solicitud de Empleo	1	2.50
3283	1479	Solicitud de Empleo	2	2.50
3452	1558	Solicitud de Empleo	5	2.50
4346	1991	Solicitud de Empleo	2	2.50
4536	2085	Solicitud de Empleo	4	2.50
4740	2199	Solicitud de Empleo	4	2.50
4763	2210	Solicitud de Empleo	1	2.50
4864	2250	Solicitud de Empleo	3	2.50
4965	2295	Solicitud de Empleo	4	2.50
5098	2363	Solicitud de Empleo	1	2.50
5120	2375	Solicitud de Empleo	2	2.50
5374	2492	Solicitud de Empleo	1	2.50
5523	2560	Solicitud de Empleo	4	2.50
5532	2563	Solicitud de Empleo	3	2.50
5577	2586	Solicitud de Empleo	6	2.50
5611	2605	Solicitud de Empleo	1	2.50
5929	2735	Solicitud de Empleo	1	2.50
7098	3280	Solicitud de Empleo	2	2.50
7287	3372	Solicitud de Empleo	3	2.50
6584	3047	Hojas Blanca	1	25.00
6918	3199	Hojas Blanca	1	13.00
7332	3390	Hojas Blanca	1	25.00
7338	3394	Hojas Blanca	1	13.00
304	160	Protector de Hoja	1	2.00
1115	522	Protector de Hoja	5	2.00
2025	907	Protector de Hoja	1	2.00
5596	2596	Protector de Hoja	1	2.00
6316	2921	Protector de Hoja	10	2.00
53	34	Corrector	1	25.00
183	96	Corrector	1	25.00
184	96	Corrector	1	25.00
196	104	Corrector	1	25.00
386	205	Corrector	1	20.00
415	215	Corrector	1	25.00
468	241	Corrector	1	25.00
1237	582	Corrector	1	25.00
1304	605	Corrector	1	25.00
1575	720	Corrector	2	22.00
1698	775	Corrector	1	22.00
1756	795	Corrector	1	25.00
2635	1179	Corrector	1	25.00
2636	1179	Corrector	1	25.00
2754	1232	Corrector	1	25.00
2821	1270	Corrector	1	25.00
2976	1350	Corrector	1	25.00
3285	1480	Corrector	1	25.00
3334	1503	Corrector	1	22.00
3814	1720	Corrector	1	25.00
3888	1759	Corrector	1	25.00
4036	1817	Corrector	1	25.00
4565	2103	Corrector	1	25.00
4646	2145	Corrector	1	25.00
4649	2146	Corrector	1	25.00
5255	2435	Corrector	1	25.00
5477	2537	Corrector	1	22.00
5723	2651	Corrector	1	22.00
6200	2866	Corrector	1	25.00
6302	2914	Corrector	1	25.00
6455	2987	Corrector	1	25.00
6502	3008	Corrector	1	25.00
6695	3104	Corrector	1	25.00
6771	3141	Corrector	1	25.00
6847	3167	Corrector	1	25.00
6980	3227	Corrector	1	22.00
7181	3315	Corrector	1	25.00
7323	3388	Corrector	1	22.00
21	15	Carpeta T/Carta	1	5.00
270	140	Carpeta T/Carta	1	5.00
283	146	Carpeta T/Carta	2	5.00
318	168	Carpeta T/Carta	1	5.00
346	184	Carpeta T/Carta	1	5.00
384	204	Carpeta T/Carta	1	5.00
397	210	Carpeta T/Carta	1	5.00
398	210	Carpeta T/Carta	1	5.00
399	211	Carpeta T/Carta	1	5.00
491	250	Carpeta T/Carta	1	5.00
493	252	Carpeta T/Carta	1	5.00
575	286	Carpeta T/Carta	1	5.00
623	311	Carpeta T/Carta	1	5.00
624	311	Carpeta T/Carta	2	5.00
705	340	Carpeta T/Carta	1	5.00
749	353	Carpeta T/Carta	1	5.00
752	354	Carpeta T/Carta	1	5.00
882	411	Carpeta T/Carta	20	5.00
1170	558	Carpeta T/Carta	2	5.00
1258	589	Carpeta T/Carta	2	5.00
1541	707	Carpeta T/Carta	1	5.00
1628	742	Carpeta T/Carta	1	5.00
1967	881	Carpeta T/Carta	1	5.00
2221	987	Carpeta T/Carta	1	5.00
2232	991	Carpeta T/Carta	1	5.00
2284	1018	Carpeta T/Carta	1	5.00
2397	1057	Carpeta T/Carta	2	9.00
2450	1076	Carpeta T/Carta	1	5.00
2607	1161	Carpeta T/Carta	6	5.00
2676	1198	Carpeta T/Carta	1	9.00
2905	1316	Carpeta T/Carta	1	5.00
2961	1346	Carpeta T/Carta	1	5.00
3024	1368	Carpeta T/Carta	2	5.00
3029	1370	Carpeta T/Carta	1	5.00
3133	1419	Carpeta T/Carta	1	5.00
3159	1434	Carpeta T/Carta	1	5.00
3436	1551	Carpeta T/Carta	1	5.00
3556	1603	Carpeta T/Carta	1	5.00
3733	1677	Carpeta T/Carta	1	5.00
3909	1767	Carpeta T/Carta	1	5.00
4002	1801	Carpeta T/Carta	1	5.00
4005	1802	Carpeta T/Carta	1	5.00
4314	1974	Carpeta T/Carta	1	5.00
4316	1976	Carpeta T/Carta	1	5.00
4327	1982	Carpeta T/Carta	1	5.00
4333	1985	Carpeta T/Carta	1	5.00
4442	2033	Carpeta T/Carta	1	5.00
4539	2086	Carpeta T/Carta	1	5.00
4599	2121	Carpeta T/Carta	1	9.00
4602	2122	Carpeta T/Carta	1	9.00
4617	2129	Carpeta T/Carta	1	5.00
4640	2143	Carpeta T/Carta	2	9.00
4685	2168	Carpeta T/Carta	1	5.00
4756	2207	Carpeta T/Carta	1	5.00
4773	2215	Carpeta T/Carta	3	5.00
4798	2227	Carpeta T/Carta	1	5.00
4916	2276	Carpeta T/Carta	1	5.00
4933	2282	Carpeta T/Carta	1	5.00
4953	2291	Carpeta T/Carta	1	9.00
5016	2322	Carpeta T/Carta	4	9.00
5057	2345	Carpeta T/Carta	1	5.00
5078	2353	Carpeta T/Carta	1	5.00
5154	2391	Carpeta T/Carta	1	5.00
5172	2399	Carpeta T/Carta	1	5.00
5198	2411	Carpeta T/Carta	1	9.00
5240	2428	Carpeta T/Carta	1	5.00
5248	2433	Carpeta T/Carta	1	5.00
5318	2468	Carpeta T/Carta	1	5.00
5352	2482	Carpeta T/Carta	1	5.00
5610	2605	Carpeta T/Carta	1	5.00
5719	2648	Carpeta T/Carta	1	9.00
5758	2670	Carpeta T/Carta	1	5.00
5927	2734	Carpeta T/Carta	1	5.00
5964	2752	Carpeta T/Carta	1	5.00
6015	2778	Carpeta T/Carta	2	5.00
6016	2778	Carpeta T/Carta	1	5.00
6070	2803	Carpeta T/Carta	1	5.00
6140	2833	Carpeta T/Carta	1	5.00
6209	2871	Carpeta T/Carta	1	5.00
6223	2877	Carpeta T/Carta	1	5.00
6275	2902	Carpeta T/Carta	1	5.00
6277	2903	Carpeta T/Carta	1	5.00
6308	2916	Carpeta T/Carta	1	5.00
6314	2919	Carpeta T/Carta	1	5.00
6454	2987	Carpeta T/Carta	1	5.00
6468	2995	Carpeta T/Carta	1	5.00
6484	3001	Carpeta T/Carta	1	5.00
6541	3026	Carpeta T/Carta	1	5.00
6572	3041	Carpeta T/Carta	1	5.00
6685	3101	Carpeta T/Carta	1	5.00
6716	3117	Carpeta T/Carta	1	5.00
6717	3117	Carpeta T/Carta	1	5.00
7039	3251	Carpeta T/Carta	1	5.00
7210	3330	Carpeta T/Carta	1	5.00
7213	3333	Carpeta T/Carta	1	5.00
7222	3337	Carpeta T/Carta	1	5.00
7266	3362	Carpeta T/Carta	1	5.00
7339	3394	Carpeta T/Carta	1	5.00
458	236	Carpeta T/Oficio	1	7.00
1198	565	Carpeta T/Oficio	2	7.00
1966	881	Carpeta T/Oficio	1	7.00
2616	1167	Carpeta T/Oficio	1	7.00
3495	1579	Carpeta T/Oficio	1	7.00
3910	1767	Carpeta T/Oficio	1	7.00
4116	1865	Carpeta T/Oficio	1	7.00
5904	2724	Carpeta T/Oficio	2	7.00
6264	2895	Carpeta T/Oficio	1	7.00
6730	3122	Carpeta T/Oficio	1	7.00
6756	3133	Carpeta T/Oficio	1	7.00
7096	3279	Carpeta T/Oficio	1	7.00
347	185	Popote	4	1.00
501	256	Popote	10	1.00
1577	720	Popote	4	1.00
1727	784	Popote	2	1.00
1765	799	Popote	4	1.00
1987	890	Popote	2	1.00
2244	996	Popote	6	1.00
5538	2565	Popote	3	1.00
5669	2628	Popote	2	1.00
6465	2994	Popote	10	1.00
22	16	Forrado	5	15.00
39	26	Forrado	2	25.00
75	49	Forrado	7	20.00
103	60	Forrado	1	15.00
130	70	Forrado	8	15.00
254	131	Forrado	15	15.00
325	173	Forrado	1	15.00
396	209	Forrado	1	15.00
464	238	Forrado	1	15.00
519	264	Forrado	2	15.00
541	274	Forrado	1	25.00
867	404	Forrado	1	20.00
959	452	Forrado	9	15.00
1387	638	Forrado	1	25.00
1388	638	Forrado	1	15.00
4552	2095	Forrado	1	25.00
4837	2237	Forrado	1	25.00
4960	2293	Forrado	3	15.00
5949	2746	Forrado	1	20.00
6734	3123	Forrado	1	15.00
7073	3271	Forrado	1	20.00
7228	3342	Forrado	1	20.00
7229	3342	Forrado	1	25.00
176	94	Cuaderno Profecional Cocido	1	75.00
181	96	Cuaderno Profecional Cocido	1	75.00
2196	982	Cuaderno Profecional Cocido	1	75.00
2664	1192	Cuaderno Profecional Cocido	1	75.00
4707	2180	Cuaderno Profecional Cocido	1	75.00
4906	2271	Cuaderno Profecional Cocido	1	75.00
7055	3265	Cuaderno Profecional Cocido	1	75.00
1954	877	Transportador	1	15.00
5265	2442	Transportador	1	25.00
6864	3176	Transportador	1	15.00
6908	3197	Transportador	1	15.00
6056	2794	Chaquira	3	5.00
2016	904	Chaquiron	1	5.00
3232	1461	Chaquiron	1	5.00
720	347	Lentejuela	1	5.00
1028	485	Lentejuela	2	5.00
2743	1228	Lentejuela	6	5.00
3271	1474	Lentejuela	3	5.00
155	84	Diamantina	3	5.00
719	347	Diamantina	2	5.00
979	463	Diamantina	1	5.00
986	465	Diamantina	3	5.00
1144	540	Diamantina	2	5.00
1215	574	Diamantina	1	5.00
1261	591	Diamantina	4	5.00
1286	599	Diamantina	2	5.00
1436	661	Diamantina	3	5.00
1506	691	Diamantina	5	5.00
1752	793	Diamantina	1	35.00
1847	832	Diamantina	6	5.00
1880	838	Diamantina	5	5.00
1943	870	Diamantina	2	5.00
1988	891	Diamantina	2	5.00
1989	892	Diamantina	1	5.00
2015	904	Diamantina	2	5.00
2113	951	Diamantina	6	5.00
2115	953	Diamantina	3	5.00
2187	978	Diamantina	2	5.00
2355	1039	Diamantina	1	5.00
2654	1187	Diamantina	2	5.00
2711	1213	Diamantina	1	5.00
3086	1403	Diamantina	2	5.00
3231	1461	Diamantina	1	5.00
3270	1474	Diamantina	3	5.00
3763	1699	Diamantina	2	5.00
3880	1755	Diamantina	2	5.00
4628	2135	Diamantina	2	5.00
4674	2162	Diamantina	1	5.00
5148	2388	Diamantina	5	5.00
6011	2774	Diamantina	2	5.00
6251	2886	Diamantina	2	5.00
6304	2915	Diamantina	3	5.00
6740	3125	Diamantina	2	5.00
6778	3142	Diamantina	1	5.00
7100	3281	Diamantina	2	5.00
1070	500	Decoracion	1	25.00
1445	667	Decoracion	1	25.00
1609	733	Decoracion	1	25.00
1825	825	Decoracion	1	25.00
1842	829	Decoracion	1	25.00
1848	832	Decoracion	1	25.00
1948	873	Decoracion	1	25.00
1963	880	Decoracion	2	25.00
2132	960	Decoracion	1	25.00
2150	964	Decoracion	1	25.00
2576	1148	Decoracion	1	25.00
2604	1159	Decoracion	1	25.00
6497	3004	Estrella Ch,med,gde	1	20.00
6704	3107	Estrella Ch,med,gde	1	20.00
132	71	Etiqueta Redonda	1	20.00
1328	619	Colores Cortos	1	12.00
3233	1462	Colores Cortos	1	20.00
6613	3061	Colores Cortos	1	20.00
6880	3184	Colores Cortos	1	20.00
30	23	Papel China	1	2.50
31	23	Papel China	1	2.50
137	74	Papel China	1	2.50
138	74	Papel China	1	2.50
475	245	Papel China	1	2.50
476	245	Papel China	1	2.50
536	272	Papel China	2	2.50
588	295	Papel China	1	2.50
617	307	Papel China	5	2.50
695	336	Papel China	1	2.50
696	336	Papel China	1	2.50
731	347	Papel China	1	2.50
733	347	Papel China	1	2.50
734	347	Papel China	1	2.50
735	347	Papel China	1	2.50
815	383	Papel China	10	2.50
816	383	Papel China	2	2.50
928	437	Papel China	4	2.50
929	437	Papel China	2	2.50
949	444	Papel China	5	2.50
957	451	Papel China	4	2.50
958	451	Papel China	3	2.50
1035	489	Papel China	1	2.50
1106	517	Papel China	2	2.50
1195	564	Papel China	1	2.50
1231	579	Papel China	1	2.50
1232	579	Papel China	2	2.50
1487	686	Papel China	1	2.50
1488	686	Papel China	1	2.50
1545	709	Papel China	2	2.50
1616	736	Papel China	1	2.50
1620	739	Papel China	2	2.50
1621	739	Papel China	2	2.50
1631	745	Papel China	1	2.50
1640	748	Papel China	2	2.50
1782	808	Papel China	20	2.50
1786	810	Papel China	1	2.50
1827	825	Papel China	2	2.50
1828	825	Papel China	2	2.50
1829	825	Papel China	1	2.50
2031	911	Papel China	2	2.50
2032	911	Papel China	2	2.50
2072	929	Papel China	4	2.50
2073	929	Papel China	4	2.50
2075	930	Papel China	3	2.50
2100	944	Papel China	10	2.50
2101	944	Papel China	10	2.50
2128	958	Papel China	1	2.50
2134	962	Papel China	1	2.50
2135	962	Papel China	1	2.50
2137	962	Papel China	1	2.50
2142	963	Papel China	1	2.50
2143	963	Papel China	1	2.50
2144	963	Papel China	1	2.50
2166	972	Papel China	2	2.50
2167	972	Papel China	2	2.50
2202	983	Papel China	2	2.50
2206	983	Papel China	1	2.50
2207	983	Papel China	1	2.50
2208	983	Papel China	1	2.50
2276	1014	Papel China	1	2.50
2277	1014	Papel China	1	2.50
2285	1019	Papel China	1	2.50
2286	1019	Papel China	1	2.50
2339	1035	Papel China	3	2.50
2345	1037	Papel China	1	2.50
2346	1037	Papel China	1	2.50
2380	1051	Papel China	1	2.50
2387	1053	Papel China	1	2.50
2417	1062	Papel China	3	2.50
2507	1120	Papel China	5	2.50
2508	1120	Papel China	5	2.50
2545	1139	Papel China	1	2.50
2547	1139	Papel China	1	2.50
2552	1142	Papel China	2	2.50
2553	1142	Papel China	2	2.50
2557	1144	Papel China	1	2.50
2558	1144	Papel China	1	2.50
2559	1144	Papel China	2	2.50
2575	1148	Papel China	4	2.50
2577	1149	Papel China	1	2.50
2578	1149	Papel China	1	2.50
2586	1151	Papel China	2	2.50
2713	1214	Papel China	1	2.50
2734	1225	Papel China	2	2.50
3174	1438	Papel China	2	2.50
3176	1438	Papel China	2	2.50
3177	1438	Papel China	2	2.50
3238	1464	Papel China	5	2.50
3239	1464	Papel China	5	2.50
3318	1496	Papel China	5	2.50
3458	1561	Papel China	2	2.50
3459	1561	Papel China	2	2.50
3462	1561	Papel China	2	2.50
3463	1562	Papel China	3	2.50
3464	1562	Papel China	3	2.50
3492	1577	Papel China	4	2.50
3761	1698	Papel China	1	2.50
3833	1730	Papel China	4	2.50
3860	1744	Papel China	3	2.50
3903	1764	Papel China	2	2.50
3951	1785	Papel China	1	2.50
3984	1796	Papel China	1	2.50
3992	1798	Papel China	1	2.50
4050	1826	Papel China	3	2.50
4051	1826	Papel China	3	2.50
4094	1847	Papel China	2	2.50
4108	1861	Papel China	3	2.50
4109	1861	Papel China	3	2.50
4110	1861	Papel China	3	2.50
4129	1872	Papel China	3	2.50
4130	1872	Papel China	3	2.50
4131	1872	Papel China	3	2.50
4132	1872	Papel China	3	2.50
4133	1873	Papel China	1	2.50
4134	1873	Papel China	1	2.50
4162	1886	Papel China	2	2.50
4163	1886	Papel China	2	2.50
4262	1944	Papel China	4	2.50
4263	1944	Papel China	2	2.50
4352	1995	Papel China	6	2.50
4716	2184	Papel China	2	2.50
4849	2243	Papel China	1	2.50
4850	2243	Papel China	1	2.50
4853	2245	Papel China	1	2.50
4854	2245	Papel China	1	2.50
4940	2287	Papel China	1	2.50
4941	2287	Papel China	1	2.50
4942	2287	Papel China	1	2.50
5232	2425	Papel China	1	2.50
5494	2547	Papel China	1	2.50
5495	2547	Papel China	1	2.50
5800	2691	Papel China	1	2.50
5875	2711	Papel China	2	2.50
6193	2865	Papel China	1	2.50
6194	2865	Papel China	1	2.50
6195	2865	Papel China	1	2.50
6242	2883	Papel China	1	2.50
6243	2883	Papel China	1	2.50
6258	2893	Papel China	1	2.50
6259	2893	Papel China	1	2.50
6589	3050	Papel China	2	2.50
6896	3195	Papel China	1	2.50
6897	3195	Papel China	1	2.50
6898	3195	Papel China	1	2.50
6899	3195	Papel China	1	2.50
6900	3195	Papel China	1	2.50
6901	3195	Papel China	1	2.50
6902	3195	Papel China	1	2.50
6903	3195	Papel China	1	2.50
6904	3195	Papel China	1	2.50
6938	3209	Papel China	2	2.50
6951	3215	Papel China	4	2.50
7118	3284	Papel China	1	2.50
7277	3366	Papel China	2	2.50
48	32	Impresion Color	2	8.00
55	35	Impresion Color	4	8.00
60	39	Impresion Color	1	8.00
65	42	Impresion Color	2	8.00
373	197	Impresion Color	1	8.00
450	231	Impresion Color	1	8.00
470	241	Impresion Color	1	8.00
656	319	Impresion Color	1	8.00
846	398	Impresion Color	1	8.00
875	408	Impresion Color	1	8.00
1055	496	Impresion Color	10	8.00
1159	550	Impresion Color	1	8.00
1199	565	Impresion Color	4	8.00
1594	727	Impresion Color	2	8.00
1833	826	Impresion Color	1	8.00
2033	912	Impresion Color	1	8.00
2437	1071	Impresion Color	11	8.00
2640	1181	Impresion Color	1	8.00
2662	1192	Impresion Color	1	8.00
2781	1247	Impresion Color	1	8.00
2846	1285	Impresion Color	1	8.00
2892	1309	Impresion Color	1	8.00
2894	1311	Impresion Color	1	8.00
2955	1342	Impresion Color	2	8.00
2981	1352	Impresion Color	6	8.00
3039	1378	Impresion Color	2	8.00
3145	1425	Impresion Color	1	8.00
3288	1482	Impresion Color	1	8.00
3674	1652	Impresion Color	1	8.00
3749	1688	Impresion Color	1	8.00
3916	1771	Impresion Color	1	8.00
4040	1819	Impresion Color	1	8.00
4123	1868	Impresion Color	2	8.00
4200	1906	Impresion Color	1	8.00
4337	1987	Impresion Color	1	8.00
4373	2005	Impresion Color	1	8.00
4687	2169	Impresion Color	1	8.00
4693	2174	Impresion Color	2	8.00
4880	2260	Impresion Color	1	8.00
4930	2281	Impresion Color	3	8.00
4938	2286	Impresion Color	4	8.00
4945	2288	Impresion Color	3	8.00
4975	2302	Impresion Color	8	8.00
5082	2355	Impresion Color	1	8.00
5302	2458	Impresion Color	1	8.00
5359	2485	Impresion Color	1	8.00
5424	2514	Impresion Color	1	8.00
5461	2529	Impresion Color	1	8.00
5509	2550	Impresion Color	1	8.00
5571	2582	Impresion Color	1	8.00
5663	2625	Impresion Color	5	8.00
5726	2652	Impresion Color	1	8.00
5767	2677	Impresion Color	1	8.00
5775	2678	Impresion Color	1	8.00
5776	2679	Impresion Color	1	8.00
5795	2688	Impresion Color	2	8.00
5822	2697	Impresion Color	21	8.00
5887	2717	Impresion Color	1	8.00
5973	2757	Impresion Color	1	8.00
6156	2839	Impresion Color	1	8.00
6158	2841	Impresion Color	4	8.00
6165	2846	Impresion Color	1	8.00
6336	2933	Impresion Color	4	8.00
6347	2934	Impresion Color	2	8.00
6419	2969	Impresion Color	4	8.00
6492	3003	Impresion Color	1	8.00
6543	3027	Impresion Color	6	8.00
6656	3086	Impresion Color	1	8.00
6795	3146	Impresion Color	1	8.00
7144	3295	Impresion Color	2	8.00
26	20	Sobre Nomina	3	2.50
203	107	Sobre Nomina	2	2.50
3472	1566	Sobre Nomina	4	2.50
4090	1844	Sobre Nomina	4	2.50
4303	1966	Sobre Nomina	6	2.50
6077	2806	Sobre Nomina	1	2.50
6420	2970	Sobre Nomina	5	2.50
6423	2971	Sobre Nomina	1	2.50
7199	3324	Sobre Nomina	10	2.50
3473	1567	Sobre Blanco	17	2.50
4553	2096	Sobre Blanco	1	2.50
5298	2456	Sobre Blanco	1	2.50
5319	2468	Sobre Blanco	2	2.50
5725	2651	Sobre Blanco	1	2.50
6120	2826	Sobre Blanco	3	2.50
6448	2983	Sobre Blanco	2	2.50
7059	3266	Sobre Blanco	1	2.50
2942	1334	Sobre Mini	5	2.50
4188	1899	Sobre Mini	1	2.50
548	276	Sobre Mediano	1	3.50
626	312	Sobre Mediano	5	3.50
1846	831	Sobre Mediano	1	3.50
3875	1752	Sobre Mediano	1	3.50
4032	1815	Sobre Mediano	1	3.50
4076	1838	Sobre Mediano	8	3.50
4243	1933	Sobre Mediano	2	3.50
4311	1972	Sobre Mediano	1	3.50
5020	2324	Sobre Mediano	3	3.50
5388	2499	Sobre Mediano	3	3.50
5632	2612	Sobre Mediano	15	3.50
5657	2622	Sobre Mediano	5	3.50
5709	2643	Sobre Mediano	3	3.50
5815	2695	Sobre Mediano	8	3.50
547	276	Sobre Grande	1	5.00
707	342	Sobre Grande	2	5.00
1015	478	Sobre Grande	1	5.00
2096	941	Sobre Grande	2	5.00
2775	1244	Sobre Grande	1	5.00
2776	1245	Sobre Grande	1	5.00
3953	1786	Sobre Grande	1	5.00
4024	1812	Sobre Grande	1	5.00
4079	1839	Sobre Grande	1	5.00
4119	1867	Sobre Grande	11	5.00
4139	1874	Sobre Grande	1	5.00
5768	2677	Sobre Grande	2	5.00
5812	2694	Sobre Grande	2	5.00
6060	2797	Sobre Grande	4	5.00
955	449	Sobre Cumple	1	13.00
1169	557	Sobre Cumple	1	5.00
3738	1680	Sobre Cumple	1	5.00
3739	1681	Sobre Cumple	1	5.00
5903	2723	Sobre Cumple	1	13.00
6052	2791	Sobre Cumple	1	13.00
32	23	Papel China	1	2.50
139	74	Papel China	1	2.50
198	105	Papel China	10	2.50
199	105	Papel China	10	2.50
332	177	Papel China	1	2.50
732	347	Papel China	1	2.50
945	443	Papel China	6	2.50
948	444	Papel China	2	2.50
1122	526	Papel China	20	2.50
1175	561	Papel China	2	2.50
1176	561	Papel China	2	2.50
1490	686	Papel China	1	2.50
1543	709	Papel China	2	2.50
1544	709	Papel China	1	2.50
1639	748	Papel China	2	2.50
1657	759	Papel China	3	2.50
1671	765	Papel China	2	2.50
1672	765	Papel China	2	2.50
1683	770	Papel China	1	2.50
1733	785	Papel China	1	2.50
1826	825	Papel China	2	2.50
1931	863	Papel China	4	2.50
2071	929	Papel China	4	2.50
2104	946	Papel China	4	2.50
2136	962	Papel China	1	2.50
2138	962	Papel China	1	2.50
2203	983	Papel China	2	2.50
2204	983	Papel China	2	2.50
2205	983	Papel China	1	2.50
2287	1019	Papel China	1	2.50
2347	1037	Papel China	1	2.50
2418	1062	Papel China	1	2.50
2506	1120	Papel China	5	2.50
2520	1127	Papel China	2	2.50
2546	1139	Papel China	1	2.50
2554	1142	Papel China	2	2.50
2574	1148	Papel China	4	2.50
2579	1149	Papel China	1	2.50
2580	1149	Papel China	1	2.50
2581	1149	Papel China	1	2.50
2585	1151	Papel China	2	2.50
2714	1214	Papel China	1	2.50
3175	1438	Papel China	2	2.50
3460	1561	Papel China	2	2.50
3461	1561	Papel China	2	2.50
3544	1599	Papel China	3	2.50
3762	1698	Papel China	1	2.50
3861	1744	Papel China	3	2.50
3899	1763	Papel China	6	2.50
4014	1808	Papel China	2	2.50
4160	1884	Papel China	1	2.50
4814	2233	Papel China	6	2.50
4848	2243	Papel China	1	2.50
4855	2245	Papel China	1	2.50
6260	2893	Papel China	1	2.50
6322	2924	Papel China	2	2.50
6905	3195	Papel China	1	2.50
6939	3209	Papel China	1	2.50
7276	3366	Papel China	1	2.50
46	30	Caja Anillo	1	15.00
178	94	Caja Anillo	1	15.00
1648	755	Caja Anillo	1	15.00
1685	771	Caja Anillo	1	30.00
2615	1166	Caja Anillo	1	30.00
3442	1553	Caja Anillo	2	20.00
3443	1553	Caja Anillo	1	15.00
3734	1678	Caja Anillo	1	10.00
3753	1692	Caja Anillo	2	20.00
4236	1927	Caja Anillo	2	15.00
4274	1949	Caja Anillo	1	15.00
5749	2666	Caja Anillo	1	15.00
5841	2703	Caja Anillo	2	20.00
5842	2703	Caja Anillo	1	30.00
6091	2811	Caja Anillo	1	15.00
6380	2954	Caja Anillo	1	20.00
45	30	Vela Magica	1	26.00
567	283	Vela Magica	1	26.00
791	369	Vela Magica	1	26.00
1386	638	Vela Magica	1	26.00
1864	836	Vela Magica	1	26.00
2838	1281	Vela Magica	1	26.00
2920	1323	Vela Magica	1	26.00
3445	1553	Vela Magica	2	26.00
3977	1795	Vela Magica	1	26.00
5417	2512	Vela Magica	1	26.00
5688	2635	Vela Magica	1	26.00
5817	2697	Vela Magica	1	26.00
7223	3338	Vela Magica	1	26.00
47	31	Palo	4	0.75
1018	479	Palo	36	0.75
1220	575	Palo	2	0.75
1362	627	Palo	6	0.75
2003	899	Palo	2	0.75
3573	1610	Palo	10	0.75
3596	1618	Palo	6	0.75
3810	1719	Palo	2	0.75
4103	1856	Palo	10	0.75
4120	1868	Palo	78	0.75
4608	2125	Palo	20	0.75
5024	2328	Palo	12	0.75
5156	2392	Palo	5	0.75
5282	2450	Palo	4	0.75
5311	2463	Palo	16	0.75
5476	2536	Palo	10	0.75
5519	2556	Palo	27	0.75
6225	2879	Palo	4	0.75
6514	3016	Palo	2	0.75
6524	3021	Palo	2	0.75
7042	3254	Palo	8	0.75
69	45	Bola Unicel	2	1.50
72	47	Bola Unicel	4	4.00
117	64	Bola Unicel	2	4.00
449	231	Bola Unicel	3	3.00
600	299	Bola Unicel	6	3.00
854	399	Bola Unicel	20	1.00
855	399	Bola Unicel	1	12.00
984	465	Bola Unicel	1	25.00
1192	564	Bola Unicel	1	25.00
1380	635	Bola Unicel	1	35.00
2176	975	Bola Unicel	1	1.50
2427	1068	Bola Unicel	6	3.00
2628	1175	Bola Unicel	6	3.00
2629	1175	Bola Unicel	6	1.50
2630	1175	Bola Unicel	6	1.50
2735	1226	Bola Unicel	2	12.00
2742	1228	Bola Unicel	2	8.00
2873	1301	Bola Unicel	1	50.00
2878	1305	Bola Unicel	2	25.00
3371	1522	Bola Unicel	1	3.50
3372	1522	Bola Unicel	1	3.00
3518	1585	Bola Unicel	1	35.00
3519	1585	Bola Unicel	1	16.00
3559	1606	Bola Unicel	1	8.00
3571	1610	Bola Unicel	20	1.50
3595	1618	Bola Unicel	10	1.50
3676	1653	Bola Unicel	1	3.50
3677	1653	Bola Unicel	1	4.00
3678	1653	Bola Unicel	1	3.00
3687	1657	Bola Unicel	1	8.00
3688	1657	Bola Unicel	1	12.00
3946	1784	Bola Unicel	1	50.00
4018	1809	Bola Unicel	2	8.00
4153	1881	Bola Unicel	13	3.50
4154	1881	Bola Unicel	14	3.00
4182	1895	Bola Unicel	4	3.50
4287	1958	Bola Unicel	10	1.50
4288	1958	Bola Unicel	6	3.50
5065	2351	Bola Unicel	2	1.50
5066	2351	Bola Unicel	3	3.50
5067	2351	Bola Unicel	5	6.00
5704	2640	Bola Unicel	1	16.00
5705	2640	Bola Unicel	1	8.00
5893	2717	Bola Unicel	1	16.00
6009	2774	Bola Unicel	1	12.00
6034	2786	Bola Unicel	2	1.50
6141	2834	Bola Unicel	4	4.00
6142	2834	Bola Unicel	4	3.50
6171	2849	Bola Unicel	1	50.00
6179	2855	Bola Unicel	6	1.50
6180	2855	Bola Unicel	6	1.00
6429	2973	Bola Unicel	6	4.00
6653	3084	Bola Unicel	1	1.00
7041	3253	Bola Unicel	2	12.00
7054	3264	Bola Unicel	1	12.00
7130	3292	Bola Unicel	1	3.50
7131	3292	Bola Unicel	1	4.00
7132	3292	Bola Unicel	1	6.00
7133	3292	Bola Unicel	1	8.00
7134	3292	Bola Unicel	1	12.00
7135	3292	Bola Unicel	1	16.00
7136	3292	Bola Unicel	1	25.00
7310	3382	Bola Unicel	10	1.50
7314	3386	Bola Unicel	1	35.00
7346	3396	Bola Unicel	2	16.00
2129	958	Plato Chico	2	3.00
404	213	Tabla	1	20.00
1724	782	Tabla	1	20.00
2349	1038	Tabla	1	20.00
2671	1196	Tabla	1	10.00
2696	1209	Tabla	1	35.00
2882	1305	Tabla	1	20.00
2916	1322	Tabla	1	48.00
3123	1416	Tabla	1	20.00
3510	1585	Tabla	1	20.00
3572	1610	Tabla	1	20.00
3786	1709	Tabla	1	20.00
3813	1720	Tabla	1	10.00
3996	1799	Tabla	1	15.00
4577	2108	Tabla	1	30.00
4923	2277	Tabla	1	10.00
5059	2346	Tabla	1	15.00
5336	2478	Tabla	1	20.00
5343	2480	Tabla	1	20.00
5501	2550	Tabla	1	20.00
5588	2592	Tabla	1	10.00
5604	2602	Tabla	1	20.00
5752	2668	Tabla	1	15.00
5961	2751	Tabla	1	15.00
6039	2787	Tabla	1	20.00
6062	2798	Tabla	1	20.00
6122	2827	Tabla	1	35.00
6428	2973	Tabla	1	20.00
6457	2988	Tabla	1	10.00
6670	3094	Tabla	1	10.00
1268	592	Tabla	1	13.00
6487	3002	Tabla	1	13.00
112	64	Pincel P.fino	2	8.00
267	138	Pincel P.fino	1	12.00
295	155	Pincel P.fino	1	10.00
911	424	Pincel P.fino	1	12.00
1567	718	Pincel P.fino	1	12.00
2064	927	Pincel P.fino	1	10.00
2065	927	Pincel P.fino	1	14.00
2214	984	Pincel P.fino	1	14.00
2271	1011	Pincel P.fino	1	10.00
2272	1011	Pincel P.fino	1	9.00
2571	1147	Pincel P.fino	1	10.00
2572	1147	Pincel P.fino	1	9.00
3236	1463	Pincel P.fino	1	8.00
3257	1471	Pincel P.fino	1	8.00
3294	1486	Pincel P.fino	1	8.00
3341	1505	Pincel P.fino	1	14.00
3388	1527	Pincel P.fino	1	10.00
3491	1576	Pincel P.fino	1	8.00
3599	1619	Pincel P.fino	1	9.00
3772	1702	Pincel P.fino	1	9.00
5223	2422	Pincel P.fino	1	12.00
5226	2422	Pincel P.fino	2	8.00
6414	2968	Pincel P.fino	2	12.00
6601	3054	Pincel P.fino	1	9.00
7164	3306	Pincel P.fino	1	8.00
7241	3349	Pincel P.fino	1	14.00
7248	3354	Pincel P.fino	1	9.00
7249	3354	Pincel P.fino	1	8.00
392	208	Pincel P.cuadrada	2	8.00
1114	521	Pincel P.cuadrada	1	10.00
1517	695	Pincel P.cuadrada	1	10.00
1795	816	Pincel P.cuadrada	1	10.00
1903	851	Pincel P.cuadrada	1	10.00
1912	853	Pincel P.cuadrada	2	9.00
2002	899	Pincel P.cuadrada	1	10.00
2573	1147	Pincel P.cuadrada	1	14.00
2736	1226	Pincel P.cuadrada	1	8.00
3490	1576	Pincel P.cuadrada	1	8.00
3577	1610	Pincel P.cuadrada	2	10.00
3902	1764	Pincel P.cuadrada	1	14.00
4066	1834	Pincel P.cuadrada	15	6.00
4807	2231	Pincel P.cuadrada	1	8.00
4808	2231	Pincel P.cuadrada	1	8.00
4815	2234	Pincel P.cuadrada	1	14.00
4862	2249	Pincel P.cuadrada	3	14.00
4868	2253	Pincel P.cuadrada	1	14.00
4955	2292	Pincel P.cuadrada	1	9.00
4956	2292	Pincel P.cuadrada	1	14.00
5002	2315	Pincel P.cuadrada	2	10.00
5068	2351	Pincel P.cuadrada	1	10.00
5127	2378	Pincel P.cuadrada	1	14.00
5224	2422	Pincel P.cuadrada	1	14.00
5518	2555	Pincel P.cuadrada	1	8.00
6066	2801	Pincel P.cuadrada	1	8.00
6473	2997	Pincel P.cuadrada	1	14.00
6761	3136	Pincel P.cuadrada	1	8.00
6762	3136	Pincel P.cuadrada	1	10.00
7242	3349	Pincel P.cuadrada	1	14.00
1132	534	Brocha	1	20.00
1897	850	Brocha	1	20.00
2705	1211	Brocha	1	20.00
2959	1344	Brocha	1	20.00
5230	2424	Brocha	1	20.00
6505	3010	Brocha	1	25.00
7290	3373	Brocha	1	25.00
213	108	Brocha	1	30.00
1896	850	Brocha	1	30.00
4957	2292	Brocha	1	30.00
393	208	Pincel	1	15.00
981	463	Pincel	1	15.00
1133	534	Pincel	1	15.00
1182	561	Pincel	1	15.00
1327	618	Pincel	1	15.00
1976	885	Pincel	1	15.00
2215	984	Pincel	1	15.00
2934	1330	Pincel	1	15.00
3167	1437	Pincel	1	15.00
3340	1505	Pincel	1	15.00
3456	1561	Pincel	1	15.00
3509	1584	Pincel	1	15.00
4144	1877	Pincel	1	15.00
4204	1907	Pincel	1	15.00
4386	2011	Pincel	1	15.00
4780	2218	Pincel	1	15.00
4863	2249	Pincel	1	15.00
5281	2450	Pincel	1	15.00
5355	2483	Pincel	2	15.00
5368	2490	Pincel	1	15.00
5506	2550	Pincel	1	15.00
5843	2704	Pincel	2	15.00
5895	2719	Pincel	1	15.00
6045	2788	Pincel	1	15.00
6682	3099	Pincel	2	15.00
6772	3142	Pincel	2	15.00
7008	3238	Pincel	1	15.00
615	306	Gis	1	20.00
7187	3318	Gis	2	20.00
405	213	Plastilina Barra	1	17.00
899	420	Plastilina Barra	1	17.00
900	421	Plastilina Barra	1	17.00
1217	575	Plastilina Barra	1	17.00
1218	575	Plastilina Barra	1	17.00
1300	603	Plastilina Barra	1	17.00
1602	732	Plastilina Barra	1	17.00
1725	782	Plastilina Barra	1	17.00
1970	883	Plastilina Barra	1	17.00
1972	883	Plastilina Barra	1	17.00
2626	1173	Plastilina Barra	2	15.00
2940	1333	Plastilina Barra	1	17.00
2941	1333	Plastilina Barra	1	17.00
3250	1470	Plastilina Barra	1	17.00
3374	1522	Plastilina Barra	1	17.00
3505	1582	Plastilina Barra	3	17.00
3521	1585	Plastilina Barra	1	17.00
3522	1585	Plastilina Barra	1	17.00
4655	2149	Plastilina Barra	1	17.00
5009	2319	Plastilina Barra	1	15.00
5052	2344	Plastilina Barra	2	17.00
5195	2410	Plastilina Barra	1	17.00
5196	2410	Plastilina Barra	1	17.00
5339	2478	Plastilina Barra	1	17.00
5340	2478	Plastilina Barra	1	17.00
5341	2478	Plastilina Barra	1	17.00
5344	2480	Plastilina Barra	1	17.00
5345	2480	Plastilina Barra	1	17.00
5346	2480	Plastilina Barra	1	17.00
5403	2506	Plastilina Barra	1	17.00
5404	2506	Plastilina Barra	1	15.00
5405	2506	Plastilina Barra	1	17.00
5459	2527	Plastilina Barra	1	17.00
5502	2550	Plastilina Barra	1	17.00
5503	2550	Plastilina Barra	1	17.00
5525	2561	Plastilina Barra	1	17.00
5526	2561	Plastilina Barra	1	17.00
5527	2561	Plastilina Barra	1	17.00
5566	2581	Plastilina Barra	2	17.00
5567	2581	Plastilina Barra	1	17.00
5755	2668	Plastilina Barra	1	17.00
5892	2717	Plastilina Barra	1	17.00
5907	2724	Plastilina Barra	1	17.00
5908	2724	Plastilina Barra	1	17.00
5984	2763	Plastilina Barra	1	17.00
6027	2784	Plastilina Barra	1	17.00
6028	2784	Plastilina Barra	1	17.00
6282	2907	Plastilina Barra	1	17.00
6283	2907	Plastilina Barra	1	17.00
6284	2907	Plastilina Barra	1	17.00
6435	2977	Plastilina Barra	1	17.00
6594	3053	Plastilina Barra	1	17.00
6668	3093	Plastilina Barra	1	17.00
6874	3182	Plastilina Barra	3	17.00
7086	3276	Plastilina Barra	1	17.00
7184	3317	Plastilina Barra	2	17.00
7202	3326	Plastilina Barra	1	17.00
77	50	Plastilina Caja	1	27.00
406	213	Plastilina Caja	1	27.00
1212	573	Plastilina Caja	1	29.00
1267	592	Plastilina Caja	1	27.00
1971	883	Plastilina Caja	1	27.00
2186	978	Plastilina Caja	1	29.00
2621	1169	Plastilina Caja	2	27.00
2672	1196	Plastilina Caja	1	29.00
2697	1209	Plastilina Caja	1	27.00
2954	1341	Plastilina Caja	2	27.00
3787	1709	Plastilina Caja	1	27.00
4974	2301	Plastilina Caja	1	27.00
5044	2340	Plastilina Caja	1	27.00
5045	2340	Plastilina Caja	1	29.00
5293	2455	Plastilina Caja	1	27.00
5306	2461	Plastilina Caja	1	30.00
5452	2525	Plastilina Caja	1	27.00
5753	2668	Plastilina Caja	1	30.00
5985	2763	Plastilina Caja	1	27.00
6546	3029	Plastilina Caja	1	27.00
6940	3210	Plastilina Caja	1	30.00
281	146	Cojin Sello	1	65.00
1753	794	Cojin Sello	1	75.00
4806	2230	Cojin Sello	1	65.00
106	62	Pintura Politec 20 Ml.	1	16.00
107	62	Pintura Politec 20 Ml.	1	16.00
108	62	Pintura Politec 20 Ml.	1	16.00
113	64	Pintura Politec 20 Ml.	1	16.00
128	69	Pintura Politec 20 Ml.	1	30.00
205	108	Pintura Politec 20 Ml.	1	16.00
206	108	Pintura Politec 20 Ml.	1	16.00
207	108	Pintura Politec 20 Ml.	1	16.00
208	108	Pintura Politec 20 Ml.	1	16.00
230	118	Pintura Politec 20 Ml.	1	16.00
290	150	Pintura Politec 20 Ml.	1	16.00
439	227	Pintura Politec 20 Ml.	1	16.00
440	227	Pintura Politec 20 Ml.	1	16.00
441	227	Pintura Politec 20 Ml.	1	16.00
442	227	Pintura Politec 20 Ml.	1	16.00
443	227	Pintura Politec 20 Ml.	1	16.00
448	231	Pintura Politec 20 Ml.	1	16.00
528	269	Pintura Politec 20 Ml.	1	16.00
609	304	Pintura Politec 20 Ml.	1	16.00
610	304	Pintura Politec 20 Ml.	1	16.00
611	304	Pintura Politec 20 Ml.	1	16.00
612	304	Pintura Politec 20 Ml.	1	16.00
856	399	Pintura Politec 20 Ml.	1	16.00
857	399	Pintura Politec 20 Ml.	1	16.00
962	454	Pintura Politec 20 Ml.	1	16.00
1074	502	Pintura Politec 20 Ml.	1	16.00
1278	594	Pintura Politec 20 Ml.	1	16.00
1331	621	Pintura Politec 20 Ml.	1	16.00
1332	621	Pintura Politec 20 Ml.	1	16.00
1333	621	Pintura Politec 20 Ml.	1	16.00
1334	622	Pintura Politec 20 Ml.	1	16.00
1335	622	Pintura Politec 20 Ml.	1	16.00
1336	622	Pintura Politec 20 Ml.	1	16.00
1337	622	Pintura Politec 20 Ml.	1	16.00
1338	622	Pintura Politec 20 Ml.	1	16.00
1515	695	Pintura Politec 20 Ml.	1	16.00
1516	695	Pintura Politec 20 Ml.	1	16.00
1568	718	Pintura Politec 20 Ml.	1	16.00
1797	816	Pintura Politec 20 Ml.	1	16.00
1798	816	Pintura Politec 20 Ml.	1	16.00
1855	833	Pintura Politec 20 Ml.	1	16.00
1856	833	Pintura Politec 20 Ml.	1	16.00
1874	836	Pintura Politec 20 Ml.	1	16.00
1875	836	Pintura Politec 20 Ml.	1	16.00
1885	842	Pintura Politec 20 Ml.	4	20.00
1904	851	Pintura Politec 20 Ml.	1	16.00
1910	853	Pintura Politec 20 Ml.	1	16.00
1911	853	Pintura Politec 20 Ml.	1	16.00
1919	856	Pintura Politec 20 Ml.	2	16.00
1975	885	Pintura Politec 20 Ml.	1	16.00
1984	890	Pintura Politec 20 Ml.	1	16.00
1985	890	Pintura Politec 20 Ml.	1	16.00
1986	890	Pintura Politec 20 Ml.	1	16.00
2109	948	Pintura Politec 20 Ml.	2	16.00
2110	949	Pintura Politec 20 Ml.	1	16.00
2111	949	Pintura Politec 20 Ml.	1	16.00
2177	975	Pintura Politec 20 Ml.	1	16.00
2183	977	Pintura Politec 20 Ml.	1	16.00
2209	984	Pintura Politec 20 Ml.	1	16.00
2210	984	Pintura Politec 20 Ml.	1	16.00
2211	984	Pintura Politec 20 Ml.	1	16.00
2212	984	Pintura Politec 20 Ml.	1	16.00
2213	984	Pintura Politec 20 Ml.	1	16.00
2528	1134	Pintura Politec 20 Ml.	1	16.00
2529	1134	Pintura Politec 20 Ml.	2	16.00
2566	1147	Pintura Politec 20 Ml.	2	16.00
2567	1147	Pintura Politec 20 Ml.	1	16.00
2568	1147	Pintura Politec 20 Ml.	1	16.00
2569	1147	Pintura Politec 20 Ml.	1	16.00
2570	1147	Pintura Politec 20 Ml.	1	16.00
2644	1182	Pintura Politec 20 Ml.	1	16.00
2645	1182	Pintura Politec 20 Ml.	1	16.00
2652	1187	Pintura Politec 20 Ml.	1	16.00
2653	1187	Pintura Politec 20 Ml.	1	16.00
2704	1211	Pintura Politec 20 Ml.	1	16.00
2912	1320	Pintura Politec 20 Ml.	1	16.00
2933	1330	Pintura Politec 20 Ml.	1	16.00
2939	1333	Pintura Politec 20 Ml.	1	16.00
3006	1359	Pintura Politec 20 Ml.	1	16.00
3007	1359	Pintura Politec 20 Ml.	1	16.00
3170	1437	Pintura Politec 20 Ml.	1	16.00
3171	1437	Pintura Politec 20 Ml.	1	16.00
3227	1461	Pintura Politec 20 Ml.	1	16.00
3237	1463	Pintura Politec 20 Ml.	1	16.00
3255	1471	Pintura Politec 20 Ml.	1	16.00
3256	1471	Pintura Politec 20 Ml.	1	16.00
3295	1486	Pintura Politec 20 Ml.	1	16.00
3296	1486	Pintura Politec 20 Ml.	1	16.00
3297	1486	Pintura Politec 20 Ml.	1	16.00
3298	1486	Pintura Politec 20 Ml.	1	16.00
3375	1522	Pintura Politec 20 Ml.	1	16.00
3376	1522	Pintura Politec 20 Ml.	1	16.00
3387	1527	Pintura Politec 20 Ml.	1	16.00
3500	1581	Pintura Politec 20 Ml.	1	16.00
3501	1581	Pintura Politec 20 Ml.	1	16.00
3531	1592	Pintura Politec 20 Ml.	1	16.00
3532	1592	Pintura Politec 20 Ml.	1	16.00
3625	1629	Pintura Politec 20 Ml.	1	16.00
3626	1629	Pintura Politec 20 Ml.	1	16.00
3627	1629	Pintura Politec 20 Ml.	1	30.00
3702	1665	Pintura Politec 20 Ml.	1	16.00
3706	1667	Pintura Politec 20 Ml.	2	16.00
3771	1702	Pintura Politec 20 Ml.	1	16.00
3947	1784	Pintura Politec 20 Ml.	1	16.00
4203	1907	Pintura Politec 20 Ml.	1	16.00
4205	1908	Pintura Politec 20 Ml.	1	16.00
4252	1936	Pintura Politec 20 Ml.	1	16.00
4513	2073	Pintura Politec 20 Ml.	1	16.00
4588	2115	Pintura Politec 20 Ml.	1	16.00
4589	2115	Pintura Politec 20 Ml.	1	16.00
4590	2115	Pintura Politec 20 Ml.	1	16.00
4591	2115	Pintura Politec 20 Ml.	1	16.00
4936	2284	Pintura Politec 20 Ml.	1	16.00
4948	2288	Pintura Politec 20 Ml.	1	16.00
4998	2313	Pintura Politec 20 Ml.	1	16.00
5070	2351	Pintura Politec 20 Ml.	1	16.00
5071	2351	Pintura Politec 20 Ml.	1	16.00
5072	2351	Pintura Politec 20 Ml.	1	16.00
5075	2351	Pintura Politec 20 Ml.	1	16.00
5097	2362	Pintura Politec 20 Ml.	1	16.00
5102	2366	Pintura Politec 20 Ml.	2	16.00
5116	2372	Pintura Politec 20 Ml.	1	16.00
5130	2378	Pintura Politec 20 Ml.	1	30.00
5157	2392	Pintura Politec 20 Ml.	1	16.00
5212	2418	Pintura Politec 20 Ml.	1	16.00
5220	2422	Pintura Politec 20 Ml.	1	16.00
5221	2422	Pintura Politec 20 Ml.	1	16.00
5222	2422	Pintura Politec 20 Ml.	1	16.00
5250	2433	Pintura Politec 20 Ml.	1	16.00
5279	2450	Pintura Politec 20 Ml.	1	16.00
5280	2450	Pintura Politec 20 Ml.	1	16.00
5309	2462	Pintura Politec 20 Ml.	1	16.00
5356	2483	Pintura Politec 20 Ml.	1	16.00
5357	2483	Pintura Politec 20 Ml.	1	16.00
5398	2506	Pintura Politec 20 Ml.	1	17.00
5399	2506	Pintura Politec 20 Ml.	1	17.00
5400	2506	Pintura Politec 20 Ml.	1	17.00
5401	2506	Pintura Politec 20 Ml.	1	17.00
5446	2523	Pintura Politec 20 Ml.	1	17.00
5447	2523	Pintura Politec 20 Ml.	1	17.00
5517	2555	Pintura Politec 20 Ml.	1	17.00
5548	2569	Pintura Politec 20 Ml.	1	17.00
5683	2633	Pintura Politec 20 Ml.	1	17.00
5684	2633	Pintura Politec 20 Ml.	1	17.00
5685	2633	Pintura Politec 20 Ml.	1	17.00
5686	2633	Pintura Politec 20 Ml.	1	17.00
5701	2640	Pintura Politec 20 Ml.	1	17.00
5703	2640	Pintura Politec 20 Ml.	1	17.00
5847	2704	Pintura Politec 20 Ml.	1	17.00
5848	2704	Pintura Politec 20 Ml.	1	17.00
5849	2704	Pintura Politec 20 Ml.	1	17.00
5882	2714	Pintura Politec 20 Ml.	1	17.00
5982	2762	Pintura Politec 20 Ml.	1	17.00
6040	2788	Pintura Politec 20 Ml.	1	17.00
6067	2801	Pintura Politec 20 Ml.	1	17.00
6143	2834	Pintura Politec 20 Ml.	1	17.00
6144	2834	Pintura Politec 20 Ml.	1	17.00
6343	2933	Pintura Politec 20 Ml.	1	17.00
6344	2933	Pintura Politec 20 Ml.	1	17.00
6416	2968	Pintura Politec 20 Ml.	1	17.00
6470	2997	Pintura Politec 20 Ml.	1	17.00
6471	2997	Pintura Politec 20 Ml.	1	17.00
6488	3002	Pintura Politec 20 Ml.	1	17.00
6506	3010	Pintura Politec 20 Ml.	1	17.00
6519	3018	Pintura Politec 20 Ml.	1	17.00
6568	3039	Pintura Politec 20 Ml.	1	17.00
6596	3054	Pintura Politec 20 Ml.	1	17.00
6597	3054	Pintura Politec 20 Ml.	1	17.00
6598	3054	Pintura Politec 20 Ml.	1	17.00
6599	3054	Pintura Politec 20 Ml.	1	17.00
6677	3099	Pintura Politec 20 Ml.	1	17.00
6678	3099	Pintura Politec 20 Ml.	1	17.00
6680	3099	Pintura Politec 20 Ml.	1	17.00
6681	3099	Pintura Politec 20 Ml.	1	17.00
6773	3142	Pintura Politec 20 Ml.	1	17.00
6774	3142	Pintura Politec 20 Ml.	1	17.00
6775	3142	Pintura Politec 20 Ml.	1	17.00
6776	3142	Pintura Politec 20 Ml.	1	17.00
6777	3142	Pintura Politec 20 Ml.	1	17.00
7009	3238	Pintura Politec 20 Ml.	1	17.00
7010	3238	Pintura Politec 20 Ml.	1	17.00
7045	3256	Pintura Politec 20 Ml.	1	17.00
7069	3269	Pintura Politec 20 Ml.	1	30.00
7088	3276	Pintura Politec 20 Ml.	1	17.00
7163	3306	Pintura Politec 20 Ml.	1	17.00
7167	3308	Pintura Politec 20 Ml.	1	17.00
7251	3354	Pintura Politec 20 Ml.	1	17.00
7252	3354	Pintura Politec 20 Ml.	1	17.00
7253	3354	Pintura Politec 20 Ml.	2	17.00
7274	3365	Pintura Politec 20 Ml.	1	17.00
7275	3366	Pintura Politec 20 Ml.	1	30.00
1566	718	Pintura Baco	1	10.00
430	223	Mica	1	10.00
5194	2410	Pasta Moldeable	1	100.00
521	265	Crayones	1	35.00
1726	783	Crayones	1	75.00
4738	2197	Crayones	1	25.00
5766	2676	Crayones	1	75.00
6124	2827	Crayones	1	25.00
7240	3349	Crayones	1	50.00
1955	877	Compas	1	35.00
3950	1785	Compas	1	40.00
4472	2048	Compas	1	35.00
4521	2077	Compas	1	40.00
4542	2087	Compas	1	40.00
7331	3390	Compas	1	35.00
4450	2037	Marcador	1	80.00
7238	3348	Marcador	1	80.00
380	201	Kola Loca	1	20.00
4679	2165	Kola Loca	1	20.00
651	316	Grapas # 26	1	15.00
1029	486	Grapas # 26	1	15.00
6490	3002	Grapas # 26	1	15.00
6641	3079	Grapas # 26	2	15.00
289	149	Grapa # 10	1	15.00
2090	938	Grapa # 10	1	15.00
7087	3276	Grapa # 10	1	15.00
2373	1048	Grapa # 26	1	35.00
3117	1413	Grapa # 26	1	35.00
3219	1455	Grapa # 26	1	35.00
3343	1506	Grapa # 26	1	35.00
4846	2242	Grapa # 26	1	35.00
5260	2438	Grapa # 26	1	35.00
5917	2730	Grapa # 26	1	35.00
7029	3245	Grapa # 26	2	35.00
7071	3269	Grapa # 26	1	35.00
360	190	Puntilla	1	15.00
3623	1629	Puntilla	1	15.00
4063	1831	Puntilla	1	15.00
5578	2587	Puntilla	1	15.00
6306	2915	Puntilla	1	15.00
298	156	Navaja Cutter	1	22.00
1097	511	Navaja Cutter	2	33.00
1398	643	Navaja Cutter	1	33.00
1421	652	Navaja Cutter	1	33.00
1629	743	Navaja Cutter	1	22.00
891	417	Broche	2	6.00
1399	644	Broche	1	6.00
3054	1387	Broche	2	6.00
4997	2312	Broche	1	6.00
6580	3046	Broche	1	6.00
125	69	Cordon P/Gafet	1	20.00
1189	563	Cordon P/Gafet	1	20.00
185	97	Papel Lustre	4	7.00
201	106	Papel Lustre	1	7.00
1043	492	Papel Lustre	2	7.00
1233	580	Papel Lustre	2	7.00
1247	586	Papel Lustre	1	7.00
1248	586	Papel Lustre	1	7.00
1663	761	Papel Lustre	1	7.00
2665	1192	Papel Lustre	1	7.00
2703	1211	Papel Lustre	4	7.00
3267	1472	Papel Lustre	3	7.00
3268	1472	Papel Lustre	3	7.00
3619	1629	Papel Lustre	3	7.00
3938	1781	Papel Lustre	1	7.00
3939	1781	Papel Lustre	1	7.00
4053	1827	Papel Lustre	2	7.00
4197	1904	Papel Lustre	4	7.00
4329	1984	Papel Lustre	1	7.00
4330	1984	Papel Lustre	1	7.00
4907	2271	Papel Lustre	1	7.00
4927	2280	Papel Lustre	2	7.00
4928	2280	Papel Lustre	1	7.00
5138	2383	Papel Lustre	3	7.00
5201	2413	Papel Lustre	1	7.00
5209	2416	Papel Lustre	1	7.00
5733	2654	Papel Lustre	1	7.00
5888	2717	Papel Lustre	1	7.00
5889	2717	Papel Lustre	1	7.00
5933	2738	Papel Lustre	1	7.00
5962	2751	Papel Lustre	1	7.00
5963	2751	Papel Lustre	1	7.00
5979	2760	Papel Lustre	1	7.00
6128	2828	Papel Lustre	1	7.00
6129	2828	Papel Lustre	1	7.00
6213	2873	Papel Lustre	7	7.00
6531	3023	Papel Lustre	3	7.00
7328	3390	Papel Lustre	1	7.00
70	46	Plastico Vinil	2	25.00
191	101	Plastico Vinil	3	25.00
1158	550	Plastico Vinil	1	25.00
1171	559	Plastico Vinil	1	25.00
1297	603	Plastico Vinil	1	25.00
1524	699	Plastico Vinil	1	15.00
1625	740	Plastico Vinil	1	25.00
64	42	Mapa	1	3.00
248	128	Mapa	1	3.00
462	237	Mapa	1	3.00
909	423	Mapa	3	3.00
1161	551	Mapa	6	3.00
1463	675	Mapa	2	3.00
1564	717	Mapa	2	3.00
1595	728	Mapa	2	3.00
1641	749	Mapa	1	3.00
1824	824	Mapa	4	3.00
2723	1219	Mapa	1	3.00
2884	1306	Mapa	1	3.00
3084	1403	Mapa	2	3.00
3112	1411	Mapa	2	3.00
3179	1439	Mapa	2	3.00
3348	1509	Mapa	1	3.00
4523	2078	Mapa	1	3.00
4572	2105	Mapa	1	3.00
5089	2358	Mapa	2	3.00
5117	2373	Mapa	1	3.00
5331	2474	Mapa	1	3.00
5940	2740	Mapa	1	3.00
6436	2977	Mapa	2	3.00
6697	3105	Mapa	1	3.00
7050	3261	Mapa	2	3.00
7066	3269	Mapa	9	3.00
97	57	Lamina	1	5.00
131	70	Lamina	2	5.00
799	373	Lamina	3	5.00
805	377	Lamina	1	5.00
908	423	Lamina	1	5.00
998	470	Lamina	2	5.00
1147	543	Lamina	1	5.00
1150	544	Lamina	1	5.00
1201	566	Lamina	1	5.00
1280	594	Lamina	1	5.00
1395	641	Lamina	1	5.00
1467	677	Lamina	1	5.00
1550	710	Lamina	3	5.00
1596	728	Lamina	1	5.00
1601	731	Lamina	1	5.00
1770	801	Lamina	2	5.00
1893	847	Lamina	1	5.00
2063	926	Lamina	1	5.00
2069	928	Lamina	1	5.00
2163	970	Lamina	1	5.00
2302	1023	Lamina	3	5.00
2338	1035	Lamina	1	5.00
2374	1049	Lamina	2	5.00
2638	1180	Lamina	1	5.00
2648	1184	Lamina	2	5.00
2691	1204	Lamina	1	5.00
2753	1232	Lamina	1	5.00
2883	1306	Lamina	1	5.00
3046	1382	Lamina	2	5.00
3289	1483	Lamina	2	5.00
4656	2150	Lamina	3	5.00
4668	2159	Lamina	1	5.00
4750	2205	Lamina	1	5.00
4783	2221	Lamina	1	5.00
5041	2339	Lamina	3	5.00
5054	2345	Lamina	1	5.00
5146	2387	Lamina	1	5.00
5555	2574	Lamina	2	5.00
5606	2603	Lamina	3	5.00
5991	2765	Lamina	1	5.00
6458	2989	Lamina	2	5.00
6631	3074	Lamina	1	5.00
6810	3153	Lamina	2	5.00
6870	3179	Lamina	1	5.00
6910	3198	Lamina	2	5.00
7031	3246	Lamina	1	5.00
7330	3390	Lamina	3	5.00
693	334	Colores	1	100.00
1585	723	Colores	1	40.00
1799	817	Colores	1	50.00
2264	1006	Colores	1	45.00
3668	1651	Colores	1	115.00
3925	1775	Colores	1	40.00
4498	2064	Colores	1	115.00
4830	2237	Colores	1	50.00
5007	2318	Colores	1	45.00
5450	2524	Colores	1	115.00
5974	2757	Colores	1	115.00
6239	2882	Colores	1	40.00
6403	2966	Colores	2	45.00
6582	3047	Colores	1	100.00
6583	3047	Colores	1	165.00
7027	3244	Colores	1	40.00
7258	3358	Colores	1	40.00
910	424	Acuarela	1	30.00
2273	1011	Acuarela	1	40.00
4505	2069	Acuarela	1	40.00
4540	2087	Acuarela	1	40.00
4958	2292	Acuarela	1	30.00
6480	3000	Acuarela	1	30.00
6520	3019	Acuarela	1	30.00
6534	3025	Acuarela	1	40.00
6760	3136	Acuarela	1	40.00
1422	653	Cinta Metrica	1	10.00
5316	2467	Cinta Metrica	1	10.00
2675	1198	Broche Baco	1	2.50
3028	1369	Broche Baco	1	2.50
4816	2235	Broche Baco	1	2.50
1806	818	Aguja Estambrera	1	5.00
3480	1568	Aguja Estambrera	2	5.00
4657	2151	Aguja Estambrera	1	5.00
5603	2601	Aguja Estambrera	1	5.00
6219	2875	Aguja Estambrera	2	5.00
6602	3054	Aguja Estambrera	1	3.50
451	231	Seguro	6	0.50
2444	1074	Seguro	10	1.00
2445	1074	Seguro	5	3.00
2446	1074	Seguro	10	1.50
3220	1456	Seguro	2	0.50
3221	1456	Seguro	4	1.00
3386	1527	Seguro	15	2.00
3743	1684	Seguro	2	4.00
4034	1816	Seguro	3	2.00
4035	1816	Seguro	10	1.50
4978	2303	Seguro	1	1.00
6025	2783	Seguro	2	1.50
6675	3097	Seguro	20	1.50
6485	3002	Iman Plastico	1	2.00
6486	3002	Iman Plastico	2	3.00
6652	3084	Iman Plastico	2	2.00
6517	3017	Iman Redondo	1	8.00
1024	484	Hilo Elastico	1	29.00
2089	937	Hilo Elastico	5	3.00
2130	959	Hilo Elastico	1	3.00
3682	1655	Hilo Elastico	1	3.00
4324	1981	Hilo Elastico	1	3.00
6297	2912	Hilo Elastico	1	29.00
471	242	Broche Aleman	5	1.00
472	243	Broche Aleman	3	1.00
1093	507	Broche Aleman	1	1.50
2148	963	Broche Aleman	10	1.50
2292	1021	Broche Aleman	10	1.50
2354	1038	Broche Aleman	10	1.50
5277	2450	Broche Aleman	4	1.50
5334	2477	Broche Aleman	17	1.50
6029	2785	Broche Aleman	3	1.50
6374	2950	Broche Aleman	5	1.00
6882	3186	Broche Aleman	3	1.00
71	47	Ojo Movible	10	1.50
861	401	Ojo Movible	1	2.50
1732	785	Ojo Movible	2	2.00
1805	818	Ojo Movible	1	2.00
2881	1305	Ojo Movible	2	5.50
3373	1522	Ojo Movible	2	1.50
3515	1585	Ojo Movible	1	5.50
4025	1812	Ojo Movible	1	2.50
5475	2536	Ojo Movible	3	2.00
5751	2667	Ojo Movible	1	4.00
5866	2709	Ojo Movible	2	4.00
5876	2712	Ojo Movible	8	1.50
6033	2786	Ojo Movible	1	2.50
6196	2865	Ojo Movible	1	1.50
6231	2880	Ojo Movible	5	2.00
6232	2880	Ojo Movible	5	1.50
6286	2907	Ojo Movible	1	2.00
6287	2907	Ojo Movible	1	2.50
6288	2907	Ojo Movible	1	4.00
6289	2907	Ojo Movible	1	1.00
6327	2927	Ojo Movible	6	1.50
6852	3169	Ojo Movible	1	2.50
6853	3169	Ojo Movible	1	1.50
74	48	Postit	1	20.00
164	89	Postit	1	25.00
272	142	Postit	1	25.00
2453	1078	Postit	1	25.00
3498	1580	Postit	1	35.00
3695	1660	Postit	1	25.00
4669	2159	Postit	1	20.00
4752	2206	Postit	1	20.00
4753	2206	Postit	1	25.00
4754	2206	Postit	1	35.00
4870	2254	Postit	1	20.00
4972	2300	Postit	1	25.00
6657	3087	Postit	1	35.00
6743	3126	Postit	1	25.00
6809	3152	Postit	1	20.00
6833	3164	Postit	1	35.00
7178	3314	Postit	1	20.00
7335	3392	Postit	2	25.00
98	58	Sticker	1	13.00
200	106	Sticker	1	14.00
339	180	Sticker	1	13.00
369	197	Sticker	1	14.00
370	197	Sticker	1	13.00
999	470	Sticker	1	15.00
1045	492	Sticker	1	12.00
1046	492	Sticker	1	14.00
1249	586	Sticker	1	13.00
1264	591	Sticker	1	12.00
1265	591	Sticker	1	13.00
1315	614	Sticker	1	15.00
1316	614	Sticker	1	12.00
1355	625	Sticker	1	12.00
1427	656	Sticker	4	15.00
1428	656	Sticker	1	13.00
1429	656	Sticker	1	12.00
1430	656	Sticker	1	10.00
1560	716	Sticker	1	14.00
1762	798	Sticker	1	13.00
2061	925	Sticker	1	15.00
2267	1008	Sticker	1	15.00
2385	1052	Sticker	2	14.00
2658	1190	Sticker	2	13.00
2660	1190	Sticker	1	20.00
2869	1299	Sticker	2	15.00
2891	1308	Sticker	1	15.00
3043	1380	Sticker	1	15.00
3415	1541	Sticker	1	20.00
3590	1616	Sticker	1	15.00
4148	1878	Sticker	1	15.00
4281	1955	Sticker	2	15.00
4385	2011	Sticker	1	14.00
4402	2017	Sticker	1	14.00
4403	2017	Sticker	1	15.00
4483	2056	Sticker	3	10.00
5652	2620	Sticker	2	15.00
5658	2622	Sticker	1	14.00
5659	2622	Sticker	1	13.00
5764	2674	Sticker	1	12.00
5915	2729	Sticker	1	15.00
5916	2729	Sticker	1	12.00
5988	2764	Sticker	1	12.00
5989	2764	Sticker	1	15.00
6270	2898	Sticker	2	15.00
6323	2925	Sticker	1	12.00
6326	2926	Sticker	2	13.00
6328	2927	Sticker	1	14.00
6345	2933	Sticker	2	15.00
6576	3043	Sticker	3	15.00
6629	3073	Sticker	1	12.00
6630	3073	Sticker	2	15.00
6739	3125	Sticker	1	15.00
6863	3175	Sticker	1	14.00
7089	3277	Sticker	3	13.00
7090	3277	Sticker	1	14.00
7091	3277	Sticker	1	15.00
7264	3362	Sticker	1	15.00
7265	3362	Sticker	1	12.00
377	200	Silicon Liquido	1	20.00
718	347	Silicon Liquido	1	45.00
860	401	Silicon Liquido	1	20.00
1017	479	Silicon Liquido	1	20.00
1086	506	Silicon Liquido	1	30.00
1184	562	Silicon Liquido	1	30.00
1226	576	Silicon Liquido	1	20.00
1235	581	Silicon Liquido	1	20.00
1322	615	Silicon Liquido	2	20.00
1368	629	Silicon Liquido	1	20.00
2120	956	Silicon Liquido	1	30.00
2160	969	Silicon Liquido	1	45.00
2226	990	Silicon Liquido	1	30.00
2280	1016	Silicon Liquido	1	30.00
2317	1027	Silicon Liquido	1	20.00
2407	1062	Silicon Liquido	1	30.00
2440	1073	Silicon Liquido	1	20.00
2564	1146	Silicon Liquido	1	45.00
3258	1471	Silicon Liquido	1	20.00
3542	1598	Silicon Liquido	1	20.00
3754	1693	Silicon Liquido	1	30.00
3812	1720	Silicon Liquido	1	30.00
3898	1763	Silicon Liquido	1	20.00
4026	1812	Silicon Liquido	1	20.00
4576	2108	Silicon Liquido	1	20.00
5129	2378	Silicon Liquido	1	20.00
5269	2444	Silicon Liquido	1	20.00
5453	2526	Silicon Liquido	1	20.00
5635	2613	Silicon Liquido	1	20.00
5877	2712	Silicon Liquido	1	20.00
5890	2717	Silicon Liquido	1	20.00
6031	2785	Silicon Liquido	1	20.00
6312	2918	Silicon Liquido	1	20.00
6427	2973	Silicon Liquido	1	20.00
6701	3106	Silicon Liquido	1	30.00
6990	3230	Silicon Liquido	1	30.00
221	113	Caja Clip	1	15.00
1339	623	Caja Clip	1	25.00
3942	1782	Caja Clip	1	15.00
4013	1807	Caja Clip	1	15.00
4980	2304	Caja Clip	1	15.00
5690	2636	Caja Clip	1	15.00
5967	2753	Caja Clip	1	25.00
6518	3017	Caja Clip	1	15.00
6530	3023	Caja Clip	1	25.00
6748	3128	Caja Clip	1	25.00
7320	3387	Caja Clip	1	17.00
892	418	Pistola de Silicon	1	85.00
1100	514	Pistola de Silicon	1	85.00
1788	812	Pistola de Silicon	1	85.00
1865	836	Pistola de Silicon	1	85.00
6351	2936	Pistola de Silicon	1	85.00
1895	849	Cascabel	6	3.50
3773	1702	Cascabel	6	3.50
3933	1778	Cascabel	4	2.50
4322	1981	Cascabel	10	2.00
78	51	Cartulina	1	15.00
219	111	Cartulina	1	15.00
455	234	Cartulina	1	15.00
457	235	Cartulina	1	15.00
896	420	Cartulina	1	15.00
975	460	Cartulina	1	7.00
977	462	Cartulina	2	7.00
992	467	Cartulina	1	7.00
1016	478	Cartulina	1	7.00
1019	480	Cartulina	1	7.00
1022	483	Cartulina	1	7.00
1032	488	Cartulina	1	7.00
1095	509	Cartulina	1	7.00
1099	513	Cartulina	2	7.00
1107	518	Cartulina	1	7.00
1111	521	Cartulina	2	7.00
1138	537	Cartulina	1	15.00
1157	550	Cartulina	1	7.00
1191	564	Cartulina	1	7.00
1200	566	Cartulina	1	7.00
1241	584	Cartulina	1	7.00
1251	587	Cartulina	1	7.00
1279	594	Cartulina	1	7.00
1295	602	Cartulina	1	7.00
1443	666	Cartulina	1	7.00
1474	682	Cartulina	2	7.00
1491	686	Cartulina	3	7.00
1505	691	Cartulina	1	7.00
1528	702	Cartulina	1	7.00
1539	706	Cartulina	2	7.00
1553	712	Cartulina	1	7.00
1565	718	Cartulina	1	7.00
1619	739	Cartulina	1	7.00
1684	770	Cartulina	1	7.00
1691	773	Cartulina	1	7.00
1708	778	Cartulina	1	7.00
1737	786	Cartulina	1	7.00
1761	798	Cartulina	1	7.00
1890	845	Cartulina	1	7.00
1918	856	Cartulina	1	7.00
1920	857	Cartulina	4	7.00
1926	861	Cartulina	2	7.00
1940	869	Cartulina	1	7.00
1994	895	Cartulina	1	7.00
2030	910	Cartulina	1	7.00
2052	920	Cartulina	2	7.00
2062	926	Cartulina	1	7.00
2080	933	Cartulina	1	7.00
2105	947	Cartulina	1	7.00
2122	957	Cartulina	1	7.00
2161	970	Cartulina	1	7.00
2306	1024	Cartulina	1	15.00
2307	1025	Cartulina	1	7.00
2308	1025	Cartulina	1	15.00
2330	1032	Cartulina	1	7.00
2366	1046	Cartulina	1	7.00
2383	1052	Cartulina	1	15.00
2438	1072	Cartulina	1	7.00
2454	1079	Cartulina	1	7.00
2556	1143	Cartulina	1	7.00
2634	1178	Cartulina	2	7.00
2639	1181	Cartulina	1	7.00
2684	1202	Cartulina	1	7.00
2692	1205	Cartulina	2	7.00
2763	1237	Cartulina	2	7.00
2786	1250	Cartulina	2	7.00
2790	1252	Cartulina	1	7.00
2832	1277	Cartulina	1	7.00
2877	1304	Cartulina	1	7.00
2889	1308	Cartulina	1	7.00
2935	1330	Cartulina	1	15.00
2962	1347	Cartulina	1	7.00
2982	1352	Cartulina	1	7.00
3021	1368	Cartulina	1	7.00
3122	1416	Cartulina	1	7.00
3136	1422	Cartulina	1	7.00
3147	1427	Cartulina	1	7.00
3153	1431	Cartulina	1	7.00
3164	1436	Cartulina	2	7.00
3181	1440	Cartulina	1	7.00
3216	1454	Cartulina	1	7.00
3369	1520	Cartulina	1	7.00
3370	1521	Cartulina	1	7.00
3536	1594	Cartulina	1	7.00
3543	1598	Cartulina	2	7.00
3558	1605	Cartulina	1	7.00
3669	1651	Cartulina	1	7.00
3699	1663	Cartulina	1	7.00
3700	1664	Cartulina	1	7.00
3740	1682	Cartulina	1	7.00
3777	1704	Cartulina	1	7.00
3806	1717	Cartulina	1	7.00
3829	1728	Cartulina	1	7.00
4449	2037	Cartulina	3	7.00
4460	2042	Cartulina	1	7.00
4494	2062	Cartulina	1	7.00
4496	2063	Cartulina	1	7.00
4558	2098	Cartulina	1	7.00
4573	2105	Cartulina	2	7.00
4621	2131	Cartulina	3	7.00
4632	2139	Cartulina	3	7.00
4689	2170	Cartulina	1	7.00
4699	2176	Cartulina	1	7.00
4730	2191	Cartulina	5	7.00
4731	2192	Cartulina	1	7.00
4788	2225	Cartulina	1	7.00
4824	2236	Cartulina	1	7.00
4873	2256	Cartulina	1	7.00
4885	2261	Cartulina	1	7.00
4899	2267	Cartulina	1	7.00
4904	2270	Cartulina	10	7.00
4926	2279	Cartulina	1	7.00
4932	2281	Cartulina	1	7.00
4947	2288	Cartulina	1	7.00
4959	2293	Cartulina	2	7.00
4999	2313	Cartulina	1	7.00
5033	2333	Cartulina	1	7.00
5048	2342	Cartulina	2	7.00
5090	2358	Cartulina	1	7.00
5106	2368	Cartulina	1	7.00
5112	2371	Cartulina	1	7.00
5115	2372	Cartulina	1	7.00
5122	2376	Cartulina	1	7.00
5158	2392	Cartulina	1	7.00
5169	2397	Cartulina	1	7.00
5210	2416	Cartulina	1	7.00
5272	2447	Cartulina	1	7.00
5312	2464	Cartulina	5	7.00
5317	2468	Cartulina	1	7.00
5320	2469	Cartulina	1	7.00
5335	2478	Cartulina	1	7.00
5354	2483	Cartulina	1	7.00
5358	2484	Cartulina	1	7.00
5419	2513	Cartulina	2	7.00
5432	2517	Cartulina	1	7.00
5435	2518	Cartulina	1	7.00
5462	2530	Cartulina	1	7.00
5469	2535	Cartulina	1	7.00
5480	2540	Cartulina	3	7.00
5558	2577	Cartulina	1	7.00
5559	2578	Cartulina	1	7.00
5560	2578	Cartulina	1	15.00
5565	2580	Cartulina	1	7.00
5574	2584	Cartulina	3	7.00
5597	2597	Cartulina	3	7.00
5605	2603	Cartulina	1	7.00
5619	2608	Cartulina	3	7.00
5677	2631	Cartulina	1	7.00
5865	2709	Cartulina	1	7.00
5918	2731	Cartulina	1	15.00
5941	2741	Cartulina	1	7.00
5978	2760	Cartulina	1	7.00
5987	2763	Cartulina	1	7.00
5996	2769	Cartulina	1	7.00
6000	2771	Cartulina	1	7.00
6102	2817	Cartulina	1	7.00
6106	2820	Cartulina	1	7.00
6126	2828	Cartulina	1	7.00
6147	2835	Cartulina	1	7.00
6190	2864	Cartulina	1	7.00
6201	2867	Cartulina	3	7.00
6206	2870	Cartulina	2	7.00
6256	2891	Cartulina	1	7.00
6262	2894	Cartulina	3	7.00
6285	2907	Cartulina	3	7.00
6303	2915	Cartulina	1	7.00
6360	2942	Cartulina	1	7.00
6444	2981	Cartulina	1	7.00
6449	2984	Cartulina	3	7.00
6461	2991	Cartulina	2	7.00
6510	3014	Cartulina	1	7.00
6525	3021	Cartulina	1	7.00
6569	3040	Cartulina	1	7.00
6605	3056	Cartulina	1	7.00
6618	3065	Cartulina	2	7.00
6661	3089	Cartulina	2	7.00
6663	3090	Cartulina	1	7.00
6690	3103	Cartulina	1	7.00
6696	3105	Cartulina	1	7.00
6723	3119	Cartulina	3	7.00
6799	3148	Cartulina	2	7.00
6804	3150	Cartulina	1	7.00
6856	3170	Cartulina	1	7.00
6861	3174	Cartulina	2	7.00
6881	3185	Cartulina	2	7.00
6886	3189	Cartulina	1	7.00
6890	3191	Cartulina	1	7.00
6935	3208	Cartulina	2	7.00
6943	3212	Cartulina	1	7.00
6979	3227	Cartulina	1	7.00
7030	3246	Cartulina	1	7.00
7049	3260	Cartulina	1	7.00
7067	3269	Cartulina	4	7.00
7092	3278	Cartulina	2	7.00
7095	3279	Cartulina	1	7.00
7151	3300	Cartulina	1	7.00
7156	3303	Cartulina	1	7.00
7166	3308	Cartulina	1	7.00
7206	3329	Cartulina	2	7.00
7221	3337	Cartulina	1	7.00
7283	3369	Cartulina	1	7.00
7289	3373	Cartulina	1	7.00
7367	3407	Cartulina	1	15.00
92	54	Escaneo	6	5.00
652	317	Escaneo	1	5.00
697	337	Escaneo	2	5.00
963	455	Escaneo	2	5.00
1329	620	Escaneo	8	5.00
1831	826	Escaneo	2	5.00
1838	828	Escaneo	1	5.00
2325	1030	Escaneo	2	5.00
3001	1358	Escaneo	2	5.00
3327	1497	Escaneo	2	5.00
3344	1507	Escaneo	2	5.00
4378	2008	Escaneo	2	5.00
4497	2063	Escaneo	4	5.00
4614	2128	Escaneo	3	5.00
4710	2181	Escaneo	1	5.00
4713	2183	Escaneo	1	5.00
4844	2241	Escaneo	2	5.00
6149	2836	Escaneo	8	5.00
6222	2877	Escaneo	5	5.00
6539	3026	Escaneo	2	5.00
6623	3068	Escaneo	1	5.00
7024	3243	Escaneo	3	5.00
7246	3352	Escaneo	9	5.00
7255	3355	Escaneo	1	5.00
100	59	Yute	1	3.00
518	264	Yute	2	3.00
840	394	Yute	2	5.00
1087	506	Yute	2	5.00
1929	862	Yute	1	5.00
2185	977	Yute	3	5.00
2243	996	Yute	2	5.00
2726	1219	Yute	1	3.00
2983	1353	Yute	2	5.00
3004	1359	Yute	1	3.00
3384	1525	Yute	3	3.00
3479	1568	Yute	4	3.00
3886	1759	Yute	5	5.00
6030	2785	Yute	1	3.00
6226	2879	Yute	3	5.00
6607	3057	Yute	2	3.00
6608	3057	Yute	2	5.00
6660	3089	Yute	1	5.00
6953	3216	Yute	6	5.00
6954	3216	Yute	16	3.00
6965	3220	Yute	2	3.00
7272	3364	Yute	2	3.00
368	197	Hoja Calcamonia	1	10.00
676	329	Hoja Calcamonia	2	10.00
935	439	Hoja Calcamonia	1	10.00
1079	504	Hoja Calcamonia	2	10.00
1193	564	Hoja Calcamonia	1	10.00
2827	1273	Hoja Calcamonia	2	10.00
4060	1830	Hoja Calcamonia	1	10.00
4275	1949	Hoja Calcamonia	1	10.00
5852	2705	Hoja Calcamonia	3	10.00
5857	2708	Hoja Calcamonia	2	10.00
6116	2824	Hoja Calcamonia	1	10.00
6320	2924	Hoja Calcamonia	2	10.00
6337	2933	Hoja Calcamonia	4	10.00
743	351	Cubo	1	45.00
833	392	Cubo	1	45.00
980	463	Cubo	1	40.00
2958	1343	Cubo	1	20.00
3204	1449	Cubo	1	40.00
3784	1708	Cubo	1	40.00
4161	1885	Cubo	2	25.00
5835	2702	Cubo	4	25.00
6133	2830	Cubo	1	55.00
537	272	Fomy T/Carta	1	4.50
538	272	Fomy T/Carta	1	4.50
721	347	Fomy T/Carta	1	4.50
859	401	Fomy T/Carta	2	4.50
1127	531	Fomy T/Carta	1	4.50
1187	562	Fomy T/Carta	2	4.50
1222	576	Fomy T/Carta	2	4.50
1223	576	Fomy T/Carta	1	4.50
1224	576	Fomy T/Carta	2	4.50
1225	576	Fomy T/Carta	1	4.50
1276	594	Fomy T/Carta	1	4.50
1277	594	Fomy T/Carta	1	4.50
1346	625	Fomy T/Carta	2	4.50
1347	625	Fomy T/Carta	2	4.50
1348	625	Fomy T/Carta	1	4.50
1349	625	Fomy T/Carta	1	4.50
1350	625	Fomy T/Carta	1	4.50
1351	625	Fomy T/Carta	1	4.50
1352	625	Fomy T/Carta	1	4.50
1353	625	Fomy T/Carta	1	4.50
1354	625	Fomy T/Carta	4	4.50
1692	773	Fomy T/Carta	1	4.50
1877	837	Fomy T/Carta	4	4.50
1878	837	Fomy T/Carta	4	4.50
2005	900	Fomy T/Carta	1	4.50
2006	900	Fomy T/Carta	1	4.50
2007	900	Fomy T/Carta	1	4.50
2008	900	Fomy T/Carta	1	4.50
2093	938	Fomy T/Carta	2	4.50
2125	958	Fomy T/Carta	1	4.50
2126	958	Fomy T/Carta	1	4.50
2127	958	Fomy T/Carta	1	4.50
2154	966	Fomy T/Carta	1	4.50
2155	966	Fomy T/Carta	1	4.50
2156	966	Fomy T/Carta	1	4.50
2157	966	Fomy T/Carta	1	4.50
2194	981	Fomy T/Carta	1	4.50
2195	981	Fomy T/Carta	1	4.50
2227	990	Fomy T/Carta	2	4.50
2228	990	Fomy T/Carta	2	4.50
2229	990	Fomy T/Carta	2	4.50
2309	1026	Fomy T/Carta	1	4.50
2310	1026	Fomy T/Carta	1	4.50
2311	1026	Fomy T/Carta	1	4.50
2312	1026	Fomy T/Carta	1	4.50
2313	1026	Fomy T/Carta	1	4.50
2314	1026	Fomy T/Carta	1	4.50
2331	1032	Fomy T/Carta	1	4.50
2361	1043	Fomy T/Carta	10	4.50
2426	1068	Fomy T/Carta	1	4.50
2457	1082	Fomy T/Carta	2	4.50
2458	1082	Fomy T/Carta	2	4.50
2495	1117	Fomy T/Carta	2	4.50
2496	1117	Fomy T/Carta	1	4.50
2533	1135	Fomy T/Carta	1	4.50
2543	1138	Fomy T/Carta	2	4.50
2544	1138	Fomy T/Carta	2	4.50
2755	1233	Fomy T/Carta	1	4.50
3042	1379	Fomy T/Carta	2	4.50
3172	1437	Fomy T/Carta	1	4.50
3173	1437	Fomy T/Carta	3	4.50
3252	1471	Fomy T/Carta	3	4.50
3305	1491	Fomy T/Carta	1	4.50
3319	1496	Fomy T/Carta	1	4.50
3320	1496	Fomy T/Carta	1	4.50
3321	1496	Fomy T/Carta	1	4.50
3322	1496	Fomy T/Carta	3	4.50
3323	1496	Fomy T/Carta	1	4.50
3329	1498	Fomy T/Carta	2	4.50
3335	1503	Fomy T/Carta	2	4.50
3360	1515	Fomy T/Carta	1	4.50
3504	1581	Fomy T/Carta	1	4.50
3511	1585	Fomy T/Carta	4	4.50
3512	1585	Fomy T/Carta	4	4.50
3513	1585	Fomy T/Carta	1	4.50
3514	1585	Fomy T/Carta	1	4.50
3553	1603	Fomy T/Carta	2	4.50
3554	1603	Fomy T/Carta	1	4.50
3560	1606	Fomy T/Carta	1	4.50
3561	1606	Fomy T/Carta	1	4.50
3562	1606	Fomy T/Carta	1	4.50
3563	1606	Fomy T/Carta	1	4.50
3564	1606	Fomy T/Carta	1	4.50
3566	1607	Fomy T/Carta	2	4.50
3567	1607	Fomy T/Carta	1	4.50
3568	1607	Fomy T/Carta	1	4.50
3570	1609	Fomy T/Carta	1	4.50
3594	1617	Fomy T/Carta	2	4.50
3605	1621	Fomy T/Carta	1	4.50
3609	1623	Fomy T/Carta	2	4.50
3631	1630	Fomy T/Carta	1	4.50
3793	1711	Fomy T/Carta	2	4.50
3794	1711	Fomy T/Carta	2	4.50
3797	1711	Fomy T/Carta	1	4.50
3948	1785	Fomy T/Carta	1	4.50
3949	1785	Fomy T/Carta	1	4.50
3982	1796	Fomy T/Carta	1	4.50
3983	1796	Fomy T/Carta	1	4.50
3990	1798	Fomy T/Carta	1	4.50
3991	1798	Fomy T/Carta	1	4.50
4179	1894	Fomy T/Carta	4	4.50
4585	2114	Fomy T/Carta	2	4.50
4586	2114	Fomy T/Carta	2	4.50
4652	2147	Fomy T/Carta	1	4.50
4985	2307	Fomy T/Carta	2	4.50
4986	2307	Fomy T/Carta	2	4.50
4987	2307	Fomy T/Carta	2	4.50
4988	2307	Fomy T/Carta	2	4.50
4989	2307	Fomy T/Carta	2	4.50
4990	2307	Fomy T/Carta	2	4.50
5017	2323	Fomy T/Carta	3	4.50
5018	2323	Fomy T/Carta	3	4.50
5104	2367	Fomy T/Carta	1	4.50
5128	2378	Fomy T/Carta	3	4.50
5278	2450	Fomy T/Carta	1	4.50
5383	2497	Fomy T/Carta	2	4.50
5384	2497	Fomy T/Carta	2	4.50
5542	2566	Fomy T/Carta	3	4.50
5743	2663	Fomy T/Carta	1	4.50
5853	2706	Fomy T/Carta	2	4.50
6001	2771	Fomy T/Carta	2	4.50
6002	2771	Fomy T/Carta	1	4.50
6003	2771	Fomy T/Carta	1	4.50
6233	2880	Fomy T/Carta	3	4.50
6234	2880	Fomy T/Carta	3	4.50
6235	2880	Fomy T/Carta	3	4.50
6236	2880	Fomy T/Carta	3	4.50
6784	3143	Fomy T/Carta	1	4.50
6820	3156	Fomy T/Carta	4	4.50
6821	3156	Fomy T/Carta	2	4.50
6942	3211	Fomy T/Carta	2	4.50
6950	3215	Fomy T/Carta	2	4.50
7107	3281	Fomy T/Carta	1	4.50
119	65	Papel Crepe	1	10.00
120	65	Papel Crepe	1	10.00
121	65	Papel Crepe	1	10.00
148	80	Papel Crepe	1	10.00
149	80	Papel Crepe	1	10.00
150	80	Papel Crepe	1	10.00
552	278	Papel Crepe	1	10.00
745	352	Papel Crepe	1	10.00
883	412	Papel Crepe	1	10.00
887	415	Papel Crepe	1	10.00
915	427	Papel Crepe	2	10.00
918	429	Papel Crepe	1	10.00
1026	485	Papel Crepe	1	10.00
1027	485	Papel Crepe	1	10.00
1228	577	Papel Crepe	1	10.00
1239	583	Papel Crepe	1	10.00
1378	634	Papel Crepe	1	10.00
1416	651	Papel Crepe	2	10.00
1417	651	Papel Crepe	2	10.00
1460	673	Papel Crepe	3	10.00
1479	683	Papel Crepe	1	10.00
1480	683	Papel Crepe	1	10.00
1481	683	Papel Crepe	1	10.00
1482	683	Papel Crepe	1	10.00
1483	683	Papel Crepe	1	10.00
1557	715	Papel Crepe	2	10.00
1558	715	Papel Crepe	2	10.00
1559	715	Papel Crepe	2	10.00
1569	718	Papel Crepe	1	10.00
1604	733	Papel Crepe	3	10.00
1615	736	Papel Crepe	1	10.00
1709	779	Papel Crepe	2	10.00
1710	779	Papel Crepe	1	10.00
1711	779	Papel Crepe	1	10.00
1712	779	Papel Crepe	1	10.00
1744	791	Papel Crepe	1	10.00
1745	791	Papel Crepe	1	10.00
1746	791	Papel Crepe	1	10.00
1804	817	Papel Crepe	1	10.00
1850	832	Papel Crepe	1	10.00
1898	850	Papel Crepe	1	10.00
1899	850	Papel Crepe	1	10.00
1917	856	Papel Crepe	1	10.00
2042	915	Papel Crepe	1	10.00
2043	915	Papel Crepe	1	10.00
2044	915	Papel Crepe	1	10.00
2048	917	Papel Crepe	2	10.00
2086	936	Papel Crepe	1	10.00
2087	936	Papel Crepe	1	10.00
2088	936	Papel Crepe	1	10.00
2102	945	Papel Crepe	2	10.00
2116	953	Papel Crepe	1	10.00
2140	963	Papel Crepe	1	10.00
2141	963	Papel Crepe	2	10.00
2149	964	Papel Crepe	3	10.00
2151	964	Papel Crepe	1	10.00
2174	975	Papel Crepe	4	10.00
2175	975	Papel Crepe	1	10.00
2180	976	Papel Crepe	6	10.00
2181	976	Papel Crepe	6	10.00
2190	980	Papel Crepe	1	10.00
2262	1005	Papel Crepe	1	10.00
2274	1012	Papel Crepe	1	10.00
2293	1021	Papel Crepe	1	10.00
2294	1021	Papel Crepe	1	10.00
2321	1029	Papel Crepe	1	10.00
2328	1032	Papel Crepe	2	10.00
2329	1032	Papel Crepe	2	10.00
2350	1038	Papel Crepe	1	10.00
2351	1038	Papel Crepe	1	10.00
2352	1038	Papel Crepe	2	10.00
2353	1038	Papel Crepe	2	10.00
2358	1042	Papel Crepe	1	10.00
2364	1044	Papel Crepe	4	10.00
2369	1048	Papel Crepe	2	10.00
2370	1048	Papel Crepe	2	10.00
2371	1048	Papel Crepe	2	10.00
2372	1048	Papel Crepe	2	10.00
2376	1050	Papel Crepe	1	10.00
2377	1050	Papel Crepe	1	10.00
2402	1061	Papel Crepe	1	10.00
2403	1061	Papel Crepe	1	10.00
2404	1061	Papel Crepe	1	10.00
2465	1085	Papel Crepe	1	10.00
2466	1085	Papel Crepe	1	10.00
2502	1118	Papel Crepe	1	10.00
2503	1118	Papel Crepe	1	10.00
2526	1132	Papel Crepe	1	10.00
2539	1137	Papel Crepe	2	10.00
2560	1144	Papel Crepe	2	10.00
2602	1158	Papel Crepe	1	10.00
2737	1227	Papel Crepe	2	10.00
2860	1295	Papel Crepe	1	10.00
2861	1295	Papel Crepe	1	10.00
2862	1295	Papel Crepe	1	10.00
3058	1391	Papel Crepe	1	10.00
3059	1391	Papel Crepe	1	10.00
3062	1392	Papel Crepe	1	10.00
3063	1392	Papel Crepe	1	10.00
3080	1400	Papel Crepe	1	10.00
3082	1402	Papel Crepe	1	10.00
3109	1411	Papel Crepe	1	10.00
3110	1411	Papel Crepe	1	10.00
3111	1411	Papel Crepe	1	10.00
3121	1415	Papel Crepe	1	10.00
3390	1528	Papel Crepe	1	10.00
3391	1528	Papel Crepe	1	10.00
3392	1528	Papel Crepe	1	10.00
3393	1528	Papel Crepe	1	10.00
3791	1711	Papel Crepe	4	10.00
3792	1711	Papel Crepe	2	10.00
3849	1740	Papel Crepe	1	10.00
3850	1740	Papel Crepe	2	10.00
3851	1740	Papel Crepe	3	10.00
3856	1743	Papel Crepe	1	10.00
3857	1743	Papel Crepe	2	10.00
3868	1749	Papel Crepe	1	10.00
3869	1749	Papel Crepe	1	10.00
4114	1864	Papel Crepe	2	10.00
4266	1945	Papel Crepe	1	10.00
4267	1945	Papel Crepe	1	10.00
4818	2236	Papel Crepe	2	10.00
4819	2236	Papel Crepe	2	10.00
4820	2236	Papel Crepe	2	10.00
4821	2236	Papel Crepe	2	10.00
4822	2236	Papel Crepe	2	10.00
4823	2236	Papel Crepe	2	10.00
5092	2358	Papel Crepe	1	10.00
6369	2946	Papel Crepe	1	10.00
6560	3036	Papel Crepe	2	10.00
6561	3036	Papel Crepe	2	10.00
6811	3154	Papel Crepe	1	10.00
6812	3154	Papel Crepe	1	10.00
6911	3198	Papel Crepe	1	10.00
6912	3198	Papel Crepe	1	10.00
6930	3207	Papel Crepe	1	10.00
6931	3207	Papel Crepe	1	10.00
6932	3207	Papel Crepe	1	10.00
6933	3207	Papel Crepe	1	10.00
6934	3207	Papel Crepe	1	10.00
6967	3221	Papel Crepe	1	10.00
6968	3221	Papel Crepe	1	10.00
6969	3221	Papel Crepe	1	10.00
7011	3239	Papel Crepe	1	10.00
7012	3239	Papel Crepe	2	10.00
7013	3239	Papel Crepe	1	10.00
7300	3379	Papel Crepe	2	10.00
7301	3379	Papel Crepe	1	10.00
7302	3379	Papel Crepe	1	10.00
7303	3379	Papel Crepe	1	10.00
1580	722	Tinta para Cojin	1	55.00
1754	794	Tinta para Cojin	1	60.00
2893	1310	Tinta para Cojin	1	55.00
1397	642	Calculadora	1	45.00
2112	950	Calculadora	1	100.00
2793	1253	Calculadora	1	65.00
2896	1312	Calculadora	1	45.00
3483	1570	Calculadora	1	85.00
4468	2046	Calculadora	1	95.00
5330	2473	Calculadora	1	65.00
5362	2487	Calculadora	1	85.00
7313	3385	Calculadora	1	85.00
6780	3142	Lienzo	1	90.00
6617	3064	Masa Moldeable	1	40.00
6676	3098	Masa Moldeable	1	40.00
4630	2137	Bolsa Ziplot	1	2.00
5378	2494	Bolsa Ziplot	1	2.00
236	121	Resistol Liquido	1	10.00
316	167	Resistol Liquido	2	10.00
376	200	Resistol Liquido	1	20.00
817	383	Resistol Liquido	1	45.00
880	410	Resistol Liquido	1	20.00
985	465	Resistol Liquido	1	20.00
1266	591	Resistol Liquido	1	20.00
1647	754	Resistol Liquido	1	26.00
1882	839	Resistol Liquido	1	10.00
2200	983	Resistol Liquido	2	20.00
2233	991	Resistol Liquido	1	20.00
2416	1062	Resistol Liquido	1	20.00
2601	1158	Resistol Liquido	1	20.00
2807	1261	Resistol Liquido	1	60.00
3272	1474	Resistol Liquido	1	25.00
3417	1542	Resistol Liquido	1	10.00
3457	1561	Resistol Liquido	1	10.00
3630	1630	Resistol Liquido	1	10.00
3686	1656	Resistol Liquido	1	10.00
3714	1669	Resistol Liquido	1	45.00
3859	1744	Resistol Liquido	1	10.00
3873	1752	Resistol Liquido	1	10.00
3928	1776	Resistol Liquido	1	20.00
3932	1777	Resistol Liquido	1	10.00
4029	1814	Resistol Liquido	1	80.00
4030	1814	Resistol Liquido	1	85.00
4115	1864	Resistol Liquido	1	40.00
4651	2147	Resistol Liquido	1	20.00
4857	2247	Resistol Liquido	1	10.00
4922	2277	Resistol Liquido	1	20.00
5294	2455	Resistol Liquido	1	25.00
5313	2465	Resistol Liquido	1	45.00
5504	2550	Resistol Liquido	1	45.00
5524	2561	Resistol Liquido	1	20.00
5612	2606	Resistol Liquido	1	10.00
5618	2607	Resistol Liquido	1	10.00
5714	2645	Resistol Liquido	1	22.00
5718	2647	Resistol Liquido	1	22.00
5797	2690	Resistol Liquido	2	10.00
5846	2704	Resistol Liquido	1	10.00
6010	2774	Resistol Liquido	1	15.00
6054	2793	Resistol Liquido	1	15.00
6160	2842	Resistol Liquido	1	22.00
6355	2938	Resistol Liquido	1	30.00
6368	2946	Resistol Liquido	1	15.00
6504	3009	Resistol Liquido	1	22.00
6851	3169	Resistol Liquido	1	15.00
6975	3225	Resistol Liquido	1	15.00
135	73	Pegamento Barra	1	15.00
136	74	Pegamento Barra	1	15.00
433	224	Pegamento Barra	1	55.00
558	280	Pegamento Barra	1	35.00
741	350	Pegamento Barra	1	35.00
744	352	Pegamento Barra	1	15.00
873	408	Pegamento Barra	1	15.00
976	461	Pegamento Barra	1	15.00
1008	474	Pegamento Barra	1	25.00
1092	507	Pegamento Barra	1	15.00
1305	605	Pegamento Barra	1	25.00
1400	644	Pegamento Barra	1	35.00
1440	664	Pegamento Barra	1	15.00
1592	726	Pegamento Barra	1	55.00
1612	735	Pegamento Barra	1	35.00
1652	756	Pegamento Barra	1	15.00
1769	801	Pegamento Barra	1	15.00
2123	957	Pegamento Barra	1	15.00
2192	980	Pegamento Barra	1	25.00
2278	1015	Pegamento Barra	1	15.00
2318	1027	Pegamento Barra	1	55.00
2341	1036	Pegamento Barra	1	55.00
2405	1061	Pegamento Barra	1	15.00
2627	1174	Pegamento Barra	1	15.00
2683	1201	Pegamento Barra	1	15.00
2740	1227	Pegamento Barra	1	35.00
2863	1296	Pegamento Barra	1	35.00
3032	1372	Pegamento Barra	1	15.00
3033	1372	Pegamento Barra	1	35.00
3085	1403	Pegamento Barra	1	15.00
3182	1440	Pegamento Barra	1	15.00
3240	1464	Pegamento Barra	1	35.00
3286	1481	Pegamento Barra	1	25.00
3311	1494	Pegamento Barra	1	35.00
3338	1505	Pegamento Barra	1	25.00
3339	1505	Pegamento Barra	1	35.00
3396	1530	Pegamento Barra	1	15.00
3401	1533	Pegamento Barra	1	15.00
3523	1586	Pegamento Barra	1	15.00
3602	1621	Pegamento Barra	1	15.00
3621	1629	Pegamento Barra	2	35.00
3696	1660	Pegamento Barra	1	15.00
3704	1666	Pegamento Barra	1	15.00
3752	1691	Pegamento Barra	2	70.00
3796	1711	Pegamento Barra	1	15.00
3805	1716	Pegamento Barra	1	15.00
3809	1719	Pegamento Barra	1	35.00
3852	1740	Pegamento Barra	1	15.00
3931	1777	Pegamento Barra	1	15.00
3978	1796	Pegamento Barra	1	15.00
4056	1828	Pegamento Barra	1	15.00
4092	1846	Pegamento Barra	1	15.00
4370	2005	Pegamento Barra	1	15.00
4382	2011	Pegamento Barra	1	15.00
4461	2042	Pegamento Barra	1	35.00
4470	2048	Pegamento Barra	1	55.00
4499	2064	Pegamento Barra	1	35.00
4534	2084	Pegamento Barra	1	35.00
4560	2099	Pegamento Barra	1	25.00
4566	2103	Pegamento Barra	1	35.00
4639	2142	Pegamento Barra	1	15.00
4688	2170	Pegamento Barra	1	35.00
4705	2180	Pegamento Barra	1	15.00
4827	2237	Pegamento Barra	2	35.00
4845	2242	Pegamento Barra	1	35.00
4878	2260	Pegamento Barra	1	35.00
4929	2281	Pegamento Barra	1	15.00
4946	2288	Pegamento Barra	1	15.00
5019	2323	Pegamento Barra	1	35.00
5051	2343	Pegamento Barra	1	15.00
5233	2425	Pegamento Barra	1	35.00
5244	2430	Pegamento Barra	1	15.00
5411	2508	Pegamento Barra	1	15.00
5581	2588	Pegamento Barra	1	15.00
5638	2614	Pegamento Barra	2	35.00
5762	2672	Pegamento Barra	2	15.00
5814	2694	Pegamento Barra	1	25.00
5860	2708	Pegamento Barra	1	15.00
5955	2747	Pegamento Barra	1	15.00
6083	2808	Pegamento Barra	1	35.00
6238	2882	Pegamento Barra	1	25.00
6340	2933	Pegamento Barra	1	35.00
6367	2946	Pegamento Barra	1	15.00
6377	2952	Pegamento Barra	1	35.00
6378	2953	Pegamento Barra	2	35.00
6408	2966	Pegamento Barra	2	15.00
6503	3008	Pegamento Barra	2	35.00
6509	3013	Pegamento Barra	1	15.00
6544	3028	Pegamento Barra	1	15.00
6666	3092	Pegamento Barra	1	15.00
6669	3093	Pegamento Barra	2	15.00
6807	3151	Pegamento Barra	1	15.00
6828	3162	Pegamento Barra	2	35.00
6842	3166	Pegamento Barra	1	15.00
6894	3194	Pegamento Barra	1	35.00
6895	3195	Pegamento Barra	3	15.00
7154	3302	Pegamento Barra	1	15.00
7215	3334	Pegamento Barra	1	35.00
7305	3379	Pegamento Barra	1	35.00
7329	3390	Pegamento Barra	1	15.00
7351	3400	Pegamento Barra	1	35.00
606	302	Etiqueta #24	1	30.00
250	129	Etiqueta #6	1	30.00
2121	956	Etiqueta #4	1	30.00
3185	1441	Etiqueta #1	1	30.00
3789	1710	Etiqueta #1	1	30.00
1832	826	Sobre Oficio	1	4.00
169	92	Vale de Caja	1	20.00
320	170	Ficha Bibliografica	10	1.50
504	257	Ficha Bibliografica	54	1.50
668	327	Ficha Bibliografica	70	1.00
1101	515	Ficha Bibliografica	2	0.50
1435	661	Ficha Bibliografica	4	1.50
1469	678	Ficha Bibliografica	6	1.50
1991	893	Ficha Bibliografica	4	1.00
3243	1466	Ficha Bibliografica	5	1.00
3276	1475	Ficha Bibliografica	10	1.00
3279	1477	Ficha Bibliografica	30	0.50
4737	2196	Ficha Bibliografica	80	0.50
5093	2359	Ficha Bibliografica	20	0.50
5227	2422	Ficha Bibliografica	10	0.50
5387	2498	Ficha Bibliografica	3	1.50
6042	2788	Ficha Bibliografica	5	1.50
6043	2788	Ficha Bibliografica	5	1.50
6375	2950	Ficha Bibliografica	4	1.50
6425	2972	Ficha Bibliografica	2	1.00
6857	3171	Ficha Bibliografica	8	1.00
6983	3227	Ficha Bibliografica	10	0.50
6995	3231	Ficha Bibliografica	5	1.00
3213	1453	Pagare	4	2.50
3750	1689	Pagare	2	2.50
5077	2353	Pagare	13	2.50
7227	3341	Pagare	1	2.50
4433	2029	Recibo de Renta	1	30.00
5482	2541	Recibo General	1	35.00
401	212	Block de Notas	1	45.00
1146	542	Block de Notas	1	45.00
1630	744	Block de Notas	1	45.00
2153	966	Block de Notas	1	45.00
2631	1176	Block de Notas	1	45.00
2857	1292	Block de Notas	1	45.00
3471	1565	Block de Notas	1	45.00
3975	1795	Block de Notas	1	20.00
4803	2229	Block de Notas	1	45.00
5629	2610	Block de Notas	1	45.00
5630	2610	Block de Notas	1	20.00
926	436	Recopilador	1	95.00
4758	2208	Recopilador	1	95.00
1807	818	Fieltro	2	7.00
1743	790	Libro para Colorear	1	15.00
3157	1433	Libro para Colorear	2	15.00
3306	1492	Libro para Colorear	1	15.00
3337	1504	Libro para Colorear	1	15.00
4156	1882	Libro para Colorear	2	15.00
6227	2879	Libro para Colorear	1	45.00
6324	2926	Libro para Colorear	1	15.00
6356	2938	Libro para Colorear	1	40.00
6614	3061	Libro para Colorear	1	15.00
7028	3244	Libro para Colorear	1	15.00
7239	3349	Libro para Colorear	1	15.00
452	232	Cuento	2	20.00
1393	640	Libro de Mandala	1	20.00
1674	766	Libro de Mandala	1	20.00
2868	1299	Libro de Mandala	1	20.00
3307	1492	Libro de Mandala	1	20.00
5410	2508	Libro Sopa de Letras	1	35.00
4282	1956	Libro Sopa de Letras	1	50.00
1375	632	Dado	1	5.00
7231	3342	Dado	3	5.00
1401	644	Dado	1	15.00
2813	1265	Dado	1	15.00
3199	1449	Dado	1	15.00
4181	1895	Dado	1	15.00
4270	1948	Dado	1	10.00
158	86	Carrillera	1	40.00
1927	862	Globo # 260	4	2.00
6884	3187	Globo T/Jumbo	1	10.00
4436	2031	Cuaderno Profecional 200 Hojas	1	160.00
698	338	Letrero	1	24.00
328	174	Letrero	1	20.00
484	247	Letrero	1	45.00
542	275	Letrero	1	50.00
1041	491	Letrero	1	35.00
2514	1123	Letrero	1	35.00
2551	1141	Letrero	1	45.00
3206	1449	Letrero	1	35.00
3261	1472	Letrero	1	35.00
3444	1553	Letrero	1	35.00
4396	2015	Letrero	1	35.00
4455	2039	Letrero	1	35.00
6363	2944	Letrero	1	35.00
6556	3034	Letrero	1	45.00
7268	3364	Letrero	1	35.00
7285	3371	Letrero	2	5.00
5451	2525	Tabla Perfocel	1	20.00
4635	2140	Etiqueta #25	1	30.00
395	209	Sobre 1/2 Carta	1	15.00
187	98	Cuaderno Profecional	4	35.00
188	98	Cuaderno Profecional	1	35.00
285	148	Cuaderno Profecional	1	35.00
315	166	Cuaderno Profecional	1	35.00
362	192	Cuaderno Profecional	1	35.00
417	217	Cuaderno Profecional	1	35.00
467	240	Cuaderno Profecional	1	35.00
802	375	Cuaderno Profecional	1	35.00
960	452	Cuaderno Profecional	1	35.00
1391	640	Cuaderno Profecional	1	35.00
2719	1216	Cuaderno Profecional	1	35.00
2867	1299	Cuaderno Profecional	1	35.00
2913	1321	Cuaderno Profecional	1	35.00
3207	1450	Cuaderno Profecional	1	35.00
3811	1720	Cuaderno Profecional	1	35.00
3863	1746	Cuaderno Profecional	1	35.00
4118	1866	Cuaderno Profecional	1	35.00
4729	2190	Cuaderno Profecional	1	35.00
4847	2242	Cuaderno Profecional	3	45.00
4902	2270	Cuaderno Profecional	6	35.00
5204	2415	Cuaderno Profecional	1	35.00
5205	2415	Cuaderno Profecional	3	35.00
5497	2549	Cuaderno Profecional	1	35.00
5746	2665	Cuaderno Profecional	1	35.00
6562	3037	Cuaderno Profecional	1	35.00
6871	3179	Cuaderno Profecional	1	35.00
7322	3388	Cuaderno Profecional	1	35.00
473	243	Cuaderno Profecional Pasta Dura	1	55.00
3116	1413	Cuaderno Profecional Pasta Dura	1	55.00
3403	1534	Cuaderno Profecional Pasta Dura	1	55.00
4404	2018	Cuaderno Profecional Pasta Dura	1	55.00
774	364	Cuaderno Profecional	1	35.00
1611	734	Cuaderno Profecional	1	35.00
4485	2058	Cuaderno Profecional	1	35.00
4874	2257	Cuaderno Profecional	2	35.00
4903	2270	Cuaderno Profecional	1	35.00
5108	2369	Cuaderno Profecional	1	35.00
6167	2848	Cuaderno Profecional	1	35.00
6741	3126	Cuaderno Profecional	1	35.00
6879	3183	Cuaderno Profecional	1	35.00
6977	3227	Cuaderno Profecional	1	35.00
7072	3270	Cuaderno Profecional	1	35.00
5364	2488	Constitucion Politica	1	45.00
5200	2413	Cuaderno Italiano	1	35.00
5292	2454	Cuaderno Italiano	1	35.00
5215	2420	Cuaderno Italiano Cocido	1	50.00
5732	2654	Cuaderno Italiano Cocido	1	50.00
6135	2831	Cuaderno Italiano Cocido	1	50.00
6379	2953	Cuaderno Italiano Cocido	2	50.00
506	259	Anilina	1	3.00
1246	585	Anilina	1	3.00
6973	3224	Anilina	1	5.00
4732	2193	Pintura Vegetal	4	5.00
5338	2478	Pintura Vegetal	1	5.00
591	298	Cubo	1	80.00
602	300	Cubo	1	80.00
4256	1940	Cubo	1	55.00
4371	2005	Cubo	1	55.00
4388	2012	Cubo	1	80.00
4426	2026	Cubo	1	55.00
5069	2351	Cubo	1	40.00
5140	2384	Cubo	1	40.00
5673	2630	Cubo	1	55.00
5756	2669	Cubo	1	40.00
6456	2988	Cubo	1	60.00
7288	3373	Cubo	1	60.00
238	123	Block Tabla	1	95.00
413	215	Block Tabla	1	95.00
1464	676	Block Tabla	1	95.00
2242	995	Block Tabla	1	105.00
5271	2446	Block Tabla	1	105.00
1236	582	Block Tabla C/Espiral	1	50.00
1254	588	Block Tabla C/Espiral	1	50.00
2657	1189	Block Tabla C/Espiral	1	50.00
3208	1451	Block Tabla C/Espiral	1	75.00
5449	2524	Block Tabla C/Espiral	1	75.00
811	382	Carpeta Costilla	1	20.00
2641	1181	Carpeta Costilla	1	20.00
3242	1465	Carpeta Costilla	1	20.00
3429	1546	Carpeta Costilla	1	20.00
3468	1563	Carpeta Costilla	1	20.00
5159	2393	Carpeta Costilla	1	20.00
786	368	Sobre Plastico	1	30.00
832	391	Sobre Plastico	1	30.00
954	448	Sobre Plastico	1	30.00
2106	947	Sobre Plastico	1	30.00
3055	1388	Sobre Plastico	1	35.00
3313	1495	Sobre Plastico	1	30.00
3662	1646	Sobre Plastico	1	30.00
4307	1969	Sobre Plastico	1	30.00
4430	2028	Sobre Plastico	1	30.00
4515	2074	Sobre Plastico	1	30.00
5143	2386	Sobre Plastico	1	30.00
5239	2427	Sobre Plastico	1	30.00
5249	2433	Sobre Plastico	1	30.00
6384	2956	Sobre Plastico	3	30.00
6463	2993	Sobre Plastico	2	30.00
6642	3079	Sobre Plastico	1	35.00
6906	3196	Sobre Plastico	1	35.00
6907	3196	Sobre Plastico	1	30.00
6919	3200	Sobre Plastico	1	30.00
7074	3271	Sobre Plastico	1	30.00
7078	3272	Sobre Plastico	1	30.00
7194	3321	Sobre Plastico	1	30.00
7204	3327	Sobre Plastico	1	35.00
3930	1777	Sobre T/Oficio	2	15.00
6361	2942	Sobre T/Oficio	1	10.00
1014	477	Sobre T/Carta	1	8.00
1389	639	Sobre T/Carta	1	8.00
2270	1010	Sobre T/Carta	1	8.00
2535	1136	Sobre T/Carta	1	8.00
3314	1496	Sobre T/Carta	1	8.00
6383	2955	Sobre T/Carta	1	8.00
6424	2971	Sobre T/Carta	1	8.00
7075	3271	Sobre T/Carta	1	8.00
7121	3286	Sobre T/Carta	1	8.00
872	407	Acetato	2	5.00
3142	1424	Acetato	1	5.00
3168	1437	Acetato	3	5.00
6673	3096	Acetato	2	5.00
7046	3257	Hojas Mantequilla	2	3.50
144	78	Papel Pasante	6	2.50
771	361	Papel Pasante	1	2.50
1837	827	Papel Pasante	1	2.50
2097	942	Papel Pasante	6	2.50
2565	1147	Papel Pasante	3	3.50
2854	1290	Papel Pasante	5	2.50
3798	1712	Papel Pasante	6	2.50
6357	2939	Papel Pasante	4	2.50
927	436	Separadores	1	40.00
5012	2320	Separadores	1	40.00
5274	2448	Separadores	1	35.00
4951	2290	Tabla Periodica	1	25.00
233	120	Forro	1	7.00
408	213	Forro	12	7.00
1269	592	Forro	2	7.00
1977	886	Forro	1	7.00
2820	1269	Forro	1	22.00
4507	2071	Forro	1	7.00
4598	2121	Forro	1	22.00
4603	2122	Forro	1	22.00
4795	2226	Forro	1	7.00
4915	2276	Forro	1	22.00
5000	2314	Forro	1	22.00
5192	2410	Forro	1	22.00
5217	2420	Forro	1	7.00
5406	2506	Forro	1	7.00
5521	2558	Forro	4	7.00
5575	2584	Forro	4	7.00
5759	2670	Forro	1	22.00
6978	3227	Forro	1	7.00
7044	3255	Forro	4	7.00
7327	3390	Forro	2	7.00
2164	971	Contrato de Arrendamiento	3	3.00
4128	1871	Contrato de Arrendamiento	1	3.00
2618	1167	Contrato de Compra y Venta	1	3.00
4805	2230	Carta Poder	4	2.50
6092	2812	Carta Poder	5	2.50
7122	3287	Carta Poder	4	2.50
650	316	Carta Responsiva	4	2.50
2617	1167	Carta Responsiva	1	2.50
6166	2847	Carta Responsiva	6	2.50
425	220	Confeti	1	20.00
996	468	Confeti	1	20.00
1064	497	Confeti	1	15.00
3587	1615	Confeti	1	15.00
2593	1155	Fichas	1	40.00
4390	2012	Fichas	1	40.00
4391	2012	Monedas y Billetes	1	45.00
3265	1472	Gancho	1	25.00
7271	3364	Gancho	1	35.00
1151	545	Lupa	1	15.00
2936	1331	Lupa	1	20.00
5412	2509	Lupa	1	20.00
2258	1003	Chincheta	1	20.00
6867	3176	Chincheta	1	20.00
4531	2082	Sujetador de Documentos	1	10.00
4804	2229	Sujetador de Documentos	2	4.50
5348	2481	Sujetador de Documentos	1	6.00
5349	2481	Sujetador de Documentos	1	10.00
5878	2712	Sujetador de Documentos	1	25.00
197	105	Engrapadora	1	55.00
288	149	Engrapadora	1	50.00
1608	733	Engrapadora	1	50.00
2091	938	Engrapadora	1	55.00
2322	1029	Engrapadora	1	65.00
2624	1171	Engrapadora	1	55.00
2678	1198	Engrapadora	1	75.00
2788	1251	Engrapadora	1	55.00
3180	1440	Engrapadora	1	55.00
5261	2438	Engrapadora	1	55.00
5778	2679	Engrapadora	1	45.00
6329	2928	Engrapadora	1	45.00
6640	3079	Engrapadora	1	70.00
143	77	Lampara	1	20.00
1291	599	Lampara	1	15.00
1370	630	Lampara	1	15.00
1654	756	Lampara	1	20.00
278	144	Rompecabezas	1	7.00
340	180	Rompecabezas	1	25.00
947	443	Rompecabezas	1	10.00
1402	644	Rompecabezas	1	7.00
1551	711	Rompecabezas	1	10.00
1552	711	Rompecabezas	1	7.00
1599	730	Rompecabezas	1	10.00
1857	834	Rompecabezas	1	7.00
3351	1510	Rompecabezas	1	20.00
3628	1629	Rompecabezas	1	7.00
3724	1674	Rompecabezas	1	10.00
3727	1674	Rompecabezas	1	15.00
3974	1794	Rompecabezas	3	10.00
4158	1882	Rompecabezas	1	10.00
4384	2011	Rompecabezas	1	7.00
4416	2023	Rompecabezas	1	20.00
1738	787	Set de Costura	2	30.00
1284	598	Llavero de Multiplicar	1	50.00
5060	2347	Llavero de Multiplicar	1	70.00
1136	535	Borrador Clip	1	35.00
1190	563	Borrador Clip	1	30.00
1579	722	Borrador Clip	1	30.00
4464	2045	Borrador Clip	1	22.00
4491	2060	Borrador Clip	1	22.00
6692	3104	Borrador Clip	1	35.00
529	269	Pegatina	1	35.00
1763	798	Pegatina	1	35.00
1990	892	Pegatina	1	30.00
2324	1029	Pegatina	1	35.00
2357	1041	Pegatina	1	30.00
2421	1065	Pegatina	1	30.00
2442	1073	Pegatina	1	35.00
2519	1126	Pegatina	1	35.00
2659	1190	Pegatina	1	30.00
3169	1437	Pegatina	1	35.00
3694	1660	Pegatina	2	35.00
6474	2997	Pegatina	1	30.00
6737	3125	Pegatina	1	30.00
6738	3125	Pegatina	1	35.00
6873	3181	Pegatina	1	35.00
871	406	Lapicero	1	20.00
1053	495	Lapicero	1	25.00
1811	819	Lapicero	1	20.00
2677	1198	Lapicero	1	30.00
3622	1629	Lapicero	1	25.00
5656	2622	Lapicero	1	25.00
6548	3029	Lapicero	1	25.00
6834	3164	Lapicero	1	30.00
7138	3292	Lapicero	1	25.00
1090	506	Acerrin	1	9.00
1148	543	Acerrin	1	35.00
2067	927	Acerrin	1	9.00
2441	1073	Acerrin	1	9.00
3083	1403	Acerrin	2	9.00
3847	1738	Acerrin	2	9.00
5295	2455	Acerrin	3	9.00
5500	2550	Acerrin	2	9.00
5845	2704	Acerrin	2	9.00
6769	3140	Acerrin	1	9.00
1720	782	Arbolitos	5	4.50
2066	927	Arbolitos	6	4.50
6352	2936	Arbolitos	3	4.50
1721	782	Animalitos	1	16.00
7114	3282	Animalitos	2	16.00
453	233	Uñas	2	15.00
758	356	Uñas	1	15.00
4350	1993	Uñas	1	15.00
4790	2225	Uñas	1	15.00
5286	2453	Pirinola	1	15.00
5666	2627	Pirinola	1	15.00
153	82	Pandero	1	27.00
331	177	Bolsa de Regalo	1	22.00
622	310	Bolsa de Regalo	1	28.00
938	441	Bolsa de Regalo	1	45.00
939	441	Bolsa de Regalo	1	25.00
942	442	Bolsa de Regalo	2	25.00
950	445	Bolsa de Regalo	1	20.00
956	450	Bolsa de Regalo	1	25.00
1002	472	Bolsa de Regalo	1	20.00
1003	472	Bolsa de Regalo	1	45.00
1626	741	Bolsa de Regalo	1	30.00
1665	761	Bolsa de Regalo	1	20.00
1676	768	Bolsa de Regalo	1	25.00
1696	774	Bolsa de Regalo	2	45.00
1869	836	Bolsa de Regalo	1	30.00
1870	836	Bolsa de Regalo	1	30.00
1871	836	Bolsa de Regalo	1	30.00
1961	879	Bolsa de Regalo	1	25.00
2077	931	Bolsa de Regalo	1	30.00
2095	940	Bolsa de Regalo	1	25.00
2098	943	Bolsa de Regalo	1	45.00
2114	952	Bolsa de Regalo	1	45.00
2588	1152	Bolsa de Regalo	1	25.00
2589	1152	Bolsa de Regalo	1	30.00
2680	1200	Bolsa de Regalo	1	25.00
2731	1223	Bolsa de Regalo	1	50.00
2855	1291	Bolsa de Regalo	1	20.00
2923	1325	Bolsa de Regalo	1	25.00
3067	1395	Bolsa de Regalo	1	25.00
3202	1449	Bolsa de Regalo	1	45.00
3224	1459	Bolsa de Regalo	1	30.00
3385	1526	Bolsa de Regalo	1	25.00
3413	1540	Bolsa de Regalo	1	30.00
3450	1557	Bolsa de Regalo	1	30.00
3601	1620	Bolsa de Regalo	1	30.00
3651	1637	Bolsa de Regalo	1	30.00
3659	1644	Bolsa de Regalo	1	30.00
3728	1675	Bolsa de Regalo	1	20.00
3731	1676	Bolsa de Regalo	1	20.00
3818	1722	Bolsa de Regalo	1	30.00
4031	1815	Bolsa de Regalo	1	25.00
4069	1835	Bolsa de Regalo	1	50.00
4087	1842	Bolsa de Regalo	1	30.00
4170	1889	Bolsa de Regalo	1	25.00
4304	1967	Bolsa de Regalo	1	20.00
4305	1968	Bolsa de Regalo	1	25.00
4320	1979	Bolsa de Regalo	1	30.00
4392	2013	Bolsa de Regalo	1	25.00
4434	2030	Bolsa de Regalo	2	25.00
4435	2030	Bolsa de Regalo	2	30.00
4715	2184	Bolsa de Regalo	1	30.00
4736	2195	Bolsa de Regalo	1	30.00
4876	2258	Bolsa de Regalo	1	45.00
4896	2266	Bolsa de Regalo	1	30.00
4901	2269	Bolsa de Regalo	1	45.00
4911	2274	Bolsa de Regalo	1	45.00
5040	2338	Bolsa de Regalo	1	25.00
5173	2399	Bolsa de Regalo	1	45.00
5373	2491	Bolsa de Regalo	1	20.00
5467	2534	Bolsa de Regalo	1	45.00
5468	2534	Bolsa de Regalo	1	25.00
5483	2542	Bolsa de Regalo	1	50.00
5696	2639	Bolsa de Regalo	1	25.00
5697	2639	Bolsa de Regalo	1	20.00
5721	2649	Bolsa de Regalo	1	20.00
5741	2661	Bolsa de Regalo	1	45.00
5818	2697	Bolsa de Regalo	1	45.00
5896	2720	Bolsa de Regalo	1	30.00
6152	2838	Bolsa de Regalo	1	25.00
6294	2910	Bolsa de Regalo	1	30.00
6315	2920	Bolsa de Regalo	1	25.00
6317	2922	Bolsa de Regalo	2	25.00
6319	2924	Bolsa de Regalo	1	45.00
6553	3033	Bolsa de Regalo	1	55.00
6646	3080	Bolsa de Regalo	1	30.00
6822	3157	Bolsa de Regalo	1	30.00
6972	3223	Bolsa de Regalo	1	25.00
6996	3232	Bolsa de Regalo	1	45.00
6999	3233	Bolsa de Regalo	1	45.00
7001	3235	Bolsa de Regalo	1	30.00
7002	3236	Bolsa de Regalo	1	55.00
7021	3241	Bolsa de Regalo	1	25.00
163	88	Bolis	2	15.00
251	130	Bolis	1	15.00
691	333	Bolis	1	15.00
809	380	Bolis	2	15.00
810	381	Bolis	1	15.00
1301	604	Bolis	2	15.00
1437	662	Bolis	2	15.00
1578	721	Bolis	4	15.00
1645	752	Bolis	1	15.00
2301	1022	Bolis	1	15.00
2304	1023	Bolis	2	15.00
2518	1126	Bolis	3	15.00
2600	1157	Bolis	3	15.00
2702	1211	Bolis	1	15.00
2852	1289	Bolis	2	15.00
3506	1582	Bolis	1	15.00
3846	1737	Bolis	1	15.00
4017	1809	Bolis	2	15.00
4231	1923	Bolis	2	15.00
4895	2265	Bolis	2	15.00
5276	2449	Bolis	1	15.00
5363	2488	Bolis	1	15.00
5693	2637	Bolis	2	15.00
5708	2642	Bolis	2	15.00
6107	2821	Bolis	1	15.00
6426	2973	Bolis	2	15.00
6588	3049	Bolis	1	15.00
343	182	Bolsa de Regalo	1	28.00
941	442	Bolsa de Regalo	2	30.00
952	446	Bolsa de Regalo	1	30.00
1701	777	Bolsa de Regalo	1	30.00
3914	1770	Bolsa de Regalo	1	30.00
3915	1770	Bolsa de Regalo	1	30.00
5178	2401	Bolsa de Regalo	1	30.00
5772	2678	Bolsa de Regalo	1	30.00
7159	3305	Bolsa de Regalo	1	30.00
166	90	Papel Picado	1	7.00
173	93	Papel Picado	1	7.00
444	228	Papel Picado	1	7.00
516	264	Papel Picado	2	7.00
568	283	Papel Picado	1	7.00
592	298	Papel Picado	1	7.00
604	300	Papel Picado	1	7.00
607	303	Papel Picado	2	7.00
621	310	Papel Picado	1	7.00
766	357	Papel Picado	1	7.00
838	393	Papel Picado	2	7.00
858	400	Papel Picado	4	7.00
913	425	Papel Picado	1	7.00
943	442	Papel Picado	4	7.00
951	445	Papel Picado	1	7.00
1001	472	Papel Picado	2	7.00
1313	612	Papel Picado	1	7.00
1323	616	Papel Picado	8	3.50
1379	634	Papel Picado	50	3.50
1384	637	Papel Picado	7	3.50
1444	667	Papel Picado	10	3.50
1667	762	Papel Picado	6	2.50
1677	768	Papel Picado	1	7.00
1697	774	Papel Picado	2	7.00
1703	777	Papel Picado	1	7.00
1785	810	Papel Picado	5	2.50
1790	813	Papel Picado	2	3.50
1816	821	Papel Picado	20	3.50
1872	836	Papel Picado	3	7.00
1950	875	Papel Picado	1	30.00
1965	880	Papel Picado	2	30.00
2029	910	Papel Picado	1	15.00
2041	915	Papel Picado	1	15.00
2076	930	Papel Picado	3	3.50
2099	943	Papel Picado	2	7.00
2131	959	Papel Picado	1	3.50
2289	1019	Papel Picado	1	7.00
2290	1019	Papel Picado	6	3.50
2291	1020	Papel Picado	4	3.50
2303	1023	Papel Picado	3	3.50
2333	1032	Papel Picado	1	7.00
2386	1053	Papel Picado	3	3.50
2401	1060	Papel Picado	2	3.50
2447	1075	Papel Picado	7	3.50
2500	1118	Papel Picado	4	3.50
2538	1137	Papel Picado	4	3.50
2584	1151	Papel Picado	10	3.50
2595	1155	Papel Picado	4	3.50
2598	1156	Papel Picado	7	3.50
2603	1159	Papel Picado	15	3.50
2924	1325	Papel Picado	1	7.00
3203	1449	Papel Picado	1	7.00
3365	1517	Papel Picado	2	7.00
3439	1553	Papel Picado	2	7.00
3451	1557	Papel Picado	1	7.00
3680	1655	Papel Picado	2	7.00
3729	1675	Papel Picado	1	7.00
3785	1708	Papel Picado	4	7.00
3819	1722	Papel Picado	6	7.00
3837	1731	Papel Picado	2	7.00
3905	1764	Papel Picado	1	7.00
3956	1787	Papel Picado	2	7.00
3963	1788	Papel Picado	4	7.00
3969	1792	Papel Picado	1	7.00
3979	1796	Papel Picado	2	7.00
4016	1808	Papel Picado	1	7.00
4042	1821	Papel Picado	2	7.00
4043	1822	Papel Picado	1	7.00
4052	1826	Papel Picado	6	7.00
4057	1829	Papel Picado	1	7.00
4070	1835	Papel Picado	2	7.00
4073	1836	Papel Picado	2	7.00
4075	1837	Papel Picado	1	7.00
4080	1839	Papel Picado	2	7.00
4086	1841	Papel Picado	1	7.00
4088	1843	Papel Picado	2	7.00
4096	1849	Papel Picado	3	7.00
4099	1852	Papel Picado	3	7.00
4172	1890	Papel Picado	1	7.00
4210	1912	Papel Picado	3	7.00
4218	1916	Papel Picado	4	7.00
4237	1928	Papel Picado	2	7.00
4238	1929	Papel Picado	2	7.00
4241	1931	Papel Picado	1	7.00
4249	1934	Papel Picado	8	7.00
4250	1935	Papel Picado	6	7.00
4265	1944	Papel Picado	20	7.00
4272	1949	Papel Picado	6	7.00
4278	1952	Papel Picado	11	7.00
4279	1953	Papel Picado	15	7.00
4291	1959	Papel Picado	4	7.00
4360	1999	Papel Picado	1	7.00
4393	2013	Papel Picado	1	7.00
4493	2061	Papel Picado	2	7.00
4675	2163	Papel Picado	2	7.00
4735	2195	Papel Picado	2	7.00
4897	2266	Papel Picado	2	7.00
5369	2491	Papel Picado	1	7.00
5543	2566	Papel Picado	1	7.00
5617	2607	Papel Picado	1	7.00
5675	2630	Papel Picado	1	7.00
5761	2671	Papel Picado	1	7.00
5825	2698	Papel Picado	1	7.00
5856	2707	Papel Picado	1	7.00
5880	2713	Papel Picado	2	7.00
6134	2830	Papel Picado	1	7.00
6153	2838	Papel Picado	2	7.00
6295	2910	Papel Picado	1	7.00
6305	2915	Papel Picado	1	7.00
6333	2930	Papel Picado	5	7.00
6554	3033	Papel Picado	3	7.00
6823	3157	Papel Picado	1	7.00
6998	3233	Papel Picado	1	7.00
7284	3370	Papel Picado	1	7.00
4145	1877	Moño Mini	1	4.50
4247	1933	Moño Mini	5	4.50
4355	1995	Moño Mini	2	4.50
6051	2791	Moño Mini	1	4.50
2928	1327	Moño Chico	2	6.00
3838	1732	Moño Chico	1	6.00
3955	1787	Moño Chico	3	6.00
4071	1836	Moño Chico	4	6.00
4227	1920	Moño Chico	1	6.00
4269	1947	Moño Chico	1	6.00
4869	2254	Moño Chico	2	6.00
5781	2681	Moño Chico	1	6.00
172	93	Moño Mediano	1	7.00
300	158	Moño Mediano	1	7.00
357	188	Moño Mediano	1	7.00
1958	879	Moño Mediano	2	7.00
2334	1032	Moño Mediano	1	7.00
4015	1808	Moño Mediano	2	7.00
4198	1904	Moño Mediano	4	7.00
4245	1933	Moño Mediano	1	7.00
4285	1957	Moño Mediano	1	7.00
2769	1238	Moño Gande	1	8.50
2885	1306	Moño Gande	2	8.50
4140	1875	Moño Gande	3	8.50
4212	1913	Moño Gande	2	8.50
4225	1918	Moño Gande	1	8.50
4257	1941	Moño Gande	2	8.50
4260	1943	Moño Gande	4	8.50
4290	1959	Moño Gande	1	8.50
4875	2258	Moño Gande	1	9.00
5315	2466	Moño Gande	3	9.00
953	447	Papel de Regalo	5	9.00
1034	489	Papel de Regalo	1	9.00
1069	500	Papel de Regalo	4	9.00
1662	761	Papel de Regalo	1	9.00
1959	879	Papel de Regalo	1	9.00
1960	879	Papel de Regalo	2	9.00
2747	1230	Papel de Regalo	2	12.00
2778	1247	Papel de Regalo	2	9.00
2831	1277	Papel de Regalo	2	9.00
2918	1323	Papel de Regalo	3	9.00
2926	1327	Papel de Regalo	2	9.00
3071	1396	Papel de Regalo	1	9.00
3141	1423	Papel de Regalo	1	9.00
3190	1444	Papel de Regalo	1	12.00
3486	1572	Papel de Regalo	1	9.00
3488	1574	Papel de Regalo	4	9.00
3726	1674	Papel de Regalo	1	9.00
3730	1676	Papel de Regalo	2	9.00
3920	1772	Papel de Regalo	2	9.00
4171	1890	Papel de Regalo	2	9.00
4258	1941	Papel de Regalo	1	10.00
4299	1965	Papel de Regalo	1	9.00
4376	2007	Papel de Regalo	2	9.00
4418	2025	Papel de Regalo	2	10.00
4544	2089	Papel de Regalo	3	9.00
4619	2131	Papel de Regalo	2	9.00
4717	2184	Papel de Regalo	2	9.00
5183	2405	Papel de Regalo	1	9.00
5314	2466	Papel de Regalo	9	9.00
5479	2539	Papel de Regalo	4	9.00
5783	2682	Papel de Regalo	2	14.00
5806	2693	Papel de Regalo	2	9.00
5873	2711	Papel de Regalo	1	12.00
5975	2757	Papel de Regalo	3	9.00
6299	2913	Papel de Regalo	1	9.00
6496	3004	Papel de Regalo	2	9.00
6672	3095	Papel de Regalo	2	9.00
6712	3114	Papel de Regalo	4	9.00
7004	3236	Papel de Regalo	3	9.00
7160	3305	Papel de Regalo	1	9.00
7237	3347	Papel de Regalo	2	9.00
7278	3367	Papel de Regalo	3	9.00
7281	3368	Papel de Regalo	1	9.00
7282	3369	Papel de Regalo	1	9.00
174	93	Envoltura	1	15.00
2250	998	Envoltura	2	15.00
2779	1247	Envoltura	1	10.00
2853	1289	Envoltura	2	20.00
3070	1396	Envoltura	1	10.00
3634	1632	Envoltura	1	10.00
3972	1794	Envoltura	1	15.00
3973	1794	Envoltura	2	10.00
4028	1813	Envoltura	1	10.00
4044	1823	Envoltura	1	20.00
4045	1823	Envoltura	1	10.00
4176	1893	Envoltura	3	15.00
4177	1893	Envoltura	4	10.00
4178	1893	Envoltura	1	20.00
4191	1901	Envoltura	2	10.00
4192	1901	Envoltura	3	15.00
4193	1902	Envoltura	2	10.00
4206	1909	Envoltura	5	20.00
4207	1910	Envoltura	1	10.00
4208	1910	Envoltura	1	20.00
4223	1918	Envoltura	1	20.00
4224	1918	Envoltura	1	15.00
4234	1926	Envoltura	1	20.00
4235	1926	Envoltura	1	10.00
177	94	Cinta Diurex	1	15.00
202	106	Cinta Diurex	1	5.00
456	234	Cinta Diurex	1	15.00
605	301	Cinta Diurex	1	15.00
619	308	Cinta Diurex	1	15.00
1047	492	Cinta Diurex	1	5.00
1263	591	Cinta Diurex	1	12.00
1634	745	Cinta Diurex	1	5.00
1658	759	Cinta Diurex	1	5.00
1778	805	Cinta Diurex	1	15.00
1962	879	Cinta Diurex	1	5.00
1974	884	Cinta Diurex	1	15.00
2179	976	Cinta Diurex	1	12.00
2448	1075	Cinta Diurex	1	5.00
2510	1120	Cinta Diurex	1	12.00
2537	1137	Cinta Diurex	1	5.00
2707	1211	Cinta Diurex	1	15.00
2748	1230	Cinta Diurex	1	15.00
2812	1264	Cinta Diurex	1	5.00
3191	1444	Cinta Diurex	1	15.00
3217	1454	Cinta Diurex	1	5.00
3363	1517	Cinta Diurex	2	5.00
3526	1588	Cinta Diurex	1	15.00
3589	1615	Cinta Diurex	1	15.00
3598	1619	Cinta Diurex	1	5.00
3653	1639	Cinta Diurex	1	15.00
3657	1642	Cinta Diurex	1	5.00
3760	1697	Cinta Diurex	1	5.00
3802	1714	Cinta Diurex	1	12.00
3882	1756	Cinta Diurex	1	15.00
3892	1762	Cinta Diurex	3	15.00
4007	1804	Cinta Diurex	1	12.00
4041	1820	Cinta Diurex	1	15.00
4074	1837	Cinta Diurex	1	5.00
4082	1839	Cinta Diurex	1	12.00
4083	1840	Cinta Diurex	1	12.00
4100	1853	Cinta Diurex	2	15.00
4105	1858	Cinta Diurex	1	15.00
4113	1863	Cinta Diurex	1	12.00
4125	1869	Cinta Diurex	1	35.00
4143	1876	Cinta Diurex	1	15.00
4173	1891	Cinta Diurex	1	12.00
4184	1896	Cinta Diurex	1	12.00
4185	1897	Cinta Diurex	1	15.00
4202	1906	Cinta Diurex	1	12.00
4215	1915	Cinta Diurex	1	12.00
4222	1917	Cinta Diurex	1	15.00
4230	1922	Cinta Diurex	1	5.00
4253	1937	Cinta Diurex	1	15.00
4261	1943	Cinta Diurex	1	12.00
4289	1958	Cinta Diurex	1	12.00
4292	1959	Cinta Diurex	1	15.00
4293	1960	Cinta Diurex	2	12.00
4357	1997	Cinta Diurex	1	5.00
4428	2026	Cinta Diurex	1	12.00
4545	2089	Cinta Diurex	2	5.00
4721	2186	Cinta Diurex	1	15.00
4791	2226	Cinta Diurex	1	5.00
5427	2515	Cinta Diurex	1	12.00
5439	2519	Cinta Diurex	1	5.00
5485	2542	Cinta Diurex	1	5.00
5531	2562	Cinta Diurex	1	5.00
5813	2694	Cinta Diurex	1	5.00
5820	2697	Cinta Diurex	1	5.00
5901	2722	Cinta Diurex	1	5.00
5942	2742	Cinta Diurex	1	5.00
6082	2807	Cinta Diurex	2	12.00
6199	2865	Cinta Diurex	1	5.00
6467	2994	Cinta Diurex	1	12.00
6498	3005	Cinta Diurex	1	12.00
6892	3192	Cinta Diurex	1	15.00
7019	3239	Cinta Diurex	1	12.00
7062	3268	Cinta Diurex	1	15.00
7185	3317	Cinta Diurex	1	5.00
7280	3367	Cinta Diurex	1	12.00
180	95	Pluma Gel	1	20.00
382	202	Pluma Gel	2	15.00
429	223	Pluma Gel	1	20.00
775	364	Pluma Gel	1	20.00
827	387	Pluma Gel	1	15.00
906	422	Pluma Gel	1	20.00
1292	600	Pluma Gel	2	15.00
1293	600	Pluma Gel	1	15.00
1296	602	Pluma Gel	2	15.00
2152	965	Pluma Gel	1	15.00
2423	1067	Pluma Gel	1	15.00
2424	1067	Pluma Gel	1	15.00
2951	1339	Pluma Gel	1	20.00
3015	1363	Pluma Gel	1	15.00
3026	1368	Pluma Gel	1	15.00
3027	1368	Pluma Gel	1	15.00
3069	1395	Pluma Gel	1	15.00
3118	1413	Pluma Gel	1	20.00
3150	1429	Pluma Gel	1	15.00
3357	1513	Pluma Gel	1	20.00
3481	1568	Pluma Gel	1	20.00
3718	1670	Pluma Gel	2	20.00
3757	1696	Pluma Gel	1	20.00
4084	1840	Pluma Gel	2	20.00
4594	2117	Pluma Gel	1	20.00
4762	2209	Pluma Gel	1	15.00
5014	2321	Pluma Gel	1	15.00
5466	2533	Pluma Gel	1	15.00
5583	2590	Pluma Gel	1	15.00
5584	2590	Pluma Gel	1	15.00
5647	2618	Pluma Gel	1	15.00
5648	2618	Pluma Gel	1	15.00
5649	2618	Pluma Gel	1	15.00
5997	2770	Pluma Gel	1	15.00
6047	2789	Pluma Gel	1	15.00
6110	2821	Pluma Gel	1	15.00
6334	2931	Pluma Gel	1	15.00
6441	2980	Pluma Gel	1	15.00
6557	3035	Pluma Gel	1	15.00
7123	3287	Pluma Gel	1	15.00
7142	3294	Pluma Gel	2	15.00
7179	3314	Pluma Gel	2	15.00
7217	3335	Pluma Gel	1	15.00
189	99	Acta Nacimiento	1	100.00
3922	1774	Acta Nacimiento	1	100.00
4310	1972	Acta Nacimiento	1	100.00
5993	2767	Acta Nacimiento	2	110.00
6803	3149	Acta Nacimiento	4	110.00
204	107	Pluma P.mediana	1	6.00
310	163	Pluma P.mediana	1	6.00
314	165	Pluma P.mediana	1	6.00
356	188	Pluma P.mediana	1	6.00
390	207	Pluma P.mediana	1	6.00
391	207	Pluma P.mediana	1	6.00
461	237	Pluma P.mediana	1	6.00
550	277	Pluma P.mediana	1	6.00
551	277	Pluma P.mediana	1	6.00
670	327	Pluma P.mediana	1	6.00
671	327	Pluma P.mediana	1	6.00
672	327	Pluma P.mediana	1	6.00
973	459	Pluma P.mediana	1	6.00
1077	503	Pluma P.mediana	1	6.00
1324	617	Pluma P.mediana	1	6.00
1325	617	Pluma P.mediana	1	6.00
1326	617	Pluma P.mediana	1	6.00
1458	672	Pluma P.mediana	1	6.00
1747	792	Pluma P.mediana	1	6.00
1748	792	Pluma P.mediana	1	6.00
1758	795	Pluma P.mediana	1	6.00
1774	803	Pluma P.mediana	1	6.00
1808	819	Pluma P.mediana	2	6.00
1809	819	Pluma P.mediana	2	6.00
1852	832	Pluma P.mediana	1	6.00
1853	832	Pluma P.mediana	1	6.00
1854	832	Pluma P.mediana	1	6.00
2410	1062	Pluma P.mediana	1	6.00
2619	1167	Pluma P.mediana	1	6.00
2750	1231	Pluma P.mediana	1	6.00
2824	1272	Pluma P.mediana	1	6.00
2825	1272	Pluma P.mediana	1	6.00
2864	1296	Pluma P.mediana	1	6.00
2871	1300	Pluma P.mediana	1	6.00
2872	1300	Pluma P.mediana	1	6.00
2914	1321	Pluma P.mediana	1	6.00
3013	1363	Pluma P.mediana	1	6.00
3014	1363	Pluma P.mediana	1	6.00
3068	1395	Pluma P.mediana	1	6.00
3210	1451	Pluma P.mediana	1	7.00
3404	1534	Pluma P.mediana	1	7.00
3405	1534	Pluma P.mediana	1	7.00
3406	1534	Pluma P.mediana	1	7.00
3638	1633	Pluma P.mediana	1	7.00
3639	1633	Pluma P.mediana	1	7.00
3645	1634	Pluma P.mediana	1	7.00
3646	1634	Pluma P.mediana	1	7.00
3647	1634	Pluma P.mediana	1	7.00
3648	1635	Pluma P.mediana	1	7.00
3649	1635	Pluma P.mediana	1	7.00
3719	1670	Pluma P.mediana	2	7.00
3747	1687	Pluma P.mediana	2	7.00
3994	1798	Pluma P.mediana	2	7.00
3995	1798	Pluma P.mediana	2	7.00
4195	1903	Pluma P.mediana	1	7.00
4196	1903	Pluma P.mediana	1	7.00
4365	2003	Pluma P.mediana	1	7.00
4366	2003	Pluma P.mediana	1	7.00
4367	2003	Pluma P.mediana	1	7.00
4452	2037	Pluma P.mediana	1	7.00
4604	2123	Pluma P.mediana	1	7.00
4743	2201	Pluma P.mediana	1	7.00
4744	2201	Pluma P.mediana	1	7.00
4772	2215	Pluma P.mediana	2	7.00
4799	2227	Pluma P.mediana	1	7.00
4833	2237	Pluma P.mediana	1	7.00
4995	2311	Pluma P.mediana	1	7.00
5034	2333	Pluma P.mediana	1	7.00
5118	2374	Pluma P.mediana	1	7.00
5119	2374	Pluma P.mediana	1	7.00
5161	2393	Pluma P.mediana	1	7.00
5206	2415	Pluma P.mediana	1	7.00
5207	2415	Pluma P.mediana	1	7.00
5437	2518	Pluma P.mediana	2	7.00
5438	2518	Pluma P.mediana	2	7.00
5653	2621	Pluma P.mediana	1	7.00
5678	2631	Pluma P.mediana	1	7.00
5734	2654	Pluma P.mediana	1	7.00
5745	2665	Pluma P.mediana	1	7.00
5969	2754	Pluma P.mediana	1	7.00
6114	2824	Pluma P.mediana	1	7.00
6726	3121	Pluma P.mediana	1	7.00
6727	3121	Pluma P.mediana	1	7.00
6831	3163	Pluma P.mediana	2	7.00
7261	3361	Pluma P.mediana	1	7.00
7292	3375	Pluma P.mediana	2	7.00
214	109	Loteria	1	50.00
4111	1861	Loteria	1	50.00
235	121	Loteria	1	38.00
1037	490	Espejitos	1	20.00
1130	533	Espejitos	1	20.00
5408	2507	Espejitos	1	20.00
5699	2639	Espejitos	1	20.00
7153	3302	Espejitos	1	20.00
323	172	Libreta Grande	1	21.00
864	402	Libreta Grande	1	21.00
2189	979	Libreta Grande	1	21.00
2610	1164	Libreta Grande	1	21.00
3358	1513	Libreta Grande	1	21.00
6098	2816	Libreta Grande	1	21.00
7022	3241	Libreta Grande	1	21.00
579	290	Libreta Taquigrafia	1	35.00
1457	672	Libreta Taquigrafia	1	35.00
5259	2437	Libreta Taquigrafia	1	25.00
1706	777	Tarjetita de Regalo	1	2.50
2782	1247	Tarjetita de Regalo	1	2.50
5750	2666	Caja #00	2	5.00
232	120	Pluma P.fino	1	8.00
286	148	Pluma P.fino	1	8.00
326	173	Pluma P.fino	5	8.00
389	207	Pluma P.fino	2	8.00
497	254	Pluma P.fino	1	8.00
498	254	Pluma P.fino	1	8.00
580	290	Pluma P.fino	1	8.00
669	327	Pluma P.fino	1	8.00
853	398	Pluma P.fino	1	8.00
1119	524	Pluma P.fino	1	8.00
1206	569	Pluma P.fino	2	8.00
1365	627	Pluma P.fino	1	8.00
1649	756	Pluma P.fino	1	8.00
1650	756	Pluma P.fino	1	8.00
1651	756	Pluma P.fino	1	8.00
1740	788	Pluma P.fino	1	8.00
1757	795	Pluma P.fino	1	8.00
1834	826	Pluma P.fino	1	8.00
1892	847	Pluma P.fino	1	8.00
1944	871	Pluma P.fino	1	8.00
1964	880	Pluma P.fino	1	8.00
2045	916	Pluma P.fino	1	8.00
2070	928	Pluma P.fino	1	8.00
2108	948	Pluma P.fino	1	8.00
2690	1204	Pluma P.fino	2	8.00
2938	1332	Pluma P.fino	1	8.00
3060	1391	Pluma P.fino	1	8.00
3078	1398	Pluma P.fino	3	8.00
3361	1516	Pluma P.fino	2	9.00
3362	1516	Pluma P.fino	2	9.00
3748	1687	Pluma P.fino	2	9.00
3845	1736	Pluma P.fino	1	9.00
4432	2028	Pluma P.fino	1	9.00
4600	2121	Pluma P.fino	1	9.00
4601	2122	Pluma P.fino	4	9.00
4723	2187	Pluma P.fino	1	9.00
4725	2188	Pluma P.fino	3	9.00
4761	2209	Pluma P.fino	1	9.00
4834	2237	Pluma P.fino	1	9.00
4835	2237	Pluma P.fino	1	9.00
4892	2264	Pluma P.fino	1	9.00
4949	2289	Pluma P.fino	1	9.00
4950	2289	Pluma P.fino	1	9.00
5013	2321	Pluma P.fino	2	9.00
5030	2331	Pluma P.fino	2	9.00
5371	2491	Pluma P.fino	5	9.00
5420	2513	Pluma P.fino	1	9.00
5436	2518	Pluma P.fino	2	9.00
5547	2568	Pluma P.fino	1	9.00
5760	2671	Pluma P.fino	1	9.00
6019	2779	Pluma P.fino	1	9.00
6022	2782	Pluma P.fino	2	9.00
6048	2789	Pluma P.fino	1	9.00
6151	2837	Pluma P.fino	1	9.00
6174	2851	Pluma P.fino	1	9.00
6382	2955	Pluma P.fino	1	9.00
6407	2966	Pluma P.fino	2	9.00
6442	2980	Pluma P.fino	1	9.00
6443	2980	Pluma P.fino	1	9.00
6587	3048	Pluma P.fino	1	9.00
6728	3121	Pluma P.fino	1	9.00
6729	3122	Pluma P.fino	1	9.00
6763	3137	Pluma P.fino	1	9.00
6830	3163	Pluma P.fino	2	9.00
6832	3163	Pluma P.fino	4	9.00
6992	3231	Pluma P.fino	2	9.00
7147	3296	Pluma P.fino	1	9.00
7155	3302	Pluma P.fino	1	9.00
7296	3377	Pluma P.fino	1	9.00
7319	3387	Pluma P.fino	2	9.00
7334	3391	Pluma P.fino	1	9.00
279	145	Pluma Retractil	1	10.00
280	145	Pluma Retractil	1	10.00
418	217	Pluma Retractil	1	10.00
419	217	Pluma Retractil	1	10.00
420	217	Pluma Retractil	1	10.00
825	387	Pluma Retractil	1	10.00
826	387	Pluma Retractil	1	10.00
888	415	Pluma Retractil	1	10.00
1453	669	Pluma Retractil	1	10.00
1741	789	Pluma Retractil	1	10.00
2504	1119	Pluma Retractil	2	10.00
2505	1119	Pluma Retractil	3	10.00
3550	1601	Pluma Retractil	1	12.00
3588	1615	Pluma Retractil	1	12.00
4473	2048	Pluma Retractil	1	12.00
4516	2074	Pluma Retractil	1	12.00
4541	2087	Pluma Retractil	1	12.00
4722	2187	Pluma Retractil	1	12.00
4813	2233	Pluma Retractil	1	15.00
5150	2389	Pluma Retractil	1	12.00
6647	3081	Pluma Retractil	1	12.00
6648	3081	Pluma Retractil	1	12.00
6993	3231	Pluma Retractil	1	12.00
6994	3231	Pluma Retractil	1	12.00
7036	3249	Pluma Retractil	1	12.00
7195	3321	Pluma Retractil	1	12.00
7235	3345	Pluma Retractil	3	12.00
239	124	Marcador Pintarron	5	35.00
972	459	Marcador Pintarron	1	40.00
1531	703	Marcador Pintarron	1	25.00
1598	730	Marcador Pintarron	1	35.00
3656	1642	Marcador Pintarron	1	20.00
4613	2127	Marcador Pintarron	1	40.00
4625	2134	Marcador Pintarron	1	20.00
4643	2144	Marcador Pintarron	1	20.00
6020	2780	Marcador Pintarron	1	25.00
6148	2835	Marcador Pintarron	1	20.00
7180	3315	Marcador Pintarron	2	20.00
7315	3387	Marcador Pintarron	1	20.00
217	110	Marcador Permanente	1	35.00
381	202	Marcador Permanente	1	25.00
523	266	Marcador Permanente	1	25.00
1185	562	Marcador Permanente	1	20.00
1340	624	Marcador Permanente	1	35.00
1760	797	Marcador Permanente	1	20.00
2219	985	Marcador Permanente	1	20.00
2633	1178	Marcador Permanente	1	30.00
2922	1324	Marcador Permanente	2	20.00
3030	1371	Marcador Permanente	1	20.00
3031	1371	Marcador Permanente	1	25.00
3352	1511	Marcador Permanente	1	35.00
3469	1564	Marcador Permanente	1	20.00
3703	1666	Marcador Permanente	1	25.00
3865	1748	Marcador Permanente	1	20.00
3876	1752	Marcador Permanente	1	20.00
3896	1762	Marcador Permanente	1	20.00
4782	2220	Marcador Permanente	1	20.00
5203	2414	Marcador Permanente	1	35.00
6228	2880	Marcador Permanente	1	20.00
6229	2880	Marcador Permanente	1	25.00
6450	2985	Marcador Permanente	1	35.00
6508	3012	Marcador Permanente	2	20.00
7291	3374	Marcador Permanente	1	20.00
7345	3396	Marcador Permanente	2	20.00
3828	1728	Marcador Acrilico	1	70.00
4211	1913	Marcador Acrilico	1	150.00
4829	2237	Marcador Acrilico	1	70.00
5864	2709	Marcador Acrilico	1	70.00
375	199	Marcador P.mediana	1	35.00
730	347	Marcador P.mediana	1	25.00
889	416	Marcador P.mediana	1	25.00
1409	648	Marcador P.mediana	1	35.00
1653	756	Marcador P.mediana	2	35.00
2028	909	Marcador P.mediana	1	35.00
2908	1318	Marcador P.mediana	1	35.00
3205	1449	Marcador P.mediana	1	35.00
3212	1452	Marcador P.mediana	1	25.00
3215	1454	Marcador P.mediana	1	25.00
3692	1659	Marcador P.mediana	1	35.00
3790	1710	Marcador P.mediana	1	25.00
3893	1762	Marcador P.mediana	3	35.00
3894	1762	Marcador P.mediana	2	25.00
3895	1762	Marcador P.mediana	5	25.00
3957	1787	Marcador P.mediana	1	25.00
4046	1824	Marcador P.mediana	1	35.00
5114	2372	Marcador P.mediana	1	35.00
5676	2631	Marcador P.mediana	1	35.00
5765	2675	Marcador P.mediana	2	35.00
5854	2706	Marcador P.mediana	1	35.00
6081	2807	Marcador P.mediana	1	35.00
6376	2951	Marcador P.mediana	1	35.00
6683	3100	Marcador P.mediana	2	25.00
6770	3141	Marcador P.mediana	1	30.00
6846	3166	Marcador P.mediana	1	35.00
997	469	Marcador Doble Punta	1	25.00
1373	632	Marcador Doble Punta	1	25.00
5900	2721	Marcador Doble Punta	1	25.00
5906	2724	Marcador Doble Punta	1	25.00
6088	2809	Marcador Doble Punta	1	25.00
6273	2901	Marcador Doble Punta	1	25.00
6639	3078	Marcador Doble Punta	1	25.00
7094	3279	Marcador Doble Punta	1	45.00
487	248	Rotulador	1	15.00
2017	904	Rotulador	1	15.00
5595	2596	Rotulador	1	15.00
1812	819	Lapiz de Puntilla	1	15.00
2198	982	Lapiz de Puntilla	1	15.00
3496	1580	Lapiz de Puntilla	1	15.00
3624	1629	Lapiz de Puntilla	1	15.00
3768	1701	Lapiz de Puntilla	1	15.00
5650	2619	Lapiz de Puntilla	1	15.00
5655	2622	Lapiz de Puntilla	1	15.00
6207	2871	Lapiz de Puntilla	1	15.00
1591	726	Marcatexto	1	20.00
2768	1237	Marcatexto	1	20.00
3045	1382	Marcatexto	1	20.00
4567	2103	Marcatexto	1	20.00
4968	2298	Marcatexto	1	20.00
5713	2644	Marcatexto	1	15.00
6246	2885	Marcatexto	1	20.00
6563	3037	Marcatexto	3	20.00
7236	3346	Marcatexto	1	20.00
3615	1627	Marcador de Cera	1	20.00
3410	1537	Lapiz Rojo	1	10.00
5006	2318	Lapiz Rojo	1	10.00
7126	3289	Lapiz Rojo	2	10.00
1298	603	Lapiz Duo	1	10.00
1603	733	Lapiz Duo	2	10.00
2201	983	Lapiz Duo	2	20.00
2283	1017	Lapiz Duo	8	10.00
3100	1407	Lapiz Duo	3	10.00
4520	2077	Lapiz Duo	1	10.00
5716	2645	Lapiz Duo	1	10.00
5826	2698	Lapiz Duo	1	10.00
6354	2938	Lapiz Duo	2	10.00
6632	3074	Lapiz Duo	1	10.00
435	224	Bicolor	1	10.00
4465	2045	Bicolor	2	10.00
4779	2217	Bicolor	1	10.00
4490	2060	Lapiz Entrenador	1	20.00
7110	3282	Lapiz Entrenador	1	20.00
3924	1775	Color Blanco	1	15.00
4415	2023	Detector de Billete	1	35.00
1219	575	Abatelengua	2	0.75
1881	839	Abatelengua	6	0.75
3606	1622	Abatelengua	4	0.75
4122	1868	Abatelengua	4	0.75
4607	2125	Abatelengua	6	0.75
4665	2156	Abatelengua	30	0.75
4984	2307	Abatelengua	10	0.75
5022	2326	Abatelengua	12	0.75
5042	2339	Lapiz Infinito	1	20.00
5392	2501	Lapiz Infinito	1	20.00
5141	2385	Canicas	1	20.00
5554	2573	Canicas	1	20.00
5505	2550	Alambre	1	25.00
1172	559	Etiqueta	1	5.00
2014	904	Etiqueta	2	5.00
431	223	Pluma Decorada	1	20.00
1250	586	Pluma Decorada	1	20.00
2946	1337	Pluma Decorada	1	20.00
3524	1587	Pluma Decorada	1	20.00
5945	2743	Pluma Decorada	1	20.00
6837	3165	Pluma Decorada	1	20.00
507	260	Pluma C/ 4 Colores	1	25.00
1374	632	Pluma C/ 4 Colores	1	25.00
1992	894	Pluma C/ 4 Colores	1	25.00
2068	928	Pluma C/ 4 Colores	1	25.00
2682	1201	Pluma C/ 4 Colores	1	25.00
4506	2070	Pluma C/ 4 Colores	1	25.00
4509	2073	Pluma C/ 4 Colores	1	50.00
4579	2109	Pluma C/ 4 Colores	1	25.00
4751	2205	Pluma C/ 4 Colores	1	25.00
4996	2312	Pluma C/ 4 Colores	1	25.00
6836	3165	Pluma C/ 4 Colores	1	25.00
6146	2834	Pluma Borrable	1	15.00
287	148	Sellitos	1	12.00
394	208	Sellitos	1	12.00
486	247	Sellitos	1	12.00
511	262	Sellitos	1	12.00
520	265	Sellitos	1	12.00
608	304	Sellitos	1	12.00
625	311	Sellitos	1	12.00
863	401	Sellitos	2	12.00
881	410	Sellitos	1	12.00
1216	574	Sellitos	1	12.00
1431	657	Sellitos	1	12.00
1841	829	Sellitos	1	12.00
2001	899	Sellitos	1	12.00
2305	1023	Sellitos	1	12.00
2957	1342	Sellitos	1	12.00
3308	1492	Sellitos	1	12.00
3497	1580	Sellitos	1	12.00
4180	1894	Sellitos	1	12.00
4571	2105	Sellitos	1	12.00
4676	2163	Sellitos	1	12.00
5409	2507	Sellitos	1	12.00
6269	2898	Sellitos	3	12.00
6325	2926	Sellitos	1	12.00
6405	2966	Sellitos	2	12.00
6634	3076	Sellitos	6	12.00
6667	3093	Sellitos	1	12.00
6986	3228	Sellitos	1	12.00
6997	3232	Sellitos	1	12.00
7115	3282	Sellitos	4	12.00
7169	3310	Sellitos	1	12.00
7262	3362	Sellitos	1	12.00
569	284	Juego	1	55.00
4323	1981	Juego	1	45.00
4666	2157	Juego	1	35.00
5950	2746	Juego	1	25.00
7299	3378	Juego	1	60.00
3187	1442	Lego	1	25.00
3725	1674	Lego	1	25.00
424	220	Vela Chica	1	20.00
2839	1281	Vela Chica	1	20.00
6445	2982	Vela Chica	1	20.00
543	275	Globo Metalico	2	25.00
593	298	Globo Metalico	1	20.00
2945	1336	Globo Metalico	2	35.00
6962	3219	Globo Metalico	3	35.00
275	144	Pelota	1	14.00
576	287	Pelota	2	14.00
647	314	Pelota	1	14.00
844	397	Pelota	1	14.00
914	426	Pelota	2	14.00
940	442	Pelota	2	14.00
1208	571	Pelota	2	14.00
1449	667	Pelota	1	14.00
3249	1469	Pelota	2	14.00
3842	1734	Pelota	1	15.00
4574	2106	Pelota	3	13.00
6412	2967	Pelota	1	15.00
6526	3022	Pelota	2	15.00
7211	3331	Pelota	1	15.00
6215	2874	Memorama	1	40.00
6720	3118	Memorama	1	40.00
946	443	Dibujo C/Acuarela	1	10.00
1405	645	Dibujo C/Acuarela	1	10.00
1534	705	Dibujo C/Acuarela	1	10.00
533	271	Valerina	1	15.00
5396	2504	Valerina	2	15.00
5832	2701	Valerina	1	15.00
6130	2829	Valerina	2	15.00
6411	2967	Valerina	2	15.00
6537	3025	Valerina	1	15.00
6733	3123	Valerina	1	15.00
7177	3314	Valerina	2	15.00
1166	556	Juego de Lapiz	1	75.00
5951	2746	Juego de Lapiz	1	50.00
3889	1760	Llaveros	1	35.00
6604	3055	Caja #0	1	7.00
6764	3138	Caja #0	5	7.00
1635	745	Caja #1	1	8.00
765	357	Caja #9	1	25.00
3710	1667	Caja #9	1	25.00
1914	854	Caja #10	1	25.00
3883	1757	Caja #11	1	25.00
1312	612	Caja #26	1	25.00
3691	1659	Caja #24	1	20.00
4359	1999	Caja #24	1	20.00
3126	1418	Caja #pm	2	30.00
3129	1419	Caja #pm	2	30.00
5884	2716	Caja #p	1	35.00
1311	611	Caja #c	1	45.00
3125	1418	Caja #c	6	45.00
3128	1419	Caja #c	6	45.00
7333	3391	Huevos Pascua	1	45.00
1063	497	Lima de Uñas	2	15.00
3051	1385	Lima de Uñas	1	15.00
2561	1145	Bolsa de Papel	2	9.00
437	225	Cortina	1	35.00
447	230	Cortina	1	35.00
485	247	Cortina	1	35.00
618	308	Cortina	1	35.00
912	425	Cortina	1	35.00
995	468	Cortina	1	35.00
1040	491	Cortina	1	35.00
1168	557	Cortina	1	35.00
2550	1141	Cortina	1	35.00
2929	1327	Cortina	1	35.00
3263	1472	Cortina	3	35.00
3774	1702	Cortina	1	35.00
4347	1992	Cortina	1	35.00
4456	2039	Cortina	1	35.00
5416	2512	Cortina	1	35.00
6364	2944	Cortina	1	35.00
6559	3036	Cortina	1	35.00
7269	3364	Cortina	1	35.00
1240	583	Fomy Moldeable	1	24.00
1494	688	Fomy Moldeable	1	29.00
1495	688	Fomy Moldeable	1	24.00
1695	773	Fomy Moldeable	1	24.00
1876	836	Fomy Moldeable	1	29.00
3251	1470	Fomy Moldeable	1	29.00
4748	2205	Fomy Moldeable	1	29.00
5219	2422	Fomy Moldeable	1	29.00
6068	2802	Fomy Moldeable	1	29.00
6111	2822	Fomy Moldeable	1	29.00
1404	645	Billetes	1	15.00
1502	690	Billetes	1	15.00
2419	1063	Billetes	1	15.00
513	264	Bolsa Celofan	5	2.50
535	272	Bolsa Celofan	1	4.50
788	368	Bolsa Celofan	6	4.50
803	376	Bolsa Celofan	2	2.00
1638	747	Bolsa Celofan	4	12.00
2055	921	Bolsa Celofan	10	6.00
2712	1214	Bolsa Celofan	1	15.00
3113	1412	Bolsa Celofan	6	2.50
3533	1593	Bolsa Celofan	25	1.00
3581	1612	Bolsa Celofan	5	4.50
3582	1612	Bolsa Celofan	5	2.50
3604	1621	Bolsa Celofan	1	2.50
3779	1705	Bolsa Celofan	1	15.00
3834	1731	Bolsa Celofan	1	18.00
3862	1745	Bolsa Celofan	1	6.00
3940	1781	Bolsa Celofan	10	2.50
3954	1787	Bolsa Celofan	20	2.00
3958	1788	Bolsa Celofan	5	4.50
3959	1788	Bolsa Celofan	2	8.00
4049	1825	Bolsa Celofan	1	2.50
4068	1834	Bolsa Celofan	15	4.50
4078	1838	Bolsa Celofan	10	1.50
4107	1860	Bolsa Celofan	1	18.00
4164	1887	Bolsa Celofan	5	7.00
4165	1888	Bolsa Celofan	10	7.00
4167	1888	Bolsa Celofan	5	6.00
4216	1916	Bolsa Celofan	10	2.50
4255	1939	Bolsa Celofan	1	12.00
4919	2276	Bolsa Celofan	20	1.50
4943	2287	Bolsa Celofan	10	1.50
5103	2366	Bolsa Celofan	1	1.50
5322	2470	Bolsa Celofan	4	1.50
5425	2515	Bolsa Celofan	1	18.00
5426	2515	Bolsa Celofan	2	4.50
5827	2699	Bolsa Celofan	12	1.50
5828	2699	Bolsa Celofan	2	2.00
5834	2702	Bolsa Celofan	4	2.50
5839	2703	Bolsa Celofan	5	2.50
5855	2707	Bolsa Celofan	1	8.00
5868	2710	Bolsa Celofan	5	1.50
6747	3128	Bolsa Celofan	5	8.00
1366	628	Broche Gafet	1	25.00
2084	934	Broche Gafet	1	25.00
5327	2472	Broche Gafet	1	25.00
5481	2541	Broche Gafet	1	25.00
1062	497	Borrador Figura	3	10.00
7113	3282	Borrador Figura	4	10.00
3658	1643	Helicoptero	1	15.00
944	442	Carrito Retractil	1	15.00
333	177	Manitas	1	5.00
1704	777	Manitas	1	5.00
2647	1183	Manitas	2	5.00
2836	1279	Manitas	1	5.00
6635	3076	Manitas	4	5.00
7189	3318	Manitas	10	5.00
2887	1307	Dona Niña	2	10.00
2921	1323	Dona Niña	2	10.00
4592	2115	Dona Niña	1	10.00
5802	2691	Dona Niña	1	10.00
1859	834	Chinchitas P/Cabello	1	12.00
3976	1795	Chinchitas P/Cabello	2	12.00
1025	484	Dona P/Cabello	1	15.00
2408	1062	Dona P/Cabello	1	15.00
5803	2691	Dona P/Cabello	1	15.00
4973	2300	Prendedor P/Cabello	1	20.00
2420	1064	Pestaña	1	20.00
3664	1647	Pestaña	1	20.00
2587	1151	Palo Brocheta	4	1.00
4095	1848	Palo Brocheta	20	1.00
4121	1868	Palo Brocheta	9	1.00
6261	2893	Palo Brocheta	1	1.00
321	171	Palo Brocheta	4	1.50
1196	564	Palo Brocheta	2	1.50
1507	691	Palo Brocheta	2	1.50
1682	769	Palo Brocheta	4	1.50
1717	782	Palo Brocheta	2	2.00
1728	784	Palo Brocheta	2	1.50
1766	799	Palo Brocheta	2	1.50
1796	816	Palo Brocheta	2	1.50
2023	906	Palo Brocheta	12	1.50
5100	2365	Palo Brocheta	2	2.00
5101	2365	Palo Brocheta	2	1.50
5671	2628	Palo Brocheta	2	1.50
5782	2682	Palo Brocheta	15	2.00
5838	2703	Palo Brocheta	5	1.50
7017	3239	Palo Brocheta	4	2.00
322	171	Palo Aplicador	4	0.75
1345	625	Palo Aplicador	10	0.75
545	275	Palo para Globo	2	1.50
365	195	Palo	6	1.50
839	394	Palo	1	2.00
1103	517	Palo	3	1.50
1104	517	Palo	4	4.50
1105	517	Palo	3	1.00
1262	591	Palo	4	1.50
1283	597	Palo	2	2.00
1526	700	Palo	3	1.50
1546	710	Palo	1	2.00
1547	710	Palo	1	4.50
1548	710	Palo	1	3.00
1718	782	Palo	1	1.50
1735	785	Palo	2	1.50
1771	802	Palo	1	4.50
1772	802	Palo	2	4.50
1945	872	Palo	1	1.50
2239	994	Palo	2	1.50
2240	994	Palo	2	4.50
2275	1013	Palo	1	1.50
2379	1051	Palo	3	1.00
2582	1150	Palo	4	3.00
2879	1305	Palo	2	1.50
3119	1414	Palo	4	4.50
3120	1415	Palo	4	4.50
3275	1475	Palo	4	0.50
3575	1610	Palo	1	3.00
3607	1622	Palo	2	4.50
3610	1624	Palo	1	4.50
4578	2108	Palo	10	1.50
4658	2151	Palo	4	1.50
5155	2392	Palo	4	1.00
5296	2455	Palo	5	0.50
5537	2565	Palo	2	1.00
5980	2760	Palo	2	4.50
5990	2764	Palo	20	0.50
6050	2790	Palo	1	1.00
6069	2802	Palo	2	1.00
6112	2823	Palo	1	1.00
6466	2994	Palo	10	1.00
6489	3002	Palo	1	0.50
6515	3016	Palo	2	1.00
6516	3017	Palo	14	0.50
6651	3084	Palo	10	0.50
6923	3204	Palo	6	1.00
7018	3239	Palo	6	1.00
603	300	Moño Magico	1	10.00
1088	506	Moño Magico	1	4.00
1256	588	Moño Magico	1	20.00
1664	761	Moño Magico	1	10.00
1973	884	Moño Magico	1	20.00
2715	1214	Moño Magico	1	20.00
2777	1246	Moño Magico	1	7.00
2780	1247	Moño Magico	1	20.00
3140	1423	Moño Magico	1	7.00
3414	1540	Moño Magico	1	8.00
3420	1544	Moño Magico	1	8.00
3507	1583	Moño Magico	1	20.00
3539	1596	Moño Magico	1	28.00
3540	1596	Moño Magico	1	7.00
3580	1612	Moño Magico	10	4.00
3635	1632	Moño Magico	1	8.00
3697	1661	Moño Magico	1	8.00
3705	1667	Moño Magico	1	4.00
3712	1667	Moño Magico	1	7.00
3735	1678	Moño Magico	1	17.00
3775	1702	Moño Magico	1	6.00
3835	1731	Moño Magico	1	20.00
3887	1759	Moño Magico	1	20.00
3901	1763	Moño Magico	1	10.00
3962	1788	Moño Magico	1	8.00
3980	1796	Moño Magico	1	10.00
4008	1804	Moño Magico	2	6.00
4009	1804	Moño Magico	1	4.00
4072	1836	Moño Magico	1	7.00
4135	1873	Moño Magico	5	7.00
4141	1876	Moño Magico	10	7.00
4142	1876	Moño Magico	2	8.00
4166	1888	Moño Magico	4	7.00
4217	1916	Moño Magico	4	8.00
4240	1931	Moño Magico	1	17.00
4246	1933	Moño Magico	2	10.00
4248	1933	Moño Magico	1	6.00
4254	1938	Moño Magico	2	4.00
4264	1944	Moño Magico	4	7.00
4268	1946	Moño Magico	1	20.00
4276	1950	Moño Magico	4	10.00
4280	1954	Moño Magico	2	17.00
4283	1956	Moño Magico	1	20.00
4284	1957	Moño Magico	1	20.00
4286	1958	Moño Magico	2	8.00
4300	1965	Moño Magico	1	20.00
4315	1975	Moño Magico	1	20.00
4354	1995	Moño Magico	2	4.00
4361	1999	Moño Magico	1	20.00
4372	2005	Moño Magico	1	20.00
4389	2012	Moño Magico	1	20.00
4427	2026	Moño Magico	1	20.00
4620	2131	Moño Magico	1	6.00
4712	2183	Moño Magico	1	20.00
5484	2542	Moño Magico	1	20.00
5899	2721	Moño Magico	1	20.00
6216	2874	Moño Magico	1	4.00
6332	2930	Moño Magico	1	7.00
6603	3055	Moño Magico	1	7.00
7003	3236	Moño Magico	1	20.00
7161	3305	Moño Magico	1	8.00
7279	3367	Moño Magico	1	20.00
7306	3380	Moño Magico	1	28.00
7307	3380	Moño Magico	1	8.00
329	175	Curp	1	15.00
378	201	Curp	1	10.00
563	282	Curp	1	15.00
582	292	Curp	1	15.00
660	322	Curp	3	10.00
704	340	Curp	1	15.00
753	354	Curp	1	15.00
1128	532	Curp	1	15.00
2851	1288	Curp	1	10.00
2898	1313	Curp	1	15.00
2904	1316	Curp	1	15.00
3435	1551	Curp	4	10.00
3485	1571	Curp	1	10.00
3545	1600	Curp	1	15.00
3923	1774	Curp	1	10.00
4345	1991	Curp	2	10.00
4680	2166	Curp	1	10.00
5213	2419	Curp	2	10.00
5365	2489	Curp	2	10.00
5545	2567	Curp	1	10.00
5796	2689	Curp	2	15.00
5804	2692	Curp	1	10.00
5953	2747	Curp	1	15.00
6189	2863	Curp	1	15.00
6802	3149	Curp	4	20.00
7208	3330	Curp	1	20.00
801	374	Sacapuntas	1	5.00
2299	1022	Sacapuntas	1	10.00
2613	1165	Sacapuntas	1	5.00
2749	1230	Sacapuntas	1	5.00
2826	1272	Sacapuntas	2	7.00
3061	1391	Sacapuntas	2	5.00
3211	1451	Sacapuntas	1	10.00
4894	2264	Sacapuntas	1	10.00
4963	2294	Sacapuntas	2	10.00
5253	2435	Sacapuntas	2	5.00
5393	2502	Sacapuntas	2	5.00
5421	2514	Sacapuntas	1	5.00
5422	2514	Sacapuntas	1	10.00
5599	2597	Sacapuntas	1	7.00
6404	2966	Sacapuntas	2	5.00
6619	3065	Sacapuntas	1	10.00
6806	3150	Sacapuntas	1	5.00
6814	3154	Sacapuntas	1	10.00
6829	3162	Sacapuntas	2	5.00
6955	3217	Sacapuntas	1	10.00
6956	3217	Sacapuntas	1	10.00
7026	3244	Sacapuntas	1	5.00
7343	3396	Sacapuntas	1	5.00
7344	3396	Sacapuntas	1	10.00
436	225	Globo Numero	2	20.00
1042	491	Globo Numero	1	20.00
1680	769	Globo Numero	1	30.00
2464	1084	Globo Numero	1	20.00
3266	1472	Globo Numero	2	20.00
6154	2839	Globo Numero	1	30.00
6469	2996	Abaco	1	45.00
6565	3037	Abaco	1	45.00
1768	800	Tangram	1	30.00
4006	1803	Tangram	1	25.00
1993	895	Marcador Agua	1	50.00
3347	1509	Marcador Agua	1	45.00
6230	2880	Marcador Agua	2	35.00
6339	2933	Marcador Agua	1	55.00
6838	3165	Marcador Agua	1	45.00
6839	3165	Marcador Agua	1	53.00
3871	1751	Mantel	1	35.00
1905	852	Liga para Cabello	1	15.00
2051	920	Liga para Cabello	2	15.00
2521	1128	Liga para Cabello	1	15.00
2803	1257	Liga para Cabello	1	15.00
2953	1340	Liga para Cabello	1	15.00
2975	1349	Liga para Cabello	1	15.00
4637	2141	Liga para Cabello	1	15.00
5376	2493	Liga para Cabello	1	15.00
7007	3237	Liga para Cabello	1	15.00
7141	3293	Liga para Cabello	1	15.00
1303	604	Tijera	1	26.00
1830	825	Tijera	1	28.00
2443	1074	Tijera	1	70.00
2841	1282	Tijera	1	45.00
3273	1474	Tijera	1	28.00
3493	1577	Tijera	1	28.00
3929	1776	Tijera	1	35.00
5046	2340	Tijera	1	45.00
6366	2946	Tijera	1	35.00
6840	3165	Tijera	1	35.00
7000	3234	Tijera	1	35.00
7203	3326	Tijera	1	35.00
7341	3396	Tijera	1	35.00
6659	3088	Kola Loca	1	40.00
6710	3112	Kola Loca	1	40.00
804	377	Libreta	1	15.00
2632	1177	Libreta	1	26.00
2915	1321	Libreta	1	26.00
2937	1332	Libreta	1	15.00
4085	1840	Libreta	1	26.00
4673	2162	Libreta	1	45.00
4691	2172	Libreta	1	26.00
5325	2472	Libreta	1	26.00
5754	2668	Libreta	1	25.00
6835	3165	Libreta	1	45.00
7146	3296	Libreta	1	15.00
3293	1486	Cincho	1	20.00
3367	1519	Cincho	1	20.00
3222	1457	Cincho	1	25.00
7259	3359	Cincho	1	25.00
517	264	Perforadora de Mano	1	45.00
2297	1021	Perforadora de Mano	1	45.00
5111	2371	Perforadora de Mano	1	40.00
2693	1206	Usb	1	130.00
1884	841	Perforadora Doble	1	55.00
6984	3228	Perforadora Doble	1	80.00
477	245	Pintura Politec 100 Ml.	1	50.00
492	251	Pintura Politec 100 Ml.	1	50.00
527	269	Pintura Politec 100 Ml.	2	50.00
978	463	Pintura Politec 100 Ml.	1	55.00
1112	521	Pintura Politec 100 Ml.	1	55.00
1181	561	Pintura Politec 100 Ml.	1	55.00
1868	836	Pintura Politec 100 Ml.	1	55.00
2182	977	Pintura Politec 100 Ml.	1	55.00
4067	1834	Pintura Politec 100 Ml.	4	55.00
4251	1936	Pintura Politec 100 Ml.	1	55.00
4937	2285	Pintura Politec 100 Ml.	1	55.00
5643	2617	Pintura Politec 100 Ml.	2	55.00
5872	2711	Pintura Politec 100 Ml.	1	55.00
6703	3107	Pintura Politec 100 Ml.	1	55.00
7270	3364	Vela Larga	1	20.00
793	370	Estuche	1	30.00
7308	3381	Liga #18	1	15.00
4624	2133	Bomba C/Valvula	1	45.00
1949	874	Bomba P/Globo	1	45.00
1702	777	Set de Papeleria	1	110.00
4147	1878	Mini Inertia	1	40.00
1060	497	Cartera	1	40.00
383	203	Papel Kraf	1	17.00
616	306	Papel Kraf	1	17.00
1633	745	Papel Kraf	1	17.00
3019	1367	Papel Kraf	1	17.00
3885	1759	Papel Kraf	5	17.00
3904	1764	Papel Kraf	1	17.00
4226	1919	Papel Kraf	1	17.00
5681	2633	Papel Kraf	1	17.00
5970	2755	Papel Kraf	1	17.00
6044	2788	Papel Kraf	1	17.00
6254	2889	Papel Kraf	1	17.00
6440	2980	Papel Kraf	2	17.00
6963	3220	Papel Kraf	1	17.00
7192	3320	Papel Kraf	1	17.00
481	247	Fomy T/Carta Diamantado	2	9.00
482	247	Fomy T/Carta Diamantado	2	9.00
483	247	Fomy T/Carta Diamantado	2	9.00
539	272	Fomy T/Carta Diamantado	1	9.00
557	279	Fomy T/Carta Diamantado	3	9.00
712	344	Fomy T/Carta Diamantado	1	9.00
722	347	Fomy T/Carta Diamantado	1	9.00
723	347	Fomy T/Carta Diamantado	1	9.00
724	347	Fomy T/Carta Diamantado	1	9.00
725	347	Fomy T/Carta Diamantado	1	9.00
726	347	Fomy T/Carta Diamantado	1	9.00
1124	528	Fomy T/Carta Diamantado	3	9.00
1156	549	Fomy T/Carta Diamantado	1	9.00
1319	615	Fomy T/Carta Diamantado	4	9.00
1320	615	Fomy T/Carta Diamantado	3	9.00
1321	615	Fomy T/Carta Diamantado	3	9.00
1344	625	Fomy T/Carta Diamantado	1	9.00
1477	682	Fomy T/Carta Diamantado	1	9.00
1496	688	Fomy T/Carta Diamantado	1	9.00
1497	688	Fomy T/Carta Diamantado	1	9.00
1498	688	Fomy T/Carta Diamantado	1	9.00
1499	688	Fomy T/Carta Diamantado	1	9.00
1500	688	Fomy T/Carta Diamantado	1	9.00
1686	772	Fomy T/Carta Diamantado	2	9.00
1693	773	Fomy T/Carta Diamantado	1	9.00
1820	823	Fomy T/Carta Diamantado	1	9.00
1821	823	Fomy T/Carta Diamantado	1	9.00
1822	823	Fomy T/Carta Diamantado	1	9.00
1946	872	Fomy T/Carta Diamantado	1	9.00
2037	913	Fomy T/Carta Diamantado	1	9.00
2038	913	Fomy T/Carta Diamantado	1	9.00
2124	958	Fomy T/Carta Diamantado	1	9.00
2158	967	Fomy T/Carta Diamantado	3	9.00
2193	981	Fomy T/Carta Diamantado	1	9.00
2236	993	Fomy T/Carta Diamantado	1	9.00
2237	993	Fomy T/Carta Diamantado	1	9.00
2435	1071	Fomy T/Carta Diamantado	3	9.00
2555	1143	Fomy T/Carta Diamantado	3	9.00
2802	1257	Fomy T/Carta Diamantado	1	9.00
2842	1282	Fomy T/Carta Diamantado	1	9.00
3008	1359	Fomy T/Carta Diamantado	1	9.00
3139	1422	Fomy T/Carta Diamantado	2	9.00
3154	1431	Fomy T/Carta Diamantado	2	9.00
3253	1471	Fomy T/Carta Diamantado	1	9.00
3254	1471	Fomy T/Carta Diamantado	1	9.00
3353	1512	Fomy T/Carta Diamantado	1	9.00
3354	1512	Fomy T/Carta Diamantado	1	9.00
3474	1568	Fomy T/Carta Diamantado	1	9.00
3475	1568	Fomy T/Carta Diamantado	1	9.00
3476	1568	Fomy T/Carta Diamantado	1	9.00
3502	1581	Fomy T/Carta Diamantado	1	8.00
3503	1581	Fomy T/Carta Diamantado	1	9.00
3527	1589	Fomy T/Carta Diamantado	1	9.00
3555	1603	Fomy T/Carta Diamantado	1	9.00
3579	1611	Fomy T/Carta Diamantado	2	9.00
3583	1613	Fomy T/Carta Diamantado	1	9.00
3584	1613	Fomy T/Carta Diamantado	2	9.00
3593	1617	Fomy T/Carta Diamantado	2	9.00
3597	1619	Fomy T/Carta Diamantado	1	9.00
3858	1744	Fomy T/Carta Diamantado	1	9.00
3918	1771	Fomy T/Carta Diamantado	1	9.00
3919	1771	Fomy T/Carta Diamantado	1	9.00
3965	1789	Fomy T/Carta Diamantado	1	9.00
4093	1846	Fomy T/Carta Diamantado	1	9.00
4653	2147	Fomy T/Carta Diamantado	1	9.00
4660	2153	Fomy T/Carta Diamantado	1	9.00
4661	2153	Fomy T/Carta Diamantado	1	9.00
4662	2153	Fomy T/Carta Diamantado	1	9.00
5086	2356	Fomy T/Carta Diamantado	1	9.00
5131	2378	Fomy T/Carta Diamantado	3	9.00
5165	2394	Fomy T/Carta Diamantado	1	9.00
5184	2406	Fomy T/Carta Diamantado	2	9.00
5389	2500	Fomy T/Carta Diamantado	1	9.00
5390	2500	Fomy T/Carta Diamantado	1	9.00
5391	2500	Fomy T/Carta Diamantado	1	9.00
5454	2526	Fomy T/Carta Diamantado	2	9.00
5455	2526	Fomy T/Carta Diamantado	1	9.00
5456	2526	Fomy T/Carta Diamantado	1	9.00
5457	2526	Fomy T/Carta Diamantado	2	9.00
5507	2550	Fomy T/Carta Diamantado	1	9.00
5512	2552	Fomy T/Carta Diamantado	1	9.00
5513	2552	Fomy T/Carta Diamantado	1	9.00
5514	2552	Fomy T/Carta Diamantado	1	9.00
5539	2566	Fomy T/Carta Diamantado	1	9.00
5540	2566	Fomy T/Carta Diamantado	3	9.00
5541	2566	Fomy T/Carta Diamantado	1	9.00
5549	2570	Fomy T/Carta Diamantado	1	9.00
5665	2626	Fomy T/Carta Diamantado	2	9.00
5727	2652	Fomy T/Carta Diamantado	2	9.00
5739	2659	Fomy T/Carta Diamantado	1	9.00
6462	2992	Fomy T/Carta Diamantado	1	9.00
6511	3015	Fomy T/Carta Diamantado	1	9.00
6512	3015	Fomy T/Carta Diamantado	1	9.00
6698	3106	Fomy T/Carta Diamantado	2	9.00
6699	3106	Fomy T/Carta Diamantado	2	9.00
6700	3106	Fomy T/Carta Diamantado	2	9.00
6702	3107	Fomy T/Carta Diamantado	3	9.00
6781	3143	Fomy T/Carta Diamantado	1	9.00
6782	3143	Fomy T/Carta Diamantado	1	9.00
6785	3143	Fomy T/Carta Diamantado	1	9.00
6949	3215	Fomy T/Carta Diamantado	4	9.00
6991	3230	Fomy T/Carta Diamantado	1	9.00
7175	3314	Fomy T/Carta Diamantado	1	9.00
7176	3314	Fomy T/Carta Diamantado	1	9.00
3866	1749	Portaretratos	1	60.00
5771	2678	Portaretratos	1	60.00
3520	1585	Audifonos	1	45.00
6359	2941	Audifonos	1	55.00
2594	1155	Baraja Poker	1	35.00
2795	1254	Baraja Poker	1	35.00
3756	1695	Cargador	1	80.00
1951	876	Cargador	1	70.00
1341	624	Cablep/Iphone	1	50.00
740	350	Bolitas para Pelo	1	35.00
422	219	Set de Pulsera	1	40.00
1823	823	Set de Pulsera	1	30.00
4157	1882	Set de Pulsera	1	40.00
4394	2013	Pulsera	1	30.00
2344	1037	Diadema	1	15.00
2425	1068	Diadema	2	15.00
2499	1117	Diadema	1	15.00
2531	1134	Diadema	2	15.00
3592	1617	Diadema	1	15.00
454	233	Cuerda	1	18.00
1011	475	Cuerda	1	18.00
2917	1323	Cuerda	1	35.00
1801	817	Sacapuntas C/Contenedor	1	15.00
2340	1036	Sacapuntas C/Contenedor	1	30.00
2806	1260	Sacapuntas C/Contenedor	1	15.00
2977	1350	Sacapuntas C/Contenedor	1	30.00
3161	1434	Sacapuntas C/Contenedor	1	25.00
3546	1600	Sacapuntas C/Contenedor	1	15.00
3770	1701	Sacapuntas C/Contenedor	1	15.00
4492	2060	Sacapuntas C/Contenedor	1	35.00
4511	2073	Sacapuntas C/Contenedor	1	35.00
4706	2180	Sacapuntas C/Contenedor	1	30.00
4831	2237	Sacapuntas C/Contenedor	1	35.00
4858	2248	Sacapuntas C/Contenedor	2	15.00
5134	2379	Sacapuntas C/Contenedor	1	35.00
5225	2422	Sacapuntas C/Contenedor	1	15.00
5498	2549	Sacapuntas C/Contenedor	1	35.00
7112	3282	Sacapuntas C/Contenedor	1	15.00
7321	3388	Sacapuntas C/Contenedor	1	35.00
6952	3215	Sacapuntas	1	18.00
7111	3282	Sacapuntas	2	18.00
1091	506	Cinta Decorativa	1	8.00
1160	550	Cinta Decorativa	1	8.00
1210	573	Cinta Decorativa	1	8.00
2178	975	Cinta Decorativa	1	8.00
3426	1545	Cinta Decorativa	2	8.00
3941	1781	Cinta Decorativa	2	8.00
4055	1828	Cinta Decorativa	1	8.00
4532	2083	Cinta Decorativa	4	8.00
5087	2356	Cinta Decorativa	1	8.00
6532	3023	Cinta Decorativa	1	8.00
6744	3126	Cinta Decorativa	1	8.00
7116	3282	Cinta Decorativa	1	8.00
7174	3314	Cinta Decorativa	1	8.00
1777	805	Sobre Doble Carta	3	15.00
6920	3201	Sobre Doble Carta	1	15.00
898	420	Cascaron Huevo	1	20.00
1006	473	Cascaron Huevo	1	10.00
1234	581	Cascaron Huevo	1	20.00
1367	629	Cascaron Huevo	1	10.00
1377	633	Cascaron Huevo	2	40.00
1419	652	Cascaron Huevo	1	20.00
1420	652	Cascaron Huevo	1	10.00
1891	846	Cascaron Huevo	2	20.00
1928	862	Cascaron Huevo	1	40.00
1938	867	Cascaron Huevo	1	20.00
2643	1182	Cascaron Huevo	1	10.00
2685	1202	Cascaron Huevo	1	10.00
3010	1361	Cascaron Huevo	2	10.00
3044	1381	Cascaron Huevo	1	40.00
3137	1422	Cascaron Huevo	1	20.00
3196	1448	Cascaron Huevo	1	10.00
3287	1482	Cascaron Huevo	1	10.00
3299	1486	Cascaron Huevo	1	10.00
3310	1493	Cascaron Huevo	1	10.00
3864	1747	Cascaron Huevo	1	20.00
4711	2182	Cascaron Huevo	1	10.00
4817	2235	Cascaron Huevo	1	20.00
4954	2292	Cascaron Huevo	1	20.00
5126	2378	Cascaron Huevo	1	10.00
5983	2763	Cascaron Huevo	1	10.00
6123	2827	Cascaron Huevo	1	20.00
6257	2892	Cascaron Huevo	1	20.00
6413	2968	Cascaron Huevo	1	20.00
6481	3000	Cascaron Huevo	1	10.00
6507	3011	Cascaron Huevo	1	10.00
6521	3019	Cascaron Huevo	2	20.00
6650	3083	Cascaron Huevo	1	10.00
1275	594	Lamina Unicel	1	20.00
1513	695	Lamina Unicel	1	20.00
1675	767	Lamina Unicel	1	55.00
2257	1003	Lamina Unicel	1	10.00
2409	1062	Lamina Unicel	1	10.00
2830	1276	Lamina Unicel	1	10.00
2988	1355	Lamina Unicel	1	10.00
3499	1581	Lamina Unicel	1	30.00
3508	1584	Lamina Unicel	2	20.00
3576	1610	Lamina Unicel	1	10.00
4033	1816	Lamina Unicel	2	30.00
5004	2316	Lamina Unicel	1	30.00
6008	2774	Lamina Unicel	1	20.00
6924	3205	Lamina Unicel	1	30.00
6925	3205	Lamina Unicel	2	10.00
6926	3205	Lamina Unicel	1	20.00
522	266	Cartulina Fluorecente	1	15.00
2027	908	Cartulina Fluorecente	1	15.00
2367	1047	Cartulina Fluorecente	1	15.00
2874	1302	Cartulina Fluorecente	1	15.00
3214	1454	Cartulina Fluorecente	2	15.00
3660	1645	Cartulina Fluorecente	2	15.00
4239	1930	Cartulina Fluorecente	1	15.00
4466	2045	Cartulina Fluorecente	1	15.00
4467	2045	Cartulina Fluorecente	1	15.00
4633	2139	Cartulina Fluorecente	2	15.00
5202	2414	Cartulina Fluorecente	3	15.00
5470	2535	Cartulina Fluorecente	1	15.00
5938	2740	Cartulina Fluorecente	1	15.00
5939	2740	Cartulina Fluorecente	1	15.00
6533	3024	Cartulina Fluorecente	1	15.00
6889	3191	Cartulina Fluorecente	1	15.00
808	380	Fomy Pliego	1	15.00
1096	510	Fomy Pliego	1	15.00
1183	562	Fomy Pliego	2	15.00
1475	682	Fomy Pliego	1	15.00
1668	762	Fomy Pliego	3	15.00
2563	1146	Fomy Pliego	1	15.00
2990	1356	Fomy Pliego	2	15.00
3552	1603	Fomy Pliego	2	15.00
3640	1634	Fomy Pliego	1	15.00
3944	1784	Fomy Pliego	2	15.00
5036	2335	Fomy Pliego	1	15.00
1866	836	Fomy Pliego Diamantado	2	30.00
2034	913	Fomy Pliego Diamantado	1	30.00
4811	2233	Fomy Pliego Diamantado	1	30.00
5037	2335	Fomy Pliego Diamantado	1	30.00
6783	3143	Fomy Pliego Diamantado	1	30.00
6819	3156	Fomy Pliego Diamantado	2	30.00
502	256	Liga Chica	10	0.50
1673	765	Liga Grande	2	1.00
6813	3154	Liga Grande	5	1.00
1501	689	Papel Leyer	1	12.00
2260	1004	Papel Leyer	3	12.00
6438	2978	Papel Leyer	1	12.00
5981	2761	Papel Mantequilla	1	25.00
852	398	Papel Imprenta	1	5.00
1152	546	Papel Imprenta	2	5.00
2133	961	Papel Imprenta	2	5.00
3672	1652	Papel Imprenta	1	5.00
4190	1900	Papel Imprenta	1	5.00
4879	2260	Papel Imprenta	1	5.00
5180	2403	Papel Imprenta	2	5.00
5881	2714	Papel Imprenta	1	5.00
6626	3070	Papel Imprenta	3	5.00
4309	1971	Papel Celofan	1	9.00
1102	516	Papel Celofan	1	13.00
1713	780	Papel Celofan	3	13.00
6255	2890	Papel Celofan	1	13.00
6798	3148	Papel Celofan	4	13.00
6824	3158	Papel Celofan	4	13.00
2162	970	Papelote/Rotafolio	1	9.00
2327	1032	Papelote/Rotafolio	1	9.00
5284	2452	Papelote/Rotafolio	1	9.00
5301	2457	Papelote/Rotafolio	1	9.00
6500	3007	Papelote/Rotafolio	1	9.00
2562	1145	Papel Deztrasa	6	4.00
5885	2716	Papel Deztrasa	2	4.00
6567	3038	Papel Deztrasa	1	4.00
715	346	Papel Caple	2	30.00
2252	1000	Papel Caple	1	30.00
2738	1227	Papel Caple	1	30.00
3165	1437	Papel Caple	1	30.00
3223	1458	Papel Caple	1	30.00
2949	1339	Papel Terciopelo	1	25.00
2741	1227	Papel Corrugado	1	35.00
2774	1243	Papel Corrugado	1	35.00
5003	2316	Papel Corrugado	1	30.00
6649	3082	Papel Corrugado	2	30.00
6706	3109	Papel Corrugado	2	30.00
6941	3211	Papel Corrugado	1	30.00
7070	3269	Papel Corrugado	1	30.00
776	364	Resorte Blanco	1	9.00
4977	2303	Resorte Blanco	1	9.00
5121	2376	Resorte Blanco	1	9.00
5125	2377	Resorte Blanco	1	9.00
785	367	Resorte Negro	4	6.00
1260	590	Resorte Negro	1	6.00
1942	869	Resorte Negro	1	6.00
2216	984	Resorte Negro	1	6.00
3389	1527	Resorte Negro	1	6.00
6397	2963	Resorte Negro	1	6.00
649	315	Liston 1.5cm	6	7.00
1956	877	Liston 1.5cm	1	7.00
2414	1062	Liston 1.5cm	1	7.00
2524	1131	Liston 1.5cm	1	7.00
2886	1307	Liston 1.5cm	3	7.00
2974	1349	Liston 1.5cm	3	7.00
2989	1355	Liston 1.5cm	3	7.00
3018	1366	Liston 1.5cm	6	7.00
5431	2517	Liston 1.5cm	2	7.00
5458	2526	Liston 1.5cm	1	7.00
5651	2619	Liston 1.5cm	15	7.00
6058	2795	Liston 1.5cm	1	7.00
1407	647	Liston 2.5cm	3	9.00
1669	763	Liston 2.5cm	2	9.00
2295	1021	Liston 2.5cm	1	9.00
2498	1117	Liston 2.5cm	4	9.00
2534	1135	Liston 2.5cm	2	9.00
2880	1305	Liston 2.5cm	2	9.00
2925	1326	Liston 2.5cm	3	9.00
3478	1568	Liston 2.5cm	2	9.00
3960	1788	Liston 2.5cm	1	9.00
3981	1796	Liston 2.5cm	1	9.00
5375	2493	Liston 2.5cm	12	9.00
6024	2783	Liston 2.5cm	1	9.00
6132	2830	Liston 2.5cm	2	9.00
6181	2855	Liston 2.5cm	2	9.00
6590	3050	Liston 2.5cm	2	9.00
699	338	Liston 4cm	2	15.00
2326	1031	Liston 4cm	4	15.00
2540	1138	Liston 4cm	1	15.00
2591	1153	Liston 4cm	1	15.00
2859	1294	Liston 4cm	3	15.00
3047	1383	Liston 4cm	3	15.00
3079	1399	Liston 4cm	4	15.00
3127	1418	Liston 4cm	3	15.00
3130	1419	Liston 4cm	3	15.00
3591	1617	Liston 4cm	1	15.00
3632	1631	Liston 4cm	1	15.00
3652	1638	Liston 4cm	2	15.00
3848	1739	Liston 4cm	1	15.00
3997	1799	Liston 4cm	1	15.00
4698	2175	Liston 4cm	1	15.00
5682	2633	Liston 4cm	1	15.00
5836	2703	Liston 4cm	3	15.00
7043	3254	Liston 4cm	3	15.00
851	398	Liston .95cm	1	5.00
1518	695	Liston .95cm	3	5.00
2413	1062	Liston .95cm	2	5.00
2541	1138	Liston .95cm	2	5.00
2590	1153	Liston .95cm	1	5.00
2745	1228	Liston .95cm	1	5.00
2979	1351	Liston .95cm	2	5.00
3005	1359	Liston .95cm	1	5.00
3711	1667	Liston .95cm	1	5.00
3993	1798	Liston .95cm	1	5.00
4353	1995	Liston .95cm	6	5.00
4609	2125	Liston .95cm	1	5.00
4841	2239	Liston .95cm	4	5.00
5147	2388	Liston .95cm	1	5.00
5264	2441	Liston .95cm	3	5.00
5328	2473	Liston .95cm	1	5.00
5430	2517	Liston .95cm	2	5.00
5801	2691	Liston .95cm	1	5.00
5971	2755	Liston .95cm	1	5.00
6055	2794	Liston .95cm	2	5.00
6395	2962	Liston .95cm	2	5.00
6754	3132	Liston .95cm	2	5.00
1536	706	Pintura Cara	1	35.00
2094	939	Pintura Cara	1	30.00
2146	963	Pintura Cara	1	35.00
2147	963	Pintura Cara	1	12.00
2319	1028	Pintura Cara	1	12.00
2398	1057	Pintura Cara	1	12.00
2455	1080	Pintura Cara	1	30.00
2459	1082	Pintura Cara	1	12.00
2460	1082	Pintura Cara	1	30.00
2516	1125	Pintura Cara	1	12.00
2599	1157	Pintura Cara	2	12.00
2710	1213	Pintura Cara	2	12.00
341	181	Decoracion	2	7.00
2888	1307	Decoracion	2	7.00
1061	497	Figura Fomy	3	10.00
1259	589	Figura Fomy	1	10.00
1382	636	Figura Fomy	1	10.00
1447	667	Figura Fomy	2	10.00
1849	832	Figura Fomy	1	10.00
1934	865	Figura Fomy	2	10.00
2018	904	Figura Fomy	1	10.00
2363	1043	Figura Fomy	9	10.00
1154	548	Araña	1	35.00
777	364	Colmillo de Dracula	1	5.00
1299	603	Colmillo de Dracula	1	5.00
1364	627	Colmillo de Dracula	2	5.00
1636	746	Colmillo de Dracula	1	5.00
1140	538	Telaraña de China	1	35.00
1605	733	Telaraña de China	1	35.00
865	403	Sangre y Lates	1	15.00
987	466	Sangre y Lates	1	15.00
1537	706	Sangre y Lates	1	15.00
1600	731	Sangre y Lates	1	15.00
1637	746	Sangre y Lates	1	15.00
1937	867	Sangre y Lates	1	15.00
2365	1045	Sangre y Lates	1	15.00
3309	1493	Cuerpos Geometricos	1	55.00
4458	2041	Argolla	1	10.00
5193	2410	Argolla	2	10.00
1287	599	Diamantina Gruesa	2	8.00
2261	1005	Diamantina Gruesa	1	8.00
1203	567	Descargas	1	8.00
1722	782	Descargas	1	8.00
1906	853	Descargas	1	8.00
1953	877	Descargas	1	8.00
2036	913	Descargas	1	8.00
3427	1546	Descargas	1	8.00
3765	1701	Descargas	1	8.00
5382	2496	Descargas	1	10.00
5444	2522	Descargas	1	10.00
5579	2588	Descargas	1	10.00
6099	2816	Descargas	1	10.00
1385	638	Globo de Helio	1	85.00
3913	1770	Globo de Helio	3	85.00
4387	2012	Globo de Helio	1	85.00
1441	665	Ula Ula	1	40.00
3259	1471	Tira de Luz	2	25.00
4127	1870	Tira de Luz	3	20.00
5674	2630	Tira de Luz	2	20.00
7137	3292	Tira de Luz	2	20.00
7362	3405	Tira de Luz	1	20.00
1642	750	Dibujo	1	2.00
1646	753	Dibujo	2	2.00
2081	933	Dibujo	1	2.00
2655	1187	Dibujo	2	2.00
2667	1192	Dibujo	3	2.00
3038	1377	Dibujo	3	2.00
3152	1430	Dibujo	1	2.00
4842	2240	Dibujo	2	2.00
4851	2243	Dibujo	3	2.00
5353	2482	Dibujo	2	2.00
6038	2787	Dibujo	1	2.00
6103	2818	Dibujo	3	2.00
6217	2875	Dibujo	2	2.00
1655	757	Cola de Rata	1	3.00
2004	900	Cola de Rata	2	3.00
2263	1005	Cola de Rata	1	3.00
6057	2794	Cola de Rata	1	3.00
7309	3382	Cola de Rata	4	3.00
1751	793	Craneo	1	50.00
1939	868	Craneo	1	35.00
3574	1610	Pintura Politec20 Ml.	1	16.00
5073	2351	Pintura Politec20 Ml.	1	16.00
5702	2640	Pintura Politec20 Ml.	1	17.00
5850	2704	Pintura Politec20 Ml.	1	17.00
6342	2933	Pintura Politec20 Ml.	2	17.00
6415	2968	Pintura Politec20 Ml.	1	17.00
6600	3054	Pintura Politec20 Ml.	1	17.00
7254	3354	Pintura Politec20 Ml.	2	17.00
5510	2551	Tijera Jumbo	1	65.00
4358	1998	Uno Personaje	1	40.00
6636	3077	Uno Personaje	1	40.00
5062	2349	Happy Time	1	50.00
505	258	Fomy Moldeable	2	35.00
2772	1241	Fomy Moldeable	1	40.00
4749	2205	Fomy Moldeable	1	40.00
4905	2270	Fomy Moldeable	1	40.00
5440	2520	Fomy Moldeable	2	40.00
5570	2581	Fomy Moldeable	1	35.00
6049	2790	Fomy Moldeable	1	35.00
3897	1762	Cinta Diurex C/Despachador	1	40.00
6204	2868	Dinosaurios	1	100.00
4295	1962	Dinosaurios	2	55.00
3723	1674	Puppy Paradise	1	30.00
4146	1878	Puppy Paradise	3	30.00
3342	1506	Engrapadora Set	1	85.00
6610	3059	Engrapadora Set	1	85.00
6172	2849	Palo de Colores	1	30.00
5695	2639	Balon	1	60.00
2950	1339	Papel Pvc	1	25.00
3197	1448	Papel Metalico	1	24.00
3629	1630	Papel Metalico	3	24.00
4138	1874	Figura Fomy	1	10.00
4012	1806	Pino	3	10.00
4058	1829	Pino	1	10.00
4101	1854	Pino	1	10.00
4102	1855	Pino	2	10.00
4126	1870	Pino	1	10.00
3525	1588	Gorro	1	15.00
3535	1594	Gorro	1	15.00
3900	1763	Gorro	1	15.00
4159	1883	Gorro	3	15.00
4242	1932	Gorro	10	15.00
4294	1961	Gorro	8	30.00
4259	1942	Diablo	1	50.00
3717	1670	Sobre	4	15.00
3767	1701	Sobre	4	15.00
4089	1844	Sobre	2	15.00
4112	1862	Sobre	4	15.00
4244	1933	Sobre	1	15.00
3538	1595	Mono de Nieve	1	35.00
3663	1647	Pegamento de Pestaña	1	20.00
4411	2021	Pintura Politec 20 Ml	1	30.00
5074	2351	Pintura Politec 20 Ml	1	30.00
5308	2462	Pintura Politec 20 Ml	1	30.00
5871	2711	Pintura Politec 20 Ml	2	17.00
6041	2788	Pintura Politec 20 Ml	1	17.00
6417	2968	Pintura Politec 20 Ml	1	17.00
6595	3054	Pintura Politec 20 Ml	1	17.00
6679	3099	Pintura Politec 20 Ml	1	17.00
7068	3269	Pintura Politec 20 Ml	1	30.00
7162	3306	Pintura Politec 20 Ml	1	17.00
7250	3354	Pintura Politec 20 Ml	1	17.00
4648	2146	Tabla con Clip	1	50.00
5214	2419	Pelota Antiestres	1	30.00
5821	2697	Pelota Antiestres	2	30.00
5954	2747	Pelota Antiestres	1	30.00
6794	3146	Pelota Antiestres	1	30.00
4900	2268	Impresion Oficio B/N	8	3.00
5926	2734	Impresion Oficio B/N	1	3.00
6006	2773	Impresion Oficio B/N	6	3.00
6293	2909	Impresion Oficio B/N	19	3.00
7084	3276	Impresion Oficio B/N	1	3.00
7201	3325	Impresion Oficio B/N	12	3.00
5133	2379	Impresion Oficio Color	1	8.00
5136	2381	Impresion Oficio Color	1	8.00
5679	2632	Impresion Oficio Color	2	8.00
5735	2655	Impresion Oficio Color	1	8.00
6658	3087	Impresion Oficio Color	1	8.00
7165	3307	Impresion Oficio Color	1	8.00
7191	3319	Impresion Oficio Color	3	8.00
5879	2713	Cubo 30x30	1	80.00
969	457	Scuichi	1	35.00
993	468	Scuichi	2	20.00
994	468	Scuichi	1	30.00
1010	475	Scuichi	1	30.00
1039	490	Scuichi	1	35.00
1149	544	Scuichi	1	30.00
1424	654	Scuichi	1	20.00
1448	667	Scuichi	1	30.00
1466	677	Scuichi	1	35.00
2020	904	Scuichi	1	35.00
2300	1022	Scuichi	1	20.00
2978	1350	Scuichi	1	35.00
3248	1469	Scuichi	2	30.00
4379	2009	Scuichi	1	30.00
4508	2072	Scuichi	1	30.00
5197	2410	Scuichi	1	30.00
5370	2491	Scuichi	1	30.00
5429	2517	Scuichi	1	30.00
5441	2520	Scuichi	1	30.00
5568	2581	Scuichi	1	30.00
5807	2693	Scuichi	1	30.00
6173	2850	Scuichi	1	30.00
6866	3176	Scuichi	2	30.00
7005	3237	Scuichi	1	30.00
7173	3313	Scuichi	2	30.00
5171	2398	Tijera	1	20.00
5254	2435	Tijera	1	20.00
5511	2551	Yoyo	1	30.00
6628	3072	Yoyo	1	30.00
6538	3025	Liga Surtida	1	32.00
6850	3169	Liga Surtida	1	32.00
6459	2989	Arco	1	55.00
5922	2732	My Pet	1	35.00
6037	2787	My Pet	1	35.00
6247	2885	Girl Toys	1	40.00
5870	2711	Pistola Balas de Gel	2	35.00
5958	2749	Pistola Balas de Gel	1	35.00
6182	2856	Pizarron Magico	1	30.00
7225	3339	Pizarron Magico	2	30.00
5626	2610	Balas de Disco	5	20.00
7006	3237	Sombras Pastel/Helado	1	55.00
1957	878	Uno	1	50.00
6946	3215	Uno	1	50.00
5372	2491	Piano	1	70.00
922	433	Burbujas	1	15.00
2651	1186	Burbujas	1	15.00
6818	3155	Burbujas	2	20.00
6869	3178	Burbujas	1	15.00
6872	3180	Burbujas	1	20.00
6883	3187	Burbujas	1	15.00
7297	3377	Burbujas	1	15.00
5402	2506	Papel Roca	1	18.00
5844	2704	Papel Roca	1	18.00
5698	2639	Llaveros	1	25.00
5819	2697	Recibo de Dinero	2	35.00
6447	2983	Hojas de Color	10	1.50
6529	3023	Hojas de Color	16	1.50
6578	3045	Hojas de Color	30	1.50
6645	3080	Hojas de Color	20	1.50
6684	3100	Hojas de Color	12	1.50
6752	3130	Hojas de Color	8	1.50
6787	3143	Hojas de Color	6	1.50
6817	3155	Hojas de Color	10	1.50
6843	3166	Hojas de Color	2	1.50
6855	3170	Hojas de Color	6	1.50
6909	3198	Hojas de Color	31	1.50
6917	3199	Hojas de Color	2	1.50
6989	3230	Hojas de Color	2	1.50
7035	3249	Hojas de Color	10	1.50
7058	3266	Hojas de Color	4	1.50
7099	3281	Hojas de Color	1	1.50
7188	3318	Hojas de Color	15	1.50
7214	3333	Hojas de Color	1	1.50
7263	3362	Hojas de Color	3	1.50
7273	3365	Hojas de Color	15	1.50
7304	3379	Hojas de Color	30	1.50
7316	3387	Hojas de Color	14	1.50
7361	3404	Hojas de Color	3	1.50
7354	3401	Pinza P/Cabello	1	20.00
\.


--
-- Data for Name: egresos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.egresos (id, monto, fecha, concepto) FROM stdin;
2	150.00	2025-09-17 11:14:41.288105	\N
3	615.00	2025-09-17 23:27:01.8707	\N
4	450.00	2025-09-17 23:27:29.473003	\N
5	950.00	2025-09-19 18:41:56.847477	\N
6	5050.00	2025-09-30 18:46:56.787284	\N
7	500.00	2025-09-30 18:47:05.92679	\N
8	2100.00	2025-10-04 01:42:08.664614	\N
9	200.00	2025-10-06 13:50:00.777128	\N
10	1100.00	2025-10-06 13:50:18.736328	\N
11	250.00	2025-10-07 19:23:49.15398	\N
12	1900.00	2025-10-07 21:17:21.690409	\N
13	900.00	2025-10-08 14:29:46.925277	\N
14	250.00	2025-10-09 18:49:44.595891	\N
15	390.00	2025-10-14 13:14:08.725779	\N
16	360.00	2025-10-14 16:59:09.266248	\N
17	200.00	2025-10-14 19:10:04.275614	\N
18	1000.00	2025-10-20 15:32:07.027246	\N
19	280.00	2025-10-21 14:17:17.360173	\N
20	100.00	2025-10-21 14:20:07.069603	\N
21	900.00	2025-10-21 19:12:54.934811	\N
22	2300.00	2025-11-04 17:19:48.153443	\N
23	250.00	2025-12-10 19:24:02.836352	\N
24	1000.00	2025-12-26 16:56:03.721599	\N
25	1000.00	2025-12-26 20:16:42.731165	\N
26	810.00	2026-01-15 18:51:33.271097	\N
27	600.00	2026-01-20 17:10:08.522304	\N
28	20.00	2026-01-26 16:26:26.487718	\N
29	1500.00	2026-01-26 16:26:31.750556	\N
30	200.00	2026-01-29 19:49:01.456872	\N
31	3000.00	2026-03-19 18:03:45.674792	\N
\.


--
-- Data for Name: lista_compras; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lista_compras (id, tienda_id, nombre_producto, cantidad, precio_ref, notas, completado, created_at) FROM stdin;
\.


--
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.productos (id, nombre, precio, descripcion, codigo, stock, status, imagen_url, categoria, precio_costo, stock_minimo) FROM stdin;
10	Barra Silicon	10.00	Gruesa	6	8	t	\N	General	0.00	15
8	Cartulina	15.00	Negra	4	26	t	\N	General	0.00	15
9	Cartulina	15.00	Verde Bandera	5	2	t	\N	General	0.00	15
6	Barra Silicon	4.00	Delgada	2	75	t	\N	General	0.00	15
294	Tabla	48.00	50x50	274	1	t	\N	General	0.00	15
36	Impresion B/N	2.00	bajo +	31	95547	t	\N	General	0.00	15
1297	Cartulina	15.00	naranja	1267	5	t	\N	General	0.00	15
1298	Cartulina	15.00	cafe	1268	25	t	\N	General	0.00	15
1300	Cartulina	15.00	verde pastel	1270	41	t	\N	General	0.00	15
1306	Cartulina	15.00	gris oscuro	1276	2	t	\N	General	0.00	15
1307	Cartulina	15.00	beige	1277	2	t	\N	General	0.00	15
1308	Cartulina	15.00	metalica	1278	16	t	\N	General	0.00	15
1310	Cartulina	15.00	azul ultra	1280	17	t	\N	General	0.00	15
1311	Cartulina	15.00	azul rey	1281	15	t	\N	General	0.00	15
1312	Cartulina	15.00	turquesa	1282	4	t	\N	General	0.00	15
1309	Cartulina	15.00	rojo	1279	36	t	\N	General	0.00	15
1303	Cartulina	15.00	lila	1273	1	t	\N	General	0.00	15
1302	Cartulina	15.00	rosas	1272	20	t	\N	General	0.00	15
1301	Cartulina	15.00	rosa pastel	1271	23	t	\N	General	0.00	15
1299	Cartulina	15.00	verde limon	1269	32	t	\N	General	0.00	15
1304	Cartulina	15.00	morado	1274	27	t	\N	General	0.00	15
1305	Cartulina	15.00	gris claro	1275	30	t	\N	General	0.00	15
1313	Cartulina	15.00	amarillo canario	1283	6	t	\N	General	0.00	15
275	Bola Unicel	3.00	#3	255	5	t	\N	General	0.00	15
269	Palo	0.75	paleta	249	164	t	\N	General	0.00	15
11	Silbato	17.00	económico	1	7	t	\N	General	0.00	15
13	Collar	10.00	un solo color	7	7	t	\N	General	0.00	15
14	Corona	40.00	 rey	9	1	t	\N	General	0.00	15
15	Lluvia	3.00	verde	10	29	t	\N	General	0.00	15
16	Lluvia	3.00	dorada	11	19	t	\N	General	0.00	15
17	Lluvia	3.00	plateada	12	11	t	\N	General	0.00	15
18	Lluvia	3.00	rojo	13	21	t	\N	General	0.00	15
20	Lluvia	3.00	azul	15	12	t	\N	General	0.00	15
21	Campana Tricolor	28.00	decoración	16	2	t	\N	General	0.00	15
22	Barba y Bigote	40.00	Sin descripcion	17	3	t	\N	General	0.00	15
23	Bandera	10.00	triangulo	18	6	t	\N	General	0.00	15
24	Bandera Chica	15.00	plastico	19	8	t	\N	General	0.00	15
26	Abanico	35.00	decoracion	21	3	t	\N	General	0.00	15
27	Tabla de Multilicar	25.00	Sin descripcion	22	4	t	\N	General	0.00	15
28	Tabla de Numeros	25.00	Sin descripcion	23	1	t	\N	General	0.00	15
29	Tabla Vocales	25.00	Sin descripcion	24	1	t	\N	General	0.00	15
30	Galleta Patria	40.00	decoracion 	25	4	t	\N	General	0.00	15
31	Borrador	35.00	pizarron	26	1	t	\N	General	0.00	15
32	Decoracion Ovalado	40.00	tricolor	27	2	t	\N	General	0.00	15
33	Cadena Mediana	40.00	decoracion	28	6	t	\N	General	0.00	15
34	Bandera	65.00	decoracion	29	1	t	\N	General	0.00	15
37	Impresion Color	10.00	 alto +++	32	9567	t	\N	General	0.00	15
38	Impresion Color	5.00	Bajo +	33	9386	t	\N	General	0.00	15
39	Impresion Color	15.00	muy Alto +++	34	9870	t	\N	General	0.00	15
40	Engargolado	35.00	1 a 40 hojas	35	29	t	\N	General	0.00	15
41	Engargolado	45.00	de 41 a 80 hojas	36	37	t	\N	General	0.00	15
42	Engargolado	60.00	81 a 125 hojas	37	45	t	\N	General	0.00	15
44	Engargolado	80.00	126 a 150 hojas	39	50	t	\N	General	0.00	15
46	Engargolado	100.00	151 a 200 hojas	40	49	t	\N	General	0.00	15
47	Enmicado	15.00	chico	41	72	t	\N	General	0.00	15
48	Enmicado	17.00	mediano	42	90	t	\N	General	0.00	15
49	Enmicado	20.00	grande	43	86	t	\N	General	0.00	15
50	Enmicado	25.00	t/carta	44	1	t	\N	General	0.00	15
51	Enmicado	35.00	t/oficio	45	14	t	\N	General	0.00	15
52	Limpiapipas	1.00	verde fluorecente	46	4	t	\N	General	0.00	15
53	Limpiapipas	1.00	morado\n	47	80	t	\N	General	0.00	15
55	Limpiapipas	1.50	plata	49	80	t	\N	General	0.00	15
56	Limpiapipas	1.50	dorada	50	40	t	\N	General	0.00	15
57	Limpiapipas	1.50	rojo metalico	51	25	t	\N	General	0.00	15
58	Limpiapipas	1.00	GRIS CLARO\n	52	100	t	\N	General	0.00	15
59	Limpiapipas	1.00	gris medio	53	100	t	\N	General	0.00	15
60	Limpiapipas	1.00	gris fuerte	54	80	t	\N	General	0.00	15
61	Limpiapipas	1.00	blanco	55	81	t	\N	General	0.00	15
62	Limpiapipas	1.00	negro	56	12	t	\N	General	0.00	15
64	Limpiapipas	1.00	cafe claro	58	80	t	\N	General	0.00	15
65	Limpiapipas	1.00	cafe oscuro	57	17	t	\N	General	0.00	15
66	Limpiapipas	1.00	verde bandera	59	145	t	\N	General	0.00	15
67	Limpiapipas	1.00	verde limon	60	139	t	\N	General	0.00	15
68	Limpiapipas	1.00	amarillo fluorecente	61	59	t	\N	General	0.00	15
69	Limpiapipas	1.00	amarillo canario	62	67	t	\N	General	0.00	15
70	Limpiapipas	1.00	amarillo	63	116	t	\N	General	0.00	15
71	Limpiaipas	1.00	rosa fiusha	64	38	t	\N	General	0.00	15
72	Limpiapipas	1.00	rosa 	65	14	t	\N	General	0.00	15
73	Limpiapipas	1.00	rosa pastel	66	49	t	\N	General	0.00	15
74	Limpiapipas	1.00	naranja fluorecente	67	94	t	\N	General	0.00	15
75	Limpiapipas	1.00	beige/carne	68	30	t	\N	General	0.00	15
76	Limpiapipas	1.00	rojo	69	259	t	\N	General	0.00	15
77	Limpiapipas	1.00	morado 	70	40	t	\N	General	0.00	15
79	Limpiapipas	1.00	morado claro	48	17	t	\N	General	0.00	15
80	Limpiapipas	1.00	morado fuerte	71	89	t	\N	General	0.00	15
81	Limpiapipas	1.00	azul rey	72	80	t	\N	General	0.00	15
82	Limpiapipas	1.00	azul intenso	73	19	t	\N	General	0.00	15
83	Limpiapias	1.00	azul cielo	74	28	t	\N	General	0.00	15
84	Limpiapias	1.00	azul medio	75	60	t	\N	General	0.00	15
90	Rafia	30.00	colores\n	79	15	t	\N	General	0.00	15
97	Disco	10.00	cd-r	86	30	t	\N	General	0.00	15
99	Lluvia	3.00	tricolor	30	80	t	\N	General	0.00	15
100	Collar	25.00	patrio	14	2	t	\N	General	0.00	15
101	Bigote	10.00	Sin descripcion	8	10	t	\N	General	0.00	15
105	Pintura Digital/Tactil	25.00	colores\n	89	5	t	\N	General	0.00	15
106	Pintura Textil	30.00	colores	90	6	t	\N	General	0.00	15
107	Lapiz	15.00	# B	91	10	t	\N	General	0.00	15
108	Lapiz	15.00	# 2B	92	49	t	\N	General	0.00	15
109	Lapiz	15.00	#3B	93	11	t	\N	General	0.00	15
110	Lapiz	15.00	#4B	94	18	t	\N	General	0.00	15
111	Lapiz	15.00	#5B	95	2	t	\N	General	0.00	15
112	Lapiz	15.00	#6B	96	9	t	\N	General	0.00	15
113	Lapiz	15.00	#7B	97	2	t	\N	General	0.00	15
114	Lapiz	15.00	#8B	98	2	t	\N	General	0.00	15
115	Lapiz	15.00	# HB	99	16	t	\N	General	0.00	15
116	Lapiz	15.00	#2H	100	11	t	\N	General	0.00	15
117	Lapiz	15.00	#3H	101	11	t	\N	General	0.00	15
118	Lapiz	15.00	#4H	102	9	t	\N	General	0.00	15
119	Lapiz	15.00	#6H	103	12	t	\N	General	0.00	15
120	Hilo Dorado	6.00	pieza	104	5	t	\N	General	0.00	15
121	Aguja	10.00	estuche	105	19	t	\N	General	0.00	15
122	Velcro X Mt.	15.00	blanco	106	3	t	\N	General	0.00	15
123	Velcro X Mt.	15.00	negro	107	1	t	\N	General	0.00	15
124	Alfileres	13.00	color	108	2	t	\N	General	0.00	15
125	Alfileres	20.00	plata	109	4	t	\N	General	0.00	15
126	Cinta Tape	30.00	flores	110	4	t	\N	General	0.00	15
127	Costalito	10.00	tela	111	10	t	\N	General	0.00	15
129	Hilo	20.00	transparente/plastico	113	4	t	\N	General	0.00	15
135	Hilo	20.00	varios colores	119	27	t	\N	General	0.00	15
140	Bastidor	35.00	grande 26 cm	124	1	t	\N	General	0.00	15
141	Pegamento Uhu	35.00	 mini	125	1	t	\N	General	0.00	15
143	Contac	18.00	1 mt	38	40	t	\N	General	0.00	15
144	Contac	15.00	 más de 3 metros	127	46	t	\N	General	0.00	15
145	Lapiz	10.00	maped	128	70	t	\N	General	0.00	15
146	Lapiz	10.00	mirado	129	25	t	\N	General	0.00	15
147	Lapiz	7.00	economico	130	251	t	\N	General	0.00	15
148	Copia B/N	2.00	t/carta	131	153	t	\N	General	0.00	15
149	Opalina	3.50	gruesa	132	198	t	\N	General	0.00	15
150	Opalina	2.50	delgada\n	133	78	t	\N	General	0.00	15
154	Opalina	5.00	color	134	82	t	\N	General	0.00	15
155	Etiqueta	12.00	lapiz	136	18	t	\N	General	0.00	15
156	Etiqueta	12.00	cuaderno\n	137	38	t	\N	General	0.00	15
157	Impresion B/N	5.00	medio ++	138	432	t	\N	General	0.00	15
158	Impresion B/N	10.00	alto +++	139	471	t	\N	General	0.00	15
159	Copia Color	5.00	T/carta	140	103	t	\N	General	0.00	15
160	Globo #6	1.50	suelto	141	198	t	\N	General	0.00	15
161	Globo #7	2.00	suelto	142	186	t	\N	General	0.00	15
162	Globo #9	2.50	suelto	143	70	t	\N	General	0.00	15
163	Globo #12	3.00	suelto	144	224	t	\N	General	0.00	15
164	Curli	1.00	normal	145	9857	t	\N	General	0.00	15
165	Curli	1.50	metalico	146	945	t	\N	General	0.00	15
166	Pom Pom	0.50	#13	147	495	t	\N	General	0.00	15
167	Pom Pom	1.00	#18	148	488	t	\N	General	0.00	15
168	Pom Pom	1.50	#25	149	497	t	\N	General	0.00	15
169	Pom Pom	2.50	#38 	150	687	t	\N	General	0.00	15
170	Pom Pom	3.00	#50	151	499	t	\N	General	0.00	15
171	Estambre	42.00	grande 40 gr	152	3	t	\N	General	0.00	15
172	Estambre	20.00	mediano 20 gr	153	4	t	\N	General	0.00	15
173	Estambre	15.00	chico 10 gr	154	2	t	\N	General	0.00	15
174	Pluma Ganso	2.00	pluma chica	155	48	t	\N	General	0.00	15
175	Pluma Ganso	4.00	pluma grande	156	34	t	\N	General	0.00	15
176	Ojos	9.00	planilla	157	8	t	\N	General	0.00	15
177	Ojo Loco	3.00	pegatina 	158	25	t	\N	General	0.00	15
178	Ojo y Boca	1.00	par	159	20	t	\N	General	0.00	15
179	Cordon P/Gafet	6.00	color	160	21	t	\N	General	0.00	15
180	Cordon P/Gafet	6.00	negro	161	46	t	\N	General	0.00	15
181	Porta Gafet	35.00	grande	162	54	t	\N	General	0.00	15
182	Porta Gafet	25.00	chico	163	14	t	\N	General	0.00	15
183	Cinta Negra	15.00	aislante	164	8	t	\N	General	0.00	15
184	Cinta Gruesa	35.00	canela	165	2	t	\N	General	0.00	15
185	Cinta Gruesa	35.00	transparente	166	4	t	\N	General	0.00	15
186	Hilaza	24.00	bola	167	5	t	\N	General	0.00	15
187	Cinta Doble Cara	55.00	12x33 mt	168	0	t	\N	General	0.00	15
188	Cinta Doble Cara	70.00	18 x 33 mt	169	1	t	\N	General	0.00	15
190	Cinta Maskitape	45.00	18x50mt.	171	2	t	\N	General	0.00	15
191	Juego Geometria	90.00	note max flexible	172	2	t	\N	General	0.00	15
193	Juego Geometria	30.00	economico	174	2	t	\N	General	0.00	15
194	Juego de Escuadras	40.00	scool	175	1	t	\N	General	0.00	15
195	Flauta	35.00	economica	176	1	t	\N	General	0.00	15
196	Flauta	75.00	jocar	177	1	t	\N	General	0.00	15
197	Regla	12.00	plastico	178	7	t	\N	General	0.00	15
198	Regla	8.00	madera	179	7	t	\N	General	0.00	15
199	Regla	35.00	metal	180	10	t	\N	General	0.00	15
200	Regla	30.00	flexible	181	13	t	\N	General	0.00	15
201	Regla	35.00	plastico rigido	182	1	t	\N	General	0.00	15
202	Regla	26.00	20 cm plastico	183	1	t	\N	General	0.00	15
203	Regla	20.00	20 cm flexible 	184	1	t	\N	General	0.00	15
204	Difuminador	25.00	#4	185	4	t	\N	General	0.00	15
206	Cutter	80.00	de precision	187	2	t	\N	General	0.00	15
207	Solicitud de Empleo	2.50	Sin descripcion	188	143	t	\N	General	0.00	15
208	Hojas Blanca	13.00	paq. 25	189	4	t	\N	General	0.00	15
209	Hojas Blanca	25.00	paq. 50	190	19	t	\N	General	0.00	15
210	Hojas Blanca	45.00	paq. 100	191	7	t	\N	General	0.00	15
213	Protector de Hoja	2.00	Carta A4	194	102	t	\N	General	0.00	15
214	Hoja	2.00	kraft	195	99	t	\N	General	0.00	15
215	Hoja de Seguridad	4.00	Sin descripcion	196	70	t	\N	General	0.00	15
216	Corrector	22.00	brocha	197	5	t	\N	General	0.00	15
217	Corrector	25.00	lapiz grande\n	198	30	t	\N	General	0.00	15
218	Corrector	25.00	tira/papel	199	24	t	\N	General	0.00	15
219	Carpeta T/Carta	5.00	rosa\n	200	97	t	\N	General	0.00	15
220	Carpeta T/Carta	5.00	azul	201	68	t	\N	General	0.00	15
221	Carpet T/Carta	5.00	amarilla	202	100	t	\N	General	0.00	15
222	Carpeta T/Carta	5.00	beige	203	34	t	\N	General	0.00	15
223	Carpeta T/Oficio	7.00	beige	204	17	t	\N	General	0.00	15
224	Carpeta T/Oficio	7.00	azul	205	17	t	\N	General	0.00	15
225	Carpeta T/Oficio	7.00	amarilla	206	8	t	\N	General	0.00	15
226	Carpeta T/Oficio	7.00	verde	207	18	t	\N	General	0.00	15
227	Carpeta T/Oficio	7.00	rosa	208	19	t	\N	General	0.00	15
228	Carpet T/Carta	5.00	verde\n	209	80	t	\N	General	0.00	15
229	Popote	1.00	Sin descripcion	210	103	t	\N	General	0.00	15
230	Forrado	15.00	contac	211	9	t	\N	General	0.00	15
231	Forrado	25.00	plastico vinil	212	43	t	\N	General	0.00	15
232	Forrado	20.00	contac + papel lustre	213	21	t	\N	General	0.00	15
233	Cuaderno Profecional Cocido	75.00	raya	214	1	t	\N	General	0.00	15
234	Cuaderno Profecional Cocido	75.00	dibujo	215	1	t	\N	General	0.00	15
235	Cuaderno Profecional Cocido	75.00	cuadro chico	216	0	t	\N	General	0.00	15
236	Cuaderno Profecional Cocido	75.00	doble raya	217	1	t	\N	General	0.00	15
237	Cuaderno Profecional Cocido	70.00	cuadro aleman	218	2	t	\N	General	0.00	15
238	Transportador	15.00	Sin descripcion	219	27	t	\N	General	0.00	15
239	Transportador	25.00	360 grados	220	3	t	\N	General	0.00	15
241	Chaquira	5.00	Sin descripcion	221	47	t	\N	General	0.00	15
242	Chaquiron	5.00	Sin descripcion	222	18	t	\N	General	0.00	15
243	Lentejuela	5.00	Sin descripcion	223	38	t	\N	General	0.00	15
244	Diamantina	5.00	sobre \n	224	11	t	\N	General	0.00	15
245	Bolita Hidrogel	8.00	paq.\n	225	20	t	\N	General	0.00	15
246	Decoracion	25.00	navideño\n	226	18	t	\N	General	0.00	15
247	Estrella Ch,med,gde	20.00	paq.	227	17	t	\N	General	0.00	15
250	Etiqueta Redonda	20.00	paq.\n	230	3	t	\N	General	0.00	15
251	Etiqueta Refuerzo	20.00	para hoja recopilador	231	5	t	\N	General	0.00	15
252	Colores Cortos	20.00	Sin descripcion	232	1	t	\N	General	0.00	15
253	Papel China	2.50	rojo	233	463	t	\N	General	0.00	15
254	Impresion Color	8.00	medio ++	234	887	t	\N	General	0.00	15
255	Sobre Nomina	2.50	amarillo\n	235	84	t	\N	General	0.00	15
256	Sobre Blanco	2.50	nomina	236	50	t	\N	General	0.00	15
257	Sobre Mini	2.50	colores	237	24	t	\N	General	0.00	15
258	Sobre Mediano	3.50	colores	238	72	t	\N	General	0.00	15
259	Sobre Grande	5.00	colores	239	19	t	\N	General	0.00	15
260	Sobre Cumple	13.00	carton	240	4	t	\N	General	0.00	15
261	Sobre Cumple	5.00	papel	241	17	t	\N	General	0.00	15
262	Papel China	2.50	verde bandera	242	731	t	\N	General	0.00	15
263	Papel China	2.50	blanco\n	243	477	t	\N	General	0.00	15
264	Caja Anillo	15.00	chica	244	14	t	\N	General	0.00	15
265	Caja Anillo	20.00	mediana\n	245	18	t	\N	General	0.00	15
266	Caja Anillo	30.00	grande	246	1	t	\N	General	0.00	15
267	Vela Magica	26.00	Sin descripcion	247	34	t	\N	General	0.00	15
270	Palo	0.75	cuadrado	250	800	t	\N	General	0.00	15
271	Bola Unicel	1.00	# 00	251	335	t	\N	General	0.00	15
272	Bola Unicel	1.00	#0	252	87	t	\N	General	0.00	15
273	Bola Unicel	1.50	#1	253	55	t	\N	General	0.00	15
274	Bola Unicel	1.50	#1-A	254	89	t	\N	General	0.00	15
276	Bola Unicel	3.50	# 3-A\n	256	56	t	\N	General	0.00	15
277	Bola Unicel	4.00	#4	257	19	t	\N	General	0.00	15
278	Bola Unicel	6.00	#5	258	31	t	\N	General	0.00	15
279	Bola Unicel	7.00	#5-A	259	28	t	\N	General	0.00	15
280	Bola Unicel	8.00	#7	260	8	t	\N	General	0.00	15
281	Bola Unicel	12.00	#8	261	4	t	\N	General	0.00	15
282	Bola Unicel	16.00	#9	262	9	t	\N	General	0.00	15
283	Bola Unicel	25.00	#10	263	9	t	\N	General	0.00	15
284	Bola Unicel	35.00	#11	264	3	t	\N	General	0.00	15
285	Bola Unicel	50.00	#12	265	0	t	\N	General	0.00	15
286	Godete	30.00	grande	266	2	t	\N	General	0.00	15
287	Plato Chico	3.00	carton	267	18	t	\N	General	0.00	15
288	Tabla	10.00	20x20	268	25	t	\N	General	0.00	15
289	Tabla	13.00	20x25	269	2	t	\N	General	0.00	15
290	Tabla	15.00	25x25	270	1	t	\N	General	0.00	15
291	Tabla	20.00	30x30	271	20	t	\N	General	0.00	15
292	Tabla	30.00	30x40	272	2	t	\N	General	0.00	15
293	Tabla	35.00	40x40	273	3	t	\N	General	0.00	15
295	Pincel P.fino	8.00	#1	275	13	t	\N	General	0.00	15
296	Pincel P.fino	8.00	#2	276	18	t	\N	General	0.00	15
297	Pincel P.fino	8.00	#3	277	23	t	\N	General	0.00	15
298	Pincel P.fino	9.00	#4	278	13	t	\N	General	0.00	15
299	Pincel P.fino	9.00	#5	279	15	t	\N	General	0.00	15
300	Pincel P.fino	10.00	#7	280	7	t	\N	General	0.00	15
301	Pincel P.fino	10.00	#6	281	19	t	\N	General	0.00	15
302	Pincel P.fino	12.00	#9	282	6	t	\N	General	0.00	15
303	Pincel P.fino	11.00	#10	283	13	t	\N	General	0.00	15
304	Pincel P.fino	14.00	#12	284	5	t	\N	General	0.00	15
305	Pincel P.cuadrada	8.00	#2	285	14	t	\N	General	0.00	15
306	Pincel P.cuadrada	8.00	#4	286	17	t	\N	General	0.00	15
307	Pincel P.cuadrada	9.00	#6	287	7	t	\N	General	0.00	15
308	Pincel P.cuadrada	10.00	#8	288	14	t	\N	General	0.00	15
309	Pincel P.cuadrada	11.00	#10	289	36	t	\N	General	0.00	15
310	Pincel P.cuadrada	14.00	#12	290	37	t	\N	General	0.00	15
311	Brocha	25.00	1"	291	2	t	\N	General	0.00	15
313	Brocha	35.00	2 1/2"	293	4	t	\N	General	0.00	15
314	Pincel	15.00	grande 	294	8	t	\N	General	0.00	15
315	Gis	15.00	blanco	295	8	t	\N	General	0.00	15
316	Gis	20.00	color	296	9	t	\N	General	0.00	15
317	Plastilina Barra	17.00	cafe	297	4	t	\N	General	0.00	15
318	Plastilina Barra	17.00	carne	298	5	t	\N	General	0.00	15
319	Plastilina Barra	17.00	amarilla	299	5	t	\N	General	0.00	15
320	Plastilina Barra	17.00	gris	300	5	t	\N	General	0.00	15
321	Plastilina Barra	17.00	azul cielo	301	4	t	\N	General	0.00	15
322	Plastilina Barra	15.00	azul medio	302	5	t	\N	General	0.00	15
323	Plastilina Barra	17.00	azul rey	303	8	t	\N	General	0.00	15
324	Plastilina Barra	17.00	verde limon	304	4	t	\N	General	0.00	15
325	Plastilina Barra	17.00	verde bandera	305	4	t	\N	General	0.00	15
326	Plastilina Barra	17.00	blanco	306	11	t	\N	General	0.00	15
327	Plastilina Barra	17.00	morado	307	5	t	\N	General	0.00	15
328	Plastilina Barra	17.00	rosa	308	10	t	\N	General	0.00	15
329	Plastilina Barra	17.00	roja	309	8	t	\N	General	0.00	15
330	Plastilina Barra	17.00	negra	310	10	t	\N	General	0.00	15
331	Plastilina Caja	30.00	color pastel	311	2	t	\N	General	0.00	15
333	Plastilina Caja	30.00	colores primarios	313	7	t	\N	General	0.00	15
334	Plastilina Caja	30.00	fluorecentes	314	3	t	\N	General	0.00	15
336	Cojin Sello	65.00	chico negro y azul	316	1	t	\N	General	0.00	15
337	Cojin Sello	75.00	grande azul y negro	317	1	t	\N	General	0.00	15
339	Pintura Politec 20 Ml.	17.00	blanca 	319	12	t	\N	General	0.00	15
340	Pintura Politec 20 Ml.	17.00	cafe	320	16	t	\N	General	0.00	15
342	Pintura Politec 20 Ml.	17.00	roja	322	19	t	\N	General	0.00	15
343	Pintura Politec 20 Ml.	17.00	negra	323	4	t	\N	General	0.00	15
349	Pintura Politec 20 Ml.	17.00	azul	329	22	t	\N	General	0.00	15
352	Pintura Politec 20 Ml.	17.00	rosa	332	13	t	\N	General	0.00	15
354	Pintura Politec 20 Ml.	17.00	naranja	334	5	t	\N	General	0.00	15
355	Pintura Politec 20 Ml.	17.00	gris	335	6	t	\N	General	0.00	15
359	Pintura Politec 20 Ml.	17.00	carne	339	4	t	\N	General	0.00	15
360	Pintura Politec 20 Ml.	30.00	plata	340	1	t	\N	General	0.00	15
361	Pintura Politec 20 Ml.	30.00	oro	341	2	t	\N	General	0.00	15
362	Pintura Politec 20 Ml.	30.00	bronce	342	3	t	\N	General	0.00	15
367	Pintura Baco	10.00	color	347	30	t	\N	General	0.00	15
368	Mica	7.00	11 x 7.5 cm	348	20	t	\N	General	0.00	15
369	Mica	7.00	10 x 8	349	23	t	\N	General	0.00	15
370	Mica	9.00	9.5 x 12.5	350	36	t	\N	General	0.00	15
371	Mica	10.00	10 x 13.5	351	25	t	\N	General	0.00	15
372	Mica	12.00	15 x 9.5	352	30	t	\N	General	0.00	15
373	Mica	10.00	12.6 x 10.2	353	10	t	\N	General	0.00	15
374	Mica	7.00	8.7 x 11.5	354	10	t	\N	General	0.00	15
375	Colores Pastel	100.00	barra profesional colores pasteles	355	1	t	\N	General	0.00	15
376	Pasta Moldeable	125.00	terracota	356	1	t	\N	General	0.00	15
377	Crayon	15.00	industrial	357	5	t	\N	General	0.00	15
378	Crayones	60.00	amazcolor c/24pza	358	3	t	\N	General	0.00	15
379	Crayones	80.00	giratorios c/8pza	359	1	t	\N	General	0.00	15
380	Crayones	75.00	giratorio c/12 pza	360	1	t	\N	General	0.00	15
381	Comanda	4.50	chica	361	26	t	\N	General	0.00	15
382	Crayones	35.00	gruesos redondos c/8 pza\n	362	2	t	\N	General	0.00	15
383	Crayones	25.00	gruesos redondos c/6 pza\n	363	6	t	\N	General	0.00	15
384	Crayones	45.00	gruesos redondos amigos	364	1	t	\N	General	0.00	15
385	Crayones	50.00	grueso triangular MAE C/12	365	0	t	\N	General	0.00	15
386	Crayones	75.00	GRUESOS TRIANGULARES C/12 CRAYOLA	366	0	t	\N	General	0.00	15
387	Crayones	20.00	delgado c/6 pza	367	2	t	\N	General	0.00	15
388	Crayones	25.00	delgado c/8 pza	368	2	t	\N	General	0.00	15
389	Compas	40.00	jumbo	369	1	t	\N	General	0.00	15
390	Compas	35.00	barrilito/mae/scool	370	5	t	\N	General	0.00	15
392	Compas y Transportador	50.00	zin zin	372	1	t	\N	General	0.00	15
393	Marcador	80.00	para vidrio	373	1	t	\N	General	0.00	15
394	Pegamento Uhu	60.00	mediano	374	2	t	\N	General	0.00	15
395	Pegamento 2000	70.00	amarillo	375	0	t	\N	General	0.00	15
396	Kola Loca	20.00	economica	376	1	t	\N	General	0.00	15
397	Grapas # 26	15.00	caja chica	377	3	t	\N	General	0.00	15
398	Grapa # 10	15.00	caja chica	378	5	t	\N	General	0.00	15
399	Grapa # 26	35.00	caja grande	379	5	t	\N	General	0.00	15
400	Puntilla	15.00	# 0.5	380	30	t	\N	General	0.00	15
401	Puntilla	15.00	# 0.7	381	18	t	\N	General	0.00	15
402	Puntilla	30.00	# 0.9	382	1	t	\N	General	0.00	15
403	Navaja Cutter	22.00	chica	383	2	t	\N	General	0.00	15
404	Navaja Cutter	33.00	grande	384	4	t	\N	General	0.00	15
405	Cuenta Facil	25.00	Sin descripcion	385	2	t	\N	General	0.00	15
406	Pintura Oleo	65.00	negro	386	1	t	\N	General	0.00	15
407	Foliadora Fecha	40.00	Sin descripcion	387	1	t	\N	General	0.00	15
408	Tinta China	35.00	azul	388	1	t	\N	General	0.00	15
409	Tinta China	35.00	negro	389	1	t	\N	General	0.00	15
410	Tinta China	35.00	amarillo	390	1	t	\N	General	0.00	15
411	Tinta China	35.00	blanco	391	1	t	\N	General	0.00	15
412	Tinta China	35.00	cafe	392	1	t	\N	General	0.00	15
413	Broche	6.00	para gafet	393	27	t	\N	General	0.00	15
414	Cordon P/Gafet	20.00	plano reforsado	394	8	t	\N	General	0.00	15
415	Papel Lustre	7.00	amarillo	395	19	t	\N	General	0.00	15
416	Plastico Vinil	25.00	mts.	396	61	t	\N	General	0.00	15
417	Mapa	3.00	blanco/negro	397	947	t	\N	General	0.00	15
418	Lamina	5.00	Sin descripcion	398	928	t	\N	General	0.00	15
419	Colores	40.00	lapizazo c/12	399	2	t	\N	General	0.00	15
420	Colores	45.00	jumbo c/12	400	1	t	\N	General	0.00	15
421	Colores	50.00	jocar c/12 borrable	401	3	t	\N	General	0.00	15
424	Colores	120.00	paper mate c/15	404	2	t	\N	General	0.00	15
426	Colores Jumbo	105.00	bacoiris c/12	406	2	t	\N	General	0.00	15
427	Acuarela	20.00	chica c/8	407	1	t	\N	General	0.00	15
428	Acuarela	40.00	c/12 y c/16 colores	408	6	t	\N	General	0.00	15
429	Cinta Metrica	10.00	tira plastica	409	4	t	\N	General	0.00	15
430	Broche Baco	2.50	Sin descripcion	410	117	t	\N	General	0.00	15
431	Diccionario	40.00	mi primer diccionario	411	1	t	\N	General	0.00	15
432	Diccionario	110.00	ingles/español larusso	412	1	t	\N	General	0.00	15
433	Diccionario	85.00	basico	413	1	t	\N	General	0.00	15
434	Tachuela	1.50	suelta	414	100	t	\N	General	0.00	15
435	Aguja Estambrera	3.50	plastico	415	17	t	\N	General	0.00	15
436	Aguja	2.50	#1	416	91	t	\N	General	0.00	15
437	Aguja Estambrera	5.00	 metal corta y larga	417	30	t	\N	General	0.00	15
438	Aguja	2.50	para chaquira	418	10	t	\N	General	0.00	15
440	Seguro	0.50	# 0	420	92	t	\N	General	0.00	15
441	Seguro	1.00	# 1	421	35	t	\N	General	0.00	15
442	Seguro	1.50	# 2	422	8	t	\N	General	0.00	15
443	Seguro	2.00	# 3	423	32	t	\N	General	0.00	15
444	Seguro	3.00	# 4	424	45	t	\N	General	0.00	15
445	Seguro	4.00	# 5	425	48	t	\N	General	0.00	15
446	Iman Plastico	2.00	chico 	426	17	t	\N	General	0.00	15
447	Iman Plastico	3.00	mediano 	427	18	t	\N	General	0.00	15
448	Iman Plastico	4.00	grande 	428	10	t	\N	General	0.00	15
449	Iman Redondo	3.00	chico	429	25	t	\N	General	0.00	15
450	Iman Redondo	5.00	mediano	430	10	t	\N	General	0.00	15
451	Hilo Elastico	3.00	mts.	431	22	t	\N	General	0.00	15
452	Hilo Elastico	29.00	rollo	432	0	t	\N	General	0.00	15
453	Broche Aleman	1.00	corto	433	84	t	\N	General	0.00	15
454	Broche Aleman	1.50	largo	434	45	t	\N	General	0.00	15
455	Ojo Movible	2.50	# 20	435	20	t	\N	General	0.00	15
456	Ojo Movible	2.00	# 15	436	20	t	\N	General	0.00	15
457	Ojo Movible	2.00	# 10	437	100	t	\N	General	0.00	15
458	Ojo Movible	2.00	# 14x 19	438	14	t	\N	General	0.00	15
459	Ojo Movible	2.50	# 18	439	15	t	\N	General	0.00	15
460	Ojo Movible	2.00	# 14	440	20	t	\N	General	0.00	15
461	Ojo Movible	2.00	#8 color	441	9	t	\N	General	0.00	15
462	Ojo Movible	1.50	# 8 ovalado	442	17	t	\N	General	0.00	15
463	Ojo Movible	1.50	# 8 blanco	443	22	t	\N	General	0.00	15
464	Ojo Movible	1.50	# 7	444	38	t	\N	General	0.00	15
465	Ojo Movible	1.00	# 6	445	100	t	\N	General	0.00	15
466	Ojo Movible	1.00	# 3	446	49	t	\N	General	0.00	15
499	Postit	20.00	Sin descripcion	477	7	t	\N	General	0.00	15
500	Postit	25.00	Sin descripcion	479	34	t	\N	General	0.00	15
501	Postit	45.00	Sin descripcion	480	3	t	\N	General	0.00	15
502	Sticker	12.00	varios	481	60	t	\N	General	0.00	15
503	Sticker	15.00	varios	482	83	t	\N	General	0.00	15
504	Sticker	10.00	varios	483	2	t	\N	General	0.00	15
505	Sticker	13.00	varios	484	26	t	\N	General	0.00	15
506	Sticker	14.00	varios	485	19	t	\N	General	0.00	15
507	Silicon Liquido	20.00	chico 30 ml.	486	13	t	\N	General	0.00	15
508	Silicon Liquido	30.00	mediano 60 ml.	487	7	t	\N	General	0.00	15
509	Silicon Liquido	45.00	grande 100 ml.	488	10	t	\N	General	0.00	15
511	Ojo Movible	5.50	#40	490	12	t	\N	General	0.00	15
512	Ojo Movible	4.00	#24	491	36	t	\N	General	0.00	15
513	Caja Clip	17.00	c/100 pza	492	9	t	\N	General	0.00	15
514	Pistola de Silicon	85.00	Sin descripcion	493	6	t	\N	General	0.00	15
515	Cascabel	3.50	#18	494	18	t	\N	General	0.00	15
516	Cascabel	3.00	#17	495	40	t	\N	General	0.00	15
517	Cascabel	2.00	#14	496	30	t	\N	General	0.00	15
518	Cascabel	2.50	#16	497	46	t	\N	General	0.00	15
519	Cartulina	15.00	azul cielo	498	34	t	\N	General	0.00	15
520	Escaneo	5.00	por hoja	499	928	t	\N	General	0.00	15
522	Yute	3.00	delgado	501	4	t	\N	General	0.00	15
523	Yute	5.00	grueso	502	0	t	\N	General	0.00	15
524	Hoja Calcamonia	10.00	t/carta	503	27	t	\N	General	0.00	15
525	Cubo	45.00	15x15 	504	9	t	\N	General	0.00	15
526	Fomy T/Carta	4.50	negro	505	25	t	\N	General	0.00	15
527	Fomy T/Carta	4.50	amarillo canario	506	37	t	\N	General	0.00	15
528	Papel Crepe	10.00	blanco\n	507	10	t	\N	General	0.00	15
529	Papel Crepe	10.00	rojo	508	20	t	\N	General	0.00	15
530	Papel Crepe	10.00	verde bandera	509	13	t	\N	General	0.00	15
531	Papel Crepe	10.00	verde limon	510	4	t	\N	General	0.00	15
532	Tinta para Cojin	55.00	azul stafford	511	2	t	\N	General	0.00	15
533	Tinta para Cojin	55.00	morada stanfford	512	1	t	\N	General	0.00	15
534	Tinta para Cojin	55.00	rojo stanfford	513	1	t	\N	General	0.00	15
535	Tinta para Cojin	60.00	negra azor	514	1	t	\N	General	0.00	15
536	Calculadora	120.00	cientifica indra	515	1	t	\N	General	0.00	15
537	Calculadora	100.00	cientifica buytiti	516	2	t	\N	General	0.00	15
539	Calculadora	65.00	basica runzon	518	1	t	\N	General	0.00	15
540	Calculadora	85.00	basica colores runzon 	519	3	t	\N	General	0.00	15
541	Calculadora	95.00	basica jumbo	520	1	t	\N	General	0.00	15
542	Lienzo	90.00	30x30	521	6	t	\N	General	0.00	15
543	Masa Moldeable	40.00	plasti kids	522	4	t	\N	General	0.00	15
544	Nieve Artificial	45.00	spray	523	1	t	\N	General	0.00	15
545	Vela	18.00	larga suelta	524	15	t	\N	General	0.00	15
546	Bolsa Ziplot	2.00	16x 17	525	43	t	\N	General	0.00	15
547	Resistol Liquido	10.00	transparente  50ml.	526	2	t	\N	General	0.00	15
548	Resistol Liquido	20.00	pelikan  30 ml.\n	527	3	t	\N	General	0.00	15
549	Resistol Liquido	40.00	resistol 850 55g.	528	3	t	\N	General	0.00	15
550	Resistol Liquido	25.00	resistol 850 35 g\n	529	2	t	\N	General	0.00	15
551	Resistol Liquido	25.00	zadaco 125 ml.	530	5	t	\N	General	0.00	15
552	Resistol Liquido	20.00	super kole 60g	531	2	t	\N	General	0.00	15
553	Resistol Liquido	10.00	super kole 30g\n	532	0	t	\N	General	0.00	15
554	Resistol Liquido	45.00	zadaco/amigos 250 ml.	533	1	t	\N	General	0.00	15
555	Pegamento Barra	15.00	chico	534	45	t	\N	General	0.00	15
556	Pegamento Barra	25.00	pritt chico	535	7	t	\N	General	0.00	15
557	Pegamento Barra	35.00	mediano	536	25	t	\N	General	0.00	15
558	Pegamento Barra	45.00	pritt mediano	537	2	t	\N	General	0.00	15
559	Pegamento Barra	55.00	jumbo	538	10	t	\N	General	0.00	15
560	Pegamento Barra	80.00	pritt jumbo	539	3	t	\N	General	0.00	15
561	Etiqueta #24	30.00	fluorecente/blanca	540	2	t	\N	General	0.00	15
562	Etiqueta #15	30.00	blanca	541	2	t	\N	General	0.00	15
563	Etiqueta #7	30.00	blanca	542	3	t	\N	General	0.00	15
564	Etiqueta #23	30.00	blanca	543	1	t	\N	General	0.00	15
565	Etiqueta #6	30.00	blanca/fluorecente	544	6	t	\N	General	0.00	15
566	Etiqueta #8	30.00	fluorecente	545	1	t	\N	General	0.00	15
567	Etiqueta #4	30.00	blanco/fluorecente	546	3	t	\N	General	0.00	15
568	Etiqueta #1	30.00	blanca/fluorecente	547	1	t	\N	General	0.00	15
569	Clip Mariposa	2.50	Sin descripcion	548	20	t	\N	General	0.00	15
570	Poliza de Cheque	45.00	block	549	3	t	\N	General	0.00	15
571	Sobre Oficio	4.00	blanco	550	34	t	\N	General	0.00	15
572	Tarjeta de Clientes	1.00	Sin descripcion	551	60	t	\N	General	0.00	15
573	Gis Patrio	15.00	para cara	552	18	t	\N	General	0.00	15
574	Vale de Caja	20.00	Sin descripcion	553	2	t	\N	General	0.00	15
575	Ficha Bibliografica	0.50	chica rayada	554	450	t	\N	General	0.00	15
576	Ficha Bibliografica	0.50	chica blanca	555	248	t	\N	General	0.00	15
577	Ficha Bibliografica	1.00	mediana rayada	556	218	t	\N	General	0.00	15
578	Ficha Bibliografica	1.00	mediana blanca	557	278	t	\N	General	0.00	15
579	Ficha Bibliografica	1.50	grande blanca	558	235	t	\N	General	0.00	15
580	Ficha Bibliografica	1.50	grande rayada	559	84	t	\N	General	0.00	15
581	Pagare	2.50	pieza	560	80	t	\N	General	0.00	15
582	Recibo de Renta	35.00	block	561	2	t	\N	General	0.00	15
583	Recibo General	35.00	block	562	2	t	\N	General	0.00	15
584	Block de Notas	35.00	original 1-F	563	2	t	\N	General	0.00	15
585	Block de Notas	35.00	duplicado 2-F	564	3	t	\N	General	0.00	15
586	Block de Notas	45.00	autocopiable	565	3	t	\N	General	0.00	15
587	Block de Notas	20.00	duplicado 1/4-F	566	3	t	\N	General	0.00	15
588	Block de Notas	20.00	original 5-C	567	4	t	\N	General	0.00	15
589	Recopilador	95.00	Sin descripcion	568	3	t	\N	General	0.00	15
590	Archivero Expandible	100.00	negro	569	1	t	\N	General	0.00	15
591	Fieltro	7.00	hoja 	570	48	t	\N	General	0.00	15
592	Libro para Colorear	90.00	jumbo	571	4	t	\N	General	0.00	15
593	Libro para Colorear	40.00	mediano	572	6	t	\N	General	0.00	15
594	Libro para Colorear	15.00	delgado	573	42	t	\N	General	0.00	15
595	Cuento	20.00	cuento,adivinansa,travalenguas	574	1	t	\N	General	0.00	15
596	Libro para Colorear	45.00	arte pixel	575	2	t	\N	General	0.00	15
597	Libro de Mandala	20.00	Sin descripcion	576	2	t	\N	General	0.00	15
598	Libro Sopa de Letras	35.00	delgado	577	3	t	\N	General	0.00	15
599	Libro Sopa de Letras	50.00	grueso	578	1	t	\N	General	0.00	15
601	Dado	5.00	chico	579	32	t	\N	General	0.00	15
602	Dado	10.00	mediano	580	8	t	\N	General	0.00	15
603	Dado	12.00	grande	581	6	t	\N	General	0.00	15
604	Carrillera	40.00	par	582	2	t	\N	General	0.00	15
605	Globo # 260	2.00	suelto	583	86	t	\N	General	0.00	15
606	Globo T/Jumbo	10.00	suelto	584	4	t	\N	General	0.00	15
607	Cuaderno Profecional 200 Hojas	150.00	estrella c.grande	585	1	t	\N	General	0.00	15
608	Cuaderno Profecional 200 Hojas	105.00	 scribe c.grande\n	586	2	t	\N	General	0.00	15
609	Cuaderno Profecional 200 Hojas	105.00	scribe c.chico	587	2	t	\N	General	0.00	15
610	Cuaderno Profecional 200 Hojas	160.00	monky c.grande,raya	588	2	t	\N	General	0.00	15
611	Letrero	20.00	se vende jumbo	589	1	t	\N	General	0.00	15
612	Letrero	20.00	se renta jumbo	590	1	t	\N	General	0.00	15
613	Tabla Perfocel	20.00	20x20	591	1	t	\N	General	0.00	15
617	Etiqueta #21	30.00	blanca	595	1	t	\N	General	0.00	15
618	Etiqueta #25	30.00	blanca	596	1	t	\N	General	0.00	15
619	Etiqueta #20	30.00	blanca/fluorecente	597	3	t	\N	General	0.00	15
620	Etiqueta #13	30.00	blanca	598	2	t	\N	General	0.00	15
621	Block Carta	50.00	estrella c.chico	599	1	t	\N	General	0.00	15
622	Block Carta	40.00	estrella raya	600	1	t	\N	General	0.00	15
623	Block Carta	40.00	estrella c.grande	601	1	t	\N	General	0.00	15
624	Sobre 1/2 Carta	15.00	plastico	602	7	t	\N	General	0.00	15
625	Cuaderno Profecional	45.00	pautado	603	1	t	\N	General	0.00	15
626	Cuaderno Profecional	35.00	doble raya	604	1	t	\N	General	0.00	15
627	Cuaderno Profecional	35.00	mixto	605	2	t	\N	General	0.00	15
628	Cuaderno Profecional	35.00	dibujo	606	4	t	\N	General	0.00	15
629	Cuaderno Profecional Pasta Dura	55.00	dibujo	607	1	t	\N	General	0.00	15
630	Cuaderno Profecional Pasta Dura	55.00	c.grande	608	5	t	\N	General	0.00	15
631	Cuaderno Profecional	35.00	c.grande	609	2	t	\N	General	0.00	15
632	Cuaderno Profecional	35.00	raya	610	10	t	\N	General	0.00	15
633	Cuaderno Profecional Pasta Dura	55.00	c.chico	611	4	t	\N	General	0.00	15
634	Cuaderno Profecional	35.00	c.chico	612	4	t	\N	General	0.00	15
635	Cuaderno Francesa	36.00	dibujo	613	2	t	\N	General	0.00	15
636	Cuaderno Francesa	36.00	doble raya	614	3	t	\N	General	0.00	15
637	Cuaderno Francesa	40.00	c.chico	615	3	t	\N	General	0.00	15
638	Cuaderno Francesa	40.00	c.grande	616	2	t	\N	General	0.00	15
639	Cuaderno Francesa Cocido	55.00	raya	617	2	t	\N	General	0.00	15
640	Cuaderno Francesa	40.00	raya	618	4	t	\N	General	0.00	15
641	Ley Federal del Trabajo	50.00	Sin descripcion	619	1	t	\N	General	0.00	15
642	Constitucion Politica	45.00	Sin descripcion	620	0	t	\N	General	0.00	15
643	Cuaderno Italiano	24.00	pautado	621	1	t	\N	General	0.00	15
644	Cuaderno Italiano Cocido	50.00	c.aleman	622	2	t	\N	General	0.00	15
645	Cuaderno Italiano Cocido	50.00	c.chico	623	3	t	\N	General	0.00	15
647	Cuaderno Italiano	40.00	c.chico	625	1	t	\N	General	0.00	15
648	Cuaderno Italiano	35.00	dibujo	626	2	t	\N	General	0.00	15
649	Cuaderno Italiano Cocido	55.00	c.grande	627	1	t	\N	General	0.00	15
650	Cuaderno Italiano Cocido	50.00	raya	628	1	t	\N	General	0.00	15
651	Cuaderno Italiano	35.00	raya	629	2	t	\N	General	0.00	15
652	Cuaderno Italiano	35.00	doble raya	630	4	t	\N	General	0.00	15
653	Anilina	5.00	Sin descripcion	631	14	t	\N	General	0.00	15
654	Pintura Vegetal	5.00	Sin descripcion	632	23	t	\N	General	0.00	15
655	Cubo	80.00	25x25	633	1	t	\N	General	0.00	15
656	Block Tabla	95.00	 stricker	634	1	t	\N	General	0.00	15
657	Block Tabla	105.00	 scribe 	635	4	t	\N	General	0.00	15
658	Block Tabla C/Espiral	75.00	20 hojas	636	2	t	\N	General	0.00	15
659	Block Tabla C/Espiral	50.00	10 hojas	637	2	t	\N	General	0.00	15
660	Block Tabla C/Espiral	40.00	A4	638	2	t	\N	General	0.00	15
661	Carpeta T/Carta	5.00	verde	639	21	t	\N	General	0.00	15
662	Carpeta Plastica	20.00	con broche baco	640	16	t	\N	General	0.00	15
663	Carpeta con Palanca	65.00	t/carta	641	5	t	\N	General	0.00	15
664	Carpeta T/Carta	9.00	multicolor	642	86	t	\N	General	0.00	15
665	Carpeta Costilla	20.00	Sin descripcion	643	38	t	\N	General	0.00	15
666	Sobre Plastico	30.00	t/carta	644	27	t	\N	General	0.00	15
667	Sobre Plastico	35.00	t/oficio	645	60	t	\N	General	0.00	15
668	Sobre Plastico	30.00	con cierre	646	9	t	\N	General	0.00	15
669	Sobre Burbuja	42.00	amarillo	647	4	t	\N	General	0.00	15
670	Sobre T/Oficio	10.00	pegatina	648	55	t	\N	General	0.00	15
671	Sobre T/Oficio	15.00	con hilo	649	17	t	\N	General	0.00	15
672	Sobre T/Carta	8.00	pegatina	650	25	t	\N	General	0.00	15
673	Juego Geometria	75.00	vinci	651	2	t	\N	General	0.00	15
675	Acetato	5.00	t/carta	653	71	t	\N	General	0.00	15
676	Hojas de Dibujo	10.00	dibujo profesional	654	30	t	\N	General	0.00	15
677	Hojas Milimetrica	1.50	suelta	655	38	t	\N	General	0.00	15
679	Hojas Mantequilla	3.50	t/carta	657	72	t	\N	General	0.00	15
680	Hojas Mantequilla	4.50	t/oficio	658	25	t	\N	General	0.00	15
681	Hojas Mantequilla	70.00	block	659	2	t	\N	General	0.00	15
682	Papel Pasante	2.50	azul/negro	660	171	t	\N	General	0.00	15
683	Papel Pasante	3.50	t/0ficio	661	47	t	\N	General	0.00	15
684	Hojas de Recopilador	60.00	raya stricker	662	3	t	\N	General	0.00	15
685	Hojas de Recopilador	70.00	scribe raya	663	0	t	\N	General	0.00	15
686	Hojas de Recopilador	60.00	c.grande stricker	664	3	t	\N	General	0.00	15
687	Hojas de Recopilador	70.00	c.grande scribe	665	2	t	\N	General	0.00	15
688	Separadores	23.00	papel	666	7	t	\N	General	0.00	15
689	Separadores	40.00	plastico	667	1	t	\N	General	0.00	15
690	Letreros de Plastico	45.00	se vende / renta / no estacionarse	668	3	t	\N	General	0.00	15
691	Tabla Periodica	25.00	grande	669	1	t	\N	General	0.00	15
692	Tabla para Corte	95.00	tamaño A4	670	1	t	\N	General	0.00	15
693	Forro	7.00	f.francesa	671	20	t	\N	General	0.00	15
694	Forro	7.00	f.italiana	672	15	t	\N	General	0.00	15
695	Forro	7.00	profecional	673	23	t	\N	General	0.00	15
696	Forro	22.00	para carpeta t/carta	674	20	t	\N	General	0.00	15
697	Forro	28.00	para carpeta T/oficio	675	14	t	\N	General	0.00	15
698	Contrato de Arrendamiento	3.00	Sin descripcion	676	117	t	\N	General	0.00	15
699	Contrato de Compra y Venta	3.00	Sin descripcion	677	90	t	\N	General	0.00	15
700	Carta Poder	2.50	Sin descripcion	678	87	t	\N	General	0.00	15
701	Carta Responsiva	2.50	Sin descripcion	679	54	t	\N	General	0.00	15
702	Mica	15.00	t/carta	680	80	t	\N	General	0.00	15
703	Mica	18.00	t/oficio	681	8	t	\N	General	0.00	15
704	Carpeta Plastica	70.00	con 10 protectores 	682	1	t	\N	General	0.00	15
705	Cartilina	15.00	beige	683	3	t	\N	General	0.00	15
706	Cartulina	15.00	carne	684	6	t	\N	General	0.00	15
707	Cartulina	15.00	melon	685	9	t	\N	General	0.00	15
708	Hojas de Recopilador	70.00	c.chico scribe	686	1	t	\N	General	0.00	15
710	Cubo	25.00	12x 6.5	688	1	t	\N	General	0.00	15
711	Cubo	25.00	12x12	689	7	t	\N	General	0.00	15
712	Cubo	35.00	15x8	690	3	t	\N	General	0.00	15
713	Cubo	35.00	15x15 blanco	691	9	t	\N	General	0.00	15
714	Confeti	15.00	bolsa	692	2	t	\N	General	0.00	15
715	Fichas	40.00	colores	693	1	t	\N	General	0.00	15
716	Monedas y Billetes	45.00	Sin descripcion	694	1	t	\N	General	0.00	15
717	Gancho	25.00	grande	695	3	t	\N	General	0.00	15
718	Fichas	50.00	colores	696	2	t	\N	General	0.00	15
719	Gancho	40.00	chico/madera	697	4	t	\N	General	0.00	15
720	Gancho	45.00	mini colores/madera	698	4	t	\N	General	0.00	15
721	Acuarela	30.00	godete	699	2	t	\N	General	0.00	15
722	Lupa	40.00	grande	700	1	t	\N	General	0.00	15
723	Lupa	20.00	mediana	701	2	t	\N	General	0.00	15
724	Lupa	15.00	chica	702	4	t	\N	General	0.00	15
725	Chincheta	20.00	caja c/50 pza	703	4	t	\N	General	0.00	15
726	Chincheta	40.00	caja c/100 pza.\n	704	1	t	\N	General	0.00	15
727	Sujetador de Documentos	25.00	caja c/12 pza.\n	705	2	t	\N	General	0.00	15
729	Chincheta Metalico	35.00	caja c/20pza	707	1	t	\N	General	0.00	15
730	Identificador de Llaves	35.00	paq.c/4pza\n	708	7	t	\N	General	0.00	15
731	Engrapadora	55.00	mini	709	1	t	\N	General	0.00	15
732	Gancho	35.00	figuras	710	4	t	\N	General	0.00	15
733	Lampara	20.00	mediana	711	2	t	\N	General	0.00	15
734	Rompecabezas	7.00	chico	712	28	t	\N	General	0.00	15
735	Set de Costura	30.00	Sin descripcion	713	5	t	\N	General	0.00	15
737	Lampara	25.00	grande	715	1	t	\N	General	0.00	15
740	Engrapadora	70.00	mediana\n	718	1	t	\N	General	0.00	15
743	Llavero de Multiplicar	50.00	personaje	721	2	t	\N	General	0.00	15
744	Borrador Clip	30.00	personaje	722	4	t	\N	General	0.00	15
745	Borrador Clip	22.00	colores	723	2	t	\N	General	0.00	15
746	Borrador Clip	35.00	con repuesto	724	3	t	\N	General	0.00	15
747	Pegatina	35.00	de piedritas	725	0	t	\N	General	0.00	15
748	Pegatina	30.00	de piedritas	726	14	t	\N	General	0.00	15
751	Pluma Paper Mate	80.00	paq.colores	729	2	t	\N	General	0.00	15
752	Cuenta Facil	20.00	cojin	730	2	t	\N	General	0.00	15
753	Cuenta Facil	30.00	cojin	731	1	t	\N	General	0.00	15
754	Lapicero	30.00	set c/respuesto	732	9	t	\N	General	0.00	15
755	Acerrin	9.00	paq.chico	733	48	t	\N	General	0.00	15
756	Acerrin	35.00	200gr.	734	1	t	\N	General	0.00	15
757	Arbolitos	4.50	variedad	735	61	t	\N	General	0.00	15
758	Animalitos	16.00	variedad	736	16	t	\N	General	0.00	15
759	Mariposas	30.00	paq.	737	2	t	\N	General	0.00	15
760	Confeti	20.00	jumbo P/globo	738	7	t	\N	General	0.00	15
762	Postit	36.00	plastificada	740	2	t	\N	General	0.00	15
763	Uñas	15.00	p/niña	741	32	t	\N	General	0.00	15
765	Liguitas	15.00	p/pelo colores	743	24	t	\N	General	0.00	15
766	Dado	15.00	gigante	744	4	t	\N	General	0.00	15
767	Pirinola	15.00	gigante	745	7	t	\N	General	0.00	15
768	Pandero	27.00	juguete	746	2	t	\N	General	0.00	15
769	Bolsa de Regalo	30.00	grande bautizo	747	3	t	\N	General	0.00	15
770	Copia B/N	3.00	t/oficio	748	3	t	\N	General	0.00	15
771	Moño Patrio	28.00	Sin descripcion	749	4	t	\N	General	0.00	15
772	Bolis	15.00	varios sabores	750	19	t	\N	General	0.00	15
773	Bolsa de Regalo	30.00	grande niña	751	5	t	\N	General	0.00	15
774	Bolsa de Regalo	55.00	gigante varios	752	8	t	\N	General	0.00	15
775	Papel Picado	7.00	variedad 	753	43	t	\N	General	0.00	15
776	Moño Mini	4.50	metalico	754	91	t	\N	General	0.00	15
777	Moño Chico	6.00	mano	755	35	t	\N	General	0.00	15
778	Moño Mediano	7.00	mano\n	756	16	t	\N	General	0.00	15
779	Moño Gande	9.00	mano\n	757	45	t	\N	General	0.00	15
780	Papel de Regalo	9.00	niño	758	33	t	\N	General	0.00	15
781	Papel de Regalo	9.00	niña	759	94	t	\N	General	0.00	15
782	Papel de Regalo	9.00	dama	760	120	t	\N	General	0.00	15
783	Papel de Regalo	9.00	caballero	761	90	t	\N	General	0.00	15
784	Papel de Regalo	9.00	bebe	762	122	t	\N	General	0.00	15
785	Papel de Regalo	9.00	boda	763	71	t	\N	General	0.00	15
786	Papel de Regalo	10.00	liso	764	57	t	\N	General	0.00	15
787	Papel de Regalo	14.00	coreano	765	22	t	\N	General	0.00	15
788	Papel de Regalo	12.00	grofado y holografico	766	64	t	\N	General	0.00	15
789	Envoltura	10.00	ch-med (1 pliego )	767	983	t	\N	General	0.00	15
790	Envoltura	15.00	gde ( 2 pliegos )	768	989	t	\N	General	0.00	15
791	Envoltura	20.00	jumbo y gigante (+ 3pliegos )	769	988	t	\N	General	0.00	15
792	Cinta Diurex	5.00	chica	770	64	t	\N	General	0.00	15
793	Cinta Diurex	12.00	mediana	771	3	t	\N	General	0.00	15
794	Cinta Diurex	15.00	grande	772	15	t	\N	General	0.00	15
795	Borrador	5.00	blanco chico	773	11	t	\N	General	0.00	15
796	Borrador	10.00	migajon mediano	774	147	t	\N	General	0.00	15
797	Borrador	15.00	mijagon grande	775	24	t	\N	General	0.00	15
798	Pluma Gel	20.00	rosa	776	4	t	\N	General	0.00	15
799	Papel Lustre	7.00	azul cielo	777	28	t	\N	General	0.00	15
800	Acta Nacimiento	110.00	Sin descripcion	778	91	t	\N	General	0.00	15
801	Papel China	2.50	naranja	779	114	t	\N	General	0.00	15
802	Papel China	2.50	amarillo	780	105	t	\N	General	0.00	15
803	Pluma P.mediana	7.00	azul	781	109	t	\N	General	0.00	15
804	Pluma P.mediana	7.00	negra	782	68	t	\N	General	0.00	15
805	Pluma P.mediana	7.00	roja	783	40	t	\N	General	0.00	15
806	Loteria	50.00	20 cartas	784	1	t	\N	General	0.00	15
807	Loteria	38.00	10 cartas	785	1	t	\N	General	0.00	15
808	Comprobante de Gastos	20.00	block	786	2	t	\N	General	0.00	15
809	Espejitos	20.00	Sin descripcion	787	13	t	\N	General	0.00	15
812	Libreta Grande	21.00	c/espiral	790	11	t	\N	General	0.00	15
814	Libreta de Notas	45.00	mediana c/iman	792	2	t	\N	General	0.00	15
815	Libreta de Notas	50.00	grande c/iman	793	2	t	\N	General	0.00	15
816	Libreta de Notas	50.00	Sin descripcion	794	1	t	\N	General	0.00	15
817	Block 1/2 Carta	25.00	scool c.chico	795	1	t	\N	General	0.00	15
819	Libreta Taquigrafia	25.00	chica	797	3	t	\N	General	0.00	15
820	Libreta Taquigrafia	20.00	striker	798	3	t	\N	General	0.00	15
822	Pagare	50.00	block	800	2	t	\N	General	0.00	15
823	Tarjetita de Regalo	2.50	de:  para:	801	54	t	\N	General	0.00	15
824	Caja #00	5.00	forrada	802	2	t	\N	General	0.00	15
825	Pluma P.fino	9.00	rojo	803	196	t	\N	General	0.00	15
826	Pluma P.fino	9.00	azul\n	804	148	t	\N	General	0.00	15
827	Pluma P.fino	9.00	negra	805	96	t	\N	General	0.00	15
828	Pluma P.fino	9.00	colores	806	21	t	\N	General	0.00	15
829	Pluma Retractil	12.00	negra	807	24	t	\N	General	0.00	15
830	Pluma Retractil	12.00	azul	808	39	t	\N	General	0.00	15
831	Pluma Retractil	12.00	roja	809	20	t	\N	General	0.00	15
832	Pluma Gel	15.00	azul	810	19	t	\N	General	0.00	15
833	Pluma Gel	15.00	negra zin zin	811	1	t	\N	General	0.00	15
834	Pluma Gel	15.00	negra	812	14	t	\N	General	0.00	15
835	Pluma Gel	15.00	roja	813	13	t	\N	General	0.00	15
836	Marcador Pintarron	40.00	duo	814	13	t	\N	General	0.00	15
837	Engrapadora	120.00	jumbo	815	2	t	\N	General	0.00	15
842	Marcador Permanente	35.00	negro jumbo	170	8	t	\N	General	0.00	15
843	Marcador Permanente	25.00	doble punta p.gruesa	819	39	t	\N	General	0.00	15
844	Marcador Permanente	20.00	negro,azul,rojo	820	25	t	\N	General	0.00	15
845	Marcador Acrilico	20.00	colores	821	0	t	\N	General	0.00	15
846	Marcador Permanente	30.00	negro G-201	822	23	t	\N	General	0.00	15
847	Borrador	15.00	blanco grande	823	20	t	\N	General	0.00	15
848	Borrador	10.00	triangular	824	32	t	\N	General	0.00	15
849	Marcador P.mediana	35.00	sharpie negro	825	2	t	\N	General	0.00	15
850	Marcador P.mediana	35.00	sharpie color	826	9	t	\N	General	0.00	15
852	Marcador P.mediana	30.00	metalicos	827	15	t	\N	General	0.00	15
853	Marcador Permanente	35.00	blanco	828	8	t	\N	General	0.00	15
854	Marcador P.mediana	25.00	negro economico	829	7	t	\N	General	0.00	15
855	Marcador P.mediana	25.00	color economino	830	8	t	\N	General	0.00	15
856	Pluma Gel	40.00	blanca	831	4	t	\N	General	0.00	15
857	Marcador Doble Punta	25.00	ngro,azul,rojo	832	7	t	\N	General	0.00	15
861	Rotulador	15.00	color y negro	836	24	t	\N	General	0.00	15
862	Cinta Maskitape	15.00	18x10mt.	837	3	t	\N	General	0.00	15
863	Cinta Maskitape	10.00	12x10mt.	838	3	t	\N	General	0.00	15
864	Borrador Clip	20.00	figuras	839	3	t	\N	General	0.00	15
865	Lapiz de Puntilla	15.00	Sin descripcion	840	13	t	\N	General	0.00	15
866	Marcatexto	20.00	grueso	841	22	t	\N	General	0.00	15
867	Marcatexto	15.00	delgado	842	26	t	\N	General	0.00	15
868	Marcador Pintarron	20.00	economico	843	38	t	\N	General	0.00	15
869	Marcador Pintarron	35.00	expo	844	9	t	\N	General	0.00	15
870	Marcador Pintarron	30.00	shely, max, artline	845	4	t	\N	General	0.00	15
871	Lapicero	20.00	.5	846	22	t	\N	General	0.00	15
872	Lapicero	20.00	.9	847	9	t	\N	General	0.00	15
873	Lapicero	20.00	.7	848	9	t	\N	General	0.00	15
874	Marcador de Cera	20.00	blanco	849	9	t	\N	General	0.00	15
875	Marcador de Cera	20.00	rojo	850	15	t	\N	General	0.00	15
876	Marcador de Cera	20.00	amarillo	851	1	t	\N	General	0.00	15
877	Marcador de Cera	20.00	negro	852	5	t	\N	General	0.00	15
878	Marcador de Cera	20.00	azul	853	10	t	\N	General	0.00	15
879	Marcador de Cera	20.00	verde	854	7	t	\N	General	0.00	15
880	Lapiz Rojo	10.00	Sin descripcion	855	52	t	\N	General	0.00	15
881	Lapiz Duo	10.00	delgado lapiz/rojo	856	39	t	\N	General	0.00	15
882	Lapiz Duo	20.00	grueso lapiz/rojo	857	7	t	\N	General	0.00	15
883	Bicolor	10.00	delgado azul/rojo	858	16	t	\N	General	0.00	15
884	Lapiz Entrenador	20.00	Sin descripcion	859	14	t	\N	General	0.00	15
885	Color Blanco	15.00	Sin descripcion	860	4	t	\N	General	0.00	15
886	Detector de Billete	35.00	billete falso	861	3	t	\N	General	0.00	15
887	Marcador Agua	12.00	p.fino negro	862	10	t	\N	General	0.00	15
889	Marcador Agua	15.00	p.gruesa colores	864	16	t	\N	General	0.00	15
893	Marcador Agua	8.00	doble punta	868	12	t	\N	General	0.00	15
894	Marcador Agua	10.00	p.mediana colores	869	7	t	\N	General	0.00	15
895	Cutter	25.00	grande	870	18	t	\N	General	0.00	15
896	Cutter	65.00	mae grande	871	2	t	\N	General	0.00	15
897	Cutter	42.00	mae grande	872	1	t	\N	General	0.00	15
898	Cutter	40.00	grande	873	3	t	\N	General	0.00	15
899	Cutter	15.00	chico	874	22	t	\N	General	0.00	15
900	Gioser	20.00	#40	875	2	t	\N	General	0.00	15
901	Gioser	25.00	#9 	876	2	t	\N	General	0.00	15
902	Gioser	25.00	#48	877	1	t	\N	General	0.00	15
903	Gioser	25.00	#13	878	1	t	\N	General	0.00	15
904	Gioser	40.00	#10	879	1	t	\N	General	0.00	15
905	Marcador Pintarron	25.00	paq. c/4 pza	880	1	t	\N	General	0.00	15
906	Cinta Gruesa	55.00	transparente	881	3	t	\N	General	0.00	15
907	Cinta Diurex	35.00	24x66mt.	882	1	t	\N	General	0.00	15
908	Cinta Maskitape	30.00	12x50mt.	883	3	t	\N	General	0.00	15
910	Cinta Maskitape	50.00	24x50mt.	885	1	t	\N	General	0.00	15
911	Abatelengua	40.00	paq.c/50pza colores	886	2	t	\N	General	0.00	15
912	Lapiz Infinito	20.00	Sin descripcion	887	5	t	\N	General	0.00	15
913	Canicas	20.00	Sin descripcion	888	6	t	\N	General	0.00	15
914	Set de Corrector	35.00	2+1	889	1	t	\N	General	0.00	15
915	Alambre	30.00	#20 y 26\n	890	2	t	\N	General	0.00	15
916	Broche Baco	30.00	gigante	891	2	t	\N	General	0.00	15
917	Cinta Invisible	35.00	Sin descripcion	892	1	t	\N	General	0.00	15
918	Ventosa	10.00	transpaente	893	8	t	\N	General	0.00	15
919	Etiqueta	5.00	paq.chico	894	7	t	\N	General	0.00	15
920	Pluma Decorada	20.00	Sin descripcion	895	25	t	\N	General	0.00	15
921	Pluma C/ 4 Colores	25.00	Sin descripcion	896	18	t	\N	General	0.00	15
923	Pluma Borrable	13.00	negra	898	6	t	\N	General	0.00	15
925	Rompecabezas	15.00	madera chico	900	2	t	\N	General	0.00	15
927	Lapicero	25.00	con animalitos	902	1	t	\N	General	0.00	15
928	Pluma Retractil	15.00	BN 619	903	13	t	\N	General	0.00	15
929	Pluma Gel	20.00	G-1067	904	2	t	\N	General	0.00	15
930	Sellitos	12.00	varios	905	68	t	\N	General	0.00	15
931	Lampara	15.00	chica	906	3	t	\N	General	0.00	15
932	Cartulina	15.00	amarillo pastel	907	32	t	\N	General	0.00	15
933	Letrero	35.00	feliz cumpleaños	908	17	t	\N	General	0.00	15
934	Letrero	50.00	bienvenido	909	4	t	\N	General	0.00	15
935	Juego	50.00	de espacio	910	1	t	\N	General	0.00	15
936	Juego	45.00	de pesca	911	2	t	\N	General	0.00	15
937	Juego	60.00	didactico de numeros	912	0	t	\N	General	0.00	15
940	Juego	35.00	soldaditos	915	2	t	\N	General	0.00	15
942	Mochilita	55.00	bety bu	917	1	t	\N	General	0.00	15
943	Lonchera	65.00	naranja	918	1	t	\N	General	0.00	15
944	Pelota Antiestres	13.00	chica	919	5	t	\N	General	0.00	15
945	Lego	25.00	chico varias figuras	920	3	t	\N	General	0.00	15
946	Letrero	24.00	para pastel	921	8	t	\N	General	0.00	15
947	Vela Chica	20.00	c/24 velas	922	5	t	\N	General	0.00	15
948	Globo Metalico	20.00	chico	923	2	t	\N	General	0.00	15
949	Globo Metalico	40.00	grande	924	10	t	\N	General	0.00	15
950	Caja Dura	50.00	corazon	925	1	t	\N	General	0.00	15
951	Pelota	15.00	varios colores	926	12	t	\N	General	0.00	15
952	Ulla Ulla	40.00	grande	927	2	t	\N	General	0.00	15
953	Memorama	40.00	personaje	928	1	t	\N	General	0.00	15
954	Calcamonia	15.00	patria p/cara	929	12	t	\N	General	0.00	15
955	Dibujo C/Acuarela	10.00	Sin descripcion	930	4	t	\N	General	0.00	15
956	Valerina	15.00	varios colores	931	16	t	\N	General	0.00	15
957	Juego de Lapiz	50.00	lapiz + sellitos	932	3	t	\N	General	0.00	15
959	Libro de Crucigrama	35.00	Sin descripcion	934	2	t	\N	General	0.00	15
960	Llaveros	35.00	personajes	935	5	t	\N	General	0.00	15
961	Caja #0	7.00	forrada	936	41	t	\N	General	0.00	15
962	Caja #1	8.00	forrada	937	42	t	\N	General	0.00	15
963	Caja #2	9.00	forrada	938	28	t	\N	General	0.00	15
964	Caja #3	10.00	forrada	939	35	t	\N	General	0.00	15
965	Caja #5	16.00	forrada	940	55	t	\N	General	0.00	15
967	Caja #9	25.00	forrada	942	29	t	\N	General	0.00	15
968	Caja #10	25.00	forrada	943	24	t	\N	General	0.00	15
969	Caja #11	25.00	forrada	944	28	t	\N	General	0.00	15
970	Caja #26	25.00	forrada	945	22	t	\N	General	0.00	15
971	Caja #24	20.00	forrada	946	29	t	\N	General	0.00	15
972	Caja #pe	18.00	forrada	947	26	t	\N	General	0.00	15
973	Caja #30	30.00	forrada	948	25	t	\N	General	0.00	15
974	Caja #pm	30.00	forrada	949	26	t	\N	General	0.00	15
975	Caja #p	35.00	forrada	950	24	t	\N	General	0.00	15
976	Caja #c	45.00	forrada	951	13	t	\N	General	0.00	15
977	Caja Anillo	10.00	mini	952	2	t	\N	General	0.00	15
978	Huevos Pascua	45.00	paquete	953	1	t	\N	General	0.00	15
979	Lima de Uñas	10.00	suelta	954	50	t	\N	General	0.00	15
980	Lima de Uñas	18.00	paquete	955	5	t	\N	General	0.00	15
981	Collar	50.00	estuche de corazon	956	6	t	\N	General	0.00	15
982	Bandera	3.00	papel	957	150	t	\N	General	0.00	15
983	Bolsa de Papel	3.50	kraft mediana	958	9	t	\N	General	0.00	15
984	Bolsa de Papel	9.00	kraft grande	959	74	t	\N	General	0.00	15
985	Bolsa de Papel	2.00	kraft chica	960	70	t	\N	General	0.00	15
986	Paleacate	25.00	rojo	961	6	t	\N	General	0.00	15
987	Cortina	35.00	varios colores	962	24	t	\N	General	0.00	15
988	Fomy Moldeable	25.00	varios colores economico	963	15	t	\N	General	0.00	15
989	Fomy Moldeable	29.00	varios colores pelikan	964	8	t	\N	General	0.00	15
991	Estuche Chico	30.00	plastico varios colores	966	3	t	\N	General	0.00	15
992	Geoplano	35.00	Sin descripcion	967	2	t	\N	General	0.00	15
993	Estuche Chico	35.00	plastico scool	968	1	t	\N	General	0.00	15
994	Billetes	15.00	surtido paq.	969	8	t	\N	General	0.00	15
995	Bolsa Celofan	1.50	7x16	970	130	t	\N	General	0.00	15
996	Bolsa Celofan	1.50	8x20	971	50	t	\N	General	0.00	15
997	Bolsa Celofan	2.00	8.5x21	972	208	t	\N	General	0.00	15
998	Bolsa Celofan	2.50	12x27	973	84	t	\N	General	0.00	15
999	Bolsa Celofan	4.50	16x36	974	58	t	\N	General	0.00	15
1000	Bolsa Celofan	6.00	17x40	975	29	t	\N	General	0.00	15
1001	Bolsa Celofan	7.00	20x45	976	7	t	\N	General	0.00	15
1002	Bolsa Celofan	8.00	20x58	977	35	t	\N	General	0.00	15
1003	Bolsa Celofan	12.00	25x64	978	33	t	\N	General	0.00	15
1004	Bolsa Celofan	15.00	30x70	979	26	t	\N	General	0.00	15
1005	Bolsa Celofan	18.00	40x80	980	27	t	\N	General	0.00	15
1006	Broche Gafet	25.00	retractil	981	4	t	\N	General	0.00	15
1007	Borrador Figura	10.00	muestrario colgante	982	7	t	\N	General	0.00	15
1009	Helicoptero	15.00	muestrario colgante	984	2	t	\N	General	0.00	15
1010	Carrito Retractil	15.00	muestrario colgante	985	1	t	\N	General	0.00	15
1011	Manitas	5.00	muestrario colgante	986	15	t	\N	General	0.00	15
1016	Dona Niña	10.00	muestrario colgante	991	20	t	\N	General	0.00	15
1017	Chinchitas P/Cabello	12.00	muestrario colgante	992	11	t	\N	General	0.00	15
1018	Dona P/Cabello	15.00	muestrario colgante	993	8	t	\N	General	0.00	15
1019	Chinchitas Doradas	15.00	muestrario colgante	994	2	t	\N	General	0.00	15
1020	Prendedor P/Cabello	20.00	muestrario colgante	995	3	t	\N	General	0.00	15
1021	Prendedor+donitas	12.00	muestrario colgante	996	1	t	\N	General	0.00	15
1022	Sticker	20.00	varios	997	11	t	\N	General	0.00	15
1023	Pestaña	20.00	Sin descripcion	998	5	t	\N	General	0.00	15
1025	Palo Brocheta	1.00	20 cm.delgado	1000	328	t	\N	General	0.00	15
1026	Palo Brocheta	1.50	25 cm.delgaado	1001	109	t	\N	General	0.00	15
1027	Palo Brocheta	1.50	30 cm.delgado	1002	150	t	\N	General	0.00	15
1028	Palo Brocheta	0.50	15 cm.delgado	1003	195	t	\N	General	0.00	15
1029	Palo Brocheta	2.00	30 cm.grueso	1004	124	t	\N	General	0.00	15
1030	Palo Brocheta	1.50	25 cm.grueso	1005	89	t	\N	General	0.00	15
1031	Palo Aplicador	0.75	Sin descripcion	1006	126	t	\N	General	0.00	15
1032	Palo	0.75	abatelenguas	1007	72	t	\N	General	0.00	15
1033	Palo para Globo	1.50	plastico	1008	55	t	\N	General	0.00	15
1034	Palo	4.50	60cm.grueso	1009	16	t	\N	General	0.00	15
1035	Palo	3.00	60 cm.delgado	1010	94	t	\N	General	0.00	15
1036	Palo	4.50	50 cm.grueso	1011	24	t	\N	General	0.00	15
1037	Palo	2.00	45 cm.delgado	1012	206	t	\N	General	0.00	15
1038	Palo	1.50	30 cm.delgado	1013	63	t	\N	General	0.00	15
1039	Palo	1.00	20 cm.delgado	1014	193	t	\N	General	0.00	15
1040	Palo	0.50	15 cm. delgado	1015	71	t	\N	General	0.00	15
1041	Cuaderno Francesa Cocido	55.00	c.chico	1016	1	t	\N	General	0.00	15
1042	Moño Magico	28.00	jumbo pom pom 	1017	2	t	\N	General	0.00	15
1043	Moño Magico	17.00	grande pom pom 	1018	25	t	\N	General	0.00	15
1044	Moño Magico	20.00	jumbo	1019	202	t	\N	General	0.00	15
1045	Moño Magico	10.00	grande metalico	1020	127	t	\N	General	0.00	15
1046	Moño Magico	8.00	grande	1021	237	t	\N	General	0.00	15
1047	Moño Magico	7.00	mediano	1022	67	t	\N	General	0.00	15
1048	Moño Magico	6.00	chico	1023	429	t	\N	General	0.00	15
1049	Moño Magico	4.00	mini	1024	263	t	\N	General	0.00	15
1050	Curp	20.00	color	1025	83	t	\N	General	0.00	15
1051	Curp	15.00	blanco/negro	1026	79	t	\N	General	0.00	15
1052	Bolsa de Regalo	25.00	mediana niña	1027	10	t	\N	General	0.00	15
1053	Sacapuntas	10.00	sharpener	1028	15	t	\N	General	0.00	15
1054	Sacapuntas	10.00	metalico doble	1029	6	t	\N	General	0.00	15
1055	Sacapuntas	7.00	metalico sencillo	1030	75	t	\N	General	0.00	15
1056	Sacapuntas	10.00	plastico doble	1031	23	t	\N	General	0.00	15
1057	Sacapuntas	5.00	economico	1032	87	t	\N	General	0.00	15
1058	Bolsa de Regalo	30.00	grande niño	1033	8	t	\N	General	0.00	15
1059	Letrero	50.00	cumplaños personaje 	1034	2	t	\N	General	0.00	15
1060	Letrero	60.00	cumpleaños personaje	1035	2	t	\N	General	0.00	15
1061	Kit de Globo	85.00	es niño,es niña	1036	2	t	\N	General	0.00	15
1062	Pintarron	70.00	chico	1037	2	t	\N	General	0.00	15
1063	Cinta Doble Cara	35.00	acolchonada	1038	3	t	\N	General	0.00	15
1064	Cinta Doble Cara	24.00	acolchonada	1039	11	t	\N	General	0.00	15
1065	Letrero	45.00	feliz cumple inflable	1040	4	t	\N	General	0.00	15
1066	Globo Numero	30.00	32" 	1041	12	t	\N	General	0.00	15
1067	Globo Numero	20.00	17"	1042	30	t	\N	General	0.00	15
1068	Abaco	45.00	grande	1043	1	t	\N	General	0.00	15
1069	Abaco	30.00	chico	1044	3	t	\N	General	0.00	15
1070	Tangram	45.00	grande	1045	2	t	\N	General	0.00	15
1071	Tangram	42.00	c/estuche mediano	1046	3	t	\N	General	0.00	15
1072	Tangram	25.00	mediano fomy	1047	2	t	\N	General	0.00	15
1073	Tangram	30.00	plastico mediano	1048	1	t	\N	General	0.00	15
1074	Tangram	25.00	chico madera	1049	2	t	\N	General	0.00	15
1077	Marcador Agua	45.00	pelikan paq c/6 PASTEL\n	1052	1	t	\N	General	0.00	15
1079	Mantel	35.00	liso	1054	11	t	\N	General	0.00	15
1080	Mantel	40.00	personaje	1055	9	t	\N	General	0.00	15
1081	Pintura para Cabello	30.00	crema	1056	9	t	\N	General	0.00	15
1082	Pintura para Cabello	70.00	aerosol	1057	6	t	\N	General	0.00	15
1083	Liga para Cabello	15.00	tela	1058	28	t	\N	General	0.00	15
1084	Liga para Cabello	15.00	plastico	1059	7	t	\N	General	0.00	15
1085	Globo con Confeti	65.00	paq.c/12 pza	1060	1	t	\N	General	0.00	15
1086	Tijera	55.00	grande	1061	1	t	\N	General	0.00	15
1088	Tijera	45.00	mediana scissors	1063	1	t	\N	General	0.00	15
1089	Tijera	35.00	zin zin 	1064	2	t	\N	General	0.00	15
1091	Kola Loca	40.00	Sin descripcion	1066	1	t	\N	General	0.00	15
1092	Libreta	15.00	s/espial chica	791	10	t	\N	General	0.00	15
1093	Libreta	18.00	s/espiral grande	1067	12	t	\N	General	0.00	15
1094	Cincho	20.00	mediano c/25 pza	1068	2	t	\N	General	0.00	15
1095	Cincho	25.00	grande c/25 pza	1069	3	t	\N	General	0.00	15
1096	Cincho	50.00	grande c/100 pza	1070	1	t	\N	General	0.00	15
1097	Perforadora de Mano	45.00	jumbo	1071	2	t	\N	General	0.00	15
1098	Perforadora de Mano	75.00	pelikan	1072	1	t	\N	General	0.00	15
1099	Enbudo	20.00	chico	1073	4	t	\N	General	0.00	15
1100	Usb	200.00	32 GB	1074	0	t	\N	General	0.00	15
1101	Usb	130.00	16 GB	1075	0	t	\N	General	0.00	15
1102	Saca Ceja	15.00	Sin descripcion	1076	9	t	\N	General	0.00	15
1103	Perforadora Doble	80.00	offis	1077	1	t	\N	General	0.00	15
1105	Corrector	20.00	lapiz chico	1079	8	t	\N	General	0.00	15
1106	Frasco	20.00	120 ml.	1080	2	t	\N	General	0.00	15
1107	Pintura Politec 100 Ml.	55.00	varios colores	1081	8	t	\N	General	0.00	15
1108	Vela Larga	20.00	c/12 pza	1082	5	t	\N	General	0.00	15
1109	Flexometro	30.00	metal	1083	3	t	\N	General	0.00	15
1110	Nariz de Payaso	25.00	con luz 	1084	12	t	\N	General	0.00	15
1112	Rompecabezas	10.00	grande	901	7	t	\N	General	0.00	15
1113	Estuche	70.00	doble tela	1086	2	t	\N	General	0.00	15
1114	Estuche	30.00	sencillo	1087	6	t	\N	General	0.00	15
1115	Estuche	20.00	transparente	1088	3	t	\N	General	0.00	15
1117	Liga #18	40.00	80 gr	1090	1	t	\N	General	0.00	15
1118	Liga #18	25.00	40 gr	1091	1	t	\N	General	0.00	15
1119	Liga #18	15.00	20 gr	1092	1	t	\N	General	0.00	15
1120	Liga #10	40.00	80 gr	1093	1	t	\N	General	0.00	15
1121	Liga #10	25.00	40 gr	1094	1	t	\N	General	0.00	15
1122	Sacagrapa	25.00	Sin descripcion	1095	4	t	\N	General	0.00	15
1126	Bomba C/Valvula	45.00	Sin descripcion	1099	2	t	\N	General	0.00	15
1127	Bomba P/Globo	45.00	Sin descripcion	1100	1	t	\N	General	0.00	15
1131	Set de Papeleria	110.00	lapiz+estuche+jgo.geometria	1104	2	t	\N	General	0.00	15
1132	Ventilador C/Sacapuntas	85.00	recargable	1105	1	t	\N	General	0.00	15
1133	Ventilador	70.00	recargable	1106	3	t	\N	General	0.00	15
1134	Mini Inertia	40.00	carro retractil	1107	1	t	\N	General	0.00	15
1135	Serpentinas	18.00	Sin descripcion	1108	5	t	\N	General	0.00	15
1136	Carritos	60.00	set c/4 pza retractil	1109	1	t	\N	General	0.00	15
1137	Estuche	40.00	metal	1110	2	t	\N	General	0.00	15
1138	Carritos	90.00	paq.c/6 pza.retractil 	1111	1	t	\N	General	0.00	15
1140	Cartera	40.00	niño,niña	1113	1	t	\N	General	0.00	15
1141	Hojas Blanca	1.00	t/oficio	1114	350	t	\N	General	0.00	15
1142	Papel Lutres	7.00	gris\n	1115	10	t	\N	General	0.00	15
1143	Papel Kraf	17.00	mts.	1116	27	t	\N	General	0.00	15
1144	Fomy T/Carta	4.50	azul cielo	1117	103	t	\N	General	0.00	15
1145	Fomy T/Carta	4.50	azul rey	1118	12	t	\N	General	0.00	15
1146	Fomy T/Carta	4.50	naranja	1119	30	t	\N	General	0.00	15
1147	Fomy T/Carta	4.50	amarillo claro	1120	16	t	\N	General	0.00	15
1148	Fomy T/Carta	4.50	verde bandera	1121	32	t	\N	General	0.00	15
1149	Fomy T/Carta	4.50	verde limon	1122	43	t	\N	General	0.00	15
1150	Fomy T/Carta	4.50	rosa pastel	1123	18	t	\N	General	0.00	15
1151	Fomy T/Carta	4.50	rosa fiusha	1124	45	t	\N	General	0.00	15
1152	Fomy T/Carta	4.50	cafe claro	1125	27	t	\N	General	0.00	15
1153	Fomy T/Carta	4.50	cafe oscuro	1126	5	t	\N	General	0.00	15
1154	Fomy T/Carta	4.50	gris	1127	35	t	\N	General	0.00	15
1155	Fomy T/Carta	4.50	carne	1128	13	t	\N	General	0.00	15
1156	Fomy T/Carta	4.50	lila	1129	34	t	\N	General	0.00	15
1157	Fomy T/Carta	4.50	morado	1130	16	t	\N	General	0.00	15
1158	Fomy T/Carta	4.50	blanca	1131	19	t	\N	General	0.00	15
1159	Fomy T/Carta	4.50	rojo	1132	70	t	\N	General	0.00	15
1160	Fomy T/Carta Diamantado	9.00	verde bandera	1133	39	t	\N	General	0.00	15
1161	Fomy T/Carta Diamantado	9.00	verde limon	1134	6	t	\N	General	0.00	15
1162	Fomy T/Carta Diamantado	9.00	naranja	1135	19	t	\N	General	0.00	15
1163	Fomy T/Carta Diamantado	9.00	bronce	1136	6	t	\N	General	0.00	15
1164	Fomy T/Carta Diamantado	8.00	cafe oscuro	1137	18	t	\N	General	0.00	15
1165	Fomy T/Carta Diamantado	9.00	cafe claro	1138	17	t	\N	General	0.00	15
1166	Fomy T/Carta Diamantado	9.00	carne	1139	9	t	\N	General	0.00	15
1167	Fomy T/Carta Diamantado	9.00	rojo	1140	42	t	\N	General	0.00	15
1168	Fomy T/Carta Diamantado	9.00	amarillo pastel	1141	21	t	\N	General	0.00	15
1169	Fomy T/Carta Diamantado	9.00	amarillo	1142	40	t	\N	General	0.00	15
1170	Fomy T/Carta Diamantado	9.00	oro	1143	17	t	\N	General	0.00	15
1171	Fomy T/Carta Diamantado	9.00	dorado	1144	25	t	\N	General	0.00	15
1172	Fomy T/Carta Diamantado	9.00	oro canario	1145	19	t	\N	General	0.00	15
1173	Fomy T/Carta Diamantado	9.00	negro	1146	12	t	\N	General	0.00	15
1174	Fomy T/Carta Diamantado	9.00	blanco	1147	39	t	\N	General	0.00	15
1175	Fomy T/Carta Diamantado	9.00	plata claro	1148	6	t	\N	General	0.00	15
1176	Fomy T/Carta Diamantado	9.00	plata oscuro	1149	9	t	\N	General	0.00	15
1177	Fomy T/Carta Diamantado	9.00	azul rey	1150	10	t	\N	General	0.00	15
1178	Fomy T/Carta Diamantado	9.00	azul cielo	1151	20	t	\N	General	0.00	15
1179	Fomy T/Carta Diamantado	9.00	azul medio	1152	10	t	\N	General	0.00	15
1180	Fomy T/Carta Diamantado	9.00	rosa pastel	1153	24	t	\N	General	0.00	15
1181	Fomy T/Carta Diamantado	9.00	rosa fiusha	1154	10	t	\N	General	0.00	15
1182	Fomy T/Carta Diamantado	9.00	morado	1155	16	t	\N	General	0.00	15
1183	Fomy T/Carta Diamantado	9.00	lila	1156	25	t	\N	General	0.00	15
1184	Fomy T/Carta Diamantado	9.00	rosa lila	1157	21	t	\N	General	0.00	15
1185	Fomy T/Carta Diamantado	9.00	aqua	1158	17	t	\N	General	0.00	15
1186	Sombras	150.00	estuche	186	2	t	\N	General	0.00	15
1187	Aretes	40.00	suelto	1159	3	t	\N	General	0.00	15
1189	Juego	50.00	animalitos	1161	1	t	\N	General	0.00	15
1190	Bolsa Niña	70.00	rojo	1162	1	t	\N	General	0.00	15
1191	Serpentina	75.00	spray	1163	2	t	\N	General	0.00	15
1192	Portaretratos	60.00	grande	1164	2	t	\N	General	0.00	15
1193	Portaretratos	40.00	chico	1165	1	t	\N	General	0.00	15
1194	Cartera	75.00	caballero	1166	1	t	\N	General	0.00	15
1195	Peine	4.50	colta varios colores	1167	14	t	\N	General	0.00	15
1197	Audifonos	55.00	varios	1169	1	t	\N	General	0.00	15
1199	Set Perfume	80.00	perfume + crema	1171	2	t	\N	General	0.00	15
1200	Domino	55.00	grande	1172	1	t	\N	General	0.00	15
1201	Domino	40.00	chico	1173	1	t	\N	General	0.00	15
1203	Baraja Poker	44.00	estuche	1175	2	t	\N	General	0.00	15
1204	Baraja Poker	35.00	caja	1176	1	t	\N	General	0.00	15
1205	Baraja Poker	30.00	economico	1177	1	t	\N	General	0.00	15
1206	Baraja Española	35.00	Sin descripcion	1178	2	t	\N	General	0.00	15
1207	Cubo Ruby	65.00	juguete	1179	2	t	\N	General	0.00	15
1208	Cargador	80.00	carga rapida	1180	1	t	\N	General	0.00	15
1209	Cargador	70.00	carga rapida	1181	1	t	\N	General	0.00	15
1210	Enchufe para Cable	45.00	para celular	1182	3	t	\N	General	0.00	15
1211	Cable P/Iphone	45.00	USB/entrada	1183	2	t	\N	General	0.00	15
1212	Cablep/Iphone	50.00	tipo c/entrada	1184	1	t	\N	General	0.00	15
1213	Bolsa Lentejuela	50.00	chica	1185	2	t	\N	General	0.00	15
1214	Lego	80.00	grande	1186	1	t	\N	General	0.00	15
1217	Perfilador de Ceja	20.00	paq c/2	1189	6	t	\N	General	0.00	15
1218	Peine de Ceja/Pestaña	15.00	Sin descripcion	1190	2	t	\N	General	0.00	15
1219	Bolitas para Pelo	35.00	caja 	742	2	t	\N	General	0.00	15
1220	Enchinador de Pestaña	35.00	Sin descripcion	1191	2	t	\N	General	0.00	15
1221	Set de Pulsera	30.00	caja	1192	2	t	\N	General	0.00	15
1223	Pulsera	30.00	varios	1194	3	t	\N	General	0.00	15
1225	Peinetas	30.00	varios	1196	4	t	\N	General	0.00	15
1226	Esmalte	22.00	varios colores	1197	4	t	\N	General	0.00	15
1227	Adaptador de Micro Sd	40.00	varios colores	1198	5	t	\N	General	0.00	15
1228	Diadema	15.00	sencillo	1199	12	t	\N	General	0.00	15
1230	Pistola Confeti	13.00	varios colores	1201	9	t	\N	General	0.00	15
1231	Cuerda	18.00	sencilla	1202	1	t	\N	General	0.00	15
1232	Borrador	7.00	figuras o paq.c/3	1203	62	t	\N	General	0.00	15
1234	Cinta Merica	30.00	amarilla metalica	1205	3	t	\N	General	0.00	15
1235	Sacapuntas C/Contenedor	35.00	sacapuntas/borrador	1204	6	t	\N	General	0.00	15
1238	Sacapuntas C/Contenedor	30.00	doble/papas	1208	22	t	\N	General	0.00	15
1240	Sacapuntas C/Contenedor	15.00	figuas varios	1210	6	t	\N	General	0.00	15
1241	Sacapuntas	18.00	goma varios figuras	1211	8	t	\N	General	0.00	15
1242	Cinta Decorativa	8.00	varios\n	1212	42	t	\N	General	0.00	15
1243	Papel Lustre	7.00	rojo	1213	22	t	\N	General	0.00	15
1244	Papel Lustre	7.00	plata	1214	47	t	\N	General	0.00	15
1245	Papel Lustre	7.00	dorado	1215	42	t	\N	General	0.00	15
1246	Papel Lustre	7.00	cafe	1216	28	t	\N	General	0.00	15
1247	Papel Lustre	7.00	morado	1217	60	t	\N	General	0.00	15
1248	Papel Lustre	7.00	lila	1218	10	t	\N	General	0.00	15
1249	Papel Lustre	7.00	verde pastel	1219	19	t	\N	General	0.00	15
1250	Papel Lustre	7.00	verde limon	1220	27	t	\N	General	0.00	15
1251	Papel Lustre	7.00	verde bandera	1221	19	t	\N	General	0.00	15
1252	Papel Lustre	7.00	blanco	1222	30	t	\N	General	0.00	15
1253	Papel Lustre	7.00	rosa pastel	1223	28	t	\N	General	0.00	15
1254	Papel Lustre	7.00	rosa medio	1224	47	t	\N	General	0.00	15
1255	Papel Lustre	7.00	fiusha	1225	17	t	\N	General	0.00	15
1256	Papel Lustre	7.00	naranja	1226	62	t	\N	General	0.00	15
1257	Papel Lustre	7.00	azul medio	1227	44	t	\N	General	0.00	15
1258	Papel Lustre	7.00	azul rey	1228	23	t	\N	General	0.00	15
1259	Papel Lustre	7.00	amarillo	1229	20	t	\N	General	0.00	15
1260	Papel Lustre	7.00	amarillo canario	1230	26	t	\N	General	0.00	15
1261	Papel Lustre	7.00	rojo	1231	49	t	\N	General	0.00	15
1262	Papel Lustre	7.00	gris	1232	33	t	\N	General	0.00	15
1263	Papel Lustre	7.00	negro	1233	39	t	\N	General	0.00	15
1264	Sobre Doble Carta	15.00	amarillo	1234	18	t	\N	General	0.00	15
1265	Cascaron Huevo	10.00	1/8	1235	14	t	\N	General	0.00	15
1266	Cascaron Huevo	20.00	1/4	1236	12	t	\N	General	0.00	15
1267	Cascaron Huevo	40.00	1/2	1237	10	t	\N	General	0.00	15
1268	Globo #7	65.00	paq.c/50	1238	1	t	\N	General	0.00	15
1269	Globo #7	40.00	paq. c/25	1239	1	t	\N	General	0.00	15
1270	Globo #7	24.00	paq.c/15	1240	0	t	\N	General	0.00	15
1271	Globo #9	80.00	paq.c/50	1241	12	t	\N	General	0.00	15
1272	Globo #9	45.00	paq.c/25	1242	1	t	\N	General	0.00	15
1273	Globo #12	75.00	paq.c/50	1243	3	t	\N	General	0.00	15
1274	Globo #12	45.00	paq.c/25	1244	2	t	\N	General	0.00	15
1275	Globo #12	25.00	paq.c/12	1245	1	t	\N	General	0.00	15
1276	Lamina Unicel	30.00	50x50	1246	2	t	\N	General	0.00	15
1277	Lamina Unicel	20.00	50x25	1247	2	t	\N	General	0.00	15
1278	Lamina Unicel	10.00	25x25	1248	2	t	\N	General	0.00	15
1279	Papel Marquilla	17.00	grueso	1249	1	t	\N	General	0.00	15
1280	Papel Marquilla	10.00	delgado	1250	8	t	\N	General	0.00	15
1281	Papel Crepe	10.00	naranja	1251	25	t	\N	General	0.00	15
1282	Papel Crepe	10.00	cempasuchil	1252	5	t	\N	General	0.00	15
1283	Papel Crepe	10.00	verde pastel	1253	8	t	\N	General	0.00	15
1284	Papel Crepe	10.00	amarillo	1254	23	t	\N	General	0.00	15
1285	Papel Crepe	10.00	fiusha	1255	19	t	\N	General	0.00	15
1286	Papel Crepe	10.00	cafe	1256	28	t	\N	General	0.00	15
1287	Papel Crepe	10.00	gris	1257	8	t	\N	General	0.00	15
1288	Papel Crepe	10.00	morado	1258	19	t	\N	General	0.00	15
1289	Papel Crepe	10.00	lila	1259	10	t	\N	General	0.00	15
1290	Papel Crepe	10.00	rosa	1260	22	t	\N	General	0.00	15
1291	Papel Crepe	10.00	azul cielo	1261	17	t	\N	General	0.00	15
1292	Papel Crepe	10.00	azul medio	1262	35	t	\N	General	0.00	15
1293	Papel Crepe	10.00	azul rey	1263	14	t	\N	General	0.00	15
1294	Papel Crepe	10.00	negro	1264	18	t	\N	General	0.00	15
1295	Papel Crepe	20.00	plata	1265	9	t	\N	General	0.00	15
1296	Papel Crepe	10.00	carne/melon	1266	7	t	\N	General	0.00	15
1314	Cartulina Fluorecente	15.00	rosa	1284	5	t	\N	General	0.00	15
1315	Cartulina Fluorecente	15.00	amarilla	1285	10	t	\N	General	0.00	15
1316	Cartulina Fluorecente	15.00	verde	1286	10	t	\N	General	0.00	15
1317	Cartulina Fluorecente	15.00	naranja	1287	11	t	\N	General	0.00	15
1318	Fomy Pliego	15.00	varios colores	1288	33	t	\N	General	0.00	15
1319	Fomy Pliego Diamantado	30.00	varios colores	1289	31	t	\N	General	0.00	15
1320	Bolsa de Regalo	30.00	grande bebe	1290	6	t	\N	General	0.00	15
1321	Papel de Regalo	9.00	bautizo	1291	7	t	\N	General	0.00	15
1322	Liga Chica	0.50	suelta	1292	40	t	\N	General	0.00	15
1323	Liga Grande	1.00	suelta	1293	43	t	\N	General	0.00	15
1324	Globo Metalico	25.00	bienvenido	1294	3	t	\N	General	0.00	15
1325	Base de Globo	2.50	plastico	1295	20	t	\N	General	0.00	15
1326	Carga Helio	45.00	tamaño 19¨	1296	50	t	\N	General	0.00	15
1327	Globo Metalico	35.00	varios 	1297	76	t	\N	General	0.00	15
1328	Papel China	2.50	azul cielo	1298	220	t	\N	General	0.00	15
1329	Papel China	2.50	azul medio	1299	331	t	\N	General	0.00	15
1330	Papel China	2.50	azul rey	1300	157	t	\N	General	0.00	15
1331	Papel China	2.50	morado	1301	186	t	\N	General	0.00	15
1332	Papel China	2.50	verde limon	1302	259	t	\N	General	0.00	15
1333	Papel China	2.50	verde pastel	1303	38	t	\N	General	0.00	15
1334	Papel China	2.50	gris	1304	15	t	\N	General	0.00	15
1335	Papel China	2.50	cafe	1305	122	t	\N	General	0.00	15
1336	Papel China	2.50	amarillo pastel	1306	141	t	\N	General	0.00	15
1337	Papel China	2.50	beige	1307	59	t	\N	General	0.00	15
1338	Papel China	2.50	lila	1308	198	t	\N	General	0.00	15
1339	Papel China	2.50	fiusha	1309	89	t	\N	General	0.00	15
1340	Papel China	2.50	rosa pastel	1310	84	t	\N	General	0.00	15
1341	Papel China	2.50	rosa	1311	156	t	\N	General	0.00	15
1342	Papel China	2.50	negro	1312	108	t	\N	General	0.00	15
1343	Contac Decorado	28.00	c/1 mt.	1313	12	t	\N	General	0.00	15
1344	Papel Manila	9.00	amarillo,verde,rojo	1314	6	t	\N	General	0.00	15
1345	Papel Leyer	12.00	pliego	1315	4	t	\N	General	0.00	15
1346	Papel Mantequilla	25.00	pliego	1316	7	t	\N	General	0.00	15
1347	Papel Imprenta	5.00	pliego	1317	21	t	\N	General	0.00	15
1348	Papel Celofan	9.00	transparente	1318	19	t	\N	General	0.00	15
1349	Papel Celofan	13.00	color	1319	20	t	\N	General	0.00	15
1350	Papelote/Rotafolio	9.00	blanco,raya,c.gde,c.chico\n	1320	72	t	\N	General	0.00	15
1351	Papel Deztrasa	4.00	pliego	1321	41	t	\N	General	0.00	15
1352	Papel Caple	30.00	pliego	1322	4	t	\N	General	0.00	15
1353	Papel Terciopelo	25.00	negro,blanco,rojo,verde	1323	9	t	\N	General	0.00	15
1354	Papel Minagris	15.00	pliego	1324	1	t	\N	General	0.00	15
1355	Papel Corrugado	30.00	por metro	1325	3	t	\N	General	0.00	15
1356	Resorte Blanco	9.00	1cm ancho x mts.	1326	46	t	\N	General	0.00	15
1357	Resorte Negro	6.00	.70cm ancho x mts.	1327	41	t	\N	General	0.00	15
1358	Bolsa de Regalo	30.00	grande caballero	1328	10	t	\N	General	0.00	15
1359	Bolsa de Regalo	30.00	grande f.cumpleaños	1329	11	t	\N	General	0.00	15
1360	Bolsa de Regalo	30.00	grande dama	1330	9	t	\N	General	0.00	15
1361	Bolsa de Regalo	30.00	grande lisa	1331	5	t	\N	General	0.00	15
1362	Bolsa de Regalo	30.00	grande primera comunion	1332	5	t	\N	General	0.00	15
1363	Bolsa de Regalo	25.00	mediana bebe	1333	7	t	\N	General	0.00	15
1364	Bolsa de Regalo	25.00	mediana f.cumpleaños	1334	9	t	\N	General	0.00	15
1365	Bolsa de Regalo	25.00	mediana dama	1335	10	t	\N	General	0.00	15
1366	Bolsa de Regalo	25.00	mediana lisa	1336	13	t	\N	General	0.00	15
1367	Bolsa de Regalo	25.00	mediana p.comunion	1337	7	t	\N	General	0.00	15
1368	Bolsa de Regalo	25.00	mediana niño	1338	12	t	\N	General	0.00	15
1369	Bolsa de Regalo	25.00	mediana caballero	1339	15	t	\N	General	0.00	15
1370	Bolsa de Regalo	20.00	chica p.comunion	1340	4	t	\N	General	0.00	15
1371	Bolsa de Regalo	20.00	chica bebe	1341	9	t	\N	General	0.00	15
1372	Bolsa de Regalo	20.00	chica f.cumpleaños	1342	11	t	\N	General	0.00	15
1373	Bolsa de Regalo	20.00	chica dama	1343	6	t	\N	General	0.00	15
1374	Bolsa de Regalo	20.00	chica lisa	1344	19	t	\N	General	0.00	15
1376	Bolsa de Regalo	20.00	chica niño	1346	9	t	\N	General	0.00	15
1377	Bolsa de Regalo	20.00	chica niña	1347	9	t	\N	General	0.00	15
1378	Bolsa de Regalo	20.00	chica caballero	1345	8	t	\N	General	0.00	15
1379	Bolsa de Regalo	15.00	mini varios	1348	22	t	\N	General	0.00	15
1380	Bolsa de Regalo	30.00	botella	1349	7	t	\N	General	0.00	15
1381	Bolsa de Regalo	45.00	jumbo varios	1350	27	t	\N	General	0.00	15
1382	Bolsa de Regalo	50.00	gigante lisa kraf	1351	3	t	\N	General	0.00	15
1383	Liston 1.5cm	7.00	mts. varios colores	1352	57	t	\N	General	0.00	15
1384	Liston 2.5cm	9.00	mts.varios calores	1353	60	t	\N	General	0.00	15
1385	Liston 4cm	15.00	mts.varios colores	1354	62	t	\N	General	0.00	15
1386	Liston .95cm	5.00	mts.varios colores	1355	59	t	\N	General	0.00	15
1387	Pintura Cara	12.00	crayon de color 	1356	7	t	\N	General	0.00	15
1389	Decoracion	25.00	dia de muertos	1358	2	t	\N	General	0.00	15
1390	Decoracion	40.00	dia de muertos	1359	3	t	\N	General	0.00	15
1394	Figura Fomy	10.00	dia de muertos\n	1363	7	t	\N	General	0.00	15
1395	Araña	35.00	pagable hallowen	1364	1	t	\N	General	0.00	15
1396	Colmillo de Dracula	5.00	hallowen	1365	9	t	\N	General	0.00	15
1397	Velo de Novia	70.00	disfras hallowen	1366	1	t	\N	General	0.00	15
1399	Telaraña de China	35.00	hallowen	1368	4	t	\N	General	0.00	15
1400	Sangre y Lates	15.00	artificial hallowen 	1369	6	t	\N	General	0.00	15
1402	Huesuda	32.00	calabera armable 	1371	3	t	\N	General	0.00	15
1404	Tira Decorada	35.00	papel metalico hallowen 	1373	1	t	\N	General	0.00	15
1405	Collar	25.00	hawaiano	1374	10	t	\N	General	0.00	15
1406	Calabaza P/Dulces	45.00	grande hallowen	1375	2	t	\N	General	0.00	15
1407	Calabaza P/Dulces	30.00	mediana  hallowen	1376	3	t	\N	General	0.00	15
1408	Calabaza P/Dulces	25.00	jack blanca hallowen	1377	3	t	\N	General	0.00	15
1409	Calabaza P/Dulces	20.00	chica hallowen	1378	3	t	\N	General	0.00	15
1410	Sombrero de Unicel	40.00	unica pieza	1379	1	t	\N	General	0.00	15
1412	Limpiapipas	1.00	fiusha	656	85	t	\N	General	0.00	15
1413	Postit	35.00	banderitas  marca sccol y pascual	788	0	t	\N	General	0.00	15
1414	Cincho	15.00	chico c/25pza.	999	2	t	\N	General	0.00	15
1416	Gancho	30.00	mini color/madera C/25 pza	1381	8	t	\N	General	0.00	15
1417	Cuerpos Geometricos	55.00	album	1357	1	t	\N	General	0.00	15
1418	Cubo	40.00	15x25	1370	2	t	\N	General	0.00	15
1421	Caja Clip	25.00	colores chico	1383	5	t	\N	General	0.00	15
1423	Pintura Cara	35.00	blanca en tarro	1385	3	t	\N	General	0.00	15
1424	Pintura Cara	12.00	blanca chica	1386	5	t	\N	General	0.00	15
1426	Cartulina	7.00	blanca	3	32	t	\N	General	0.00	15
1427	Argolla	10.00	25 mm	1387	8	t	\N	General	0.00	15
1428	Papel China	52.00	tinto	1388	100	t	\N	General	0.00	15
1429	Cubo	55.00	28x24x7.5	1389	4	t	\N	General	0.00	15
1430	Papel Picado	3.50	grande dia de muertos	1390	130	t	\N	General	0.00	15
1431	Papel Picado	2.50	chico dia de muertos	1391	389	t	\N	General	0.00	15
1432	Sujetador de Documentos	2.00	15mm	1392	2	t	\N	General	0.00	15
1433	Sujetador de Documentos	6.00	32mm	1393	11	t	\N	General	0.00	15
1434	Sujetador de Documentos	10.00	41mm	1394	10	t	\N	General	0.00	15
1436	Bolsa de Regalo	35.00	mediana c/personaje	1396	14	t	\N	General	0.00	15
1437	Diamantina Gruesa	8.00	varios colores	1397	17	t	\N	General	0.00	15
1438	Descargas	10.00	de internet	419	989	t	\N	General	0.00	15
1439	Globo de Helio	85.00	globo y carga de helio	897	95	t	\N	General	0.00	15
1440	Ula Ula	40.00	grande	933	1	t	\N	General	0.00	15
1441	Tabla de Dividir	40.00	Sin descripcion	989	3	t	\N	General	0.00	15
1442	Tira de Luz	20.00	luz led 1mt.	1102	100	t	\N	General	0.00	15
1443	Contac	10.00	1/2 metro	719	97	t	\N	General	0.00	15
1444	Plastico Vinil	15.00	1/2 metro	1168	49	t	\N	General	0.00	15
1445	Dibujo	2.00	para colorear	1174	92	t	\N	General	0.00	15
1446	Cola de Rata	3.00	colores	1187	991	t	\N	General	0.00	15
1447	Lamina Unicel	55.00	100 x 50 cm	1398	0	t	\N	General	0.00	15
1448	Craneo	75.00	grande	1399	1	t	\N	General	0.00	15
1450	Craneo	35.00	chico	1401	1	t	\N	General	0.00	15
1452	Tabla Periodica	15.00	chica	739	2	t	\N	General	0.00	15
1453	Pintura Politec 20 Ml.	22.00	neon 	1078	4	t	\N	General	0.00	15
1454	Cuaderno Francesa Cocido	55.00	c.grande	1360	1	t	\N	General	0.00	15
1457	Pintura Politec20 Ml.	17.00	verde	716	31	t	\N	General	0.00	15
1459	Hilo Dorado	4.00	metro	717	99	t	\N	General	0.00	15
1460	Tijera Jumbo	50.00	mediana 6"	1053	3	t	\N	General	0.00	15
1461	Tijera Jumbo	65.00	grande 7"	1101	2	t	\N	General	0.00	15
1462	Pintura Politec 20 Ml.	17.00	morada	326	12	t	\N	General	0.00	15
1463	Resistol Liquido	15.00	zin zin 40 ml.	1103	7	t	\N	General	0.00	15
1464	Resistol Liquido	22.00	zin zin 60 ml.	1367	8	t	\N	General	0.00	15
1465	Cubo	60.00	25x25x13	1380	0	t	\N	General	0.00	15
1466	Sujetador de Documentos	4.50	25mm	20	10	t	\N	General	0.00	15
1467	Uno Personaje	40.00	juguete	76	1	t	\N	General	0.00	15
1468	Happy Time	50.00	juguete	77	1	t	\N	General	0.00	15
1469	Loteria	75.00	ggante	78	1	t	\N	General	0.00	15
1470	Fomy Moldeable	35.00	paq.c/12 chico\n	80	3	t	\N	General	0.00	15
1471	Cinta Diurex C/Despachador	40.00	cinta c/despachador\n	81	2	t	\N	General	0.00	15
1472	Cinta Diurex C/Despachador	20.00	cinta c/despachador	82	3	t	\N	General	0.00	15
1475	Dinosaurios	100.00	c/6 pza\n	85	1	t	\N	General	0.00	15
1476	Dinosaurios	55.00	c/3 pza	87	1	t	\N	General	0.00	15
1477	Globo #9	110.00	paq.c/100	88	1	t	\N	General	0.00	15
1480	Puppy Paradise	30.00	juguete	371	1	t	\N	General	0.00	15
1481	Engrapadora	45.00	chica	517	3	t	\N	General	0.00	15
1482	Engrapadora Set	85.00	set 	593	1	t	\N	General	0.00	15
1579	Decoradcion	40.00	enamorados 	789	2	t	\N	General	0.00	15
1483	Palo de Colores	30.00	paq. c/50 pza    14 cm 	706	2	t	\N	General	0.00	15
1484	Perforadora de Mano	40.00	economica	833	2	t	\N	General	0.00	15
1485	Rompecabezas	20.00	grande	834	14	t	\N	General	0.00	15
1486	Libreta	45.00	note book pasta dura 	987	6	t	\N	General	0.00	15
1487	Libreta	25.00	chica pasta dura	799	13	t	\N	General	0.00	15
1488	Rompecabezas	15.00	mini madera	1085	11	t	\N	General	0.00	15
1489	Balon	60.00	chico	1200	2	t	\N	General	0.00	15
1490	Papel Pvc	25.00	metro	1361	49	t	\N	General	0.00	15
1491	Papel Metalico	24.00	mts. varios colores 	318	96	t	\N	General	0.00	15
1492	Iman Redondo	8.00	grande	687	9	t	\N	General	0.00	15
1493	Sticker	15.00	navideño	884	12	t	\N	General	0.00	15
1494	Figura Fomy	10.00	navideño	941	27	t	\N	General	0.00	15
1495	Pino	10.00	navideño	1209	28	t	\N	General	0.00	15
1497	Gorro	30.00	navideño c/luz	1372	1	t	\N	General	0.00	15
1498	Diablo	50.00	dizfraz navideño	1384	1	t	\N	General	0.00	15
1499	Decoracion	15.00	navideño	1400	6	t	\N	General	0.00	15
1500	Bota	30.00	navideño	1402	6	t	\N	General	0.00	15
1501	Decoracion	45.00	año nuevo selfie	1403	3	t	\N	General	0.00	15
1502	Sobre	15.00	navideño	1404	3	t	\N	General	0.00	15
1503	Mono de Nieve	45.00	navideño	1405	1	t	\N	General	0.00	15
1504	Pegamento de Pestaña	20.00	Sin descripcion	1170	5	t	\N	General	0.00	15
1508	Ula Ula	35.00	mediano	913	3	t	\N	General	0.00	15
1509	Pluma Kiut	15.00	fiusha o lila\n	592	40	t	\N	General	0.00	15
1510	Cinta Diurex	25.00	18x65	594	2	t	\N	General	0.00	15
1511	Pintura Politec 20 Ml	30.00	dorado	914	1	t	\N	General	0.00	15
1512	Tabla con Clip	50.00	t/carta	173	2	t	\N	General	0.00	15
1513	Papel de Regalo	9.00	novio / enamorados	315	18	t	\N	General	0.00	15
1514	Pelota Antiestres	30.00	grande	112	7	t	\N	General	0.00	15
1515	Cubo	40.00	30x19 	114	1	t	\N	General	0.00	15
1516	Cubo	60.00	20 x 20	115	3	t	\N	General	0.00	15
1517	Cubo	40.00	16x16x10	116	5	t	\N	General	0.00	15
1518	Marcador Agua	15.00	p.gruesa negro	84	7	t	\N	General	0.00	15
1519	Impresion Oficio B/N	3.00	bajo +	117	9953	t	\N	General	0.00	15
1520	Impresion Oficio Color	8.00	bajo +	118	990	t	\N	General	0.00	15
1521	Cuaderno Profecional Cocido	75.00	c.grande	120	2	t	\N	General	0.00	15
1522	Bolsa de Regalo	30.00	enamorados\n	121	3	t	\N	General	0.00	15
1523	Cubo 30x30	80.00	enamorados	122	1	t	\N	General	0.00	15
1524	Cubo	45.00	15x15 enamorados	123	2	t	\N	General	0.00	15
1525	Cubo 20x20	60.00	enamorados	248	2	t	\N	General	0.00	15
1526	Limpiapipas	1.00	verde hoja	652	100	t	\N	General	0.00	15
1528	Borrador	15.00	colores	727	26	t	\N	General	0.00	15
1529	Libro Numeros y Letras	30.00	Sin descripcion	728	9	t	\N	General	0.00	15
1530	Libro Mandala de Niño	25.00	Sin descripcion	835	3	t	\N	General	0.00	15
1531	Scuichi	30.00	varios	863	5	t	\N	General	0.00	15
1532	Tiara	15.00	colores	865	21	t	\N	General	0.00	15
1533	Marcador Agua	55.00	paq.c/12 pza ZIN ZIN	866	1	t	\N	General	0.00	15
1534	Marcador Agua	35.00	paq.c/12 pza. COLOR FIBRE	867	3	t	\N	General	0.00	15
1535	Brocha	30.00	1 1/2¨	292	6	t	\N	General	0.00	15
1536	Rosa C/Luz	40.00	enamorados	899	12	t	\N	General	0.00	15
1537	Tijera	20.00	economica	988	10	t	\N	General	0.00	15
1538	Juego Geometria	35.00	flexi	990	10	t	\N	General	0.00	15
1539	Brocha	20.00	1/2´	1050	7	t	\N	General	0.00	15
1540	Yoyo	30.00	colores	1062	1	t	\N	General	0.00	15
1543	Liga Surtida	32.00	tela/plastico	1195	3	t	\N	General	0.00	15
1544	Caja Anillo	40.00	jumbo 	1206	12	t	\N	General	0.00	15
1545	Arco	55.00	juguete	1207	1	t	\N	General	0.00	15
1546	Pino Boliche	40.00	juguete	1362	3	t	\N	General	0.00	15
1547	Raqueta	55.00	juguete	1382	2	t	\N	General	0.00	15
1549	My Pet	45.00	juguete	1407	2	t	\N	General	0.00	15
1550	Girl Toys	40.00	juguete	1408	1	t	\N	General	0.00	15
1551	Pistola Balas de Gel	35.00	 juguete	1409	2	t	\N	General	0.00	15
1552	Pizarron Magico	30.00	juguete	1410	1	t	\N	General	0.00	15
1554	Pistolas Avion	30.00	juguete	1412	3	t	\N	General	0.00	15
1555	Kit Doctor	50.00	juguete	1413	4	t	\N	General	0.00	15
1556	Balas de Disco	20.00	juguete\n	1414	7	t	\N	General	0.00	15
1557	Carro Dinosaurio	30.00	juguete	1415	3	t	\N	General	0.00	15
1558	Kit Herramientas	45.00	juguete	1416	1	t	\N	General	0.00	15
1559	Sombras Pastel/Helado	55.00	juguete	1417	1	t	\N	General	0.00	15
1560	Sombras	45.00	juguete	1418	1	t	\N	General	0.00	15
1561	Porta Gafet	40.00	personaje	1419	7	t	\N	General	0.00	15
1562	Uno	50.00	juguete	1420	1	t	\N	General	0.00	15
1563	Slaim	20.00	varios colores	1112	4	t	\N	General	0.00	15
1564	Piano	70.00	juguete	816	1	t	\N	General	0.00	15
1566	Separadores	35.00	plastico 	83	1	t	\N	General	0.00	15
1567	Postit	15.00	76mmx51mm	312	8	t	\N	General	0.00	15
1568	Burbujas	15.00	grande 	720	6	t	\N	General	0.00	15
1569	Mini Cuento	25.00	varios	1160	3	t	\N	General	0.00	15
1570	Chocolate	19.00	c/2	1193	9	t	\N	General	0.00	15
1571	Flauta	60.00	scool	1421	2	t	\N	General	0.00	15
1572	Caja Clip	25.00	colores clip jumbo	500	3	t	\N	General	0.00	15
1573	Burbujas	20.00	gel	1422	15	t	\N	General	0.00	15
1574	Pluma C/ 6 Colores	30.00	enamorados\n	1423	5	t	\N	General	0.00	15
1575	Brocha	20.00	esponja	1424	4	t	\N	General	0.00	15
1576	Plastilina Barra	17.00	naranja	1425	5	t	\N	General	0.00	15
1577	Papel Roca	18.00	pliego\n	228	2	t	\N	General	0.00	15
1578	Letrero	50.00	enamorados inflable	229	5	t	\N	General	0.00	15
1580	Letrero	25.00	enamorados papel\n	796	2	t	\N	General	0.00	15
1581	Llaveros	25.00	enamodados corazon\n	818	14	t	\N	General	0.00	15
1582	Cubo 16.5 X 14	45.00	ENAMORADO PASTA DURA\n	1426	1	t	\N	General	0.00	15
1584	Bolsa de Regalo	35.00	boutique	983	4	t	\N	General	0.00	15
1585	Resistol Liquido	30.00	super kole 120 gr	965	3	t	\N	General	0.00	15
1586	Recibo de Dinero	35.00	block	343	2	t	\N	General	0.00	15
1587	Pintura Politec 20 Ml	17.00	amarillo	321	37	t	\N	General	0.00	15
1588	Borrador	13.00	repuesto	324	10	t	\N	General	0.00	15
1589	Pluma Borrable	15.00	negra	325	11	t	\N	General	0.00	15
1590	Pluma Borrable	30.00	azul 	327	5	t	\N	General	0.00	15
1591	Cuaderno Italiano	40.00	c.grande	328	1	t	\N	General	0.00	15
1592	Hojas de Color	1.50	varios colores	126	9849	t	\N	General	0.00	15
1593	Brocha	20.00	# 5 y 7	135	12	t	\N	General	0.00	15
1594	Colores	110.00	maped 12+1+1	192	1	t	\N	General	0.00	15
1595	Colores	90.00	maped c/12\n	193	3	t	\N	General	0.00	15
1596	Marcador Agua	53.00	pelikan paq c/6 fluorecente	330	2	t	\N	General	0.00	15
1597	Marcador Agua	45.00	pelikan paq C/6 PRIMARIOS 	331	2	t	\N	General	0.00	15
1598	Hojas de Recopilador	60.00	c.chico stricker	333	3	t	\N	General	0.00	15
1599	Marcador Doble Punta	45.00	sharpie\n	336	3	t	\N	General	0.00	15
1600	Letrero	5.00	se vende / se renta chico	337	98	t	\N	General	0.00	15
1601	Pinza P/Cabello	20.00	paq.c/2pza	338	11	t	\N	General	0.00	15
\.


--
-- Data for Name: tienda_productos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tienda_productos (id, tienda_id, nombre, precio, notas, updated_at) FROM stdin;
\.


--
-- Data for Name: tiendas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tiendas (id, nombre, direccion, telefono, notas, created_at) FROM stdin;
\.


--
-- Data for Name: ventas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ventas (id, fecha, total, descuento, monto_recibido, metodo_pago) FROM stdin;
5	2025-08-28 21:00:43.600996	2.00	0.00	2.00	efectivo
6	2025-08-28 22:20:59.786375	35.00	0.00	35.00	efectivo
7	2025-09-04 21:24:39.388911	36.00	0.00	36.00	efectivo
8	2025-09-04 21:25:19.685431	45.00	0.00	45.00	efectivo
9	2025-09-05 15:27:15.288328	125.50	0.00	125.50	efectivo
10	2025-09-05 15:27:28.007362	10.00	0.00	10.00	efectivo
11	2025-09-05 15:28:09.602154	8.00	0.00	8.00	efectivo
12	2025-09-06 13:08:56.063026	14.00	0.00	14.00	efectivo
13	2025-09-06 13:09:21.357653	14.00	0.00	14.00	efectivo
14	2025-09-06 13:09:26.949833	2.00	0.00	2.00	efectivo
15	2025-09-08 11:18:13.300536	23.00	0.00	23.00	efectivo
16	2025-09-08 11:20:45.341072	75.00	0.00	75.00	efectivo
17	2025-09-08 13:12:04.334462	8.00	0.00	8.00	efectivo
18	2025-09-08 14:58:32.144146	36.00	0.00	36.00	efectivo
19	2025-09-08 15:30:51.467614	16.00	0.00	16.00	efectivo
20	2025-09-08 15:34:32.930271	7.50	0.00	7.50	efectivo
21	2025-09-08 15:41:56.382028	4.00	0.00	4.00	efectivo
22	2025-09-08 15:51:46.88984	2.00	0.00	2.00	efectivo
23	2025-09-08 15:59:08.31167	44.50	0.00	44.50	efectivo
24	2025-09-08 16:15:36.985081	2.00	0.00	2.00	efectivo
25	2025-09-08 16:17:30.052631	49.00	0.00	49.00	efectivo
26	2025-09-08 17:14:12.93053	50.00	0.00	50.00	efectivo
27	2025-09-08 17:37:15.380344	46.00	0.00	46.00	efectivo
28	2025-09-08 17:37:40.325687	31.00	0.00	31.00	efectivo
29	2025-09-08 17:41:47.924814	5.00	0.00	5.00	efectivo
30	2025-09-08 17:48:38.559111	41.00	0.00	41.00	efectivo
31	2025-09-08 17:50:19.538505	3.00	0.00	3.00	efectivo
32	2025-09-08 18:10:33.578151	16.00	0.00	16.00	efectivo
33	2025-09-09 13:27:20.35653	52.00	0.00	52.00	efectivo
34	2025-09-09 13:28:23.810173	124.00	0.00	124.00	efectivo
35	2025-09-09 14:19:27.218443	32.00	0.00	32.00	efectivo
36	2025-09-09 16:20:17.503834	5.00	0.00	5.00	efectivo
37	2025-09-09 16:20:35.828842	2.00	0.00	2.00	efectivo
38	2025-09-09 17:42:13.986801	40.00	0.00	40.00	efectivo
39	2025-09-09 17:55:41.795506	16.00	0.00	16.00	efectivo
40	2025-09-09 18:01:23.435541	18.00	0.00	18.00	efectivo
41	2025-09-09 18:29:06.840694	17.00	0.00	17.00	efectivo
42	2025-09-09 18:53:07.351988	19.00	0.00	19.00	efectivo
43	2025-09-09 19:10:06.116967	15.00	0.00	15.00	efectivo
44	2025-09-09 20:11:36.951191	25.00	0.00	25.00	efectivo
45	2025-09-10 12:15:17.130725	10.00	0.00	10.00	efectivo
46	2025-09-10 12:15:31.990931	50.00	0.00	50.00	efectivo
47	2025-09-10 12:16:49.73598	31.00	0.00	31.00	efectivo
48	2025-09-10 16:43:50.916562	60.00	0.00	60.00	efectivo
49	2025-09-10 16:44:45.748434	156.00	0.00	156.00	efectivo
50	2025-09-10 17:47:50.552603	27.00	0.00	27.00	efectivo
51	2025-09-10 17:52:30.805563	33.00	0.00	33.00	efectivo
52	2025-09-10 17:53:05.503031	5.00	0.00	5.00	efectivo
53	2025-09-10 18:11:08.706325	21.00	0.00	21.00	efectivo
54	2025-09-10 18:35:01.97693	44.00	0.00	44.00	efectivo
55	2025-09-10 18:35:14.271225	8.00	0.00	8.00	efectivo
56	2025-09-10 18:36:55.574571	72.00	0.00	72.00	efectivo
57	2025-09-10 18:54:52.136314	5.00	0.00	5.00	efectivo
58	2025-09-10 18:55:18.662891	28.00	0.00	28.00	efectivo
59	2025-09-10 19:10:51.015515	64.00	0.00	64.00	efectivo
60	2025-09-11 13:11:44.929381	90.00	0.00	90.00	efectivo
61	2025-09-11 13:12:06.917117	125.00	0.00	125.00	efectivo
62	2025-09-11 13:29:51.538849	48.00	0.00	48.00	efectivo
63	2025-09-11 14:04:47.383585	10.50	0.00	10.50	efectivo
64	2025-09-11 14:32:31.193112	110.00	0.00	110.00	efectivo
65	2025-09-11 14:34:15.021459	30.00	0.00	30.00	efectivo
66	2025-09-11 14:43:34.573002	18.00	0.00	18.00	efectivo
67	2025-09-11 16:34:17.919978	22.00	0.00	22.00	efectivo
68	2025-09-11 17:37:29.877558	10.00	0.00	10.00	efectivo
69	2025-09-11 17:55:09.291355	71.00	0.00	71.00	efectivo
70	2025-09-11 17:55:31.417104	130.00	0.00	130.00	efectivo
71	2025-09-11 18:13:59.337353	20.00	0.00	20.00	efectivo
72	2025-09-12 13:00:44.360239	60.00	0.00	60.00	efectivo
73	2025-09-12 13:01:00.757534	25.00	0.00	25.00	efectivo
74	2025-09-12 17:39:29.990345	22.50	0.00	22.50	efectivo
75	2025-09-12 17:42:20.851396	25.00	0.00	25.00	efectivo
76	2025-09-12 18:05:35.236451	6.00	0.00	6.00	efectivo
77	2025-09-12 18:23:42.38632	45.00	0.00	45.00	efectivo
78	2025-09-12 18:25:01.487083	15.00	0.00	15.00	efectivo
79	2025-09-12 18:48:56.043381	20.50	0.00	20.50	efectivo
80	2025-09-12 19:06:35.83777	60.00	0.00	60.00	efectivo
81	2025-09-13 11:34:17.073696	20.00	0.00	20.00	efectivo
82	2025-09-13 11:35:37.29152	55.00	0.00	55.00	efectivo
83	2025-09-13 11:57:22.283862	4.00	0.00	4.00	efectivo
84	2025-09-13 11:57:34.066955	15.00	0.00	15.00	efectivo
85	2025-09-13 11:59:29.59973	12.00	0.00	12.00	efectivo
86	2025-09-13 13:27:16.139099	79.00	0.00	79.00	efectivo
87	2025-09-13 13:31:20.632944	28.00	0.00	28.00	efectivo
88	2025-09-13 13:32:05.965644	30.00	0.00	30.00	efectivo
89	2025-09-13 13:33:23.861281	25.00	0.00	25.00	efectivo
90	2025-09-13 14:26:37.168485	35.00	0.00	35.00	efectivo
91	2025-09-13 15:03:22.86905	9.00	0.00	9.00	efectivo
92	2025-09-13 15:03:29.70538	20.00	0.00	20.00	efectivo
93	2025-09-13 15:16:00.397049	83.00	0.00	83.00	efectivo
94	2025-09-13 16:15:45.923103	202.00	0.00	202.00	efectivo
95	2025-09-13 16:18:15.763288	20.00	0.00	20.00	efectivo
96	2025-09-13 16:37:28.338408	137.00	0.00	137.00	efectivo
97	2025-09-13 17:21:27.049499	43.00	0.00	43.00	efectivo
98	2025-09-14 11:47:45.223345	175.00	0.00	175.00	efectivo
99	2025-09-14 11:48:13.408948	100.00	0.00	100.00	efectivo
100	2025-09-15 14:25:10.005834	75.00	0.00	75.00	efectivo
101	2025-09-15 14:25:37.404321	75.00	0.00	75.00	efectivo
102	2025-09-15 15:21:42.474959	38.00	0.00	38.00	efectivo
103	2025-09-15 15:22:18.438859	14.00	0.00	14.00	efectivo
104	2025-09-15 15:35:52.88207	25.00	0.00	25.00	efectivo
105	2025-09-15 16:11:30.954361	105.00	0.00	105.00	efectivo
106	2025-09-15 16:59:49.11136	26.00	0.00	26.00	efectivo
107	2025-09-15 17:09:43.691383	11.00	0.00	11.00	efectivo
108	2025-09-15 17:13:13.482037	208.00	0.00	208.00	efectivo
109	2025-09-15 18:20:57.326601	50.00	0.00	50.00	efectivo
110	2025-09-17 11:12:19.133539	109.00	0.00	109.00	efectivo
111	2025-09-17 11:12:52.590226	15.00	0.00	15.00	efectivo
112	2025-09-17 11:54:45.127381	2.00	0.00	2.00	efectivo
113	2025-09-17 12:15:41.678853	15.00	0.00	15.00	efectivo
114	2025-09-17 12:26:21.299835	14.00	0.00	14.00	efectivo
115	2025-09-17 12:27:06.836729	8.00	0.00	8.00	efectivo
116	2025-09-17 13:16:59.875845	45.00	0.00	45.00	efectivo
117	2025-09-17 13:20:09.333738	30.00	0.00	30.00	efectivo
118	2025-09-17 13:31:25.545421	16.00	0.00	16.00	efectivo
119	2025-09-17 13:31:36.089272	12.00	0.00	12.00	efectivo
120	2025-09-17 13:56:26.494623	18.00	0.00	18.00	efectivo
121	2025-09-17 14:21:40.819482	48.00	0.00	48.00	efectivo
122	2025-09-17 14:26:27.917046	60.00	0.00	60.00	efectivo
123	2025-09-17 16:56:02.773895	95.00	0.00	95.00	efectivo
124	2025-09-17 17:02:30.226689	210.00	0.00	210.00	efectivo
125	2025-09-17 17:03:01.599931	4.00	0.00	4.00	efectivo
126	2025-09-17 17:18:17.364397	7.00	0.00	7.00	efectivo
127	2025-09-17 17:22:49.936699	73.00	0.00	73.00	efectivo
128	2025-09-17 17:31:48.003939	18.00	0.00	18.00	efectivo
129	2025-09-17 17:34:09.524543	30.00	0.00	30.00	efectivo
130	2025-09-17 18:05:56.179288	36.00	0.00	36.00	efectivo
131	2025-09-17 18:35:20.475694	225.00	0.00	225.00	efectivo
132	2025-09-17 18:35:57.857805	35.00	0.00	35.00	efectivo
133	2025-09-17 19:39:33.053003	15.00	0.00	15.00	efectivo
134	2025-09-17 23:32:14.399384	40.00	0.00	40.00	efectivo
135	2025-09-18 11:58:40.838702	40.00	0.00	40.00	efectivo
136	2025-09-18 11:59:21.327973	32.00	0.00	32.00	efectivo
137	2025-09-18 12:00:41.029829	6.00	0.00	6.00	efectivo
138	2025-09-18 12:07:02.270645	12.00	0.00	12.00	efectivo
139	2025-09-18 12:42:03.011741	6.00	0.00	6.00	efectivo
140	2025-09-18 12:58:17.942009	12.50	0.00	12.50	efectivo
141	2025-09-18 13:23:45.54993	2.00	0.00	2.00	efectivo
142	2025-09-18 14:12:27.200335	25.00	0.00	25.00	efectivo
143	2025-09-18 15:52:00.211459	50.00	0.00	50.00	efectivo
144	2025-09-18 16:35:27.925967	51.00	0.00	51.00	efectivo
145	2025-09-18 16:37:54.025937	20.00	0.00	20.00	efectivo
146	2025-09-18 16:54:00.262375	91.00	0.00	91.00	efectivo
147	2025-09-18 16:54:25.757218	6.00	0.00	6.00	efectivo
148	2025-09-18 17:39:51.424328	55.00	0.00	55.00	efectivo
149	2025-09-18 17:40:12.131581	65.00	0.00	65.00	efectivo
150	2025-09-18 17:44:55.387256	16.00	0.00	16.00	efectivo
151	2025-09-18 19:32:33.798179	50.00	0.00	50.00	efectivo
152	2025-09-18 19:33:21.006919	14.00	0.00	14.00	efectivo
153	2025-09-18 19:37:49.603274	3.00	0.00	3.00	efectivo
154	2025-09-18 19:39:40.892213	8.00	0.00	8.00	efectivo
155	2025-09-18 19:46:11.099658	10.00	0.00	10.00	efectivo
156	2025-09-18 19:57:31.038948	102.00	0.00	102.00	efectivo
157	2025-09-18 19:59:02.053033	2.00	0.00	2.00	efectivo
158	2025-09-19 10:51:33.160356	16.00	0.00	16.00	efectivo
159	2025-09-19 10:52:34.162953	20.00	0.00	20.00	efectivo
160	2025-09-19 11:08:18.430953	40.00	0.00	40.00	efectivo
161	2025-09-19 12:17:16.368337	10.00	0.00	10.00	efectivo
162	2025-09-19 13:20:27.787436	30.00	0.00	30.00	efectivo
163	2025-09-19 14:03:21.533202	6.00	0.00	6.00	efectivo
164	2025-09-19 14:03:42.137254	105.00	0.00	105.00	efectivo
165	2025-09-19 14:23:52.576652	14.00	0.00	14.00	efectivo
166	2025-09-19 17:50:41.192357	35.00	0.00	35.00	efectivo
167	2025-09-19 18:10:21.74761	20.00	0.00	20.00	efectivo
168	2025-09-19 18:31:12.731751	9.00	0.00	9.00	efectivo
169	2025-09-19 18:31:26.548284	20.00	0.00	20.00	efectivo
170	2025-09-19 19:27:42.900759	15.00	0.00	15.00	efectivo
171	2025-09-19 19:30:52.294104	9.00	0.00	9.00	efectivo
172	2025-09-20 11:51:53.253458	31.00	0.00	31.00	efectivo
173	2025-09-20 12:19:33.415323	57.00	0.00	57.00	efectivo
174	2025-09-20 12:19:45.006216	20.00	0.00	20.00	efectivo
175	2025-09-20 12:38:15.002974	15.00	0.00	15.00	efectivo
176	2025-09-20 12:39:19.129742	2.00	0.00	2.00	efectivo
177	2025-09-20 12:49:25.597267	29.50	0.00	29.50	efectivo
178	2025-09-20 12:56:10.333448	18.00	0.00	18.00	efectivo
179	2025-09-20 13:05:21.510162	22.00	0.00	22.00	efectivo
180	2025-09-20 13:54:34.700076	52.00	0.00	52.00	efectivo
181	2025-09-20 14:03:32.783617	15.50	0.00	15.50	efectivo
182	2025-09-20 14:20:33.746786	28.00	0.00	28.00	efectivo
183	2025-09-20 14:31:17.205789	34.00	0.00	34.00	efectivo
184	2025-09-20 14:32:00.459233	5.00	0.00	5.00	efectivo
185	2025-09-20 14:41:07.706703	15.50	0.00	15.50	efectivo
186	2025-09-20 16:03:07.090978	38.50	0.00	38.50	efectivo
187	2025-09-20 17:00:42.052721	306.00	0.00	306.00	efectivo
188	2025-09-20 17:06:50.638653	22.00	0.00	22.00	efectivo
189	2025-09-20 17:08:10.716755	18.00	0.00	18.00	efectivo
190	2025-09-22 12:54:01.385374	25.00	0.00	25.00	efectivo
191	2025-09-22 12:55:07.21839	5.00	0.00	5.00	efectivo
192	2025-09-22 12:55:14.362874	35.00	0.00	35.00	efectivo
193	2025-09-22 13:04:20.437479	2.00	0.00	2.00	efectivo
194	2025-09-22 13:05:36.498479	4.00	0.00	4.00	efectivo
195	2025-09-22 13:12:40.403014	9.00	0.00	9.00	efectivo
196	2025-09-22 13:24:23.769444	4.00	0.00	4.00	efectivo
197	2025-09-22 13:49:56.593282	90.50	0.00	90.50	efectivo
198	2025-09-22 13:51:20.2615	42.00	0.00	42.00	efectivo
199	2025-09-22 14:18:36.927515	35.00	0.00	35.00	efectivo
200	2025-09-22 14:20:36.310733	40.00	0.00	40.00	efectivo
201	2025-09-22 14:24:06.662592	36.00	0.00	36.00	efectivo
202	2025-09-22 14:34:06.03505	55.00	0.00	55.00	efectivo
203	2025-09-22 14:37:57.708611	17.00	0.00	17.00	efectivo
204	2025-09-22 16:59:39.911568	95.00	0.00	95.00	efectivo
205	2025-09-22 17:04:17.774688	25.00	0.00	25.00	efectivo
206	2025-09-22 17:14:50.513517	24.00	0.00	24.00	efectivo
207	2025-09-22 17:27:51.074827	28.00	0.00	28.00	efectivo
208	2025-09-22 18:08:52.997267	43.00	0.00	43.00	efectivo
209	2025-09-22 19:06:12.271797	30.00	0.00	30.00	efectivo
210	2025-09-22 19:27:57.990794	10.00	0.00	10.00	efectivo
211	2025-09-22 19:28:17.263548	9.00	0.00	9.00	efectivo
212	2025-09-22 19:37:07.016466	45.00	0.00	45.00	efectivo
213	2025-09-22 20:14:29.797266	254.00	0.00	254.00	efectivo
214	2025-09-22 20:41:18.468274	15.00	0.00	15.00	efectivo
215	2025-09-23 11:34:10.803718	130.00	0.00	130.00	efectivo
216	2025-09-23 11:34:17.783826	4.00	0.00	4.00	efectivo
217	2025-09-23 11:34:56.086676	65.00	0.00	65.00	efectivo
218	2025-09-23 11:44:03.903932	5.00	0.00	5.00	efectivo
219	2025-09-23 12:35:52.86765	50.00	0.00	50.00	efectivo
220	2025-09-23 12:37:51.021479	85.00	0.00	85.00	efectivo
221	2025-09-23 12:38:14.71638	4.00	0.00	4.00	efectivo
222	2025-09-23 13:39:11.822808	13.00	0.00	13.00	efectivo
223	2025-09-23 14:31:09.433385	70.00	0.00	70.00	efectivo
224	2025-09-23 16:38:35.38463	72.00	0.00	72.00	efectivo
225	2025-09-23 16:38:52.938552	75.00	0.00	75.00	efectivo
226	2025-09-23 16:48:28.314894	35.00	0.00	35.00	efectivo
227	2025-09-23 17:00:00.657542	80.00	0.00	80.00	efectivo
228	2025-09-23 17:19:17.238716	35.00	0.00	35.00	efectivo
229	2025-09-23 17:19:32.703015	7.00	0.00	7.00	efectivo
230	2025-09-23 17:19:46.37147	35.00	0.00	35.00	efectivo
231	2025-09-23 17:24:19.867538	36.00	0.00	36.00	efectivo
232	2025-09-23 18:32:00.820281	40.00	0.00	40.00	efectivo
233	2025-09-23 18:41:01.307835	48.00	0.00	48.00	efectivo
234	2025-09-23 18:43:38.913784	30.00	0.00	30.00	efectivo
235	2025-09-23 18:49:20.558922	15.00	0.00	15.00	efectivo
236	2025-09-23 18:55:04.242522	16.00	0.00	16.00	efectivo
237	2025-09-23 18:55:19.586463	9.00	0.00	9.00	efectivo
238	2025-09-23 18:55:32.374973	75.00	0.00	75.00	efectivo
239	2025-09-23 19:18:37.824999	60.00	0.00	60.00	efectivo
240	2025-09-23 19:24:37.474176	35.00	0.00	35.00	efectivo
241	2025-09-23 19:29:39.273466	39.00	0.00	39.00	efectivo
242	2025-09-23 19:29:50.018877	5.00	0.00	5.00	efectivo
243	2025-09-23 19:57:31.148316	58.00	0.00	58.00	efectivo
244	2025-09-23 20:12:53.882646	13.00	0.00	13.00	efectivo
245	2025-09-23 20:14:17.553561	55.00	0.00	55.00	efectivo
246	2025-09-23 20:43:31.012764	87.00	0.00	87.00	efectivo
247	2025-09-24 14:16:05.240755	146.00	0.00	146.00	efectivo
248	2025-09-24 14:34:17.611505	18.50	0.00	18.50	efectivo
249	2025-09-24 15:30:20.821962	25.00	0.00	25.00	efectivo
250	2025-09-24 15:48:24.467948	13.00	0.00	13.00	efectivo
251	2025-09-24 16:48:42.946982	50.00	0.00	50.00	efectivo
252	2025-09-24 17:09:59.716297	14.00	0.00	14.00	efectivo
253	2025-09-24 17:10:21.57764	12.00	0.00	12.00	efectivo
254	2025-09-24 17:23:09.346646	16.00	0.00	16.00	efectivo
255	2025-09-24 18:17:56.89167	10.00	0.00	10.00	efectivo
256	2025-09-24 18:53:43.844948	75.00	0.00	75.00	efectivo
257	2025-09-24 18:55:14.980347	81.00	0.00	81.00	efectivo
258	2025-09-24 18:57:53.579051	70.00	0.00	70.00	efectivo
259	2025-09-24 19:21:36.044718	3.00	0.00	3.00	efectivo
260	2025-09-24 19:28:15.855856	42.50	0.00	42.50	efectivo
261	2025-09-24 19:35:41.732086	28.00	0.00	28.00	efectivo
262	2025-09-24 19:35:53.555138	54.00	0.00	54.00	efectivo
263	2025-09-24 19:36:01.662062	25.00	0.00	25.00	efectivo
264	2025-09-24 20:13:35.71074	148.00	0.00	148.00	efectivo
265	2025-09-25 11:26:10.148272	47.00	0.00	47.00	efectivo
266	2025-09-25 11:32:28.556565	40.00	0.00	40.00	efectivo
267	2025-09-25 11:50:04.615289	50.00	0.00	50.00	efectivo
268	2025-09-25 11:54:50.000313	6.00	0.00	6.00	efectivo
269	2025-09-25 12:08:12.607887	151.00	0.00	151.00	efectivo
270	2025-09-25 12:08:30.099552	30.00	0.00	30.00	efectivo
271	2025-09-25 12:11:26.777567	23.00	0.00	23.00	efectivo
272	2025-09-25 12:16:44.720237	31.50	0.00	31.50	efectivo
273	2025-09-25 13:25:28.457383	4.00	0.00	4.00	efectivo
274	2025-09-25 13:58:07.884718	25.00	0.00	25.00	efectivo
275	2025-09-25 14:21:01.285206	115.00	0.00	115.00	efectivo
276	2025-09-25 16:42:37.763718	98.50	0.00	98.50	efectivo
277	2025-09-25 16:52:28.583628	20.00	0.00	20.00	efectivo
278	2025-09-25 17:10:00.921716	10.00	0.00	10.00	efectivo
279	2025-09-25 17:21:46.108252	55.00	0.00	55.00	efectivo
280	2025-09-25 17:24:45.163917	44.00	0.00	44.00	efectivo
281	2025-09-25 17:31:14.575568	22.00	0.00	22.00	efectivo
282	2025-09-25 17:41:35.340593	48.00	0.00	48.00	efectivo
283	2025-09-25 19:19:15.738754	33.00	0.00	33.00	efectivo
284	2025-09-25 20:28:47.970113	74.00	0.00	74.00	efectivo
285	2025-09-25 20:28:59.192928	8.00	0.00	8.00	efectivo
286	2025-09-26 10:57:59.899524	75.00	0.00	75.00	efectivo
287	2025-09-26 10:58:14.590688	28.00	0.00	28.00	efectivo
288	2025-09-26 10:58:27.935763	4.00	0.00	4.00	efectivo
289	2025-09-26 11:05:11.50926	35.00	0.00	35.00	efectivo
290	2025-09-26 11:10:08.134703	43.00	0.00	43.00	efectivo
291	2025-09-26 11:42:27.429139	20.00	0.00	20.00	efectivo
292	2025-09-26 11:42:27.435036	34.00	0.00	34.00	efectivo
293	2025-09-26 12:46:11.041365	17.00	0.00	17.00	efectivo
294	2025-09-26 15:34:30.620266	24.00	0.00	24.00	efectivo
295	2025-09-26 16:02:57.041362	2.50	0.00	2.50	efectivo
296	2025-09-26 16:03:22.911096	50.00	0.00	50.00	efectivo
297	2025-09-26 17:55:20.327249	10.00	0.00	10.00	efectivo
298	2025-09-26 19:57:25.866872	107.00	0.00	107.00	efectivo
299	2025-09-26 20:11:40.42489	45.00	0.00	45.00	efectivo
300	2025-09-27 12:08:30.516615	97.00	0.00	97.00	efectivo
301	2025-09-27 12:08:47.746041	15.00	0.00	15.00	efectivo
302	2025-09-27 12:21:01.798506	30.00	0.00	30.00	efectivo
303	2025-09-27 12:29:20.400008	14.00	0.00	14.00	efectivo
304	2025-09-27 12:37:42.472869	76.00	0.00	76.00	efectivo
305	2025-09-27 12:57:56.297676	35.00	0.00	35.00	efectivo
306	2025-09-27 13:03:29.875661	37.00	0.00	37.00	efectivo
307	2025-09-27 13:50:41.077722	12.50	0.00	12.50	efectivo
308	2025-09-27 14:53:35.567533	50.00	0.00	50.00	efectivo
309	2025-09-27 15:10:03.58905	10.00	0.00	10.00	efectivo
310	2025-09-27 15:50:37.995108	35.00	0.00	35.00	efectivo
311	2025-09-27 16:18:36.537519	27.00	0.00	27.00	efectivo
312	2025-09-27 16:18:41.574015	17.50	0.00	17.50	efectivo
313	2025-09-27 16:31:32.581229	30.00	0.00	30.00	efectivo
314	2025-09-27 17:03:11.982569	24.00	0.00	24.00	efectivo
315	2025-09-27 17:05:28.85304	42.00	0.00	42.00	efectivo
316	2025-09-29 13:29:24.150049	25.00	0.00	25.00	efectivo
317	2025-09-29 13:29:37.110843	10.00	0.00	10.00	efectivo
318	2025-09-29 13:48:10.331222	52.00	0.00	52.00	efectivo
319	2025-09-29 14:00:59.90742	20.00	0.00	20.00	efectivo
320	2025-09-29 14:11:42.7157	30.00	0.00	30.00	efectivo
321	2025-09-29 14:30:45.279849	8.00	0.00	8.00	efectivo
322	2025-09-29 17:14:59.053363	44.00	0.00	44.00	efectivo
323	2025-09-29 17:15:06.429064	4.00	0.00	4.00	efectivo
324	2025-09-29 17:23:54.204554	5.00	0.00	5.00	efectivo
325	2025-09-29 17:51:42.238476	2.00	0.00	2.00	efectivo
326	2025-09-29 17:54:51.680167	14.00	0.00	14.00	efectivo
327	2025-09-29 18:10:43.294456	119.00	0.00	119.00	efectivo
328	2025-09-29 18:10:47.821693	12.00	0.00	12.00	efectivo
329	2025-09-29 18:41:25.404763	40.00	0.00	40.00	efectivo
330	2025-09-29 18:46:12.523278	8.00	0.00	8.00	efectivo
331	2025-09-29 18:54:35.635198	10.00	0.00	10.00	efectivo
332	2025-09-29 19:01:39.971585	25.00	0.00	25.00	efectivo
333	2025-09-29 19:01:59.109801	22.00	0.00	22.00	efectivo
334	2025-09-29 19:02:31.900495	100.00	0.00	100.00	efectivo
335	2025-09-29 19:03:01.053574	35.00	0.00	35.00	efectivo
336	2025-09-29 19:15:05.484917	5.00	0.00	5.00	efectivo
337	2025-09-29 19:17:41.780097	10.00	0.00	10.00	efectivo
338	2025-09-29 19:37:02.644027	54.00	0.00	54.00	efectivo
339	2025-09-29 20:00:31.572213	4.00	0.00	4.00	efectivo
340	2025-09-29 20:06:21.483404	38.00	0.00	38.00	efectivo
341	2025-09-29 20:13:12.68295	32.00	0.00	32.00	efectivo
342	2025-09-29 20:13:26.455825	10.00	0.00	10.00	efectivo
343	2025-09-29 20:14:18.512491	11.50	0.00	11.50	efectivo
344	2025-09-29 20:14:35.694605	9.00	0.00	9.00	efectivo
345	2025-09-29 20:21:47.044662	9.00	0.00	9.00	efectivo
346	2025-09-29 20:34:05.121986	110.00	0.00	110.00	efectivo
347	2025-09-29 20:45:39.183971	186.50	0.00	186.50	efectivo
348	2025-09-29 20:55:16.090296	20.00	0.00	20.00	efectivo
349	2025-09-30 10:45:45.464199	6.00	0.00	6.00	efectivo
350	2025-09-30 11:14:00.874267	127.00	0.00	127.00	efectivo
351	2025-09-30 11:49:40.312958	45.00	0.00	45.00	efectivo
352	2025-09-30 11:50:29.869862	71.00	0.00	71.00	efectivo
353	2025-09-30 12:06:05.417602	14.00	0.00	14.00	efectivo
354	2025-09-30 12:21:32.157918	28.00	0.00	28.00	efectivo
355	2025-09-30 12:59:15.248948	29.00	0.00	29.00	efectivo
356	2025-09-30 14:14:06.627238	39.00	0.00	39.00	efectivo
357	2025-09-30 14:14:30.152993	32.00	0.00	32.00	efectivo
358	2025-09-30 17:35:44.104137	7.00	0.00	7.00	efectivo
359	2025-09-30 17:41:42.292205	15.00	0.00	15.00	efectivo
360	2025-09-30 18:05:51.123387	37.00	0.00	37.00	efectivo
479	2025-10-06 18:59:11.069158	47.00	0.00	47.00	efectivo
361	2025-09-30 18:09:51.366544	2.50	0.00	2.50	efectivo
362	2025-09-30 18:19:00.087934	10.00	0.00	10.00	efectivo
363	2025-09-30 18:24:08.701142	14.00	0.00	14.00	efectivo
364	2025-09-30 18:45:30.020589	69.00	0.00	69.00	efectivo
365	2025-09-30 18:45:52.662598	45.00	0.00	45.00	efectivo
366	2025-09-30 19:05:42.993604	36.00	0.00	36.00	efectivo
367	2025-09-30 19:48:52.500159	24.00	0.00	24.00	efectivo
368	2025-09-30 20:22:17.304705	63.00	0.00	63.00	efectivo
369	2025-09-30 20:24:44.014739	55.00	0.00	55.00	efectivo
370	2025-09-30 20:26:30.682771	30.00	0.00	30.00	efectivo
371	2025-09-30 20:35:14.162409	16.00	0.00	16.00	efectivo
372	2025-09-30 20:35:25.60831	25.00	0.00	25.00	efectivo
373	2025-09-30 21:00:22.928025	22.00	0.00	22.00	efectivo
374	2025-10-01 13:57:04.0583	12.00	0.00	12.00	efectivo
375	2025-10-01 13:57:30.989464	35.00	0.00	35.00	efectivo
376	2025-10-01 14:36:48.662778	4.00	0.00	4.00	efectivo
377	2025-10-01 16:39:00.215784	20.00	0.00	20.00	efectivo
378	2025-10-01 17:09:35.206015	7.00	0.00	7.00	efectivo
379	2025-10-01 17:37:12.39614	3.50	0.00	3.50	efectivo
380	2025-10-01 17:40:24.972571	45.00	0.00	45.00	efectivo
381	2025-10-01 17:42:27.904731	15.00	0.00	15.00	efectivo
382	2025-10-01 17:53:27.384177	154.00	0.00	154.00	efectivo
383	2025-10-01 18:01:37.544893	125.00	0.00	125.00	efectivo
384	2025-10-01 18:13:26.560441	7.00	0.00	7.00	efectivo
385	2025-10-01 18:18:36.764832	25.00	0.00	25.00	efectivo
386	2025-10-01 18:21:49.875483	17.00	0.00	17.00	efectivo
387	2025-10-01 18:31:59.479184	70.00	0.00	70.00	efectivo
388	2025-10-01 18:34:40.903125	12.00	0.00	12.00	efectivo
389	2025-10-01 18:53:33.566246	14.00	0.00	14.00	efectivo
390	2025-10-01 18:55:47.65469	24.00	0.00	24.00	efectivo
391	2025-10-01 19:00:07.069342	30.00	0.00	30.00	efectivo
392	2025-10-01 19:14:59.178776	91.00	0.00	91.00	efectivo
393	2025-10-01 19:15:05.665068	14.00	0.00	14.00	efectivo
394	2025-10-01 19:15:27.552571	13.50	0.00	13.50	efectivo
395	2025-10-01 19:35:06.878428	15.00	0.00	15.00	efectivo
396	2025-10-01 19:35:12.790985	25.00	0.00	25.00	efectivo
397	2025-10-01 19:41:42.80719	18.00	0.00	18.00	efectivo
398	2025-10-01 19:57:41.777859	52.00	0.00	52.00	efectivo
399	2025-10-01 20:10:07.808798	64.00	0.00	64.00	efectivo
400	2025-10-01 20:36:35.633498	28.00	0.00	28.00	efectivo
401	2025-10-01 20:52:52.054696	80.50	0.00	80.50	efectivo
402	2025-10-01 21:18:52.500166	21.00	0.00	21.00	efectivo
403	2025-10-02 16:36:20.830984	25.00	0.00	25.00	efectivo
404	2025-10-02 16:47:29.669642	20.00	0.00	20.00	efectivo
405	2025-10-02 16:50:17.197987	19.50	0.00	19.50	efectivo
406	2025-10-02 16:59:06.578913	28.00	0.00	28.00	efectivo
407	2025-10-02 17:01:04.904043	10.00	0.00	10.00	efectivo
408	2025-10-02 17:26:54.989949	63.00	0.00	63.00	efectivo
409	2025-10-02 17:27:25.569741	67.00	0.00	67.00	efectivo
410	2025-10-02 17:33:49.240303	57.00	0.00	57.00	efectivo
411	2025-10-02 17:37:03.935352	100.00	0.00	100.00	efectivo
412	2025-10-02 18:09:19.893638	10.00	0.00	10.00	efectivo
413	2025-10-02 18:24:39.530983	17.00	0.00	17.00	efectivo
414	2025-10-02 18:27:39.033208	10.00	0.00	10.00	efectivo
415	2025-10-02 18:32:03.60383	20.00	0.00	20.00	efectivo
416	2025-10-02 19:03:05.046115	32.00	0.00	32.00	efectivo
417	2025-10-02 19:10:17.146864	12.00	0.00	12.00	efectivo
418	2025-10-02 19:17:10.380914	93.00	0.00	93.00	efectivo
419	2025-10-02 19:29:10.828694	15.00	0.00	15.00	efectivo
420	2025-10-02 19:34:45.316484	67.00	0.00	67.00	efectivo
421	2025-10-02 19:43:53.294415	32.00	0.00	32.00	efectivo
422	2025-10-02 19:48:33.515369	27.50	0.00	27.50	efectivo
423	2025-10-02 19:58:41.558664	74.00	0.00	74.00	efectivo
424	2025-10-02 20:08:22.972053	42.00	0.00	42.00	efectivo
425	2025-10-02 20:11:36.973034	42.00	0.00	42.00	efectivo
426	2025-10-02 20:12:20.217466	28.00	0.00	28.00	efectivo
427	2025-10-02 20:24:09.056451	35.00	0.00	35.00	efectivo
428	2025-10-02 20:29:21.99694	12.00	0.00	12.00	efectivo
429	2025-10-02 20:53:02.666968	10.00	0.00	10.00	efectivo
430	2025-10-02 20:53:12.479202	6.00	0.00	6.00	efectivo
431	2025-10-03 15:00:10.318729	55.00	0.00	55.00	efectivo
432	2025-10-03 15:20:38.9183	35.00	0.00	35.00	efectivo
433	2025-10-03 17:08:54.1695	15.00	0.00	15.00	efectivo
434	2025-10-03 17:44:49.157269	15.00	0.00	15.00	efectivo
435	2025-10-03 17:51:08.367196	95.00	0.00	95.00	efectivo
436	2025-10-03 17:52:03.869998	135.00	0.00	135.00	efectivo
437	2025-10-03 18:20:31.901248	15.00	0.00	15.00	efectivo
438	2025-10-03 18:51:08.096639	45.00	0.00	45.00	efectivo
439	2025-10-03 18:53:49.55647	20.00	0.00	20.00	efectivo
440	2025-10-03 19:21:33.921667	2.00	0.00	2.00	efectivo
441	2025-10-03 20:51:41.810518	82.00	0.00	82.00	efectivo
442	2025-10-04 13:10:12.187439	181.00	0.00	181.00	efectivo
443	2025-10-04 13:23:32.685165	35.00	0.00	35.00	efectivo
444	2025-10-04 13:48:15.790009	17.50	0.00	17.50	efectivo
445	2025-10-04 13:59:44.651094	27.00	0.00	27.00	efectivo
446	2025-10-04 14:08:49.527445	30.00	0.00	30.00	efectivo
447	2025-10-04 14:17:56.726728	45.00	0.00	45.00	efectivo
448	2025-10-04 14:20:21.379943	30.00	0.00	30.00	efectivo
449	2025-10-04 15:02:58.860981	13.00	0.00	13.00	efectivo
450	2025-10-04 15:17:07.902943	25.00	0.00	25.00	efectivo
451	2025-10-04 15:29:34.088941	17.50	0.00	17.50	efectivo
452	2025-10-06 12:15:45.163494	170.00	0.00	170.00	efectivo
453	2025-10-06 12:16:17.333869	25.00	0.00	25.00	efectivo
454	2025-10-06 12:23:16.042845	16.00	0.00	16.00	efectivo
455	2025-10-06 12:54:27.873831	10.00	0.00	10.00	efectivo
456	2025-10-06 13:14:46.033406	28.50	0.00	28.50	efectivo
457	2025-10-06 13:15:20.359412	62.00	0.00	62.00	efectivo
458	2025-10-06 13:18:02.881121	2.00	0.00	2.00	efectivo
459	2025-10-06 13:24:12.205527	46.00	0.00	46.00	efectivo
460	2025-10-06 13:28:48.043894	21.00	0.00	21.00	efectivo
461	2025-10-06 13:49:43.991382	15.00	0.00	15.00	efectivo
462	2025-10-06 14:24:02.061806	14.00	0.00	14.00	efectivo
463	2025-10-06 14:26:17.854858	115.00	0.00	115.00	efectivo
464	2025-10-06 14:40:32.694948	30.00	0.00	30.00	efectivo
465	2025-10-06 16:13:47.058699	60.00	0.00	60.00	efectivo
466	2025-10-06 16:45:10.438736	40.50	0.00	40.50	efectivo
467	2025-10-06 17:07:55.527845	17.00	0.00	17.00	efectivo
468	2025-10-06 17:46:18.150641	125.00	0.00	125.00	efectivo
469	2025-10-06 18:29:04.66133	25.00	0.00	25.00	efectivo
470	2025-10-06 18:32:07.481233	25.00	0.00	25.00	efectivo
471	2025-10-06 18:34:56.360063	10.00	0.00	10.00	efectivo
472	2025-10-06 18:36:40.623257	89.00	0.00	89.00	efectivo
473	2025-10-06 18:37:06.324138	14.00	0.00	14.00	efectivo
474	2025-10-06 18:41:21.931253	50.00	0.00	50.00	efectivo
475	2025-10-06 18:43:54.410968	88.00	0.00	88.00	efectivo
476	2025-10-06 18:52:25.242445	55.00	0.00	55.00	efectivo
477	2025-10-06 18:52:39.810138	8.00	0.00	8.00	efectivo
478	2025-10-06 18:53:24.299106	12.00	0.00	12.00	efectivo
480	2025-10-06 19:16:18.039211	7.00	0.00	7.00	efectivo
481	2025-10-06 19:24:27.30064	6.00	0.00	6.00	efectivo
482	2025-10-06 19:28:27.596403	4.00	0.00	4.00	efectivo
483	2025-10-06 19:40:48.123663	22.00	0.00	22.00	efectivo
484	2025-10-06 19:41:26.641874	44.00	0.00	44.00	efectivo
485	2025-10-06 19:58:21.143575	30.00	0.00	30.00	efectivo
486	2025-10-06 20:07:06.793323	15.00	0.00	15.00	efectivo
487	2025-10-06 20:09:16.709332	51.00	0.00	51.00	efectivo
488	2025-10-06 20:10:24.989749	7.00	0.00	7.00	efectivo
489	2025-10-07 11:07:56.415618	51.50	0.00	51.50	efectivo
490	2025-10-07 11:11:08.06533	100.00	0.00	100.00	efectivo
491	2025-10-07 11:18:02.421269	90.00	0.00	90.00	efectivo
492	2025-10-07 11:32:00.374813	49.00	0.00	49.00	efectivo
493	2025-10-07 12:04:05.401335	10.00	0.00	10.00	efectivo
494	2025-10-07 12:09:47.565388	26.50	0.00	26.50	efectivo
495	2025-10-07 12:15:07.130845	37.00	0.00	37.00	efectivo
496	2025-10-07 12:16:08.055032	110.00	0.00	110.00	efectivo
497	2025-10-07 13:25:39.787372	277.00	0.00	277.00	efectivo
498	2025-10-07 13:26:09.669966	25.00	0.00	25.00	efectivo
499	2025-10-07 13:26:25.643656	30.00	0.00	30.00	efectivo
500	2025-10-07 13:27:25.701011	106.00	0.00	106.00	efectivo
501	2025-10-07 13:27:41.657368	75.00	0.00	75.00	efectivo
502	2025-10-07 13:36:43.008459	43.00	0.00	43.00	efectivo
503	2025-10-07 14:09:57.069456	26.00	0.00	26.00	efectivo
504	2025-10-07 16:51:34.046916	76.00	0.00	76.00	efectivo
505	2025-10-07 16:51:37.705858	2.00	0.00	2.00	efectivo
506	2025-10-07 17:30:21.096273	110.00	0.00	110.00	efectivo
507	2025-10-07 17:33:26.067445	16.50	0.00	16.50	efectivo
508	2025-10-07 17:57:39.432352	10.00	0.00	10.00	efectivo
509	2025-10-07 18:27:12.759686	7.00	0.00	7.00	efectivo
510	2025-10-07 18:31:41.580301	15.00	0.00	15.00	efectivo
511	2025-10-07 18:31:48.292861	66.00	0.00	66.00	efectivo
512	2025-10-07 18:34:01.850006	10.00	0.00	10.00	efectivo
513	2025-10-07 19:05:31.734703	14.00	0.00	14.00	efectivo
514	2025-10-07 19:05:40.149364	85.00	0.00	85.00	efectivo
515	2025-10-07 19:05:53.828338	1.00	0.00	1.00	efectivo
516	2025-10-07 19:11:07.800734	13.00	0.00	13.00	efectivo
517	2025-10-07 19:20:54.148272	30.50	0.00	30.50	efectivo
518	2025-10-07 19:23:30.23349	37.00	0.00	37.00	efectivo
519	2025-10-07 19:26:39.209286	3.50	0.00	3.50	efectivo
520	2025-10-07 19:39:13.788723	15.00	0.00	15.00	efectivo
521	2025-10-07 19:44:54.394097	83.00	0.00	83.00	efectivo
522	2025-10-07 20:00:25.733532	70.00	0.00	70.00	efectivo
523	2025-10-07 20:00:29.420932	4.00	0.00	4.00	efectivo
524	2025-10-07 20:17:54.1311	8.00	0.00	8.00	efectivo
525	2025-10-08 14:30:15.328764	17.00	0.00	17.00	efectivo
526	2025-10-08 15:47:25.890076	50.00	0.00	50.00	efectivo
527	2025-10-08 15:52:45.836527	20.00	0.00	20.00	efectivo
528	2025-10-08 15:59:13.726808	27.00	0.00	27.00	efectivo
529	2025-10-08 15:59:19.344591	2.00	0.00	2.00	efectivo
530	2025-10-08 16:01:54.351468	20.00	0.00	20.00	efectivo
531	2025-10-08 16:15:03.797447	4.50	0.00	4.50	efectivo
532	2025-10-08 16:39:26.451372	19.00	0.00	19.00	efectivo
533	2025-10-08 16:40:40.788008	20.00	0.00	20.00	efectivo
534	2025-10-08 16:48:37.36486	42.50	0.00	42.50	efectivo
535	2025-10-08 16:57:42.172651	70.00	0.00	70.00	efectivo
536	2025-10-08 16:59:25.138501	35.00	0.00	35.00	efectivo
537	2025-10-08 17:16:24.096537	27.00	0.00	27.00	efectivo
538	2025-10-08 17:26:55.75592	53.00	0.00	53.00	efectivo
539	2025-10-08 17:37:27.017043	15.00	0.00	15.00	efectivo
540	2025-10-08 17:37:37.619822	10.00	0.00	10.00	efectivo
541	2025-10-08 17:51:07.218391	30.00	0.00	30.00	efectivo
542	2025-10-08 17:51:50.659091	45.00	0.00	45.00	efectivo
543	2025-10-08 17:58:10.247155	40.00	0.00	40.00	efectivo
544	2025-10-08 18:00:04.636682	35.00	0.00	35.00	efectivo
545	2025-10-08 18:01:21.435072	15.00	0.00	15.00	efectivo
546	2025-10-08 18:04:51.762184	10.00	0.00	10.00	efectivo
547	2025-10-08 18:06:38.661136	5.00	0.00	5.00	efectivo
548	2025-10-08 18:09:26.117935	71.00	0.00	71.00	efectivo
549	2025-10-08 18:10:06.19123	9.00	0.00	9.00	efectivo
550	2025-10-08 18:13:35.554192	48.00	0.00	48.00	efectivo
551	2025-10-08 18:32:59.056379	18.00	0.00	18.00	efectivo
552	2025-10-08 18:48:17.843843	35.00	0.00	35.00	efectivo
553	2025-10-08 19:05:20.297671	22.00	0.00	22.00	efectivo
554	2025-10-08 19:05:26.897546	18.00	0.00	18.00	efectivo
555	2025-10-08 19:05:31.855538	10.00	0.00	10.00	efectivo
556	2025-10-08 19:09:33.558536	75.00	0.00	75.00	efectivo
557	2025-10-08 19:15:03.006831	90.00	0.00	90.00	efectivo
558	2025-10-08 19:18:19.503531	10.00	0.00	10.00	efectivo
559	2025-10-08 19:37:40.324411	30.00	0.00	30.00	efectivo
560	2025-10-08 19:44:55.789591	47.00	0.00	47.00	efectivo
561	2025-10-08 20:10:10.751024	92.00	0.00	92.00	efectivo
562	2025-10-08 20:23:32.337986	114.00	0.00	114.00	efectivo
563	2025-10-08 20:25:18.699564	80.00	0.00	80.00	efectivo
564	2025-10-08 20:54:00.011349	62.50	0.00	62.50	efectivo
565	2025-10-09 12:27:12.867479	151.00	0.00	151.00	efectivo
566	2025-10-09 13:23:22.430183	17.00	0.00	17.00	efectivo
567	2025-10-09 13:27:03.086582	18.00	0.00	18.00	efectivo
568	2025-10-09 13:30:16.348526	20.00	0.00	20.00	efectivo
569	2025-10-09 13:40:01.886087	16.00	0.00	16.00	efectivo
570	2025-10-09 14:34:39.001362	6.00	0.00	6.00	efectivo
571	2025-10-09 14:37:13.224603	28.00	0.00	28.00	efectivo
572	2025-10-09 15:28:36.634652	25.00	0.00	25.00	efectivo
573	2025-10-09 16:08:02.273628	44.00	0.00	44.00	efectivo
574	2025-10-09 16:17:03.765919	62.00	0.00	62.00	efectivo
575	2025-10-09 16:35:21.840463	41.00	0.00	41.00	efectivo
576	2025-10-09 16:43:19.892821	47.00	0.00	47.00	efectivo
577	2025-10-09 16:46:06.473254	20.00	0.00	20.00	efectivo
578	2025-10-09 16:46:31.05985	3.00	0.00	3.00	efectivo
579	2025-10-09 17:36:05.998677	13.50	0.00	13.50	efectivo
580	2025-10-09 17:36:28.732817	14.00	0.00	14.00	efectivo
581	2025-10-09 17:56:54.021525	40.00	0.00	40.00	efectivo
582	2025-10-09 17:57:48.087422	125.00	0.00	125.00	efectivo
583	2025-10-09 17:58:22.588533	34.00	0.00	34.00	efectivo
584	2025-10-09 18:09:39.741294	13.00	0.00	13.00	efectivo
585	2025-10-09 18:14:26.150825	12.50	0.00	12.50	efectivo
586	2025-10-09 18:19:41.626781	47.00	0.00	47.00	efectivo
587	2025-10-09 18:20:01.190993	7.00	0.00	7.00	efectivo
588	2025-10-09 18:25:19.675065	120.00	0.00	120.00	efectivo
589	2025-10-09 18:30:11.098909	28.00	0.00	28.00	efectivo
590	2025-10-09 18:34:17.14115	6.00	0.00	6.00	efectivo
591	2025-10-09 18:39:33.845481	83.00	0.00	83.00	efectivo
592	2025-10-09 18:44:31.744171	84.00	0.00	84.00	efectivo
593	2025-10-09 18:46:39.945618	5.50	0.00	5.50	efectivo
594	2025-10-09 19:25:50.188341	57.00	0.00	57.00	efectivo
595	2025-10-09 19:27:12.795485	3.00	0.00	3.00	efectivo
596	2025-10-09 19:27:46.774194	4.50	0.00	4.50	efectivo
597	2025-10-09 19:29:06.432424	4.00	0.00	4.00	efectivo
598	2025-10-09 19:41:44.512108	50.00	0.00	50.00	efectivo
599	2025-10-09 19:47:09.210229	271.00	0.00	271.00	efectivo
600	2025-10-09 20:06:17.736448	45.00	0.00	45.00	efectivo
601	2025-10-09 20:06:41.230314	210.00	0.00	210.00	efectivo
602	2025-10-09 20:07:21.840514	37.00	0.00	37.00	efectivo
603	2025-10-09 20:13:18.431838	57.00	0.00	57.00	efectivo
604	2025-10-09 20:42:59.645929	76.00	0.00	76.00	efectivo
605	2025-10-09 20:44:40.075003	50.00	0.00	50.00	efectivo
606	2025-10-10 12:06:11.447036	10.00	0.00	10.00	efectivo
607	2025-10-10 12:06:25.627593	10.00	0.00	10.00	efectivo
608	2025-10-10 12:06:34.897872	6.00	0.00	6.00	efectivo
609	2025-10-10 12:06:53.887089	20.00	0.00	20.00	efectivo
610	2025-10-10 12:18:47.47097	10.00	0.00	10.00	efectivo
611	2025-10-10 12:39:42.48822	45.00	0.00	45.00	efectivo
612	2025-10-10 13:46:23.25082	32.00	0.00	32.00	efectivo
613	2025-10-10 13:46:31.36579	8.00	0.00	8.00	efectivo
614	2025-10-10 13:57:28.860415	33.50	0.00	33.50	efectivo
615	2025-10-10 14:12:36.851973	130.00	0.00	130.00	efectivo
616	2025-10-13 13:54:11.698401	28.00	0.00	28.00	efectivo
617	2025-10-13 13:54:24.99129	18.00	0.00	18.00	efectivo
618	2025-10-13 13:54:33.332776	15.00	0.00	15.00	efectivo
619	2025-10-13 13:54:48.041562	12.00	0.00	12.00	efectivo
620	2025-10-13 13:56:27.018162	46.00	0.00	46.00	efectivo
621	2025-10-13 14:29:37.099373	48.00	0.00	48.00	efectivo
622	2025-10-13 15:42:13.656142	80.00	0.00	80.00	efectivo
623	2025-10-13 15:47:07.034388	25.00	0.00	25.00	efectivo
624	2025-10-13 16:21:02.696084	109.00	0.00	109.00	efectivo
625	2025-10-13 16:34:25.551115	99.50	0.00	99.50	efectivo
626	2025-10-13 16:48:04.331463	2.00	0.00	2.00	efectivo
627	2025-10-13 17:13:39.862509	38.00	0.00	38.00	efectivo
628	2025-10-13 17:26:48.613599	25.00	0.00	25.00	efectivo
629	2025-10-13 17:50:35.151447	40.00	0.00	40.00	efectivo
630	2025-10-13 18:41:01.272327	15.00	0.00	15.00	efectivo
631	2025-10-13 18:45:32.527108	42.00	0.00	42.00	efectivo
632	2025-10-13 18:53:55.171239	60.00	0.00	60.00	efectivo
633	2025-10-13 19:01:01.503293	80.00	0.00	80.00	efectivo
634	2025-10-13 19:09:17.757094	185.00	0.00	185.00	efectivo
635	2025-10-13 19:11:34.525685	42.00	0.00	42.00	efectivo
636	2025-10-13 19:18:27.745612	17.50	0.00	17.50	efectivo
637	2025-10-13 19:18:46.566015	24.50	0.00	24.50	efectivo
638	2025-10-13 19:23:37.456718	151.00	0.00	151.00	efectivo
639	2025-10-13 19:27:18.366145	16.00	0.00	16.00	efectivo
640	2025-10-13 20:01:09.336774	70.00	0.00	70.00	efectivo
641	2025-10-13 20:51:00.010258	45.00	0.00	45.00	efectivo
642	2025-10-13 20:58:46.164887	45.00	0.00	45.00	efectivo
643	2025-10-14 11:59:38.491923	33.00	0.00	33.00	efectivo
644	2025-10-14 12:19:13.210727	63.00	0.00	63.00	efectivo
645	2025-10-14 12:20:09.617998	29.00	0.00	29.00	efectivo
646	2025-10-14 12:20:26.892236	24.00	0.00	24.00	efectivo
647	2025-10-14 12:20:55.733452	39.00	0.00	39.00	efectivo
648	2025-10-14 13:00:55.16391	53.00	0.00	53.00	efectivo
649	2025-10-14 13:10:00.224139	60.00	0.00	60.00	efectivo
650	2025-10-14 16:19:37.491959	60.00	0.00	60.00	efectivo
651	2025-10-14 16:23:43.926247	65.00	0.00	65.00	efectivo
652	2025-10-14 16:29:44.636545	63.00	0.00	63.00	efectivo
653	2025-10-14 16:49:55.422731	10.00	0.00	10.00	efectivo
654	2025-10-14 16:57:23.259531	25.00	0.00	25.00	efectivo
655	2025-10-14 17:08:31.27383	16.00	0.00	16.00	efectivo
656	2025-10-14 17:21:47.769799	105.00	0.00	105.00	efectivo
657	2025-10-14 17:26:31.662192	12.00	0.00	12.00	efectivo
658	2025-10-14 17:28:33.24317	18.00	0.00	18.00	efectivo
659	2025-10-14 17:40:19.055127	40.00	0.00	40.00	efectivo
660	2025-10-14 17:44:08.949743	20.00	0.00	20.00	efectivo
661	2025-10-14 18:04:01.668605	21.00	0.00	21.00	efectivo
662	2025-10-14 18:44:58.849743	38.00	0.00	38.00	efectivo
663	2025-10-14 18:46:02.245291	5.00	0.00	5.00	efectivo
664	2025-10-14 18:47:02.727166	15.00	0.00	15.00	efectivo
665	2025-10-14 18:48:12.17353	40.00	0.00	40.00	efectivo
666	2025-10-14 18:56:58.572112	37.00	0.00	37.00	efectivo
667	2025-10-14 19:07:22.772771	174.00	0.00	174.00	efectivo
668	2025-10-14 19:07:38.729665	75.00	0.00	75.00	efectivo
669	2025-10-14 19:26:00.97799	20.50	0.00	20.50	efectivo
670	2025-10-14 19:38:22.827063	46.00	0.00	46.00	efectivo
671	2025-10-14 19:45:00.100289	30.00	0.00	30.00	efectivo
672	2025-10-14 19:50:20.006324	41.00	0.00	41.00	efectivo
673	2025-10-14 19:56:39.581304	35.00	0.00	35.00	efectivo
674	2025-10-14 20:03:04.425159	12.00	0.00	12.00	efectivo
675	2025-10-14 20:12:50.643722	6.00	0.00	6.00	efectivo
676	2025-10-14 20:35:26.861296	121.00	0.00	121.00	efectivo
677	2025-10-14 20:43:16.394131	40.00	0.00	40.00	efectivo
678	2025-10-14 20:45:45.623236	19.00	0.00	19.00	efectivo
679	2025-10-14 20:57:39.392773	40.00	0.00	40.00	efectivo
680	2025-10-14 20:58:27.375318	35.00	0.00	35.00	efectivo
681	2025-10-15 13:03:17.014365	7.50	0.00	7.50	efectivo
682	2025-10-15 13:53:24.145324	73.00	0.00	73.00	efectivo
683	2025-10-15 15:09:54.761281	80.00	0.00	80.00	efectivo
684	2025-10-15 16:44:58.158563	30.00	0.00	30.00	efectivo
685	2025-10-15 16:45:20.812155	6.00	0.00	6.00	efectivo
686	2025-10-15 17:40:02.128403	43.50	0.00	43.50	efectivo
687	2025-10-15 17:40:33.464076	61.00	0.00	61.00	efectivo
688	2025-10-15 17:47:23.583413	98.00	0.00	98.00	efectivo
689	2025-10-15 18:06:48.399908	12.00	0.00	12.00	efectivo
690	2025-10-15 18:19:41.814906	47.00	0.00	47.00	efectivo
691	2025-10-15 18:36:13.404962	35.00	0.00	35.00	efectivo
692	2025-10-15 18:42:35.225	68.00	0.00	68.00	efectivo
693	2025-10-15 18:45:07.078044	25.00	0.00	25.00	efectivo
694	2025-10-15 18:51:07.016214	10.00	0.00	10.00	efectivo
695	2025-10-15 18:57:13.265526	79.00	0.00	79.00	efectivo
696	2025-10-15 18:57:19.693039	6.00	0.00	6.00	efectivo
697	2025-10-15 19:01:37.910984	32.50	0.00	32.50	efectivo
698	2025-10-15 19:02:57.035804	12.00	0.00	12.00	efectivo
699	2025-10-15 19:05:52.493951	20.00	0.00	20.00	efectivo
700	2025-10-15 19:24:08.77126	4.50	0.00	4.50	efectivo
701	2025-10-15 19:35:31.962143	4.00	0.00	4.00	efectivo
702	2025-10-15 19:39:48.207029	9.00	0.00	9.00	efectivo
703	2025-10-15 19:59:49.880339	250.00	0.00	250.00	efectivo
704	2025-10-15 20:01:14.191952	56.00	0.00	56.00	efectivo
705	2025-10-15 20:03:00.547849	16.00	0.00	16.00	efectivo
706	2025-10-15 20:09:35.074913	74.00	0.00	74.00	efectivo
707	2025-10-15 20:13:06.67523	25.00	0.00	25.00	efectivo
708	2025-10-15 20:15:08.96608	10.00	0.00	10.00	efectivo
709	2025-10-15 20:17:52.056204	12.50	0.00	12.50	efectivo
710	2025-10-15 20:23:06.910779	36.50	0.00	36.50	efectivo
711	2025-10-15 20:33:13.304034	17.00	0.00	17.00	efectivo
712	2025-10-15 20:42:04.211637	22.00	0.00	22.00	efectivo
713	2025-10-15 20:55:18.819605	10.00	0.00	10.00	efectivo
714	2025-10-15 20:58:00.351589	10.00	0.00	10.00	efectivo
715	2025-10-16 14:20:38.447613	60.00	0.00	60.00	efectivo
716	2025-10-16 14:20:57.603944	16.00	0.00	16.00	efectivo
717	2025-10-16 14:21:23.779703	81.00	0.00	81.00	efectivo
718	2025-10-16 17:13:15.869478	55.00	0.00	55.00	efectivo
719	2025-10-16 17:14:19.729879	2.00	0.00	2.00	efectivo
720	2025-10-16 17:35:47.270112	86.00	0.00	86.00	efectivo
721	2025-10-16 17:36:01.337387	60.00	0.00	60.00	efectivo
722	2025-10-16 18:11:41.217392	91.00	0.00	91.00	efectivo
723	2025-10-16 18:17:21.343829	50.00	0.00	50.00	efectivo
724	2025-10-16 18:24:43.152174	10.00	0.00	10.00	efectivo
725	2025-10-16 19:02:04.886226	26.00	0.00	26.00	efectivo
726	2025-10-16 19:06:27.457483	161.00	0.00	161.00	efectivo
727	2025-10-16 19:09:46.619315	18.00	0.00	18.00	efectivo
728	2025-10-16 19:11:07.330663	11.00	0.00	11.00	efectivo
729	2025-10-16 19:13:41.572088	25.00	0.00	25.00	efectivo
730	2025-10-16 19:16:28.676261	45.00	0.00	45.00	efectivo
731	2025-10-16 19:27:54.36812	20.00	0.00	20.00	efectivo
732	2025-10-16 19:28:15.61513	17.00	0.00	17.00	efectivo
733	2025-10-16 19:44:45.340143	216.00	0.00	216.00	efectivo
734	2025-10-16 19:56:07.765645	35.00	0.00	35.00	efectivo
735	2025-10-16 20:01:38.782739	70.00	0.00	70.00	efectivo
736	2025-10-16 20:03:54.664335	12.50	0.00	12.50	efectivo
737	2025-10-16 20:12:32.640732	4.00	0.00	4.00	efectivo
738	2025-10-16 20:18:38.465717	5.00	0.00	5.00	efectivo
739	2025-10-16 20:32:04.968148	26.00	0.00	26.00	efectivo
740	2025-10-16 20:43:07.841918	25.00	0.00	25.00	efectivo
741	2025-10-16 21:12:04.599393	30.00	0.00	30.00	efectivo
742	2025-10-17 16:32:32.863024	11.00	0.00	11.00	efectivo
743	2025-10-17 16:39:24.072261	22.00	0.00	22.00	efectivo
744	2025-10-17 17:08:45.238183	45.00	0.00	45.00	efectivo
745	2025-10-17 17:13:44.288107	77.50	0.00	77.50	efectivo
746	2025-10-17 17:16:38.023822	20.00	0.00	20.00	efectivo
747	2025-10-17 17:18:23.946952	48.00	0.00	48.00	efectivo
748	2025-10-17 17:23:56.170144	10.00	0.00	10.00	efectivo
749	2025-10-17 17:32:27.421857	3.00	0.00	3.00	efectivo
750	2025-10-17 17:47:43.756901	2.00	0.00	2.00	efectivo
751	2025-10-17 17:51:29.48119	7.00	0.00	7.00	efectivo
752	2025-10-17 17:54:13.424686	15.00	0.00	15.00	efectivo
753	2025-10-17 17:54:25.461143	4.00	0.00	4.00	efectivo
754	2025-10-17 18:12:56.43563	26.00	0.00	26.00	efectivo
755	2025-10-17 18:33:31.772517	15.00	0.00	15.00	efectivo
756	2025-10-17 18:46:49.449206	129.00	0.00	129.00	efectivo
757	2025-10-17 18:58:19.031368	3.00	0.00	3.00	efectivo
758	2025-10-17 19:24:13.946787	12.00	0.00	12.00	efectivo
759	2025-10-17 19:30:19.887298	12.50	0.00	12.50	efectivo
760	2025-10-17 20:09:22.569686	8.00	0.00	8.00	efectivo
761	2025-10-17 20:29:56.174715	73.00	0.00	73.00	efectivo
762	2025-10-18 13:24:49.600365	75.00	0.00	75.00	efectivo
763	2025-10-18 13:25:00.040829	18.00	0.00	18.00	efectivo
764	2025-10-18 13:25:16.119313	22.50	0.00	22.50	efectivo
765	2025-10-18 13:37:07.45747	12.00	0.00	12.00	efectivo
766	2025-10-18 13:37:16.824587	20.00	0.00	20.00	efectivo
767	2025-10-18 13:56:47.785695	55.00	0.00	55.00	efectivo
768	2025-10-18 14:03:19.124886	32.00	0.00	32.00	efectivo
769	2025-10-18 14:13:48.996639	83.00	0.00	83.00	efectivo
770	2025-10-18 16:03:03.399526	9.50	0.00	9.50	efectivo
771	2025-10-18 16:42:25.741676	30.00	0.00	30.00	efectivo
772	2025-10-18 16:47:45.67607	24.00	0.00	24.00	efectivo
773	2025-10-18 16:48:39.257331	64.50	0.00	64.50	efectivo
774	2025-10-18 16:55:21.801903	104.00	0.00	104.00	efectivo
775	2025-10-18 17:16:58.73406	22.00	0.00	22.00	efectivo
776	2025-10-18 17:19:35.469558	245.00	0.00	245.00	efectivo
777	2025-10-20 14:54:24.280237	184.50	0.00	184.50	efectivo
778	2025-10-20 14:54:37.085379	7.00	0.00	7.00	efectivo
779	2025-10-20 14:58:17.838049	50.00	0.00	50.00	efectivo
780	2025-10-20 15:25:46.774091	39.00	0.00	39.00	efectivo
781	2025-10-20 15:40:53.765505	27.00	0.00	27.00	efectivo
782	2025-10-20 16:05:00.390126	119.00	0.00	119.00	efectivo
783	2025-10-20 16:06:38.641866	75.00	0.00	75.00	efectivo
784	2025-10-20 16:24:32.477927	17.00	0.00	17.00	efectivo
785	2025-10-20 16:44:42.863465	81.50	0.00	81.50	efectivo
786	2025-10-20 16:46:10.2949	7.00	0.00	7.00	efectivo
787	2025-10-20 17:38:23.463428	65.00	0.00	65.00	efectivo
788	2025-10-20 17:53:48.682784	8.00	0.00	8.00	efectivo
789	2025-10-20 17:54:21.070102	38.00	0.00	38.00	efectivo
790	2025-10-20 18:02:37.131172	15.00	0.00	15.00	efectivo
791	2025-10-20 18:04:49.609605	30.00	0.00	30.00	efectivo
792	2025-10-20 18:15:10.313784	27.00	0.00	27.00	efectivo
793	2025-10-20 18:19:03.743257	85.00	0.00	85.00	efectivo
794	2025-10-20 18:21:28.886878	135.00	0.00	135.00	efectivo
795	2025-10-20 18:34:54.537928	74.00	0.00	74.00	efectivo
796	2025-10-20 18:35:36.816938	20.00	0.00	20.00	efectivo
797	2025-10-20 18:44:45.531811	20.00	0.00	20.00	efectivo
798	2025-10-20 18:51:17.618516	55.00	0.00	55.00	efectivo
799	2025-10-20 18:54:40.618141	21.00	0.00	21.00	efectivo
800	2025-10-20 18:56:12.943327	30.00	0.00	30.00	efectivo
801	2025-10-20 19:07:43.751219	25.00	0.00	25.00	efectivo
802	2025-10-20 19:08:16.510644	13.50	0.00	13.50	efectivo
803	2025-10-20 19:13:35.619064	44.00	0.00	44.00	efectivo
804	2025-10-20 19:18:45.191326	18.00	0.00	18.00	efectivo
805	2025-10-20 19:23:10.982698	60.00	0.00	60.00	efectivo
806	2025-10-20 19:28:39.183422	45.00	0.00	45.00	efectivo
807	2025-10-20 19:28:56.076523	15.00	0.00	15.00	efectivo
808	2025-10-20 19:33:23.426347	50.00	0.00	50.00	efectivo
809	2025-10-20 19:34:58.780628	28.00	0.00	28.00	efectivo
810	2025-10-20 19:42:09.038032	40.00	0.00	40.00	efectivo
811	2025-10-20 19:42:22.300321	5.00	0.00	5.00	efectivo
812	2025-10-20 19:43:15.450771	97.00	0.00	97.00	efectivo
813	2025-10-20 19:50:09.877586	7.00	0.00	7.00	efectivo
814	2025-10-20 19:52:14.27991	90.00	0.00	90.00	efectivo
815	2025-10-20 20:05:15.415081	26.00	0.00	26.00	efectivo
816	2025-10-20 20:18:38.888382	48.00	0.00	48.00	efectivo
817	2025-10-20 20:19:40.037041	115.00	0.00	115.00	efectivo
818	2025-10-20 20:38:03.08854	21.00	0.00	21.00	efectivo
819	2025-10-20 20:49:11.537304	61.00	0.00	61.00	efectivo
820	2025-10-20 20:50:20.006448	8.00	0.00	8.00	efectivo
821	2025-10-20 21:28:32.242764	267.00	0.00	267.00	efectivo
822	2025-10-20 21:30:07.883486	40.00	0.00	40.00	efectivo
823	2025-10-21 12:09:43.231797	57.00	0.00	57.00	efectivo
824	2025-10-21 12:20:36.131917	12.00	0.00	12.00	efectivo
825	2025-10-21 12:27:14.467279	70.50	0.00	70.50	efectivo
826	2025-10-21 12:36:08.107417	30.00	0.00	30.00	efectivo
827	2025-10-21 12:38:53.196187	32.50	0.00	32.50	efectivo
828	2025-10-21 14:03:50.391982	10.00	0.00	10.00	efectivo
829	2025-10-21 14:16:41.786782	73.00	0.00	73.00	efectivo
830	2025-10-21 14:27:57.605615	77.00	0.00	77.00	efectivo
831	2025-10-21 14:50:34.498818	11.50	0.00	11.50	efectivo
832	2025-10-21 16:11:09.539394	113.00	0.00	113.00	efectivo
833	2025-10-21 16:12:47.653751	32.00	0.00	32.00	efectivo
834	2025-10-21 16:17:16.364433	51.00	0.00	51.00	efectivo
835	2025-10-21 17:18:26.054894	13.50	0.00	13.50	efectivo
836	2025-10-21 18:48:36.502109	528.00	0.00	528.00	efectivo
837	2025-10-21 18:54:17.635338	36.00	0.00	36.00	efectivo
838	2025-10-21 18:56:05.166032	40.00	0.00	40.00	efectivo
839	2025-10-21 19:06:15.469983	14.50	0.00	14.50	efectivo
840	2025-10-21 19:08:47.983509	4.00	0.00	4.00	efectivo
841	2025-10-21 19:09:31.743316	55.00	0.00	55.00	efectivo
842	2025-10-21 19:35:29.560661	80.00	0.00	80.00	efectivo
843	2025-10-21 19:44:47.416959	39.00	0.00	39.00	efectivo
844	2025-10-21 19:48:08.862426	35.00	0.00	35.00	efectivo
845	2025-10-21 19:49:30.70918	11.00	0.00	11.00	efectivo
846	2025-10-21 20:19:24.223892	40.00	0.00	40.00	efectivo
847	2025-10-21 20:19:39.516022	13.00	0.00	13.00	efectivo
848	2025-10-21 20:21:42.348893	15.00	0.00	15.00	efectivo
849	2025-10-21 20:22:47.571918	21.00	0.00	21.00	efectivo
850	2025-10-21 20:40:04.344756	95.00	0.00	95.00	efectivo
851	2025-10-21 20:45:08.686927	49.50	0.00	49.50	efectivo
852	2025-10-21 20:54:33.621321	15.00	0.00	15.00	efectivo
853	2025-10-21 21:02:43.606638	80.00	0.00	80.00	efectivo
854	2025-10-21 21:05:33.644405	31.00	0.00	31.00	efectivo
855	2025-10-22 16:01:53.640995	32.00	0.00	32.00	efectivo
856	2025-10-22 16:03:46.21643	64.00	0.00	64.00	efectivo
857	2025-10-22 16:11:26.520544	28.00	0.00	28.00	efectivo
858	2025-10-22 17:06:10.002829	4.00	0.00	4.00	efectivo
859	2025-10-22 17:10:13.639235	18.50	0.00	18.50	efectivo
860	2025-10-22 17:10:38.564397	13.00	0.00	13.00	efectivo
861	2025-10-22 17:39:22.145135	14.00	0.00	14.00	efectivo
862	2025-10-22 17:45:22.412194	73.00	0.00	73.00	efectivo
863	2025-10-22 17:51:46.59786	13.50	0.00	13.50	efectivo
864	2025-10-22 18:03:16.853176	25.00	0.00	25.00	efectivo
865	2025-10-22 18:07:21.16164	20.00	0.00	20.00	efectivo
866	2025-10-22 18:15:46.407517	8.50	0.00	8.50	efectivo
867	2025-10-22 18:37:13.048753	35.00	0.00	35.00	efectivo
868	2025-10-22 18:40:50.886457	35.00	0.00	35.00	efectivo
869	2025-10-22 18:41:14.117855	15.00	0.00	15.00	efectivo
870	2025-10-22 18:44:07.737616	10.00	0.00	10.00	efectivo
871	2025-10-22 18:51:51.947859	8.00	0.00	8.00	efectivo
872	2025-10-22 18:56:37.184232	10.50	0.00	10.50	efectivo
873	2025-10-22 18:57:46.176287	65.00	0.00	65.00	efectivo
874	2025-10-22 19:03:55.658352	45.00	0.00	45.00	efectivo
875	2025-10-22 19:11:54.798906	30.00	0.00	30.00	efectivo
876	2025-10-22 19:20:35.561749	70.00	0.00	70.00	efectivo
877	2025-10-22 19:26:10.540065	75.00	0.00	75.00	efectivo
878	2025-10-22 19:29:59.138714	50.00	0.00	50.00	efectivo
879	2025-10-22 19:38:20.059575	71.00	0.00	71.00	efectivo
880	2025-10-22 19:41:46.663459	118.00	0.00	118.00	efectivo
881	2025-10-22 19:43:34.530247	12.00	0.00	12.00	efectivo
882	2025-10-22 19:52:53.074663	7.00	0.00	7.00	efectivo
883	2025-10-22 19:55:35.574616	61.00	0.00	61.00	efectivo
884	2025-10-22 20:01:20.271041	35.00	0.00	35.00	efectivo
885	2025-10-22 20:10:10.876133	31.00	0.00	31.00	efectivo
886	2025-10-22 20:14:00.157857	7.00	0.00	7.00	efectivo
887	2025-10-22 20:18:03.750253	40.00	0.00	40.00	efectivo
888	2025-10-22 20:18:22.347373	20.00	0.00	20.00	efectivo
889	2025-10-22 20:24:32.632165	27.00	0.00	27.00	efectivo
890	2025-10-22 20:26:44.888374	50.00	0.00	50.00	efectivo
891	2025-10-22 20:27:39.748026	10.00	0.00	10.00	efectivo
892	2025-10-22 20:33:20.28907	35.00	0.00	35.00	efectivo
893	2025-10-22 20:39:33.950898	4.00	0.00	4.00	efectivo
894	2025-10-22 20:50:35.680631	25.00	0.00	25.00	efectivo
895	2025-10-22 20:56:06.30102	57.00	0.00	57.00	efectivo
896	2025-10-23 15:56:20.803717	2.00	0.00	2.00	efectivo
897	2025-10-23 16:26:36.50146	125.00	0.00	125.00	efectivo
898	2025-10-23 16:47:31.215244	8.00	0.00	8.00	efectivo
899	2025-10-23 17:09:25.515376	37.50	0.00	37.50	efectivo
900	2025-10-23 17:13:18.752276	24.00	0.00	24.00	efectivo
901	2025-10-23 17:13:25.812287	8.00	0.00	8.00	efectivo
902	2025-10-23 17:50:47.807454	24.00	0.00	24.00	efectivo
903	2025-10-23 17:53:17.869017	72.00	0.00	72.00	efectivo
904	2025-10-23 18:03:07.440882	97.00	0.00	97.00	efectivo
905	2025-10-23 18:09:43.560547	24.00	0.00	24.00	efectivo
906	2025-10-23 18:19:02.417154	48.00	0.00	48.00	efectivo
907	2025-10-23 18:31:48.954702	12.00	0.00	12.00	efectivo
908	2025-10-23 18:33:27.048097	35.00	0.00	35.00	efectivo
909	2025-10-23 18:34:17.099796	35.00	0.00	35.00	efectivo
910	2025-10-23 18:35:00.068111	22.00	0.00	22.00	efectivo
911	2025-10-23 18:36:30.886652	10.00	0.00	10.00	efectivo
912	2025-10-23 18:41:57.454589	8.00	0.00	8.00	efectivo
913	2025-10-23 18:59:46.937815	58.00	0.00	58.00	efectivo
914	2025-10-23 18:59:52.603906	4.00	0.00	4.00	efectivo
915	2025-10-23 19:02:57.567767	65.00	0.00	65.00	efectivo
916	2025-10-23 19:04:17.865231	11.00	0.00	11.00	efectivo
917	2025-10-23 19:05:22.934647	20.00	0.00	20.00	efectivo
918	2025-10-23 19:05:30.624395	24.00	0.00	24.00	efectivo
919	2025-10-23 19:07:09.077416	20.00	0.00	20.00	efectivo
920	2025-10-23 19:11:49.64421	134.00	0.00	134.00	efectivo
921	2025-10-23 19:13:57.631754	60.00	0.00	60.00	efectivo
922	2025-10-23 19:25:52.389009	30.00	0.00	30.00	efectivo
923	2025-10-23 19:27:24.757452	4.00	0.00	4.00	efectivo
924	2025-10-23 20:01:02.002224	8.00	0.00	8.00	efectivo
925	2025-10-23 20:09:33.801254	35.00	0.00	35.00	efectivo
926	2025-10-23 20:12:10.492005	12.00	0.00	12.00	efectivo
927	2025-10-23 20:47:06.152602	60.00	0.00	60.00	efectivo
928	2025-10-23 21:12:22.643217	38.00	0.00	38.00	efectivo
929	2025-10-24 16:57:19.387709	30.00	0.00	30.00	efectivo
930	2025-10-24 16:58:14.063038	33.00	0.00	33.00	efectivo
931	2025-10-24 17:04:19.647967	30.00	0.00	30.00	efectivo
932	2025-10-24 17:10:09.35427	10.00	0.00	10.00	efectivo
933	2025-10-24 17:13:11.578623	9.00	0.00	9.00	efectivo
934	2025-10-24 17:31:49.388196	50.00	0.00	50.00	efectivo
935	2025-10-24 17:33:40.456806	20.00	0.00	20.00	efectivo
936	2025-10-24 17:36:15.498943	30.00	0.00	30.00	efectivo
937	2025-10-24 17:48:07.213814	15.00	0.00	15.00	efectivo
938	2025-10-24 17:50:45.556781	87.00	0.00	87.00	efectivo
939	2025-10-24 17:59:41.030985	30.00	0.00	30.00	efectivo
940	2025-10-24 18:09:13.184577	25.00	0.00	25.00	efectivo
941	2025-10-24 18:10:14.870866	10.00	0.00	10.00	efectivo
942	2025-10-24 18:16:15.615052	15.00	0.00	15.00	efectivo
943	2025-10-24 18:20:23.152056	59.00	0.00	59.00	efectivo
944	2025-10-24 18:37:05.645709	50.00	0.00	50.00	efectivo
945	2025-10-24 18:40:18.22469	20.00	0.00	20.00	efectivo
946	2025-10-24 18:56:35.045687	30.00	0.00	30.00	efectivo
947	2025-10-24 19:07:42.216955	44.00	0.00	44.00	efectivo
948	2025-10-24 19:16:52.312538	40.00	0.00	40.00	efectivo
949	2025-10-24 19:18:40.126073	32.00	0.00	32.00	efectivo
950	2025-10-24 19:18:50.846906	100.00	0.00	100.00	efectivo
951	2025-10-24 19:25:02.688302	30.00	0.00	30.00	efectivo
952	2025-10-24 19:41:58.646809	45.00	0.00	45.00	efectivo
953	2025-10-24 20:49:06.604531	28.50	0.00	28.50	efectivo
954	2025-10-24 20:49:13.908409	2.00	0.00	2.00	efectivo
955	2025-10-24 20:55:14.159809	20.00	0.00	20.00	efectivo
956	2025-10-27 15:58:02.821841	60.00	0.00	60.00	efectivo
957	2025-10-27 16:10:50.781205	22.00	0.00	22.00	efectivo
958	2025-10-27 16:17:06.954077	31.00	0.00	31.00	efectivo
959	2025-10-27 16:17:24.789253	6.50	0.00	6.50	efectivo
960	2025-10-27 16:18:03.4627	25.00	0.00	25.00	efectivo
961	2025-10-27 16:25:18.21188	10.00	0.00	10.00	efectivo
962	2025-10-27 16:26:28.798924	14.50	0.00	14.50	efectivo
963	2025-10-27 16:36:02.843825	119.50	0.00	119.50	efectivo
964	2025-10-27 16:40:21.493181	65.00	0.00	65.00	efectivo
965	2025-10-27 16:40:59.067028	15.00	0.00	15.00	efectivo
966	2025-10-27 16:48:58.667462	63.00	0.00	63.00	efectivo
967	2025-10-27 16:49:27.783382	27.00	0.00	27.00	efectivo
968	2025-10-27 17:04:05.051207	25.00	0.00	25.00	efectivo
969	2025-10-27 17:07:23.425908	45.00	0.00	45.00	efectivo
970	2025-10-27 17:23:10.248095	21.00	0.00	21.00	efectivo
971	2025-10-27 17:23:20.825737	9.00	0.00	9.00	efectivo
972	2025-10-27 17:29:30.268499	34.50	0.00	34.50	efectivo
973	2025-10-27 17:31:38.67827	24.00	0.00	24.00	efectivo
974	2025-10-27 17:33:31.245809	39.00	0.00	39.00	efectivo
975	2025-10-27 17:38:36.639114	75.50	0.00	75.50	efectivo
976	2025-10-27 17:46:39.841998	132.00	0.00	132.00	efectivo
977	2025-10-27 17:58:18.525463	101.00	0.00	101.00	efectivo
978	2025-10-27 18:21:53.577547	47.00	0.00	47.00	efectivo
979	2025-10-27 18:27:27.794166	21.00	0.00	21.00	efectivo
980	2025-10-27 18:41:19.642063	52.00	0.00	52.00	efectivo
981	2025-10-27 18:42:32.613781	18.00	0.00	18.00	efectivo
982	2025-10-27 18:51:09.345947	97.00	0.00	97.00	efectivo
983	2025-10-27 19:21:31.365217	113.00	0.00	113.00	efectivo
984	2025-10-27 19:27:43.142405	115.00	0.00	115.00	efectivo
985	2025-10-27 19:36:47.745357	39.00	0.00	39.00	efectivo
986	2025-10-27 19:41:44.94637	2.00	0.00	2.00	efectivo
987	2025-10-27 19:47:33.34256	39.00	0.00	39.00	efectivo
988	2025-10-27 19:49:11.313455	35.00	0.00	35.00	efectivo
989	2025-10-27 19:52:14.196535	66.00	0.00	66.00	efectivo
990	2025-10-27 19:58:25.439146	57.00	0.00	57.00	efectivo
991	2025-10-27 20:25:23.611115	60.00	0.00	60.00	efectivo
992	2025-10-27 20:25:56.798767	35.00	0.00	35.00	efectivo
993	2025-10-27 20:30:40.982997	22.00	0.00	22.00	efectivo
994	2025-10-27 20:32:02.190827	28.00	0.00	28.00	efectivo
995	2025-10-27 20:33:30.886885	105.00	0.00	105.00	efectivo
996	2025-10-27 20:48:07.909024	59.00	0.00	59.00	efectivo
997	2025-10-27 21:09:38.180482	380.00	0.00	380.00	efectivo
998	2025-10-27 21:10:16.593981	30.00	0.00	30.00	efectivo
999	2025-10-28 17:38:26.575306	12.00	0.00	12.00	efectivo
1000	2025-10-28 17:38:35.187438	30.00	0.00	30.00	efectivo
1001	2025-10-28 17:38:58.073744	50.00	0.00	50.00	efectivo
1002	2025-10-28 17:41:50.101241	6.00	0.00	6.00	efectivo
1003	2025-10-28 17:57:08.745523	114.00	0.00	114.00	efectivo
1004	2025-10-28 18:00:52.420622	36.00	0.00	36.00	efectivo
1005	2025-10-28 18:01:14.408123	21.00	0.00	21.00	efectivo
1006	2025-10-28 18:01:54.42697	45.00	0.00	45.00	efectivo
1007	2025-10-28 18:18:59.604981	45.00	0.00	45.00	efectivo
1008	2025-10-28 18:26:39.913262	35.00	0.00	35.00	efectivo
1009	2025-10-28 18:29:43.475277	20.00	0.00	20.00	efectivo
1010	2025-10-28 18:33:23.433388	64.00	0.00	64.00	efectivo
1011	2025-10-28 18:40:38.16899	59.00	0.00	59.00	efectivo
1012	2025-10-28 18:42:23.575892	10.00	0.00	10.00	efectivo
1013	2025-10-28 19:00:15.917268	1.50	0.00	1.50	efectivo
1014	2025-10-28 19:01:15.643125	5.00	0.00	5.00	efectivo
1015	2025-10-28 19:02:06.79943	15.00	0.00	15.00	efectivo
1016	2025-10-28 19:04:03.288827	79.50	0.00	79.50	efectivo
1017	2025-10-28 19:06:45.343549	155.00	0.00	155.00	efectivo
1018	2025-10-28 19:07:26.874469	5.00	0.00	5.00	efectivo
1019	2025-10-28 19:19:37.691969	55.50	0.00	55.50	efectivo
1020	2025-10-28 19:22:16.409352	14.00	0.00	14.00	efectivo
1021	2025-10-28 19:28:04.514025	97.00	0.00	97.00	efectivo
1022	2025-10-28 19:28:56.491935	52.00	0.00	52.00	efectivo
1023	2025-10-28 19:34:45.598569	67.50	0.00	67.50	efectivo
1024	2025-10-28 19:37:25.815191	15.00	0.00	15.00	efectivo
1025	2025-10-28 19:41:45.048981	22.00	0.00	22.00	efectivo
1026	2025-10-28 19:44:34.554396	27.00	0.00	27.00	efectivo
1027	2025-10-28 19:58:35.361904	173.00	0.00	173.00	efectivo
1028	2025-10-28 20:04:13.001994	27.00	0.00	27.00	efectivo
1029	2025-10-28 20:29:45.764334	135.00	0.00	135.00	efectivo
1030	2025-10-28 20:29:49.947249	10.00	0.00	10.00	efectivo
1031	2025-10-28 20:31:13.337651	60.00	0.00	60.00	efectivo
1032	2025-10-28 20:46:06.966601	119.50	0.00	119.50	efectivo
1033	2025-10-28 20:49:41.352169	30.00	0.00	30.00	efectivo
1034	2025-10-28 20:59:50.610547	122.00	0.00	122.00	efectivo
1035	2025-10-28 21:00:02.45996	12.50	0.00	12.50	efectivo
1036	2025-10-29 16:06:47.285985	123.00	0.00	123.00	efectivo
1037	2025-10-29 17:09:42.560678	30.50	0.00	30.50	efectivo
1038	2025-10-29 17:20:50.082583	95.00	0.00	95.00	efectivo
1039	2025-10-29 17:23:10.73779	5.00	0.00	5.00	efectivo
1040	2025-10-29 17:36:21.719674	100.00	0.00	100.00	efectivo
1041	2025-10-29 17:37:55.326905	30.00	0.00	30.00	efectivo
1042	2025-10-29 17:39:01.941335	10.00	0.00	10.00	efectivo
1043	2025-10-29 17:47:45.048647	169.50	0.00	169.50	efectivo
1044	2025-10-29 17:49:28.343264	40.00	0.00	40.00	efectivo
1045	2025-10-29 17:58:45.036899	15.00	0.00	15.00	efectivo
1046	2025-10-29 18:01:33.259061	7.00	0.00	7.00	efectivo
1047	2025-10-29 18:05:57.087285	15.00	0.00	15.00	efectivo
1048	2025-10-29 18:20:27.546051	135.00	0.00	135.00	efectivo
1049	2025-10-29 18:24:05.446001	10.00	0.00	10.00	efectivo
1050	2025-10-29 18:33:57.355756	52.00	0.00	52.00	efectivo
1051	2025-10-29 18:36:30.073226	40.50	0.00	40.50	efectivo
1052	2025-10-29 18:41:01.080436	49.00	0.00	49.00	efectivo
1053	2025-10-29 18:48:58.431299	13.00	0.00	13.00	efectivo
1054	2025-10-29 19:16:10.970834	42.00	0.00	42.00	efectivo
1055	2025-10-29 19:16:26.707776	6.00	0.00	6.00	efectivo
1056	2025-10-29 19:16:36.081886	10.00	0.00	10.00	efectivo
1057	2025-10-29 19:24:04.697381	69.00	0.00	69.00	efectivo
1058	2025-10-29 19:24:06.377223	15.00	0.00	15.00	efectivo
1059	2025-10-29 19:26:30.324883	10.00	0.00	10.00	efectivo
1060	2025-10-29 19:38:43.934109	7.00	0.00	7.00	efectivo
1061	2025-10-29 19:39:34.331096	57.00	0.00	57.00	efectivo
1062	2025-10-29 20:03:57.304856	144.00	0.00	144.00	efectivo
1063	2025-10-30 15:39:19.563473	15.00	0.00	15.00	efectivo
1064	2025-10-30 15:40:13.021387	20.00	0.00	20.00	efectivo
1065	2025-10-30 15:41:49.478497	30.00	0.00	30.00	efectivo
1066	2025-10-30 16:14:38.558038	12.00	0.00	12.00	efectivo
1067	2025-10-30 16:29:17.666363	30.00	0.00	30.00	efectivo
1068	2025-10-30 16:30:56.309015	52.50	0.00	52.50	efectivo
1069	2025-10-30 16:39:40.009493	45.00	0.00	45.00	efectivo
1070	2025-10-30 16:49:38.509746	30.50	0.00	30.50	efectivo
1071	2025-10-30 17:05:19.806933	195.00	0.00	195.00	efectivo
1072	2025-10-30 17:29:32.287591	7.00	0.00	7.00	efectivo
1073	2025-10-30 18:20:08.930381	68.00	0.00	68.00	efectivo
1074	2025-10-30 18:21:51.908245	110.00	0.00	110.00	efectivo
1075	2025-10-30 18:48:53.826094	46.50	0.00	46.50	efectivo
1076	2025-10-30 19:12:29.109421	15.00	0.00	15.00	efectivo
1077	2025-10-30 19:24:44.878759	55.00	0.00	55.00	efectivo
1078	2025-10-30 19:25:22.681658	25.00	0.00	25.00	efectivo
1079	2025-10-30 19:27:19.608621	7.00	0.00	7.00	efectivo
1080	2025-10-30 19:35:10.251366	30.00	0.00	30.00	efectivo
1081	2025-10-30 19:57:11.153023	6.00	0.00	6.00	efectivo
1082	2025-10-30 20:04:20.717822	60.00	0.00	60.00	efectivo
1083	2025-10-30 20:32:13.05564	80.00	0.00	80.00	efectivo
1084	2025-10-30 20:48:58.495006	32.50	0.00	32.50	efectivo
1085	2025-10-30 20:49:54.4054	20.00	0.00	20.00	efectivo
1117	2025-10-31 16:05:13.764507	72.50	0.00	72.50	efectivo
1118	2025-10-31 16:08:42.735238	54.00	0.00	54.00	efectivo
1119	2025-10-31 16:19:50.229831	50.00	0.00	50.00	efectivo
1120	2025-10-31 16:31:36.048975	69.50	0.00	69.50	efectivo
1121	2025-10-31 16:40:39.454319	12.00	0.00	12.00	efectivo
1122	2025-10-31 16:56:24.069422	44.50	0.00	44.50	efectivo
1123	2025-10-31 17:03:25.212328	35.00	0.00	35.00	efectivo
1124	2025-10-31 17:18:31.100948	40.00	0.00	40.00	efectivo
1125	2025-10-31 17:25:54.070213	12.00	0.00	12.00	efectivo
1126	2025-10-31 17:38:36.206196	120.00	0.00	120.00	efectivo
1127	2025-10-31 17:40:47.14457	5.00	0.00	5.00	efectivo
1128	2025-10-31 17:47:05.636841	15.00	0.00	15.00	efectivo
1129	2025-10-31 17:47:52.1833	20.00	0.00	20.00	efectivo
1130	2025-10-31 17:48:32.979731	16.00	0.00	16.00	efectivo
1131	2025-10-31 17:59:27.30743	7.00	0.00	7.00	efectivo
1132	2025-10-31 18:06:27.129526	25.00	0.00	25.00	efectivo
1133	2025-10-31 18:07:55.240571	25.00	0.00	25.00	efectivo
1134	2025-10-31 18:08:51.479511	103.00	0.00	103.00	efectivo
1135	2025-10-31 18:17:56.406376	37.50	0.00	37.50	efectivo
1136	2025-10-31 18:22:24.923452	18.00	0.00	18.00	efectivo
1137	2025-10-31 18:22:56.815768	39.00	0.00	39.00	efectivo
1138	2025-10-31 18:36:07.443028	51.00	0.00	51.00	efectivo
1139	2025-10-31 18:43:12.284369	7.50	0.00	7.50	efectivo
1140	2025-10-31 18:43:34.740568	12.00	0.00	12.00	efectivo
1141	2025-10-31 19:15:09.653687	105.00	0.00	105.00	efectivo
1142	2025-10-31 19:26:03.731912	15.00	0.00	15.00	efectivo
1143	2025-10-31 20:16:25.093112	34.00	0.00	34.00	efectivo
1144	2025-10-31 20:40:04.512254	30.00	0.00	30.00	efectivo
1145	2025-11-01 12:37:56.188033	42.00	0.00	42.00	efectivo
1146	2025-11-01 12:44:22.919858	60.00	0.00	60.00	efectivo
1147	2025-11-01 14:40:15.511308	139.50	0.00	139.50	efectivo
1148	2025-11-01 16:33:36.953671	45.00	0.00	45.00	efectivo
1149	2025-11-01 16:34:02.172288	12.50	0.00	12.50	efectivo
1150	2025-11-01 16:34:35.000053	12.00	0.00	12.00	efectivo
1151	2025-11-01 16:46:48.401797	69.00	0.00	69.00	efectivo
1152	2025-11-01 17:25:18.525899	55.00	0.00	55.00	efectivo
1153	2025-11-01 17:25:29.538688	20.00	0.00	20.00	efectivo
1154	2025-11-01 17:35:10.544745	20.00	0.00	20.00	efectivo
1155	2025-11-01 17:50:28.969738	89.00	0.00	89.00	efectivo
1156	2025-11-01 17:56:44.487889	109.50	0.00	109.50	efectivo
1157	2025-11-01 17:57:00.75096	69.00	0.00	69.00	efectivo
1158	2025-11-03 17:00:23.159771	30.00	0.00	30.00	efectivo
1159	2025-11-03 17:00:41.847778	77.50	0.00	77.50	efectivo
1160	2025-11-03 17:09:21.508094	2.00	0.00	2.00	efectivo
1161	2025-11-03 18:04:06.703126	60.00	0.00	60.00	efectivo
1162	2025-11-03 18:24:27.661002	6.00	0.00	6.00	efectivo
1163	2025-11-03 18:25:05.795096	12.00	0.00	12.00	efectivo
1164	2025-11-03 18:59:11.82419	21.00	0.00	21.00	efectivo
1165	2025-11-03 18:59:33.882742	20.00	0.00	20.00	efectivo
1166	2025-11-03 19:06:48.972	45.00	0.00	45.00	efectivo
1167	2025-11-03 19:18:53.117398	18.50	0.00	18.50	efectivo
1168	2025-11-03 19:34:01.197114	60.00	0.00	60.00	efectivo
1169	2025-11-03 19:36:54.870757	54.00	0.00	54.00	efectivo
1170	2025-11-03 19:38:18.977682	23.00	0.00	23.00	efectivo
1171	2025-11-03 19:45:18.436918	55.00	0.00	55.00	efectivo
1172	2025-11-03 20:20:54.100587	42.00	0.00	42.00	efectivo
1173	2025-11-03 20:26:18.742435	30.00	0.00	30.00	efectivo
1174	2025-11-03 20:26:31.342184	15.00	0.00	15.00	efectivo
1175	2025-11-04 16:04:39.172628	36.00	0.00	36.00	efectivo
1176	2025-11-04 16:10:18.94052	45.00	0.00	45.00	efectivo
1177	2025-11-04 16:10:35.418666	26.00	0.00	26.00	efectivo
1178	2025-11-04 16:16:23.049914	44.00	0.00	44.00	efectivo
1179	2025-11-04 16:27:41.522985	52.00	0.00	52.00	efectivo
1180	2025-11-04 16:28:37.328844	5.00	0.00	5.00	efectivo
1181	2025-11-04 16:36:34.650243	45.00	0.00	45.00	efectivo
1182	2025-11-04 17:00:19.453337	42.00	0.00	42.00	efectivo
1183	2025-11-04 17:13:54.727441	15.00	0.00	15.00	efectivo
1184	2025-11-04 17:47:58.963713	10.00	0.00	10.00	efectivo
1185	2025-11-04 17:54:07.56105	20.00	0.00	20.00	efectivo
1186	2025-11-04 17:54:34.915053	15.00	0.00	15.00	efectivo
1187	2025-11-04 18:12:23.805824	46.00	0.00	46.00	efectivo
1188	2025-11-04 18:48:14.902333	2.00	0.00	2.00	efectivo
1189	2025-11-04 18:48:59.962488	50.00	0.00	50.00	efectivo
1190	2025-11-04 18:53:55.639381	76.00	0.00	76.00	efectivo
1191	2025-11-04 19:06:02.299085	10.00	0.00	10.00	efectivo
1192	2025-11-04 19:10:43.571886	101.00	0.00	101.00	efectivo
1193	2025-11-04 19:17:21.385439	4.00	0.00	4.00	efectivo
1194	2025-11-04 19:24:45.459075	8.00	0.00	8.00	efectivo
1195	2025-11-04 19:38:29.962162	6.00	0.00	6.00	efectivo
1196	2025-11-04 19:42:21.964649	53.00	0.00	53.00	efectivo
1197	2025-11-04 19:44:45.627746	60.00	0.00	60.00	efectivo
1198	2025-11-04 19:48:45.297757	116.50	0.00	116.50	efectivo
1199	2025-11-04 20:23:23.598043	30.00	0.00	30.00	efectivo
1200	2025-11-04 20:58:44.909241	25.00	0.00	25.00	efectivo
1201	2025-11-05 16:25:58.507768	57.50	0.00	57.50	efectivo
1202	2025-11-05 16:37:04.28753	152.00	0.00	152.00	efectivo
1203	2025-11-05 16:42:39.90737	26.00	0.00	26.00	efectivo
1204	2025-11-05 16:47:39.272092	21.00	0.00	21.00	efectivo
1205	2025-11-05 17:03:43.255496	14.00	0.00	14.00	efectivo
1206	2025-11-05 17:41:44.979202	130.00	0.00	130.00	efectivo
1207	2025-11-05 17:41:55.585707	8.00	0.00	8.00	efectivo
1208	2025-11-05 17:57:27.113716	4.00	0.00	4.00	efectivo
1209	2025-11-05 18:02:26.268572	62.00	0.00	62.00	efectivo
1210	2025-11-05 18:08:33.254947	55.50	0.00	55.50	efectivo
1211	2025-11-05 18:12:53.465492	96.00	0.00	96.00	efectivo
1212	2025-11-05 18:13:00.691184	13.00	0.00	13.00	efectivo
1213	2025-11-05 18:39:52.774844	31.00	0.00	31.00	efectivo
1214	2025-11-05 19:10:02.443501	40.00	0.00	40.00	efectivo
1215	2025-11-05 19:11:02.345876	42.00	0.00	42.00	efectivo
1216	2025-11-05 19:11:19.001824	35.00	0.00	35.00	efectivo
1217	2025-11-05 19:20:20.516581	26.00	0.00	26.00	efectivo
1218	2025-11-05 19:29:57.209864	6.00	0.00	6.00	efectivo
1219	2025-11-05 19:47:49.867652	22.00	0.00	22.00	efectivo
1220	2025-11-05 19:47:57.779735	7.00	0.00	7.00	efectivo
1221	2025-11-05 20:01:59.318715	44.00	0.00	44.00	efectivo
1222	2025-11-05 20:02:06.213544	4.00	0.00	4.00	efectivo
1223	2025-11-05 20:28:25.893412	52.00	0.00	52.00	efectivo
1224	2025-11-05 20:28:42.419283	3.00	0.00	3.00	efectivo
1225	2025-11-05 20:36:56.699066	5.00	0.00	5.00	efectivo
1226	2025-11-06 15:25:56.027719	32.00	0.00	32.00	efectivo
1227	2025-11-06 15:26:50.181056	128.00	0.00	128.00	efectivo
1228	2025-11-06 15:35:50.484444	71.00	0.00	71.00	efectivo
1229	2025-11-06 16:27:50.073811	7.50	0.00	7.50	efectivo
1230	2025-11-06 16:28:10.019903	44.00	0.00	44.00	efectivo
1231	2025-11-06 16:46:29.094119	21.00	0.00	21.00	efectivo
1232	2025-11-06 16:49:40.762394	30.00	0.00	30.00	efectivo
1233	2025-11-06 17:08:02.433586	9.00	0.00	9.00	efectivo
1234	2025-11-06 17:08:30.639655	4.50	0.00	4.50	efectivo
1235	2025-11-06 17:33:37.617629	15.00	0.00	15.00	efectivo
1236	2025-11-06 17:42:44.814698	10.00	0.00	10.00	efectivo
1237	2025-11-06 17:51:36.221652	44.50	0.00	44.50	efectivo
1238	2025-11-06 17:58:40.761585	8.50	0.00	8.50	efectivo
1239	2025-11-06 18:00:17.589179	2.00	0.00	2.00	efectivo
1240	2025-11-06 18:27:55.590458	10.00	0.00	10.00	efectivo
1241	2025-11-06 18:29:34.377363	40.00	0.00	40.00	efectivo
1242	2025-11-06 18:38:08.359823	4.00	0.00	4.00	efectivo
1243	2025-11-06 19:21:48.529313	35.00	0.00	35.00	efectivo
1244	2025-11-06 19:29:40.834943	5.00	0.00	5.00	efectivo
1245	2025-11-06 19:29:44.715397	5.00	0.00	5.00	efectivo
1246	2025-11-06 19:42:54.76572	7.00	0.00	7.00	efectivo
1247	2025-11-06 20:06:12.292663	58.50	0.00	58.50	efectivo
1248	2025-11-06 20:23:07.820409	34.00	0.00	34.00	efectivo
1249	2025-11-06 20:23:49.195741	2.00	0.00	2.00	efectivo
1250	2025-11-06 20:35:59.094427	14.00	0.00	14.00	efectivo
1251	2025-11-06 21:03:34.195173	119.00	0.00	119.00	efectivo
1252	2025-11-07 16:44:30.831456	19.00	0.00	19.00	efectivo
1253	2025-11-07 17:52:50.41598	90.00	0.00	90.00	efectivo
1254	2025-11-07 17:56:36.780558	46.00	0.00	46.00	efectivo
1255	2025-11-07 18:06:22.170191	60.00	0.00	60.00	efectivo
1256	2025-11-07 18:08:29.97219	10.00	0.00	10.00	efectivo
1257	2025-11-07 18:28:31.038314	46.50	0.00	46.50	efectivo
1258	2025-11-07 18:31:03.138219	5.00	0.00	5.00	efectivo
1259	2025-11-07 19:00:21.96632	20.00	0.00	20.00	efectivo
1260	2025-11-07 19:21:59.167931	15.00	0.00	15.00	efectivo
1261	2025-11-08 15:47:08.201873	60.00	0.00	60.00	efectivo
1262	2025-11-08 17:31:33.740678	90.00	0.00	90.00	efectivo
1263	2025-11-08 17:31:52.967885	15.00	0.00	15.00	efectivo
1264	2025-11-08 17:53:17.68579	5.00	0.00	5.00	efectivo
1265	2025-11-10 16:07:58.750319	23.00	0.00	23.00	efectivo
1266	2025-11-10 16:29:32.217116	25.00	0.00	25.00	efectivo
1267	2025-11-10 17:52:07.765843	66.00	0.00	66.00	efectivo
1268	2025-11-10 18:47:31.384036	15.00	0.00	15.00	efectivo
1269	2025-11-10 18:47:56.256316	22.00	0.00	22.00	efectivo
1270	2025-11-10 18:48:08.561082	25.00	0.00	25.00	efectivo
1271	2025-11-10 18:48:29.056202	20.00	0.00	20.00	efectivo
1272	2025-11-10 18:58:35.029421	33.50	0.00	33.50	efectivo
1273	2025-11-10 19:04:21.567964	20.00	0.00	20.00	efectivo
1274	2025-11-10 19:21:35.379197	8.00	0.00	8.00	efectivo
1275	2025-11-10 19:21:44.660958	20.00	0.00	20.00	efectivo
1276	2025-11-10 19:33:56.077046	10.00	0.00	10.00	efectivo
1277	2025-11-10 20:07:20.344856	25.00	0.00	25.00	efectivo
1278	2025-11-10 20:10:01.371511	22.00	0.00	22.00	efectivo
1279	2025-11-10 20:13:40.516896	23.00	0.00	23.00	efectivo
1280	2025-11-10 20:36:58.65266	75.00	0.00	75.00	efectivo
1281	2025-11-11 16:19:55.966471	46.00	0.00	46.00	efectivo
1282	2025-11-11 17:05:44.136637	56.00	0.00	56.00	efectivo
1283	2025-11-11 17:26:03.326182	9.00	0.00	9.00	efectivo
1284	2025-11-11 17:27:11.266451	70.00	0.00	70.00	efectivo
1285	2025-11-11 17:41:25.580795	23.00	0.00	23.00	efectivo
1286	2025-11-11 17:46:36.581097	10.00	0.00	10.00	efectivo
1287	2025-11-11 17:47:42.943476	4.00	0.00	4.00	efectivo
1288	2025-11-11 17:50:01.804836	10.00	0.00	10.00	efectivo
1289	2025-11-11 17:58:52.537847	70.00	0.00	70.00	efectivo
1290	2025-11-11 18:03:04.032652	12.50	0.00	12.50	efectivo
1291	2025-11-11 18:13:24.25047	26.00	0.00	26.00	efectivo
1292	2025-11-11 19:15:30.390562	45.00	0.00	45.00	efectivo
1293	2025-11-11 19:15:41.050804	16.00	0.00	16.00	efectivo
1294	2025-11-11 19:33:45.506015	45.00	0.00	45.00	efectivo
1295	2025-11-11 19:56:19.672062	30.00	0.00	30.00	efectivo
1296	2025-11-11 20:10:21.449921	41.00	0.00	41.00	efectivo
1297	2025-11-11 20:41:47.703308	26.00	0.00	26.00	efectivo
1298	2025-11-12 16:18:06.185854	12.00	0.00	12.00	efectivo
1299	2025-11-12 16:56:04.681664	85.00	0.00	85.00	efectivo
1300	2025-11-12 17:07:45.624525	26.00	0.00	26.00	efectivo
1301	2025-11-12 17:25:36.869015	50.00	0.00	50.00	efectivo
1302	2025-11-12 17:40:04.825298	15.00	0.00	15.00	efectivo
1303	2025-11-12 17:51:01.654711	4.00	0.00	4.00	efectivo
1304	2025-11-12 18:13:56.66873	12.00	0.00	12.00	efectivo
1305	2025-11-12 18:21:15.948955	102.00	0.00	102.00	efectivo
1306	2025-11-12 18:58:04.963561	25.00	0.00	25.00	efectivo
1307	2025-11-12 19:08:10.694551	55.00	0.00	55.00	efectivo
1308	2025-11-12 19:09:01.841939	40.00	0.00	40.00	efectivo
1309	2025-11-12 19:09:08.930668	8.00	0.00	8.00	efectivo
1310	2025-11-12 19:10:20.25789	55.00	0.00	55.00	efectivo
1311	2025-11-12 19:17:08.909358	8.00	0.00	8.00	efectivo
1312	2025-11-12 19:17:28.63191	70.00	0.00	70.00	efectivo
1313	2025-11-12 19:56:10.741919	20.00	0.00	20.00	efectivo
1314	2025-11-12 20:18:29.950281	24.00	0.00	24.00	efectivo
1315	2025-11-12 20:27:09.013847	35.50	0.00	35.50	efectivo
1316	2025-11-13 17:31:25.234388	29.00	0.00	29.00	efectivo
1317	2025-11-13 18:12:20.099264	25.00	0.00	25.00	efectivo
1318	2025-11-13 18:25:31.362154	63.00	0.00	63.00	efectivo
1319	2025-11-13 18:33:40.91161	42.00	0.00	42.00	efectivo
1320	2025-11-13 18:35:54.64208	16.00	0.00	16.00	efectivo
1321	2025-11-13 19:35:50.054724	67.00	0.00	67.00	efectivo
1322	2025-11-13 19:38:24.964694	48.00	0.00	48.00	efectivo
1323	2025-11-13 19:40:52.648028	128.00	0.00	128.00	efectivo
1324	2025-11-13 20:08:11.574421	40.00	0.00	40.00	efectivo
1325	2025-11-13 20:33:49.409142	32.00	0.00	32.00	efectivo
1326	2025-11-14 15:24:23.553073	27.00	0.00	27.00	efectivo
1327	2025-11-14 15:52:41.398072	81.00	0.00	81.00	efectivo
1328	2025-11-14 16:20:08.354558	4.00	0.00	4.00	efectivo
1329	2025-11-14 17:01:56.403519	10.00	0.00	10.00	efectivo
1330	2025-11-14 17:24:27.035874	66.00	0.00	66.00	efectivo
1331	2025-11-14 17:24:37.127367	20.00	0.00	20.00	efectivo
1332	2025-11-14 17:53:57.085451	23.00	0.00	23.00	efectivo
1333	2025-11-14 18:12:35.354588	50.00	0.00	50.00	efectivo
1334	2025-11-14 18:58:36.671043	16.50	0.00	16.50	efectivo
1335	2025-11-15 15:46:56.804056	28.00	0.00	28.00	efectivo
1336	2025-11-16 15:55:52.307281	70.00	0.00	70.00	efectivo
1337	2025-11-17 14:02:03.630294	24.00	0.00	24.00	efectivo
1338	2025-11-17 14:06:10.575442	2.50	0.00	2.50	efectivo
1339	2025-11-17 14:53:46.449949	80.00	0.00	80.00	efectivo
1340	2025-11-17 15:24:48.72323	15.00	0.00	15.00	efectivo
1341	2025-11-17 16:08:39.299794	54.00	0.00	54.00	efectivo
1342	2025-11-17 16:15:09.644492	38.00	0.00	38.00	efectivo
1343	2025-11-17 16:21:26.919003	20.00	0.00	20.00	efectivo
1344	2025-11-17 16:46:27.913001	20.00	0.00	20.00	efectivo
1345	2025-11-17 17:00:07.926756	15.00	0.00	15.00	efectivo
1346	2025-11-17 17:03:53.835604	5.00	0.00	5.00	efectivo
1347	2025-11-17 17:20:44.767576	96.00	0.00	96.00	efectivo
1348	2025-11-17 17:25:16.297616	16.50	0.00	16.50	efectivo
1349	2025-11-17 18:12:47.236983	36.00	0.00	36.00	efectivo
1350	2025-11-17 18:48:52.657354	90.00	0.00	90.00	efectivo
1351	2025-11-17 18:54:52.959855	10.00	0.00	10.00	efectivo
1352	2025-11-17 18:55:30.385419	85.00	0.00	85.00	efectivo
1353	2025-11-17 18:55:52.97629	10.00	0.00	10.00	efectivo
1354	2025-11-17 19:04:32.62759	144.00	0.00	144.00	efectivo
1355	2025-11-18 16:38:49.768937	31.00	0.00	31.00	efectivo
1356	2025-11-18 17:47:02.11153	30.00	0.00	30.00	efectivo
1357	2025-11-18 17:49:18.701456	99.00	0.00	99.00	efectivo
1358	2025-11-18 17:49:38.549611	30.00	0.00	30.00	efectivo
1359	2025-11-18 17:50:39.94188	49.00	0.00	49.00	efectivo
1360	2025-11-18 17:53:45.814542	1.50	0.00	1.50	efectivo
1361	2025-11-18 17:56:59.320701	20.00	0.00	20.00	efectivo
1362	2025-11-18 18:27:16.453809	25.00	0.00	25.00	efectivo
1363	2025-11-18 18:27:34.721786	27.00	0.00	27.00	efectivo
1364	2025-11-18 18:28:46.490438	15.00	0.00	15.00	efectivo
1365	2025-11-18 18:46:44.06038	10.00	0.00	10.00	efectivo
1366	2025-11-18 18:46:51.647551	42.00	0.00	42.00	efectivo
1367	2025-11-18 18:58:11.372951	29.00	0.00	29.00	efectivo
1368	2025-11-18 19:02:58.456744	63.00	0.00	63.00	efectivo
1369	2025-11-18 19:03:32.00786	2.50	0.00	2.50	efectivo
1370	2025-11-18 19:03:49.285538	5.00	0.00	5.00	efectivo
1371	2025-11-18 19:05:50.163938	45.00	0.00	45.00	efectivo
1372	2025-11-18 19:13:46.858841	50.00	0.00	50.00	efectivo
1373	2025-11-18 19:21:44.337487	10.00	0.00	10.00	efectivo
1374	2025-11-18 19:28:32.307331	30.00	0.00	30.00	efectivo
1375	2025-11-18 19:29:46.923334	40.00	0.00	40.00	efectivo
1376	2025-11-18 19:31:38.665088	12.00	0.00	12.00	efectivo
1377	2025-11-18 19:32:42.897322	6.00	0.00	6.00	efectivo
1378	2025-11-18 19:47:10.606545	41.00	0.00	41.00	efectivo
1379	2025-11-18 19:48:09.566593	9.00	0.00	9.00	efectivo
1380	2025-11-18 19:56:31.994622	15.00	0.00	15.00	efectivo
1381	2025-11-18 20:02:38.739414	40.00	0.00	40.00	efectivo
1382	2025-11-18 20:06:21.414375	30.00	0.00	30.00	efectivo
1383	2025-11-18 20:14:41.3759	45.00	0.00	45.00	efectivo
1384	2025-11-18 20:28:27.123449	45.00	0.00	45.00	efectivo
1385	2025-11-18 20:33:18.712231	70.00	0.00	70.00	efectivo
1386	2025-11-18 20:53:24.968983	4.50	0.00	4.50	efectivo
1387	2025-11-18 20:54:28.111977	12.00	0.00	12.00	efectivo
1388	2025-11-18 21:06:25.348163	35.00	0.00	35.00	efectivo
1389	2025-11-19 17:08:08.667858	25.00	0.00	25.00	efectivo
1390	2025-11-19 17:08:20.384034	35.00	0.00	35.00	efectivo
1391	2025-11-19 17:15:45.130998	38.00	0.00	38.00	efectivo
1392	2025-11-19 17:30:38.775485	20.00	0.00	20.00	efectivo
1393	2025-11-19 17:32:33.151153	15.00	0.00	15.00	efectivo
1394	2025-11-19 17:33:01.597044	50.00	0.00	50.00	efectivo
1395	2025-11-19 18:03:05.217201	46.00	0.00	46.00	efectivo
1396	2025-11-19 18:08:32.16303	45.00	0.00	45.00	efectivo
1397	2025-11-19 18:19:02.270618	42.00	0.00	42.00	efectivo
1398	2025-11-19 18:20:05.291692	41.00	0.00	41.00	efectivo
1399	2025-11-19 18:23:25.439602	60.00	0.00	60.00	efectivo
1400	2025-11-19 18:33:37.61714	10.00	0.00	10.00	efectivo
1401	2025-11-19 18:46:06.834039	6.00	0.00	6.00	efectivo
1402	2025-11-19 18:47:56.226539	10.00	0.00	10.00	efectivo
1403	2025-11-19 19:13:05.412702	53.50	0.00	53.50	efectivo
1404	2025-11-19 19:13:17.776794	6.00	0.00	6.00	efectivo
1405	2025-11-19 19:13:26.932276	5.00	0.00	5.00	efectivo
1406	2025-11-19 19:17:41.695431	25.50	0.00	25.50	efectivo
1407	2025-11-19 19:20:08.816987	60.00	0.00	60.00	efectivo
1408	2025-11-19 19:24:12.829365	12.00	0.00	12.00	efectivo
1409	2025-11-19 19:43:16.786013	14.00	0.00	14.00	efectivo
1410	2025-11-19 19:58:01.679037	55.00	0.00	55.00	efectivo
1411	2025-11-19 19:58:15.892363	36.00	0.00	36.00	efectivo
1412	2025-11-19 20:15:58.771414	55.50	0.00	55.50	efectivo
1413	2025-11-19 20:20:40.291483	110.00	0.00	110.00	efectivo
1414	2025-11-19 20:30:42.273681	18.00	0.00	18.00	efectivo
1415	2025-11-19 20:34:55.891838	28.00	0.00	28.00	efectivo
1416	2025-11-19 20:35:45.101331	27.00	0.00	27.00	efectivo
1417	2025-11-19 20:45:21.495197	10.00	0.00	10.00	efectivo
1418	2025-11-19 21:44:49.414293	375.00	0.00	375.00	efectivo
1419	2025-11-19 21:59:12.994658	455.00	0.00	455.00	efectivo
1420	2025-11-20 14:51:25.986773	4.00	0.00	4.00	efectivo
1421	2025-11-20 15:01:22.124244	14.00	0.00	14.00	efectivo
1422	2025-11-20 15:46:07.459755	60.00	0.00	60.00	efectivo
1423	2025-11-20 16:54:56.453315	16.00	0.00	16.00	efectivo
1424	2025-11-20 16:55:07.809058	25.00	0.00	25.00	efectivo
1425	2025-11-20 17:06:15.631428	10.00	0.00	10.00	efectivo
1426	2025-11-20 17:12:26.33863	4.00	0.00	4.00	efectivo
1427	2025-11-20 17:18:38.466395	7.00	0.00	7.00	efectivo
1428	2025-11-20 17:41:12.486865	15.00	0.00	15.00	efectivo
1429	2025-11-20 17:46:08.777148	18.00	0.00	18.00	efectivo
1430	2025-11-20 17:48:37.920254	2.00	0.00	2.00	efectivo
1431	2025-11-20 17:49:59.533395	25.00	0.00	25.00	efectivo
1432	2025-11-20 18:15:27.462665	40.50	0.00	40.50	efectivo
1433	2025-11-20 18:15:37.213322	30.00	0.00	30.00	efectivo
1434	2025-11-20 18:22:01.048442	51.50	0.00	51.50	efectivo
1435	2025-11-20 18:32:16.135526	8.00	0.00	8.00	efectivo
1436	2025-11-20 18:36:11.942754	14.00	0.00	14.00	efectivo
1437	2025-11-20 18:38:56.421384	165.00	0.00	165.00	efectivo
1438	2025-11-20 18:42:00.947464	72.00	0.00	72.00	efectivo
1439	2025-11-20 18:42:54.431408	6.00	0.00	6.00	efectivo
1440	2025-11-20 19:05:30.259418	93.00	0.00	93.00	efectivo
1441	2025-11-20 19:19:58.750723	30.00	0.00	30.00	efectivo
1442	2025-11-20 19:29:41.4766	50.00	0.00	50.00	efectivo
1443	2025-11-20 19:32:48.791441	48.00	0.00	48.00	efectivo
1444	2025-11-20 20:00:50.849986	27.00	0.00	27.00	efectivo
1445	2025-11-20 20:16:57.219307	5.00	0.00	5.00	efectivo
1446	2025-11-20 20:24:43.329782	24.00	0.00	24.00	efectivo
1447	2025-11-20 20:33:09.851059	25.00	0.00	25.00	efectivo
1448	2025-11-20 20:35:34.922116	59.00	0.00	59.00	efectivo
1449	2025-11-20 21:09:55.674363	247.00	0.00	247.00	efectivo
1450	2025-11-21 15:44:21.977404	35.00	0.00	35.00	efectivo
1451	2025-11-21 16:29:18.409722	100.00	0.00	100.00	efectivo
1452	2025-11-21 17:50:49.493294	25.00	0.00	25.00	efectivo
1453	2025-11-21 17:50:57.718233	10.00	0.00	10.00	efectivo
1454	2025-11-21 18:18:33.289014	122.00	0.00	122.00	efectivo
1455	2025-11-21 18:21:17.823761	35.00	0.00	35.00	efectivo
1456	2025-11-21 18:26:40.762738	5.00	0.00	5.00	efectivo
1457	2025-11-21 18:39:47.702602	25.00	0.00	25.00	efectivo
1458	2025-11-21 18:39:53.097917	30.00	0.00	30.00	efectivo
1459	2025-11-21 19:27:52.840108	30.00	0.00	30.00	efectivo
1460	2025-11-21 19:38:56.591532	2.00	0.00	2.00	efectivo
1461	2025-11-21 21:16:34.948568	54.00	0.00	54.00	efectivo
1462	2025-11-22 16:38:11.374941	26.00	0.00	26.00	efectivo
1463	2025-11-22 16:38:48.393493	30.00	0.00	30.00	efectivo
1464	2025-11-22 17:31:17.507991	60.00	0.00	60.00	efectivo
1465	2025-11-22 17:31:54.800255	42.00	0.00	42.00	efectivo
1466	2025-11-22 17:32:28.175824	5.00	0.00	5.00	efectivo
1467	2025-11-22 17:47:53.05365	43.00	0.00	43.00	efectivo
1468	2025-11-22 17:48:06.267809	7.00	0.00	7.00	efectivo
1469	2025-11-22 17:49:43.596027	88.00	0.00	88.00	efectivo
1470	2025-11-24 16:22:32.710816	46.00	0.00	46.00	efectivo
1471	2025-11-24 17:41:03.037608	201.50	0.00	201.50	efectivo
1472	2025-11-24 18:45:36.392901	314.00	0.00	314.00	efectivo
1473	2025-11-24 18:45:48.397878	8.00	0.00	8.00	efectivo
1474	2025-11-24 18:57:29.405394	83.00	0.00	83.00	efectivo
1475	2025-11-24 18:59:14.237664	26.00	0.00	26.00	efectivo
1476	2025-11-24 19:18:58.349059	55.00	0.00	55.00	efectivo
1477	2025-11-24 19:22:38.752722	35.00	0.00	35.00	efectivo
1478	2025-11-24 19:23:07.805686	12.00	0.00	12.00	efectivo
1479	2025-11-24 19:23:23.796146	5.00	0.00	5.00	efectivo
1480	2025-11-24 19:29:39.829257	37.00	0.00	37.00	efectivo
1481	2025-11-24 19:31:37.32655	25.00	0.00	25.00	efectivo
1482	2025-11-24 19:33:18.084283	18.00	0.00	18.00	efectivo
1483	2025-11-24 19:41:33.797896	10.00	0.00	10.00	efectivo
1484	2025-11-24 19:54:02.445203	45.00	0.00	45.00	efectivo
1485	2025-11-24 20:06:11.389252	25.00	0.00	25.00	efectivo
1486	2025-11-24 20:13:50.400705	102.00	0.00	102.00	efectivo
1487	2025-11-24 20:15:19.690711	20.00	0.00	20.00	efectivo
1488	2025-11-24 20:15:23.815062	5.00	0.00	5.00	efectivo
1489	2025-11-24 20:51:24.937657	4.00	0.00	4.00	efectivo
1490	2025-11-24 21:08:27.915994	20.00	0.00	20.00	efectivo
1491	2025-11-25 17:58:02.292944	10.50	0.00	10.50	efectivo
1492	2025-11-25 17:58:26.49664	47.00	0.00	47.00	efectivo
1493	2025-11-25 17:59:46.176704	65.00	0.00	65.00	efectivo
1494	2025-11-25 18:01:03.883072	55.00	0.00	55.00	efectivo
1495	2025-11-25 18:04:30.517552	30.00	0.00	30.00	efectivo
1496	2025-11-25 18:24:46.265496	100.00	0.00	100.00	efectivo
1497	2025-11-25 18:48:03.340254	10.00	0.00	10.00	efectivo
1498	2025-11-25 18:50:02.092608	19.00	0.00	19.00	efectivo
1499	2025-11-25 18:52:15.705344	26.00	0.00	26.00	efectivo
1500	2025-11-25 19:09:49.687426	6.00	0.00	6.00	efectivo
1501	2025-11-25 19:16:12.527279	10.00	0.00	10.00	efectivo
1502	2025-11-25 19:18:48.622625	15.00	0.00	15.00	efectivo
1503	2025-11-25 19:20:43.043776	31.00	0.00	31.00	efectivo
1504	2025-11-25 19:25:22.170139	35.00	0.00	35.00	efectivo
1505	2025-11-25 19:40:28.220242	89.00	0.00	89.00	efectivo
1506	2025-11-25 19:48:56.285524	120.00	0.00	120.00	efectivo
1507	2025-11-25 19:49:08.316495	12.00	0.00	12.00	efectivo
1508	2025-11-25 19:59:49.094656	40.00	0.00	40.00	efectivo
1509	2025-11-25 20:02:30.142132	56.00	0.00	56.00	efectivo
1510	2025-11-25 20:11:15.88713	45.00	0.00	45.00	efectivo
1511	2025-11-25 20:54:57.454391	35.00	0.00	35.00	efectivo
1512	2025-11-25 21:02:23.377587	48.00	0.00	48.00	efectivo
1513	2025-11-25 21:04:34.482226	45.00	0.00	45.00	efectivo
1514	2025-11-26 16:14:27.225144	16.00	0.00	16.00	efectivo
1515	2025-11-26 16:17:22.463566	4.50	0.00	4.50	efectivo
1516	2025-11-26 16:25:21.530201	36.00	0.00	36.00	efectivo
1517	2025-11-26 16:31:45.685838	26.00	0.00	26.00	efectivo
1518	2025-11-26 16:50:47.701171	4.00	0.00	4.00	efectivo
1519	2025-11-26 17:12:24.502491	20.00	0.00	20.00	efectivo
1520	2025-11-26 17:20:23.041469	14.00	0.00	14.00	efectivo
1521	2025-11-26 17:35:30.115376	7.00	0.00	7.00	efectivo
1522	2025-11-26 18:15:15.308124	58.50	0.00	58.50	efectivo
1523	2025-11-26 18:25:24.707812	17.50	0.00	17.50	efectivo
1524	2025-11-26 18:45:48.338036	16.00	0.00	16.00	efectivo
1525	2025-11-26 18:53:18.222243	9.00	0.00	9.00	efectivo
1526	2025-11-26 19:01:06.115946	25.00	0.00	25.00	efectivo
1527	2025-11-26 19:17:00.961627	62.00	0.00	62.00	efectivo
1528	2025-11-26 19:22:50.140988	60.00	0.00	60.00	efectivo
1529	2025-11-26 19:37:59.511704	20.00	0.00	20.00	efectivo
1530	2025-11-26 19:59:48.396821	18.00	0.00	18.00	efectivo
1531	2025-11-26 20:04:57.662221	2.00	0.00	2.00	efectivo
1532	2025-11-26 20:23:20.261272	4.00	0.00	4.00	efectivo
1533	2025-11-26 20:58:48.883999	17.00	0.00	17.00	efectivo
1534	2025-11-26 21:01:34.629129	76.00	0.00	76.00	efectivo
1535	2025-11-27 15:57:28.574359	12.00	0.00	12.00	efectivo
1536	2025-11-27 15:57:35.481865	5.00	0.00	5.00	efectivo
1537	2025-11-27 15:57:52.238407	17.00	0.00	17.00	efectivo
1538	2025-11-27 15:58:52.683613	6.00	0.00	6.00	efectivo
1539	2025-11-27 16:14:05.047381	10.00	0.00	10.00	efectivo
1540	2025-11-27 17:19:50.346217	38.00	0.00	38.00	efectivo
1541	2025-11-27 17:21:30.346777	30.50	0.00	30.50	efectivo
1542	2025-11-27 17:37:47.449492	25.00	0.00	25.00	efectivo
1543	2025-11-27 17:40:04.756111	10.00	0.00	10.00	efectivo
1544	2025-11-27 18:07:46.346803	8.00	0.00	8.00	efectivo
1545	2025-11-27 18:12:27.32946	124.00	0.00	124.00	efectivo
1546	2025-11-27 19:02:19.279842	32.00	0.00	32.00	efectivo
1547	2025-11-27 19:03:34.489642	8.00	0.00	8.00	efectivo
1548	2025-11-27 19:03:58.880191	2.00	0.00	2.00	efectivo
1549	2025-11-27 19:04:13.114559	2.00	0.00	2.00	efectivo
1550	2025-11-27 19:19:52.641945	10.00	0.00	10.00	efectivo
1551	2025-11-27 19:35:16.718558	53.00	0.00	53.00	efectivo
1552	2025-11-27 19:45:47.778651	28.00	0.00	28.00	efectivo
1553	2025-11-27 19:50:04.993162	162.00	0.00	162.00	efectivo
1554	2025-11-27 19:51:32.021585	24.00	0.00	24.00	efectivo
1555	2025-11-27 20:25:45.340995	14.00	0.00	14.00	efectivo
1556	2025-11-27 20:34:34.017596	6.00	0.00	6.00	efectivo
1557	2025-11-27 20:47:08.269669	37.00	0.00	37.00	efectivo
1558	2025-11-27 20:47:13.96123	12.50	0.00	12.50	efectivo
1559	2025-11-28 17:11:34.177959	14.00	0.00	14.00	efectivo
1560	2025-11-28 17:11:43.531323	13.00	0.00	13.00	efectivo
1561	2025-11-28 17:35:33.92293	50.00	0.00	50.00	efectivo
1562	2025-11-28 17:46:02.728454	36.00	0.00	36.00	efectivo
1563	2025-11-28 17:54:23.854909	20.00	0.00	20.00	efectivo
1564	2025-11-28 18:22:08.781756	20.00	0.00	20.00	efectivo
1565	2025-11-28 18:29:11.644085	47.00	0.00	47.00	efectivo
1566	2025-11-28 20:10:14.202499	10.00	0.00	10.00	efectivo
1567	2025-11-28 20:10:28.13222	42.50	0.00	42.50	efectivo
1568	2025-11-28 20:25:06.958646	107.00	0.00	107.00	efectivo
1569	2025-11-28 20:41:21.509896	2.00	0.00	2.00	efectivo
1570	2025-11-29 16:01:00.340561	85.00	0.00	85.00	efectivo
1571	2025-11-29 16:30:03.320118	24.00	0.00	24.00	efectivo
1572	2025-11-29 16:30:10.878567	9.00	0.00	9.00	efectivo
1573	2025-11-29 17:12:15.803704	4.00	0.00	4.00	efectivo
1574	2025-11-29 17:12:25.226568	36.00	0.00	36.00	efectivo
1575	2025-11-29 17:13:35.35957	45.00	0.00	45.00	efectivo
1576	2025-12-01 15:46:47.548555	16.00	0.00	16.00	efectivo
1577	2025-12-01 15:47:13.532607	38.00	0.00	38.00	efectivo
1578	2025-12-01 16:29:39.530575	48.00	0.00	48.00	efectivo
1579	2025-12-01 16:30:10.418399	7.00	0.00	7.00	efectivo
1580	2025-12-01 16:30:45.218947	62.00	0.00	62.00	efectivo
1581	2025-12-01 16:53:50.323807	83.50	0.00	83.50	efectivo
1582	2025-12-01 17:13:32.170597	66.00	0.00	66.00	efectivo
1583	2025-12-01 17:41:36.451833	20.00	0.00	20.00	efectivo
1584	2025-12-01 17:41:50.274322	55.00	0.00	55.00	efectivo
1585	2025-12-01 17:55:10.086081	205.50	0.00	205.50	efectivo
1586	2025-12-01 17:55:17.163186	15.00	0.00	15.00	efectivo
1587	2025-12-01 17:58:38.590436	20.00	0.00	20.00	efectivo
1588	2025-12-01 18:05:23.58738	30.00	0.00	30.00	efectivo
1589	2025-12-01 18:17:18.378796	9.00	0.00	9.00	efectivo
1590	2025-12-01 18:39:25.229236	14.00	0.00	14.00	efectivo
1591	2025-12-01 18:44:09.936318	4.00	0.00	4.00	efectivo
1592	2025-12-01 18:55:28.290423	32.00	0.00	32.00	efectivo
1593	2025-12-01 19:00:02.089283	45.00	0.00	45.00	efectivo
1594	2025-12-01 19:00:37.630588	37.00	0.00	37.00	efectivo
1595	2025-12-01 19:02:00.918394	35.00	0.00	35.00	efectivo
1596	2025-12-01 19:09:44.337376	35.00	0.00	35.00	efectivo
1597	2025-12-01 19:10:45.896702	2.00	0.00	2.00	efectivo
1598	2025-12-01 19:43:29.322751	34.00	0.00	34.00	efectivo
1599	2025-12-01 20:06:56.756909	7.50	0.00	7.50	efectivo
1600	2025-12-01 20:21:23.939569	37.00	0.00	37.00	efectivo
1601	2025-12-01 20:50:56.145122	20.50	0.00	20.50	efectivo
1602	2025-12-01 20:51:03.577105	18.00	0.00	18.00	efectivo
1603	2025-12-02 15:49:03.274615	57.50	0.00	57.50	efectivo
1604	2025-12-02 15:53:21.79338	70.00	0.00	70.00	efectivo
1605	2025-12-02 16:22:17.627894	7.00	0.00	7.00	efectivo
1606	2025-12-02 17:03:16.157901	35.50	0.00	35.50	efectivo
1607	2025-12-02 17:04:22.592572	18.00	0.00	18.00	efectivo
1608	2025-12-02 17:04:35.30584	15.00	0.00	15.00	efectivo
1609	2025-12-02 17:05:00.2885	4.50	0.00	4.50	efectivo
1610	2025-12-02 17:10:14.000873	106.50	0.00	106.50	efectivo
1611	2025-12-02 17:12:27.64106	53.00	0.00	53.00	efectivo
1612	2025-12-02 17:21:55.49581	75.00	0.00	75.00	efectivo
1613	2025-12-02 17:24:00.686114	31.00	0.00	31.00	efectivo
1614	2025-12-02 17:42:13.508552	30.00	0.00	30.00	efectivo
1615	2025-12-02 17:46:49.749124	42.00	0.00	42.00	efectivo
1616	2025-12-02 18:10:21.607656	15.00	0.00	15.00	efectivo
1617	2025-12-02 18:13:59.733005	57.00	0.00	57.00	efectivo
1618	2025-12-02 18:50:11.113698	19.50	0.00	19.50	efectivo
1619	2025-12-02 18:53:14.478342	40.00	0.00	40.00	efectivo
1620	2025-12-02 18:53:55.613148	30.00	0.00	30.00	efectivo
1621	2025-12-02 19:00:43.764062	30.00	0.00	30.00	efectivo
1622	2025-12-02 19:02:23.870701	19.00	0.00	19.00	efectivo
1623	2025-12-02 19:02:51.709523	9.00	0.00	9.00	efectivo
1624	2025-12-02 19:08:11.803579	4.50	0.00	4.50	efectivo
1625	2025-12-02 19:18:08.431559	9.00	0.00	9.00	efectivo
1626	2025-12-02 19:35:38.95458	6.00	0.00	6.00	efectivo
1627	2025-12-02 20:05:18.83283	24.00	0.00	24.00	efectivo
1628	2025-12-02 20:23:47.661371	22.00	0.00	22.00	efectivo
1629	2025-12-02 20:32:01.81497	273.00	0.00	273.00	efectivo
1630	2025-12-02 20:56:26.702286	86.50	0.00	86.50	efectivo
1631	2025-12-04 16:55:26.66952	27.00	0.00	27.00	efectivo
1632	2025-12-04 17:14:10.592792	18.00	0.00	18.00	efectivo
1633	2025-12-04 17:54:20.792495	127.00	0.00	127.00	efectivo
1634	2025-12-04 17:59:33.860761	64.00	0.00	64.00	efectivo
1635	2025-12-04 18:00:46.193438	14.00	0.00	14.00	efectivo
1636	2025-12-04 18:07:31.324604	2.00	0.00	2.00	efectivo
1637	2025-12-04 18:11:50.000725	30.00	0.00	30.00	efectivo
1638	2025-12-04 18:14:42.332482	30.00	0.00	30.00	efectivo
1639	2025-12-04 18:19:41.691126	15.00	0.00	15.00	efectivo
1640	2025-12-04 18:56:18.884847	75.00	0.00	75.00	efectivo
1641	2025-12-04 19:07:05.149173	8.00	0.00	8.00	efectivo
1642	2025-12-04 19:11:43.608922	25.00	0.00	25.00	efectivo
1643	2025-12-04 19:19:21.516881	15.00	0.00	15.00	efectivo
1644	2025-12-04 19:25:04.279545	30.00	0.00	30.00	efectivo
1645	2025-12-04 19:33:31.464054	30.00	0.00	30.00	efectivo
1646	2025-12-04 19:34:11.389179	76.00	0.00	76.00	efectivo
1647	2025-12-04 19:38:28.881928	40.00	0.00	40.00	efectivo
1648	2025-12-04 19:42:27.146224	21.00	0.00	21.00	efectivo
1649	2025-12-04 20:14:51.839209	20.00	0.00	20.00	efectivo
1650	2025-12-04 20:31:45.969728	25.00	0.00	25.00	efectivo
1651	2025-12-04 20:35:59.112309	142.00	0.00	142.00	efectivo
1652	2025-12-04 20:54:51.328495	86.00	0.00	86.00	efectivo
1653	2025-12-04 20:58:44.092575	10.50	0.00	10.50	efectivo
1654	2025-12-04 20:58:57.843461	15.00	0.00	15.00	efectivo
1655	2025-12-04 21:05:17.329811	31.00	0.00	31.00	efectivo
1656	2025-12-04 21:08:25.445021	14.50	0.00	14.50	efectivo
1657	2025-12-04 21:14:00.074003	20.00	0.00	20.00	efectivo
1658	2025-12-04 21:25:00.872101	27.00	0.00	27.00	efectivo
1659	2025-12-05 15:19:59.89576	55.00	0.00	55.00	efectivo
1660	2025-12-05 15:22:01.434062	140.00	0.00	140.00	efectivo
1661	2025-12-05 15:22:19.999673	8.00	0.00	8.00	efectivo
1662	2025-12-05 15:27:30.068378	6.00	0.00	6.00	efectivo
1663	2025-12-05 16:02:05.678457	7.00	0.00	7.00	efectivo
1664	2025-12-05 16:02:12.637473	22.00	0.00	22.00	efectivo
1665	2025-12-05 16:16:22.939827	16.00	0.00	16.00	efectivo
1666	2025-12-05 16:18:29.172021	40.00	0.00	40.00	efectivo
1667	2025-12-05 16:29:39.135556	86.50	0.00	86.50	efectivo
1668	2025-12-05 17:08:32.67351	45.00	0.00	45.00	efectivo
1669	2025-12-05 17:10:29.339401	45.00	0.00	45.00	efectivo
1670	2025-12-05 17:28:30.263857	174.00	0.00	174.00	efectivo
1671	2025-12-05 17:28:36.095953	15.00	0.00	15.00	efectivo
1672	2025-12-05 17:30:24.370284	16.00	0.00	16.00	efectivo
1673	2025-12-05 17:50:08.166848	15.00	0.00	15.00	efectivo
1674	2025-12-05 17:56:47.162327	89.00	0.00	89.00	efectivo
1675	2025-12-05 18:15:56.272974	27.00	0.00	27.00	efectivo
1676	2025-12-05 18:45:02.046708	38.00	0.00	38.00	efectivo
1677	2025-12-05 19:00:36.714504	35.00	0.00	35.00	efectivo
1678	2025-12-05 19:33:25.094851	27.00	0.00	27.00	efectivo
1679	2025-12-05 19:42:33.495019	15.00	0.00	15.00	efectivo
1680	2025-12-05 20:20:48.251937	30.00	0.00	30.00	efectivo
1681	2025-12-05 20:21:55.957735	5.00	0.00	5.00	efectivo
1682	2025-12-05 20:28:59.765974	7.00	0.00	7.00	efectivo
1683	2025-12-05 20:51:01.371814	2.00	0.00	2.00	efectivo
1684	2025-12-08 16:08:24.597871	36.00	0.00	36.00	efectivo
1685	2025-12-08 16:54:09.043219	66.00	0.00	66.00	efectivo
1686	2025-12-08 17:01:55.747332	24.00	0.00	24.00	efectivo
1687	2025-12-08 17:03:33.760078	32.00	0.00	32.00	efectivo
1688	2025-12-08 17:03:41.122336	8.00	0.00	8.00	efectivo
1689	2025-12-08 17:09:26.710057	5.00	0.00	5.00	efectivo
1690	2025-12-10 16:38:06.691268	15.00	0.00	15.00	efectivo
1691	2025-12-10 16:38:32.695727	140.00	0.00	140.00	efectivo
1692	2025-12-10 16:38:45.130513	40.00	0.00	40.00	efectivo
1693	2025-12-10 16:38:58.43634	30.00	0.00	30.00	efectivo
1694	2025-12-10 16:39:15.924163	35.00	0.00	35.00	efectivo
1695	2025-12-10 16:39:28.916259	80.00	0.00	80.00	efectivo
1696	2025-12-10 17:18:17.549934	28.00	0.00	28.00	efectivo
1697	2025-12-10 17:19:04.444138	13.00	0.00	13.00	efectivo
1698	2025-12-10 17:19:42.528672	5.00	0.00	5.00	efectivo
1699	2025-12-10 17:23:04.033102	10.00	0.00	10.00	efectivo
1700	2025-12-10 17:29:16.246907	15.00	0.00	15.00	efectivo
1701	2025-12-10 17:53:16.797004	145.00	0.00	145.00	efectivo
1702	2025-12-10 18:06:25.18406	87.00	0.00	87.00	efectivo
1703	2025-12-10 18:38:09.371272	4.00	0.00	4.00	efectivo
1704	2025-12-10 18:39:05.954233	14.00	0.00	14.00	efectivo
1705	2025-12-10 18:43:25.791697	40.00	0.00	40.00	efectivo
1706	2025-12-10 18:57:41.531856	24.00	0.00	24.00	efectivo
1707	2025-12-10 19:01:28.583801	4.00	0.00	4.00	efectivo
1708	2025-12-10 19:14:09.24831	68.00	0.00	68.00	efectivo
1709	2025-12-10 19:14:39.969062	67.00	0.00	67.00	efectivo
1710	2025-12-10 19:17:02.180764	55.00	0.00	55.00	efectivo
1711	2025-12-10 19:22:45.35663	113.50	0.00	113.50	efectivo
1712	2025-12-10 19:23:52.904647	15.00	0.00	15.00	efectivo
1713	2025-12-10 19:51:35.119111	41.00	0.00	41.00	efectivo
1714	2025-12-10 19:52:07.269475	25.00	0.00	25.00	efectivo
1715	2025-12-10 20:00:53.85616	50.00	0.00	50.00	efectivo
1716	2025-12-10 20:01:04.200002	25.00	0.00	25.00	efectivo
1717	2025-12-10 20:02:18.22998	7.00	0.00	7.00	efectivo
1718	2025-12-10 20:10:46.937928	60.00	0.00	60.00	efectivo
1719	2025-12-10 20:11:00.511694	36.50	0.00	36.50	efectivo
1720	2025-12-10 20:35:51.595981	100.00	0.00	100.00	efectivo
1721	2025-12-10 20:55:55.586009	15.00	0.00	15.00	efectivo
1722	2025-12-11 15:21:43.21354	123.00	0.00	123.00	efectivo
1723	2025-12-11 15:38:55.018186	5.00	0.00	5.00	efectivo
1724	2025-12-11 16:20:39.708808	6.00	0.00	6.00	efectivo
1725	2025-12-11 16:32:18.598552	8.00	0.00	8.00	efectivo
1726	2025-12-11 16:40:25.750073	40.00	0.00	40.00	efectivo
1727	2025-12-11 17:48:13.571114	4.00	0.00	4.00	efectivo
1728	2025-12-11 18:13:52.307939	87.00	0.00	87.00	efectivo
1729	2025-12-11 18:21:34.647017	8.00	0.00	8.00	efectivo
1730	2025-12-11 18:21:50.186124	10.00	0.00	10.00	efectivo
1731	2025-12-11 18:39:56.532704	72.00	0.00	72.00	efectivo
1732	2025-12-11 19:46:40.235156	19.00	0.00	19.00	efectivo
1733	2025-12-11 19:48:49.500074	15.00	0.00	15.00	efectivo
1734	2025-12-11 19:55:16.380308	15.00	0.00	15.00	efectivo
1735	2025-12-11 20:09:45.572967	5.00	0.00	5.00	efectivo
1736	2025-12-11 20:11:24.906041	18.00	0.00	18.00	efectivo
1737	2025-12-11 20:13:18.858219	15.00	0.00	15.00	efectivo
1738	2025-12-11 20:28:50.751877	18.00	0.00	18.00	efectivo
1739	2025-12-11 20:42:19.523531	15.00	0.00	15.00	efectivo
1740	2025-12-11 20:57:42.690094	78.00	0.00	78.00	efectivo
1741	2025-12-11 20:57:55.337232	20.00	0.00	20.00	efectivo
1742	2025-12-11 21:07:30.9173	42.00	0.00	42.00	efectivo
1743	2025-12-12 14:43:46.877103	30.00	0.00	30.00	efectivo
1744	2025-12-12 14:56:48.090766	34.00	0.00	34.00	efectivo
1745	2025-12-12 16:13:25.102325	6.00	0.00	6.00	efectivo
1746	2025-12-12 16:20:18.583646	35.00	0.00	35.00	efectivo
1747	2025-12-12 16:31:21.761332	20.00	0.00	20.00	efectivo
1748	2025-12-12 17:13:00.852178	20.00	0.00	20.00	efectivo
1749	2025-12-12 17:19:48.876706	84.00	0.00	84.00	efectivo
1750	2025-12-12 17:46:31.391642	2.00	0.00	2.00	efectivo
1751	2025-12-12 17:52:59.186626	75.00	0.00	75.00	efectivo
1752	2025-12-12 19:36:05.635782	35.00	0.00	35.00	efectivo
1753	2025-12-13 16:50:29.065253	18.00	0.00	18.00	efectivo
1754	2025-12-13 17:01:58.67606	35.00	0.00	35.00	efectivo
1755	2025-12-13 17:02:06.517157	14.00	0.00	14.00	efectivo
1756	2025-12-13 17:02:15.236217	15.00	0.00	15.00	efectivo
1757	2025-12-13 17:26:07.632245	25.00	0.00	25.00	efectivo
1758	2025-12-13 17:28:41.543106	5.00	0.00	5.00	efectivo
1759	2025-12-13 17:41:47.594014	155.00	0.00	155.00	efectivo
1760	2025-12-13 17:49:04.358598	35.00	0.00	35.00	efectivo
1761	2025-12-13 18:53:04.930137	400.00	0.00	400.00	efectivo
1762	2025-12-15 12:19:48.583553	385.00	0.00	385.00	efectivo
1763	2025-12-15 12:39:12.63343	60.00	0.00	60.00	efectivo
1764	2025-12-15 13:21:01.831586	43.00	0.00	43.00	efectivo
1765	2025-12-15 13:51:00.336109	51.00	0.00	51.00	efectivo
1766	2025-12-15 13:55:14.988675	30.00	0.00	30.00	efectivo
1767	2025-12-15 14:09:43.572077	12.00	0.00	12.00	efectivo
1768	2025-12-15 14:35:48.749661	4.00	0.00	4.00	efectivo
1769	2025-12-15 15:54:03.080377	16.00	0.00	16.00	efectivo
1770	2025-12-15 15:54:53.752463	315.00	0.00	315.00	efectivo
1771	2025-12-15 16:24:05.932136	29.50	0.00	29.50	efectivo
1772	2025-12-15 16:35:29.773695	18.00	0.00	18.00	efectivo
1773	2025-12-15 17:15:51.076948	2.00	0.00	2.00	efectivo
1774	2025-12-15 17:39:24.095139	110.00	0.00	110.00	efectivo
1775	2025-12-15 18:26:14.022728	55.00	0.00	55.00	efectivo
1776	2025-12-15 19:30:34.843915	140.00	0.00	140.00	efectivo
1777	2025-12-15 19:31:06.559037	55.00	0.00	55.00	efectivo
1778	2025-12-15 20:05:11.014656	13.00	0.00	13.00	efectivo
1779	2025-12-16 12:42:47.145182	22.00	0.00	22.00	efectivo
1780	2025-12-16 13:00:51.733314	6.00	0.00	6.00	efectivo
1781	2025-12-16 13:51:46.853587	145.00	0.00	145.00	efectivo
1782	2025-12-16 15:38:35.842734	15.00	0.00	15.00	efectivo
1783	2025-12-16 15:48:27.190163	4.00	0.00	4.00	efectivo
1784	2025-12-16 15:53:19.286475	111.00	0.00	111.00	efectivo
1785	2025-12-16 16:32:09.149429	91.50	0.00	91.50	efectivo
1786	2025-12-16 16:40:26.38461	5.00	0.00	5.00	efectivo
1787	2025-12-16 17:03:27.454839	97.00	0.00	97.00	efectivo
1788	2025-12-16 17:07:08.353495	87.50	0.00	87.50	efectivo
1789	2025-12-16 17:44:33.333697	13.00	0.00	13.00	efectivo
1790	2025-12-16 18:06:38.85849	4.00	0.00	4.00	efectivo
1791	2025-12-16 18:09:29.105217	13.50	0.00	13.50	efectivo
1792	2025-12-16 18:16:06.175146	7.00	0.00	7.00	efectivo
1793	2025-12-16 18:49:29.44537	18.00	0.00	18.00	efectivo
1794	2025-12-16 18:57:19.449961	65.00	0.00	65.00	efectivo
1795	2025-12-16 19:06:03.212285	70.00	0.00	70.00	efectivo
1796	2025-12-16 19:22:59.648048	61.00	0.00	61.00	efectivo
1797	2025-12-16 19:32:15.538177	20.00	0.00	20.00	efectivo
1798	2025-12-16 20:17:05.509533	84.50	0.00	84.50	efectivo
1799	2025-12-16 20:25:46.206605	30.00	0.00	30.00	efectivo
1800	2025-12-18 12:34:23.998961	50.00	0.00	50.00	efectivo
1801	2025-12-18 13:35:00.341999	29.00	0.00	29.00	efectivo
1802	2025-12-18 13:36:16.561055	49.00	0.00	49.00	efectivo
1803	2025-12-18 14:27:03.048019	25.00	0.00	25.00	efectivo
1804	2025-12-18 14:37:30.653657	28.00	0.00	28.00	efectivo
1805	2025-12-18 14:52:06.534233	15.00	0.00	15.00	efectivo
1806	2025-12-18 14:52:35.158861	33.00	0.00	33.00	efectivo
1807	2025-12-18 15:05:21.726172	15.00	0.00	15.00	efectivo
1808	2025-12-18 16:41:35.542189	26.00	0.00	26.00	efectivo
1809	2025-12-18 16:41:48.364094	46.00	0.00	46.00	efectivo
1810	2025-12-18 17:09:43.818408	6.00	0.00	6.00	efectivo
1811	2025-12-18 17:10:15.252717	51.00	0.00	51.00	efectivo
1812	2025-12-18 17:21:53.447825	43.50	0.00	43.50	efectivo
1813	2025-12-18 17:28:23.900974	10.00	0.00	10.00	efectivo
1814	2025-12-18 17:28:59.997426	165.00	0.00	165.00	efectivo
1815	2025-12-18 17:37:21.578025	28.50	0.00	28.50	efectivo
1816	2025-12-18 18:35:48.413258	81.00	0.00	81.00	efectivo
1817	2025-12-18 18:36:37.921945	25.00	0.00	25.00	efectivo
1818	2025-12-18 18:37:47.024009	60.00	0.00	60.00	efectivo
1819	2025-12-18 18:48:06.82923	8.00	0.00	8.00	efectivo
1820	2025-12-18 18:48:20.268771	15.00	0.00	15.00	efectivo
1821	2025-12-18 19:14:36.60046	14.00	0.00	14.00	efectivo
1822	2025-12-18 19:14:38.129896	7.00	0.00	7.00	efectivo
1823	2025-12-18 19:29:39.910799	30.00	0.00	30.00	efectivo
1824	2025-12-18 19:43:49.634871	39.00	0.00	39.00	efectivo
1825	2025-12-18 19:51:27.989153	30.50	0.00	30.50	efectivo
1826	2025-12-18 19:56:09.848853	57.00	0.00	57.00	efectivo
1827	2025-12-18 20:13:07.18613	14.00	0.00	14.00	efectivo
1828	2025-12-18 20:23:00.25641	113.00	0.00	113.00	efectivo
1829	2025-12-18 20:38:22.541031	17.00	0.00	17.00	efectivo
1830	2025-12-18 20:52:04.633594	20.00	0.00	20.00	efectivo
1831	2025-12-19 15:51:25.891561	30.00	0.00	30.00	efectivo
1832	2025-12-19 15:53:07.15968	12.00	0.00	12.00	efectivo
1833	2025-12-19 18:42:56.272318	8.00	0.00	8.00	efectivo
1834	2025-12-19 19:04:30.366823	377.50	0.00	377.50	efectivo
1835	2025-12-19 19:05:52.117753	64.00	0.00	64.00	efectivo
1836	2025-12-19 19:06:26.292341	45.00	0.00	45.00	efectivo
1837	2025-12-19 19:06:44.540827	12.00	0.00	12.00	efectivo
1838	2025-12-19 19:26:59.836727	59.00	0.00	59.00	efectivo
1839	2025-12-19 20:04:51.720869	41.00	0.00	41.00	efectivo
1840	2025-12-19 20:08:54.964313	78.00	0.00	78.00	efectivo
1841	2025-12-19 20:17:49.406696	7.00	0.00	7.00	efectivo
1842	2025-12-19 20:46:06.977569	30.00	0.00	30.00	efectivo
1843	2025-12-20 12:26:10.67137	14.00	0.00	14.00	efectivo
1844	2025-12-20 12:52:06.362559	40.00	0.00	40.00	efectivo
1845	2025-12-20 13:23:03.273246	40.00	0.00	40.00	efectivo
1846	2025-12-20 13:24:22.099898	24.00	0.00	24.00	efectivo
1847	2025-12-20 14:14:25.416104	5.00	0.00	5.00	efectivo
1848	2025-12-20 14:22:22.86484	20.00	0.00	20.00	efectivo
1849	2025-12-20 15:06:20.831457	21.00	0.00	21.00	efectivo
1850	2025-12-20 15:07:02.178512	2.00	0.00	2.00	efectivo
1851	2025-12-20 16:02:30.659592	2.00	0.00	2.00	efectivo
1852	2025-12-20 16:02:59.998251	21.00	0.00	21.00	efectivo
1853	2025-12-20 16:10:36.101094	30.00	0.00	30.00	efectivo
1854	2025-12-20 16:44:48.238935	10.00	0.00	10.00	efectivo
1855	2025-12-20 16:45:52.483594	20.00	0.00	20.00	efectivo
1856	2025-12-21 12:54:01.096052	7.50	0.00	7.50	efectivo
1857	2025-12-21 16:51:44.744418	18.00	0.00	18.00	efectivo
1858	2025-12-21 16:56:49.660786	15.00	0.00	15.00	efectivo
1859	2025-12-21 17:26:47.467959	12.00	0.00	12.00	efectivo
1860	2025-12-22 12:13:22.734746	18.00	0.00	18.00	efectivo
1861	2025-12-22 12:24:06.642633	72.50	0.00	72.50	efectivo
1862	2025-12-22 12:29:48.314412	60.00	0.00	60.00	efectivo
1863	2025-12-22 13:15:55.561762	12.00	0.00	12.00	efectivo
1864	2025-12-22 13:24:57.90999	60.00	0.00	60.00	efectivo
1865	2025-12-22 13:41:24.781933	17.00	0.00	17.00	efectivo
1866	2025-12-22 13:59:24.04459	35.00	0.00	35.00	efectivo
1867	2025-12-22 14:15:47.60916	55.00	0.00	55.00	efectivo
1868	2025-12-22 14:21:30.584216	90.00	0.00	90.00	efectivo
1869	2025-12-22 14:21:46.486247	35.00	0.00	35.00	efectivo
1870	2025-12-22 14:22:09.348236	70.00	0.00	70.00	efectivo
1871	2025-12-22 14:22:33.858825	3.00	0.00	3.00	efectivo
1872	2025-12-22 15:05:01.871191	30.00	0.00	30.00	efectivo
1873	2025-12-22 15:15:13.030196	40.00	0.00	40.00	efectivo
1874	2025-12-22 16:36:10.468929	36.50	0.00	36.50	efectivo
1875	2025-12-22 16:39:09.658865	25.50	0.00	25.50	efectivo
1876	2025-12-22 16:41:26.163056	101.00	0.00	101.00	efectivo
1877	2025-12-22 17:15:05.834138	19.50	0.00	19.50	efectivo
1878	2025-12-22 17:28:30.90847	145.00	0.00	145.00	efectivo
1879	2025-12-22 17:29:07.152665	124.00	0.00	124.00	efectivo
1880	2025-12-22 17:29:50.47579	20.50	0.00	20.50	efectivo
1881	2025-12-22 18:06:32.956219	111.50	0.00	111.50	efectivo
1882	2025-12-22 18:29:45.116603	80.00	0.00	80.00	efectivo
1883	2025-12-22 18:30:25.894332	45.00	0.00	45.00	efectivo
1884	2025-12-22 18:31:58.704115	2.50	0.00	2.50	efectivo
1885	2025-12-22 18:53:47.641742	50.00	0.00	50.00	efectivo
1886	2025-12-22 18:56:23.676664	10.00	0.00	10.00	efectivo
1887	2025-12-22 19:23:49.398018	35.00	0.00	35.00	efectivo
1888	2025-12-22 20:14:12.182164	182.50	0.00	182.50	efectivo
1889	2025-12-22 20:16:31.449493	25.00	0.00	25.00	efectivo
1890	2025-12-22 20:18:11.477827	25.00	0.00	25.00	efectivo
1891	2025-12-23 12:09:03.2489	12.00	0.00	12.00	efectivo
1892	2025-12-23 12:30:25.634266	25.00	0.00	25.00	efectivo
1893	2025-12-23 13:10:20.006359	105.00	0.00	105.00	efectivo
1894	2025-12-23 13:39:26.461058	30.00	0.00	30.00	efectivo
1895	2025-12-23 14:18:33.184365	53.00	0.00	53.00	efectivo
1896	2025-12-23 14:27:10.536228	12.00	0.00	12.00	efectivo
1897	2025-12-23 14:27:33.749335	15.00	0.00	15.00	efectivo
1898	2025-12-23 14:34:04.980075	50.00	0.00	50.00	efectivo
1899	2025-12-23 14:47:45.424272	6.50	0.00	6.50	efectivo
1900	2025-12-23 15:53:15.640581	39.00	0.00	39.00	efectivo
1901	2025-12-23 16:32:29.696822	65.00	0.00	65.00	efectivo
1902	2025-12-23 16:32:33.913256	20.00	0.00	20.00	efectivo
1903	2025-12-23 16:36:38.561229	24.00	0.00	24.00	efectivo
1904	2025-12-23 17:02:53.398255	56.00	0.00	56.00	efectivo
1905	2025-12-23 17:29:07.089832	20.00	0.00	20.00	efectivo
1906	2025-12-23 17:35:07.173937	25.00	0.00	25.00	efectivo
1907	2025-12-23 17:48:53.344957	31.00	0.00	31.00	efectivo
1908	2025-12-23 17:50:40.981916	16.00	0.00	16.00	efectivo
1909	2025-12-23 17:55:14.004391	100.00	0.00	100.00	efectivo
1910	2025-12-23 17:55:18.149814	30.00	0.00	30.00	efectivo
1911	2025-12-23 18:12:23.666589	28.00	0.00	28.00	efectivo
1912	2025-12-23 18:12:33.025101	21.00	0.00	21.00	efectivo
1913	2025-12-23 18:16:41.659037	167.00	0.00	167.00	efectivo
1914	2025-12-23 18:17:30.224753	30.00	0.00	30.00	efectivo
1915	2025-12-23 18:29:18.47235	12.00	0.00	12.00	efectivo
1916	2025-12-23 18:39:40.87498	85.00	0.00	85.00	efectivo
1917	2025-12-23 19:41:31.299455	52.00	0.00	52.00	efectivo
1918	2025-12-23 19:42:48.806053	43.50	0.00	43.50	efectivo
1919	2025-12-23 19:44:08.144666	17.00	0.00	17.00	efectivo
1920	2025-12-23 19:51:51.021246	6.00	0.00	6.00	efectivo
1921	2025-12-23 20:11:13.311451	30.00	0.00	30.00	efectivo
1922	2025-12-23 20:20:12.493832	20.00	0.00	20.00	efectivo
1923	2025-12-23 20:24:54.631263	30.00	0.00	30.00	efectivo
1924	2025-12-23 20:28:19.332535	8.00	0.00	8.00	efectivo
1925	2025-12-24 11:17:35.776413	32.00	0.00	32.00	efectivo
1926	2025-12-24 11:17:47.037395	30.00	0.00	30.00	efectivo
1927	2025-12-24 11:17:53.13494	30.00	0.00	30.00	efectivo
1928	2025-12-24 11:19:15.77205	14.00	0.00	14.00	efectivo
1929	2025-12-24 11:32:30.044443	14.00	0.00	14.00	efectivo
1930	2025-12-24 11:32:39.364861	15.00	0.00	15.00	efectivo
1931	2025-12-24 11:33:09.935628	24.00	0.00	24.00	efectivo
1932	2025-12-24 11:33:38.05594	150.00	0.00	150.00	efectivo
1933	2025-12-24 12:07:21.533193	77.50	0.00	77.50	efectivo
1934	2025-12-24 12:32:46.900447	56.00	0.00	56.00	efectivo
1935	2025-12-24 12:38:00.855754	42.00	0.00	42.00	efectivo
1936	2025-12-24 12:47:00.690308	71.00	0.00	71.00	efectivo
1937	2025-12-24 12:55:33.361511	15.00	0.00	15.00	efectivo
1938	2025-12-24 12:56:51.647334	8.00	0.00	8.00	efectivo
1939	2025-12-24 13:02:47.185389	12.00	0.00	12.00	efectivo
1940	2025-12-24 13:15:43.868401	55.00	0.00	55.00	efectivo
1941	2025-12-24 13:55:49.685692	27.00	0.00	27.00	efectivo
1942	2025-12-24 14:05:15.496094	50.00	0.00	50.00	efectivo
1943	2025-12-24 14:08:49.484565	46.00	0.00	46.00	efectivo
1944	2025-12-24 14:17:11.319242	183.00	0.00	183.00	efectivo
1945	2025-12-24 14:25:41.906929	20.00	0.00	20.00	efectivo
1946	2025-12-24 14:54:05.416617	20.00	0.00	20.00	efectivo
1947	2025-12-24 15:09:38.217106	6.00	0.00	6.00	efectivo
1948	2025-12-24 15:16:31.735265	15.00	0.00	15.00	efectivo
1949	2025-12-24 15:38:10.065878	87.00	0.00	87.00	efectivo
1950	2025-12-24 15:42:53.202167	40.00	0.00	40.00	efectivo
1951	2025-12-24 15:46:21.782331	7.50	0.00	7.50	efectivo
1952	2025-12-24 16:02:01.007701	77.00	0.00	77.00	efectivo
1953	2025-12-24 16:14:17.534579	105.00	0.00	105.00	efectivo
1954	2025-12-24 16:18:37.193099	34.00	0.00	34.00	efectivo
1955	2025-12-24 16:19:08.962691	30.00	0.00	30.00	efectivo
1956	2025-12-24 16:26:14.979735	70.00	0.00	70.00	efectivo
1957	2025-12-24 17:58:21.189798	27.00	0.00	27.00	efectivo
1958	2025-12-24 18:00:49.696734	64.00	0.00	64.00	efectivo
1959	2025-12-24 18:07:47.750496	51.50	0.00	51.50	efectivo
1960	2025-12-24 18:10:02.197096	24.00	0.00	24.00	efectivo
1961	2025-12-24 18:36:29.112169	240.00	0.00	240.00	efectivo
1962	2025-12-24 19:53:32.037745	110.00	0.00	110.00	efectivo
1963	2025-12-26 16:29:09.805076	25.00	0.00	25.00	efectivo
1964	2025-12-26 16:48:35.88391	4.00	0.00	4.00	efectivo
1965	2025-12-26 18:18:53.595933	36.00	0.00	36.00	efectivo
1966	2025-12-26 18:19:01.800485	15.00	0.00	15.00	efectivo
1967	2025-12-26 19:48:06.193958	20.00	0.00	20.00	efectivo
1968	2025-12-26 19:48:12.148845	25.00	0.00	25.00	efectivo
1969	2025-12-29 16:26:24.019035	190.00	0.00	190.00	efectivo
1970	2025-12-29 16:26:29.968997	2.00	0.00	2.00	efectivo
1971	2025-12-29 16:28:34.268135	9.00	0.00	9.00	efectivo
1972	2025-12-29 17:53:06.439733	103.50	0.00	103.50	efectivo
1973	2025-12-29 17:53:20.738848	10.00	0.00	10.00	efectivo
1974	2025-12-29 18:40:44.351915	43.00	0.00	43.00	efectivo
1975	2025-12-29 18:53:57.100794	20.00	0.00	20.00	efectivo
1976	2025-12-29 19:20:47.662137	33.00	0.00	33.00	efectivo
1977	2025-12-29 19:22:29.792682	4.00	0.00	4.00	efectivo
1978	2025-12-30 13:59:50.853861	12.00	0.00	12.00	efectivo
1979	2025-12-30 14:01:12.25409	30.00	0.00	30.00	efectivo
1980	2025-12-30 17:05:42.93746	12.00	0.00	12.00	efectivo
1981	2025-12-30 17:31:02.660698	68.00	0.00	68.00	efectivo
1982	2025-12-30 17:39:17.077863	21.00	0.00	21.00	efectivo
1983	2025-12-30 18:02:50.100734	8.00	0.00	8.00	efectivo
1984	2025-12-30 18:35:58.652581	14.00	0.00	14.00	efectivo
1985	2025-12-30 20:13:08.283768	12.00	0.00	12.00	efectivo
1986	2025-12-30 20:18:41.985924	12.00	0.00	12.00	efectivo
1987	2026-01-06 16:23:47.067699	58.00	0.00	58.00	efectivo
1988	2026-01-06 16:24:20.831626	3.00	0.00	3.00	efectivo
1989	2026-01-06 16:25:28.027987	60.00	0.00	60.00	efectivo
1990	2026-01-06 16:26:47.263191	30.00	0.00	30.00	efectivo
1991	2026-01-06 17:01:24.026206	63.00	0.00	63.00	efectivo
1992	2026-01-06 17:10:21.965912	40.50	0.00	40.50	efectivo
1993	2026-01-06 17:20:44.366726	15.00	0.00	15.00	efectivo
1994	2026-01-06 17:42:02.70299	40.00	0.00	40.00	efectivo
1995	2026-01-06 18:03:18.880049	62.00	0.00	62.00	efectivo
1996	2026-01-06 18:11:04.027222	12.00	0.00	12.00	efectivo
1997	2026-01-06 18:11:25.128025	5.00	0.00	5.00	efectivo
1998	2026-01-06 18:19:53.754369	40.00	0.00	40.00	efectivo
1999	2026-01-06 18:32:04.923615	47.00	0.00	47.00	efectivo
2000	2026-01-06 19:07:07.258544	5.00	0.00	5.00	efectivo
2001	2026-01-06 19:23:54.541737	32.00	0.00	32.00	efectivo
2002	2026-01-06 19:35:08.688006	48.00	0.00	48.00	efectivo
2003	2026-01-06 19:43:55.679985	36.00	0.00	36.00	efectivo
2004	2026-01-06 19:44:04.209971	20.00	0.00	20.00	efectivo
2005	2026-01-06 19:49:46.593303	163.00	0.00	163.00	efectivo
2006	2026-01-06 20:26:01.981241	4.00	0.00	4.00	efectivo
2007	2026-01-06 20:26:14.73895	18.00	0.00	18.00	efectivo
2008	2026-01-07 15:06:16.30721	14.00	0.00	14.00	efectivo
2009	2026-01-07 15:22:48.533422	30.00	0.00	30.00	efectivo
2010	2026-01-07 16:25:26.249664	2.00	0.00	2.00	efectivo
2011	2026-01-07 16:37:58.574209	67.00	0.00	67.00	efectivo
2012	2026-01-07 16:52:00.584656	270.00	0.00	270.00	efectivo
2013	2026-01-07 18:00:24.566475	62.00	0.00	62.00	efectivo
2014	2026-01-07 18:00:35.952771	36.00	0.00	36.00	efectivo
2015	2026-01-07 18:17:33.47035	35.00	0.00	35.00	efectivo
2016	2026-01-07 18:19:31.0636	6.00	0.00	6.00	efectivo
2017	2026-01-07 19:05:44.213274	83.00	0.00	83.00	efectivo
2018	2026-01-07 19:36:24.911733	77.00	0.00	77.00	efectivo
2019	2026-01-07 19:53:42.058197	50.00	0.00	50.00	efectivo
2020	2026-01-07 19:58:08.661374	6.00	0.00	6.00	efectivo
2021	2026-01-07 20:48:08.385539	30.00	0.00	30.00	efectivo
2022	2026-01-08 16:22:38.719755	40.00	0.00	40.00	efectivo
2023	2026-01-08 16:44:09.624985	55.00	0.00	55.00	efectivo
2024	2026-01-08 16:52:09.118333	16.00	0.00	16.00	efectivo
2025	2026-01-08 17:22:46.459736	72.50	0.00	72.50	efectivo
2026	2026-01-08 17:23:06.085139	87.00	0.00	87.00	efectivo
2027	2026-01-08 17:28:37.656965	4.00	0.00	4.00	efectivo
2028	2026-01-08 17:36:36.889453	54.00	0.00	54.00	efectivo
2029	2026-01-08 17:46:19.211259	30.00	0.00	30.00	efectivo
2030	2026-01-08 17:57:13.651355	110.00	0.00	110.00	efectivo
2031	2026-01-08 18:12:03.504659	164.00	0.00	164.00	efectivo
2032	2026-01-08 18:16:39.500486	17.00	0.00	17.00	efectivo
2033	2026-01-08 18:20:00.512289	23.00	0.00	23.00	efectivo
2034	2026-01-08 18:47:12.819816	18.00	0.00	18.00	efectivo
2035	2026-01-08 18:47:15.607733	4.00	0.00	4.00	efectivo
2036	2026-01-08 18:47:45.170217	4.50	0.00	4.50	efectivo
2037	2026-01-08 19:38:07.6118	116.00	0.00	116.00	efectivo
2038	2026-01-08 20:03:35.205771	25.00	0.00	25.00	efectivo
2039	2026-01-08 20:26:53.919796	70.00	0.00	70.00	efectivo
2040	2026-01-08 20:50:03.120138	2.00	0.00	2.00	efectivo
2041	2026-01-09 17:58:20.490171	40.00	0.00	40.00	efectivo
2042	2026-01-09 18:00:09.173459	42.00	0.00	42.00	efectivo
2043	2026-01-09 18:00:19.269301	35.00	0.00	35.00	efectivo
2044	2026-01-09 18:00:28.444446	35.00	0.00	35.00	efectivo
2045	2026-01-09 18:02:44.050968	72.00	0.00	72.00	efectivo
2046	2026-01-09 18:05:47.59095	95.00	0.00	95.00	efectivo
2047	2026-01-09 18:09:23.675078	65.00	0.00	65.00	efectivo
2048	2026-01-09 19:06:43.874703	112.00	0.00	112.00	efectivo
2049	2026-01-09 19:08:55.943383	16.00	0.00	16.00	efectivo
2050	2026-01-09 20:21:34.539882	135.00	0.00	135.00	efectivo
2051	2026-01-09 21:18:03.154622	61.50	0.00	61.50	efectivo
2052	2026-01-12 16:15:17.657561	2.00	0.00	2.00	efectivo
2053	2026-01-12 16:52:06.053137	2.00	0.00	2.00	efectivo
2054	2026-01-12 16:59:48.067288	4.00	0.00	4.00	efectivo
2055	2026-01-12 17:08:19.796617	12.00	0.00	12.00	efectivo
2056	2026-01-12 17:10:02.381077	30.00	0.00	30.00	efectivo
2057	2026-01-12 17:17:06.960661	25.00	0.00	25.00	efectivo
2058	2026-01-12 17:24:31.697279	35.00	0.00	35.00	efectivo
2059	2026-01-12 17:28:35.512058	57.00	0.00	57.00	efectivo
2060	2026-01-12 17:39:28.558617	87.00	0.00	87.00	efectivo
2061	2026-01-12 17:49:51.78403	14.00	0.00	14.00	efectivo
2062	2026-01-12 17:50:56.21814	25.00	0.00	25.00	efectivo
2063	2026-01-12 18:12:01.96233	27.00	0.00	27.00	efectivo
2064	2026-01-12 18:35:34.636135	160.00	0.00	160.00	efectivo
2065	2026-01-12 18:47:38.112716	10.00	0.00	10.00	efectivo
2066	2026-01-12 18:49:11.533367	14.00	0.00	14.00	efectivo
2067	2026-01-12 18:56:29.460181	5.00	0.00	5.00	efectivo
2068	2026-01-12 18:59:23.691826	14.00	0.00	14.00	efectivo
2069	2026-01-12 19:11:50.656902	40.00	0.00	40.00	efectivo
2070	2026-01-12 19:14:18.526733	25.00	0.00	25.00	efectivo
2071	2026-01-12 19:20:14.105935	7.00	0.00	7.00	efectivo
2072	2026-01-12 19:23:55.433817	30.00	0.00	30.00	efectivo
2073	2026-01-12 19:43:12.275988	131.00	0.00	131.00	efectivo
2074	2026-01-12 19:52:54.223663	129.00	0.00	129.00	efectivo
2075	2026-01-12 19:53:02.027163	4.00	0.00	4.00	efectivo
2076	2026-01-12 19:53:19.255242	12.00	0.00	12.00	efectivo
2077	2026-01-12 20:05:59.768435	58.00	0.00	58.00	efectivo
2078	2026-01-12 20:06:05.320819	3.00	0.00	3.00	efectivo
2079	2026-01-12 20:34:04.898647	16.00	0.00	16.00	efectivo
2080	2026-01-12 20:38:40.826451	5.00	0.00	5.00	efectivo
2081	2026-01-12 20:56:09.219863	80.00	0.00	80.00	efectivo
2082	2026-01-12 20:56:28.420664	10.00	0.00	10.00	efectivo
2083	2026-01-12 21:02:29.801814	46.00	0.00	46.00	efectivo
2084	2026-01-13 14:31:56.353277	70.00	0.00	70.00	efectivo
2085	2026-01-13 14:37:41.703708	10.00	0.00	10.00	efectivo
2086	2026-01-13 15:19:16.701992	13.00	0.00	13.00	efectivo
2087	2026-01-13 15:20:19.610129	92.00	0.00	92.00	efectivo
2088	2026-01-13 15:23:52.766145	10.00	0.00	10.00	efectivo
2089	2026-01-13 15:42:36.925407	37.00	0.00	37.00	efectivo
2090	2026-01-13 15:43:28.923481	14.00	0.00	14.00	efectivo
2091	2026-01-13 15:47:39.810272	50.00	0.00	50.00	efectivo
2092	2026-01-13 16:31:57.437683	20.00	0.00	20.00	efectivo
2093	2026-01-13 17:15:05.942704	10.00	0.00	10.00	efectivo
2094	2026-01-13 17:25:46.878562	32.00	0.00	32.00	efectivo
2095	2026-01-13 17:25:58.728752	25.00	0.00	25.00	efectivo
2096	2026-01-13 18:02:36.459881	2.50	0.00	2.50	efectivo
2097	2026-01-13 18:04:26.799502	26.00	0.00	26.00	efectivo
2098	2026-01-13 18:16:22.212461	102.00	0.00	102.00	efectivo
2099	2026-01-13 18:33:12.045916	25.00	0.00	25.00	efectivo
2100	2026-01-13 18:39:58.543349	16.00	0.00	16.00	efectivo
2101	2026-01-13 18:44:36.88789	2.00	0.00	2.00	efectivo
2102	2026-01-13 18:49:33.735703	20.00	0.00	20.00	efectivo
2103	2026-01-13 18:54:21.103107	80.00	0.00	80.00	efectivo
2104	2026-01-13 19:00:04.771775	35.00	0.00	35.00	efectivo
2105	2026-01-13 19:15:37.157327	39.00	0.00	39.00	efectivo
2106	2026-01-13 19:26:13.550117	39.00	0.00	39.00	efectivo
2107	2026-01-13 19:42:33.162715	17.00	0.00	17.00	efectivo
2108	2026-01-13 19:51:39.221438	65.00	0.00	65.00	efectivo
2109	2026-01-13 19:53:39.734279	25.00	0.00	25.00	efectivo
2110	2026-01-13 19:55:17.640825	10.00	0.00	10.00	efectivo
2111	2026-01-13 19:55:21.086793	6.00	0.00	6.00	efectivo
2112	2026-01-13 20:06:34.26723	20.00	0.00	20.00	efectivo
2113	2026-01-13 20:07:23.644868	26.00	0.00	26.00	efectivo
2114	2026-01-13 20:20:31.497832	18.00	0.00	18.00	efectivo
2115	2026-01-13 20:35:14.496974	79.00	0.00	79.00	efectivo
2116	2026-01-13 20:57:22.530804	10.00	0.00	10.00	efectivo
2117	2026-01-13 20:58:30.915506	20.00	0.00	20.00	efectivo
2118	2026-01-14 15:50:36.52067	36.00	0.00	36.00	efectivo
2119	2026-01-14 15:51:42.65392	2.00	0.00	2.00	efectivo
2120	2026-01-14 16:02:09.023766	10.00	0.00	10.00	efectivo
2121	2026-01-14 16:22:28.816347	40.00	0.00	40.00	efectivo
2122	2026-01-14 16:23:34.387394	67.00	0.00	67.00	efectivo
2123	2026-01-14 16:25:22.011679	7.00	0.00	7.00	efectivo
2124	2026-01-14 16:27:04.928995	10.00	0.00	10.00	efectivo
2125	2026-01-14 16:29:56.811385	48.50	0.00	48.50	efectivo
2126	2026-01-14 16:46:48.739981	4.00	0.00	4.00	efectivo
2127	2026-01-14 16:47:01.924336	65.00	0.00	65.00	efectivo
2128	2026-01-14 17:13:53.244865	21.00	0.00	21.00	efectivo
2129	2026-01-14 17:17:22.067428	77.00	0.00	77.00	efectivo
2130	2026-01-14 17:20:22.32895	14.00	0.00	14.00	efectivo
2131	2026-01-14 17:41:21.914249	45.00	0.00	45.00	efectivo
2132	2026-01-14 17:49:33.356004	25.00	0.00	25.00	efectivo
2133	2026-01-14 17:51:50.428959	45.00	0.00	45.00	efectivo
2134	2026-01-14 18:04:48.416413	47.00	0.00	47.00	efectivo
2135	2026-01-14 18:13:05.903893	10.00	0.00	10.00	efectivo
2136	2026-01-14 18:13:53.996644	10.00	0.00	10.00	efectivo
2137	2026-01-14 18:15:02.634126	2.00	0.00	2.00	efectivo
2138	2026-01-14 18:17:01.649098	7.00	0.00	7.00	efectivo
2139	2026-01-14 18:19:38.279616	58.00	0.00	58.00	efectivo
2140	2026-01-14 18:41:53.453383	30.00	0.00	30.00	efectivo
2141	2026-01-14 18:43:45.127094	32.50	0.00	32.50	efectivo
2142	2026-01-14 18:53:12.904451	35.00	0.00	35.00	efectivo
2143	2026-01-14 19:00:22.239332	66.00	0.00	66.00	efectivo
2144	2026-01-14 19:03:59.326582	47.00	0.00	47.00	efectivo
2145	2026-01-14 19:15:33.641445	95.00	0.00	95.00	efectivo
2146	2026-01-14 19:19:46.506133	145.00	0.00	145.00	efectivo
2147	2026-01-14 19:21:32.232359	33.50	0.00	33.50	efectivo
2148	2026-01-14 19:25:39.412455	8.00	0.00	8.00	efectivo
2149	2026-01-14 19:26:34.356378	17.00	0.00	17.00	efectivo
2150	2026-01-14 19:33:29.742683	15.00	0.00	15.00	efectivo
2151	2026-01-14 19:34:44.509743	11.00	0.00	11.00	efectivo
2152	2026-01-14 19:49:51.883168	10.00	0.00	10.00	efectivo
2153	2026-01-14 19:51:55.920207	27.00	0.00	27.00	efectivo
2154	2026-01-14 19:58:49.548444	18.00	0.00	18.00	efectivo
2155	2026-01-14 20:01:25.130547	10.00	0.00	10.00	efectivo
2156	2026-01-14 20:19:24.845806	22.50	0.00	22.50	efectivo
2157	2026-01-14 20:26:46.205422	35.00	0.00	35.00	efectivo
2158	2026-01-14 20:44:40.561962	8.00	0.00	8.00	efectivo
2159	2026-01-14 20:56:29.545242	31.00	0.00	31.00	efectivo
2160	2026-01-15 15:37:25.653298	22.00	0.00	22.00	efectivo
2161	2026-01-15 15:39:49.533307	75.00	0.00	75.00	efectivo
2162	2026-01-15 16:15:15.698001	50.00	0.00	50.00	efectivo
2163	2026-01-15 16:48:35.002117	26.00	0.00	26.00	efectivo
2164	2026-01-15 18:04:44.492074	4.00	0.00	4.00	efectivo
2165	2026-01-15 18:17:41.029977	45.00	0.00	45.00	efectivo
2166	2026-01-15 18:56:57.240395	23.00	0.00	23.00	efectivo
2167	2026-01-15 18:59:06.39784	9.00	0.00	9.00	efectivo
2168	2026-01-15 19:10:55.247945	19.00	0.00	19.00	efectivo
2169	2026-01-15 19:13:19.100006	18.00	0.00	18.00	efectivo
2170	2026-01-15 19:15:56.365893	42.00	0.00	42.00	efectivo
2171	2026-01-15 19:20:21.315059	32.00	0.00	32.00	efectivo
2172	2026-01-15 19:21:40.88905	26.00	0.00	26.00	efectivo
2173	2026-01-15 19:22:48.240036	2.00	0.00	2.00	efectivo
2174	2026-01-15 19:24:48.841122	24.00	0.00	24.00	efectivo
2175	2026-01-15 19:29:47.266651	102.50	0.00	102.50	efectivo
2176	2026-01-15 19:37:14.386194	7.00	0.00	7.00	efectivo
2177	2026-01-15 19:37:23.838713	4.00	0.00	4.00	efectivo
2178	2026-01-15 19:53:18.10256	17.00	0.00	17.00	efectivo
2179	2026-01-15 19:53:22.96183	10.00	0.00	10.00	efectivo
2180	2026-01-15 20:29:11.467158	130.00	0.00	130.00	efectivo
2181	2026-01-15 20:52:04.988662	17.00	0.00	17.00	efectivo
2182	2026-01-15 20:52:44.707494	10.00	0.00	10.00	efectivo
2183	2026-01-16 16:01:13.164517	27.00	0.00	27.00	efectivo
2184	2026-01-16 16:43:11.670058	53.00	0.00	53.00	efectivo
2185	2026-01-16 17:49:12.203573	23.00	0.00	23.00	efectivo
2186	2026-01-16 17:52:54.22157	19.00	0.00	19.00	efectivo
2187	2026-01-17 16:59:38.912058	23.00	0.00	23.00	efectivo
2188	2026-01-17 18:00:12.302723	27.00	0.00	27.00	efectivo
2189	2026-01-17 18:02:31.589922	20.00	0.00	20.00	efectivo
2190	2026-01-19 15:10:08.274962	51.00	0.00	51.00	efectivo
2191	2026-01-19 15:49:14.084755	35.00	0.00	35.00	efectivo
2192	2026-01-19 15:50:00.108607	7.00	0.00	7.00	efectivo
2193	2026-01-19 16:46:03.421945	28.00	0.00	28.00	efectivo
2194	2026-01-19 16:46:12.405747	15.00	0.00	15.00	efectivo
2195	2026-01-19 16:51:07.431695	44.00	0.00	44.00	efectivo
2196	2026-01-19 17:00:42.878187	40.00	0.00	40.00	efectivo
2197	2026-01-19 18:09:43.254321	25.00	0.00	25.00	efectivo
2198	2026-01-19 18:47:52.030904	2.00	0.00	2.00	efectivo
2199	2026-01-19 19:11:59.415126	10.00	0.00	10.00	efectivo
2200	2026-01-19 19:12:06.815621	2.00	0.00	2.00	efectivo
2201	2026-01-19 19:18:55.92104	54.00	0.00	54.00	efectivo
2202	2026-01-19 19:46:41.733485	12.00	0.00	12.00	efectivo
2203	2026-01-19 20:12:49.55756	12.00	0.00	12.00	efectivo
2204	2026-01-19 20:17:34.407736	4.00	0.00	4.00	efectivo
2205	2026-01-19 20:31:36.831947	99.00	0.00	99.00	efectivo
2206	2026-01-19 20:34:17.059724	80.00	0.00	80.00	efectivo
2207	2026-01-19 20:36:03.210976	13.00	0.00	13.00	efectivo
2208	2026-01-19 20:49:34.418002	165.00	0.00	165.00	efectivo
2209	2026-01-20 15:44:24.76668	76.00	0.00	76.00	efectivo
2210	2026-01-20 15:44:32.522064	2.50	0.00	2.50	efectivo
2211	2026-01-20 15:52:54.097943	5.00	0.00	5.00	efectivo
2212	2026-01-20 16:26:20.0611	4.00	0.00	4.00	efectivo
2213	2026-01-20 17:07:32.861752	13.50	0.00	13.50	efectivo
2214	2026-01-20 17:09:19.422232	24.00	0.00	24.00	efectivo
2215	2026-01-20 17:23:03.877994	41.00	0.00	41.00	efectivo
2216	2026-01-20 17:25:24.821455	39.00	0.00	39.00	efectivo
2217	2026-01-20 17:34:00.286416	59.00	0.00	59.00	efectivo
2218	2026-01-20 17:58:50.018451	15.00	0.00	15.00	efectivo
2219	2026-01-20 18:07:22.296445	36.00	0.00	36.00	efectivo
2220	2026-01-20 18:10:46.770719	20.00	0.00	20.00	efectivo
2221	2026-01-20 18:12:42.839929	5.00	0.00	5.00	efectivo
2222	2026-01-20 18:16:48.475478	35.00	0.00	35.00	efectivo
2223	2026-01-20 18:17:35.101388	8.00	0.00	8.00	efectivo
2224	2026-01-20 18:17:49.515418	4.00	0.00	4.00	efectivo
2225	2026-01-20 18:32:06.438896	36.00	0.00	36.00	efectivo
2226	2026-01-20 18:40:28.686537	28.50	0.00	28.50	efectivo
2227	2026-01-20 18:48:37.120801	45.00	0.00	45.00	efectivo
2228	2026-01-20 18:50:01.972718	2.00	0.00	2.00	efectivo
2229	2026-01-20 18:55:20.320122	99.00	0.00	99.00	efectivo
2230	2026-01-20 18:57:37.224836	75.00	0.00	75.00	efectivo
2231	2026-01-20 18:58:58.713332	16.00	0.00	16.00	efectivo
2232	2026-01-20 19:02:12.299885	28.00	0.00	28.00	efectivo
2233	2026-01-20 19:10:07.260168	67.00	0.00	67.00	efectivo
2234	2026-01-20 19:10:17.06646	14.00	0.00	14.00	efectivo
2235	2026-01-20 19:20:50.268566	22.50	0.00	22.50	efectivo
2236	2026-01-20 19:35:58.149645	154.00	0.00	154.00	efectivo
2237	2026-01-20 19:55:52.798446	301.00	0.00	301.00	efectivo
2238	2026-01-20 20:35:58.99963	17.00	0.00	17.00	efectivo
2239	2026-01-21 14:53:12.85494	50.00	0.00	50.00	efectivo
2240	2026-01-21 16:38:56.060517	49.00	0.00	49.00	efectivo
2241	2026-01-21 17:34:07.774299	10.00	0.00	10.00	efectivo
2242	2026-01-21 17:37:43.2204	205.00	0.00	205.00	efectivo
2243	2026-01-21 17:41:03.824139	13.50	0.00	13.50	efectivo
2244	2026-01-21 17:41:54.854656	14.00	0.00	14.00	efectivo
2245	2026-01-21 17:43:58.534621	7.50	0.00	7.50	efectivo
2246	2026-01-21 17:49:50.361461	4.00	0.00	4.00	efectivo
2247	2026-01-21 18:00:25.197569	10.00	0.00	10.00	efectivo
2248	2026-01-21 18:06:17.865114	60.00	0.00	60.00	efectivo
2249	2026-01-21 18:09:24.151507	57.00	0.00	57.00	efectivo
2250	2026-01-21 18:23:10.795551	7.50	0.00	7.50	efectivo
2251	2026-01-21 18:27:09.40129	15.00	0.00	15.00	efectivo
2252	2026-01-21 18:32:47.858431	72.00	0.00	72.00	efectivo
2253	2026-01-21 18:39:56.290817	14.00	0.00	14.00	efectivo
2254	2026-01-21 18:54:47.626508	32.00	0.00	32.00	efectivo
2255	2026-01-21 19:33:27.158154	46.00	0.00	46.00	efectivo
2256	2026-01-21 19:36:57.402079	7.00	0.00	7.00	efectivo
2257	2026-01-21 19:47:10.14057	70.00	0.00	70.00	efectivo
2258	2026-01-21 20:00:27.066597	54.00	0.00	54.00	efectivo
2259	2026-01-21 20:12:54.464232	5.00	0.00	5.00	efectivo
2260	2026-01-21 20:46:07.127923	50.00	0.00	50.00	efectivo
2261	2026-01-21 21:05:18.596182	61.00	0.00	61.00	efectivo
2262	2026-01-23 16:43:11.299502	44.00	0.00	44.00	efectivo
2263	2026-01-23 16:49:07.874314	21.50	0.00	21.50	efectivo
2264	2026-01-23 16:52:17.702216	37.00	0.00	37.00	efectivo
2265	2026-01-23 16:59:16.197707	30.00	0.00	30.00	efectivo
2266	2026-01-23 17:14:57.501568	44.00	0.00	44.00	efectivo
2267	2026-01-23 17:35:29.324163	9.00	0.00	9.00	efectivo
2268	2026-01-23 17:40:34.172372	24.00	0.00	24.00	efectivo
2269	2026-01-23 17:46:01.607586	45.00	0.00	45.00	efectivo
2270	2026-01-23 18:04:43.520282	355.00	0.00	355.00	efectivo
2271	2026-01-23 18:36:51.203771	100.00	0.00	100.00	efectivo
2272	2026-01-23 19:09:57.994086	30.00	0.00	30.00	efectivo
2273	2026-01-23 19:30:25.320615	12.00	0.00	12.00	efectivo
2274	2026-01-23 19:36:14.331949	45.00	0.00	45.00	efectivo
2275	2026-01-23 20:20:14.968166	39.00	0.00	39.00	efectivo
2276	2026-01-23 21:06:45.496623	67.00	0.00	67.00	efectivo
2277	2026-01-23 21:22:05.888457	200.00	0.00	200.00	efectivo
2278	2026-01-23 21:22:31.653102	3.00	0.00	3.00	efectivo
2279	2026-01-26 13:30:42.260235	17.00	0.00	17.00	efectivo
2280	2026-01-26 13:37:33.463004	21.00	0.00	21.00	efectivo
2281	2026-01-26 16:15:23.879563	51.00	0.00	51.00	efectivo
2282	2026-01-26 16:19:16.651621	19.00	0.00	19.00	efectivo
2283	2026-01-26 16:19:21.876163	20.00	0.00	20.00	efectivo
2284	2026-01-26 16:19:34.949347	16.00	0.00	16.00	efectivo
2285	2026-01-26 16:26:13.123439	55.00	0.00	55.00	efectivo
2286	2026-01-26 16:35:34.098335	32.00	0.00	32.00	efectivo
2287	2026-01-26 17:21:01.830092	29.50	0.00	29.50	efectivo
2288	2026-01-26 17:36:22.775725	62.00	0.00	62.00	efectivo
2289	2026-01-26 17:37:33.321649	18.00	0.00	18.00	efectivo
2290	2026-01-26 17:45:36.341751	25.00	0.00	25.00	efectivo
2291	2026-01-26 17:46:00.558044	14.00	0.00	14.00	efectivo
2292	2026-01-26 18:05:26.770405	103.00	0.00	103.00	efectivo
2293	2026-01-26 18:11:27.50652	59.00	0.00	59.00	efectivo
2294	2026-01-26 18:15:50.791699	60.00	0.00	60.00	efectivo
2295	2026-01-26 18:18:16.550338	10.00	0.00	10.00	efectivo
2296	2026-01-26 18:20:55.252658	10.00	0.00	10.00	efectivo
2297	2026-01-26 18:34:01.441386	166.00	0.00	166.00	efectivo
2298	2026-01-26 18:34:42.559307	20.00	0.00	20.00	efectivo
2299	2026-01-26 18:40:56.858243	16.00	0.00	16.00	efectivo
2300	2026-01-26 18:42:26.134117	60.00	0.00	60.00	efectivo
2301	2026-01-26 18:42:40.377624	27.00	0.00	27.00	efectivo
2302	2026-01-26 18:54:59.79749	80.00	0.00	80.00	efectivo
2303	2026-01-26 19:07:21.142962	14.00	0.00	14.00	efectivo
2304	2026-01-26 19:07:47.93158	15.00	0.00	15.00	efectivo
2305	2026-01-26 19:16:18.829188	15.00	0.00	15.00	efectivo
2306	2026-01-26 19:32:44.958326	20.00	0.00	20.00	efectivo
2307	2026-01-26 19:35:32.651813	61.50	0.00	61.50	efectivo
2308	2026-01-26 19:42:29.836345	7.00	0.00	7.00	efectivo
2309	2026-01-26 19:46:09.575158	22.00	0.00	22.00	efectivo
2310	2026-01-26 19:46:34.134291	8.00	0.00	8.00	efectivo
2311	2026-01-26 19:50:48.24635	43.00	0.00	43.00	efectivo
2312	2026-01-26 19:55:29.107806	31.00	0.00	31.00	efectivo
2313	2026-01-26 19:59:29.44094	23.00	0.00	23.00	efectivo
2314	2026-01-26 20:05:14.942024	58.00	0.00	58.00	efectivo
2315	2026-01-26 20:07:38.888612	20.00	0.00	20.00	efectivo
2316	2026-01-26 20:24:18.857978	60.00	0.00	60.00	efectivo
2317	2026-01-26 20:32:40.535734	10.00	0.00	10.00	efectivo
2318	2026-01-26 20:37:49.347483	62.00	0.00	62.00	efectivo
2319	2026-01-26 20:51:08.779996	15.00	0.00	15.00	efectivo
2320	2026-01-26 20:51:28.077802	160.00	0.00	160.00	efectivo
2321	2026-01-27 15:38:50.97619	48.00	0.00	48.00	efectivo
2322	2026-01-27 15:39:07.544579	36.00	0.00	36.00	efectivo
2323	2026-01-27 15:55:18.117355	62.00	0.00	62.00	efectivo
2324	2026-01-27 15:55:36.514923	10.50	0.00	10.50	efectivo
2325	2026-01-27 16:01:39.432452	20.00	0.00	20.00	efectivo
2326	2026-01-27 16:03:26.093867	9.00	0.00	9.00	efectivo
2327	2026-01-27 16:51:03.296729	4.00	0.00	4.00	efectivo
2328	2026-01-27 16:51:59.060217	9.00	0.00	9.00	efectivo
2329	2026-01-27 16:59:07.505758	2.00	0.00	2.00	efectivo
2330	2026-01-27 17:12:25.681992	5.00	0.00	5.00	efectivo
2331	2026-01-27 17:41:51.942165	87.50	0.00	87.50	efectivo
2332	2026-01-27 17:57:56.972986	8.00	0.00	8.00	efectivo
2333	2026-01-27 18:04:09.02221	14.00	0.00	14.00	efectivo
2334	2026-01-27 18:10:18.960865	2.00	0.00	2.00	efectivo
2335	2026-01-27 18:10:28.779027	45.00	0.00	45.00	efectivo
2336	2026-01-27 18:16:28.448617	4.00	0.00	4.00	efectivo
2337	2026-01-27 18:27:41.986457	32.00	0.00	32.00	efectivo
2338	2026-01-27 18:29:03.914197	25.00	0.00	25.00	efectivo
2339	2026-01-27 18:30:45.611718	35.00	0.00	35.00	efectivo
2340	2026-01-27 18:51:30.621029	136.00	0.00	136.00	efectivo
2341	2026-01-27 19:21:15.705574	30.00	0.00	30.00	efectivo
2342	2026-01-27 20:13:19.620293	14.00	0.00	14.00	efectivo
2343	2026-01-27 20:15:35.3535	35.00	0.00	35.00	efectivo
2344	2026-01-27 20:16:22.262234	47.00	0.00	47.00	efectivo
2345	2026-01-27 20:48:01.256778	19.00	0.00	19.00	efectivo
2346	2026-01-27 20:52:36.996663	30.00	0.00	30.00	efectivo
2347	2026-01-27 20:55:46.763943	70.00	0.00	70.00	efectivo
2348	2026-01-27 21:02:18.254154	4.00	0.00	4.00	efectivo
2349	2026-01-28 15:50:11.718292	50.00	0.00	50.00	efectivo
2350	2026-01-28 16:26:03.796072	24.00	0.00	24.00	efectivo
2351	2026-01-28 16:34:44.936969	203.50	0.00	203.50	efectivo
2352	2026-01-28 16:36:21.624853	13.00	0.00	13.00	efectivo
2353	2026-01-28 16:48:40.401956	50.50	0.00	50.50	efectivo
2354	2026-01-28 17:10:23.872926	18.00	0.00	18.00	efectivo
2355	2026-01-28 17:24:20.391704	28.00	0.00	28.00	efectivo
2356	2026-01-28 17:32:02.582375	83.00	0.00	83.00	efectivo
2357	2026-01-28 17:34:50.535895	12.00	0.00	12.00	efectivo
2358	2026-01-28 17:47:51.869495	39.00	0.00	39.00	efectivo
2359	2026-01-28 17:54:20.592248	18.00	0.00	18.00	efectivo
2360	2026-01-28 18:10:53.85338	5.00	0.00	5.00	efectivo
2361	2026-01-28 18:23:20.685558	2.00	0.00	2.00	efectivo
2362	2026-01-28 18:24:08.632875	16.00	0.00	16.00	efectivo
2363	2026-01-28 18:42:46.170253	2.50	0.00	2.50	efectivo
2364	2026-01-28 18:43:12.126496	10.00	0.00	10.00	efectivo
2365	2026-01-28 18:47:54.731142	7.00	0.00	7.00	efectivo
2366	2026-01-28 18:55:10.366069	33.50	0.00	33.50	efectivo
2367	2026-01-28 19:08:04.709232	4.50	0.00	4.50	efectivo
2368	2026-01-28 19:20:53.147439	52.00	0.00	52.00	efectivo
2369	2026-01-28 19:21:09.506806	35.00	0.00	35.00	efectivo
2370	2026-01-28 19:33:30.382445	29.00	0.00	29.00	efectivo
2371	2026-01-28 19:37:09.746081	53.00	0.00	53.00	efectivo
2372	2026-01-28 19:42:49.239878	58.00	0.00	58.00	efectivo
2373	2026-01-28 20:13:05.175766	3.00	0.00	3.00	efectivo
2374	2026-01-28 20:15:58.292182	14.00	0.00	14.00	efectivo
2375	2026-01-28 20:30:58.478631	5.00	0.00	5.00	efectivo
2376	2026-01-28 20:39:42.792518	38.50	0.00	38.50	efectivo
2377	2026-01-28 20:41:01.810889	9.00	0.00	9.00	efectivo
2378	2026-01-28 21:17:56.93052	114.50	0.00	114.50	efectivo
2379	2026-01-28 21:18:46.633375	50.00	0.00	50.00	efectivo
2380	2026-01-29 15:37:15.870828	2.00	0.00	2.00	efectivo
2381	2026-01-29 15:37:21.452825	8.00	0.00	8.00	efectivo
2382	2026-01-29 15:37:29.685474	4.00	0.00	4.00	efectivo
2383	2026-01-29 15:54:33.103481	29.00	0.00	29.00	efectivo
2384	2026-01-29 15:58:37.280254	40.00	0.00	40.00	efectivo
2385	2026-01-29 16:11:38.38723	20.00	0.00	20.00	efectivo
2386	2026-01-29 16:22:17.74825	58.00	0.00	58.00	efectivo
2387	2026-01-29 16:23:46.202402	102.00	0.00	102.00	efectivo
2388	2026-01-29 16:35:37.439386	30.00	0.00	30.00	efectivo
2389	2026-01-29 16:52:17.570158	68.00	0.00	68.00	efectivo
2390	2026-01-29 18:42:07.088627	100.00	0.00	100.00	efectivo
2391	2026-01-29 19:17:59.68681	20.00	0.00	20.00	efectivo
2392	2026-01-29 19:23:54.491747	30.75	0.00	30.75	efectivo
2393	2026-01-29 19:48:45.355416	51.00	0.00	51.00	efectivo
2394	2026-01-29 20:05:48.744994	26.00	0.00	26.00	efectivo
2395	2026-01-29 20:22:05.579562	55.00	0.00	55.00	efectivo
2396	2026-01-29 20:59:54.096986	33.00	0.00	33.00	efectivo
2397	2026-01-30 15:00:22.360414	7.00	0.00	7.00	efectivo
2398	2026-01-30 15:05:43.400476	26.00	0.00	26.00	efectivo
2399	2026-01-30 16:03:09.023055	60.00	0.00	60.00	efectivo
2400	2026-01-30 16:31:12.808397	14.00	0.00	14.00	efectivo
2401	2026-01-30 16:32:03.380656	57.00	0.00	57.00	efectivo
2402	2026-01-30 16:32:26.278723	2.00	0.00	2.00	efectivo
2403	2026-01-30 17:01:52.463801	10.00	0.00	10.00	efectivo
2404	2026-01-30 17:04:29.351086	39.00	0.00	39.00	efectivo
2405	2026-01-30 18:24:08.49283	9.00	0.00	9.00	efectivo
2406	2026-01-30 18:35:48.804677	18.00	0.00	18.00	efectivo
2407	2026-01-30 19:22:43.412617	29.00	0.00	29.00	efectivo
2408	2026-01-30 19:25:03.787507	20.00	0.00	20.00	efectivo
2409	2026-01-30 19:25:09.355132	1.50	0.00	1.50	efectivo
2410	2026-01-30 21:29:58.756215	222.00	0.00	222.00	efectivo
2411	2026-01-30 21:30:16.289716	9.00	0.00	9.00	efectivo
2412	2026-01-31 16:03:56.964633	2.00	0.00	2.00	efectivo
2413	2026-01-31 16:11:22.162088	42.00	0.00	42.00	efectivo
2414	2026-01-31 16:38:11.768748	80.00	0.00	80.00	efectivo
2415	2026-01-31 16:38:43.681117	154.00	0.00	154.00	efectivo
2416	2026-01-31 18:01:29.879962	114.00	0.00	114.00	efectivo
2417	2026-01-31 18:05:07.556989	20.00	0.00	20.00	efectivo
2418	2026-02-03 15:47:01.462714	16.00	0.00	16.00	efectivo
2419	2026-02-03 16:08:29.041701	50.00	0.00	50.00	efectivo
2420	2026-02-03 16:10:26.643569	58.50	0.00	58.50	efectivo
2421	2026-02-03 16:20:25.777423	2.00	0.00	2.00	efectivo
2422	2026-02-03 16:44:00.751781	149.00	0.00	149.00	efectivo
2423	2026-02-03 16:46:00.487122	4.00	0.00	4.00	efectivo
2424	2026-02-03 16:51:11.158517	20.00	0.00	20.00	efectivo
2425	2026-02-03 17:06:29.216639	47.50	0.00	47.50	efectivo
2426	2026-02-03 17:48:15.247076	82.00	0.00	82.00	efectivo
2427	2026-02-03 17:51:47.201839	57.00	0.00	57.00	efectivo
2428	2026-02-03 17:53:13.058659	9.00	0.00	9.00	efectivo
2429	2026-02-03 17:53:57.627351	4.00	0.00	4.00	efectivo
2430	2026-02-03 17:56:00.131955	29.00	0.00	29.00	efectivo
2431	2026-02-03 17:56:32.675261	15.00	0.00	15.00	efectivo
2432	2026-02-03 18:00:27.989356	12.00	0.00	12.00	efectivo
2433	2026-02-03 18:11:20.315048	85.00	0.00	85.00	efectivo
2434	2026-02-03 18:11:40.857136	4.00	0.00	4.00	efectivo
2435	2026-02-03 18:15:45.250273	90.00	0.00	90.00	efectivo
2436	2026-02-03 18:22:19.056242	38.00	0.00	38.00	efectivo
2437	2026-02-03 18:23:10.922645	37.00	0.00	37.00	efectivo
2438	2026-02-03 18:28:03.988455	90.00	0.00	90.00	efectivo
2439	2026-02-03 18:29:06.698675	4.00	0.00	4.00	efectivo
2440	2026-02-03 18:29:09.739639	2.00	0.00	2.00	efectivo
2441	2026-02-03 18:30:10.398214	15.00	0.00	15.00	efectivo
2442	2026-02-03 18:39:12.909124	38.00	0.00	38.00	efectivo
2443	2026-02-03 18:54:38.5117	16.00	0.00	16.00	efectivo
2444	2026-02-03 19:06:42.261894	60.00	0.00	60.00	efectivo
2445	2026-02-03 19:13:00.700257	50.00	0.00	50.00	efectivo
2446	2026-02-03 19:13:25.451618	105.00	0.00	105.00	efectivo
2447	2026-02-03 19:26:11.241148	7.00	0.00	7.00	efectivo
2448	2026-02-03 19:39:29.913224	95.00	0.00	95.00	efectivo
2449	2026-02-03 19:58:46.755244	23.00	0.00	23.00	efectivo
2450	2026-02-03 20:04:19.24702	60.50	0.00	60.50	efectivo
2451	2026-02-03 20:05:49.280767	10.00	0.00	10.00	efectivo
2452	2026-02-03 20:08:08.905581	14.00	0.00	14.00	efectivo
2453	2026-02-03 20:12:43.220662	30.00	0.00	30.00	efectivo
2454	2026-02-03 20:36:56.525611	35.00	0.00	35.00	efectivo
2455	2026-02-03 20:47:55.279043	91.50	0.00	91.50	efectivo
2456	2026-02-03 21:00:29.788678	16.50	0.00	16.50	efectivo
2457	2026-02-03 21:00:39.863124	9.00	0.00	9.00	efectivo
2458	2026-02-03 21:01:54.430343	14.00	0.00	14.00	efectivo
2459	2026-02-04 15:28:44.529242	14.00	0.00	14.00	efectivo
2460	2026-02-04 15:47:56.865249	4.00	0.00	4.00	efectivo
2461	2026-02-04 15:48:14.342936	30.00	0.00	30.00	efectivo
2462	2026-02-04 15:54:23.546079	56.00	0.00	56.00	efectivo
2463	2026-02-04 15:56:14.937542	27.00	0.00	27.00	efectivo
2464	2026-02-04 16:12:09.283528	35.00	0.00	35.00	efectivo
2465	2026-02-04 16:14:46.713847	45.00	0.00	45.00	efectivo
2466	2026-02-04 16:15:22.388863	108.00	0.00	108.00	efectivo
2467	2026-02-04 16:15:42.289779	10.00	0.00	10.00	efectivo
2468	2026-02-04 16:44:45.546745	17.00	0.00	17.00	efectivo
2469	2026-02-04 16:51:33.588486	7.00	0.00	7.00	efectivo
2470	2026-02-04 17:05:54.590578	8.00	0.00	8.00	efectivo
2471	2026-02-04 17:14:36.309812	8.00	0.00	8.00	efectivo
2472	2026-02-04 17:28:18.514146	136.00	0.00	136.00	efectivo
2473	2026-02-04 17:40:32.346446	75.00	0.00	75.00	efectivo
2474	2026-02-04 17:41:07.619437	3.00	0.00	3.00	efectivo
2475	2026-02-04 17:48:06.426092	26.00	0.00	26.00	efectivo
2476	2026-02-04 17:50:31.648786	8.00	0.00	8.00	efectivo
2477	2026-02-04 18:20:22.959095	25.50	0.00	25.50	efectivo
2478	2026-02-04 18:21:11.132108	91.00	0.00	91.00	efectivo
2479	2026-02-04 18:26:56.720024	26.00	0.00	26.00	efectivo
2480	2026-02-04 18:36:24.388898	76.00	0.00	76.00	efectivo
2481	2026-02-04 19:15:09.650856	16.00	0.00	16.00	efectivo
2482	2026-02-04 19:20:03.460659	68.00	0.00	68.00	efectivo
2483	2026-02-04 19:21:14.500831	69.00	0.00	69.00	efectivo
2484	2026-02-04 19:52:41.05613	7.00	0.00	7.00	efectivo
2485	2026-02-04 19:56:03.584235	24.00	0.00	24.00	efectivo
2486	2026-02-04 20:28:34.142497	13.00	0.00	13.00	efectivo
2487	2026-02-04 20:55:03.39383	85.00	0.00	85.00	efectivo
2488	2026-02-05 15:36:54.530322	60.00	0.00	60.00	efectivo
2489	2026-02-05 15:44:44.297152	29.00	0.00	29.00	efectivo
2490	2026-02-05 15:50:29.92735	15.00	0.00	15.00	efectivo
2491	2026-02-05 16:00:18.614913	172.00	0.00	172.00	efectivo
2492	2026-02-05 16:00:26.510706	2.50	0.00	2.50	efectivo
2493	2026-02-05 16:06:44.690023	123.00	0.00	123.00	efectivo
2494	2026-02-05 16:19:27.80952	38.00	0.00	38.00	efectivo
2495	2026-02-05 16:22:00.22542	20.00	0.00	20.00	efectivo
2496	2026-02-05 16:28:06.210788	25.00	0.00	25.00	efectivo
2497	2026-02-05 16:31:46.410148	24.00	0.00	24.00	efectivo
2498	2026-02-05 16:47:51.893727	4.50	0.00	4.50	efectivo
2499	2026-02-05 16:48:16.109482	10.50	0.00	10.50	efectivo
2500	2026-02-05 16:48:39.239843	27.00	0.00	27.00	efectivo
2501	2026-02-05 16:48:47.343243	20.00	0.00	20.00	efectivo
2502	2026-02-05 16:49:00.516563	10.00	0.00	10.00	efectivo
2503	2026-02-05 16:49:16.158734	8.00	0.00	8.00	efectivo
2504	2026-02-05 17:11:26.02187	40.00	0.00	40.00	efectivo
2505	2026-02-05 17:23:45.649261	15.00	0.00	15.00	efectivo
2506	2026-02-05 17:37:20.910937	142.00	0.00	142.00	efectivo
2507	2026-02-05 17:38:14.266179	47.00	0.00	47.00	efectivo
2508	2026-02-05 17:46:03.002968	50.00	0.00	50.00	efectivo
2509	2026-02-05 18:06:32.138193	20.00	0.00	20.00	efectivo
2510	2026-02-05 18:09:44.752276	20.00	0.00	20.00	efectivo
2511	2026-02-05 18:15:26.29212	10.00	0.00	10.00	efectivo
2512	2026-02-05 18:16:28.418642	110.00	0.00	110.00	efectivo
2513	2026-02-05 18:25:01.877355	23.00	0.00	23.00	efectivo
2514	2026-02-05 18:32:08.000936	28.00	0.00	28.00	efectivo
2515	2026-02-05 18:45:03.711715	39.00	0.00	39.00	efectivo
2516	2026-02-05 18:45:06.808868	2.00	0.00	2.00	efectivo
2517	2026-02-05 19:06:33.533516	71.00	0.00	71.00	efectivo
2518	2026-02-05 19:12:21.092464	73.00	0.00	73.00	efectivo
2519	2026-02-05 19:16:59.340358	5.00	0.00	5.00	efectivo
2520	2026-02-05 19:33:27.909277	110.00	0.00	110.00	efectivo
2521	2026-02-05 19:34:10.83243	432.00	0.00	432.00	efectivo
2522	2026-02-05 19:49:03.825367	14.00	0.00	14.00	efectivo
2523	2026-02-05 19:49:42.33465	54.00	0.00	54.00	efectivo
2524	2026-02-05 20:10:26.38398	190.00	0.00	190.00	efectivo
2525	2026-02-05 20:22:56.978436	47.00	0.00	47.00	efectivo
2526	2026-02-05 20:32:55.054546	81.00	0.00	81.00	efectivo
2527	2026-02-05 20:54:29.272988	17.00	0.00	17.00	efectivo
2528	2026-02-06 16:20:32.669435	10.00	0.00	10.00	efectivo
2529	2026-02-06 16:22:17.229933	8.00	0.00	8.00	efectivo
2530	2026-02-06 16:28:19.044137	7.00	0.00	7.00	efectivo
2531	2026-02-06 17:00:14.533016	19.00	0.00	19.00	efectivo
2532	2026-02-06 17:38:10.805474	8.00	0.00	8.00	efectivo
2533	2026-02-06 17:38:21.612986	15.00	0.00	15.00	efectivo
2534	2026-02-06 17:46:36.261787	70.00	0.00	70.00	efectivo
2535	2026-02-06 18:25:35.870458	26.50	0.00	26.50	efectivo
2536	2026-02-06 18:29:38.168261	13.50	0.00	13.50	efectivo
2537	2026-02-06 19:22:58.728156	22.00	0.00	22.00	efectivo
2538	2026-02-06 19:48:42.236614	5.00	0.00	5.00	efectivo
2539	2026-02-06 19:54:32.413798	36.00	0.00	36.00	efectivo
2540	2026-02-06 20:38:43.516985	21.00	0.00	21.00	efectivo
2541	2026-02-06 20:59:06.304794	60.00	0.00	60.00	efectivo
2542	2026-02-07 15:45:38.805106	75.00	0.00	75.00	efectivo
2543	2026-02-07 15:55:22.781429	110.00	0.00	110.00	efectivo
2544	2026-02-07 16:10:23.965686	15.00	0.00	15.00	efectivo
2545	2026-02-07 16:52:04.15549	48.50	0.00	48.50	efectivo
2546	2026-02-07 16:56:40.931656	70.00	0.00	70.00	efectivo
2547	2026-02-07 17:52:39.259659	5.00	0.00	5.00	efectivo
2548	2026-02-07 18:01:56.579615	20.00	0.00	20.00	efectivo
2549	2026-02-07 18:05:41.92443	95.00	0.00	95.00	efectivo
2550	2026-02-07 18:25:30.035057	176.00	0.00	176.00	efectivo
2551	2026-02-07 18:36:27.663957	95.00	0.00	95.00	efectivo
2552	2026-02-07 18:37:05.124238	27.00	0.00	27.00	efectivo
2553	2026-02-09 16:08:09.567225	15.00	0.00	15.00	efectivo
2554	2026-02-09 16:13:59.208604	25.00	0.00	25.00	efectivo
2555	2026-02-09 16:36:42.570768	25.00	0.00	25.00	efectivo
2556	2026-02-09 17:08:37.315781	20.25	0.00	20.25	efectivo
2557	2026-02-09 17:15:19.925223	30.00	0.00	30.00	efectivo
2558	2026-02-09 17:18:18.742079	28.00	0.00	28.00	efectivo
2559	2026-02-09 17:22:57.846549	6.00	0.00	6.00	efectivo
2560	2026-02-09 17:31:46.55157	10.00	0.00	10.00	efectivo
2561	2026-02-09 17:49:18.751816	71.00	0.00	71.00	efectivo
2562	2026-02-09 18:04:05.727121	10.00	0.00	10.00	efectivo
2563	2026-02-09 18:04:57.06829	7.50	0.00	7.50	efectivo
2564	2026-02-09 18:07:38.867228	26.00	0.00	26.00	efectivo
2565	2026-02-09 18:14:46.652371	13.00	0.00	13.00	efectivo
2566	2026-02-09 18:18:47.184273	73.50	0.00	73.50	efectivo
2567	2026-02-09 18:21:46.4046	48.00	0.00	48.00	efectivo
2568	2026-02-09 18:24:30.383294	9.00	0.00	9.00	efectivo
2569	2026-02-09 18:27:53.262083	17.00	0.00	17.00	efectivo
2570	2026-02-09 18:30:19.713876	12.50	0.00	12.50	efectivo
2571	2026-02-09 18:30:59.092441	14.00	0.00	14.00	efectivo
2572	2026-02-09 18:38:25.655583	6.00	0.00	6.00	efectivo
2573	2026-02-09 18:39:22.957946	20.00	0.00	20.00	efectivo
2574	2026-02-09 18:41:03.876113	10.00	0.00	10.00	efectivo
2575	2026-02-09 18:44:40.835519	18.00	0.00	18.00	efectivo
2576	2026-02-09 18:48:29.106777	36.00	0.00	36.00	efectivo
2577	2026-02-09 18:51:21.869687	7.00	0.00	7.00	efectivo
2578	2026-02-09 19:00:28.78587	22.00	0.00	22.00	efectivo
2579	2026-02-09 19:11:54.694556	15.50	0.00	15.50	efectivo
2580	2026-02-09 19:14:48.883428	13.00	0.00	13.00	efectivo
2581	2026-02-09 19:18:04.378494	121.00	0.00	121.00	efectivo
2582	2026-02-09 19:35:04.332725	8.00	0.00	8.00	efectivo
2583	2026-02-09 19:35:45.703464	77.00	0.00	77.00	efectivo
2584	2026-02-09 19:36:02.251056	49.00	0.00	49.00	efectivo
2585	2026-02-09 19:36:10.985912	4.00	0.00	4.00	efectivo
2586	2026-02-09 19:41:43.456149	15.00	0.00	15.00	efectivo
2587	2026-02-09 19:44:12.245177	15.00	0.00	15.00	efectivo
2588	2026-02-09 19:48:06.360989	30.00	0.00	30.00	efectivo
2589	2026-02-09 19:48:49.514534	20.00	0.00	20.00	efectivo
2590	2026-02-09 19:58:50.428246	30.00	0.00	30.00	efectivo
2591	2026-02-09 20:03:30.386267	30.00	0.00	30.00	efectivo
2592	2026-02-09 20:04:48.954722	22.00	0.00	22.00	efectivo
2593	2026-02-09 20:05:29.751011	7.00	0.00	7.00	efectivo
2594	2026-02-09 20:05:49.758518	2.00	0.00	2.00	efectivo
2595	2026-02-09 20:10:20.334691	14.00	0.00	14.00	efectivo
2596	2026-02-09 20:20:52.478419	112.00	0.00	112.00	efectivo
2597	2026-02-09 20:39:06.563173	38.00	0.00	38.00	efectivo
2598	2026-02-09 20:44:06.109169	10.00	0.00	10.00	efectivo
2599	2026-02-09 20:45:49.725199	5.00	0.00	5.00	efectivo
2600	2026-02-09 20:54:47.744543	5.00	0.00	5.00	efectivo
2601	2026-02-10 17:08:13.585258	5.00	0.00	5.00	efectivo
2602	2026-02-10 17:39:27.978823	20.00	0.00	20.00	efectivo
2603	2026-02-10 17:41:38.918725	22.00	0.00	22.00	efectivo
2604	2026-02-10 17:42:08.829099	80.00	0.00	80.00	efectivo
2605	2026-02-10 17:53:17.498255	12.50	0.00	12.50	efectivo
2606	2026-02-10 18:03:39.873361	30.50	0.00	30.50	efectivo
2607	2026-02-10 18:03:59.048557	17.00	0.00	17.00	efectivo
2608	2026-02-10 18:24:11.266603	21.00	0.00	21.00	efectivo
2609	2026-02-10 18:24:42.292316	60.00	0.00	60.00	efectivo
2610	2026-02-10 18:39:21.086615	509.00	0.00	509.00	efectivo
2611	2026-02-10 18:40:35.391106	36.00	0.00	36.00	efectivo
2612	2026-02-10 18:41:06.499698	54.00	0.00	54.00	efectivo
2613	2026-02-10 18:41:47.521874	29.00	0.00	29.00	efectivo
2614	2026-02-10 18:48:30.707792	85.00	0.00	85.00	efectivo
2615	2026-02-10 18:59:41.151458	13.00	0.00	13.00	efectivo
2616	2026-02-10 19:01:51.026369	30.00	0.00	30.00	efectivo
2617	2026-02-10 19:03:26.78605	110.00	0.00	110.00	efectivo
2618	2026-02-10 19:06:30.542691	94.50	0.00	94.50	efectivo
2619	2026-02-10 19:36:41.894387	120.00	0.00	120.00	efectivo
2620	2026-02-10 20:19:38.193052	30.00	0.00	30.00	efectivo
2621	2026-02-10 20:26:24.919103	11.50	0.00	11.50	efectivo
2622	2026-02-10 20:29:46.230914	84.50	0.00	84.50	efectivo
2623	2026-02-10 20:42:57.878127	12.00	0.00	12.00	efectivo
2624	2026-02-10 20:46:02.07708	14.00	0.00	14.00	efectivo
2625	2026-02-10 20:53:57.062335	40.00	0.00	40.00	efectivo
2626	2026-02-10 20:55:58.343195	36.00	0.00	36.00	efectivo
2627	2026-02-10 20:56:27.652086	15.00	0.00	15.00	efectivo
2628	2026-02-11 16:18:57.350466	38.00	0.00	38.00	efectivo
2629	2026-02-11 16:19:06.890519	10.00	0.00	10.00	efectivo
2630	2026-02-11 17:03:55.168413	102.00	0.00	102.00	efectivo
2631	2026-02-11 17:11:23.179488	49.00	0.00	49.00	efectivo
2632	2026-02-11 17:11:40.240836	28.00	0.00	28.00	efectivo
2633	2026-02-11 17:12:42.283029	100.00	0.00	100.00	efectivo
2634	2026-02-11 17:14:36.744156	8.00	0.00	8.00	efectivo
2635	2026-02-11 17:14:56.685222	26.00	0.00	26.00	efectivo
2636	2026-02-11 17:18:43.806697	65.00	0.00	65.00	efectivo
2637	2026-02-11 17:53:06.192401	115.00	0.00	115.00	efectivo
2638	2026-02-11 17:54:28.515209	35.00	0.00	35.00	efectivo
2639	2026-02-11 17:57:12.062035	150.00	0.00	150.00	efectivo
2640	2026-02-11 18:07:24.315059	79.00	0.00	79.00	efectivo
2641	2026-02-11 18:19:45.700019	56.00	0.00	56.00	efectivo
2642	2026-02-11 18:20:39.606925	30.00	0.00	30.00	efectivo
2643	2026-02-11 18:23:11.820879	15.00	0.00	15.00	efectivo
2644	2026-02-11 18:32:24.649175	139.00	0.00	139.00	efectivo
2645	2026-02-11 18:33:06.343773	62.00	0.00	62.00	efectivo
2646	2026-02-11 18:36:45.75723	84.00	0.00	84.00	efectivo
2647	2026-02-11 19:06:04.762211	22.00	0.00	22.00	efectivo
2648	2026-02-11 19:08:24.070715	9.00	0.00	9.00	efectivo
2649	2026-02-11 19:09:52.525382	28.00	0.00	28.00	efectivo
2650	2026-02-11 19:13:18.771301	30.00	0.00	30.00	efectivo
2651	2026-02-11 19:14:40.531024	39.50	0.00	39.50	efectivo
2652	2026-02-11 19:27:06.312034	32.00	0.00	32.00	efectivo
2653	2026-02-11 19:29:22.201754	21.00	0.00	21.00	efectivo
2654	2026-02-11 19:50:17.213683	64.00	0.00	64.00	efectivo
2655	2026-02-11 19:51:22.034664	8.00	0.00	8.00	efectivo
2656	2026-02-11 19:52:39.710541	24.00	0.00	24.00	efectivo
2657	2026-02-11 20:08:12.671952	7.50	0.00	7.50	efectivo
2658	2026-02-11 20:08:44.735277	8.00	0.00	8.00	efectivo
2659	2026-02-11 20:09:19.726005	9.00	0.00	9.00	efectivo
2660	2026-02-11 20:12:37.65447	4.00	0.00	4.00	efectivo
2661	2026-02-11 20:17:36.463954	45.00	0.00	45.00	efectivo
2662	2026-02-11 20:24:12.360874	50.00	0.00	50.00	efectivo
2663	2026-02-11 20:27:10.859018	4.50	0.00	4.50	efectivo
2664	2026-02-11 20:27:47.400552	8.00	0.00	8.00	efectivo
2665	2026-02-11 20:30:53.450108	112.00	0.00	112.00	efectivo
2666	2026-02-11 20:32:16.276367	31.00	0.00	31.00	efectivo
2667	2026-02-11 20:32:44.623083	4.00	0.00	4.00	efectivo
2668	2026-02-11 20:47:48.933695	87.00	0.00	87.00	efectivo
2669	2026-02-11 20:56:34.846754	40.00	0.00	40.00	efectivo
2670	2026-02-11 21:36:10.025884	81.00	0.00	81.00	efectivo
2671	2026-02-11 21:37:51.110142	16.00	0.00	16.00	efectivo
2672	2026-02-12 16:42:40.861013	30.00	0.00	30.00	efectivo
2673	2026-02-12 16:42:49.668704	6.00	0.00	6.00	efectivo
2674	2026-02-12 16:45:11.399129	12.00	0.00	12.00	efectivo
2675	2026-02-12 16:45:43.322558	70.00	0.00	70.00	efectivo
2676	2026-02-12 16:51:28.741875	75.00	0.00	75.00	efectivo
2677	2026-02-12 17:36:09.39991	22.50	0.00	22.50	efectivo
2678	2026-02-12 17:37:16.593401	104.00	0.00	104.00	efectivo
2679	2026-02-12 17:37:34.064781	57.00	0.00	57.00	efectivo
2680	2026-02-12 18:01:44.538478	15.00	0.00	15.00	efectivo
2681	2026-02-12 18:03:12.110053	8.00	0.00	8.00	efectivo
2682	2026-02-12 18:09:32.880054	58.00	0.00	58.00	efectivo
2683	2026-02-12 18:10:58.855826	14.00	0.00	14.00	efectivo
2684	2026-02-12 18:15:57.720873	8.00	0.00	8.00	efectivo
2685	2026-02-12 18:16:06.050674	12.00	0.00	12.00	efectivo
2686	2026-02-12 18:18:33.540496	22.50	0.00	22.50	efectivo
2687	2026-02-12 18:21:49.464818	22.50	0.00	22.50	efectivo
2688	2026-02-12 18:21:56.982033	16.00	0.00	16.00	efectivo
2689	2026-02-12 18:26:05.164234	30.00	0.00	30.00	efectivo
2690	2026-02-12 18:27:08.909449	53.00	0.00	53.00	efectivo
2691	2026-02-12 18:29:09.822217	32.50	0.00	32.50	efectivo
2692	2026-02-12 18:32:28.343649	12.00	0.00	12.00	efectivo
2693	2026-02-12 18:34:34.073405	48.00	0.00	48.00	efectivo
2694	2026-02-12 18:42:17.244917	68.00	0.00	68.00	efectivo
2695	2026-02-12 18:42:34.729646	28.00	0.00	28.00	efectivo
2696	2026-02-12 18:42:57.824278	10.00	0.00	10.00	efectivo
2697	2026-02-12 18:59:38.239385	434.00	0.00	434.00	efectivo
2698	2026-02-12 19:01:04.384052	18.50	0.00	18.50	efectivo
2699	2026-02-12 19:05:37.136157	25.00	0.00	25.00	efectivo
2700	2026-02-12 19:08:58.459671	100.00	0.00	100.00	efectivo
2701	2026-02-12 19:14:22.062886	37.00	0.00	37.00	efectivo
2702	2026-02-12 19:25:34.968578	110.00	0.00	110.00	efectivo
2703	2026-02-12 19:34:06.17787	145.00	0.00	145.00	efectivo
2704	2026-02-12 19:38:54.673441	144.00	0.00	144.00	efectivo
2705	2026-02-12 20:05:30.861987	75.00	0.00	75.00	efectivo
2706	2026-02-12 20:13:07.947876	44.00	0.00	44.00	efectivo
2707	2026-02-12 20:31:52.987613	15.00	0.00	15.00	efectivo
2708	2026-02-12 20:36:43.068864	58.00	0.00	58.00	efectivo
2709	2026-02-12 20:46:26.314987	127.00	0.00	127.00	efectivo
2710	2026-02-12 20:49:27.751597	7.50	0.00	7.50	efectivo
2711	2026-02-13 22:49:07.319595	256.00	0.00	256.00	efectivo
2712	2026-02-14 16:31:49.825604	57.00	0.00	57.00	efectivo
2713	2026-02-14 16:32:53.07075	94.00	0.00	94.00	efectivo
2714	2026-02-14 16:33:17.450348	22.00	0.00	22.00	efectivo
2715	2026-02-14 16:43:42.521409	4.00	0.00	4.00	efectivo
2716	2026-02-14 16:51:34.26388	43.00	0.00	43.00	efectivo
2717	2026-02-14 17:06:20.363107	93.00	0.00	93.00	efectivo
2718	2026-02-14 17:07:07.506122	4.00	0.00	4.00	efectivo
2719	2026-02-14 17:52:55.699761	15.00	0.00	15.00	efectivo
2720	2026-02-14 18:28:36.857257	30.00	0.00	30.00	efectivo
2721	2026-02-14 18:38:12.984107	77.50	0.00	77.50	efectivo
2722	2026-02-16 16:20:28.304628	9.00	0.00	9.00	efectivo
2723	2026-02-16 17:31:46.961602	13.00	0.00	13.00	efectivo
2724	2026-02-16 17:47:16.381354	99.00	0.00	99.00	efectivo
2725	2026-02-16 17:52:48.065013	30.00	0.00	30.00	efectivo
2726	2026-02-16 18:02:54.393139	35.00	0.00	35.00	efectivo
2727	2026-02-16 18:05:08.043206	6.00	0.00	6.00	efectivo
2728	2026-02-16 18:09:30.428196	6.00	0.00	6.00	efectivo
2729	2026-02-16 18:17:48.492428	27.00	0.00	27.00	efectivo
2730	2026-02-16 18:21:58.777858	35.00	0.00	35.00	efectivo
2731	2026-02-16 18:24:11.285594	55.00	0.00	55.00	efectivo
2732	2026-02-16 18:35:08.767429	47.00	0.00	47.00	efectivo
2733	2026-02-16 18:36:57.257939	2.50	0.00	2.50	efectivo
2734	2026-02-16 18:41:56.864688	23.00	0.00	23.00	efectivo
2735	2026-02-16 18:46:31.764747	6.50	0.00	6.50	efectivo
2736	2026-02-16 18:48:22.956392	10.00	0.00	10.00	efectivo
2737	2026-02-16 18:48:54.320338	2.00	0.00	2.00	efectivo
2738	2026-02-16 18:57:58.960311	22.00	0.00	22.00	efectivo
2739	2026-02-16 19:06:08.465663	109.00	0.00	109.00	efectivo
2740	2026-02-16 19:33:48.561929	33.00	0.00	33.00	efectivo
2741	2026-02-16 19:39:32.961534	7.00	0.00	7.00	efectivo
2742	2026-02-16 19:46:56.951841	8.00	0.00	8.00	efectivo
2743	2026-02-16 19:51:06.467635	50.00	0.00	50.00	efectivo
2744	2026-02-16 20:16:09.791222	30.00	0.00	30.00	efectivo
2745	2026-02-16 20:21:05.849081	8.00	0.00	8.00	efectivo
2746	2026-02-16 20:36:03.032117	107.00	0.00	107.00	efectivo
2747	2026-02-17 15:28:50.216199	60.00	0.00	60.00	efectivo
2748	2026-02-17 15:29:09.310181	33.00	0.00	33.00	efectivo
2749	2026-02-17 16:19:35.440657	37.00	0.00	37.00	efectivo
2750	2026-02-17 16:19:45.950734	12.00	0.00	12.00	efectivo
2751	2026-02-17 16:20:22.128618	29.00	0.00	29.00	efectivo
2752	2026-02-17 16:45:23.142307	19.00	0.00	19.00	efectivo
2753	2026-02-17 16:52:54.024483	31.00	0.00	31.00	efectivo
2754	2026-02-17 16:53:42.8126	52.00	0.00	52.00	efectivo
2755	2026-02-17 16:55:21.868554	22.00	0.00	22.00	efectivo
2756	2026-02-17 16:56:59.33938	6.00	0.00	6.00	efectivo
2757	2026-02-17 17:34:13.306688	150.00	0.00	150.00	efectivo
2758	2026-02-17 17:41:31.020312	135.00	0.00	135.00	efectivo
2759	2026-02-17 18:04:16.983803	6.00	0.00	6.00	efectivo
2760	2026-02-17 18:17:57.368396	23.00	0.00	23.00	efectivo
2761	2026-02-17 18:20:39.97313	25.00	0.00	25.00	efectivo
2762	2026-02-17 18:38:46.101351	17.00	0.00	17.00	efectivo
2763	2026-02-17 18:43:21.107279	71.00	0.00	71.00	efectivo
2764	2026-02-17 18:52:38.985466	37.00	0.00	37.00	efectivo
2765	2026-02-17 18:52:45.55174	5.00	0.00	5.00	efectivo
2766	2026-02-17 18:56:26.839455	10.00	0.00	10.00	efectivo
2767	2026-02-17 18:56:53.232103	220.00	0.00	220.00	efectivo
2768	2026-02-17 19:01:01.795825	20.00	0.00	20.00	efectivo
2769	2026-02-17 19:04:21.505112	7.00	0.00	7.00	efectivo
2770	2026-02-17 19:07:10.122866	19.00	0.00	19.00	efectivo
2771	2026-02-17 19:13:32.750846	41.00	0.00	41.00	efectivo
2772	2026-02-17 19:17:49.979871	30.00	0.00	30.00	efectivo
2773	2026-02-17 19:22:36.670127	53.00	0.00	53.00	efectivo
2774	2026-02-17 19:26:23.791249	57.00	0.00	57.00	efectivo
2775	2026-02-17 19:29:16.643925	12.00	0.00	12.00	efectivo
2776	2026-02-17 19:32:28.574378	15.00	0.00	15.00	efectivo
2777	2026-02-17 19:52:24.005717	8.00	0.00	8.00	efectivo
2778	2026-02-17 19:54:00.717481	15.00	0.00	15.00	efectivo
2779	2026-02-17 20:01:34.699297	29.00	0.00	29.00	efectivo
2780	2026-02-17 20:05:08.836455	25.00	0.00	25.00	efectivo
2781	2026-02-17 20:05:30.812096	72.00	0.00	72.00	efectivo
2782	2026-02-17 20:12:53.802948	31.00	0.00	31.00	efectivo
2783	2026-02-17 20:23:13.163518	40.00	0.00	40.00	efectivo
2784	2026-02-17 20:25:59.616698	34.00	0.00	34.00	efectivo
2785	2026-02-17 20:28:15.360316	47.50	0.00	47.50	efectivo
2786	2026-02-17 20:43:09.278526	8.50	0.00	8.50	efectivo
2787	2026-02-17 21:10:19.398188	57.00	0.00	57.00	efectivo
2788	2026-02-17 21:13:24.781384	81.00	0.00	81.00	efectivo
2789	2026-02-18 15:51:49.991404	37.00	0.00	37.00	efectivo
2790	2026-02-18 15:53:34.134024	36.00	0.00	36.00	efectivo
2791	2026-02-18 16:17:21.032287	17.50	0.00	17.50	efectivo
2792	2026-02-18 16:18:35.220983	6.00	0.00	6.00	efectivo
2793	2026-02-18 16:21:05.829964	15.00	0.00	15.00	efectivo
2794	2026-02-18 16:32:19.756957	28.00	0.00	28.00	efectivo
2795	2026-02-18 16:36:14.998693	7.00	0.00	7.00	efectivo
2796	2026-02-18 16:39:38.637674	15.00	0.00	15.00	efectivo
2797	2026-02-18 16:58:03.762254	20.00	0.00	20.00	efectivo
2798	2026-02-18 17:24:45.745572	32.00	0.00	32.00	efectivo
2799	2026-02-18 18:37:43.271127	20.00	0.00	20.00	efectivo
2800	2026-02-18 18:46:32.468404	6.00	0.00	6.00	efectivo
2801	2026-02-18 18:57:51.734191	32.50	0.00	32.50	efectivo
2802	2026-02-18 19:00:27.969037	31.00	0.00	31.00	efectivo
2803	2026-02-18 19:18:31.786226	9.00	0.00	9.00	efectivo
2804	2026-02-18 19:28:24.66769	52.00	0.00	52.00	efectivo
2805	2026-02-18 19:39:50.91376	21.00	0.00	21.00	efectivo
2806	2026-02-18 19:47:36.361391	2.50	0.00	2.50	efectivo
2807	2026-02-18 20:01:10.088198	119.00	0.00	119.00	efectivo
2808	2026-02-18 20:02:57.377513	35.00	0.00	35.00	efectivo
2809	2026-02-18 20:17:03.628741	38.00	0.00	38.00	efectivo
2810	2026-02-18 20:38:19.137804	30.00	0.00	30.00	efectivo
2811	2026-02-19 15:59:46.01941	15.00	0.00	15.00	efectivo
2812	2026-02-19 15:59:52.686038	12.50	0.00	12.50	efectivo
2813	2026-02-19 16:00:21.919244	4.00	0.00	4.00	efectivo
2814	2026-02-19 16:47:07.100269	26.00	0.00	26.00	efectivo
2815	2026-02-19 17:00:52.945755	6.00	0.00	6.00	efectivo
2816	2026-02-19 17:13:53.27947	36.00	0.00	36.00	efectivo
2817	2026-02-19 17:36:52.117641	47.00	0.00	47.00	efectivo
2818	2026-02-19 18:31:44.465185	6.00	0.00	6.00	efectivo
2819	2026-02-19 18:42:07.540772	3.00	0.00	3.00	efectivo
2820	2026-02-19 18:51:01.771587	7.00	0.00	7.00	efectivo
2821	2026-02-19 18:54:57.087005	53.00	0.00	53.00	efectivo
2822	2026-02-19 19:00:00.280604	29.00	0.00	29.00	efectivo
2823	2026-02-19 19:01:25.709084	1.00	0.00	1.00	efectivo
2824	2026-02-19 19:23:45.140199	47.00	0.00	47.00	efectivo
2825	2026-02-19 19:27:16.654286	18.00	0.00	18.00	efectivo
2826	2026-02-19 19:29:58.459741	7.50	0.00	7.50	efectivo
2827	2026-02-19 19:48:27.130284	124.00	0.00	124.00	efectivo
2828	2026-02-19 19:54:31.909124	51.00	0.00	51.00	efectivo
2829	2026-02-19 19:55:36.291316	30.00	0.00	30.00	efectivo
2830	2026-02-19 20:19:26.95723	100.00	0.00	100.00	efectivo
2831	2026-02-19 20:29:10.259714	64.00	0.00	64.00	efectivo
2832	2026-02-19 20:31:56.563533	14.00	0.00	14.00	efectivo
2833	2026-02-19 21:03:39.641877	35.00	0.00	35.00	efectivo
2834	2026-02-20 16:07:19.941497	89.00	0.00	89.00	efectivo
2835	2026-02-20 16:10:31.992015	27.00	0.00	27.00	efectivo
2836	2026-02-20 16:19:41.598176	40.00	0.00	40.00	efectivo
2837	2026-02-20 17:11:10.237392	29.00	0.00	29.00	efectivo
2838	2026-02-20 17:17:19.224722	39.00	0.00	39.00	efectivo
2839	2026-02-20 17:30:22.611019	88.00	0.00	88.00	efectivo
2840	2026-02-20 17:35:07.650415	10.00	0.00	10.00	efectivo
2841	2026-02-20 17:35:20.016312	42.00	0.00	42.00	efectivo
2842	2026-02-20 17:40:13.318828	22.00	0.00	22.00	efectivo
2843	2026-02-20 17:47:43.699401	6.00	0.00	6.00	efectivo
2844	2026-02-20 17:50:14.29227	33.00	0.00	33.00	efectivo
2845	2026-02-20 18:08:47.601526	56.00	0.00	56.00	efectivo
2846	2026-02-20 18:09:27.787107	8.00	0.00	8.00	efectivo
2847	2026-02-20 18:11:16.591779	15.00	0.00	15.00	efectivo
2848	2026-02-20 18:44:50.818476	35.00	0.00	35.00	efectivo
2849	2026-02-20 18:50:24.556344	99.00	0.00	99.00	efectivo
2850	2026-02-20 18:51:29.55578	30.00	0.00	30.00	efectivo
2851	2026-02-20 18:53:13.910818	13.00	0.00	13.00	efectivo
2852	2026-02-20 19:02:35.916456	8.00	0.00	8.00	efectivo
2853	2026-02-20 19:03:35.32333	14.00	0.00	14.00	efectivo
2854	2026-02-20 19:20:04.986575	4.00	0.00	4.00	efectivo
2855	2026-02-20 19:22:21.829068	33.00	0.00	33.00	efectivo
2856	2026-02-20 20:15:30.844308	30.00	0.00	30.00	efectivo
2857	2026-02-20 20:16:31.954156	18.00	0.00	18.00	efectivo
2858	2026-02-24 17:05:16.115943	4.00	0.00	4.00	efectivo
2859	2026-02-24 17:05:19.005457	10.00	0.00	10.00	efectivo
2860	2026-02-24 17:05:22.310751	10.00	0.00	10.00	efectivo
2861	2026-02-24 17:16:28.979784	13.00	0.00	13.00	efectivo
2862	2026-02-24 17:16:34.662602	22.00	0.00	22.00	efectivo
2863	2026-02-24 17:24:04.618739	15.00	0.00	15.00	efectivo
2864	2026-02-24 17:34:12.006961	84.00	0.00	84.00	efectivo
2865	2026-02-24 17:52:48.492263	26.50	0.00	26.50	efectivo
2866	2026-02-24 17:53:30.648754	25.00	0.00	25.00	efectivo
2867	2026-02-24 18:34:39.651413	25.00	0.00	25.00	efectivo
2868	2026-02-24 18:35:52.369698	120.00	0.00	120.00	efectivo
2869	2026-02-24 18:38:04.144443	20.00	0.00	20.00	efectivo
2870	2026-02-24 18:40:05.93897	14.00	0.00	14.00	efectivo
2871	2026-02-24 18:56:22.348438	52.00	0.00	52.00	efectivo
2872	2026-02-24 19:14:33.697666	133.00	0.00	133.00	efectivo
2873	2026-02-24 19:27:10.4049	55.00	0.00	55.00	efectivo
2874	2026-02-24 19:28:10.707801	44.00	0.00	44.00	efectivo
2875	2026-02-24 20:00:55.325464	18.00	0.00	18.00	efectivo
2876	2026-02-24 20:06:33.096969	6.00	0.00	6.00	efectivo
2877	2026-02-24 20:10:20.039153	36.00	0.00	36.00	efectivo
2878	2026-02-24 20:24:06.044389	8.00	0.00	8.00	efectivo
2879	2026-02-25 16:10:25.584877	63.00	0.00	63.00	efectivo
2880	2026-02-25 16:28:46.898122	186.50	0.00	186.50	efectivo
2881	2026-02-25 16:46:24.403976	20.00	0.00	20.00	efectivo
2882	2026-02-25 17:33:32.982603	75.00	0.00	75.00	efectivo
2883	2026-02-25 17:34:03.371849	11.00	0.00	11.00	efectivo
2884	2026-02-25 17:37:00.311662	12.00	0.00	12.00	efectivo
2885	2026-02-25 17:43:05.609824	60.00	0.00	60.00	efectivo
2886	2026-02-25 17:48:03.083293	29.00	0.00	29.00	efectivo
2887	2026-02-25 17:57:21.049714	4.00	0.00	4.00	efectivo
2888	2026-02-25 18:30:22.394694	36.00	0.00	36.00	efectivo
2889	2026-02-25 18:50:46.155337	17.00	0.00	17.00	efectivo
2890	2026-02-25 18:57:12.361219	13.00	0.00	13.00	efectivo
2891	2026-02-25 19:13:28.003712	7.00	0.00	7.00	efectivo
2892	2026-02-25 19:16:37.819978	20.00	0.00	20.00	efectivo
2893	2026-02-25 19:21:07.365604	8.50	0.00	8.50	efectivo
2894	2026-02-25 20:09:51.178322	21.00	0.00	21.00	efectivo
2895	2026-02-25 20:18:53.556773	21.00	0.00	21.00	efectivo
2896	2026-02-25 20:19:47.016912	21.50	0.00	21.50	efectivo
2897	2026-02-25 21:00:01.196964	65.00	0.00	65.00	efectivo
2898	2026-02-26 16:54:37.862562	66.00	0.00	66.00	efectivo
2899	2026-02-26 16:54:45.769953	8.00	0.00	8.00	efectivo
2900	2026-02-26 17:53:35.051891	35.00	0.00	35.00	efectivo
2901	2026-02-26 18:34:55.166922	25.00	0.00	25.00	efectivo
2902	2026-02-26 19:08:09.316262	35.00	0.00	35.00	efectivo
2903	2026-02-26 19:23:45.648336	17.00	0.00	17.00	efectivo
2904	2026-02-26 19:28:53.274833	36.00	0.00	36.00	efectivo
2905	2026-02-26 19:44:22.496802	4.00	0.00	4.00	efectivo
2906	2026-02-26 20:18:34.680449	75.00	0.00	75.00	efectivo
2907	2026-02-26 21:20:55.704329	87.50	0.00	87.50	efectivo
2908	2026-02-27 15:42:38.272722	16.00	0.00	16.00	efectivo
2909	2026-02-27 15:51:46.231545	95.00	0.00	95.00	efectivo
2910	2026-02-27 17:11:34.411904	37.00	0.00	37.00	efectivo
2911	2026-02-27 17:40:44.949755	20.00	0.00	20.00	efectivo
2912	2026-02-27 17:40:50.866972	29.00	0.00	29.00	efectivo
2913	2026-02-27 18:02:36.667498	45.00	0.00	45.00	efectivo
2914	2026-02-27 18:02:50.486969	95.00	0.00	95.00	efectivo
2915	2026-02-27 18:34:53.493882	44.00	0.00	44.00	efectivo
2916	2026-02-27 18:36:07.340806	7.00	0.00	7.00	efectivo
2917	2026-02-27 19:11:53.328373	2.00	0.00	2.00	efectivo
2918	2026-02-27 19:45:18.190696	34.00	0.00	34.00	efectivo
2919	2026-02-27 19:50:05.929086	17.00	0.00	17.00	efectivo
2920	2026-02-28 15:44:18.083023	25.00	0.00	25.00	efectivo
2921	2026-02-28 15:44:55.063063	20.00	0.00	20.00	efectivo
2922	2026-02-28 16:02:45.769385	50.00	0.00	50.00	efectivo
2923	2026-02-28 16:14:00.717046	10.00	0.00	10.00	efectivo
2924	2026-02-28 17:41:37.791588	90.00	0.00	90.00	efectivo
2925	2026-02-28 18:18:32.378181	12.00	0.00	12.00	efectivo
2926	2026-02-28 18:21:14.157764	53.00	0.00	53.00	efectivo
2927	2026-03-02 16:36:42.461661	23.00	0.00	23.00	efectivo
2928	2026-03-02 17:09:29.988856	53.00	0.00	53.00	efectivo
2929	2026-03-02 17:11:09.7925	10.00	0.00	10.00	efectivo
2930	2026-03-02 17:12:40.616574	42.00	0.00	42.00	efectivo
2931	2026-03-02 17:18:06.758581	15.00	0.00	15.00	efectivo
2932	2026-03-02 17:41:41.729127	14.00	0.00	14.00	efectivo
2933	2026-03-02 18:17:10.839714	304.00	0.00	304.00	efectivo
2934	2026-03-02 18:24:30.639526	39.00	0.00	39.00	efectivo
2935	2026-03-02 18:33:54.283267	60.00	0.00	60.00	efectivo
2936	2026-03-02 18:44:22.479746	103.50	0.00	103.50	efectivo
2937	2026-03-02 18:45:51.821064	10.00	0.00	10.00	efectivo
2938	2026-03-02 18:47:54.234398	90.00	0.00	90.00	efectivo
2939	2026-03-02 18:52:55.966067	10.00	0.00	10.00	efectivo
2940	2026-03-02 18:58:58.176301	14.00	0.00	14.00	efectivo
2941	2026-03-02 19:00:56.160046	55.00	0.00	55.00	efectivo
2942	2026-03-02 19:10:12.89815	17.00	0.00	17.00	efectivo
2943	2026-03-02 19:10:21.744485	35.00	0.00	35.00	efectivo
2944	2026-03-02 19:12:08.151154	70.00	0.00	70.00	efectivo
2945	2026-03-02 19:31:19.968624	45.00	0.00	45.00	efectivo
2946	2026-03-02 19:32:20.57339	75.00	0.00	75.00	efectivo
2947	2026-03-02 19:44:09.663566	5.00	0.00	5.00	efectivo
2948	2026-03-02 19:49:50.651023	6.00	0.00	6.00	efectivo
2949	2026-03-02 19:50:05.049044	35.00	0.00	35.00	efectivo
2950	2026-03-02 20:54:09.377306	17.00	0.00	17.00	efectivo
2951	2026-03-02 20:57:41.783506	35.00	0.00	35.00	efectivo
2952	2026-03-02 20:57:50.407133	35.00	0.00	35.00	efectivo
2953	2026-03-03 16:08:46.865201	170.00	0.00	170.00	efectivo
2954	2026-03-03 16:31:20.573517	20.00	0.00	20.00	efectivo
2955	2026-03-03 16:46:55.282512	51.00	0.00	51.00	efectivo
2956	2026-03-03 17:13:37.718041	90.00	0.00	90.00	efectivo
2957	2026-03-03 17:13:47.340391	25.00	0.00	25.00	efectivo
2958	2026-03-03 17:25:54.65148	35.00	0.00	35.00	efectivo
2959	2026-03-03 17:53:00.569572	52.00	0.00	52.00	efectivo
2960	2026-03-03 18:09:30.55846	12.00	0.00	12.00	efectivo
2961	2026-03-03 18:11:10.68122	90.00	0.00	90.00	efectivo
2962	2026-03-03 18:12:08.215336	10.00	0.00	10.00	efectivo
2963	2026-03-03 18:20:58.938645	21.00	0.00	21.00	efectivo
2964	2026-03-03 18:54:18.384885	159.00	0.00	159.00	efectivo
2965	2026-03-03 18:56:53.51518	143.00	0.00	143.00	efectivo
2966	2026-03-03 19:02:21.523263	231.00	0.00	231.00	efectivo
2967	2026-03-03 19:10:03.774579	57.00	0.00	57.00	efectivo
2968	2026-03-03 19:19:43.005531	95.00	0.00	95.00	efectivo
2969	2026-03-03 19:32:20.646298	40.00	0.00	40.00	efectivo
2970	2026-03-03 20:39:14.716323	28.50	0.00	28.50	efectivo
2971	2026-03-03 20:52:43.794428	62.50	0.00	62.50	efectivo
2972	2026-03-03 20:53:48.973105	2.00	0.00	2.00	efectivo
2973	2026-03-04 16:54:24.116313	94.00	0.00	94.00	efectivo
2974	2026-03-04 16:54:36.985433	60.00	0.00	60.00	efectivo
2975	2026-03-04 17:03:37.338378	7.50	0.00	7.50	efectivo
2976	2026-03-04 17:15:47.956134	7.00	0.00	7.00	efectivo
2977	2026-03-04 17:47:18.325187	23.00	0.00	23.00	efectivo
2978	2026-03-04 17:55:26.736222	52.00	0.00	52.00	efectivo
2979	2026-03-04 17:59:19.308667	12.00	0.00	12.00	efectivo
2980	2026-03-04 18:04:03.256556	67.00	0.00	67.00	efectivo
2981	2026-03-04 18:04:37.351196	7.00	0.00	7.00	efectivo
2982	2026-03-04 18:11:03.580385	20.00	0.00	20.00	efectivo
2983	2026-03-04 18:37:31.527766	24.00	0.00	24.00	efectivo
2984	2026-03-04 18:38:47.522276	21.00	0.00	21.00	efectivo
2985	2026-03-04 18:51:12.400407	50.00	0.00	50.00	efectivo
2986	2026-03-04 19:15:36.184643	12.00	0.00	12.00	efectivo
2987	2026-03-04 19:45:49.45992	30.00	0.00	30.00	efectivo
2988	2026-03-04 19:46:43.763173	70.00	0.00	70.00	efectivo
2989	2026-03-04 19:58:54.552414	65.00	0.00	65.00	efectivo
2990	2026-03-04 19:59:21.293506	12.00	0.00	12.00	efectivo
2991	2026-03-04 20:08:34.136224	14.00	0.00	14.00	efectivo
2992	2026-03-04 20:20:20.353126	9.00	0.00	9.00	efectivo
2993	2026-03-04 20:32:11.760386	60.00	0.00	60.00	efectivo
2994	2026-03-04 20:35:56.808283	57.00	0.00	57.00	efectivo
2995	2026-03-04 21:08:02.302254	5.00	0.00	5.00	efectivo
2996	2026-03-05 16:35:05.624729	45.00	0.00	45.00	efectivo
2997	2026-03-05 16:38:59.174079	83.00	0.00	83.00	efectivo
2998	2026-03-05 16:40:28.792628	13.00	0.00	13.00	efectivo
2999	2026-03-05 17:18:12.975083	58.00	0.00	58.00	efectivo
3000	2026-03-05 17:33:05.005641	40.00	0.00	40.00	efectivo
3001	2026-03-05 18:01:25.847881	19.00	0.00	19.00	efectivo
3002	2026-03-05 18:08:58.082874	53.50	0.00	53.50	efectivo
3003	2026-03-05 18:14:46.413135	23.00	0.00	23.00	efectivo
3004	2026-03-05 18:36:30.293263	103.00	0.00	103.00	efectivo
3005	2026-03-05 18:38:10.539486	12.00	0.00	12.00	efectivo
3006	2026-03-05 18:47:54.546337	9.00	0.00	9.00	efectivo
3007	2026-03-05 19:02:05.303049	29.00	0.00	29.00	efectivo
3008	2026-03-05 19:03:12.502476	95.00	0.00	95.00	efectivo
3009	2026-03-05 19:10:02.681716	22.00	0.00	22.00	efectivo
3010	2026-03-05 19:17:15.376043	42.00	0.00	42.00	efectivo
3011	2026-03-05 19:17:23.995004	10.00	0.00	10.00	efectivo
3012	2026-03-05 19:28:23.644137	40.00	0.00	40.00	efectivo
3013	2026-03-05 19:30:45.858951	15.00	0.00	15.00	efectivo
3014	2026-03-05 19:31:24.217124	7.00	0.00	7.00	efectivo
3015	2026-03-05 19:32:40.85927	18.00	0.00	18.00	efectivo
3016	2026-03-05 19:41:50.595196	7.00	0.00	7.00	efectivo
3017	2026-03-05 19:47:53.792018	30.00	0.00	30.00	efectivo
3018	2026-03-05 19:48:52.14702	17.00	0.00	17.00	efectivo
3019	2026-03-05 19:51:18.433539	77.00	0.00	77.00	efectivo
3020	2026-03-05 20:09:49.13066	38.00	0.00	38.00	efectivo
3021	2026-03-05 20:10:10.969828	8.50	0.00	8.50	efectivo
3022	2026-03-05 20:10:18.635506	30.00	0.00	30.00	efectivo
3023	2026-03-05 20:17:40.163831	125.50	0.00	125.50	efectivo
3024	2026-03-05 20:18:51.990216	15.00	0.00	15.00	efectivo
3025	2026-03-05 20:20:50.014212	109.00	0.00	109.00	efectivo
3026	2026-03-05 20:30:16.43893	46.50	0.00	46.50	efectivo
3027	2026-03-05 20:31:58.809519	48.00	0.00	48.00	efectivo
3028	2026-03-05 20:33:29.102906	22.00	0.00	22.00	efectivo
3029	2026-03-05 20:38:15.183353	132.00	0.00	132.00	efectivo
3030	2026-03-06 16:51:31.789762	16.00	0.00	16.00	efectivo
3031	2026-03-06 17:19:52.188184	30.00	0.00	30.00	efectivo
3032	2026-03-06 17:43:27.120833	22.00	0.00	22.00	efectivo
3033	2026-03-06 17:44:57.664841	121.00	0.00	121.00	efectivo
3034	2026-03-06 17:46:34.170255	45.00	0.00	45.00	efectivo
3035	2026-03-06 17:53:58.348989	15.00	0.00	15.00	efectivo
3036	2026-03-06 18:28:08.970164	99.00	0.00	99.00	efectivo
3037	2026-03-06 19:51:36.226204	156.00	0.00	156.00	efectivo
3038	2026-03-09 15:34:08.688258	4.00	0.00	4.00	efectivo
3039	2026-03-09 15:34:16.721949	17.00	0.00	17.00	efectivo
3040	2026-03-09 15:34:28.171654	7.00	0.00	7.00	efectivo
3041	2026-03-09 15:44:51.218426	57.00	0.00	57.00	efectivo
3042	2026-03-09 15:58:26.014845	5.00	0.00	5.00	efectivo
3043	2026-03-09 16:06:12.336388	55.00	0.00	55.00	efectivo
3044	2026-03-09 16:17:50.790895	15.00	0.00	15.00	efectivo
3045	2026-03-09 16:18:58.308288	69.00	0.00	69.00	efectivo
3046	2026-03-09 16:23:51.956121	6.00	0.00	6.00	efectivo
3047	2026-03-09 16:37:58.55696	400.00	0.00	400.00	efectivo
3048	2026-03-09 16:57:08.366595	39.00	0.00	39.00	efectivo
3049	2026-03-09 17:02:35.631927	15.00	0.00	15.00	efectivo
3050	2026-03-09 17:03:43.296146	23.00	0.00	23.00	efectivo
3051	2026-03-09 17:28:17.535685	8.00	0.00	8.00	efectivo
3052	2026-03-09 17:28:49.381428	13.00	0.00	13.00	efectivo
3053	2026-03-09 17:32:02.005218	17.00	0.00	17.00	efectivo
3054	2026-03-09 17:49:21.573341	114.50	0.00	114.50	efectivo
3055	2026-03-09 18:27:08.001866	14.00	0.00	14.00	efectivo
3056	2026-03-09 18:27:26.117535	7.00	0.00	7.00	efectivo
3057	2026-03-09 18:28:32.128262	21.00	0.00	21.00	efectivo
3058	2026-03-09 18:49:24.946455	8.00	0.00	8.00	efectivo
3059	2026-03-09 18:49:32.753209	85.00	0.00	85.00	efectivo
3060	2026-03-09 18:57:59.646642	35.00	0.00	35.00	efectivo
3061	2026-03-09 19:02:50.67007	35.00	0.00	35.00	efectivo
3062	2026-03-09 19:06:39.523576	10.00	0.00	10.00	efectivo
3063	2026-03-09 19:16:02.237894	15.00	0.00	15.00	efectivo
3064	2026-03-09 19:20:23.071035	40.00	0.00	40.00	efectivo
3065	2026-03-09 19:25:39.900742	24.00	0.00	24.00	efectivo
3066	2026-03-09 19:32:14.238028	20.00	0.00	20.00	efectivo
3067	2026-03-09 19:38:28.217938	24.00	0.00	24.00	efectivo
3068	2026-03-09 19:56:24.878166	10.00	0.00	10.00	efectivo
3069	2026-03-10 15:50:58.128305	9.00	0.00	9.00	efectivo
3070	2026-03-10 15:52:42.961375	15.00	0.00	15.00	efectivo
3071	2026-03-10 16:35:38.519208	7.00	0.00	7.00	efectivo
3072	2026-03-10 16:38:10.145865	30.00	0.00	30.00	efectivo
3073	2026-03-10 16:41:49.266275	42.00	0.00	42.00	efectivo
3074	2026-03-10 17:20:17.170367	15.00	0.00	15.00	efectivo
3075	2026-03-10 17:37:13.344925	24.00	0.00	24.00	efectivo
3076	2026-03-10 18:32:41.102296	92.00	0.00	92.00	efectivo
3077	2026-03-10 18:36:52.940351	45.00	0.00	45.00	efectivo
3078	2026-03-10 18:39:00.812342	43.00	0.00	43.00	efectivo
3079	2026-03-10 18:39:58.518192	173.00	0.00	173.00	efectivo
3080	2026-03-10 18:54:46.063921	60.00	0.00	60.00	efectivo
3081	2026-03-10 19:07:41.094029	24.00	0.00	24.00	efectivo
3082	2026-03-10 19:13:14.627881	60.00	0.00	60.00	efectivo
3083	2026-03-10 19:15:10.69026	10.00	0.00	10.00	efectivo
3084	2026-03-10 19:37:33.650698	10.00	0.00	10.00	efectivo
3085	2026-03-10 19:55:13.638711	34.00	0.00	34.00	efectivo
3086	2026-03-10 19:56:23.184103	8.00	0.00	8.00	efectivo
3087	2026-03-10 19:57:37.282452	43.00	0.00	43.00	efectivo
3088	2026-03-10 19:58:16.415229	40.00	0.00	40.00	efectivo
3089	2026-03-11 16:44:49.205106	29.00	0.00	29.00	efectivo
3090	2026-03-11 16:45:53.275989	7.00	0.00	7.00	efectivo
3091	2026-03-11 18:17:00.95341	22.00	0.00	22.00	efectivo
3092	2026-03-11 18:18:57.333664	25.00	0.00	25.00	efectivo
3093	2026-03-11 18:23:23.632873	59.00	0.00	59.00	efectivo
3094	2026-03-11 18:26:13.101509	24.00	0.00	24.00	efectivo
3095	2026-03-11 19:03:11.917491	18.00	0.00	18.00	efectivo
3096	2026-03-11 19:03:18.928453	10.00	0.00	10.00	efectivo
3097	2026-03-11 19:25:13.794003	50.00	0.00	50.00	efectivo
3098	2026-03-11 19:25:15.85792	40.00	0.00	40.00	efectivo
3099	2026-03-11 19:45:12.692616	115.00	0.00	115.00	efectivo
3100	2026-03-11 19:53:47.048855	68.00	0.00	68.00	efectivo
3101	2026-03-11 19:54:11.739898	5.00	0.00	5.00	efectivo
3102	2026-03-11 19:58:39.297091	31.00	0.00	31.00	efectivo
3103	2026-03-11 20:11:54.183217	15.00	0.00	15.00	efectivo
3104	2026-03-11 20:18:09.626433	73.00	0.00	73.00	efectivo
3105	2026-03-11 20:18:25.868276	10.00	0.00	10.00	efectivo
3106	2026-03-11 20:22:49.536204	84.00	0.00	84.00	efectivo
3107	2026-03-11 20:23:47.461429	102.00	0.00	102.00	efectivo
3108	2026-03-11 20:26:59.74673	5.00	0.00	5.00	efectivo
3109	2026-03-11 20:27:06.635802	60.00	0.00	60.00	efectivo
3110	2026-03-11 20:30:28.023593	26.00	0.00	26.00	efectivo
3111	2026-03-11 21:01:16.994242	32.00	0.00	32.00	efectivo
3112	2026-03-12 15:55:55.554131	40.00	0.00	40.00	efectivo
3113	2026-03-12 18:10:42.203504	10.00	0.00	10.00	efectivo
3114	2026-03-12 18:10:49.632219	36.00	0.00	36.00	efectivo
3115	2026-03-12 18:23:38.280366	27.00	0.00	27.00	efectivo
3116	2026-03-12 18:23:44.933771	34.00	0.00	34.00	efectivo
3117	2026-03-12 18:23:54.502071	10.00	0.00	10.00	efectivo
3118	2026-03-12 18:34:43.180372	94.00	0.00	94.00	efectivo
3119	2026-03-12 18:47:30.110651	42.00	0.00	42.00	efectivo
3120	2026-03-12 18:50:48.258477	16.00	0.00	16.00	efectivo
3121	2026-03-12 18:53:56.313092	28.00	0.00	28.00	efectivo
3122	2026-03-12 19:09:44.193149	16.00	0.00	16.00	efectivo
3123	2026-03-12 19:18:47.123873	70.00	0.00	70.00	efectivo
3124	2026-03-12 20:00:59.521679	50.00	0.00	50.00	efectivo
3125	2026-03-12 20:13:18.568711	120.00	0.00	120.00	efectivo
3126	2026-03-12 21:02:39.521499	78.00	0.00	78.00	efectivo
3127	2026-03-13 17:32:55.071895	35.00	0.00	35.00	efectivo
3128	2026-03-13 17:33:43.928219	65.00	0.00	65.00	efectivo
3129	2026-03-13 17:42:33.550543	65.00	0.00	65.00	efectivo
3130	2026-03-13 18:15:48.162591	12.00	0.00	12.00	efectivo
3131	2026-03-13 18:53:52.371947	2.00	0.00	2.00	efectivo
3132	2026-03-13 18:54:54.354291	10.00	0.00	10.00	efectivo
3133	2026-03-13 19:23:28.809807	19.00	0.00	19.00	efectivo
3134	2026-03-13 19:43:46.936604	12.00	0.00	12.00	efectivo
3135	2026-03-16 16:25:29.558517	25.00	0.00	25.00	efectivo
3136	2026-03-16 16:28:30.420486	58.00	0.00	58.00	efectivo
3137	2026-03-16 16:28:44.680267	9.00	0.00	9.00	efectivo
3138	2026-03-16 17:37:37.550566	35.00	0.00	35.00	efectivo
3139	2026-03-16 18:26:05.720788	38.00	0.00	38.00	efectivo
3140	2026-03-16 18:28:53.197089	37.00	0.00	37.00	efectivo
3141	2026-03-16 19:26:35.3954	55.00	0.00	55.00	efectivo
3142	2026-03-16 20:04:43.066316	217.00	0.00	217.00	efectivo
3143	2026-03-16 20:08:48.613189	75.50	0.00	75.50	efectivo
3144	2026-03-17 17:15:23.698873	30.00	0.00	30.00	efectivo
3145	2026-03-17 17:19:27.735405	2.00	0.00	2.00	efectivo
3146	2026-03-17 17:33:06.559562	48.00	0.00	48.00	efectivo
3147	2026-03-17 17:37:16.053694	8.00	0.00	8.00	efectivo
3148	2026-03-17 17:40:38.280979	66.00	0.00	66.00	efectivo
3149	2026-03-17 17:52:36.668093	575.00	0.00	575.00	efectivo
3150	2026-03-17 18:07:02.552835	14.00	0.00	14.00	efectivo
3151	2026-03-17 18:07:30.324454	15.00	0.00	15.00	efectivo
3152	2026-03-17 18:07:48.185985	27.00	0.00	27.00	efectivo
3153	2026-03-17 18:08:56.088977	10.00	0.00	10.00	efectivo
3154	2026-03-17 18:24:55.007265	35.00	0.00	35.00	efectivo
3155	2026-03-17 18:32:59.594292	100.00	0.00	100.00	efectivo
3156	2026-03-17 18:36:41.133657	87.00	0.00	87.00	efectivo
3157	2026-03-17 18:36:53.772124	37.00	0.00	37.00	efectivo
3158	2026-03-17 18:42:56.523608	52.00	0.00	52.00	efectivo
3159	2026-03-17 18:43:00.045632	4.00	0.00	4.00	efectivo
3160	2026-03-17 18:45:50.952245	15.00	0.00	15.00	efectivo
3161	2026-03-17 19:07:53.325238	16.00	0.00	16.00	efectivo
3162	2026-03-17 19:34:54.346525	80.00	0.00	80.00	efectivo
3163	2026-03-17 19:49:10.3757	68.00	0.00	68.00	efectivo
3164	2026-03-17 20:00:22.343466	65.00	0.00	65.00	efectivo
3165	2026-03-17 20:07:13.448678	223.00	0.00	223.00	efectivo
3166	2026-03-17 20:24:59.608407	103.00	0.00	103.00	efectivo
3167	2026-03-17 20:26:59.387591	29.00	0.00	29.00	efectivo
3168	2026-03-17 20:39:03.407809	10.00	0.00	10.00	efectivo
3169	2026-03-17 21:10:00.333204	51.00	0.00	51.00	efectivo
3170	2026-03-18 17:40:02.834989	26.00	0.00	26.00	efectivo
3171	2026-03-18 17:41:54.641941	8.00	0.00	8.00	efectivo
3172	2026-03-18 17:50:34.51909	2.00	0.00	2.00	efectivo
3173	2026-03-18 17:50:42.397237	6.00	0.00	6.00	efectivo
3174	2026-03-18 18:20:40.602058	16.00	0.00	16.00	efectivo
3175	2026-03-18 18:29:09.275727	29.00	0.00	29.00	efectivo
3176	2026-03-18 18:35:40.230953	107.00	0.00	107.00	efectivo
3177	2026-03-18 18:35:50.917253	8.00	0.00	8.00	efectivo
3178	2026-03-18 18:37:44.165422	15.00	0.00	15.00	efectivo
3179	2026-03-18 18:46:30.139922	40.00	0.00	40.00	efectivo
3180	2026-03-18 18:46:42.272715	20.00	0.00	20.00	efectivo
3181	2026-03-18 18:50:38.095395	35.00	0.00	35.00	efectivo
3182	2026-03-18 19:02:12.170714	130.00	0.00	130.00	efectivo
3183	2026-03-18 19:08:32.422829	35.00	0.00	35.00	efectivo
3184	2026-03-18 19:11:54.494175	20.00	0.00	20.00	efectivo
3185	2026-03-18 19:12:00.874509	14.00	0.00	14.00	efectivo
3186	2026-03-18 19:12:37.943595	3.00	0.00	3.00	efectivo
3187	2026-03-18 19:22:05.616217	25.00	0.00	25.00	efectivo
3188	2026-03-18 19:25:25.289884	2.00	0.00	2.00	efectivo
3189	2026-03-18 19:34:54.036501	7.00	0.00	7.00	efectivo
3190	2026-03-18 19:37:03.399745	20.00	0.00	20.00	efectivo
3191	2026-03-18 19:46:22.620186	57.00	0.00	57.00	efectivo
3192	2026-03-18 20:12:55.516781	30.00	0.00	30.00	efectivo
3193	2026-03-18 20:14:28.18464	14.00	0.00	14.00	efectivo
3194	2026-03-18 20:25:20.548953	35.00	0.00	35.00	efectivo
3195	2026-03-18 20:45:02.514485	70.00	0.00	70.00	efectivo
3196	2026-03-18 20:45:13.279268	65.00	0.00	65.00	efectivo
3197	2026-03-18 20:57:52.395896	15.00	0.00	15.00	efectivo
3198	2026-03-18 21:18:27.957318	96.50	0.00	96.50	efectivo
3199	2026-03-19 15:26:44.263322	47.00	0.00	47.00	efectivo
3200	2026-03-19 15:27:22.487063	30.00	0.00	30.00	efectivo
3201	2026-03-19 15:36:11.94934	15.00	0.00	15.00	efectivo
3202	2026-03-19 15:40:06.68441	8.00	0.00	8.00	efectivo
3203	2026-03-19 16:17:40.774598	20.00	0.00	20.00	efectivo
3204	2026-03-19 16:36:01.351431	6.00	0.00	6.00	efectivo
3205	2026-03-19 16:56:23.866522	70.00	0.00	70.00	efectivo
3206	2026-03-19 17:08:06.444384	36.00	0.00	36.00	efectivo
3207	2026-03-19 17:24:51.1157	65.00	0.00	65.00	efectivo
3208	2026-03-19 17:58:13.555469	14.00	0.00	14.00	efectivo
3209	2026-03-19 18:19:33.55652	37.50	0.00	37.50	efectivo
3210	2026-03-19 18:30:11.63283	30.00	0.00	30.00	efectivo
3211	2026-03-19 18:56:35.559608	39.00	0.00	39.00	efectivo
3212	2026-03-19 18:56:40.628332	7.00	0.00	7.00	efectivo
3213	2026-03-19 19:10:56.668339	12.50	0.00	12.50	efectivo
3214	2026-03-19 19:14:04.629099	7.50	0.00	7.50	efectivo
3215	2026-03-19 19:21:39.767146	151.00	0.00	151.00	efectivo
3216	2026-03-19 19:26:41.386067	78.00	0.00	78.00	efectivo
3217	2026-03-19 19:30:25.619108	20.00	0.00	20.00	efectivo
3218	2026-03-19 19:40:40.326135	40.00	0.00	40.00	efectivo
3219	2026-03-19 19:46:26.2509	169.00	0.00	169.00	efectivo
3220	2026-03-19 19:53:25.725665	31.50	0.00	31.50	efectivo
3221	2026-03-19 19:58:15.502993	30.00	0.00	30.00	efectivo
3222	2026-03-19 20:07:59.11431	75.00	0.00	75.00	efectivo
3223	2026-03-19 20:32:49.544348	25.00	0.00	25.00	efectivo
3224	2026-03-19 20:36:50.227738	15.00	0.00	15.00	efectivo
3225	2026-03-19 20:39:00.655936	15.00	0.00	15.00	efectivo
3226	2026-03-19 20:41:30.319447	32.00	0.00	32.00	efectivo
3227	2026-03-19 21:19:05.71066	98.00	0.00	98.00	efectivo
3228	2026-03-20 19:10:24.874944	112.00	0.00	112.00	efectivo
3229	2026-03-20 19:10:39.628257	8.00	0.00	8.00	efectivo
3230	2026-03-20 19:27:33.948955	72.00	0.00	72.00	efectivo
3231	2026-03-20 19:28:51.911499	47.00	0.00	47.00	efectivo
3232	2026-03-20 19:51:03.126706	57.00	0.00	57.00	efectivo
3233	2026-03-20 19:57:45.46869	52.00	0.00	52.00	efectivo
3234	2026-03-20 20:14:53.871335	35.00	0.00	35.00	efectivo
3235	2026-03-20 20:24:45.586511	30.00	0.00	30.00	efectivo
3236	2026-03-21 15:38:29.432731	102.00	0.00	102.00	efectivo
3237	2026-03-21 16:44:25.145077	100.00	0.00	100.00	efectivo
3238	2026-03-21 17:16:07.507257	49.00	0.00	49.00	efectivo
3239	2026-03-21 17:38:06.473374	86.00	0.00	86.00	efectivo
3240	2026-03-21 17:46:46.310549	36.00	0.00	36.00	efectivo
3241	2026-03-21 18:14:01.770807	46.00	0.00	46.00	efectivo
3242	2026-03-21 18:22:46.34732	6.00	0.00	6.00	efectivo
3243	2026-03-23 17:34:13.677302	17.00	0.00	17.00	efectivo
3244	2026-03-23 17:36:10.981465	60.00	0.00	60.00	efectivo
3245	2026-03-23 17:37:18.232867	70.00	0.00	70.00	efectivo
3246	2026-03-23 17:40:44.199616	12.00	0.00	12.00	efectivo
3247	2026-03-23 17:57:24.574832	14.00	0.00	14.00	efectivo
3248	2026-03-23 18:03:16.767272	2.00	0.00	2.00	efectivo
3249	2026-03-23 18:20:23.209619	27.00	0.00	27.00	efectivo
3250	2026-03-23 18:30:37.320587	10.00	0.00	10.00	efectivo
3251	2026-03-23 18:59:07.861285	25.00	0.00	25.00	efectivo
3252	2026-03-23 19:00:52.849005	6.00	0.00	6.00	efectivo
3253	2026-03-23 19:03:03.639171	24.00	0.00	24.00	efectivo
3254	2026-03-23 19:06:20.133521	51.00	0.00	51.00	efectivo
3255	2026-03-23 19:12:03.779792	28.00	0.00	28.00	efectivo
3256	2026-03-23 19:14:57.158629	17.00	0.00	17.00	efectivo
3257	2026-03-23 19:19:14.445481	7.00	0.00	7.00	efectivo
3258	2026-03-23 19:38:05.021999	45.00	0.00	45.00	efectivo
3259	2026-03-23 19:52:53.875765	40.00	0.00	40.00	efectivo
3260	2026-03-23 19:56:54.664968	7.00	0.00	7.00	efectivo
3261	2026-03-23 20:01:50.640778	6.00	0.00	6.00	efectivo
3262	2026-03-23 20:26:54.584571	36.00	0.00	36.00	efectivo
3263	2026-03-23 20:28:16.631299	20.00	0.00	20.00	efectivo
3264	2026-03-23 20:34:26.747066	12.00	0.00	12.00	efectivo
3265	2026-03-23 20:56:56.890342	89.00	0.00	89.00	efectivo
3266	2026-03-23 20:58:53.403557	18.50	0.00	18.50	efectivo
3267	2026-03-24 16:14:02.859358	4.00	0.00	4.00	efectivo
3268	2026-03-24 16:37:14.641379	50.00	0.00	50.00	efectivo
3269	2026-03-24 16:47:55.133078	271.00	0.00	271.00	efectivo
3270	2026-03-24 17:03:54.964541	35.00	0.00	35.00	efectivo
3271	2026-03-24 17:20:42.460008	68.00	0.00	68.00	efectivo
3272	2026-03-24 17:21:05.529082	36.00	0.00	36.00	efectivo
3273	2026-03-24 17:28:52.474966	4.00	0.00	4.00	efectivo
3274	2026-03-24 17:33:54.00901	2.00	0.00	2.00	efectivo
3275	2026-03-24 17:36:02.773639	20.00	0.00	20.00	efectivo
3276	2026-03-24 18:03:58.098776	66.00	0.00	66.00	efectivo
3277	2026-03-24 18:05:51.224391	68.00	0.00	68.00	efectivo
3278	2026-03-24 18:07:48.888006	28.00	0.00	28.00	efectivo
3279	2026-03-24 18:09:01.949928	77.00	0.00	77.00	efectivo
3280	2026-03-24 18:09:23.844887	5.00	0.00	5.00	efectivo
3281	2026-03-24 18:17:42.132635	56.00	0.00	56.00	efectivo
3282	2026-03-24 18:27:54.897703	226.00	0.00	226.00	efectivo
3283	2026-03-24 18:51:16.508597	2.00	0.00	2.00	efectivo
3284	2026-03-24 18:51:35.521611	2.50	0.00	2.50	efectivo
3285	2026-03-24 18:54:25.940039	30.00	0.00	30.00	efectivo
3286	2026-03-24 19:17:42.258469	14.00	0.00	14.00	efectivo
3287	2026-03-24 19:31:28.640673	25.00	0.00	25.00	efectivo
3288	2026-03-24 19:31:55.881957	83.00	0.00	83.00	efectivo
3289	2026-03-24 19:33:12.169075	34.00	0.00	34.00	efectivo
3290	2026-03-24 19:56:12.47192	28.00	0.00	28.00	efectivo
3291	2026-03-24 19:59:07.318562	15.00	0.00	15.00	efectivo
3292	2026-03-24 20:37:59.568361	169.50	0.00	169.50	efectivo
3293	2026-03-24 20:49:51.787801	23.00	0.00	23.00	efectivo
3294	2026-03-25 17:42:06.211439	66.00	0.00	66.00	efectivo
3295	2026-03-25 17:50:11.104378	16.00	0.00	16.00	efectivo
3296	2026-03-25 17:52:08.70096	26.00	0.00	26.00	efectivo
3297	2026-03-25 18:12:24.346066	54.00	0.00	54.00	efectivo
3298	2026-03-25 18:15:55.228218	18.00	0.00	18.00	efectivo
3299	2026-03-25 18:21:36.546259	6.00	0.00	6.00	efectivo
3300	2026-03-25 18:24:31.157305	7.00	0.00	7.00	efectivo
3301	2026-03-25 18:29:32.14008	12.00	0.00	12.00	efectivo
3302	2026-03-25 19:09:22.552162	44.00	0.00	44.00	efectivo
3303	2026-03-25 19:09:31.3048	7.00	0.00	7.00	efectivo
3304	2026-03-25 19:33:49.761846	80.00	0.00	80.00	efectivo
3305	2026-03-25 19:36:06.319831	47.00	0.00	47.00	efectivo
3306	2026-03-25 19:52:51.525688	42.00	0.00	42.00	efectivo
3307	2026-03-25 19:55:40.282498	8.00	0.00	8.00	efectivo
3308	2026-03-25 20:07:11.401552	24.00	0.00	24.00	efectivo
3309	2026-03-25 20:17:49.739394	8.00	0.00	8.00	efectivo
3310	2026-03-25 20:19:30.125721	12.00	0.00	12.00	efectivo
3311	2026-03-25 20:23:43.723459	15.00	0.00	15.00	efectivo
3312	2026-03-25 20:25:27.96855	21.00	0.00	21.00	efectivo
3313	2026-03-25 20:28:38.041701	60.00	0.00	60.00	efectivo
3314	2026-03-25 20:32:33.942222	106.00	0.00	106.00	efectivo
3315	2026-03-25 20:44:48.735385	69.00	0.00	69.00	efectivo
3316	2026-03-25 21:12:35.111588	16.00	0.00	16.00	efectivo
3317	2026-03-26 16:20:27.723346	39.00	0.00	39.00	efectivo
3318	2026-03-26 16:56:19.998226	152.50	0.00	152.50	efectivo
3319	2026-03-26 17:16:05.492292	64.00	0.00	64.00	efectivo
3320	2026-03-26 17:19:43.290135	23.00	0.00	23.00	efectivo
3321	2026-03-26 17:25:32.004671	42.00	0.00	42.00	efectivo
3322	2026-03-26 17:35:18.31658	8.00	0.00	8.00	efectivo
3323	2026-03-26 17:50:17.937361	8.00	0.00	8.00	efectivo
3324	2026-03-26 18:00:13.946114	37.00	0.00	37.00	efectivo
3325	2026-03-26 18:06:17.172248	66.00	0.00	66.00	efectivo
3326	2026-03-26 18:09:05.950075	52.00	0.00	52.00	efectivo
3327	2026-03-26 18:44:35.27121	35.00	0.00	35.00	efectivo
3328	2026-03-26 18:47:48.852158	6.00	0.00	6.00	efectivo
3329	2026-03-26 18:52:55.632739	14.00	0.00	14.00	efectivo
3330	2026-03-26 19:32:26.066924	48.00	0.00	48.00	efectivo
3331	2026-03-26 19:33:05.926575	15.00	0.00	15.00	efectivo
3332	2026-03-26 20:02:25.983265	4.00	0.00	4.00	efectivo
3333	2026-03-26 20:02:56.580647	6.50	0.00	6.50	efectivo
3334	2026-03-26 20:10:43.663274	40.00	0.00	40.00	efectivo
3335	2026-03-26 20:20:14.136621	15.00	0.00	15.00	efectivo
3336	2026-03-30 15:54:57.095365	68.00	0.00	68.00	efectivo
3337	2026-03-30 19:14:32.989047	26.00	0.00	26.00	efectivo
3338	2026-03-30 19:16:53.790733	26.00	0.00	26.00	efectivo
3339	2026-03-30 19:33:55.531194	85.00	0.00	85.00	efectivo
3340	2026-03-30 19:38:50.545466	10.00	0.00	10.00	efectivo
3341	2026-03-30 19:42:28.84207	2.50	0.00	2.50	efectivo
3342	2026-03-30 20:36:01.942783	72.00	0.00	72.00	efectivo
3343	2026-03-31 16:34:41.892759	27.00	0.00	27.00	efectivo
3344	2026-03-31 16:50:27.359595	6.00	0.00	6.00	efectivo
3345	2026-03-31 18:25:19.147434	36.00	0.00	36.00	efectivo
3346	2026-03-31 18:25:22.13479	20.00	0.00	20.00	efectivo
3347	2026-03-31 18:39:34.712714	18.00	0.00	18.00	efectivo
3348	2026-03-31 18:45:35.535895	80.00	0.00	80.00	efectivo
3349	2026-04-07 16:41:30.601494	93.00	0.00	93.00	efectivo
3350	2026-04-07 18:29:11.315474	15.00	0.00	15.00	efectivo
3351	2026-04-07 18:30:05.654707	6.00	0.00	6.00	efectivo
3352	2026-04-07 18:30:29.70791	63.00	0.00	63.00	efectivo
3353	2026-04-07 18:35:04.940873	4.00	0.00	4.00	efectivo
3354	2026-04-07 18:49:35.745501	136.00	0.00	136.00	efectivo
3355	2026-04-07 18:53:04.61432	5.00	0.00	5.00	efectivo
3356	2026-04-07 18:57:57.247804	2.00	0.00	2.00	efectivo
3357	2026-04-07 18:58:58.849844	4.00	0.00	4.00	efectivo
3358	2026-04-07 19:27:48.381621	40.00	0.00	40.00	efectivo
3359	2026-04-07 20:06:29.802329	25.00	0.00	25.00	efectivo
3360	2026-04-07 20:06:37.407076	4.00	0.00	4.00	efectivo
3361	2026-04-07 20:11:38.021508	7.00	0.00	7.00	efectivo
3362	2026-04-08 18:02:18.140231	48.50	0.00	48.50	efectivo
3363	2026-04-08 18:03:49.081793	20.00	0.00	20.00	efectivo
3364	2026-04-08 18:30:07.318137	131.00	0.00	131.00	efectivo
3365	2026-04-08 18:31:32.075682	39.50	0.00	39.50	efectivo
3366	2026-04-08 18:40:14.40498	37.50	0.00	37.50	efectivo
3367	2026-04-08 18:53:55.380227	59.00	0.00	59.00	efectivo
3368	2026-04-08 18:56:02.889764	9.00	0.00	9.00	efectivo
3369	2026-04-08 19:10:59.355205	16.00	0.00	16.00	efectivo
3370	2026-04-08 19:14:11.562864	7.00	0.00	7.00	efectivo
3371	2026-04-08 20:36:44.160172	10.00	0.00	10.00	efectivo
3372	2026-04-08 21:00:56.020142	25.50	0.00	25.50	efectivo
3373	2026-04-08 21:03:05.349095	92.00	0.00	92.00	efectivo
3374	2026-04-10 15:47:10.808718	20.00	0.00	20.00	efectivo
3375	2026-04-10 16:18:41.79383	14.00	0.00	14.00	efectivo
3376	2026-04-10 17:22:29.209583	65.00	0.00	65.00	efectivo
3377	2026-04-10 17:34:19.234738	41.00	0.00	41.00	efectivo
3378	2026-04-10 17:38:16.891938	60.00	0.00	60.00	efectivo
3379	2026-04-10 18:03:43.731981	130.00	0.00	130.00	efectivo
3380	2026-04-10 18:05:12.422376	36.00	0.00	36.00	efectivo
3381	2026-04-10 18:44:51.882822	15.00	0.00	15.00	efectivo
3382	2026-04-10 19:17:30.444258	27.00	0.00	27.00	efectivo
3383	2026-04-10 19:32:35.064751	8.00	0.00	8.00	efectivo
3384	2026-04-11 17:08:47.346276	148.00	0.00	148.00	efectivo
3385	2026-04-11 17:13:57.43774	85.00	0.00	85.00	efectivo
3386	2026-04-11 18:20:17.349711	35.00	0.00	35.00	efectivo
3387	2026-04-13 17:24:03.694922	89.50	0.00	89.50	efectivo
3388	2026-04-13 17:26:15.475876	122.00	0.00	122.00	efectivo
3389	2026-04-13 17:55:23.398672	25.00	0.00	25.00	efectivo
3390	2026-04-13 18:24:57.46295	111.00	0.00	111.00	efectivo
3391	2026-04-13 18:27:04.369971	54.00	0.00	54.00	efectivo
3392	2026-04-13 18:28:06.213628	50.00	0.00	50.00	efectivo
3393	2026-04-13 18:30:17.953879	73.00	0.00	73.00	efectivo
3394	2026-04-13 18:33:14.148962	18.00	0.00	18.00	efectivo
3395	2026-04-13 18:34:46.182707	16.00	0.00	16.00	efectivo
3396	2026-04-13 18:40:22.093229	142.00	0.00	142.00	efectivo
3397	2026-04-13 18:42:12.417478	6.00	0.00	6.00	efectivo
3398	2026-04-13 18:45:20.979074	2.00	0.00	2.00	efectivo
3399	2026-04-13 18:54:20.602294	54.00	0.00	54.00	efectivo
3400	2026-04-13 18:56:30.296364	65.00	0.00	65.00	efectivo
3401	2026-04-13 19:19:27.833554	30.00	0.00	30.00	efectivo
3402	2026-04-13 19:31:51.077013	47.00	0.00	47.00	efectivo
3403	2026-04-13 19:54:15.408598	20.00	0.00	20.00	efectivo
3404	2026-04-13 20:09:33.738022	24.50	0.00	24.50	efectivo
3405	2026-04-13 20:11:01.537739	20.00	0.00	20.00	efectivo
3406	2026-04-13 20:15:25.938504	19.00	0.00	19.00	efectivo
3407	2026-04-13 20:21:59.025853	17.00	0.00	17.00	efectivo
3408	2026-04-13 20:30:51.336417	2.00	0.00	2.00	efectivo
\.


--
-- Name: detalle_venta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.detalle_venta_id_seq', 7368, true);


--
-- Name: egresos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.egresos_id_seq', 31, true);


--
-- Name: lista_compras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lista_compras_id_seq', 1, false);


--
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.productos_id_seq', 1607, true);


--
-- Name: tienda_productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tienda_productos_id_seq', 1, false);


--
-- Name: tiendas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tiendas_id_seq', 1, false);


--
-- Name: ventas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ventas_id_seq', 3408, true);


--
-- Name: detalle_venta detalle_venta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_venta
    ADD CONSTRAINT detalle_venta_pkey PRIMARY KEY (id);


--
-- Name: egresos egresos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egresos
    ADD CONSTRAINT egresos_pkey PRIMARY KEY (id);


--
-- Name: lista_compras lista_compras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lista_compras
    ADD CONSTRAINT lista_compras_pkey PRIMARY KEY (id);


--
-- Name: productos productos_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_codigo_key UNIQUE (codigo);


--
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- Name: tienda_productos tienda_productos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tienda_productos
    ADD CONSTRAINT tienda_productos_pkey PRIMARY KEY (id);


--
-- Name: tiendas tiendas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tiendas
    ADD CONSTRAINT tiendas_pkey PRIMARY KEY (id);


--
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- Name: idx_detalle_venta_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_detalle_venta_nombre ON public.detalle_venta USING btree (nombre);


--
-- Name: idx_detalle_venta_venta_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_detalle_venta_venta_id ON public.detalle_venta USING btree (venta_id);


--
-- Name: idx_egresos_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_egresos_fecha ON public.egresos USING btree (fecha);


--
-- Name: idx_lista_compras_tienda_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lista_compras_tienda_id ON public.lista_compras USING btree (tienda_id);


--
-- Name: idx_productos_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_categoria ON public.productos USING btree (categoria);


--
-- Name: idx_productos_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_codigo ON public.productos USING btree (codigo);


--
-- Name: idx_productos_stock; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_stock ON public.productos USING btree (stock);


--
-- Name: idx_tienda_productos_tienda_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tienda_productos_tienda_id ON public.tienda_productos USING btree (tienda_id);


--
-- Name: idx_ventas_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_fecha ON public.ventas USING btree (fecha);


--
-- Name: idx_ventas_metodo_pago; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_metodo_pago ON public.ventas USING btree (metodo_pago);


--
-- Name: detalle_venta detalle_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_venta
    ADD CONSTRAINT detalle_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: lista_compras lista_compras_tienda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lista_compras
    ADD CONSTRAINT lista_compras_tienda_id_fkey FOREIGN KEY (tienda_id) REFERENCES public.tiendas(id) ON DELETE SET NULL;


--
-- Name: tienda_productos tienda_productos_tienda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tienda_productos
    ADD CONSTRAINT tienda_productos_tienda_id_fkey FOREIGN KEY (tienda_id) REFERENCES public.tiendas(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict gFR3BnNzaSspxBj2Y6RAyTQ9ga4WeaF4RX73OS3pGelGPfSJBweGRQrEOXc45wY

