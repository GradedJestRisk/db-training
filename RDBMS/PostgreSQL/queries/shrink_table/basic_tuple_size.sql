--------------------------------------------------
------ DISCLAIMER       --------------------------
--------------------------------------------------

-- https://stackoverflow.com/questions/13570613/making-sense-of-postgres-row-sizes
-- Calculation of row size is much more complex than that.
-- Storage is typically partitioned in 8 kB data pages.
-- There is a small fixed overhead per page, possible remainders not big enough to fit another tuple,
-- and more importantly dead rows or a percentage initially reserved with the FILLFACTOR setting (100% per default)
--
-- And there is even more overhead per row (tuple):
--  - an item identifier of 4 bytes at the start of the page,
--  - the HeapTupleHeader of 23 bytes and alignment padding.
--  The start of the tuple header as well as the start of tuple data are aligned at a multiple of MAXALIGN, which is 8 bytes on a typical 64-bit machine.
--  Some data types require alignment to the next multiple of 2, 4 or 8 bytes.


--------------------------------------------------
------ Single column, single row   ---------------
--------------------------------------------------

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id INTEGER
 );

INSERT INTO foo (id) VALUES (1);
VACUUM (VERBOSE, ANALYZE) foo;

-- column size
SELECT pg_column_size('foo') size_bytes;
-- 4

-- table size
SELECT * FROM pg_table_size('foo') size_bytes;
-- 40 690

-- pages
SELECT
 relpages page_count,
 (relpages * 8 * 1024) total_size_bytes
FROM pg_class WHERE relname = 'foo';
-- 1 page, 8 192 bytes

SELECT
    pg_size_pretty(tuple_len)       alive_size,
    pg_size_pretty(dead_tuple_len)  dead_size,
    pg_size_pretty(free_space)      unused_size,
    pg_size_pretty(table_len)       total_size,
    pg_size_pretty(table_len - tuple_len - dead_tuple_len - free_space) overhead
FROM pgstattuple('foo')
;
-- Most of the page is empty (8128)
-- data is only 28 bytes

-- overhead take most of size
SELECT
     pg_table_size('foo')   total,
     pg_column_size('foo')  "data",
     (pg_table_size('foo') - pg_column_size('foo'))  overhead
;



--------------------------------------------------
------ Single column   --------------------------
--------------------------------------------------

--------------------------------
-- Text, identical (compression)

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   bar    TEXT
 );

INSERT INTO foo
  (bar)
SELECT
  'same'
FROM
    generate_series( 1, 1000000) -- 1 million => 2 seconds
;

VACUUM (VERBOSE, ANALYZE) foo;

SELECT *
FROM foo;

-- Integer
SELECT pg_column_size('same'::text);
-- 8 bytes

-- column size
SELECT pg_column_size('foo') size_bytes;
-- 4

SELECT * FROM pg_table_size('foo') size_bytes;
-- 36 290 560

-- Pages
SELECT
   relpages   page_count,
   (relpages * 8 * 1000) total_size_bytes
FROM pg_class WHERE relname = 'foo';

-- 4 425 pages
-- 35 400 000


--------------------------------
-- Integer, random

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER PRIMARY KEY
 );

-- CREATE TABLE foo (
--    id    INTEGER
--  );
--
-- CREATE UNLOGGED TABLE foo (
--    id    INTEGER PRIMARY KEY
--  );


-- INSERT INTO foo (id)
-- SELECT *
-- FROM generate_series( 1, power(10, 2)::int) -- 100 => 2 seconds
-- ;

INSERT INTO foo   (id)
SELECT *
FROM generate_series( 1, power(10, 6)::int) -- 1 million => 10 seconds
;

-- INSERT INTO foo   (id)
-- SELECT *
-- FROM generate_series( 1, power(10, 7)::int) -- 10 million => 1 minute
-- ;

VACUUM (VERBOSE, ANALYZE) foo; -- for 10 million => 2 minutes
SELECT * FROM foo;

-- Integer
SELECT pg_column_size(1::integer);
-- 4 bytes

-- column size
SELECT pg_column_size('foo') size_bytes;
-- 4

-- tuple size as text
SELECT
       octet_length(t::text)
FROM foo AS t WHERE id=1;
-- 3

SELECT COUNT(1) FROM foo;
-- 1 000 000

SELECT * FROM pg_table_size('foo') size_bytes;
-- should be  4 000 000
-- is        36 282 368


-- should be    400 000 000
-- is         2 200 608 768 (219 bytes per row)


-- integer is 4 bytes
-- => bytes per row: 4
-- 10^6 rows
-- size should be 4.10^6 bytes
-- 4  000 000 bytes (4Mb)
-- actual is
-- 36 249 600 bytes (35Mb)
-- => bytes per row: 36 => why is that ?

-- There are some hidden properties, causing overhead

SELECT
  'data=>',
  id,
  'hidden properties=>',
  ctid ctid_physical_location,
  xmin transaction_number_created_row,
  xmax transaction_number_changed_row
FROM foo;

-- System columns have a 90% overhead then (30 Mbytes on 35 Mbytes)

-- Pages
SELECT
   relpages   page_count,
   (relpages * 8 * 1000) total_size_bytes
FROM pg_class WHERE relname = 'foo';
-- 4 425 pages
-- 35 400 000 bytes

--------------------------------------------------
------ Several columns  --------------------------
--------------------------------------------------

-- UUID size
SELECT pg_column_size('60c0d3d5-b35c-47d4-853c-36bee508fb5f'::uuid);
-- 16 bytes

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id SERIAL PRIMARY KEY,
   c1 UUID,
   c2 UUID,
   c3 UUID,
   c4 UUID,
   c5 UUID,
   c6 UUID,
   c7 UUID,
   c8 UUID,
   c9 UUID,
   c10 UUID
 );

INSERT INTO foo
  (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
SELECT
  uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4()
FROM
    generate_series( 1, 100000) -- 100 000 => 6 seconds
;

SELECT * FROM foo;

SELECT COUNT(1) FROM foo;
-- 100 000

-- Actual size
SELECT
   pg_table_size('foo') size_bytes,
   pg_table_size('foo') / 100000 row_size_bytes
;
-- 20 021 248
-- 200 bytes

-- Expected size
SELECT
   4 + pg_column_size('60c0d3d5-b35c-47d4-853c-36bee508fb5f'::uuid) * 10;
-- 164 bytes

-- System columns have a 10% overhead then

