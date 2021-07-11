

VACUUM (VERBOSE, ANALYZE) vac_ins;


--
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

-- Visibility map
-- relallvisible = IF  all transactions
SELECT
   relname,
   relpages       page_count,          -- Number of pages
   relallvisible  visible_page_count   -- Number of pages that are visible to all transactions
FROM pg_class
WHERE 1=1
    AND relname = 'vac_ins'
;

VACUUM (VERBOSE, ANALYZE) vac_ins;

-- Scenario
BEGIN;
insert into vac_ins values(generate_series(1,20000),'aaaaaa');
-- page count has not changed
VACUUM (VERBOSE, ANALYZE) vac_ins;
-- page count has changed
COMMIT;
-- all-visible page count has not changed
VACUUM (VERBOSE, ANALYZE) vac_ins;
-- all-visible page count has changed