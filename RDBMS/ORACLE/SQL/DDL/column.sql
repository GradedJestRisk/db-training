
------------------ Column  ---------------------------


-- Column 
-- Given name
SELECT 
   atc.owner,
   atc.table_name,
   atc.column_name,
   atc.*
FROM 
   all_tab_columns atc
WHERE 1=1
   --AND atc.owner         =   'PEGASE'
   AND UPPER(atc.column_name)   =   UPPER('cd_ass')
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;



-- Column 
-- Par Propri�taire + nom
SELECT 
   atc.owner,
   atc.table_name,
   atc.column_name,
   atc.*
FROM 
   all_tab_columns atc
WHERE 1=1
  -- AND atc.owner         =   'OCAPI'
   AND UPPER(atc.column_name)   LIKE '%NAI%'
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;
   
-- Pour excel 
-- Column 
-- Par table / nom
SELECT 
   'Colonnes => ' rqt_cnt  
--   'pss_flx.' || LOWER(atc.column_name) || ' ' || LOWER(atc.column_name) || ',',
   ,lower(atc.column_name)
   ,atc.data_type || '(' || atc.data_length || ')'
   ,atc.data_length
--   atc.*
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner        =   'PTOP'
   AND atc.table_name   =   UPPER('db_job')
ORDER BY 
--   atc.column_name ASC
   atc.column_id ASC
;

-- Column 
-- Par table / Nom + Colonne / Nom 
SELECT 
    'Colonne'        rqt_cnt
   ,atc.owner        tbl_prp
   ,atc.table_name   tbl_nm
   ,atc.column_name  cln_nm
   ,atc.*
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner        =   'DBOFAP'
   AND atc.table_name   =   'TRONCON'
   AND atc.column_name  =   'ID_FILPRD' -- IN ('','')
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;





-- Column 
-- Par table / Nom + Colonne / Nom (approximatif )
SELECT 
    'Colonne'        rqt_cnt
   ,atc.owner        tbl_prp
   ,atc.table_name   tbl_nm
   ,atc.column_name  cln_nm
   ,atc.*
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner        =   'PEGASE'
   AND atc.table_name   =   'DB_DOSSIER'
   AND atc.column_name  LIKE   'IS_%'
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;


-- Column
-- Dans un ensemble de tables (recherche)

SELECT 
   atc.owner,
   atc.table_name,
   atc.column_name,
   atc.*
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner = 'PEGASE'
   AND atc.table_name IN (
      'DB_PERSONNE',
      'DB_CONTRAT',
      'DB_TIERS',
      'DB_CONTRACTANT',
      'DP_DOC_TRAIT_AUTORISE',
      'DB_PRODUIT',
      'DB_DOSSIER',
      'PEG_DB_DER',
      'DB_EVENEMENT',
      'DP_LIBELLES',
      'DB_RACHAT')
   AND atc.COLUMN_NAME = 'B_NON_IFU'
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;




-- Column
-- NULL
SELECT 
   atc.owner,
   atc.table_name,
   atc.column_name,
   atc.nullable,
   atc.*
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner      =   'DBOFAP'
   AND atc.nullable   =   'Y'
   AND atc.table_name =   'RFR_PRODUIT_RF'
   AND atc.column_name =  'DAT_DSP_RFR'
ORDER BY 
   atc.table_name  ASC,
   atc.column_name ASC
;


-- Column
-- NOT NULL
SELECT 
   atc.owner,
   atc.table_name,
   atc.column_name,
   atc.nullable,
   atc.*
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner      =   'DBOFAP'
   AND atc.nullable   =   'Y'
   AND ATc.table_name =   'RFR_PRODUIT_RF'
ORDER BY 
   atc.table_name  ASC,
   atc.column_name ASC
;




-- Column / Comment
-- Par table / nom
SELECT 
    'Colonne'        rqt_cnt
   ,cln_cmm.owner        tbl_prp
   ,cln_cmm.table_name   tbl_nm
   ,cln_cmm.column_name  cln_nm
   ,cln_cmm.*
FROM
   all_col_comments cln_cmm
WHERE 1=1
   AND cln_cmm.owner = 'PTOP'
   AND cln_cmm.table_name = 'DB_MT_KP'
--   AND cln_cmm.column_name LIKE '%SITE%'
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;



-- Column / Comment
-- Par table / nom
SELECT 
    'Colonne'        rqt_cnt
   ,cln_cmm.owner        tbl_prp
   ,cln_cmm.table_name   tbl_nm
   ,cln_cmm.column_name  cln_nm
   ,cln_cmm.*
FROM
   all_col_comments cln_cmm
WHERE 1=1
   AND cln_cmm.owner      = 'DBOFAP'
--   AND cln_cmm.table_name = 'DB_MT_KP'
--   AND cln_cmm.column_name LIKE '%SITE%'
   AND 
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;



---------------------------------------------------------------------------
--------------      Selectivity                    -------------
---------------------------------------------------------------------------

/*

Density = 1 / Number of distinct NON null values

Values close to 1 indicate that this column is unselective
Values close to 0 indicate that this column is highly selective

The more selective a column, the less rows are likely to be returned by a 
query referencing this column in its predicate list. 


*/

-- Column density
-- Par table / Nom + Colonne / Nom 
SELECT 
    'Colonne'        rqt_cnt
   ,atc.owner        tbl_prp
   ,atc.table_name   tbl_nm
   ,atc.column_name  cln_nm
   ,atc.density      density  
FROM all_tab_columns atc
WHERE 1=1
   AND atc.owner        =   'DBOFAP'
   AND atc.table_name   =   'TRONCON'
--   AND atc.column_name  =   'ID_FILPRD' -- IN ('','')
ORDER BY 
   atc.density ASC
;


/*
Selectivity = distinct values / line count
Eg: 1, 1, 2, 2, 2, 3  =>  3 / 6 = 0.5                   

Inverse = 6/3 = 2 = number rows selected for a value (average)

The ideal selectivity is 1. 
Such a selectivity can be reached only by UNIQUE NOT NULL
*/


-- Column selectivity
-- For table / name 
SELECT 
   'Selectivity=>'                  rpr_cnt
  ,clm.column_name 
  ,'Raw data =>'
  ,clm.num_distinct                distinct_values
  ,tbl.num_rows                    row_count
  ,clm.num_nulls
  ,'Ratios =>'
  ,ROUND(( clm.num_nulls / tbl.num_rows  ) * 100, 0) || '%'      null_ratio_pct
  ,ROUND(( clm.num_distinct / tbl.num_rows  ) * 100, 2)  || '%'  selectivity_ratio_pct
  ,'Row count for =>'
  ,TRUNC(( tbl.num_rows  / clm.num_distinct ))                   a_notnull_value
FROM 
   all_tables     tbl
      INNER JOIN all_tab_columns clm ON clm.table_name = tbl.table_name
WHERE 1=1
   AND tbl.table_name = 'TRONCON'
 --  AND clm.column_name IN ('COD_NATTRC', 'ID_NAT_CTX', 'ID_PRI', 'ID_FLUX')
   AND num_distinct IS NOT NULL AND num_distinct <> 0
ORDER BY
    (clm.num_distinct / tbl.num_rows) DESC
;


-- Column selectivity
-- For table / name + column / name
SELECT 
   'Selectivity=>'                  rpr_cnt
  ,clm.column_name 
  ,clm.num_distinct                distinct_values
  ,tbl.num_rows                     row_count
  ,( clm.num_distinct / tbl.num_rows  )   selectivity_ratio
  ,TRUNC(( tbl.num_rows  / clm.num_distinct ))   selectivity_inv_ratio
FROM 
   all_tables     tbl
      INNER JOIN all_tab_columns clm ON clm.table_name = tbl.table_name
WHERE 1=1
   AND tbl.table_name = 'TRONCON'
   AND clm.column_name IN ('COD_NATTRC', 'ID_NAT_CTX', 'ID_PRI', 'ID_FLUX')
;

