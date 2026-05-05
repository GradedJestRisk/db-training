# TOAST

Is the column toastable ?
```postgresql
SELECT attname, atttypid::regtype,
CASE attstorage
WHEN 'p' THEN 'plain'
WHEN 'e' THEN 'external'
WHEN 'm' THEN 'main'
WHEN 'x' THEN 'extended'
END AS storage
FROM pg_attribute
WHERE attrelid = 'people'::regclass AND attnum > 0;
```

Get toast table name 
```postgresql
SELECT relnamespace::regnamespace, relname
FROM pg_class
WHERE oid = (
SELECT reltoastrelid
FROM pg_class WHERE relname = 'people'
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

Access
```postgresql
SELECT * FROM pg_toast.pg_toast_16424
```
