--------- On UPDATE and DELETE -----------

-- https://www.2ndquadrant.com/en/blog/when-autovacuum-does-not-vacuum/

-- Should be ON to trigger autovacuum
SHOW autovacuum;
SELECT name, setting FROM pg_settings WHERE name='autovacuum';

-- If track_counts is off, the statistics collector won’t update the count of the number of dead rows for each table
-- which is the value that the autovacuum daemon checks in order to determine when and where it needs to run
SHOW track_counts;

-- On table
SELECT reloptions FROM pg_class WHERE relname='foo';
ALTER TABLE foo SET (AUTOVACUUM_ENABLED=FALSE);
ALTER TABLE foo SET (AUTOVACUUM_ENABLED=TRUE);


-- Daemon
SELECT
    t.backend_type,
    t.backend_start,
    t.wait_event,
    'pg_stat_activity=>'
    ,t.*
FROM
  pg_stat_activity t
where t.backend_type = 'autovacuum launcher'
;

--------------
-- Settings --
--------------


-- https://www.postgresql.org/docs/current/runtime-config-autovacuum.html
-- All
SELECT
    name, short_desc, unit, vartype "type",
    setting  "current_value",
    boot_val "default value",
    pending_restart "need_restart",
    'pg_settings=>',
    stt.*
FROM pg_settings stt WHERE category = 'Autovacuum'
;

SELECT * from pg_settings where name ILIKE '%autovacuum%'
;



-- Analyze
SELECT * from pg_settings
where category like 'Autovacuum'
AND name ILIKE '%analyze%';

-- Threshold (Minimum number of tuple updates or deletes prior to vacuum)
SHOW autovacuum_vacuum_threshold;
-- 50

-- Scale factor (Number of tuple updates or deletes prior to vacuum as a fraction of reltuples)
SHOW autovacuum_vacuum_scale_factor;
--0.2


-- Will autovacuum trigger ?
-- For relation
SELECT
       relname
       ,stt.n_live_tup
       ,stt.n_dead_tup
       ,TRUNC(current_setting('autovacuum_vacuum_threshold')::float8 + current_setting('autovacuum_vacuum_scale_factor')::float8 * stt.n_live_tup) ceiling -- if > n_dead_tup, autovaccum is triggered
FROM pg_stat_user_tables stt
WHERE 1=1
--    AND relname = 'foo'
ORDER BY stt.n_dead_tup DESC
;

-- Statistics
SELECT
   TO_CHAR(NOW(),'HH:MI:SS') now,
   stt.relname,
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
   ,stt.*
FROM pg_stat_user_tables stt
WHERE 1=1
   AND relname LIKE 'traces_metier%'
--   AND stt.last_autoanalyze IS NOT NULL
;

--------- On INSERT -----------

-- Starting with PG 13, the visibility map is updated by ANALYZE even if ony INSERT took place
-- http://amitkapila16.blogspot.com/2020/05/improved-autovacuum-in-postgresql-13.html


-- Deactivate
ALTER SYSTEM SET autovacuum_vacuum_insert_threshold=-1;

-- Activate
ALTER SYSTEM SET autovacuum_vacuum_insert_threshold=10000;
SHOW autovacuum_vacuum_insert_threshold;
-- 1000 as default


-- Statistics
SELECT
   TO_CHAR(NOW(),'HH:MI:SS') now,
   stt.relname,
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
    AND relname = 'vac_ins'
--   AND stt.last_autoanalyze IS NOT NULL
;


-----------------
-- Block by lock
----------------

-- https://www.datadoghq.com/blog/postgresql-vacuum-monitoring/


SELECT reloptions FROM pg_class WHERE relname='foo';
-- {autovacuum_enabled=true}


-- In another session, run
BEGIN TRANSACTION;
DELETE FROM foo WHERE id > 500;
ALTER TABLE foo RENAME COLUMN id TO bar;
SELECT count(1) FROM foo;

-- ANALYZE VERBOSE foo;
-- INFO:  analyzing "public.foo"
-- INFO:  "foo": scanned 2440 of 2440 pages, containing 250 live rows and 49750 dead rows; 250 rows in sample, 250 estimated total rows


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


-- Statistics
SELECT
   TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
;



-- idle
SELECT
       --xact_start, state, usename
    application_name,
    query
    -- *
FROM pg_stat_activity
WHERE 1=1
  AND datname = 'postgres'
  AND state = 'idle'
;

-- Check autovacuum is in queue, waiting
-- docker exec -it database ps -ef | grep autovacuum


-- Logs --

-- Enable logs
SELECT * from pg_settings where name = 'log_autovacuum_min_duration'
;

-- Log autovacuum longer than one minute
ALTER SYSTEM SET log_autovacuum_min_duration='1min';

-- Log autovacuum longer than one minute
ALTER SYSTEM SET log_autovacuum_min_duration=100;