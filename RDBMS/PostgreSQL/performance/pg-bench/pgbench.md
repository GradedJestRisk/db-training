# PG bench(mark)

https://www.postgresql.org/docs/current/pgbench.html

## Normalized scenario


### Create data

https://medium.com/@c.ucanefe/pgbench-load-test-166bdfb5c75a

Create database
```shell
docker compose --file ../../docker-compose.12.bitnami.yml up --renew-anon-volumes --force-recreate --detach
```

Setup connection (in order not to pass flags)
```shell
export PGPASSWORD=password123
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
```

Create table and data
```shell
pgbench --initialize --scale=50 example
```

Check
```shell
psql --dbname "host=localhost port=5432 user=postgres password=password123 dbname=example"
```

### Perform queries

Run tests
```shell
pgbench --client=10 --jobs=2 --transactions=10000 example
```

You''l get a summery
```shell
pgbench (14.11 (Ubuntu 14.11-0ubuntu0.22.04.1), server 12.18)
starting vacuum...end.
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 50
query mode: simple
number of clients: 10
number of threads: 2
number of transactions per client: 100000
number of transactions actually processed: 1000000/1000000
latency average = 2.465 ms
initial connection time = 9.765 ms
tps = 4056.161433 (without initial connection time)
```

Restore
```shell
unset PGPASSWORD
unset PGHOST
unset PGPORT
unset PGUSER
```

## Custom scenario

### Create data

### Perform queries


Run tests
```shell
export FILE=<PATH>
pgbench --client=10 --jobs=2 --transactions=10000 --file=$FILE example
```
