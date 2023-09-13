
--https://www.cybertec-postgresql.com/en/postgresql-more-performance-for-like-and-ilike-statements/

create table t_hash AS
select id, md5(id::text)
from generate_series(1, 50000000) AS id;

select * from t_hash limit 10;

explain select * from t_hash where md5 like '%e2345679a%';

create EXTENSION pg_trgm;
select show_trgm('dadb4b54e2345679a8861ab52e4128ea');
create index idx_gist on t_hash using gist (md5 gist_trgm_ops);

select show_trgm('john.doe');


-----------
-- AS-IS  -
-----------
-- Cardinality
select
   stt.n_live_tup
from pg_stat_user_tables stt
where 1=1
    and relname = 'users';
-- 9 594 329

-- Size
SELECT pg_size_pretty(pg_table_size('users')); -- 56kb
--  1 110 MB


 SELECT i.relname "Table Name",indexrelname "Index Name",
 pg_size_pretty(pg_total_relation_size(relid)) As "Total Size",
 pg_size_pretty(pg_indexes_size(relid)) as "Total Size of all Indexes",
 pg_size_pretty(pg_relation_size(relid)) as "Table Size",
 pg_size_pretty(pg_relation_size(indexrelid)) "Index Size",
 reltuples::bigint "Estimated table row count"
 FROM pg_stat_all_indexes i JOIN pg_class c ON i.relid=c.oid
 WHERE i.relname='users'

explain (analyze, buffers)
select * from users
where 1=1
   and "firstName" like '%terms%'
;
--                                                        QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------
-- Gather  (cost=1000.00..173145.83 rows=738 width=131) (actual time=685.902..693.357 rows=0 loops=1)
--   Workers Planned: 4
--   Workers Launched: 4
--   Buffers: shared hit=7 read=142083
--   ->  Parallel Seq Scan on users  (cost=0.00..172072.03 rows=184 width=131) (actual time=644.074..644.075 rows=0 loops=5)
--         Filter: (("firstName")::text ~~ '%terms%'::text)
--         Rows Removed by Filter: 1918850
--         Buffers: shared hit=7 read=142083
-- Planning Time: 0.169 ms
-- JIT:
--   Functions: 10
--   Options: Inlining false, Optimization false, Expressions true, Deforming true
--   Timing: Generation 1.544 ms, Inlining 0.000 ms, Optimization 1.553 ms, Emission 20.984 ms, Total 24.081 ms
-- Execution Time: 693.926 ms
--(14 rows)
--
--pix_datawar_7855=> \timing
--Timing is on.


-- GIST

create index "users_firstName_gist" on users using gist ("firstName" gist_trgm_ops);

-----------
-- GIN   --
-----------

DROP INDEX "users_firstName_gin";
CREATE INDEX "users_firstName_gin" ON users USING GIN ("firstName" GIN_TRGM_OPS);  --26s

select pg_size_pretty(pg_table_size('users')); -- 56kb
SELECT pg_size_pretty(pg_table_size('"users_firstName_gin"')); -- 32kb / 153 MB in production

-- Not working ?
select pg_size_pretty(pg_indexes_size('"users_firstName_gin"'));

select *
from pg_indexes
where indexname = 'users_firstName_gin'
;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users
WHERE 1=1
    AND "firstName" LIKE '%terms%'
;
--                                                           QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------
-- Bitmap Heap Scan on users  (cost=16.72..762.95 rows=738 width=131) (actual time=0.314..0.315 rows=0 loops=1)
--   Recheck Cond: (("firstName")::text ~~ '%terms%'::text)
--   Buffers: shared hit=20
--   ->  Bitmap Index Scan on "users_firstName_gin"  (cost=0.00..16.54 rows=738 width=0) (actual time=0.311..0.312 rows=0 loops=1)
--         Index Cond: (("firstName")::text ~~ '%terms%'::text)
--         Buffers: shared hit=20
-- Planning:
--   Buffers: shared hit=3
-- Planning Time: 0.387 ms
-- Execution Time: 0.372 ms
--(10 rows)
--
--Time: 1.888 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users
WHERE 1=1
    AND LOWER("firstName") LIKE '%terms%'
;

--                                                         QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------
-- Gather  (cost=1000.00..180603.54 rows=15351 width=131) (actual time=829.927..838.117 rows=0 loops=1)
--   Workers Planned: 4
--   Workers Launched: 4
--   Buffers: shared hit=199 read=141891
--   ->  Parallel Seq Scan on users  (cost=0.00..178068.44 rows=3838 width=131) (actual time=792.748..792.749 rows=0 loops=5)
--         Filter: (lower(("firstName")::text) ~~ '%terms%'::text)
--         Rows Removed by Filter: 1918850
--         Buffers: shared hit=199 read=141891
-- Planning Time: 0.113 ms
-- JIT:
--   Functions: 10
--   Options: Inlining false, Optimization false, Expressions true, Deforming true
--   Timing: Generation 1.617 ms, Inlining 0.000 ms, Optimization 1.512 ms, Emission 17.394 ms, Total 20.522 ms
-- Execution Time: 838.683 ms
--(14 rows)

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users
WHERE 1=1
    AND "firstName" ILIKE '%terms%'
;
--                                                           QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------
-- Bitmap Heap Scan on users  (cost=16.72..762.95 rows=738 width=131) (actual time=0.662..0.663 rows=0 loops=1)
--   Recheck Cond: (("firstName")::text ~~* '%terms%'::text)
--   Buffers: shared hit=20
--   ->  Bitmap Index Scan on "users_firstName_gin"  (cost=0.00..16.54 rows=738 width=0) (actual time=0.658..0.658 rows=0 loops=1)
--         Index Cond: (("firstName")::text ~~* '%terms%'::text)
--         Buffers: shared hit=20
-- Planning:
--   Buffers: shared hit=4
-- Planning Time: 0.864 ms
-- Execution Time: 0.715 ms
--(10 rows)



INSERT INTO users ( "firstName", "lastName")
VALUES ('John', 'Doe');

INSERT INTO users ( "firstName", "lastName")
VALUES ('john', 'Doe');

SELECT * FROM
  users u1,
  users u2
WHERE 1=1
    AND u1."firstName" = LOWER(u2."firstName")
    AND LOWER(u1."lastName") = LOWER(u2."lastName")
    AND u1.id <> u2.id
;


INSERT INTO users ( "firstName", "lastName")
SELECT MD5(id::text), 'Doe'
FROM generate_series (1, 9000000) AS id;

SELECT * FROM users ORDER BY "createdAt" DESC;
