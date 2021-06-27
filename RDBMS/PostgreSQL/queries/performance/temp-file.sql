-- Reset
select pg_stat_statements_reset();


-- Trigger log
-- LOG:  temporary file: path "base/pgsql_tmp/pgsql_tmp76.0", size 18120704

SELECT id
FROM foo
ORDER BY value;

-- Temporary file = actual file
-- Used for JOIN, SORT, DISTINCT

-- If a query exceed this size in memory while being performed , a temporary file will be used
SHOW work_mem;

SELECT
       query                                                       AS query,
       to_char(temp_blks_written, 'FM999G999G999G990')             AS temp_blocks_written,
       interval '1 millisecond' * total_exec_time                  AS total_exec_time,
       to_char(calls, 'FM999G999G999G990')                         AS ncalls,
       total_exec_time / calls                                     AS avg_exec_time_ms,
       interval '1 millisecond' * (blk_read_time + blk_write_time) AS sync_io_time
FROM pg_stat_statements
WHERE userid = (SELECT usesysid FROM pg_user WHERE usename = current_user LIMIT 1)
  AND temp_blks_written > 0
ORDER BY temp_blks_written DESC
LIMIT 20
;

SELECT *
FROM pg_stat_statements
;