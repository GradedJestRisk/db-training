# Database, index, table

## Primitive

[Doc](https://www.postgresql.org/docs/current/datatype.html)

Name 	            Storage Size (octet = byte)
smallint 	        2
integer 	        4
bigint 	            8
decimal 	        variable
decimal 	        variable
numeric 	        variable
real 	            4
double precision 	8


Dataset
```postgresql

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER CONSTRAINT value_unique UNIQUE
 );

INSERT INTO foo (value)
SELECT floor(random() * 2147483627 + 1)::int
FROM
    generate_series( 1, 1000000) -- 1 million => 40 seconds
ON CONFLICT ON CONSTRAINT value_unique DO NOTHING;
```

## Record

https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-ADMIN-DBSIZE
https://www.postgresql.org/docs/current/storage-toast.html

```postgresql
SELECT octet_length(repeat('1234567890',(2^n)::integer)),
       pg_column_size(repeat('1234567890',(2^n)::integer))
FROM generate_series(0,12) n;

CREATE TABLE stored_query AS
SELECT repeat('1234567890',(2^n)::integer) AS data
FROM generate_series(0,12) n;

SELECT
    octet_length(data)   uncompressed,
    pg_column_size(data) compressed,
    (octet_length(data) - pg_column_size(data) ) saved_space_due_redundency,
    data
FROM stored_query
ORDER BY LENGTH(data) DESC;
```


```postgresql
-- Columns
SELECT
    c.column_name,
    c.data_type
  FROM information_schema.columns c
WHERE 1=1
    and c.table_name = 'foo'
;

-- https://stackoverflow.com/questions/13304572/how-can-pg-column-size-be-smaller-than-octet-length
-- Record (compressed)
SELECT
       id, pg_column_size(f.*)
FROM foo f
    WHERE id = 1
;

-- Record (uncompressed)
SELECT
       octet_length(t.*::text)
FROM foo AS t
    WHERE id = 1
;
```

## Table

```postgresql
SELECT
    MOD(id, 2), COUNT(1)
FROM foo
GROUP BY MOD(id, 2);

-- Generate insert
INSERT INTO foo (value)
SELECT floor(random() * 2147483627 + 1)::int
FROM
    generate_series( 1, 1000000) -- 1 million => 10 seconds
ON CONFLICT ON CONSTRAINT value_unique DO NOTHING;

-- Generate dead tuples
DELETE FROM foo
WHERE MOD(id, 2) = 0;

-- Generate update
UPDATE foo SET value = -1 * value;
;
```

### Row count 

#### Immediate, not accurate : pg_stat_user_tables

```postgresql
SELECT
   stt.n_live_tup,
   stt.last_analyze,
   stt.last_autoanalyze
FROM pg_stat_user_tables stt
WHERE 1=1
   AND relname = 'answers'
;
```

#### Actual, may take time : pg_stat_get_*_tuples

```postgresql
SELECT
    COUNT(*)                                        live_row_count_actual,
    pg_stat_get_live_tuples('public.foo'::regclass) live_row_count_estimated,
    pg_stat_get_dead_tuples('public.foo'::regclass) dead_row_count_estimated
FROM foo
;
```

### Statistics

#### Update 

Update statistics (update estimation)
```postgresql
ANALYZE foo;
--VACUUM ANALYZE foo;
```

Reclaim space => 5 seconds
Execute DELETE, check dead_tuples, then run VACUUM full
```postgresql
VACUUM FULL;
```

#### Reset

```postgresql
SELECT
    pg_stat_reset_single_table_counters('public.foo'::regclass)
;
```

####  Statistics

```postgresql
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   'events=>',
   stt.n_tup_ins,
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
   stt.n_tup_del
FROM pg_stat_user_tables stt
WHERE 1=1
   AND relname = 'foo'
;
```

Full
Statistics
```postgresql
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   'events=>',
   stt.n_tup_ins,
   stt.n_tup_upd,
   stt.n_tup_hot_upd,  -- hot, see https://www.cybertec-postgresql.com/en/hot-updates-in-postgresql-for-better-performance/
   stt.n_tup_del,
   'analyze=>',
   stt.last_analyze,
   stt.analyze_count,
   stt.last_autoanalyze,
   stt.autoanalyze_count,
   'vacuum=>',
   stt.last_vacuum,
   stt.vacuum_count,
   stt.last_autovacuum,
   stt.autovacuum_count,
   'pg_stat_user_tables=>'
   ,stt.*
FROM pg_stat_user_tables stt
WHERE 1=1
--    AND relname = 'foo'
   AND stt.last_autoanalyze IS NOT NULL
;
```

### Data (regular + TOAST + fsm + vm)  : pg_table_size

> the size reported includes the actual table data, any TOAST table data, the free space map and the visibility map. 
> The size of any indexes is NOT included in the total.

```postgresql
SELECT
       pg_table_size('foo')                   data_size_octet,
       pg_size_pretty(pg_table_size('foo'))   data_size_pretty
;
```

### Indexes only : pg_indexes_size

```postgresql
SELECT
       pg_size_pretty(pg_indexes_size('foo'))   index_size
;
```


Get included indexes
```postgresql
SELECT
    ndx.indexname  ndxl_nm
   ,ndx.indexdef  dfn
FROM pg_indexes ndx
WHERE 1=1
    AND ndx.tablename = 'foo'
;
```


### Data + indexes : pg_total_relation_size

```postgresql
SELECT
       pg_size_pretty(  pg_total_relation_size('foo'))  data_toast_index
;
```

### Complete

[SE](https://dba.stackexchange.com/questions/23879/measure-the-size-of-a-postgresql-table-row/23933#23933)
```postgresql
WITH x AS (
   SELECT count(*)               AS ct
        , sum(length(t::text))   AS txt_len  -- length in characters
        , 'public.foo'::regclass AS tbl      -- provide table name as string
   FROM   public.foo t                       -- provide table name as name
   ), y AS (
   SELECT ARRAY [pg_relation_size(tbl)
               , pg_relation_size(tbl, 'vm')
               , pg_relation_size(tbl, 'fsm')
               , pg_table_size(tbl)
               , pg_indexes_size(tbl)
               , pg_total_relation_size(tbl)
               , txt_len
             ] AS val
        , ARRAY ['core_relation_size'
               , 'visibility_map'
               , 'free_space_map'
               , 'table_size_incl_toast'
               , 'indexes_size'
               , 'total_size_incl_toast_and_indexes'
               , 'live_rows_in_text_representation'
             ] AS name
   FROM   x
   )
SELECT unnest(name)                AS metric
     , unnest(val)                 AS bytes
     , pg_size_pretty(unnest(val)) AS bytes_pretty
     , unnest(val) / NULLIF(ct, 0) AS bytes_per_row
FROM   x, y
UNION ALL SELECT '------------------------------', NULL, NULL, NULL
UNION ALL SELECT 'row_count', ct, NULL, NULL FROM x
UNION ALL SELECT 'live_tuples', pg_stat_get_live_tuples(tbl), NULL, NULL FROM x
UNION ALL SELECT 'dead_tuples', pg_stat_get_dead_tuples(tbl), NULL, NULL FROM x
;
```


Without COUNT (can be resource-consuming)
```postgresql
WITH x AS (
   SELECT ARRAY [pg_relation_size('foo')
               , pg_relation_size('foo', 'vm')
               , pg_relation_size('foo', 'fsm')
               , pg_table_size('foo')
               , pg_indexes_size('foo')
               , pg_total_relation_size('foo')
             ] AS val
        , ARRAY ['core_relation_size'
               , 'visibility_map'
               , 'free_space_map'
               , 'table_size_incl_toast'
               , 'indexes_size'
               , 'total_size_incl_toast_and_indexes'
             ] AS name
)
SELECT unnest(name)                AS metric
     , unnest(val)                 AS bytes
     , pg_size_pretty(unnest(val)) AS bytes_pretty
FROM x
;
```

## Index

> An index is sometimes considered a "table", in this case when using pg_table_size(), and so you get 8192 as the size of the index table (i.e., relation).
> Since an index doesn't have an index of its own, pg_indexes_size() returns 0.

[Source](https://postgrespro.com/list/thread-id/1235601)



## Database

### Components

Components are
- shared buffer
- WAL
- temp
- ...

[Doc](https://www.postgresql.fastware.com/blog/back-to-basics-with-postgresql-memory-components)


#### Block size

```postgresql
-- Block size
SELECT current_setting('block_size');
```

#### Cache

```postgresql
--
SHOW shared_buffers;
-- 128 MB
```

#### client working area
```postgresql
SHOW work_mem;
-- 4MB
```

#### Temporary table storage

Unrelated to temporary files

```postgresql
SHOW temp_buffers
;
```
8MB

```postgresql
SELECT *
FROM pg_controldata
;
```

### Database

```postgresql
SELECT
       pg_size_pretty(  pg_database_size('database'))  data_toast_index
;
```

https://www.postgresql.org/docs/current/monitoring-stats.html#PG-STAT-DATABASE-VIEW


Reset stats
```postgresql
SELECT pg_stat_reset()
;

```

### Statistics

```postgresql
SELECT
     'Database stats=>'
     ,db.stats_reset  audit_start_time
     ,db.numbackends  client_actually_connected
     ,'cache:'
     ,db.blks_read    blocks_read_file
     ,db.blks_read    blocks_read_memory
     ,'counts:'
     ,db.xact_commit   commit_count
     ,db.xact_rollback rollback_count
     ,db.tup_returned  rows_returned_to_client
     ,db.tup_fetched   rows_select
     ,db.tup_inserted  rows_inserted
     ,db.tup_updated   rows_updated
     ,db.tup_deleted   rows_deleted
     ,'pg_stat_database->'
     ,db.*
FROM
    pg_stat_database db
WHERE 1=1
    AND db.datname = 'database'
;
```

### Disc

#### total
Volume total size (all volumes)

```shell
docker system df
```

#### File mapping

https://www.postgresql.org/docs/current/storage-file-layout.html

Named volume size
```shell
sudo du -sh /var/lib/docker/volumes/database_database-data/
```

Browse
```shell
sudo ncdu /var/lib/docker/volumes/database_database-data/
```

### WAL

```text
_data/pg_wal
-- Relations
_data/base/16384
```

### Total activity

Reset stats
```postgresql
select pg_stat_statements_reset();
```

Get
```postgresql
SELECT
    TRUNC(SUM(stt.total_exec_time))                  execution_time_ms
   ,pg_size_pretty(SUM(wal_bytes))                   disk_wal_size
   ,pg_size_pretty(SUM(temp_blks_written) * 8192)    disk_temp_size
FROM pg_stat_statements stt
    INNER JOIN pg_authid usr ON usr.oid = stt.userid
    INNER JOIN pg_database db ON db.oid = stt.dbid
WHERE 1=1
    AND db.datname = 'database'
;
```
