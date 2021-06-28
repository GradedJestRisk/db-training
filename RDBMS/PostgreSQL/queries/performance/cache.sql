-- https://madusudanan.com/blog/understanding-postgres-caching-in-depth/
--
-- caching => memory => shared_buffers

-- Check OS cache
-- sudo iotop

-- Cache size
SHOW shared_buffers;
-- 128 MB

-- Cache hit
select (round(sum(blks_hit) * 100 / sum(blks_hit + blks_read), 2))::varchar || '%' as hit_ratio
from pg_stat_database;



-- Database
SELECT
     db.stats_reset  audit_start_time
FROM
    pg_stat_database db
WHERE 1=1
    AND db.datname = 'database'
;



-- Dig into the cache
-- https://www.postgresql.org/docs/current/pgbuffercache.html
CREATE EXTENSION pg_buffercache;

-- Cache entries
SELECT *
FROM pg_buffercache
;

-- Cache entries + table
-- Table with most cache entries
SELECT
       c.relname,
       count(*) AS buffers
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON (b.reldatabase = d.oid AND
                        d.datname = current_database())
GROUP BY c.relname
ORDER BY 2 DESC
LIMIT 100;
