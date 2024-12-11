# filesystem

## Layout

https://www.postgresql.org/docs/current/storage-file-layout.html

Layout
- base
  - database
    - relation
- pg_wal

## Database

Size
```postgresql
SELECT 
    pg_size_pretty(pg_database_size('postgres'));
```

## Relation (heap)

```postgresql
SELECT pg_relation_filenode('') 
```


https://wiki.postgresql.org/wiki/Disk_Usage
```postgresql
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;
```