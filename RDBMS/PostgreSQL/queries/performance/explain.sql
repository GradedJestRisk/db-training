--https://www.postgresql.org/docs/current/auto-explain.html
LOAD 'auto_explain';
SET auto_explain.log_min_duration = 0;
SET auto_explain.log_analyze = true;


EXPLAIN ANALYZE VERBOSE
SELECT * FROM foo
;

SET track_io_timing TO on;

-- FULL with cache, planning/execution time, etc..
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM "users" WHERE id = -1;


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



-- is index build limited by I/O ?
SET track_io_timing TO on;
EXPLAIN (ANALYZE, BUFFERS) CREATE UNIQUE INDEX "answers_id_index_load_test" ON "answers_bigint"(id);

DROP INDEX answers_id_index_load_test;
CREATE UNIQUE INDEX answers_id_index_load_test ON "answers_bigint"(id);
