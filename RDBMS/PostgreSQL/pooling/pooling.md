# Pooling

## Server-side

### pgPool

pgpool:
- start N process
- which can hold each M connexions

num_init_children = N
max_pool = M

So if you want 10 connexions, you can use
- N=10 / M=1
- N=1 / M=10

https://severalnines.com/blog/guide-pgpool-postgresql-part-one/

https://www.refurbed.org/posts/load-balancing-sql-queries-using-pgpool/

#### Start containers

```shell
docker compose --file=docker-compose.pgPool.replication.classic.yml up --remove-orphans --renew-anon-volumes --force-recreate --detach
docker logs --follow pooling-pgpool-1
```

[Create data](../performance/memory/load-test)

Check pgpool received the connexion
```shell
pgpool-1              | 2024-05-01 15:55:57: pid 123: LOG:  new connection receiv
pgpool-1              | 2024-05-01 15:55:57: pid 123: DETAIL:  connecting host=172.25.0.1 port=43344
pgpool-1              | 2024-05-01 15:55:57: pid 123: LOG:  pool_reuse_block: blockid: 0
```

Monitor databse primary container memory usage
```shell
while :; do docker stats --no-stream | grep primary | awk '{print $4}' | sed -e 's/MiB//g' \
    | LC_ALL=en_US numfmt --from-unit Mi --to-unit Mi; sleep 1; done | ttyplot -u Mi
```

#### Locate connexion

Start idle query
```shell
psql --command = "SELECT pg_sleep(60)"
```

Monitor connexion memory
```shell
export PID_MONITOR=$(ps -C postgres --no-headers --format pid --format cmd | grep test | grep SELECT | tr -s ' ' | cut -f 2 -d ' ')
while :; do grep -oP '^VmRSS:\s+\K\d+' /proc/$PID_MONITOR/status \
    | numfmt --from-unit Ki --to-unit Mi; sleep 1; done | ttyplot -u Mi
```

Execute many transactions
```shell
pgbench --client=1 --jobs=1 --transactions=100 --transactions=10 --no-vacuum --file=select-by-id.sql
```

If you interrupt, it will break the connexion. pgpool will reallocate another one.


#### Stop containers

```shell
docker compose --file=docker-compose.pgPool.replication.classic.yml down
```

### Client-side

#### Tarn

https://github.com/vincit/tarn.js/
