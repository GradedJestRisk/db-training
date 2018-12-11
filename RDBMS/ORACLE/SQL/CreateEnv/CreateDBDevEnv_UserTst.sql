
--------------     CONNECT AS SYSTEM                   -------------


-- Make sure role does not exists
-- Should return no rows
SELECT * 
FROM 
   dba_roles rl
WHERE 1=1
   AND rl.role        = UPPER('role_dev')
;



---------------------------------------------------------------------------
--------------    Test data                 -------------
---------------------------------------------------------------------------

CREATE TABLE dbofap.test(
  id NUMBER(10) NOT NULL
);


---------------------------------------------------------------
--------------    Create role                     -------------
---------------------------------------------------------------

DROP ROLE 
   role_dev;

CREATE ROLE 
   role_dev;


-- Connexion privileges   
GRANT 
   CREATE SESSION 
TO 
   role_dev;
   
GRANT 
   DEBUG CONNECT SESSION 
TO 
   role_dev;
   
GRANT 
   DEBUG ANY PROCEDURE 
TO 
   role_dev;

-- DML privileges     
GRANT 
   CREATE ANY PROCEDURE 
TO 
   role_dev;
   
GRANT 
   ALTER ANY PROCEDURE 
TO 
   role_dev;
   
GRANT 
   DROP ANY PROCEDURE 
TO 
   role_dev;
   
GRANT 
   EXECUTE ANY PROCEDURE 
TO 
   role_dev;

-- DDL privileges on test table
GRANT 
   SELECT, 
   INSERT, 
   UPDATE, 
   DELETE 
ON 
   dbofap.test
TO 
   role_dev;


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


-- A généraliser !!

SELECT * FROM all_sequences seq
WHERE seq.sequence_owner = 'DBOFAP'
;

GRANT SELECT ON dbofap.SEQ_ID_EVT_DET TO user_dev
;

CREATE SYNONYM user_dev.SEQ_ID_EVT_DET FOR dbofap.SEQ_ID_EVT_DET
;
SELECT  SEQ_ID_EVT_DET.NEXTVAL FROM dual
;