-- https://www.postgresql.org/docs/13/sql-analyze.html
-- ANALYZE collects statistics about the contents of tables in the database, and stores the results in the pg_statistic system catalog.
-- Subsequently, the query planner uses these statistics to help determine the most efficient execution plans for queries.


DROP TABLE IF EXISTS foo;

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER CONSTRAINT value_unique UNIQUE
 );

INSERT INTO foo (value)
SELECT floor(random() * 2147483627 + 1)::int
FROM
    generate_series( 1, 1000000) -- 1 million => 40 seconds
ON CONFLICT ON CONSTRAINT value_unique DO NOTHING;


-- Generate dead tuples
DELETE FROM foo
WHERE MOD(id, 2) = 0;

-- Generate update
UPDATE foo SET value = -1 * value;
;


-- Gather statistics
ANALYZE VERBOSE foo;
-- [2021-07-11 14:27:34] [00000] analyzing "public.foo"
-- [2021-07-11 14:27:34] [00000] "foo": scanned 8848 of 8848 pages, containing 999748 live rows and 499878 dead rows; 30000 rows in sample, 999748 estimated total rows
-- [2021-07-11 14:27:34] completed in 135 ms

-- Statistics
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   stt.last_analyze,
   stt.analyze_count,
   stt.last_autoanalyze,
   stt.autoanalyze_count
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
;


-- More statistics
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   'events=>',
   stt.n_tup_ins,
   stt.n_tup_upd,
   stt.n_tup_hot_upd,  -- hot, see https://www.cybertec-postgresql.com/en/hot-updates-in-postgresql-for-better-performance/
   stt.n_tup_del,
   'analyze=>',
   stt.last_analyze,
   stt.analyze_count,
   stt.last_autoanalyze,
   stt.autoanalyze_count,
   'vacuum=>',
   stt.last_vacuum,
   stt.vacuum_count,
   stt.last_autovacuum,
   stt.autovacuum_count,
   'pg_stat_user_tables=>'
   ,stt.*
FROM pg_stat_user_tables stt
WHERE 1=1
    AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
;

-- https://pgstats.dev/