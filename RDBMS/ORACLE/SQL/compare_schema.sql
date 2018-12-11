-- Présent dans premiére table et absent dans deuxiéme
SELECT 
   atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner = 'DBOFAP'
   AND atc.table_name = 'DB_DBOFAP'
MINUS
SELECT 
   atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner = 'DBOFAP'
   AND atc.table_name = 'DB_DBOFAP'

UNION ALL

-- Présent dans premiére table et absent dans deuxiéme
SELECT 
   atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner = 'PEGASE'
   AND atc.table_name = 'DB_TRAITEMENT_ALERTE'
MINUS
SELECT 
   atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner = 'PEGASE'
   AND atc.table_name = 'TQ_LISTE_ALERTE'
;

----------------------- Comparaison actuelle - distante  via DBLINK --------------------------

SELECT  * 
FROM 
   all_db_links
WHERE 1=1
   AND db_link LIKE upper('dblk') || '%'
;

DROP DATABASE LINK 
   dblk
;

CREATE DATABASE LINK dblk
CONNECT TO fap IDENTIFIED BY FAP
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=lnxfrh099700850.enterprise.horsprod.lan)(PORT=1521)) (CONNECT_DATA=(SID=FAP)(SERVER=DEDICATED)))'
;


SELECT 
   *
FROM 
   p


SELECT 'local: ' || instance_name || '@' ||host_name FROM v$instance
UNION
SELECT 'remote: ' || instance_name || '@' ||host_name FROM v$instance@dblk
;

-- TEST
SELECT * from all_tables@dblk
;


select * from all_tables@DBLK where table_name='PEG_DB_PRODUIT'
;

select * from all_tab_columns@DBLK atc  where table_name='PEG_DB_PRODUIT'
;

---------------------------------------------------------------------------
--------------      Table                    -------------
---------------------------------------------------------------------------


-- Résumé
SELECT 
   'Actuelle' sch, COUNT(1) AS tbl_nbr
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'
UNION
SELECT 
   'Distante' sch, COUNT(1) AS tbl_nbr
FROM all_tables@DBLK tbl
WHERE 1=1
   AND tbl.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'
;

-- Présent sur instance actuelle mais pas sur distante
SELECT 
   tbl.owner, tbl.table_name
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'
MINUS
SELECT 
   tbl.owner, tbl.table_name
FROM all_tables@DBLK tbl
WHERE 1=1
   AND tbl.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'

UNION ALL

-- Présent sur distante mais pas sur instance actuelle 
SELECT 
   tbl.owner, tbl.table_name
FROM all_tables@DBLK tbl
WHERE 1=1
   AND tbl.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'
MINUS
SELECT 
   tbl.owner, tbl.table_name
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'
;


---------------------------------------------------------------------------
--------------      Colonnes                    -------------
---------------------------------------------------------------------------


-- Présent sur instance actuelle mais pas sur distante
SELECT 
   atc.table_name, atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'
MINUS
SELECT 
   atc.table_name, atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM all_tab_columns@DBLK atc
WHERE 1=1
   AND atc.owner = 'DBOFAP'
   --AND atc.table_name = 'DB_DBOFAP'

UNION ALL

-- Présent sur distante mais pas sur instance actuelle 
SELECT 
   atc.table_name, atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM 
   all_tables@DBLK      atb,
   all_tab_columns@DBLK atc
WHERE 1=1
   AND atb.owner = 'DBOFAP'
   AND atc.owner = atb.owner
   AND atc.table_name = atb.table_name
   --AND atc.table_name = 'DB_TRAITEMENT_ALERTE'
MINUS
SELECT 
   atc.table_name, atc.column_name,atc.data_type, atc.data_length, atc.data_precision, atc.data_scale, atc.nullable
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner = 'DBOFAP'
  --AND atc.table_name = 'TQ_LISTE_ALERTE'
;


---------------------------------------------------------------------------
--------------      Indexs                    -------------
---------------------------------------------------------------------------

-- Présent sur instance actuelle mais pas sur distante
SELECT 
   ndx.table_name,
   ndx.index_name
FROM all_indexes ndx
WHERE 1=1
   AND ndx.owner = 'DBOFAP'
MINUS
SELECT 
   ndx.table_name,
   ndx.index_name
FROM all_indexes@dblk ndx
WHERE 1=1
   AND ndx.owner = 'DBOFAP'
;

UNION ALL

-- Présent sur distante mais pas sur instance actuelle 
SELECT 
   ndx.table_name,
   ndx.index_name
FROM all_indexes@dblk ndx
WHERE 1=1
   AND ndx.owner = 'DBOFAP'
MINUS
SELECT 
   ndx.table_name,
   ndx.index_name
FROM all_indexes ndx
WHERE 1=1
   AND ndx.owner = 'DBOFAP'
;

SELECT
   ndx_clm.table_name,
   ndx_clm.index_name,
   LISTAGG(ndx_clm.column_name, ',') WITHIN GROUP (ORDER BY ndx_clm.column_name) AS columns
FROM 
   all_ind_columns   ndx_clm
WHERE 1=1
   AND   ndx_clm.index_owner   =   'DBOFAP'
   AND   ndx_clm.index_name    IN (
            'CFGFCO_FK',
            'CFGHIE_FK',
            'CFGNCL_FK',
            'CFGTRA_FK',
            'CFGTUL_FK',
            'FILETA_FK',
            'FILPRI_FK',
            'MFIFLX_FK',
            'MFINCT_FK',
            'MFINDF_FK',
            'MFISIT_FK',
            'PK_CONFIG',
            'RESCFG_FK',
            'SYS_C005285',
            'SYS_C006005',
            'SYS_C006002',
            'IDX_DAT_FIN_FAP',
            'IDX_FILIERE_DAT_FIN_FAP_F',
            'IDX_FOR_MERGE_GEN_FAP_TRC',
            'IDX_RIN_FCO',
            'TRACE_IDX',
            'IDX_DATEXPPE',
            'SYS_C006001',
            'WRK_TRC_NDX'  
   )
GROUP BY    
   ndx_clm.table_name,
   ndx_clm.index_name
ORDER BY
   ndx_clm.table_name
;


