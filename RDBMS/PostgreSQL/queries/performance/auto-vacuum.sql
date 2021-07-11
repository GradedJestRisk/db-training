--------- On UPDATE and DELETE -----------

-- https://www.2ndquadrant.com/en/blog/when-autovacuum-does-not-vacuum/

-- Should be ON to trigger autovacuum
SHOW autovacuum;
SHOW track_counts;

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

-- Settings

SHOW autovacuum_vacuum_threshold;
-- 50

SHOW autovacuum_vacuum_scale_factor;
--0.2


-- Autovacuum trigger for relation
SELECT
       relname
       ,stt.n_dead_tup
       ,(50 + 0.2 * stt.n_live_tup) ceiling -- if > n_dead_tup, autovaccum is triggered
FROM pg_stat_user_tables stt
WHERE 1=1
--    AND relname = 'foo'
ORDER BY stt.n_dead_tup DESC
;


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
