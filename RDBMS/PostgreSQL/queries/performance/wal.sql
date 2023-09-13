-- Get WAL size
SELECT
  name,
  setting size_megabytes
FROM pg_settings
WHERE name IN ('min_wal_size','max_wal_size')
;
-- name	size_megabytes
-- max_wal_size	1024 --1GB
-- min_wal_size	80

SHOW max_wal_size;


select name, setting
from pg_settings
where name like '%wal_size%' or name like '%checkpoint%' order by name
;

-- Toggle WAL on table

-- Deactivate WAL on creation

DROP TABLE IF EXISTS foo;

CREATE UNLOGGED TABLE foo(
    id INTEGER
);

-- WAL activated  : 3 seconds
-- WAL deactivated: 8 seconds
INSERT INTO foo (id) VALUES (generate_series( 1, 10000000))
;

TRUNCATE TABLE foo;

-- Deactivate WAL
ALTER TABLE foo SET UNLOGGED;

-- Reactivate WAL
ALTER TABLE foo SET LOGGED;


-- https://www.postgresql.org/docs/current/functions-admin.html
-- Current WAL position
SELECT
       pg_current_wal_lsn()
;
-- Run 1:  0/815483E0
-- Run 2: 0/9D3D0110

-- Get size between 2 positions
SELECT
 pg_size_pretty(
     pg_wal_lsn_diff('0/9D3D0110', '0/815483E0')
 )
;
-- 447 Mb


-- Measure WAL used form reference point
-- Works only in psql as it's using variables
-- https://franckpachot.medium.com/postgresql-measuring-query-activity-wal-size-generated-shared-buffer-reads-filesystem-reads-15d2f9b4ca1f

-- Step 1: setup reference point
SELECT
       *, pg_current_wal_lsn()
FROM pg_stat_database where datname=current_database() \gset
;

-- Step 2: run queries

-- Step 3: measure
select blks_hit - :blks_hit                                                         "blk hit",
       blks_read - :blks_read                                                       "blk read",
       tup_inserted - :tup_inserted                                                 "ins",
       tup_updated - :tup_updated                                                   "upd",
       tup_deleted - :tup_deleted                                                   "del",
       tup_returned - :tup_returned                                                 "tup ret",
       tup_fetched - :tup_fetched                                                   "tup fch",
       xact_commit - :xact_commit                                                   "commit",
       xact_rollback - :xact_rollback                                               "rbk",
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'pg_current_wal_lsn')) "WAL",
       pg_size_pretty(temp_bytes - :temp_bytes)                                     "temp"
from pg_stat_database
where datname = current_database();