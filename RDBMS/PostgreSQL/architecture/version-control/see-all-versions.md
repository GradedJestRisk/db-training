# See all versions

You can use the following extensions:
- [pg_dirtyread](https://github.com/df7cb/pg_dirtyread), which should be installed;
- [pg_visibility](https://www.postgresql.org/docs/current/pgvisibility.html), which is available out-of-the-box, but display actual data in cumbersome.

https://www.highgo.ca/2024/04/19/a-deeper-look-inside-postgresql-visibility-check-mechanism/

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

Disable auto-vacuum
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


## Create another version

Create another version
```postgresql
UPDATE versions 
SET version_number = 2, value = 'b'
WHERE id=1
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
You see version 2 only

| no | ctid  | xmin | xmax |
|----|-------|------|------|
| 2  | (0,2) | 750  | 0    |

## See all version

Now use the extension `pg_diryread`

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

You see both versions !

| no | ctid  | xmin | xmax | dead |
|----|-------|------|------|------|
| 1  | (0,1) | 749  | 750  | yes  |
| 2  | (0,2) | 750  | 0    |      |

## Remove dead tuples

Now force dead tuples removal.
```postgresql
VACUUM VERBOSE versions;
```

You'll get
```text
vacuuming "database.public.versions"
tuples: 1 removed
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

Version 1 is gone
| no | ctid  | xmin | xmax | dead |
|----|-------|------|------|------|
| 2  | (0,2) | 750  | 0    |      |

## Freeze

```postgresql
VACUUM FREEZE versions;
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
xmin has NOT changed

| no | ctid  | xmin | xmax | dead |
|----|-------|------|------|------|
| 2  | (0,2) | 750  | 0    |      |

## Release space

```postgresql
VACUUM FULL versions;
```

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