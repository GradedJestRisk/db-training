-- Tables
-- Given table name
SELECT
    t.table_name,
    t.*
  FROM information_schema.tables t
WHERE 1=1
    AND t.table_type = 'BASE TABLE'
--    and t.table_name = 'users'
    and t.table_catalog = 'pix'
    and t.table_schema = 'public'
ORDER BY
    t.table_name ASC
;

-- Table
-- Given OID (object identifier)
SELECT
   oid     obj_dtf ,
   relname tbl_nm,
   c.*
FROM
     pg_class c
WHERE 1=1
--    AND relname = 'users'
    AND relkind = 'r'
    AND oid     IN ( 138183, 30074)
ORDER BY
    relname ASC
;

-- Table + OID
SELECT
  --sch.nspname sch,
  tbl.relname tbl_nm,
  tbl.oid
FROM pg_class tbl
    INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
WHERE 1=1
    AND tbl.relkind = 'r'
    AND sch.nspname = 'public'
ORDER BY relname ASC;





-- Table record count
SELECT
   tbl.schemaname schm_nm,
   tbl.relname tbl_nm,
   tbl.n_live_tup record_count
FROM
     pg_stat_user_tables tbl
WHERE 1=1
 --   AND tbl.schemaname = 'public'
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

