# Estimate INTEGER TO BIGINT migration impact

> I'm not often ashamed of our work at @basecamp. 
> But today is one such day. 
> To be stuck in read-only mode for hours due to a failure to use bigint for our primary keys on every table is embarrassing.
https://twitter.com/dhh/status/1060565296048562177?lang=en


## TL,DR

Run a benchmark of different strategies to change INTEGER type TO BIGINT:

- bare column
- column with UNIQUE constraint
- column with PRIMARY KEY constraint
- column referenced by a FOREIGN KEY constraint
- column referencing by a FOREIGN KEY constraint

Benchmark measures:

- elapsed time (database-side)
- disk usage:
  - WAL
  - temporary file (all space is not used at once, and is usually freed)

Database comes with:

- volatile named volume (using `extfs`, as`tmpfs` cannot handle the load)
- `pg_stat_statements` enabled
- quotas on CPU and memory
- logs: all queries and temporary file creation (>100kBytes).

## Start database

Steps:

- start database `npm run database:start`
- check logs `npm run database:peek-last-logs`
- check connexion from Node client `npm run test_connexion`

Startup should take a minute, but you can shorten it by using less data
in [schema creation](./database/create-schema.sql)

```sql
INSERT INTO foo (..)
FROM
--generate_series( 1, 5000000) -- 5 million => 2 minutes
generate_series( 1, 1000000) -- 1 million => 40 seconds
```

## Perform benchmark

Steps:
- start some monitoring tool, eg.
  - OS-level: htop
  - docker-level: [ctop](https://github.com/bcicen/ctop)  
- start changes `npm run type_change:perform`
- check logs `npm run database:peek-last-logs`

Results are displayed after all changes have taken place.

```json
[
  {
    label: 'CHANGE_IN_PLACE',
    execution_time_ms: 1570,
    disk_wal_size: '110 MB',
    disk_temp_size: '38 MB'
  },
  {
    label: 'CHANGE_IN_PLACE_PRIMARY_KEY',
    execution_time_ms: 1521,
    disk_wal_size: '107 MB',
    disk_temp_size: '38 MB'
  }
]
```

## Debug

You can connect to database with `psql` client

`psql postgresql://postgres@localhost:5432/database`

You can check actual space in volume (`docker system df` does not report on individual volumes).

`sudo du -sh /var/lib/docker/volumes/database_database-data/`
