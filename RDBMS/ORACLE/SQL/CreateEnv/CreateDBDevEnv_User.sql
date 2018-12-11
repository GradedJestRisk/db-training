-- Make sure role exists
-- Should return 1 row
SELECT * 
FROM 
   dba_roles rl
WHERE 1=1
   AND rl.role        = UPPER('role_dev')
;


-- Make sure user hasn't been yet granted role
-- Should return no rows
SELECT * 
FROM 
   dba_role_privs rl_tls
WHERE 1=1
   AND rl_tls.grantee      = UPPER('user_dev')
   AND rl_tls.granted_role = UPPER('role_dev')
;

--------------     CONNECT AS SYSTEM                   -------------


---------------------------------------------------------------------------
--------------    Test data                 -------------
---------------------------------------------------------------------------

CREATE TABLE dbofap.test(
  id NUMBER(10) NOT NULL
);

---------------------------------------------------------------------------
--------------    Create user                    -------------
---------------------------------------------------------------------------
CREATE USER 
   user_dev 
IDENTIFIED BY 
   user_dev
; 

---------------------------------------------------------------
--------------    Assign user to role            -------------
---------------------------------------------------------------
GRANT 
   role_dev 
TO 
   user_dev;

---------------------------------------------------------------------------
--------------    Create synonyms for user                   -------------
---------------------------------------------------------------------------


--Test table
CREATE OR REPLACE SYNONYM 
   user_dev.test 
FOR 
   dbofap.test
; 
 
-- Real tables
SELECT 
   'CREATE OR REPLACE SYNONYM ' || param.tls_cbl_nm || '.' || param.syn_nm || ' FOR ' || param.tls_src_nm || '.' || param.tbl_nm || ';'    cmd_crt_syn
FROM
   (SELECT 
      'dbofap'        tls_src_nm
      ,tbl.table_name tbl_nm
      ,tbl.table_name syn_nm
      ,'user_dev'     tls_cbl_nm
   FROM 
      all_tables tbl
   WHERE 1=1
      AND tbl.owner =   UPPER('dbofap')
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

SELECT * FROM all_synonyms syn
WHERE 1=1
   AND syn.owner        = UPPER('user_dev') 
   AND syn.synonym_name = UPPER('filiere')
;



--------------     CONNECT AS USER_DEV                   -------------



---------------------------------------------------------------
--------------    Tests                     -------------
---------------------------------------------------------------

-- Data insert

INSERT INTO 
   test (id)
VALUES (2);

COMMIT;

--
SELECT * 
FROM 
   test
;


-- Real tables
SELECT * 
FROM 
   filiere
;

-- Create and exec procedure within package

