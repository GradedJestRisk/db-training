------------------ Table  ---------------------------

-- DROP TABLE
SELECT 
   tbl.table_name, 
   'DROP TABLE ' || owner || '.' ||  table_name || ';'
FROM 
   all_tables tbl
WHERE 1=1
 AND tbl.TABLE_name LIKE 'FILIERE_%'
;


-- Table 
-- Row movement enabled
SELECT 
   'Table'         rqt_cnt 
   ,tbl.owner      tbl_prp
   ,tbl.table_name tbl_nm
   ,tbl.num_rows   tbl_nrg_nmb
   ,tbl.last_analyzed
   ,tbl.row_movement
FROM 
   all_tables tbl
WHERE 1=1
   AND tbl.owner        = 'DBOFAP'
   AND tbl.row_movement = 'ENABLED'
ORDER bY
   tbl.num_rows DESC
;


For name
```oracle
SELECT 
   'Table'         rqt_cnt 
   ,tbl.owner      tbl_prp
   ,tbl.table_name tbl_nm
   ,tbl.num_rows   tbl_nrg_nmb
   ,tbl.last_analyzed
--    ,'all_t&ables=>'
   ,tbl.*
FROM 
   all_tables tbl
WHERE 1=1
   AND UPPER(tbl.table_name)   =   UPPER('simple_table')
ORDER bY
   tbl.num_rows DESC
;
```

```oracle
select owner from all_tables where 
--                                  owner = 'public'
                                  owner = 'username'
   --table_name = 'simple_table';
```

For owner
```oracle
SELECT 
   'Table'         rqt_cnt 
   ,tbl.owner      tbl_prp
   ,tbl.table_name tbl_nm
   ,tbl.num_rows   tbl_nrg_nmb
   ,tbl.last_analyzed
   ,tbl.*
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner               =   'USERNAME'
--    AND UPPER(tbl.table_name)   =   UPPER('TRONCON')
ORDER bY
   tbl.num_rows DESC
;
```


-- Nb enreg table 
-- Pour propri�taire + nom 
SELECT 
   tbl.num_rows   tbl_nrg_nmb
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner               =   'DBOFAP'
   AND UPPER(tbl.table_name)   =   UPPER('EXT_CUGS_EXPORT')
;

-- Table 
-- Pour propri�taire   nom 
SELECT 
   'Table'         rqt_cnt 
   ,tbl.owner      tbl_prp
   ,tbl.table_name tbl_nm
   ,tbl.num_rows   tbl_nrg_nmb
   ,tbl.last_analyzed
   ,tbl.*
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner               =   'DBOFAP'
   AND UPPER(tbl.table_name)   LIKE    UPPER('%pu%')
;



-- Table 
-- Pour nom approx
SELECT 
   'Table'         rqt_cnt 
   ,tbl.owner      tbl_prp
   ,tbl.table_name tbl_nm
   ,tbl.num_rows   tbl_nrg_nmb
   ,tbl.last_analyzed
   ,tbl.*
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner               =   'DBOFAP'
   AND UPPER(tbl.table_name)   LIKE    UPPER('%pu%')
;

DB_COMMENT_DOSSIER
-- ENREG
-- DB_DOSSIER 65 M




-- Tables temporaires syst�me
-- Pour propri�taire
SELECT 
    'GTT'            rqt_cnt
   ,tbl.owner        tbl_prp
   ,tbl.table_name   tbl_nm
   ,tbl.duration     vld
   ,tbl.*
FROM all_tables tbl
WHERE 1=1
   AND tbl.owner       =   'SGR'
   AND tbl.temporary   =   'Y'
;
-- 25 en tout


----------------  Utilisation table par package ----------------------------


SELECT 
   dpn.name
FROM 
   all_dependencies  dpn
WHERE 1=1
   AND dpn.type            = 'PACKAGE' 
   AND dpn.referenced_type = 'TABLE' 
   AND dpn.referenced_name = 'DB_CHANGE'
;


-- Table / Creation date
SELECT 
   obj.object_name   tbl_nm,
   obj.created       ctr_dt   
FROM
   dba_objects obj
WHERE 1=1
   AND obj.owner       = 'DBOFAP'
   AND obj.object_name = 'TRONCON_GARDE'
;

-- Table created after
-- Given a creation date
SELECT 
   obj.object_name   tbl_nm,
   obj.created       ctr_dt   
FROM
   dba_objects obj
WHERE 1=1
   AND obj.owner       =   'DBOFAP'
   AND obj.created     >    TO_DATE('20181122-11:00','YYYYMMDD-HH24:MI')
   AND obj.object_type NOT IN ('PACKAGE','PACKAGE BODY')
ORDER BY
   obj.created DESC   
;




---------------------------------------------------------------------------
--------------     CREATE TABLE                    -------------
---------------------------------------------------------------------------

DROP TABLE  tbl_test;

-- Syntax 1: from scratch
CREATE TABLE tbl_test (
   id INTEGER NOT NULL,
   CONSTRAINT cnt_uniq  UNIQUE(id),
   CONSTRAINT cnt_range CHECK (id BETWEEN 0 AND 10000),
   CONSTRAINT cnt_notnull CHECK (id IS NOT NULL)
);

INSERT INTO tbl_test (id) VALUES (1) ;
COMMIT;

-- Syntax 2: from existing table
DROP TABLE tbl_test_empty;
CREATE TABLE tbl_test_empty AS SELECT * FROM tbl_test WHERE 1=0;

SELECT * FROM tbl_test_empty
;

-- NO specified (check, unique) contraints           are copied 
-- ALL inline column definition constraints (SYC_C%) are copied
SELECT 
    cnt.constraint_type 
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
   ,cnt.search_condition
--   ,cnt.*
FROM 
   all_constraints cnt
WHERE 1=1
   AND   LOWER(cnt.table_name)   IN ( 'tbl_test', 'tbl_test_empty')
--ORDER BY
 --  cnt.search_condition
;

SELECT 
    table_name
   ,atc.nullable
FROM all_tab_columns atc
WHERE 1=1
   AND LOWER(atc.table_name)   IN ( 'tbl_test','tbl_test_empty')
   AND LOWER(atc.column_name)   =  'id'
;



