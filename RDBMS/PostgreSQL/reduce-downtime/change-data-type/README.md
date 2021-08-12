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

You can also generate more data in less time 
- generating data with [external tool](./database/tools/generate-foo-data.c) 
- importing it with `COPY`
// TODO: lay down the steps

## Perform benchmark

Steps:
- start some monitoring tool, eg.
  - OS-level: htop
  - docker-level: [ctop](https://github.com/bcicen/ctop)  
- start changes `npm run type_change:perform`
- check logs `npm run database:peek-last-logs`

Results are displayed after all changes have taken place.


## Results 
These results are 
- for 5 millions row
- using primary key and foreign key

### In place
```json
[
  {
    phase: 'downtime',
    execution_time_ms: 30809,
    disk_wal_size: '1045 MB',
    disk_temp_size: '764 MB'
  }
]
```


### Using temporary column
```json
[
  {
    phase: 'beforeDowntime',
    execution_time_ms: 523630,
    disk_wal_size: '2775 MB',
    disk_temp_size: '6355 MB'
  },
  {
    phase: 'downtime',
    execution_time_ms: 2864,
    disk_wal_size: '298 kB',
    disk_temp_size: '0 bytes'
  },
  {
    phase: 'afterDowntime',
    execution_time_ms: 1,
    disk_wal_size: '301 bytes',
    disk_temp_size: '0 bytes'
  }
]
```

### Comparison

Metrics:
- downtime: 31 s in place / 3 s using temporary column
- WAL: 1 Gb in place / 3 Gb using temporary column (but no WAL during downtime)

## Perform benchmark against concurrent access

You can trigger some activity during the benchmark
- to get more accurate metrics
- to hightlight downtime

To trigger activity:
- not retrying when disconnected, local mode: `npm run fake_activity`
- retrying when disconnected, PaaS-mode (require bash): `npm run fake_activity:retry`

## Debug

You can connect to database with `psql` client

`psql postgresql://postgres@localhost:5432/database`

You can check actual space in volume (`docker system df` does not report on individual volumes).

`sudo du -sh /var/lib/docker/volumes/database_database-data/`

## Full log
```bash
 npm run type_change:perform

> type_change:perform
> node ./src/perform-type-change.js

👷 Changing type with CHANGE_WITH_TEMPORARY_COLUMN_PRIMARY_KEY_AND_FOREIGN_KEY_CONSTRAINT 🕗
Preparing for maintenance window:
- new_id column has ben created
- new_foo_id column has ben created
- NOT NULL constraint on new_foo_id has been created NOT VALID
- trigger has been created, so that each new record in table will have new_id filled
- index on new_id has been build concurrently
- feeding new_id and foo_new_id on existing rows (using 100000-record size chunks)
-..................................................- finished feeding new_id on existing rows
- user login has been disabled
- all connexions have been terminated
Opening maintenance window...
- transaction started
- triggers have been dropped
- 0 remaining rows on foo have been migrated
- 0 remaining rows on foobar have been migrated
- sequence type is now BIGINT
- sequence is now used by new_id
- referencing FK constraint on foobar has been dropped
- primary key on id has been dropped
- primary key on new_id has been created
- column id has been dropped
- column new_id has been renamed to id
- NOT NULL constraint on foobar has been dropped
- column foo_id has been dropped
- column foo_new_id has been renamed to foo_id
- constraint new_foo_id_not_null has been renamed to foo_id_not_null
- referencing FK has been created (no validation)
- INSERT has succeeded with id 2147483628
- transaction committed
Closing maintenance window...
default: 2.884s
- referencing FK has been validated
- NOT NULL constraint has been validated on existing rows
Type changed ✔
⚖ Statistics:
[
  {
    phase: 'beforeDowntime',
    execution_time_ms: 523630,
    disk_wal_size: '2775 MB',
    disk_temp_size: '6355 MB'
  },
  {
    phase: 'downtime',
    execution_time_ms: 2864,
    disk_wal_size: '298 kB',
    disk_temp_size: '0 bytes'
  },
  {
    phase: 'afterDowntime',
    execution_time_ms: 1,
    disk_wal_size: '301 bytes',
    disk_temp_size: '0 bytes'
  }
]
Reverting 🕗
Reverted ✔
👷 Changing type with CHANGE_IN_PLACE_PRIMARY_KEY_AND_FOREIGN_KEY_CONSTRAINT 🕗
- user login has been disabled
- all connexions have been terminated
Opening maintenance window...
- transaction started
- column foobar.foo_id has been changed to type BIGINT
- column foo.id has been changed to type BIGINT
- sequence for foo.id table has been changed to type BIGINT
- INSERT has succeeded with id 2147483628
- transaction committed
Closing maintenance window...
default: 14.614s
Type changed ✔
⚖ Statistics:
[
  {
    phase: 'downtime',
    execution_time_ms: 30809,
    disk_wal_size: '1045 MB',
    disk_temp_size: '764 MB'
  }
]
Reverting 🕗
Reverted ✔
^C



```
