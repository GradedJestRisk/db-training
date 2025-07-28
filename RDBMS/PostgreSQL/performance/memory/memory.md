# Memory

## Theory

### Memory management

Memory is managed internally by Postgresql, written C, by its owm memory management, not by `malloc`: memory contexts. Its aim is to prevent memory leaks.

[Source](https://www.cybertec-postgresql.com/en/memory-context-for-postgresql-memory-management/)

### Memory type

Shared memory ("POSIX shared memory") for:
- buffer cache, shared between all background process
- locks, transaction log
- parallel workers

Private memory for
- backend process (join, sort, aggregate)

https://momjian.us/main/writings/pgsql/inside_shmem.pdf

### Tracking down usage

Memory usage cannot be accurately monitored:
- process memory usage will report some `shared_buffer` footprint (due to copying process mem map to forked)
- connexion footprint is 2 MBytes 
https://blog.anarazel.de/2020/10/07/measuring-the-memory-overhead-of-a-postgres-connection/

More details on this here
https://dba.stackexchange.com/questions/12501/view-postgresql-memory-usage

Which include Linux memory survey
https://utcc.utoronto.ca/~cks/space/blog/linux/LinuxMemoryStats

To choose how much RAM to allocate
https://pgtune.leopard.in.ua/

Cache is at two levels: 
- PG cache 
- OS cache
https://dev.to/franckpachot/postgresql-double-buffering-understand-the-cache-size-in-a-managed-service-oci-2oci

Connection metadata are not freed (unless connexion is closed ) and can cause memory leak
https://dba.stackexchange.com/questions/160887/how-can-i-find-the-source-of-postgresql-per-connection-memory-leaks
https://wiki.postgresql.org/wiki/Developer_FAQ#Examining_backend_memory_use
https://aws.amazon.com/blogs/database/resources-consumed-by-idle-postgresql-connections/


## Usage

https://severalnines.com/blog/what-check-if-postgresql-memory-utilization-high/

Get actual memory share
```postgresql
SHOW shared_buffers;
SHOW work_mem;
SHOW temp_buffers;
SHOW maintenance_work_mem;
```

Sample use

[Start local](../../install-postgresql.md)
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

## Get memory

### in OS

#### using top

Get the process ID 
```shell
SELECT
    cnn.pid
FROM
   pg_stat_activity cnn
WHERE 1=1
      AND cnn.query ILIKE '%INSERT%'
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

#### using pg_top

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

### from database

#### using view pg_backend_memory_contexts

For current session
```postgresql
SELECT name,
       total_bytes / 1024 size_kbytes,
       total_bytes / 1024 / 1024 size_mbytes
FROM pg_backend_memory_contexts mmr_cnt
WHERE 1=1
--AND mmr_cnt.name = 'TopMemoryContext';
ORDER BY total_bytes DESC
```

You can see metada use up to 1 Mb

| name               | size_kbytes | size_mbytes |
|:-------------------|:------------|:------------|
| CacheMemoryContext | 1024        | 1           |
| Timezones          | 101         | 0           |
| TopMemoryContext   | 80          | 0           |

#### using function pg_log_backend_memory_contexts

Get the process ID
```shell
SELECT
    cnn.pid,
    'pg_log_backend_memory_contexts(' || cnn.pid || ')'
FROM
   pg_stat_activity cnn
WHERE 1=1
      AND cnn.query ILIKE '%INSERT%';
```

In container as `postgres`
```postgresql
SELECT pg_log_backend_memory_contexts(79672)
```

Then read database log

### using extensions

#### pg_proctab


```shell
docker compose --file=docker-compose.pg_proctab.yml up --detach
```

```postgresql
CREATE EXTENSION pg_proctab;
select pg_size_pretty(sum(rss)*1000) from pg_proctab();
```

#### plperlu

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

#### pg_buffercache (cache, not backend memory)

```shell
psql --dbname "host=localhost port=5432 user=postgres password=password123 dbname=test" --file ./database-setup/activate-extensions.sql
```

Check access
```postgresql
SELECT * FROM pg_extension
WHERE extname = 'pg_buffercache'
```

## Exhaust memory

### Start container

Use [limited memory](database-setup/postgresql.conf)
```
shared_buffers=256MB
work_mem=5MB
temp_buffers=10MB
maintenance_work_mem=10MB
```

Start
```shell
docker compose --file=docker-compose.exhaust.yml up --remove-orphans --renew-anon-volumes --force-recreate --detach
docker logs --follow postgresql
```

Setup
```shell
psql --dbname "host=localhost port=5432 user=postgres password=password123 dbname=test" \
    --file ./database-setup/activate-extensions.sql
```

Check memory allocation
```postgresql
SHOW shared_buffers;
SHOW work_mem;
SHOW temp_buffers;
SHOW maintenance_work_mem;
```

### Cache tooling


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



### Dump connection memory content

Start connexion, do stuff without committing

Get the process ID
```shell
ps aux | grep "postgres:.*INSERT"
```

Get the process ID
```shell
SELECT
    cnn.pid,
    'pg_log_backend_memory_contexts(' || cnn.pid || ')'
FROM
   pg_stat_activity cnn
WHERE 1=1
      AND cnn.query ILIKE '%INSERT%';
```

In container as `postgres`
```postgresql
SELECT pg_log_backend_memory_contexts(79672)
```

Will give you [this file](./memory-dump.log).

[Doc](https://git.postgresql.org/gitweb/?p=postgresql.git;a=blob;f=src/backend/utils/mmgr/README):


Total footprint is NOT in first record `TopMemoryContext`: it should be added form each node
```text
2024-04-30 12:30:21.997 GMT [195] LOG:  level: 0; TopMemoryContext: 69472 total in 5 blocks; 14392 free (21 chunks); 55080 used
```

Metadata cache
```text
LOG:  level: 1; CacheMemoryContext: 524 288 total in 7 blocks; 59 648 free (0 chunks); 464 640 used
```

`524288` is `524 288` bytes, so 524 kbytes

Doesn't match with 7 blocks 8 kb
```postgresql
SELECT pg_size_pretty(7 * 8 * 1024::numeric);
```
### Exhaust

#### Setup database

Build volume
```shell
mkdir /tmp/postgres
sudo chown 1001 /tmp/postgres
```

Start container
```shell
docker compose --file=docker-compose.exhaust.yml up --remove-orphans --renew-anon-volumes --force-recreate --detach
docker logs --follow postgresql
```

Add extensions
```shell
psql --dbname "host=localhost port=5432 user=postgres password=password123 dbname=test" \
    --file ./database-setup/activate-extensions.sql
```

Monitor database primary container memory usage
```shell
while :; do docker stats --no-stream | grep postgres | awk '{print $4}' | sed -e 's/MiB//g' \
    | LC_ALL=en_US numfmt --from-unit Mi --to-unit Mi; sleep 1; done | ttyplot -u Mi
```

#### Monitor connexion and container

Start client connexion
```shell
psql
```

Check you can see it in process
```shell
ps -C postgres --no-headers --format pid --format cmd | grep "jane test" | tr -s ' ' | cut -f 2 -d ' '
```

If no, check here
```postgresql
select pid, query from pg_stat_activity
WHERE usename = 'jane' and application_name = 'psql'
```

Monitor connexion memory
```shell
export PID_MONITOR=$(ps -C postgres --no-headers --format pid --format cmd | grep "jane test" | tr -s ' ' | cut -f 2 -d ' ')
while :; do grep -oP '^VmRSS:\s+\K\d+' /proc/$PID_MONITOR/status \
    | numfmt --from-unit Ki --to-unit Mi; sleep 1; done | ttyplot -u Mi
```

Memory usage can be broadly simplified into two values
- Virtual Memory (VMEM) which a program believes it has
- Resident Set Size (RSS) which is the actual amount of memory it uses.

```shell
man proc | vi -
```
Same values
```shell
ps -U 1001 -o rss,cmd | grep jane
```

#### Create dataset and fill cache

Create table bigger than cache
```postgresql
\i ./load-test/create-single-table.sql 
```

Get table size : 56 Mb
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('big_table') );
```

Perform activity to fill cache
```postgresql
\i ./load-test/select-single-table-random.sql
```

Check if cache is full

Cache free space
```postgresql
SELECT pg_size_pretty(COUNT(1) * 8 * 1024)
FROM pg_buffercache
WHERE relfilenode IS NULL
```

Cache used space
```postgresql
SELECT pg_size_pretty(COUNT(1) * 8 * 1024)
FROM pg_buffercache
WHERE relfilenode IS NOT NULL
```

Get cached row size < 56 Mb
```postgresql
SELECT pg_size_pretty(COUNT(1) * 8 * 1024) 
FROM buffercache('big_table');
```

Cache hit
```postgresql
SELECT relname, heap_blks_read, heap_blks_hit
FROM pg_statio_all_tables
WHERE relname ILIKE 'big_table';
AND relname NOT ILIKE '%pkey'
ORDER BY relname ASC
```

Close connexion

#### Now exhaust 

Open connexion
```shell
psql
```

Write down memory size 
- container: 33,5 Mb
- connexion: 13 Mb

Perform activity
```postgresql
\i ./load-test/select-single-table-random.sql
```

Stop after a minute (Ctrl-C)

Write down memory size
- container : 38 Mb
- connexion : 26 Mb

Exit connexion

Write down memory size
- container : 33 Mb

