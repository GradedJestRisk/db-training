-- Index statistics
SELECT
    ndx_stt.relname      tbl_nm,
    ndx_stt.indexrelname ndx_nm,
    'statistics=>',
    ndx_stt.idx_scan     usage_count, -- Number of index scans initiated on this index
    ndx_stt.idx_tup_read,             -- Number of index entries returned by scans on this index
    ndx_stt.idx_tup_fetch             -- Number of live table rows fetched by simple index scans using this index
FROM pg_stat_all_indexes ndx_stt
WHERE 1 = 1
  AND ndx_stt.schemaname = 'public'
--   AND indexrelname NOT LIKE '%pkey%'
--   AND indexrelname NOT LIKE '%unique%'
ORDER BY
   idx_tup_fetch DESC,
   idx_tup_read DESC
;


-- Index usage + definition
SELECT
    relname      tbl_nm,
    indexrelname ndx_nm,
    ndx.indexdef,
    idx_scan     usage_count
FROM pg_stat_all_indexes ndx_sg
         INNER JOIN pg_indexes ndx ON ndx.indexname = ndx_sg.indexrelname
WHERE 1 = 1
  AND ndx_sg.idx_scan <= 10
  AND ndx_sg.schemaname = 'public'
--   AND indexrelname NOT LIKE '%pkey%'
--   AND indexrelname NOT LIKE '%unique%'
ORDER BY idx_scan ASC
;

-- Index usage + definition
SELECT
    relname                                                tbl_nm,
    (select
         (array_to_string(array_agg(a.attname), ', ') :: text) as column_names
     from pg_index ix
              inner join pg_class t on t.oid = ix.indrelid
              inner join pg_attribute a on a.attrelid = t.oid AND a.attnum = ANY (ix.indkey)
     where ix.indexrelid = pg_stat_all_indexes.indexrelid) ndx_clm,
    indexrelname                                           ndx_nm,
    idx_scan                                               usage_count
FROM pg_stat_all_indexes
WHERE 1 = 1
  AND idx_scan <= 10
  AND schemaname = 'public'
--   AND indexrelname NOT LIKE '%pkey%'
--   AND indexrelname NOT LIKE '%unique%'
ORDER BY idx_scan ASC;



-- Indexes usage + Table cardinality
-- Given schema name
SELECT
    'Table=>'       qry
  , ndx.tablename   tbl_nm
  , tbl.n_live_tup  record_count
  , 'Indexes=>'     qry
  , ndx.indexname   ndxl_nm
  , 'usage=>'       qry
  , ndx_sg.idx_scan sg_cnt
    --      ,ndx.indexdef  dfn
--        ,'pg_indexes=>' qry
--        ,ndx.*
FROM pg_indexes ndx
         INNER JOIN pg_stat_user_tables tbl ON tbl.relname = ndx.tablename
         INNER JOIN pg_stat_all_indexes ndx_sg ON ndx_sg.indexrelname = ndx.indexname
WHERE 1 = 1
  --AND ndx_sg.idx_scan < 100
  AND ndx_sg.idx_scan > 100
--     AND tbl.n_live_tup <= 100000 --LOG(10, 5)
ORDER BY tbl.n_live_tup,
         ndx.tablename ASC
;


-- Indexes on tables < 10^5 records (useless)
-- Given schema name
SELECT
    'Table=>'      qry
  , ndx.tablename  tbl_nm
  , tbl.n_live_tup record_count
  , 'Indexes=>'    qry
  , ndx.indexname  ndxl_nm
    --      ,ndx.indexdef  dfn
--        ,'pg_indexes=>' qry
--        ,ndx.*
FROM pg_indexes ndx
         INNER JOIN pg_stat_user_tables tbl ON tbl.relname = ndx.tablename
WHERE 1 = 1
  AND ndx.schemaname = 'public'
  --AND ndx.indexname = 'users_createdAt_idx'
  AND tbl.n_live_tup <= 100000 --LOG(10, 5)
ORDER BY tbl.n_live_tup, ndx.tablename ASC
;


-- Duplicated indexes
SELECT
    array_agg(indexname)             AS indexes,
    replace(indexdef, indexname, '') AS defn
FROM pg_indexes
GROUP BY defn
HAVING count(*) > 1;

