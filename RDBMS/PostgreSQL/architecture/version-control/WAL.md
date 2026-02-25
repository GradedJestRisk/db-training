# WAL


[Dalibo](https://blog.dalibo.com/2024/01/05/cambouis.html)

## Automatic checkpointer configuration

> A checkpoint is begun every checkpoint_timeout seconds, or if max_wal_size is about to be exceeded, whichever comes first. The default settings are 5 minutes and 1 GB, respectively.

https://www.postgresql.org/docs/current/wal-configuration.html

> Checkpoints are run periodically (the frequency of requested checkpoints is defined by checkpoint_timeout), and when they complete in time and the next one naturally begins it’s considered a timed checkpoint. If checkpoints are calculating too slow or out of tune, they will be requested checkpoints.

https://thewordtim5times.com/blog/7

## Manual checkpoint

Force checkpoint (WAL)
```postgresql
CHECKPOINT
```

## Checkpoint logs 

https://www.postgresql.org/docs/14/monitoring-stats.html#MONITORING-PG-STAT-BGWRITER-VIEW

## Table (stats)

Checkpointed
```postgresql
SELECT 
    buffers_checkpoint              buffer_checkpointed,
    checkpoints_timed timed_count,
    checkpoints_req   requested_count,
    TO_CHAR(stats_reset,'HH:MI:SS') stats_since,
    '=>',
    bg.*
FROM pg_stat_bgwriter bg
```

Reset stats
```postgresql
SELECT pg_stat_reset_shared('bgwriter') ;
```

## Database logs

```text
2024-12-26 14:11:14.154 GMT [61] LOG:  checkpoint starting: time
2024-12-26 14:11:41.118 GMT [61] LOG:  checkpoint complete: wrote 44272 buffers (4.2%); 0 WAL file(s) added, 0 removed, 38 recycled; write=26.895 s, sync=0.003 s, total=26.965 s; sync files=19, longest=0.002 s, average=0.001 s; distance=626950 kB, estimate=626950 kB
```


## Asychronous or synchronous commit

[Postgresql docs](https://www.postgresql.org/docs/current/wal-async-commit.html)
> As described in the previous section, transaction commit is normally synchronous: the server waits for the transaction's WAL records to be flushed to permanent storage before returning a success indication to the client. The client is therefore guaranteed that a transaction reported to be committed will be preserved, even in the event of a server crash immediately after. 
> However, for short transactions this delay is a major component of the total transaction time. 
> Selecting asynchronous commit mode means that the server returns success as soon as the transaction is logically completed, before the WAL records it generated have actually made their way to disk. 

```text
synchronous_commit=off
```

## Get all WAL files size

### shell

Using shell
```text
root@cc1c742e9a47:/var/lib/postgresql/data# du --human $PGDATA/pg_wal
4.0K	/var/lib/postgresql/data/pg_wal/archive_status
4.0K	/var/lib/postgresql/data/pg_wal/summaries
1.3G	/var/lib/postgresql/data/pg_wal
```

### pg_ls_dir 

Using queries
```postgresql
SELECT
    pg_size_pretty(wal_files.count * s.setting::INT) wal_size
FROM
    (SELECT COUNT(*) AS count FROM pg_ls_dir('pg_wal') WHERE pg_ls_dir ~ '^[0-9A-F]{24}' ) wal_files,
    pg_settings s
WHERE 1=1
    AND s.name = 'wal_segment_size'
;
```
1232 MB

## Get WAL generated between 2 operations

### pg_wal_lsn_diff

```sql
SELECT  pg_current_wal_insert_lsn();
```

0/1C2A528

```postgresql
INSERT INTO mytable (id)
SELECT n
FROM generate_series(1, 10000000) AS n;
```

```postgresql
SELECT  pg_current_wal_insert_lsn();
```
0/280A4570

Use `pg_wal_lsn_diff`
```postgresql
SELECT  pg_size_pretty(pg_wal_lsn_diff('0/280A4570','0/1C2A528'));
```
612 MB

### pg_lsn

Or `::pg_lsn`
```postgresql
SELECT pg_size_pretty('0/748F4EF8'::pg_lsn - '0/4E4CFAA8'::pg_lsn )
```


## Explore WAL

Use pg_waldump
```shell
/usr/lib/postgresql/17/bin/pg_waldump --stats --path=$PGDATA/pg_wal --start=0/1C2A528 --end=0/280A4570
```


```postgresql
DROP TABLE IF EXISTS mytable ;

CREATE TABLE mytable (
    id  integer
) WITH (AUTOVACUUM_ENABLED = FALSE);

SELECT  pg_current_wal_insert_lsn();

INSERT INTO mytable (id)
SELECT n
FROM generate_series(1, 10000000) AS n;

SELECT  pg_current_wal_insert_lsn();
```


```text
root@525ec17ec544:/var/lib/postgresql/data# /usr/lib/postgresql/17/bin/pg_waldump --stats --path=$PGDATA/pg_wal --start=0/1C2A528 --end=0/280A4570
WAL statistics between 0/1C2A528 and 0/280A4570:
Type                                           N      (%)          Record size      (%)             FPI size      (%)        Combined size      (%)
----                                           -      ---          -----------      ---             --------      ---        -------------      ---
XLOG                                           1 (  0.00)                   30 (  0.00)                    0 (  0.00)                   30 (  0.00)
Transaction                                   14 (  0.00)                  476 (  0.00)                    0 (  0.00)                  476 (  0.00)
Storage                                        1 (  0.00)                   42 (  0.00)                    0 (  0.00)                   42 (  0.00)
CLOG                                           0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Database                                       0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Tablespace                                     0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
MultiXact                                      0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
RelMap                                         0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Standby                                        0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Heap2                                         10 (  0.00)                 1384 (  0.00)                21180 (  8.52)                22564 (  0.00)
Heap                                    10000329 (100.00)            590075319 (100.00)               154428 ( 62.15)            590229747 ( 99.98)
Btree                                        187 (  0.00)                19148 (  0.00)                72868 ( 29.33)                92016 (  0.02)
Hash                                           0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Gin                                            0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Gist                                           0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Sequence                                       0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
SPGist                                         0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
BRIN                                           0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
CommitTs                                       0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
ReplicationOrigin                              0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
Generic                                        0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
LogicalMessage                                 0 (  0.00)                    0 (  0.00)                    0 (  0.00)                    0 (  0.00)
                                        --------                      --------                      --------                      --------
Total                                   10000542                     590096399 [99.96%]               248476 [0.04%]             590344875 [100%]
```

All information comes from record, not FPI.


## Get WAL generated by a query

Use `BUFFERS` options
```postgresql
EXPLAIN (ANALYSE , BUFFERS , WAL)
INSERT INTO mytable (id)
SELECT n
FROM generate_series(1, 10000000) AS n;
```

You get
```text
| QUERY PLAN |
| :--- |
| Insert on mytable  \(cost=0.00..100000.00 rows=0 width=0\) \(actual time=5934.867..5934.869 rows=0 loops=1\) |
|   Buffers: shared hit=10088486 dirtied=44248 written=88286, temp read=17090 written=17090 |
|   I/O Timings: shared write=580.779, temp read=39.094 write=165.463 |
|   WAL: records=10000000 bytes=590000000 |
|   -&gt;  Function Scan on generate\_series n  \(cost=0.00..100000.00 rows=10000000 width=4\) \(actual time=571.454..1063.688 rows=10000000 loops=1\) |
|         Buffers: temp read=17090 written=17090 |
|         I/O Timings: temp read=39.094 write=165.463 |
| Planning Time: 0.052 ms |
| Execution Time: 5937.470 ms |
```
> records=10 000 000 bytes=590 000 000
So 590 Mb for 10 million records


## Get WAL generated by a backend

Only > v18
```postgresql
SELECT *  
FROM pg_stat_get_backend_io(pg_backend_pid()) where object = 'wal';
```
[Source](https://bdrouvot.github.io/2025/04/02/postgres-backend-statistics-part-2/)

## Disable or reduce WAL


### Log less information

You cannot disable WAL, but you can reduce what is logged.

[](https://medium.com/@wasiualhasib/deep-dive-into-postgresql-wal-parameters-wal-writer-delay-wal-writer-flush-after-and-0b0d5d6dc741)
> From the above, it is clear that the worst cases are those with wal_compression disabled, while the best cases are those with compression enabled. 


#### log_level

[From Postgresql docs](https://www.postgresql.org/docs/current/runtime-config-wal.html)
> `minimal` removes all logging except the information required to recover from a crash or immediate shutdown.
>  archive_mode cannot be enabled when wal_level is set to minimal.
 
```text
wal_level=minimal
```

#### hint bits (wal_log_hints)

Hint bits are not logged - they are not critical for recovery.
But if you use checksum protection, setting hint bits change checksum, so PostgreSQL write the whole block to WAL.
```postgresql
SHOW data_checksums
```

This is the default, but you can switch it off.
```text
wal_log_hints = OFF
```

[Reference](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-WAL-LOG-HINTS)

#### do not log table creation

Write it to FS instead when table size > `wal_skip_threshold`

```postgresql
SELECT setting, unit, min_val, max_val FROM pg_settings s
WHERE 1=1
    AND s.name = 'wal_skip_threshold'
;
```

> When wal_level is minimal and a transaction commits after creating or rewriting a permanent relation, this setting determines how to persist the new data. If the data is smaller than this setting, write it to the WAL log; otherwise, use an fsync of affected files
[Source](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-WAL-SKIP-THRESHOLD)


#### do not log full block after modification

May cause data corruption, `ON` by default
```postgresql
SHOW full_page_writes 
```

```text
full_page_writes = OFF
```

#### compress

Disabled by default.
Only on full-age write ?

```postgresql
SHOW wal_compression
```

```postgresql
SELECT setting, enumvals FROM pg_settings s
WHERE 1=1
    AND s.name = 'wal_compression'
;
```


```text
wal_compression = ON
```

[Source](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-WAL-COMPRESSION)

### Write WAL buffers from memory to FS (wal_writer)

To reduce WAL buffers write to disk, make it less frequently

Set `wal_writer_delay` to max, `10000`
```postgresql
SELECT setting, unit, min_val, max_val FROM pg_settings s
WHERE 1=1
    AND s.name = 'wal_writer_delay'
;
```

To reduce WAL buffers write to disk, keep writing to OS cache but do not ask to write to disk
Set `wal_writer_flush_after` to `0` 

```postgresql
SELECT setting, unit, min_val, max_val FROM pg_settings s
WHERE 1=1
    AND s.name = 'wal_writer_flush_after'
;
```

All in all

```text
# write each 10 seconds, do not ask for fsync
wal_writer_delay = 10000
wal_writer_flush_after = 0
```

[Source](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-WAL-WRITER-DELAY)



### Write dirty buffers to disk (checkpointer)

```text
# Checkpoint frequency : set to one day so its does not happens frequently
checkpoint_timeout = 1d
wal_level = minimal
max_wal_senders = 0
min_wal_size = 1GB
# The size of WAL files that will trigger a checkpoint, regardless of frequency
max_wal_size = 4GB
```