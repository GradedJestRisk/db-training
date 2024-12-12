# Freeze

[DOC](https://www.interdb.jp/pg/pgsql05/10.html)

## Setup

Start instance with [pg-dirtyread](https://tracker.debian.org/pkg/pg-dirtyread) extension.

You'll find one [here](../../docker/justfile).
```shell
just start-instance-fresh
```

## Create a version

Create a table
```postgresql
DROP TABLE IF EXISTS versions;
CREATE TABLE versions (id INTEGER, version_number INTEGER, value TEXT);
```

Disable auto-vacuum, which launch auto-freeze
```postgresql
ALTER TABLE versions SET (autovacuum_enabled = off);
```

Create a version
```postgresql
INSERT INTO versions (id, version_number, value) 
VALUES (1, 1, 'a'); 
```

Get versions
```postgresql
SELECT 
    'values=>',
    v.id, v.version_number, v.value,
    'flags=>',
    ctid, xmin, xmax
FROM versions v
WHERE 1=1
    AND v.id = 1
    --AND v.version_number = 1
```
You see version 1

| no | ctid  | xmin | xmax |
|----|-------|------|------|
| 1  | (0,1) | 749  | 0    |


## Freeze

Get parameters
```postgresql
SHOW  vacuum_freeze_min_age;
SHOW  vacuum_freeze_table_age;
```

Launch freeze
```postgresql
VACUUM FREEZE VERBOSE versions;
```

You'll get
```text
removable cutoff: 760, which was 0 XIDs old when operation ended
new relfrozenxid: 760, which is 6 XIDs ahead of previous value
```

## Check frozen 

Check
```postgresql
SELECT
    'values=>',
    v.id, v.version_number, v.value,
    'flags=>',
    v.ctid, v.xmin, v.xmax, v.dead
FROM pg_dirtyread('versions') 
    AS v(ctid tid, xmin xid, xmax xid, dead boolean,
        id INTEGER, version_number INTEGER, value TEXT)
WHERE v.id = 1;
```
xmin has NOT changed ! 

| no | ctid  | xmin | xmax | dead |
|----|-------|------|------|------|
| 2  | (0,2) | 750  | 0    |      |


> In versions 9.4 or later, the XMIN_FROZEN bit is set to the t_infomask field of tuples rather than rewriting the t_xmin of tuples to the frozen txid (Figure 5.21 b).
[Doc](https://www.interdb.jp/pg/pgsql05/10.html)

## Peek into t_infomask

Activate `pageinspect`
```postgresql
CREATE EXTENSION pageinspect;
```


[Doc](https://www.postgresql.org/docs/current/pageinspect.html)

Get flags
```postgresql
SELECT 
    t_ctid, 
    --raw_flags, 
    combined_flags
FROM heap_page_items(get_raw_page('versions', 0)),
           LATERAL heap_tuple_infomask_flags(t_infomask, t_infomask2)
WHERE t_infomask IS NOT NULL OR t_infomask2 IS NOT NULL;
```

It is frozen.

| t_ctid | combined_flags     |
|:-------|:-------------------|
| (0,2)  | {HEAP_XMIN_FROZEN} |

## Create another version

It will not be frozen
```postgresql
UPDATE versions 
SET version_number = 2, value = 'b'
WHERE id=1
```

Check
```postgresql
SELECT
    'values=>',
    v.id, v.version_number, v.value,
    'flags=>',
    v.ctid, v.xmin, v.xmax, v.dead
FROM pg_dirtyread('versions') 
    AS v(ctid tid, xmin xid, xmax xid, dead boolean,
        id INTEGER, version_number INTEGER, value TEXT)
WHERE v.id = 1;
```

| no | ctid  | xmin | xmax | dead |
|----|-------|------|------|------|
| 2  | (0,2) | 759  | 762  |      |
| 2  | (0,3) | 762  | 0    |      |

Get flags
```postgresql
SELECT 
    t_ctid, 
    --raw_flags, 
    combined_flags
FROM heap_page_items(get_raw_page('versions', 0)),
           LATERAL heap_tuple_infomask_flags(t_infomask, t_infomask2)
WHERE t_infomask IS NOT NULL OR t_infomask2 IS NOT NULL;
```

| t_ctid | combined_flags     |
|:-------|:-------------------|
| (0,3)  | {HEAP_XMIN_FROZEN} |
| (0,3)  | {}                 |
