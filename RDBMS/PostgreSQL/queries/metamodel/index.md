# Index


## Indexes

### Given schema

Count
```postgresql
SELECT
    --ndx.indexname
    COUNT(1)
FROM pg_indexes ndx
WHERE 1=1
    AND ndx.schemaname = 'public'
;
```

Indexes
```postgresql
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
    AND ndx.indexname NOT ILIKE '%_pkey'
    AND ndx.indexname NOT ILIKE 'fk_%'
;
```

### Given table name

```postgresql
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
--    AND ndx.indexname = 'knowledge_elements_assessmentid_foreign'
    AND ndx.tablename = 'knowledge-elements'
--    AND ndx.tablename LIKE 'account%'
;
```





SELECT
   a.attname,
   am.amname index_type
FROM pg_index idx
    INNER JOIN pg_class cls ON cls.oid=idx.indexrelid
    INNER JOIN pg_class tab ON tab.oid=idx.indrelid
    INNER JOIN pg_am am     ON am.oid=cls.relam
    INNER JOIN pg_attribute a ON a.attrelid = cls.oid
WHERE 1=1
--     AND tab.relname = 'answers_bigint'
    AND tab.relname = 'knowledge-elements_bigint'
ORDER BY a.attname
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




-- Invalid indexes
-- Given table name
SELECT
    'index=>',
    cls.relname       index_name,
    cls.*,
    ndx.indisvalid    is_valid,
    ndx.indisunique   is_unique,
     ndx.indisprimary is_primary,
    'pg_index=>',
    ndx.*
FROM pg_index ndx
      INNER JOIN pg_class cls ON ndx.indexrelid = cls.oid
WHERE 1=1
--    AND ndx.indisvalid IS FALSE
--    AND ndx.indisprimary IS TRUE
    AND cls.relname  = 'idx_uniq_bigintId'
;

-- Monitor index creation
-- Phases in https://www.postgresql.org/docs/13/progress-reporting.html
-- initializing
-- waiting for writers before build
-- building index
-- waiting for writers before validation
-- index validation: scanning index
-- index validation: sorting tuples
-- index validation: scanning table
-- waiting for old snapshots
-- waiting for readers before marking dead
-- waiting for readers before dropping


SELECT
  p.phase,
  p.blocks_total,
  p.blocks_done,
  p.tuples_total,
  p.tuples_done
FROM pg_stat_progress_create_index p;

SELECT
  p.phase,
  p.blocks_done,
  p.blocks_total,
  CASE WHEN blocks_total = 0 THEN 'N/A' ELSE TRUNC((p.blocks_done :: decimal / p.blocks_total ::decimal ) * 100) || '%' END progress_blocks,
  p.tuples_total,
  p.tuples_done,
  CASE WHEN tuples_total = 0 THEN 'N/A' ELSE TRUNC((p.tuples_done :: decimal / p.tuples_total ::decimal ) * 100) || '%' END progress_tuples
FROM pg_stat_progress_create_index p
;


SELECT
  now()::TIME(0),
  a.query,
  p.phase,
  p.blocks_total,
  p.blocks_done,
  p.tuples_total,
  p.tuples_done
FROM pg_stat_progress_create_index p
JOIN pg_stat_activity a ON p.pid = a.pid;
-- now	query	phase	blocks_total	blocks_done	progress	tuples_total	tuples_done
-- 18:19:16	CREATE UNIQUE INDEX ndx_pk_foo ON foo(id)	building index: scanning table	3097346	567725	18%	0	0


