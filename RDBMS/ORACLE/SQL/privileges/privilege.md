# Privileges

##  System privileges (NOT ON OBJECTS)

System privileges
Granted to X
```oracle
SELECT
  sys_prv.*
FROM
  dba_sys_privs sys_prv
WHERE 1=1
   AND sys_prv.grantee = 'DBOFAP'
;
```

System privileges
Granted to X
```oracle
SELECT
    sys_prv.*
FROM
    dba_sys_privs sys_prv
WHERE 1=1
--   AND sys_prv.grantee = 'DBOFAP'
  AND sys_prv.privilege LIKE '%VIEW%'
;
```


System  privileges
For a specific privilege
```oracle
SELECT
  sys_prv.*
FROM
  dba_sys_privs sys_prv
WHERE 1=1
--   AND sys_prv.grantee = 'DBOFAP'
   AND sys_prv.privilege = 'CREATE TABLE'
ORDER BY 
   sys_prv.grantee
;
```

Current user
```oracle
select * from user_sys_privs
;
```

##  Direct privileges (on objects) 

-- Directly granted privileges
-- Example of SYS to a SYS role

```oracle


SELECT
  prv_drc.grantor,
  prv_drc.privilege,
  prv_drc.table_name,
  prv_drc.grantee
FROM
  dba_tab_privs prv_drc
WHERE 1=1
--   AND prv_drc.grantor    =   'SYS'
--   AND prv_drc.grantee    =   'SELECT_CATALOG_ROLE'
--    AND prv_drc.table_name =   UPPER ('REF_K_BATCHS')   
   AND UPPER(prv_drc.table_name) LIKE 'V_$SESS_TIME_MODEL%'   
;
```

-- Directly granted privileges
-- Example of SYS to a user
SELECT
  prv_drc.grantor,
  prv_drc.privilege,
  prv_drc.table_name,
  prv_drc.grantee
FROM
  dba_tab_privs prv_drc
WHERE 1=1
   AND prv_drc.grantor    =   'SYS'
   AND prv_drc.grantee    =   'DBOFAP'
   --AND prv_drc.table_name = UPPER ('dba_tables')      
;


-- Directly granted privileges
-- Example of a user to another user
SELECT
  prv_drc.grantor,
  prv_drc.privilege,
  prv_drc.table_name,
  prv_drc.grantee
FROM
  dba_tab_privs prv_drc
WHERE 1=1
   AND prv_drc.grantor    =   'DBOFAP'
   AND prv_drc.grantee    =   'FAP'
   AND prv_drc.table_name = UPPER ('filiere')      
;


##  Role granted privileges

-- Indirectly granted privileges (by role)

```oracle
SELECT
  prv_rl.granted_role,
  prv_rl.grantee
FROM
  dba_role_privs prv_rl
WHERE 1=1
--   AND prv_rl.granted_role  =   'DBOFAP'
   AND prv_rl.grantee       =   'USERNAME'
--   AND prv_rl.table_name = UPPER ('filiere')      
;
```


## Privileges
-- Privil�ges syst�mes (CREATE USER, DROP USER,..)
SELECT * FROM 
   user_sys_privs
;

Privil�ges objets tables
Pour utilisateur
```oracle
SELECT 
   prv_tls.grantor,
   prv_tls.grantee,
   prv_tls.table_schema,
   prv_tls.table_name,
   prv_tls.*
FROM all_tab_privs prv_tls
WHERE 1=1
   --AND prv_tls.grantee      =   'SYSTEM'
--    AND prv_tls.table_name   =   'TBL_TEST' --UPPER('wrk_gen_trc_fil')
--   AND prv_tls.table_name LIKE 'V$%'
;

```


-- Privil�ges objets tables
-- Pour table
SELECT 
   prv_tls.grantor,
   prv_tls.grantee,
   prv_tls.table_schema,
   prv_tls.table_name,
   prv_tls.*
FROM all_tab_privs prv_tls
WHERE 1=1
   AND prv_tls.grantee      =   'IFU_LINK'
   AND prv_tls.table_name   =   UPPER('wrk_gen_trc_fil')
--   AND prv_tls.table_name LIKE 'V$%'
;


-- Lien utilisateur-r�le
SELECT * FROM 
-- user_role_privs
   dba_role_privs tls_rl
WHERE 1=1
   AND   tls_rl.grantee   = 'DBOFAP' 
--   AND   tls_rl.grantee   = 'THCC'
;

# Role

SELECT *
FROM 
   role_role_privs rl
WHERE 1=1
--   AND rl.role = 'RU_DEV'
;

SELECT *
FROM 
   role_role_privs rl
WHERE 1=1
   AND rl.role = 'EXP_RDO_ROLE'
;

## Roles + rights

-- R�le: droits sur tables
SELECT * 
FROM 
   role_tab_privs rl_tbl
WHERE 1=1
   AND rl_tbl.owner = 'SYS'
   AND rl_tbl.role  = 'SELECT_CATALOG_ROLE'
   AND rl_tbl.table_name LIKE 'DBA_%'
   AND rl_tbl.table_name LIKE 'DBA_SEGMENTS'
ORDER BY
   rl_tbl.table_name ASC
;


-- R�le: droits sur tables
SELECT * 
FROM 
   role_tab_privs rl_tbl
WHERE 1=1
   --AND rl_tbl.owner = 'TOOLS'
   --AND rl_tbl.role  = 'ROLE_IFU_SQLL'
   AND rl_tbl.table_name =  UPPER('wrk_gen_trc_fil')
;

## Role + user
-- R�le: droits sur tables
SELECT   
    rl_tls.username     rl_tls
   ,rl_tls.granted_role rl_nm
   ,rl_tbl.table_name   tbl_nm
   ,rl_tbl.privilege    tbl_prv
FROM 
    user_role_privs rl_tls
   ,role_tab_privs  rl_tbl
WHERE 1=1
 --  AND rl_tls.username     =   'FAP'
   AND rl_tbl.role         =   rl_tls.granted_role
 --AND rl_tbl.owner        =   'FAP'
   --AND rl_tbl.table_name   =   'DBMS_AQ'
ORDER BY
    rl_tls.username     
   ,rl_tls.granted_role 
   ,rl_tbl.table_name   
   ,rl_tbl.privilege    
;



## Role

-- Priorit�
-- Tous       
SELECT
    rl.*
FROM
   user_roles rl
WHERE 1=1
--   AND evt_typ.cod_typ_evt   =   'GEN_FIL'
;

select *
from all_privileges
;


  select privilege             "Privilege", 
                                      initcap(admin_option) "Admin_Option"
                                 from 1 
                                order by privilege    
                                ;
SELECT *
FROM user_sys_privs prv_sys
WHERE 1=1
   AND prv_sys.privilege IN ('DEBUG CONNECT SESSION', 'DEBUG ANY PROCEDURE')
;

SELECT *
FROM 
   dba_sys_privs prv_sys
WHERE 1=1
   AND prv_sys.privilege LIKE '%DEBUG%'
;




## Add privileges

Table
```oracle
GRANT 
   SELECT, INSERT, UPDATE, DELETE 
ON 
   db_mt_kp
TO 
   ptop
;
```

All system views
```oracle
GRANT select any dictionary TO USERNAME;
GRANT execute ON sys.dbms_session TO USERNAME;
```

System view
```oracle
GRANT SELECT ON V$SESS_TIME_MODEL TO USERNAME;
GRANT SELECT ON sys.v_$sess_time_model TO USERNAME;
```