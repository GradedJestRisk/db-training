```postgresql
SELECT 
    inhparent::regclass relation_name,
    inhrelid::regclass::text AS prt_name,
    substring(inhrelid::regclass::text, 15 , 4)
FROM pg_catalog.pg_inherits
WHERE 1=1
    AND inhparent = 'traces_metier'::regclass
ORDER BY prt_name ASC
```