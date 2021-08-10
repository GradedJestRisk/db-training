-- https://habr.com/en/company/postgrespro/blog/469087/


---------------------------------------------------
-- Bacics     --
---------------------------------------------------

-- Hierarchy:
-- - database
-- - relation (table, index, sequence..)
-- - fork with type (eg. FSM) (1:N with relation)
-- - segment (1:N with fork)
-- - page/block (usually 8Kb)

SELECT
    current_setting('block_size')
;
-- 8192

---------------------------------------------------
-- Data sample    --
---------------------------------------------------

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER PRIMARY KEY
 );

INSERT INTO foo (id) VALUES (1);

SELECT * FROM foo
;


---------------------------------------------------
-- Database directory     --
---------------------------------------------------

-- Database data directory
SELECT setting FROM pg_settings WHERE name = 'data_directory';
-- /var/lib/postgresql/data

SHOW data_directory;
-- /var/lib/postgresql/data

-- docker exec -it database bash
-- echo $PGDATA
-- /var/lib/postgresql/data

-- Instance directory
SELECT oid FROM pg_database WHERE datname = 'postgres';
-- 13342

---------------------------------------------------
-- Relation directory  --
---------------------------------------------------

-- Relation directory
SELECT relfilenode FROM pg_class WHERE relname = 'foo';
-- 16489

-- Full path ( database data directory + relation directory)
SELECT
       pg_relation_filepath('foo') relative_path,
       '/var/lib/postgresql/data/' || pg_relation_filepath('foo') absolute_path,
       'ls -l /var/lib/postgresql/data/' || pg_relation_filepath('foo') list
;
-- base/13442/16489
-- ls -l /var/lib/postgresql/data/base/13442/16489

---------------------------------------------------
-- Initialization fork (UNLOGGED table only)     --
---------------------------------------------------

ALTER TABLE foo SET UNLOGGED;

SELECT
       pg_relation_filepath('foo'),
       'ls -l /var/lib/postgresql/data/' || pg_relation_filepath('foo') || '_init';
-- base/13442/16475
-- ls -l /var/lib/postgresql/data/base/13442/16475

ALTER TABLE foo SET LOGGED;
-- ls: /var/lib/postgresql/data/base/13442/16485_init: No such file or directory

---------------------------------------------------
-- Free space map (FSM)     --
---------------------------------------------------

-- Keeps track of the availability of free space inside pages.
-- This space is constantly changing: it decreases when new versions of rows are added and increases during vacuuming.
-- The free space map is used during insertion of new row versions in order to quickly find a suitable page, where the data to be added will fit.

-- Force creation
VACUUM foo;

SELECT
       pg_relation_filepath('foo'),
       'ls -l /var/lib/postgresql/data/' || pg_relation_filepath('foo') || '_fsm';
-- base/13442/16489
-- ls -l /var/lib/postgresql/data/base/13442/16489_fsm

---------------------------------------------------
-- Visibility map (VM)     --
---------------------------------------------------

-- Pages that only contain up-to-date row versions are marked by one bit.
-- Roughly, it means that when a transaction tries to read a row from such a page, the row can be shown without checking its visibility.

-- Force creation
VACUUM foo;

SELECT
       pg_relation_filepath('foo'),
       'ls -l /var/lib/postgresql/data/' || pg_relation_filepath('foo') || '_vm';
-- base/13442/16489
-- ls -l /var/lib/postgresql/data/base/13442/16489_vm

---------------------------------------------------
-- Page     --
---------------------------------------------------

CREATE EXTENSION pageinspect;

-- Page partition
--        0  +-----------------------------------+
--           | header                            |
--       24  +-----------------------------------+
--           | array of pointers to row versions |
--    lower  +-----------------------------------+
--           | free space                        |
--    upper  +-----------------------------------+
--           | row versions                      |
--  special  +-----------------------------------+
--           | special space                     |
-- pagesize  +-----------------------------------+

-- Get page 0 partition size
SELECT lower, upper, special, pagesize
FROM page_header(
    get_raw_page('foo',0)
);
-- 28,8160,8192,8192
