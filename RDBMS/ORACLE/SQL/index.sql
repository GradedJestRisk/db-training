--------------------------------------------------------------------------
--------------     Index                    -------------
---------------------------------------------------------------------------

-- Column-based
CREATE INDEX cfgfil_fk ON filiere (fil_id_filprd);

-- Fucntion-based
CREATE INDEX ndx_trace_trunc_dt ON trace (TRUNC(dt));


-- Indexes:
-- - can be disabled
-- - structure can't be modified, you had to drop/create
-- - others attributes can be changed (name, storage)


SELECT 
   ndx.table_name, 
   ndx.index_name,
   'DROP INDEX ' || owner || '.' || index_name || ';'
FROM all_indexes  ndx
WHERE 1=1
 AND ndx.TABLE_name LIKE 'FILIERE_%'
;



-- Index
-- Pour propri�taire
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
   ,ndx.monitoring_usage
   ,ndx.*   
FROM all_indexes ndx
WHERE 1=1
   AND ndx.owner   =  'DBOFAP'
;


-- Index
-- Pour nom d'index
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
FROM 
   all_indexes ndx
WHERE 1=1
   AND ndx.owner        =  'DBOFAP'
   AND ndx.index_name   =  'LK_TQ_IFU_FK'
;


-- Index
-- Pour propri�taire et une table
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
FROM 
   all_indexes ndx
WHERE 1=1
   AND ndx.owner        =  'DBOFAP'
   AND ndx.table_name   =  'TRONCON'
;



-- Index 
-- Profondeur décroissante
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
--   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
--   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
   ,ndx.blevel             ndx_prf
  -- ,ndx.*   
FROM 
   all_indexes       ndx 
WHERE 1=1
   AND   ndx.owner             =   'DBOFAP'
   AND   ndx.blevel            IS NOT NULL
   AND   ndx.table_name        =   'FILIERE'
ORDER BY 
   ndx.blevel DESC
;

ANALYZE INDEX 
   dbofap.idx_dat_fin_fap 
VALIDATE STRUCTURE
;

SELECT 
   ndx_stt.height               ndx_prf
   ,ndx_stt.lf_blks             rows_in_table
   ,ndx_stt.lf_rows             total_rows_in_index
   ,ndx_stt.del_lf_rows         deleted_rows_in_index
   ,(del_lf_rows / lf_rows * 100) del_rows_ratio      
FROM 
   index_stats ndx_stt
;


SELECT 
   n(clustering_factor)
FROM 
   all_indexes 
WHERE 1=1
--TABLE_NAME='AGG_CLAIM_HP'
   AND index_name = 'IDX_DATEXPPE'
;

SELECT 
   n(num_rows) row_count,
   n(blocks)   block_count
FROM 
   all_tables 
WHERE 
   table_name = 'TRONCON'
;

/*

TRONCON
ROW_COUNT	BLOCK_COUNT
464 345 822	  7 664 428

IDX_DATEXPPE
15 894 042

-- clustering 

/*
https://gerardnico.com/db/oracle/clustering_factor

If the value is near the number of blocks, then the table is very well ordered. 
In this case, the index entries in a single leaf block tend to point to rows in the same data blocks.

If the value is near the number of rows, then the table is very randomly ordered. 
In this case, it is unlikely that index entries in the same leaf block point to rows in the same data blocks.
*/


SELECT 
   ndx.index_name,
   n(tbl.blocks) block_count,
   n(ndx.clustering_factor) clust_factor,
   n(tbl.num_rows) row_count  
FROM 
   all_indexes ndx
      INNER JOIN all_tables tbl ON tbl.table_name = ndx.table_name
WHERE 1=1
   AND ndx.table_name   =   'TRONCON'
--   AND ndx.index_name   =   'IDX_DATEXPPE'
ORDER BY
   ndx.clustering_factor
;



--------------------------------------------------------------------------
--------------     Colonne                    -------------
---------------------------------------------------------------------------


SELECT 
   'Index col'             rqt_cnt
   ,ndx_clm.index_owner    ndx_prp
   ,ndx_clm.index_name     ndx_nm
   ,ndx_clm.column_name    clm_nm
   ,ndx_clm.*   
FROM 
   all_ind_columns   ndx_clm
WHERE 1=1
   AND   ndx_clm.index_owner   =   'DBOFAP'
   AND   ndx_clm.index_name    =   'TRCSIT_FK'
;

SELECT 
   ndx_clm.table_name,
   ndx_clm.index_name,
   LISTAGG(ndx_clm.column_name, ',') WITHIN GROUP (ORDER BY ndx_clm.column_name)
FROM 
   all_ind_columns   ndx_clm
WHERE 1=1
   AND   ndx_clm.index_owner   =   'DBOFAP'
   AND   ndx_clm.index_name    =   'IDX_RIN_FCO'
GROUP BY 
   ndx_clm.table_name,
   ndx_clm.index_name
;


--------------------------------------------------------------------------
--------------     Index  + colonne                  -------------
---------------------------------------------------------------------------


-- Index + colonnes
-- Pour index / nom
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
   ,ndx_clm.column_name    clm_nm
  -- ,ndx.*   
FROM 
   all_indexes       ndx,
   all_ind_columns   ndx_clm
WHERE 1=1
--   AND   ndx.owner             =   'DBOFAP'
   AND   ndx.index_name        =   UPPER('idx_evt_fap_detail_id_filprd')
   AND   ndx_clm.index_owner   =    ndx.owner
   AND   ndx_clm.index_name    =    ndx.index_name 
;



-- Index + colonnes
-- Pour table / nom
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
   ,ndx_clm.column_name    clm_nm
  -- ,ndx.*   
FROM 
   all_indexes       ndx,
   all_ind_columns   ndx_clm
WHERE 1=1
   AND   ndx.owner             =   'DBOFAP'
   AND   ndx.table_name        =   'LUU_ULO'
   AND   ndx_clm.index_owner   =    ndx.owner
   AND   ndx_clm.index_name    =    ndx.index_name 
;

-- Index + colonnes
-- Pour table / nom + colonne / nom
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
   ,ndx_clm.column_name    clm_nm
  -- ,ndx.*   
FROM 
   all_indexes       ndx 
      INNER JOIN  all_ind_columns   ndx_clm ON ( ndx_clm.index_owner   =    ndx.owner AND ndx_clm.index_name    =    ndx.index_name )
WHERE 1=1
   --AND   ndx.owner             =   'DBOFAP'
   AND   ndx.table_name        =   'TRONCON'
   AND   ndx_clm.column_name   =   'ID_NAT_CTX'
;


-- Index + colonnes
-- Pour table / nom + colonne / nom
SELECT 
   'Index'             rqt_cnt
   ,ndx.owner          ndx_prp
   ,ndx.index_name     ndx_nm
   ,ndx.index_type     ndx_typ
   ,ndx.table_name     tbl_nm
   ,ndx.partitioned    ndx_prt
   ,ndx.uniqueness     ndx_nqn
   ,ndx.blevel             ndx_prf
   ,ndx_clm.column_name    clm_nm
  -- ,ndx.*   
FROM 
   all_indexes       ndx 
      INNER JOIN  all_ind_columns   ndx_clm ON ( ndx_clm.index_owner   =    ndx.owner AND ndx_clm.index_name    =    ndx.index_name )
WHERE 1=1
   --AND   ndx.owner             =   'DBOFAP'
   AND   ndx.table_name        =   'FILIERE'
   AND   ndx_clm.column_name   =   'ID_NAT_CTX'
;


SELECT 
   index_name,
   blevel,
   leaf_blocks
FROM 
   dba_indexes
WHERE 1=1
--   AND   owner      =   user
   AND   index_name = 'TRCNCT_FK'
;

---------------------------------------------------------------------------
--------------     Function source                   -------------
---------------------------------------------------------------------------


SELECT 
   src.index_name, 
   src.column_expression
FROM
   dba_ind_expressions src
WHERE index_name IN (
   'IDX_DBA_FIL_1',
   'IDX_ECM_DAT_EXP',
   'IDX_FILIERE_DAT_FIN_FAP_F',
   'TRC_IS_NULL_EXP_PE'
)
;


---------------------------------------------------------------------------
--------------      Selectivity                    -------------
---------------------------------------------------------------------------


/*   
The ratio of the number of distinct values in the indexed column / columns to the number of records in the table represents the selectivity of an index.
The ideal selectivity is 1. Such a selectivity can be reached only by unique indexes on NOT NULL columns.
*/

-- Index selectivity
-- Given table name
SELECT 
   'Selectivity=>'                  rpr_cnt
  ,ndx.index_name
  ,ndx.distinct_keys                  distinct_values
  ,'Raw data =>'
  ,tbl.num_rows                     tbl_row_count
  ,ndx.distinct_keys                ndx_distinct_values
--  ,n(ndx.avg_leaf_blocks_per_key)      ndx_leaf_per_key
  ,'Ratios =>' x
  ,ROUND(( ndx.distinct_keys  / tbl.num_rows  ) * 100, 7) || '%'  selectivity
  ,'Row count for =>' x
  ,TRUNC(( tbl.num_rows  / ndx.distinct_keys ))                   a_notnull_value  
FROM 
   all_tables     tbl
      INNER JOIN all_indexes ndx ON ndx.table_name = tbl.table_name
WHERE 1=1
   AND tbl.table_name       =   'TRONCON'
   AND ndx.distinct_keys   <>   0
   --   AND ndx.index_name =   'TRCNAT_FK'
ORDER BY
   (ndx.distinct_keys  / tbl.num_rows ) DESC   
;


-- Index selectivity
-- Given index name
SELECT 
   'Selectivity=>'                  rpr_cnt
  ,ndx.index_name
  ,ndx.distinct_keys                  distinct_values
  ,'Raw data =>'
  ,tbl.num_rows                     tbl_row_count
  ,ndx.distinct_keys                ndx_distinct_values
--  ,n(ndx.avg_leaf_blocks_per_key)      ndx_leaf_per_key
  ,'Ratios =>' x
  ,ROUND(( ndx.distinct_keys  / tbl.num_rows  ) * 100, 7) || '%'  selectivity
  ,'Row count for =>' x
  ,TRUNC(( tbl.num_rows  / ndx.distinct_keys ))                   a_notnull_value  
FROM 
   all_tables     tbl
      INNER JOIN all_indexes ndx ON ndx.table_name = tbl.table_name
WHERE 1=1
   AND tbl.table_name = 'TRONCON'
   AND ndx.index_name IN (
      'TRCNAT_FK',
      'TRCNCT_FK',
      'TRCPRI_FK',
      'TRCTDF_FK')
;

-- Manual

SELECT 
   COUNT (DISTINCT id_filprd) distinct_values
FROM evt_fap_detail
WHERE id_filprd IS NOT NULL
;
-- 132 782


SELECT 
   COUNT(1) tbl_row_count
FROM evt_fap_detail
;
-- 574 915

SELECT 
   COUNT(1) tbl_row_count
FROM evt_fap_detail
WHERE id_filprd IS NOT NULL
;

-- 194 268

SELECT 
   ROUND(
      (SELECT 
         COUNT (DISTINCT id_filprd) distinct_values
      FROM evt_fap_detail) / 
      
      (SELECT 
         COUNT(1) tbl_row_count
      FROM evt_fap_detail
      WHERE id_filprd IS NOT NULL)
      
      * 100, 2) || '%' SELECTIVITY
FROM dual
;
-- 68% => bad..