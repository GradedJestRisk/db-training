
-- UUID size
SELECT pg_column_size('60c0d3d5-b35c-47d4-853c-36bee508fb5f'::uuid);
-- 16 bytes

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

---------------------------
-- Table with all columns -
---------------------------

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id SERIAL PRIMARY KEY,
   c1 UUID,
   c2 UUID,
   c3 UUID,
   c4 UUID,
   c5 UUID,
   c6 UUID,
   c7 UUID,
   c8 UUID,
   c9 UUID,
   c10 UUID
 );

INSERT INTO foo
  (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
SELECT
  uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4()
FROM
    generate_series( 1, 100000) -- 100 000 => 6 seconds
;

SELECT * FROM foo;

SELECT COUNT(1) FROM foo;
-- 100 000

VACUUM (VERBOSE, ANALYZE) foo;

DELETE FROM foo
WHERE MOD(id, 2) = 0;


-- Actual size
SELECT
   pg_table_size('foo') size_bytes,
   pg_table_size('foo') / 100000 row_size_bytes
;
-- 20 021 248
-- 200 bytes

-- Expected size
SELECT
   4 + pg_column_size('60c0d3d5-b35c-47d4-853c-36bee508fb5f'::uuid) * 10;
-- 164 bytes

-- System columns have a 10% overhead then

ALTER TABLE foo SET (AUTOVACUUM_ENABLED=FALSE);

ALTER TABLE foo DROP COLUMN c10;

VACUUM (VERBOSE, ANALYZE) foo;
-- "foo": scanned 2440 of 2440 pages, containing 100000 live rows and 0 dead rows; 30000 rows in sample, 100000 estimated total rows


-- Actual size
SELECT
   pg_table_size('foo') size_bytes,
   pg_size_pretty(pg_table_size('foo')) size_bytes_pretty,
   pg_table_size('foo') / 100000 row_size_bytes
;
-- 20 021 248 bytes => same as before DROP
-- 19 MB

VACUUM FULL VERBOSE ANALYZE foo;
-- "foo": found 0 removable, 100000 nonremovable row versions in 2440 pages

-- Actual size
SELECT
   pg_table_size('foo') size_bytes,
   pg_size_pretty(pg_table_size('foo')) size_bytes_pretty,
   pg_table_size('foo') / 100000 row_size_bytes
;
-- 19 054 592
-- - less than before VACUUM FULL   (20 021 248)
-- - more than if table was created (18 243 584)

-- Statistics
SELECT
   TO_CHAR(NOW(),'HH:MI:SS') now,
   stt.n_live_tup,
   stt.n_dead_tup,
   'analyze=>',
   stt.analyze_count count,
   TO_CHAR(stt.last_analyze,'HH:MI:SS') last_analyze,
   stt.autoanalyze_count count,
   TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze,
   'vacuum=>',
   stt.vacuum_count count,
   TO_CHAR(stt.last_vacuum,'HH:MI:SS') last_vacuum,
   stt.autovacuum_count count,
   TO_CHAR(stt.last_autovacuum,'HH:MI:SS') last_autovacuum
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
;



---------------------------
-- Table with all columns, but one -
---------------------------




-- Table with all columns

DROP TABLE IF EXISTS bar CASCADE;

CREATE TABLE bar (
   id SERIAL PRIMARY KEY,
   c1 UUID,
   c2 UUID,
   c3 UUID,
   c4 UUID,
   c5 UUID,
   c6 UUID,
   c7 UUID,
   c8 UUID,
   c9 UUID
 );

INSERT INTO bar
  (c1, c2, c3, c4, c5, c6, c7, c8, c9)
SELECT
  uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4()
FROM
    generate_series( 1, 100000) -- 100 000 => 6 seconds
;

SELECT * FROM bar;

SELECT COUNT(1) FROM bar;
-- 100 000

VACUUM (VERBOSE) bar;


-- Actual size
SELECT
   pg_table_size('bar') size_bytes,
   pg_size_pretty(pg_table_size('bar')) size_bytes_pretty,
   pg_table_size('bar') / 100000 row_size_bytes
;
-- 18 243 584
-- 17 Mb
-- 182 bytes per colmumn

-- Expected size
SELECT
   4 + pg_column_size('60c0d3d5-b35c-47d4-853c-36bee508fb5f'::uuid) * 9;
-- 148 bytes

-- System columns have a 10% overhead then



























DROP TABLE IF EXISTS foo;

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER
 );

INSERT INTO foo
  (value)
SELECT
  floor(random() * 2147483627 + 1)::int
FROM
    generate_series( 1, 1000000) -- 1 million => 2 seconds
;

select count(1) from foo;

-- https://dba.stackexchange.com/questions/23879/measure-the-size-of-a-postgresql-table-row/23933#23933
WITH x AS (
    SELECT count(*)               AS ct
         , 'public.foo'::regclass AS tbl -- provide table name as string
    FROM public.foo t -- provide table name as name
),
     y AS (
         SELECT ARRAY [pg_relation_size(tbl)
             , pg_relation_size(tbl, 'vm')
             , pg_relation_size(tbl, 'fsm')
             , pg_table_size(tbl)
             , pg_indexes_size(tbl)
             , pg_total_relation_size(tbl)
             ] AS val
              , ARRAY ['core_relation_size'
             , 'visibility_map'
             , 'free_space_map'
             , 'table_size_incl_toast'
             , 'indexes_size'
             , 'total_size_incl_toast_and_indexes'
             ] AS name
         FROM x
     )
SELECT unnest(name)                AS metric
     , unnest(val)                 AS bytes
     , pg_size_pretty(unnest(val)) AS bytes_pretty
     , unnest(val) / NULLIF(ct, 0) AS bytes_per_row
FROM x,
     y

    UNION ALL
    SELECT '------------------------------', NULL, NULL, NULL
    UNION ALL
    SELECT 'row_count', ct, NULL, NULL
    FROM x
    UNION ALL
    SELECT 'live_tuples', pg_stat_get_live_tuples(tbl), NULL, NULL
    FROM x
    UNION ALL
    SELECT 'dead_tuples', pg_stat_get_dead_tuples(tbl), NULL, NULL
    FROM x
;

select * from foo;

-- Disable AUTOVACUUM
ALTER TABLE foo SET (autovacuum_enabled = false)
;

-- Gather stats if needed
VACUUM (VERBOSE, ANALYZE) foo;

SELECT * FROM stats_foo;
-- 35 mb (w/o index)
-- 1 000 000 live tuples
-- no dead tuples

-- -- Prevent VACUUM => run separate session
-- BEGIN TRANSACTION;
-- SELECT * FROM foo LIMIT 1;
-- UPDATE foo SET  value = 0;
-- DELETE FROM foo
-- WHERE MOD(id, 2) = 0;

-- Drop column
ALTER TABLE foo DROP COLUMN value;



SELECT * from stats_foo;
-- 35 mb
-- 1 000 000 live tuples
-- no dead tuples

VACUUM (VERBOSE, ANALYZE) foo;
SELECT * FROM stats_foo;
-- 35 mb
-- 1 000 000 live tuples
-- no dead tuples

VACUUM FULL foo;
SELECT * FROM stats_foo;
-- 35 mb
-- 1 000 000 live tuples
-- no dead tuples


-- Statistics (from user session point of view)
-- - live_tup and dead_tup vary according to session
-- - file-related data does not vary (pg_relation_size, etc..)
SELECT
   TO_CHAR(NOW(),'HH:MI:SS') now,
   'tuples=>',
   stt.n_live_tup,
   stt.n_dead_tup,
   'analyze=>',
   stt.analyze_count analyze_count,
   TO_CHAR(stt.last_analyze,'HH:MI:SS') last_analyze,
   stt.autoanalyze_count count,
   TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze,
   'vacuum=>',
   stt.vacuum_count count,
   TO_CHAR(stt.last_vacuum,'HH:MI:SS') last_vacuum,
   stt.autovacuum_count count,
   TO_CHAR(stt.last_autovacuum,'HH:MI:SS') last_autovacuum
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
;

-- Size:
-- - data: 35Mb
-- - index: 35Mb



