# Column

## Given table name

```postgresql
SELECT
     'column'
     ,c.table_name
     ,c.column_name
     ,c.is_nullable
--     ,c.table_schema
--     ,'columns=>'
     ,c.*
FROM
     information_schema.columns c
WHERE 1=1
    AND c.table_schema = 'public'
    --AND c.table_name = 'answers'
    --AND c.data_type = 'character varying'
    --AND c.character_maximum_length = 255
    --AND c.column_name ILIKE '%code%'
    --AND c.is_nullable = 'NO'
ORDER BY
    c.table_name, c.column_name ASC
;
```


## Given column name

```postgresql
SELECT
     'column'
     ,c.table_name
     ,c.column_name
     ,c.is_nullable
--     ,c.table_schema
--     ,'columns=>'
     ,c.*
FROM
     information_schema.columns c
WHERE 1=1
    AND c.table_schema = 'public'
    --AND c.table_name = 'answers'
    --AND c.data_type = 'character varying'
    --AND c.character_maximum_length = 255
    AND c.column_name = ''
    --AND c.column_name ILIKE '%code%'
    --AND c.is_nullable = 'NO'
ORDER BY
    c.table_name, c.column_name ASC
;
```


## Given column type

```postgresql
SELECT
    c.table_catalog,
    c.table_schema,
    c.table_name,
    c.column_name,
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length,
    c.is_nullable,
    'columns=>',
     c.*
  FROM information_schema.columns c
WHERE 1=1
    AND c.table_catalog = 'flight'
    AND c.table_schema  NOT IN ('information_schema', 'pg_catalog')
--     AND c.data_type     LIKE 'timestamp%'
   -- AND c.table_name  NOT LIKE 'pg_%'
--     AND SUBSTR(c.table_name, 1,3) <> 'pg_'
    AND c.data_type     = 'jsonb'
--    AND c.column_name LIKE '%Id'
--    AND is_nullable = 'NO'
ORDER BY
    c.column_name ASC
;
```

```postgresql
SELECT * 
FROM airports_data
```

## Count by type

```postgresql
SELECT
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length,
    COUNT(1)
FROM information_schema.columns c
WHERE 1=1
    AND c.table_catalog = 'flight' -- database name
    --AND c.table_schema  = 'flight'
--     AND SUBSTR(c.table_name, 1,3) <> 'pg_'
    AND c.table_schema  NOT IN ('information_schema', 'pg_catalog')
--    AND c.data_type = 'name'
--    AND c.column_name = 'id'
    --AND c.column_name LIKE '%Id'
GROUP BY
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length
ORDER BY COUNT(1) DESC;
```

## Lint

### Name containing hyphens

```postgresql
SELECT
    c.table_name,
    c.column_name
  FROM information_schema.columns c
 WHERE 1=1
   AND position( '-' in c.column_name) <> 0 ;
```


### With default values

```postgresql
SELECT
    c.table_name,
    c.column_name,
    c.column_default
  FROM information_schema.columns c
WHERE 1=1
    AND c.table_name = 'organizations'
    AND c.column_default IS NOT NULL
ORDER BY
    c.table_name, c.column_name ASC
;
```

### Schema-lint whitelist

```postgresql
SELECT DISTINCT
--      'column'
--      ,c.table_name
--      ,c.column_name
-- --     ,c.table_schema
--     '{identifier: ''' || c.table_schema ||  '.' || c.table_name  || '.' || c.column_name  || ''', rule: ''default-varchar-length'' },'
    '{identifierPattern: ''' || c.table_schema ||  '\\.' || c.table_name  || '.*'', rule: ''default-varchar-length'' },'
--     ,'columns=>'
--     ,c.*
FROM
     information_schema.columns c
WHERE 1=1
    AND c.table_schema = 'public'
    AND c.data_type = 'character varying'
    AND c.character_maximum_length = 255
-- ORDER BY
--     c.table_name, c.column_name ASC
;
```
