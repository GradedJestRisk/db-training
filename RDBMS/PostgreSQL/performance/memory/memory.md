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