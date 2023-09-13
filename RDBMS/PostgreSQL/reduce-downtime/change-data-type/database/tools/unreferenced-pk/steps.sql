-- 70 000 000 => 70 million records
-- time ./generate-unreferenced-pk 70000000
-- Generating 70000000 lines TO /tmp/unreferenced-pk.txt ...

-- Follow last written line
--❯ tail -n1  /tmp/unreferenced-pk.txt
-- 70 000 000

-- Follow size
-- ls -ltrh /tmp/unreferenced-pk.txt
-- -rw-rw-r-- 1 topi topi 591M août  13 09:58 /tmp/unreferenced-pk.txt

-- Copy in container - 3 s
-- docker cp /tmp/unreferenced-pk.txt database:/tmp/unreferenced-pk.txt

-- Create structure
DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo
(
    id INTEGER
);

TRUNCATE TABLE foo;

-- Import the file
COPY foo (id)
    FROM '/tmp/unreferenced-pk.txt'
    DELIMITER ',';
-- 30 s


-- Follow import progress
SELECT pg_size_pretty(pg_total_relation_size('foo'));
-- 2420 MB (finished)

SELECT *
FROM foo
--ORDER BY ctid DESC
;


--------------- Create the PK index  ----------------------------------

CREATE UNIQUE INDEX ndx_pk_foo ON foo (id);
-- 45 s

-- Monitor index creation
SELECT
    now()::TIME(0),
    a.query,
    p.phase,
    TRUNC(p.blocks_done / p.blocks_total ::real * 100) || '%' AS progress,
    p.blocks_total,
    p.blocks_done,
    p.tuples_total,
    p.tuples_done
FROM pg_stat_progress_create_index p
         JOIN pg_stat_activity a ON p.pid = a.pid;

SELECT pg_size_pretty(pg_indexes_size('foo'));
-- 1500 MB


--------------- Create the primary key  ----------------------------------

ALTER TABLE foo
    ADD CONSTRAINT foo_pkey PRIMARY KEY USING INDEX ndx_pk_foo;
-- 5s

INSERT INTO foo(id)
VALUES ((POWER(2, 32) / 2) + 1);
-- [22003] ERROR: integer out of range


--------------- Create a sequence ----------------------------------

SELECT
    MAX(id)
FROM foo;
-- 70 000 000

DROP SEQUENCE IF EXISTS foo_id_seq;
CREATE SEQUENCE foo_id_seq AS BIGINT START 70000001;
ALTER TABLE foo
    ALTER COLUMN id SET DEFAULT nextval('foo_id_seq');

GRANT ALL PRIVILEGES ON SEQUENCE foo_id_seq TO activity;

INSERT INTO foo DEFAULT VALUES;

SELECT *
FROM foo
WHERE id = 70000001;

--------------- Monitor type change ---------------------------------

-- new_id index creation
SELECT
    now()::TIME(0),
    a.query,
    p.phase,
    TRUNC(p.blocks_done / p.blocks_total ::real * 100) || '%' AS progress,
    p.blocks_total,
    p.blocks_done,
    p.tuples_total,
    p.tuples_done
FROM pg_stat_progress_create_index p
         JOIN pg_stat_activity a ON p.pid = a.pid;

-- new_id feeding progress
SELECT
    COUNT(1) migrated_rows,
    TRUNC(COUNT(1) / 700000000 ::real * 100) || '%' migrated_rows
FROM foo
WHERE new_id IS NOT NULL;
/*migrated_rows	migrated_rows
39100000	55%*/

-- Sessions
-- Session
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,ssn.usename user_name
  ,ssn.datname database_name
  ,ssn.client_port
  ,ssn.pid -- in database, not on client
  ,ssn.query
  ,ssn.state
  ,'pg_stat_activity=>'
  ,ssn.*
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.usename = 'activity'
--  AND ssn.datname = 'database'
  AND ssn.state = 'active'
--  AND ssn.query ILIKE '%VALUES%'
--   AND pid <> pg_backend_pid()
    --AND ssn.query = 'CREATE UNIQUE INDEX ndx_pk_foo ON foo(id)'
;



-- Statements + User + Database
SELECT
   --usr.rolname,
   --db.datname,
   stt.query query_text,
   'count=>',
   stt.calls,
   stt.rows  affected_rows,
   'time=>',
--   TRUNC(stt.total_exec_time) cumulated_excution_time_millis,
   TRUNC(stt.total_exec_time / 1000) cumulated_excution_time_s,
   TRUNC(stt.total_exec_time / 1000 / 60) cumulated_excution_time_min,
   stt.min_exec_time,
   TRUNC(stt.max_exec_time / 1000 / 60) max_excution_time_min,
   stt.max_exec_time,
   'wal=>'
   ,pg_size_pretty(wal_bytes) wal_size
   ,stt.wal_records  wal_count
   ,'temp=>'
   ,to_char(temp_blks_written, 'FM999G999G999G990')             AS temp_blocks_written
   ,pg_size_pretty(temp_blks_written * 8192)                    AS temp_size_written
   ,stt.*
FROM pg_stat_statements stt
    INNER JOIN pg_authid usr ON usr.oid = stt.userid
    INNER JOIN pg_database db ON db.oid = stt.dbid
WHERE 1=1
--    AND usr.rolname <> 'postgres'
    AND db.datname = 'database'
    AND stt.query ILIKE '%WITH rows AS %'
   -- AND stt.query = 'CREATE UNIQUE INDEX CONCURRENTLY idx ON foo(new_id)'
ORDER BY
    stt.total_exec_time DESC
;

-- 33 min pour 70%
-- 45 min pour 100%



-- Show temporary files used by query
SELECT
    query                                                       AS query,
    to_char(temp_blks_written, 'FM999G999G999G990')             AS temp_blocks_written,
    pg_size_pretty(temp_blks_written * 8192)                    AS temp_size_written,
    interval '1 millisecond' * total_exec_time                  AS total_exec_time,
    to_char(calls, 'FM999G999G999G990')                         AS ncalls,
    total_exec_time / calls                                     AS avg_exec_time_ms,
    interval '1 millisecond' * (blk_read_time + blk_write_time) AS sync_io_time
FROM pg_stat_statements
WHERE userid = (SELECT usesysid FROM pg_user WHERE usename = current_user LIMIT 1)
--  AND temp_blks_written > 0
  AND query ILIKE '%UPDATE foo%'
ORDER BY
   --temp_blks_written DESC
    total_exec_time DESC
LIMIT 20
;
-- WITH ROWS
-- 202 MB TEMP



--EXPLAIN ANALYZE VERBOSE
SELECT id
FROM foo
WHERE new_id IS NULL
LIMIT 100000
;

SELECT POWER(10,7);
-- 10 000 000

-- table de 700 millions
-- 100 000 => 4 min
-- 1 000 000 => 4 min
-- 10 000 000 => 10 min
--EXPLAIN ANALYZE VERBOSE
WITH rows AS (
    SELECT id
      FROM foo
      WHERE new_id IS NULL
      LIMIT 10000000
  --    LIMIT 100000
)
UPDATE foo
SET new_id = id
WHERE EXISTS (SELECT * FROM rows WHERE foo.id = rows.id);

-- QUERY PLAN
-- Update on foo  (cost=289750.11..17287759.28 rows=356169008 width=46) (actual time=245133.865..245135.273 rows=0 loops=1)
--   ->  Hash Join  (cost=289750.11..17287759.28 rows=356169008 width=46) (actual time=934.654..244585.648 rows=100000 loops=1)
--         Hash Cond: (foo.id = rows.id)
--         ->  Seq Scan on foo  (cost=0.00..10275319.15 rows=712338015 width=10) (actual time=270.965..106334.430 rows=700000000 loops=1)
--         ->  Hash  (cost=289747.61..289747.61 rows=200 width=32) (actual time=167.389..168.303 rows=100000 loops=1)
--               Buckets: 131072 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 7274kB
--               ->  HashAggregate  (cost=289745.61..289747.61 rows=200 width=32) (actual time=118.831..141.717 rows=100000 loops=1)
--                     Group Key: rows.id
--                     Batches: 1  Memory Usage: 14369kB
--                     ->  Subquery Scan on rows  (cost=0.00..289495.61 rows=100000 width=32) (actual time=0.213..54.043 rows=100000 loops=1)
--                           ->  Limit  (cost=0.00..288495.61 rows=100000 width=4) (actual time=0.027..28.024 rows=100000 loops=1)
--                                 ->  Seq Scan on foo foo_1  (cost=0.00..10275319.15 rows=3561690 width=4) (actual time=0.021..17.732 rows=100000 loops=1)
--                                       Filter: (new_id IS NULL)
-- Planning Time: 3.816 ms
-- JIT:
--   Functions: 19
--   Options: Inlining true, Optimization true, Expressions true, Deforming true
--   Timing: Generation 37.693 ms, Inlining 55.975 ms, Optimization 143.699 ms, Emission 67.952 ms, Total 305.318 ms
-- Execution Time: 245194.238 ms
--


--------------- Create dump  ----------------------------------

-- Create dump on table (no schema, data including indexes) - 20s
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo --data-only database

-- pg_dump: saving search_path =
-- pg_dump: processing data for table "public.foo"
-- pg_dump: dumping contents of table "public.foo"

-- Monitor progress
-- ls -ltrh /tmp/foo.dmp
-- 6.5G août  12 21:01 /tmp/foo.dmp

--------------- Restore dump (test)  ----------------------------------

CREATE TABLE foo
(
    id INTEGER
);


TRUNCATE TABLE foo;

-- Restore with psql uncompressed file and view progress - 3 min
-- pv /tmp/foo.dmp | psql postgres://postgres@localhost:5432/database