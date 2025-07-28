# Cache

## Overview
[Introduction](https://web.archive.org/web/20240107132036/https://madusudanan.com/blog/understanding-postgres-caching-in-depth/)

caching => memory => shared_buffers

Check OS cache
```shell
sudo iotop
```

Cache size
```postgresql
SHOW shared_buffers;
```
128 MB


## Cache hit

All tables
```postgresql
select (round(sum(blks_hit) * 100 / sum(blks_hit + blks_read), 2))::varchar || '%' as hit_ratio
from pg_stat_database;
```

By table
```postgresql
select
    --*
   (round(sum(heap_blks_hit) * 100 / sum(heap_blks_hit + heap_blks_read), 2))::varchar || '%' as hit_ratio
from pg_statio_all_tables t
where 1=1
 and t.relname LIKE 'traces_metier%'
;
```

Database
```postgresql
SELECT
     db.stats_reset  audit_start_time
FROM
    pg_stat_database db
WHERE 1=1
    AND db.datname = 'database'
;
```

## Dig into the cache

https://www.postgresql.org/docs/current/pgbuffercache.html

```postgresql
CREATE EXTENSION pg_buffercache;
```

Cache entries
```postgresql
SELECT *
FROM pg_buffercache
;
```

[Summary](https://www.postgresql.org/docs/current/pgbuffercache.html#PGBUFFERCACHE-SUMMARY):
- used
- unused 
- dirty
- pinned
- average usage count of used shared buffers

```postgresql
SELECT 
    '(used, unused, dirty, pinned,average)',
    pg_buffercache_summary();
```

Cache entries + table
Table with most cache entries
```postgresql
SELECT
       c.relname,
       count(*) AS buffers,
       pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON (b.reldatabase = d.oid AND
                        d.datname = current_database())
GROUP BY c.relname
ORDER BY 2 DESC
LIMIT 100;
```
