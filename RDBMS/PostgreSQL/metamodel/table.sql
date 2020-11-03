-- Tables
-- Given table name
SELECT
    t.table_name,
    t.*
  FROM information_schema.tables t
WHERE 1=1
--    and t.table_name = 'users'
    and t.table_catalog = 'pix'
ORDER BY
    t.table_name ASC
;

SELECT  COUNT(1) FROM information_schema.tables t WHERE t.table_name = 'answers'
;

-- Table record count
SELECT
   tbl.schemaname schm_nm,
   tbl.relname tbl_nm,
   tbl.n_live_tup record_count
FROM
     pg_stat_user_tables tbl
WHERE 1=1
    AND tbl.schemaname = 'public'
--    AND tbl.relname = 'users'
ORDER BY
   tbl.relname ASC
;

-- Table record count
SELECT
   tbl.relname tbl_nm,
   tbl.n_live_tup record_count
FROM
     pg_stat_user_tables tbl
WHERE 1=1
    AND tbl.schemaname = 'public'
ORDER BY
   tbl.relname ASC;



-- Use ANALYZE BEFORE !!
SELECT
  nspname AS schemaname,
  relname,
  reltuples
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE
  nspname NOT IN ('pg_catalog', 'information_schema') AND
  relkind='r'
ORDER BY reltuples DESC;

