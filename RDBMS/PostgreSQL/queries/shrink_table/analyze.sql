-------------------------
--- analyze --
-------------------------

-- Analyze is run:
-- - manually with VACUUM ANALYZE foo;
-- - automatically with AUTO-VACUUM

-- auto-analyze settings
SELECT * from pg_settings
where category like 'Autovacuum'
AND name ILIKE '%analyze%';

-- Threshold (Minimum number of tuple updates or deletes prior to vacuum)
SHOW autovacuum_analyze_threshold;
-- 50

-- Scale factor (Number of tuple updates or deletes prior to vacuum as a fraction of reltuples)
SHOW autovacuum_analyze_scale_factor;
--0.1

-- Will autoanalyze trigger ?
SELECT
       relname
       ,stt.n_live_tup
       ,stt.n_dead_tup
       ,TRUNC(current_setting('autovacuum_analyze_threshold')::float8 + current_setting('autovacuum_analyze_scale_factor')::float8 * stt.n_live_tup) ceiling -- if > n_dead_tup, autovaccum is triggered
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
ORDER BY stt.n_dead_tup DESC
;

-- https://www.postgresql.org/docs/current/sql-analyze.html
ANALYZE foo;
ANALYZE VERBOSE foo;
-- analyzing "public.foo"
-- "foo": scanned 4425 of 4425 pages, containing 500 live rows and 999500 dead rows; 500 rows in sample, 500 estimated total rows

-- ANALYZE update this table
SELECT *
FROM  pg_statistic
;

-- This view is based upon pg_statistic
SELECT * FROM pg_stats s
WHERE 1=1
 AND s.schemaname <> 'pg_catalog'
AND s.tablename = 'foo'
--- AND s.attname = ''
;

-- ANALYZE also update n_dead_tuples in pg_stat_user_tables, which are used by VACUUM



-------------------------
----- When are metrics updated ?
-------------------------


-- In another session, run
DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER PRIMARY KEY
 );

INSERT INTO foo   (id)
SELECT *
FROM generate_series( 1, power(10, 6)::int) -- 1 million => 10 seconds
;

SELECT * FROM foo;
SELECT count(1) FROM foo;
-- 1 000 000

ALTER TABLE foo SET (AUTOVACUUM_ENABLED=FALSE);
SELECT reloptions FROM pg_class WHERE relname='foo';
-- {autovacuum_enabled=false}

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
   TO_CHAR(stt.last_autovacuum,'HH:MI:SS') last_autovacuum,
   'pg_stat_user_tables=>'
   --,stt.*
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
;

SELECT count(1) FROM foo;
-- 1 000 000

DELETE FROM foo WHERE id > 500;
SELECT count(1) FROM foo;
-- 500

-- Statistics
SELECT
   TO_CHAR(NOW(),'HH:MI:SS') now,
   stt.n_live_tup,
   stt.n_dead_tup,
   'analyze=>',
   stt.analyze_count count,
   TO_CHAR(stt.last_analyze,'HH:MI:SS') last_analyze,
   stt.autoanalyze_count count,
   TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
;
-- n_dead_tup = 999500
-- n_dead_tup is already updated, whereas no analyze or auto-analyze take place ?

ANALYZE VERBOSE foo;

-- Statistics
SELECT
   TO_CHAR(NOW(),'HH:MI:SS') now,
   stt.n_live_tup,
   stt.n_dead_tup,
   'analyze=>',
   stt.analyze_count count,
   TO_CHAR(stt.last_analyze,'HH:MI:SS') last_analyze,
   stt.autoanalyze_count count,
   TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
;

ALTER TABLE foo SET (AUTOVACUUM_ENABLED=TRUE);
SELECT reloptions FROM pg_class WHERE relname='foo';
-- {autovacuum_enabled=true}


-- Will autovacuum trigger ?
-- For relation
SELECT
       relname
       ,stt.n_live_tup
       ,stt.n_dead_tup
       ,TRUNC(current_setting('autovacuum_vacuum_threshold')::float8 + current_setting('autovacuum_vacuum_scale_factor')::float8 * stt.n_live_tup) ceiling -- if > n_dead_tup, autovaccum is triggered
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
ORDER BY stt.n_dead_tup DESC
;


-- Check autovacumm
SELECT
   TO_CHAR(NOW(),'HH:MI:SS') now,
   stt.n_live_tup,
   stt.n_dead_tup,
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
-- autovacuum has been run
-- n_dead_tup is now 0