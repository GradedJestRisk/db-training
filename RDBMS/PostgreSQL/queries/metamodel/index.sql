-- Indexes
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
SELECT COUNT(1) FROM pg_indexes ndx WHERE ndx.indexname = 'users_createdAt_idx';


-- Indexes
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
