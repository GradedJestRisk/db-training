# TOAST

## All tables

All tables with TOASTed data, their size and the TOAST size
```postgresql
SELECT 
  t.relname                                                 main_table_name,
  pg_size_pretty(pg_table_size(t.relname::regclass)-pg_table_size(t.reltoastrelid::regclass)) main_table_size,
  t.reltoastrelid                                           toast_table_name,
  pg_size_pretty(pg_table_size(t.reltoastrelid::regclass))  toast_table_size
FROM pg_class t 
WHERE 1=1
  AND t.reltoastrelid <> 0
  AND SUBSTR(t.relname, 1, 3) <> 'pg_'
  AND SUBSTR(t.relname, 1, 4) <> 'sql_'
```


## Table

Get toast table name 
```postgresql
SELECT relnamespace::regnamespace, relname
FROM pg_class
WHERE oid = (
  SELECT reltoastrelid
  FROM pg_class WHERE relname = 'book'
);
```

```postgresql
SELECT toast.relname
FROM pg_class heap 
    INNER JOIN pg_class toast ON heap.reltoastrelid = toast.oid
WHERE 1=1
  AND heap.relkind = 'r'
  AND heap.relname = 'tickets'
  AND toast.relkind = 't'
;  
```

Access (prefix with `toast` namespace)
```postgresql
SELECT 
  tst.chunk_id,
  tst.chunk_seq,
  tst.chunk_data,
  pg_size_pretty(length(tst.chunk_data)::BIGINT)
FROM pg_toast.pg_toast_16803 tst
```


## Column

Is the column toastable ?
```postgresql
SELECT 
  attname, 
  atttypid::regtype,
  CASE attstorage
    WHEN 'p' THEN 'plain'
    WHEN 'e' THEN 'external'
    WHEN 'm' THEN 'main'
    WHEN 'x' THEN 'extended'
    END AS storage
FROM pg_attribute
WHERE 1=1
  AND attrelid = 'people'::regclass 
  AND attnum > 0;
```

## Record

TOAST record size, slice count
```postgresql
SELECT 
  tst.chunk_id record_id,
  COUNT(*)     slice_count,
  pg_size_pretty((COUNT(*) * 2 * 1024) :: BIGINT) toasted_record_size
FROM pg_toast.pg_toast_16803 tst
GROUP BY tst.chunk_id
```

Row + TOAST record id
```postgresql
SELECT 
  b.id,
  b.name,
  b.content,
  pg_column_toast_chunk_id(b.content) chunk_id
FROM book b
```

How many slice per TOAST record ?
```postgresql
SELECT COUNT(*)
FROM pg_toast.pg_toast_16803 tst 
WHERE 1=1
    AND tst.chunk_id = 16808
;
```

## Serialize

Read from TOAST only if TOASTED content is necessary


1 block, as `content` is not selected and serialized 

```postgresql
EXPLAIN (ANALYZE, SERIALIZE)
SELECT id, name FROM book
```
| QUERY PLAN                                                                                              |
|:--------------------------------------------------------------------------------------------------------|
| Seq Scan on book  \(cost=0.00..18.50 rows=850 width=36\) \(actual time=0.028..0.029 rows=2.00 loops=1\) |
| Buffers: shared hit=1                                                                                   |
| Planning Time: 0.044 ms                                                                                 |
| Serialization: time=0.003 ms  output=1kB  format=text                                                   |
| Execution Time: 0.050 ms                                                                                |


1 block, as `content` is selected but not serialized

```postgresql
EXPLAIN (ANALYZE)
SELECT id, name, content FROM book
```

| QUERY PLAN                                                                                              |
|:--------------------------------------------------------------------------------------------------------|
| Seq Scan on book  \(cost=0.00..18.50 rows=850 width=68\) \(actual time=0.019..0.021 rows=2.00 loops=1\) |
| Buffers: shared hit=1                                                                                   |
| Planning Time: 0.046 ms                                                                                 |
| Execution Time: 0.036 ms                                                                                |



517 block, as `content` is selected and serialized

```postgresql
EXPLAIN (ANALYZE, SERIALIZE)
SELECT id, name, content FROM book
```

| QUERY PLAN                                                                                              |
|:--------------------------------------------------------------------------------------------------------|
| Seq Scan on book  \(cost=0.00..18.50 rows=850 width=68\) \(actual time=0.019..0.028 rows=2.00 loops=1\) |
| Buffers: shared hit=1                                                                                   |
| Planning Time: 0.045 ms                                                                                 |
| Serialization: time=33.392 ms  output=9362kB  format=text                                               |
| Buffers: shared hit=517                                                                                 |
| Execution Time: 33.963 ms                                                                               |
