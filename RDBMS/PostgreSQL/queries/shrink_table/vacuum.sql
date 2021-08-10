--------------------
-- VACUUM -----------
--------------------

-- Reclaims storage occupied by dead tuple, concurrently
-- => update the visibility map
VACUUM foo;
VACUUM VERBOSE foo;
VACUUM VERBOSE ANALYZE foo;

-- Reclaims storage occupied by dead tuple, blocking
-- => rewrite whole table
VACUUM FULL foo;
VACUUM FULL VERBOSE foo;
VACUUM FULL VERBOSE ANALYZE foo;


-- https://www.postgresql.org/docs/current/sql-vacuum.html

-- VACUUM reclaims storage occupied by dead tuple
-- Extra space is not returned to the operating system; it's just kept available for re-use within the same table.
-- To do this, it must make sure no transaction ever use dead tuples. This is achieved by updating the visibility map.
-- As a side effect, a visibility map refresh will support index-only scan

-- VACUUM FULL reclaim more space, but takes much longer and exclusively locks the table.
-- This method also requires extra disk space, since it writes a new copy of the table and doesn't release the old copy until the operation is complete

-- VACUUM ANALYZE performs a VACUUM and then an ANALYZE for each selected table.


DROP TABLE IF EXISTS vac_ins;

CREATE TABLE vac_ins(c1 int, c2 char(500));
CREATE INDEX idx_vac_ins ON vac_ins(c1);

INSERT INTO
    vac_ins
VALUES(
    generate_series(1,200000),
   'aaaaaa'
);

DELETE FROM vac_ins WHERE c1 > 2000
;

DELETE FROM vac_ins
;


-- Statistics
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'vac_ins'
--   AND stt.last_autoanalyze IS NOT NULL
;

-- Vacuum
VACUUM  vac_ins;

-- Vacuum verbose
VACUUM (VERBOSE) vac_ins;
-- [2021-07-11 14:19:13] [00000] vacuuming "public.vac_ins"
-- [2021-07-11 14:19:13] [00000] scanned index "idx_vac_ins" to remove 792000 row versions
-- [2021-07-11 14:19:13] [00000] "vac_ins": removed 792000 row versions in 52814 pages
-- [2021-07-11 14:19:13] [00000] index "idx_vac_ins" now contains 40180 row versions in 1994 pages
-- [2021-07-11 14:19:13] [00000] "vac_ins": found 792000 removable, 385 nonremovable row versions in 52826 out of 55479 pages
-- [2021-07-11 14:19:13] completed in 5 s 69 ms



-- After a VACUUM, there should not be any dead tuple (except if some transactions are pending)
-- https://www.cybertec-postgresql.com/en/reasons-why-vacuum-wont-remove-dead-rows/
-- Statistics
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'vac_ins'
--   AND stt.last_autoanalyze IS NOT NULL
;

-- With stats
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

VACUUM (VERBOSE) vac_ins;

-- Scenario
BEGIN;
insert into vac_ins values(generate_series(1,20000),'aaaaaa');
-- page count has not changed
VACUUM vac_ins;
-- page count has changed
COMMIT;
-- all-visible page count has not changed
VACUUM vac_ins;
-- all-visible page count has changed




-------------- ROLLBACK ------------
-- You can get dead tuples with any update/delete

BEGIN;

INSERT INTO
    vac_ins
VALUES(
    generate_series(1,200000),
   'aaaaaa'
);

ROLLBACK;

-- Statistics
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'vac_ins'
--   AND stt.last_autoanalyze IS NOT NULL
;

-- vac_ins,0,200000
