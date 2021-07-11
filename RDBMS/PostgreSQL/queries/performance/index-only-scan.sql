-----------------------
-- Index-only scans ---
-----------------------

-- TL;DR: read data more quickly if it stored in an index

-- https://www.postgresql.org/docs/10/indexes-index-only-scans.html
-- An ordinary index scan, each row retrieval requires fetching data from both the index and the heap.
-- Furthermore, while the index entries that match a given indexable WHERE condition are usually close together in the index,
-- the table rows they reference might be anywhere in the heap.
-- The heap-access portion of an index scan thus involves a lot of random access into the heap, which can be slow.

-- To solve this performance problem, PostgreSQL supports index-only scans, which can answer queries from an index alone without any heap access.
-- The basic idea is to return values directly out of each index entry instead of consulting the associated heap entry.

-- Restrictions:
-- - the index type must support index-only scans
-- - the query must reference only columns stored in the index

-- Additional requirement: it must verify that each retrieved row be “visible” to the query's MVCC snapshot.
-- Visibility information is not stored in index entries, only in heap entries; so at first glance it would seem that every row retrieval would require a heap access anyway.
-- And this is indeed the case, if the table row has been modified recently. '
-- 'However, for seldom-changing data there is a way around this problem. '
-- 'PostgreSQL tracks, for each page in a table's heap, whether all rows stored in that page are old enough to be visible to all current and future transactions.
-- This information is stored in a bit in the table's visibility map. '
-- 'An index-only scan, after finding a candidate index entry, checks the visibility map bit for the corresponding heap page. '
-- 'If it's set, the row is known visible and so the data can be returned with no further work.
-- If it's not set, the heap entry must be visited to find out whether it's visible, so no performance advantage is gained over a standard index scan.
-- Even in the successful case, this approach trades visibility map accesses for heap accesses; but since the visibility map is four orders of magnitude smaller
-- than the heap it describes, far less physical I/O is needed to access it. In most situations the visibility map remains cached in memory all the time.
--
-- In short, while an index-only scan is possible given the two fundamental requirements,
-- => it will be a win only if a significant fraction of the table's heap pages have their all-visible map bits set.
-- But tables in which a large fraction of the rows are unchanging are common enough to make this type of scan very useful in practice.


---------------------
-- Visibility map ---
---------------------

-- https://www.postgresql.org/docs/13/storage-vm.html
-- The map is conservative in the sense that
-- -  whenever a bit is set, we know the condition is true,
-- -  if a bit is not set, it might or might not be true.
--
-- Visibility map bits are only set by vacuum, but are cleared by any data-modifying operations on a page.

-- API in pg_visibility
-- https://www.postgresql.org/docs/13/pgvisibility.html

-- Visibility map
-- relallvisible = IF visible to all transactions
SELECT
   relname
   ,relpages       page_count          -- Number of pages
   ,relallvisible  visible_page_count   -- Number of pages that are visible to all transactions
   ,(relallvisible / relpages) pct_visible
FROM pg_class
WHERE 1=1
    AND relname = 'vac_ins'
;


---------------------
-- INSERTs ---
---------------------

-- Starting with PG 13, the visibility map is updated by VACUUM even if ony INSERT took place
-- http://amitkapila16.blogspot.com/2020/05/improved-autovacuum-in-postgresql-13.html


-- Deactivate
ALTER SYSTEM SET autovacuum_vacuum_insert_threshold=-1;

-- Activate
ALTER SYSTEM SET autovacuum_vacuum_insert_threshold=10000;
SHOW autovacuum_vacuum_insert_threshold;
-- 1000 as default

DROP TABLE IF EXISTS vac_ins;
create table vac_ins(c1 int, c2 char(500));
create index idx_vac_ins on vac_ins(c1);

INSERT INTO
    vac_ins
VALUES(
    generate_series(1,200000),
   'aaaaaa'
);

DELETE FROM vac_ins WHERE c1 > 2000
;

-- VACUUM after massive INSERT => no rows removed, but visibility map has been updated, so index-scan only can take place
-- 021-07-11 10:50:44.220 UTC [107] DEBUG:  vac_ins: vac: 0 (threshold 96050), ins: 200000 (threshold 97000), anl: 200000 (threshold 48050)
-- 2021-07-11 10:50:44.220 UTC [107] DEBUG:  autovac_balance_cost(pid=107 db=16384, rel=16389, dobalance=yes cost_limit=200, cost_limit_base=200, cost_delay=2)
-- 2021-07-11 10:50:44.220 UTC [107] DEBUG:  CommitTransaction(1) name: unnamed; blockState: STARTED; state: INPROGRESS, xid/subid/cid: 0/1/0
-- 2021-07-11 10:50:44.220 UTC [107] DEBUG:  StartTransaction(1) name: unnamed; blockState: DEFAULT; state: INPROGRESS, xid/subid/cid: 0/1/0
-- 2021-07-11 10:50:44.221 UTC [107] DEBUG:  vacuuming "public.vac_ins"
-- 2021-07-11 10:50:44.245 UTC [49] DEBUG:  snapshot of 0+0 running transaction ids (lsn 0/1CD7B800 oldest xid 524 latest complete 523 next xid 524)
-- 2021-07-11 10:50:44.695 UTC [107] DEBUG:  index "idx_vac_ins" now contains 290479 row versions in 1429 pages
-- 2021-07-11 10:50:44.695 UTC [107] DETAIL:  0 index row versions were removed.
-- 	0 index pages have been deleted, 0 are currently reusable.
-- 	CPU: user: 0.00 s, system: 0.00 s, elapsed: 0.01 s.
-- 2021-07-11 10:50:44.695 UTC [107] CONTEXT:  while cleaning up index "idx_vac_ins" of relation "public.vac_ins"
-- 2021-07-11 10:50:44.695 UTC [107] DEBUG:  "vac_ins": found 0 removable, 200000 nonremovable row versions in 13334 out of 45334 pages
-- 2021-07-11 10:50:44.695 UTC [107] DETAIL:  0 dead row versions cannot be removed yet, oldest xmin: 524
-- 	There were 0 unused item identifiers.
-- 	Skipped 0 pages due to buffer pins, 0 frozen pages.
-- 	0 pages are entirely empty.
-- 	CPU: user: 0.17 s, system: 0.00 s, elapsed: 0.47 s.
-- 2021-07-11 10:50:44.695 UTC [107] CONTEXT:  while scanning relation "public.vac_ins"
-- 2021-07-11 10:50:44.695 UTC [107] DEBUG:  CommitTransaction(1) name: unnamed; blockState: STARTED; state: INPROGRESS, xid/subid/cid: 0/1/0 (used)
-- 2021-07-11 10:50:44.696 UTC [107] DEBUG:  StartTransaction(1) name: unnamed; blockState: DEFAULT; state: INPROGRESS, xid/subid/cid: 0/1/0
-- 2021-07-11 10:50:44.696 UTC [107] DEBUG:  analyzing "public.vac_ins"


-- VACUUM after massive DELETE => rows removed
-- 2021-07-11 10:52:44.262 UTC [111] DEBUG:  vac_ins: vac: 648000 (threshold 136052), ins: 0 (threshold 137002), anl: 648000 (threshold 68051)
-- 2021-07-11 10:52:44.262 UTC [111] DEBUG:  autovac_balance_cost(pid=111 db=16384, rel=16389, dobalance=yes cost_limit=200, cost_limit_base=200, cost_delay=2)
-- 2021-07-11 10:52:44.262 UTC [111] DEBUG:  CommitTransaction(1) name: unnamed; blockState: STARTED; state: INPROGRESS, xid/subid/cid: 0/1/0
-- 2021-07-11 10:52:44.262 UTC [111] DEBUG:  StartTransaction(1) name: unnamed; blockState: DEFAULT; state: INPROGRESS, xid/subid/cid: 0/1/0
-- 2021-07-11 10:52:44.263 UTC [111] DEBUG:  vacuuming "public.vac_ins"
-- 2021-07-11 10:52:47.071 UTC [49] DEBUG:  snapshot of 0+0 running transaction ids (lsn 0/2DAD79A8 oldest xid 526 latest complete 525 next xid 526)
-- 2021-07-11 10:52:58.602 UTC [111] DEBUG:  scanned index "idx_vac_ins" to remove 648000 row versions
-- 2021-07-11 10:52:58.602 UTC [111] DETAIL:  CPU: user: 0.52 s, system: 0.01 s, elapsed: 1.13 s
-- 2021-07-11 10:52:58.602 UTC [111] CONTEXT:  while vacuuming index "idx_vac_ins" of relation "public.vac_ins"
-- 2021-07-11 10:53:02.161 UTC [49] DEBUG:  snapshot of 0+0 running transaction ids (lsn 0/2DFF10F8 oldest xid 526 latest complete 525 next xid 526)
-- 2021-07-11 10:53:02.339 UTC [111] DEBUG:  creating and filling new WAL file
-- 2021-07-11 10:53:02.339 UTC [111] CONTEXT:  writing block 9594 of relation base/16384/16389
-- 	while vacuuming block 9626 of relation "public.vac_ins"
-- 2021-07-11 10:53:02.394 UTC [111] DEBUG:  done creating and filling new WAL file
-- 2021-07-11 10:53:02.394 UTC [111] CONTEXT:  writing block 9594 of relation base/16384/16389
-- 	while vacuuming block 9626 of relation "public.vac_ins"
-- 2021-07-11 10:53:11.419 UTC [111] DEBUG:  "vac_ins": removed 648000 row versions in 43211 pages
-- 2021-07-11 10:53:11.419 UTC [111] DETAIL:  CPU: user: 0.68 s, system: 0.88 s, elapsed: 12.81 s
-- 2021-07-11 10:53:11.419 UTC [111] CONTEXT:  while vacuuming relation "public.vac_ins"
-- 2021-07-11 10:53:11.419 UTC [111] DEBUG:  index "idx_vac_ins" now contains 32000 row versions in 1429 pages
-- 2021-07-11 10:53:11.419 UTC [111] DETAIL:  648000 index row versions were removed.
-- 	1378 index pages have been deleted, 0 are currently reusable.
-- 	CPU: user: 0.00 s, system: 0.00 s, elapsed: 0.00 s.



SELECT c1
FROM vac_ins WHERE c1 < 100
LIMIT 10
;

-- After a few seconds, you can notice the below message in the server log which shows that autovacuum has performed analyze on the table.
-- LOG:  automatic analyze of table "postgres.public.vac_ins" system usage: CPU: user: 0.03 s, system: 0.11 s, elapsed: 0.15 s

EXPLAIN ANALYZE VERBOSE
    SELECT c1 FROM vac_ins WHERE c1 < 100;

-- When deactivated, index-scan only does not occur
--                                                                QUERY PLAN
-- -----------------------------------------------------------------------------------------------------------------------------------------
--  Index Only Scan using idx_vac_ins on public.vac_ins  (cost=0.41..432.80 rows=1622 width=4) (actual time=0.137..1.231 rows=1683 loops=1)
--    Output: c1
--    Index Cond: (vac_ins.c1 < 100)
--    Heap Fetches: 159
--  Planning Time: 0.320 ms
--  Execution Time: 1.778 ms
-- (6 rows)

-- Except if you trigger analyze by yourself
VACUUM (VERBOSE, ANALYZE) vac_ins;

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

-- Index only scan !!
-- Index Only Scan using idx_vac_ins on public.vac_ins  (cost=0.42..61.89 rows=1912 width=4) (actual time=0.034..0.369 rows=1881 loops=1)
--   Output: c1
--   Index Cond: (vac_ins.c1 < 100)
--   Heap Fetches: 0
-- Planning Time: 0.141 ms
-- Execution Time: 0.605 ms