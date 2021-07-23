--
-- PostgreSQL database dump
--

-- Dumped from database version 12.0
-- Dumped by pg_dump version 12.0

-- Started on 2021-03-17 19:32:55

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 245491)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 245496)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 208 (class 1259 OID 246498)
-- Name: itrdb_distance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.itrdb_distance (
    series_a text,
    series_b text,
    distance_m double precision
);


--
-- TOC entry 209 (class 1259 OID 246504)
-- Name: similarities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.similarities (
    series_a text,
    series_b text,
    r double precision,
    sgc double precision,
    ssgc double precision,
    overlap double precision,
    p double precision
);


--
-- TOC entry 210 (class 1259 OID 246510)
-- Name: distance_statistics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.distance_statistics AS
 SELECT similarities.series_a,
    similarities.series_b,
    similarities.r,
    similarities.sgc,
    similarities.ssgc,
    similarities.overlap,
    similarities.p,
    itrdb_distance.distance_m
   FROM public.similarities,
    public.itrdb_distance
  WHERE ((similarities.series_a = itrdb_distance.series_a) AND (similarities.series_b = itrdb_distance.series_b) AND (similarities.r IS NOT NULL));


--
-- TOC entry 211 (class 1259 OID 246514)
-- Name: itrdb_clean; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.itrdb_clean (
    code text NOT NULL,
    studysite text,
    species text,
    investigator text,
    lon numeric,
    lat numeric,
    url text,
    geom public.geometry(Point,4326)
);


--
-- TOC entry 212 (class 1259 OID 246520)
-- Name: distance_statistics_abal; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.distance_statistics_abal AS
 SELECT similarities.series_a,
    similarities.series_b,
    similarities.r,
    similarities.sgc,
    similarities.ssgc,
    similarities.overlap,
    similarities.p,
    itrdb_distance.distance_m
   FROM public.similarities,
    public.itrdb_distance,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean
          WHERE (itrdb_clean.species = 'ABAL'::text)) itrdb_spec1,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean
          WHERE (itrdb_clean.species = 'ABAL'::text)) itrdb_spec2
  WHERE ((similarities.series_a = itrdb_distance.series_a) AND (similarities.series_b = itrdb_distance.series_b) AND (similarities.series_a = itrdb_spec1.code) AND (similarities.series_b = itrdb_spec2.code) AND (similarities.series_a <> similarities.series_b) AND (similarities.r IS NOT NULL));


--
-- TOC entry 213 (class 1259 OID 246525)
-- Name: distance_statistics_pisy; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.distance_statistics_pisy AS
 SELECT similarities.series_a,
    similarities.series_b,
    similarities.r,
    similarities.sgc,
    similarities.ssgc,
    similarities.overlap,
    similarities.p,
    itrdb_distance.distance_m
   FROM public.similarities,
    public.itrdb_distance,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean
          WHERE (itrdb_clean.species = 'PISY'::text)) itrdb_spec1,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean
          WHERE (itrdb_clean.species = 'PISY'::text)) itrdb_spec2
  WHERE ((similarities.series_a = itrdb_distance.series_a) AND (similarities.series_b = itrdb_distance.series_b) AND (similarities.series_a = itrdb_spec1.code) AND (similarities.series_b = itrdb_spec2.code) AND (similarities.series_a <> similarities.series_b) AND (similarities.r IS NOT NULL));


--
-- TOC entry 214 (class 1259 OID 246530)
-- Name: distance_statistics_qusp; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.distance_statistics_qusp AS
 SELECT similarities.series_a,
    similarities.series_b,
    similarities.r,
    similarities.sgc,
    similarities.ssgc,
    similarities.overlap,
    similarities.p,
    itrdb_distance.distance_m
   FROM public.similarities,
    public.itrdb_distance,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean
          WHERE (itrdb_clean.species = 'QUSP'::text)) itrdb_spec1,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean
          WHERE (itrdb_clean.species = 'QUSP'::text)) itrdb_spec2
  WHERE ((similarities.series_a = itrdb_distance.series_a) AND (similarities.series_b = itrdb_distance.series_b) AND (similarities.series_a = itrdb_spec1.code) AND (similarities.series_b = itrdb_spec2.code) AND (similarities.series_a <> similarities.series_b) AND (similarities.r IS NOT NULL));


--
-- TOC entry 215 (class 1259 OID 246535)
-- Name: distance_statistics_species; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.distance_statistics_species AS
 SELECT similarities.series_a,
    similarities.series_b,
    similarities.r,
    similarities.sgc,
    similarities.ssgc,
    similarities.overlap,
    similarities.p,
    itrdb_distance.distance_m,
    itrdb_spec2.species
   FROM public.similarities,
    public.itrdb_distance,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean) itrdb_spec1,
    ( SELECT itrdb_clean.code,
            itrdb_clean.studysite,
            itrdb_clean.species,
            itrdb_clean.investigator,
            itrdb_clean.lon,
            itrdb_clean.lat,
            itrdb_clean.url,
            itrdb_clean.geom
           FROM public.itrdb_clean) itrdb_spec2
  WHERE ((similarities.series_a = itrdb_distance.series_a) AND (similarities.series_b = itrdb_distance.series_b) AND (similarities.series_a = itrdb_spec1.code) AND (similarities.series_b = itrdb_spec2.code) AND (similarities.series_a <> similarities.series_b) AND (similarities.r IS NOT NULL) AND (itrdb_spec2.species = itrdb_spec1.species));


--
-- TOC entry 216 (class 1259 OID 246540)
-- Name: itrdb_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.itrdb_country (
    code text NOT NULL,
    name_en character varying(44),
    continent character varying(23)
);


--
-- TOC entry 217 (class 1259 OID 246546)
-- Name: network_4; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.network_4 AS
 SELECT DISTINCT tbl_sim_dist.series_a,
    tbl_sim_dist.series_b,
    tbl_sim_dist.r,
    tbl_sim_dist.sgc,
    tbl_sim_dist.ssgc,
    tbl_sim_dist.overlap,
    tbl_sim_dist.p,
    itrdb_distance.distance_m
   FROM ( SELECT similarities.series_a,
            similarities.series_b,
            similarities.r,
            similarities.sgc,
            similarities.ssgc,
            similarities.overlap,
            similarities.p
           FROM public.similarities
          WHERE ((similarities.r >= (0.5)::double precision) AND (similarities.overlap >= (50)::double precision) AND (similarities.p <= (0.0001)::double precision))
        UNION
         SELECT similarities.series_a,
            similarities.series_b,
            similarities.r,
            similarities.sgc,
            similarities.ssgc,
            similarities.overlap,
            similarities.p
           FROM public.similarities
          WHERE ((similarities.r >= (0.5)::double precision) AND (similarities.sgc >= (0.7)::double precision) AND (similarities.overlap >= (50)::double precision))) tbl_sim_dist,
    public.itrdb_distance
  WHERE ((tbl_sim_dist.series_a = itrdb_distance.series_a) AND (tbl_sim_dist.series_b = itrdb_distance.series_b));


--
-- TOC entry 218 (class 1259 OID 246551)
-- Name: worldcountries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worldcountries (
    gid integer NOT NULL,
    featurecla character varying(15),
    scalerank smallint,
    labelrank smallint,
    sovereignt character varying(32),
    sov_a3 character varying(3),
    adm0_dif smallint,
    level smallint,
    type character varying(17),
    admin character varying(36),
    adm0_a3 character varying(3),
    geou_dif smallint,
    geounit character varying(36),
    gu_a3 character varying(3),
    su_dif smallint,
    subunit character varying(36),
    su_a3 character varying(3),
    brk_diff smallint,
    name character varying(25),
    name_long character varying(36),
    brk_a3 character varying(3),
    brk_name character varying(32),
    brk_group character varying(17),
    abbrev character varying(13),
    postal character varying(4),
    formal_en character varying(52),
    formal_fr character varying(35),
    name_ciawf character varying(45),
    note_adm0 character varying(22),
    note_brk character varying(63),
    name_sort character varying(36),
    name_alt character varying(19),
    mapcolor7 smallint,
    mapcolor8 smallint,
    mapcolor9 smallint,
    mapcolor13 smallint,
    pop_est bigint,
    pop_rank smallint,
    gdp_md_est double precision,
    pop_year smallint,
    lastcensus smallint,
    gdp_year smallint,
    economy character varying(26),
    income_grp character varying(23),
    wikipedia smallint,
    fips_10_ character varying(3),
    iso_a2 character varying(3),
    iso_a3 character varying(3),
    iso_a3_eh character varying(3),
    iso_n3 character varying(3),
    un_a3 character varying(4),
    wb_a2 character varying(3),
    wb_a3 character varying(3),
    woe_id integer,
    woe_id_eh integer,
    woe_note character varying(167),
    adm0_a3_is character varying(3),
    adm0_a3_us character varying(3),
    adm0_a3_un smallint,
    adm0_a3_wb smallint,
    continent character varying(23),
    region_un character varying(23),
    subregion character varying(25),
    region_wb character varying(26),
    name_len smallint,
    long_len smallint,
    abbrev_len smallint,
    tiny smallint,
    homepart smallint,
    min_zoom double precision,
    min_label double precision,
    max_label double precision,
    ne_id bigint,
    wikidataid character varying(8),
    name_ar character varying(72),
    name_bn character varying(148),
    name_de character varying(46),
    name_en character varying(44),
    name_es character varying(44),
    name_fr character varying(54),
    name_el character varying(88),
    name_hi character varying(126),
    name_hu character varying(52),
    name_id character varying(46),
    name_it character varying(48),
    name_ja character varying(63),
    name_ko character varying(47),
    name_nl character varying(49),
    name_pl character varying(47),
    name_pt character varying(43),
    name_ru character varying(86),
    name_sv character varying(57),
    name_tr character varying(42),
    name_vi character varying(56),
    name_zh character varying(36),
    geom public.geometry(MultiPolygon,4326)
);


--
-- TOC entry 219 (class 1259 OID 246557)
-- Name: worldcountries_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worldcountries_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 219
-- Name: worldcountries_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worldcountries_gid_seq OWNED BY public.worldcountries.gid;


--
-- TOC entry 3584 (class 2604 OID 246559)
-- Name: worldcountries gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worldcountries ALTER COLUMN gid SET DEFAULT nextval('public.worldcountries_gid_seq'::regclass);


--
-- TOC entry 3588 (class 2606 OID 246561)
-- Name: itrdb_clean itrdb_clean_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itrdb_clean
    ADD CONSTRAINT itrdb_clean_pkey PRIMARY KEY (code);


--
-- TOC entry 3590 (class 2606 OID 246563)
-- Name: itrdb_country itrdb_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itrdb_country
    ADD CONSTRAINT itrdb_country_pkey PRIMARY KEY (code);


--
-- TOC entry 3592 (class 2606 OID 246565)
-- Name: worldcountries worldcountries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worldcountries
    ADD CONSTRAINT worldcountries_pkey PRIMARY KEY (gid);


-- Completed on 2021-03-17 19:32:58

--
-- PostgreSQL database dump complete
--

