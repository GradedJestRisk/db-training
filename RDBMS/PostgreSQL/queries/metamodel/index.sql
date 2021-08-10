
-- Invalid indexes
SELECT
    'index=>',
    cls.relname       table_name,
    ndx.indisvalid    is_valid,
    ndx.indisunique   is_unique,
     ndx.indisprimary is_primary,
    'pg_index=>',
    ndx.*
FROM pg_index ndx
      INNER JOIN pg_class cls ON ndx.indexrelid = cls.oid
WHERE 1=1
    AND ndx.indisvalid IS FALSE
--    AND ndx.indisprimary IS TRUE
;


-- Indexes
-- Given name
SELECT
       'Indexes=>' qry
       ,ndx.indexname ndxl_nm
       ,ndx.tablename tbl_nm
       ,ndx.indexdef  dfn
       ,'pg_indexes=>' qry
       ,ndx.*
FROM pg_indexes ndx
WHERE 1=1
    AND ndx.schemaname <> 'pg_catalog'
    AND ndx.indexname = 'users_createdAt_idx'
;


-- Indexes
-- Given table name
SELECT
       'Indexes=>' qry
       ,ndx.indexname ndxl_nm
       ,ndx.tablename tbl_nm
       ,ndx.indexdef  dfn
       ,'pg_indexes=>' qry
       ,ndx.*
FROM pg_indexes ndx
WHERE 1=1
    --AND ndx.schemaname <> 'pg_catalog'
    AND ndx.tablename = 'account-recovery-demands'
    AND ndx.tablename LIKE 'account%'
;

-- Indexes
-- Given schema name
SELECT
       'Indexes=>' qry
       ,ndx.indexname ndxl_nm
       ,ndx.tablename tbl_nm
       ,ndx.indexdef  dfn
       ,'pg_indexes=>' qry
       ,ndx.*
FROM pg_indexes ndx
WHERE 1=1
    AND ndx.schemaname = 'public'
    --AND ndx.indexname = 'users_createdAt_idx'
;



-- Indexes on tables < 10^5 records (useless)
-- Given schema name
SELECT
       'Table=>' qry
       ,ndx.tablename tbl_nm
       ,tbl.n_live_tup record_count
       ,'Indexes=>' qry
       ,ndx.indexname ndxl_nm
 --      ,ndx.indexdef  dfn
--        ,'pg_indexes=>' qry
--        ,ndx.*
FROM pg_indexes ndx
    INNER JOIN  pg_stat_user_tables tbl ON tbl.relname = ndx.tablename
WHERE 1=1
    AND ndx.schemaname = 'public'
    --AND ndx.indexname = 'users_createdAt_idx'
    AND tbl.n_live_tup <= 100000 --LOG(10, 5)
ORDER BY tbl.n_live_tup, ndx.tablename ASC
;
