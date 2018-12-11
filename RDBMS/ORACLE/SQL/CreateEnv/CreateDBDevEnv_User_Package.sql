
--------------     CONNECT AS SYSTEM                   -------------

---------------------------------------------------------------
--------------    GRANT to tables                    ----------
---------------------------------------------------------------



-- DDL privileges  on real tables
SELECT 
   'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || param.tls_src_nm || '.' || param.syn_nm || ' TO ' || param.rl_cbl_nm || ';'    cmd_crt_syn
FROM
   (SELECT 
      'dbofap'        tls_src_nm
      ,tbl.table_name tbl_nm
      ,tbl.table_name syn_nm
      ,'user_dev'     rl_cbl_nm
   FROM 
      all_tables tbl
   WHERE 1=1
      AND tbl.owner  =   UPPER('dbofap')
      AND NOT EXISTS (
         SELECT 1
         FROM all_external_tables tbl_xtr
         WHERE 1=1
            AND tbl_xtr.owner = tbl.owner 
            AND tbl_xtr.table_name = tbl.table_name 
      )
   ) param
;
--282 rows




---------------------------------------------------------------
--------------    CREATE SYNONYM to tables                    ----------
---------------------------------------------------------------



-- CREATE SYNONYM user_dev.REC_FAP_CCO FOR dbofap.REC_FAP_CCO
SELECT 
   'CREATE OR REPLACE SYNONYM ' || param.rl_cbl_nm || '.' || param.syn_nm || ' FOR ' || param.tls_src_nm || '.' || param.syn_nm  || ';'    cmd_crt_syn
FROM
   (SELECT 
      'dbofap'        tls_src_nm
      ,tbl.table_name tbl_nm
      ,tbl.table_name syn_nm
      ,'user_dev'     rl_cbl_nm
   FROM 
      all_tables tbl
   WHERE 1=1
      AND tbl.owner  =   UPPER('dbofap')
      AND NOT EXISTS (
         SELECT 1
         FROM all_external_tables tbl_xtr
         WHERE 1=1
            AND tbl_xtr.owner = tbl.owner 
            AND tbl_xtr.table_name = tbl.table_name 
      )
   ) param
;
-- 43 rows



---------------------------------------------------------------
--------------    GRANT to sequences                    ----------
---------------------------------------------------------------


-- DDL privileges  on real tables
SELECT 
   'GRANT SELECT ON ' || param.tls_src_nm || '.' || param.syn_nm || ' TO ' || param.rl_cbl_nm || ';'    cmd_crt_syn
FROM
   (SELECT 
      'dbofap'        tls_src_nm
      ,seq.sequence_name tbl_nm
      ,seq.sequence_name syn_nm
      ,'user_dev'     rl_cbl_nm
   FROM 
     all_sequences seq
   WHERE 1=1
      AND seq.sequence_owner  =   UPPER('dbofap')     
   ) param
;
--282 rows


---------------------------------------------------------------
--------------    GRANT to sequences                    ----------
---------------------------------------------------------------

-- GRANT SELECT ON dbofap.SEQ_ID_EVT_DET TO user_dev

SELECT 
   'GRANT SELECT ON ' || param.tls_src_nm || '.' || param.syn_nm || ' TO ' || param.rl_cbl_nm || ';'    cmd_crt_syn
FROM
   (SELECT 
      'dbofap'        tls_src_nm
      ,seq.sequence_name tbl_nm
      ,seq.sequence_name syn_nm
      ,'user_dev'     rl_cbl_nm
   FROM 
     all_sequences seq
   WHERE 1=1
      AND seq.sequence_owner  =   UPPER('dbofap')     
   ) param
;
-- 78 rows


---------------------------------------------------------------
--------------    CREATE SYNONYM to sequences                    ----------
---------------------------------------------------------------


SELECT * FROM all_sequences seq
WHERE seq.sequence_owner = 'DBOFAP'
;


-- CREATE SYNONYM user_dev.SEQ_ID_EVT_DET FOR dbofap.SEQ_ID_EVT_DET
SELECT 
   'CREATE OR REPLACE SYNONYM ' || param.syn_cbl_nm || '.' || param.sqn_src_nm || ' FOR ' || param.sqn_src_tls || '.' || param.sqn_src_nm  || ';'    cmd_crt_syn
FROM
   (SELECT 
       seq.sequence_name  sqn_src_nm
      ,seq.sequence_owner sqn_src_tls
      ,'user_dev'         syn_cbl_nm
   FROM 
     all_sequences seq
   WHERE 1=1
      AND seq.sequence_owner  =   UPPER('dbofap')     
   ) param
;
-- 78 rows

-- Test
SELECT  
   seq_id_evt_det.NEXTVAL 
FROM 
   dual
;



---------------------------------------------------------------
--------------    Create synonym for types                     -------------
---------------------------------------------------------------

SELECT 
   typ.*
FROM 
   all_types typ
WHERE 1=1
   AND typ.owner = 'DBOFAP'
;
--43 rows

-- CREATE SYNONYM user_dev.REC_FAP_CCO FOR dbofap.REC_FAP_CCO
SELECT 
   'CREATE OR REPLACE SYNONYM ' || param.syn_cbl_nm || '.' || param.typ_src_nm || ' FOR ' || param.typ_src_tls || '.' || param.typ_src_nm  || ';'    cmd_crt_syn
FROM
   (SELECT 
       typ.type_name  typ_src_nm
      ,typ.owner      typ_src_tls
      ,'user_dev'     syn_cbl_nm
   FROM 
      all_types typ
   WHERE 1=1
      AND typ.owner  =   UPPER('dbofap')     
   ) param
;
-- 43 rows


---------------------------------------------------------------
--------------    CREATE SYNONYM to types                    ----------
---------------------------------------------------------------


-- GRANT EXECUTE ON dbofap.REC_FAP_CCO TO user_dev

SELECT 
   'GRANT EXECUTE ON ' || param.typ_src_tls || '.' || param.typ_src_nm || ' TO ' || param.syn_cbl_nm || ';'    cmd_crt_syn
FROM
   (SELECT 
       typ.type_name  typ_src_nm
      ,typ.owner      typ_src_tls
      ,'user_dev'     syn_cbl_nm
   FROM 
      all_types typ
   WHERE 1=1
      AND typ.owner  =   UPPER('dbofap')     
   ) param
;
-- 43 rows
