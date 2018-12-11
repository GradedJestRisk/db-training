-----------------------------------------------------------------------
--------------      Tablespace   management               -------------
---------------------------------------------------------------------------


/*
tablespace management:

- local:
   - extent management
      - automatic
      - manual

- dictionary
*/


-- Tablespace management : LOCAL
SELECT 
    tablespace_name
   ,extent_management 
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.extent_management   =  'LOCAL'
;

-- Tablespace
SELECT 
   tbls.tablespace_name,
   tbls.contents,
   tbls.logging,
   tbls.extent_management,
   tbls.segment_space_management
--   ,'TABLESPACE => '
--   ,tbls.*
FROM
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.tablespace_name = 'FAP_DATA'
;


-- Tablespace management : Dictionnary
SELECT 
    tablespace_name
   ,extent_management 
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.extent_management   =  'DICTIONARY'
;


-- Tablespace management 
-- Given tablespace / name
SELECT 
    tablespace_name
   ,extent_management 
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.tablespace_name     =   'FAP_DATA'
;






-----------------------------------------------------------------------
--------------      Tablespace                  -------------
---------------------------------------------------------------------------

-- Tablespace 
-- All
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*
FROM 
   dba_tablespaces tbls
WHERE 1=1
--   AND tbls.tablespace_name     =   'FAP_DATA'
;



-- Tablespace 
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.tablespace_name     =   'FAP_DATA'
;


-----------------------------------------------------------------------
--------------      DATA Tablespace                  -------------
---------------------------------------------------------------------------




-- Tablespace 
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.contents     =   'PERMANENT'
;


-- Tablespace 
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.contents            =   'PERMANENT'
   AND tbls.tablespace_name     =   'FAP_DATA'
;


-----------------------------------------------------------------------
--------------      UNDO Tablespace                  -------------
---------------------------------------------------------------------------


SHOW PARAMETER undo

/*
NAME            TYPE    VALUE  
--------------- ------- ------ 
undo_management string  AUTO   
undo_retention  integer 900    ( 900 s = 15 min)
undo_tablespace string  UNDO02 
*/




-- Tablespace 
-- All
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.contents     =   'UNDO'
;

-- Tablespace 
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.contents            =   'UNDO'
   AND tbls.tablespace_name     =   'UNDO02'
;


-----------------------------------------------------------------------
--------------      TEMP Tablespace                  -------------
---------------------------------------------------------------------------

-- Tablespace 
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.contents     =   'TEMPORARY'
;


-- Tablespace 
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
  , 'DBA_TABLESPACE=>'    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
WHERE 1=1
   AND tbls.contents            =   'TEMPORARY'
   AND tbls.tablespace_name     =   'TEMP'
;



---------------------------------------------------------------------------
--------------      Tablespace monitoring           -------------
---------------------------------------------------------------------------

SELECT 
   m.tablespace_name
   ,ROUND((m.tablespace_size - m.used_space) * 8192 / 1024 / 1024 /1024, 1 ) free_gb
   ,ROUND(m.used_percent, 2)                                                 free_cpt
FROM 
   dba_tablespace_usage_metrics m
;
