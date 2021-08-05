

DROP VIEW IF EXISTS stats_foo;

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
select * from stats_foo;

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



