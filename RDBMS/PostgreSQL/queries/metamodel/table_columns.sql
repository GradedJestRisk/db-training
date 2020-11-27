


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
    c.column_name
  FROM information_schema.columns c
WHERE 1=1
    and c.column_name = 'id'
ORDER BY
    c.table_name, c.column_name ASC
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
