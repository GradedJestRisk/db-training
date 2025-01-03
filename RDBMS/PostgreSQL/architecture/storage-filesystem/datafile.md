# Datafile structure

## Files

### Relation (heap)

Each relation is stored in at least one file on FS.

The filename is the relation oid, eg. `16433` for table `big_table', followed by a dot if table exceeds 1 GB.

All relation files are stored in a folder, named with the database oid, eg. `16384` for database "database".

All database folder are stored in a folder named `base`, pointed by $PGDATA or `data_directory` setting.

Eg
```text
root@845f5da6d8e1:/# ls -ltrah /var/lib/postgresql/data/base/16384/16385
-rw------- 1 postgres postgres 346M Dec 26 10:44 /var/lib/postgresql/data/base/16384/16385
```

### Find files 

To get the fragment under $PGDATA for a relation
```postgresql
SELECT  pg_relation_filepath('big_table')
```

You get.
```text
base/16384/16433
```

Which is.
```text
base/$DATABASE_OID/$TABLE_OID
```

Relation
```postgresql
SELECT *
FROM pg_class 
WHERE relname = 'big_table' and oid  = 16433
```

Database
```postgresql
SELECT *
FROM pg_database 
WHERE oid=16384 and datname = 'database'
```

In a container, you can get all files for a relation by executing
```postgresql
SELECT 'docker exec --tty postgresql bash -c ' || '"' || 'du -sh ' || setting || '/' ||  pg_relation_filepath('big_table') || '"'
FROM pg_settings WHERE name = 'data_directory';
```

## Structure of a file

### Relation

https://www.postgresql.org/docs/current/storage-file-layout.html

Each relation is stored in several blocks (=pages), 8 kbytes each.
```postgresql
SHOW block_size;
```

Each tuple can be located by using ctid, which is (block_number, offset).
```postgresql
SELECT ctid
FROM versions;
```

There are 2 tuples, all in the same block (0) at offset 1 and 2

| ctid  |
|:------|
| (0,1) |
| (0,2) |


## pageinspect

To display the block content:
- header
- its tuple

> All tuples are shown, whether or not the tuples were visible to an MVCC snapshot at the time the raw page was copied.

### Create data, single column

Create a table
```postgresql
DROP TABLE IF EXISTS versions;
CREATE TABLE versions (id INTEGER, version INTEGER);
```

Disable auto-vacuum, which launch auto-freeze
```postgresql
ALTER TABLE versions SET (autovacuum_enabled = off);
```

Create a version
```postgresql
INSERT INTO versions (id, version) VALUES (1, 1); 
INSERT INTO versions (id, version) VALUES (1, 2); 
INSERT INTO versions (id, version) VALUES (1, 63); 
INSERT INTO versions (id, version) VALUES (1, 64); 
INSERT INTO versions (id, version) VALUES (1, 65); 
INSERT INTO versions (id, version) VALUES (1, 66); 
```


### Inspect


Tuples pointers, with tuple data as single value
```postgresql
SELECT * 
FROM heap_page_items(
        get_raw_page('versions', 0)
);
``` 

Tuples pointers, with tuple data in columns
```postgresql
SELECT * 
FROM 
heap_page_item_attrs(
        get_raw_page('versions', 0), 
        'versions'::regclass,
        TRUE);
```

Tuples data
```postgresql
SELECT 
    tuple_data_split('versions'::regclass, t_data, t_infomask, t_infomask2, t_bits) 
FROM 
    heap_page_items(
            get_raw_page('versions', 0)
    );
```

### Decode data (manually)

```postgresql
DROP TABLE IF EXISTS versions;
CREATE TABLE versions (id INTEGER);
```

Create a version
```postgresql
TRUNCATE TABLE versions;
INSERT INTO versions (id) VALUES (1);        --2^0 
INSERT INTO versions (id) VALUES (2);        --2 * 2^0 
INSERT INTO versions (id) VALUES (256);      --2^8
INSERT INTO versions (id) VALUES (65536);    --2^16 
INSERT INTO versions (id) VALUES (16777216); --2^24
```

```postgresql
SELECT 
    2^0,
    2^8,
    2^16,
    2^24;
```

Tuples data.

You need to know how data is stored:
- each INTEGER is 4 bytes

```postgresql
SELECT
    id.value raw,
    id.id_first_byte * 2^0 +
    id.id_second_byte * 2^8 +
    id.id_third_byte * 2^16 +
    id.id_fourth_byte * 2^24 value
FROM( 
    SELECT
        tuple.tuple_data_split[1] value,
        get_byte(tuple.tuple_data_split[1], 0) id_first_byte, 
        get_byte(tuple.tuple_data_split[1], 1) id_second_byte, 
        get_byte(tuple.tuple_data_split[1], 2) id_third_byte,
        get_byte(tuple.tuple_data_split[1], 3) id_fourth_byte    
    FROM (
        SELECT 
            tuple_data_split('versions'::regclass, t_data, t_infomask, t_infomask2, t_bits) 
        FROM 
            heap_page_items(
                    get_raw_page('versions', 0)
            )
        ) tuple 
) id
ORDER BY id.value DESC
```



2 integer
```postgresql
SELECT
    tuple.tuple_data_split[1],
    get_byte(tuple.tuple_data_split[1], 0) id, 
    get_byte(tuple.tuple_data_split[2], 0) version
FROM (
    SELECT 
        tuple_data_split('versions'::regclass, t_data, t_infomask, t_infomask2, t_bits) 
    FROM 
        heap_page_items(
                get_raw_page('versions', 0)
        )) tuple;
```


### Flags

Tuple flags, eg `frozen`
```postgresql
SELECT 
    t_ctid, 
    --raw_flags, 
    combined_flags
FROM heap_page_items(get_raw_page('versions', 0)),
           LATERAL heap_tuple_infomask_flags(t_infomask, t_infomask2)
WHERE t_infomask IS NOT NULL OR t_infomask2 IS NOT NULL;
```