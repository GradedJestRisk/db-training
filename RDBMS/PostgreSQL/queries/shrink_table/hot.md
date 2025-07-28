# Heap Only Tuple

## Overview

Heap Only Tuple
Heap Only(-referenced) Tuple
Tuple (which is referenced in the) Heap Only 
= a tuple that is not referenced from outside the table block.

Essentially, UPDATE-heavy workloads are challenging for PostgreSQL.

If a row is changed, instead of deleting the old version, a "forwarding address" (its line pointer number) is stored in the old row version.

That only works if the new and the old version of the row are in the same block. 

The external address of the row (the original line pointer) remains unchanged. To access the heap only tuple, PostgreSQL has to follow the "forwarding address" within the block.

## Theory

### MVCC

[Cybertec](https://www.cybertec-postgresql.com/en/hot-updates-in-postgresql-for-better-performance/)

> PostgreSQL implements multiversioning by keeping the old version of the table row in the table – an UPDATE adds a new row version (“tuple”) of the row and marks the old version as invalid.
In many respects, an UPDATE in PostgreSQL is not much different from a DELETE followed by an INSERT.

> This has a lot of advantages:
> - no need for an extra storage area where old row versions are kept
> - ROLLBACK does not have to undo anything and is very fast
> - no overflow problem with transactions that modify many rows

> But it also has some disadvantages:
> - old, obsolete (“dead”) tuples have to be removed from the table eventually (VACUUM)
> - heavily updated tables can become “bloated” with dead tuples
> - every update requires new index entries to be added, even if no indexed attribute is modified -  and modifying an index is much more expensive than modifying the table (order has to be maintained)

> Essentially, UPDATE-heavy workloads are challenging for PostgreSQL. This is the area where HOT updates help.

### HOT update

Line pointer at start of block
[Layout](https://www.postgresql.org/docs/current/storage-page-layout.html)

### Advantages

> There are two main advantages of HOT updates:
> - PostgreSQL doesn't have to modify indexes. Since the external address of the tuple stays the same, the original index entry can still be used. Index scans follow the HOT chain to find the appropriate tuple.

And we know that updating an index is costly.

> - Dead tuples can be removed without the need for VACUUM. If there are several HOT updates on a single row, the HOT chain grows longer. Now any backend that processes a block and detects a HOT chain with dead tuples (even a SELECT!) will try to lock and reorganize the block, removing intermediate tuples. This is possible, because there are no outside references to these tuples. This greatly reduces the need for VACUUM for UPDATE-heavy workloads.

And we know that `autovacuum` is limit its activity to not interfere with user queries.

### Conditions

> There are two conditions for HOT updates to be used:
> -   there must be enough space in the block containing the updated row (to create another line)
> -   there is no index defined on any column whose value it modified

The last condition is self-explanatory: if you updated the value and keep the index as-is, the index is no longer usable. 

### Leaving space in blocks 

> Note that setting fillfactor on an existing table will not rearrange the data, it will only apply to future INSERTs. But you can use VACUUM (FULL) or CLUSTER to rewrite the table, which will respect the new fillfactor setting.

[Extract block number from ctid](https://dba.stackexchange.com/questions/65964/how-do-i-decompose-ctid-into-page-and-row-numbers)


[Default fillfactor is 100%](https://www.postgresql.org/docs/current/sql-createtable.html)

```postgresql
DROP TABLE mytable;

CREATE TABLE mytable (
                         id  integer PRIMARY KEY,
                         val integer NOT NULL
) WITH (fillfactor= 100, autovacuum_enabled = off);

INSERT INTO mytable
SELECT *, 0
FROM generate_series(1, 235) AS n;
```

Most rows are in block 0
235 rows * 2 integers * 4 bytes per integer = 1 880 bytes
1 block is 8 000 bytes => fsm and vm
```postgresql
SELECT
    ctid,
    (ctid::text::point)[0]::bigint AS block
    , id, val
FROM mytable;
```

Rows per block
```postgresql
SELECT
    (ctid::text::point)[0]::bigint AS block,
    COUNT(1) rows_per_block
FROM mytable
GROUP BY (ctid::text::point)[0]::bigint
;
```

| block | rows_per_block |
|:------|:---------------|
| 0     | 226            |
| 1     | 9              |



Lower fillfactor
```postgresql
ALTER TABLE mytable SET (fillfactor = 70);
TRUNCATE mytable;
INSERT INTO mytable
SELECT *, 0
FROM generate_series(1, 235) AS n;
```

Rows per block
```postgresql
SELECT
    (ctid::text::point)[0]::bigint AS block,
    COUNT(1) rows_per_block
FROM mytable
GROUP BY (ctid::text::point)[0]::bigint
;
```
| block | rows_per_block |
|:------|:---------------|
| 0     | 158            |
| 1     | 77             |



Get not-default storage, fillfactor may not be 100%
```postgresql 
select 
    t.relname as table_name,
    t.reloptions
from pg_class t
  join pg_namespace n on n.oid = t.relnamespace
where 1=1
---  and t.relname in ('organization-learners')
 and n.nspname = 'public'
 and reloptions is not null
;
```

## Create dataset

```postgresql
DROP TABLE IF EXISTS foo;

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER
 );
``` 

Disable autovacuum
```postgresql
ALTER TABLE foo SET (AUTOVACUUM_ENABLED=FALSE);
```

Generate activity
```postgresql
INSERT INTO foo
  (value)
SELECT
  floor(random() * 2147483627 + 1)::int
FROM
    generate_series( 1, 1000000) -- 1 million => 2 seconds
;
```


## Generate activity - no HOT

```postgresql
UPDATE foo SET value = value - 1; -- 3s
```


No HOT update `n_tup_hot_upd`
```postgresql
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   'hot-update=>',
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
   'events=>',
   stt.n_tup_ins,
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
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
     AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY stt.n_tup_hot_upd DESC
;
```

## Generate activity - HOT

Change fillfactor
```postgresql
ALTER TABLE foo SET ( fillfactor = 50);
VACUUM FULL foo;
```

Generate activity - 30 s
```postgresql
UPDATE foo SET value = value - 1;
```


Check again `n_tup_hot_upd`
```postgresql
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   'hot-update=>',
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
   'events=>',
   stt.n_tup_ins,
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
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
     AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY stt.n_tup_hot_upd DESC
;
```
n_hot_tup_upd
1 000 000