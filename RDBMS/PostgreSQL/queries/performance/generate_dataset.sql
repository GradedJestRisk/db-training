

-- Reactivate WAL
-- SET LOGGED rewrites the table using the WAL (essentially doing the whole operation), and rewrites the indexes.
-- https://dba.stackexchange.com/questions/195780/set-postgresql-table-to-logged-after-data-loading

-- The advantage to loading as unlogged and then altering to logged would come if
-- you were doing some kind of large-scale manipulation of the table (update ... from ...)
-- after loading it but before setting to logged, or if you for some reason couldn't load it with COPY but had to use individual INSERT statements. ' ||
-- 'Neither of those apply to you, so I wouldn't expect this 2-step method to be of any benefit.


ALTER TABLE foo SET LOGGED; -- More than s




-----------------------------------------------
-- Table with random INTEGER and PK         ---
-----------------------------------------------

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER UNIQUE NOT NULL
 );


INSERT INTO foo
  (value)
SELECT
  floor(random() * 2147483627 + 1)::int
FROM
  --generate_series( 1, 5000000) -- 5 million => 2 minutes
    generate_series( 1, 1000000) -- 1 million => 40 seconds
ON CONFLICT ON CONSTRAINT referenced_value_unique DO NOTHING;

-----------------------------------------------
-- Table with INTEGER SERIAL column, full   ---
-- Use INSERT
-----------------------------------------------

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id   INTEGER
 );

-- Deactivate WAL
ALTER TABLE foo SET UNLOGGED;

INSERT INTO foo
  (value)
SELECT
   *
FROM
    generate_series( 1, 2147483627);

-- Reactivate WAL
ALTER TABLE foo SET LOGGED;


-----------------------------------------------
-- Table with INTEGER SERIAL column, full   ---
-- Use COPY
-----------------------------------------------

-- why use copy ?
-- https://www.depesz.com/2007/07/05/how-to-insert-data-to-database-as-fast-as-possible/

-- Discard bad records in file input
-- https://github.com/brainbuz/pgbulkload

-- File size when content is
-- 1
-- 2
-- (..)
-- max_integer
SELECT
    POWER(2, 4 * 8 ) / 2                      line_count,
    length('2147483648') + 1                  max_char_count_line, -- with newline
    POWER(2, 4 * 8 ) * length('2147483648')   max_char_count_file, -- 42 949 672 960
    1                                         byte_per_char,
    pg_size_pretty(42949672960)               size_disk_human
;

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER
 );


-- Generate 4Gb file with INT_MAX_RANGE identical lines "1" (5 minutes)
-- yes "1" | head -n 2147483627 > /tmp/foo.txt

-- Generate Gb file whit consecutive INTEGER values lines (5 minutes)
-- gcc generate-foo-data.c -o generate-foo-data

-- Launch
-- ./generate-foo-data

-- Follow size
-- ls -ltrh ~/foo.txt

-- Follow last written line
-- tail -n1  /tmp/foo.txt
--- 1 421 495 199
--  2 147 483 627 <= goal

-- Copy in container (< 5 minutes)
-- docker cp ~/foo.txt database:/tmp/foo.txt

-- Check
-- docker exec -it database bash
-- ls -ltrh /tmp/foo.txt
-- -r--r--r--    1 1000     1000       21.0G Aug 12 10:16 /tmp/foo.txt

-- Import the file (15 minutes)
COPY foo(id)
FROM '/tmp/foo.txt'
DELIMITER ',';
-- COPY 2147483627

-- Follow import progress
SELECT pg_size_pretty(pg_total_relation_size('foo'));
-- Will reach 73Gb

SELECT * FROM foo
--ORDER BY ctid DESC
;

SELECT COUNT(1) FROM foo; --More than 30 secs..

--VACUUM VERBOSE ANALYZE foo;

-- Statistics
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup
FROM pg_stat_user_tables stt
WHERE relname = 'foo'
;
--  relname | n_live_tup | n_dead_tup
-- ---------+------------+------------
--  foo     | 2147483640 |          0


SELECT pg_size_pretty(pg_total_relation_size('foo'));
-- 73 GB

-- Details: everything is in core data
SELECT
    pg_size_pretty(pg_relation_size('foo'))        core
  , pg_size_pretty(pg_relation_size('foo', 'vm'))  visibility
  , pg_size_pretty(pg_relation_size('foo', 'fsm')) free_space
  , pg_size_pretty(pg_table_size('foo'))           data_with_toast
  , pg_size_pretty(pg_indexes_size('foo'))         indexs
  , pg_size_pretty(pg_total_relation_size('foo'))  complete
;

-- core	visibility	free_space	data_with_toast	indexs	complete
-- 72 GB	0 bytes	18 MB	73 GB	0 bytes	73 GB


CREATE UNIQUE INDEX ndx_pk_foo ON foo(id); -- 28 min

-- Monitor index creation
SELECT
  now()::TIME(0),
  a.query,
  p.phase,
  p.blocks_total,
  p.blocks_done,
  p.tuples_total,
  p.tuples_done
FROM pg_stat_progress_create_index p
JOIN pg_stat_activity a ON p.pid = a.pid;

SELECT pg_size_pretty(pg_indexes_size('foo'));
-- 45 GB

ALTER TABLE foo ADD CONSTRAINT pk_foo PRIMARY KEY USING INDEX ndx_pk_foo; -- 2 minutes

INSERT INTO foo(id)  VALUES ((POWER(2, 32) / 2) + 1 );
-- [22003] ERROR: integer out of range

-- Create dump on table (no schema, data including indexes)
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo --data-only database

-- Restore with psql and view progress
-- psql psql postgres://postgres@localhost:5432/database database < dumpfile
-- pv foo.sql.gz | zcat | psql postgres://postgres@localhost:5432/database

-----------------------------------
-- Duplicate table               --
-----------------------------------

DROP TABLE new_foo;

-- Structure
CREATE TABLE new_foo AS TABLE foo WITH NO DATA;

CREATE TABLE new_foo (
    LIKE foo
--     INCLUDING DEFAULTS
--     INCLUDING CONSTRAINTS
--     INCLUDING INDEXES
    INCLUDING ALL
);


-- Structure and data
CREATE TABLE new_foo AS TABLE foo;


SELECT * FROM new_foo
;

-- Copy data manually
INSERT INTO new_foo SELECT * FROM foo
;


-----------------------------------------------------------------

SET statement_timeout = 50;

SELECT relation::regclass, * FROM pg_locks WHERE NOT GRANTED;

-- =$ copy test (payload) from program 'ruby -e "10000000.times { puts (0...50).map { (97 + rand(26)).chr }.join}"'
-- COPY 10000000

-- Monitor with pipe viewer
-- https://catonmat.net/unix-utilities-pipe-viewer
pv access.log | gzip > access.log.gz
