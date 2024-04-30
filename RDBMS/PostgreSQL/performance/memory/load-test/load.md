# Load

```shell
psql --file load-data.sql
```

```shell
pgbench --client=10 --jobs=2 --transactions=1000 --no-vacuum --file=select-by-id.sql
```