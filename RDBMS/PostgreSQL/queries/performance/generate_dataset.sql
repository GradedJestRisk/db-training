-- Reactivate WAL
-- SET LOGGED rewrites the table using the WAL (essentially doing the whole operation), and rewrites the indexes.
-- https://dba.stackexchange.com/questions/195780/set-postgresql-table-to-logged-after-data-loading

-- The advantage to loading as unlogged and then altering to logged would come if
-- you were doing some kind of large-scale manipulation of the table (update ... from ...)
-- after loading it but before setting to logged, or if you for some reason couldn't load it with COPY but had to use individual INSERT statements. ' ||
-- 'Neither of those apply to you, so I wouldn't expect this 2-step method to be of any benefit.

-- ALTER TABLE foo SET UNLOGGED;
-- ALTER TABLE foo SET LOGGED;


-----------------------------------------------
-- Table with single INTEGER and PK         ---
-----------------------------------------------

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER PRIMARY KEY
 );



INSERT INTO foo (id)
SELECT *
FROM
  --generate_series( 1, 5000000) -- 5 million => 2 minutes
    --generate_series( 1, 1000000) -- 1 million => 40 seconds
    generate_series( 1, 10000000) -- 10 million => 33 seconds ?
;

DROP SEQUENCE IF EXISTS foo_id_seq;
CREATE SEQUENCE foo_id_seq AS INTEGER START 1000001;
ALTER TABLE foo ALTER COLUMN id SET DEFAULT nextval('foo_id_seq');

INSERT INTO foo DEFAULT VALUES;

SELECT * FROM foo ORDER by id DESC;



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



--------------- Generate file ----------------------------------


-- Generate 4Gb file with INT_MAX_RANGE identical lines "1" (5 minutes)
-- yes "1" | head -n 2147483627 > /tmp/foo.txt

-- Generate Gb file whit consecutive INTEGER values lines (5 minutes)
-- gcc generate-foo-data.c -o generate-foo-data

-- Launch
-- ./generate-foo-data

-- Follow size
-- ls -ltrh ~/foo.txt
-- 6,5G août  12 19:43 /tmp/foo.txt -- 700 million

-- Follow last written line
-- tail -n1  /tmp/foo.txt
--- 1 421 495 199
--  2 147 483 627 <= goal

-- Copy in container (< 5 minutes)
-- docker cp ~/foo.txt database:/tmp/foo.txt

-- Check
-- docker exec -it database bash
-- ls -ltrh /tmp/foo.txt
-- 21.0G Aug 12 10:16 /tmp/foo.txt --2 billion


--------------- COPY ----------------------------------

-- Create structure
DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER
 );


-- Import the file
COPY foo(id)
FROM '/tmp/foo.txt'
DELIMITER ',';
-- 15 m for 2 billion
-- 6m for 700 million
-- COPY 2147483627


-- Follow import progress
SELECT pg_size_pretty(pg_total_relation_size('foo'));
-- Will reach 73Gb

SELECT * FROM foo
--ORDER BY ctid DESC
;

-- SELECT COUNT(1) FROM foo; --More than 30 secs..

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
-- 24 Gb for 700 million
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


--------------- Create a sequence ----------------------------------

SELECT MAX(id) FROM foo;
-- 700000000

DROP SEQUENCE IF EXISTS foo_id_seq;
CREATE SEQUENCE foo_id_seq AS BIGINT START 700000001;
ALTER TABLE foo ALTER COLUMN id SET DEFAULT nextval('foo_id_seq');

INSERT INTO foo DEFAULT VALUES;
SELECT MAX (id) FROM foo;


--------------- Create the PK index  ----------------------------------

CREATE UNIQUE INDEX ndx_pk_foo ON foo(id);
-- 28 min for 2 billion
-- min for 700 million

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
-- 45 GB for 2 billion


--------------- Create the primary key  ----------------------------------

ALTER TABLE foo ADD CONSTRAINT pk_foo PRIMARY KEY USING INDEX ndx_pk_foo;
-- ? minutes for 2 billion
-- 9 minutes for 700 million

INSERT INTO foo(id)  VALUES ((POWER(2, 32) / 2) + 1 );
-- [22003] ERROR: integer out of range


--------------- Create dump  ----------------------------------

-- Create dump on table (no schema, data including indexes)
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo --data-only database
-- pg_dump: saving search_path =
-- pg_dump: processing data for table "public.foo"
-- pg_dump: dumping contents of table "public.foo"

-- Monitor progress
-- ls -ltrh /tmp/foo.dmp
-- 6.5G août  12 21:01 /tmp/foo.dmp


--------------- Restore dump (test)  ----------------------------------

TRUNCATE TABLE foo;

-- Restore with psql uncompressed
-- psql postgres://postgres@localhost:5432/database database < /tmp/foo.dmp

-- Restore with psql uncompressed file and view progress
-- pv /tmp/foo.dmp | psql postgres://postgres@localhost:5432/database


-- Restore with psql compressed file and view progress
-- pv foo.sql.gz | zcat | psql postgres://postgres@localhost:5432/database


-- Monitor progress / data
SELECT pg_size_pretty(pg_relation_size('foo'));
-- for 700 million

-- Monitor progress / indexes
SELECT pg_size_pretty(pg_indexes_size('foo'));
-- 45 GB for 2 billion

-- Indexes
-- Given table name
SELECT
       'Indexes=>' qry
       ,ndx.indexname ndxl_nm
       ,ndx.tablename tbl_nm
       ,ndx.indexdef  dfn
       ,'pg_indexes=>' qry
       ,ndx.*
FROM pg_indexes ndx
WHERE 1=1
    --AND ndx.schemaname <> 'pg_catalog'
    AND ndx.tablename = 'foo'
;

-- Invalid indexes
-- Given table name
SELECT
    'index=>',
    cls.relname       table_name,
    ndx.indisvalid    is_valid,
    ndx.indisunique   is_unique,
     ndx.indisprimary is_primary,
    'pg_index=>',
    ndx.*
FROM pg_index ndx
      INNER JOIN pg_class cls ON ndx.indexrelid = cls.oid
WHERE 1=1
--    AND ndx.indisvalid IS FALSE
--    AND ndx.indisprimary IS TRUE
    AND cls.relname  = 'ndx_pk_foo'
;

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
-- 24 GB	760 kB	6112 kB	24 GB	15 GB	38 GB

-----------------------------------------------------------------

SET statement_timeout = 50;

SELECT relation::regclass, * FROM pg_locks WHERE NOT GRANTED;

-- =$ copy test (payload) from program 'ruby -e "10000000.times { puts (0...50).map { (97 + rand(26)).chr }.join}"'
-- COPY 10000000

-- Monitor with pipe viewer
-- https://catonmat.net/unix-utilities-pipe-viewer
-- pv access.log | gzip > access.log.gz

SELECT COUNT(1) FROM foo where new_id IS NULL;
--


