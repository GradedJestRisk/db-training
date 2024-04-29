# Memory

https://dba.stackexchange.com/questions/12501/view-postgresql-memory-usage

Tune usage
https://pgtune.leopard.in.ua/

## Usage

https://severalnines.com/blog/what-check-if-postgresql-memory-utilization-high/

La mémoire est répartie entre les différents usages, notamment `shared_buffers` (cache mémoire), 
via [configuration](postgresql.sh). 

En limitant l'usage, on peut obtenir que les requêtes ne soient pas toutes mises en cache.


Get actual memory share
```postgresql
SHOW shared_buffers;
SHOW work_mem;
SHOW temp_buffers;
SHOW maintenance_work_mem;
```


Sample use

[Start local](../../local.md)
```shell
docker exec --user root --tty --interactive postgresql-debian bash
```

```shell
export PGPASSWORD=password123;
pg_top --set-delay=1 --hide-idle --order-field=size \
   --host=localhost --port=5432 --username=postgres -d template1
```

```postgresql
CREATE TABLE foo (id INTEGER UNIQUE);
INSERT INTO foo (id) VALUES (generate_series( 1, 10000000));
```

## Local

## Docker (eg. bitnami)

Get the process ID 
```shell
SELECT
    cnn.pid
FROM
   pg_stat_activity cnn
WHERE 1=1
      AND cnn.query ILIKE 'CREATE UNIQUE INDEX%'
```

Connect to container
```shell
docker exec --user root --tty --interactive postgresql bash
```

Get actual memory used
```shell
grep VmSize: /proc/600/status
```
https://stackoverflow.com/questions/131303/how-can-i-measure-the-actual-memory-usage-of-an-application-or-process

OR 
```shell
ps aux | grep "postgres:.*INSERT"
```

Get PID of container from OS shell
```shell
ps aux | grep "postgres:.*INSERT"
grep NSpid /proc/661311/status
```

To follow memory usage
```shell
top -p <OS_PID>
```

Chart ?
https://unix.stackexchange.com/questions/554/how-to-monitor-cpu-memory-usage-of-a-single-process


```shell
snap install ttyplot
export PID_MONITOR=<OS_PID>;
while :; do grep -oP '^VmRSS:\s+\K\d+' /proc/$PID_MONITOR/status \
    | numfmt --from-unit Ki --to-unit Mi; sleep 1; done | ttyplot -u Mi
```

## CLI

### pg_top

https://severalnines.com/blog/dynamic-monitoring-postgresql-instances-using-pgtop/

If you monitor Postgresql running in docker:
- process ID are the container one
- memory usage may not be reported

```shell
sudo apt install pg_top
export PGPASSWORD=integration;
pg_top --set-delay=1 --hide-idle --order-field=size \
   --host=localhost --port=5497 --username=integration -d integration_db
```

Get 
- query: `Q`
- locks: `L`
- locks: `L`


 Display:
- IO: `L`
Hide idle: `i`

You can monitor a remote database if extension `pg_proctab` is installed, using `--remote-mode`.

## Extension

### pg_proctab


```shell
docker compose --file=docker-compose.pg_proctab.yml up --detach
```

```postgresql
CREATE EXTENSION pg_proctab;
select pg_size_pretty(sum(rss)*1000) from pg_proctab();
```

### plperlu

```shell
docker compose --file=docker-compose.plperlu.yml up --detach
```

https://www.enterprisedb.com/blog/monitor-cpu-and-memory-percentage-used-each-process-postgresqlppas-91

```postgresql
CREATE EXTENSION plperlu;
```

Create 
```postgresql
CREATE OR REPLACE FUNCTION get_pid_cpu_mem(int) returns table(PID INT,CPU_perc float,MEM_perc float) 
as
$$
  my $ps = "ps aux";
  my $awk = "awk '{if (\$2==".$_[0]."){print \$2\":\"\$3\":\"\$4}}'";
  my $cmd = $ps."|".$awk;
  $output = `$cmd 2>&1`;
  @output = split(/[\n\r]+/,$output);
  foreach $out (@output)
  { 
    my @line = split(/:/,$out);
    return_next{'pid' => $line[0],'cpu_perc' => $line[1], 'mem_perc' => $line[2]};
    return undef;
  }
   return;
 $$ language plperlu;
```

Query
```postgresql
SELECT 
   get_pid_cpu_mem(27)
;
```


```postgresql
select 
    pid,usename, application_name, 
--     get_pid_cpu_mem(pid).cpu_perc,
--     get_pid_cpu_mem(pid).mem_perc,
    query 
from pg_stat_activity;
```

## Exhaust memory

### Start container

Use [limited memory](./postgresql.conf)
```
shared_buffers=256MB
work_mem=5MB
temp_buffers=10MB
maintenance_work_mem=10MB
```

Start
```shell
docker compose --file=docker-compose.exhaust.yml up --detach
```

Check 
```text
docker logs --follow postgresql
postgresql 06:58:26.73 INFO  ==> Loading custom scripts...
```

```postgresql
SHOW shared_buffers;
SHOW work_mem;
SHOW temp_buffers;
SHOW maintenance_work_mem;
```

### Cache tooling

As `postgresql`
```postgresql
CREATE EXTENSION pg_buffercache;
GRANT EXECUTE ON FUNCTION pg_buffercache_pages() TO jane;
GRANT SELECT ON pg_buffercache TO jane;
```

Check access
```postgresql
SELECT * FROM pg_extension
WHERE extname = 'pg_buffercache'
```

```postgresql
CREATE FUNCTION buffercache(rel regclass)
RETURNS TABLE(
bufferid integer, relfork text, relblk bigint,
isdirty boolean, usagecount smallint, pins integer
) AS $$
SELECT bufferid,
CASE relforknumber
WHEN 0 THEN 'main'
WHEN 1 THEN 'fsm'
WHEN 2 THEN 'vm'
END,
relblocknumber,
isdirty,
usagecount,
pinning_backends
FROM pg_buffercache
WHERE relfilenode = pg_relation_filenode(rel)
ORDER BY relforknumber, relblocknumber;
$$ LANGUAGE sql;
```

Force-feed the cache
```postgresql
CREATE TABLE cacheme(
id integer
) WITH (autovacuum_enabled = off);
INSERT INTO cacheme VALUES (1);
```

Get cached pages
```postgresql
SELECT * FROM buffercache('cacheme');
```

Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('cacheme') );
```

Get cached pages size
```postgresql
SELECT pg_size_pretty(COUNT(1) * 8 * 1024)
FROM buffercache('cacheme');
```

Empty cache
```shell
docker exec postgresql bash -c "pg_ctl restart -D /bitnami/postgresql/data"
```

Cache is preserved if restarting container
```shell
docker restart postgresql
```

Cache hit
```postgresql
SELECT heap_blks_read, heap_blks_hit
FROM pg_statio_all_tables
WHERE relname = 'cacheme';
```

Query table to trigger cache loading
```postgresql
SELECT * FROM cacheme;
```

Repartition
```postgresql
SELECT usagecount, count(*)
FROM pg_buffercache
GROUP BY usagecount
ORDER BY usagecount;
```

Buffer by relation
```postgresql
SELECT rel.relname
       ,bfr.usagecount
       ,'pg_buffercache:'
       ,bfr.*
       ,'pg_class:'
       ,rel.*
FROM pg_buffercache bfr
    INNER JOIN pg_class rel ON rel.relfilenode = bfr.relfilenode
       INNER JOIN pg_namespace ns ON ns.oid = rel.relnamespace
WHERE 1=1
    AND bfr.relfilenode IS NOT NULL
    AND ns.nspname  = 'public'
    AND rel.relname = 'cacheme'
ORDER BY rel.relname DESC;
```

Cache total size
```postgresql
SELECT pg_size_pretty(COUNT(1) * 8 * 1024)
FROM pg_buffercache bfr
```

Cache free
```postgresql
SELECT pg_size_pretty(COUNT(1) * 8 * 1024)
FROM pg_buffercache bfr
WHERE relfilenode IS NULL
```

Cache used
```postgresql
SELECT pg_size_pretty(COUNT(1) * 8 * 1024)
FROM pg_buffercache bfr
WHERE relfilenode IS NOT NULL
```



How much of the table is cached ?
Hot data (always in cache)
```postgresql
SELECT c.relname,
count(*) blocks,
round( 100.0 * 8192 * count(*) /
pg_table_size(c.oid) ) AS "% of rel",
round( 100.0 * 8192 * count(*) FILTER (WHERE b.usagecount > 1) /
pg_table_size(c.oid) ) AS "% hot"
FROM pg_buffercache b
    JOIN pg_class c ON pg_relation_filenode(c.oid) = b.relfilenode
     INNER JOIN pg_namespace ns ON ns.oid = c.relnamespace
WHERE b.reldatabase IN (
0, -- cluster-wide objects
(SELECT oid FROM pg_database WHERE datname = current_database())
)
AND b.usagecount IS NOT NULL
  AND ns.nspname  = 'public'
GROUP BY c.relname, c.oid
ORDER BY 2 DESC
LIMIT 10;
```

SELECT pg_prewarm('big');

### Pre-warm

```postgresql
CREATE EXTENSION pg_prewarm;
ALTER SYSTEM SET shared_preload_libraries = 'pg_prewarm';
```
Restart
```shell
psql --dbname "host=localhost port=5432 user=postgres password=password123 dbname=test"
```

Get cached pages
```postgresql
SELECT * FROM buffercache('cacheme');
```
Empty
```postgresql
SELECT pg_prewarm('cacheme');
```

Get cached pages
```postgresql
SELECT * FROM buffercache('cacheme');
```

PG cache and OS cache
https://dev.to/franckpachot/postgresql-double-buffering-understand-the-cache-size-in-a-managed-service-oci-2oci