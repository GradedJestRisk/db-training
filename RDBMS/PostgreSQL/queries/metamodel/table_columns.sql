


-- Column
-- Given table name
SELECT
    c.table_name,
    c.column_name
  FROM information_schema.columns c
WHERE 1=1
    and c.table_name = 'users'
ORDER BY
    c.table_name, c.column_name ASC
;

-- Column
-- Given column name
SELECT
    c.table_name,
    c.column_name,
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length,
    'columns=>',
     c.*
  FROM information_schema.columns c
WHERE 1=1
    AND c.table_catalog = 'pix'
    AND c.table_schema  = 'public'
--    AND c.column_name = 'id'
    AND c.column_name LIKE '%Id'
ORDER BY
    c.table_name, c.column_name ASC
;


-- Column
-- Given column type
SELECT
    c.table_name,
    c.column_name,
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length,
    'columns=>',
     c.*
  FROM information_schema.columns c
WHERE 1=1
    --AND c.table_catalog = 'pix'
--    AND c.table_schema  = 'public'
    AND c.data_type     LIKE 'timestamp%'
--    AND c.data_type     = 'character varying'
--    AND c.column_name LIKE '%Id'
ORDER BY
    c.column_name ASC
;



-- Column
-- Count by type
SELECT
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length,
    COUNT(1)
FROM information_schema.columns c
WHERE 1=1
    AND c.table_catalog = 'pix'
    AND c.table_schema  = 'public'
--    AND c.column_name = 'id'
    AND c.column_name LIKE '%Id'
GROUP BY
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length
;


-- Column
-- Given column name (approx)
SELECT
    c.table_name,
    c.column_name
  FROM information_schema.columns c
WHERE 1=1
    and c.column_name LIKE '%ba%'
ORDER BY
    c.table_name, c.column_name ASC
;


-- Column
-- Column name containing hyphens
SELECT
    c.table_name,
    c.column_name
  FROM information_schema.columns c
 WHERE 1=1
   AND position( '-' in c.column_name) <> 0 ;



-- Column
-- With default values
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