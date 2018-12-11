-- Locking session
select 
   x.sid,
   x.status
from 
   v$session x, v$sqltext y
where 
   x.sql_address = y.address
and 
   y.sql_text like '%PKG_PURGE_FIL_INACT%';


SELECT 
   s.sid,
   l.lock_type,
   l.mode_held,
   l.mode_requested,
   l.lock_id1
FROM   
   dba_lock_internal l,
   v$session s
WHERE 1=1
   AND s.sid = l.session_id
   AND UPPER(l.lock_id1) LIKE '%PKG%'
   AND l.lock_type = 'Body Definition Lock'
;



SELECT
   object_name,
   procedure_name,
   authid
FROM  
   dba_procedures
WHERE 1=1
   AND object_name = 'PKG_PURGE_FAP'
   AND procedure_name IS NULL
--   AND authid <> 'DEFINER'
--   AND object_name LIKE 'PKG%'
; 

-- All ﻿CURRENT_USER
SELECT
   object_name,
   procedure_name,
   authid
FROM  
   dba_procedures
WHERE 1=1
   AND object_name LIKE 'PKG%'
   AND procedure_name IS NULL
   AND authid         = '﻿CURRENT_USER'
; 


------------------------------------------------------------------------
----------------------------- Compilation ----------------------------------
------------------------------------------------------------------------

-- plsql_optimize_level
-- 1 = Debug
-- 2 = Normal (with optimization)

SELECT 
   *
FROM 
   all_plsql_object_settings p
WHERE 1=1
   AND p.owner                =   'DBOFAP'
   AND p.type                IN   ('PACKAGE','PACKAGE BODY')
   AND p.plsql_optimize_level <   2
;

-- Compile all packages with level1 in level2
SELECT DISTINCT
   'ALTER PACKAGE ' ||p.name ||' COMPILE;'
FROM 
   all_plsql_object_settings p
WHERE 1=1
   AND p.owner                =   'DBOFAP'
   AND p.type                IN   ('PACKAGE','PACKAGE BODY')
   AND p.plsql_optimize_level <   2
;

SELECT *
  FROM ALL_PLSQL_OBJECT_SETTINGS 
;

SELECT * FROM 
   v$parameter
WHERE 1=1
   AND name = 'plsql_optimize_level'
--   AND lower(name) LIKE '%optim%'
;


------------------------------------------------------------------------
----------------------------- Package ----------------------------------
------------------------------------------------------------------------

/*
ALL_OBJECTS.OBJECT_TYPE

FUNCTION
PACKAGE
PACKAGE BODY
SYNONYM
TABLE
*/

-- Package: Etat + Date dernière compilation
-- Par nom 
SELECT 
   'Package: '
   ,pck.object_name 
   ,pck.owner       
   ,pck.status       pck_tt
   ,PCK.LAST_DDL_TIME
FROM 
   all_objects pck
WHERE 1=1
   AND pck.object_type = 'PACKAGE'
   AND pck.owner = 'DBOFAP'
   AND upper(pck.object_name) = upper('PKG_GEN_FILIERE')
;

-- Package invalides
-- Pour utilisateur
SELECT distinct 
   'ALTER PACKAGE ' || pck.owner || '.' || pck.object_name || ' COMPILE;'
   ,pck.object_name  pck_nm
   ,pck.owner        pck_prp
   ,pck.status       pck_tt
   ,pck.*
FROM 
   all_objects pck
WHERE 1=1
   AND pck.object_type   IN   ('PACKAGE','PACKAGE BODY')
   AND pck.owner         =   'DBOFAP'
   AND pck.status        =   'INVALID'
 --  AND pck.object_name   =   'PKG_GEN_FILIERE'
;


-- Package
-- Par propri�taire
SELECT 
   'Package: '
   ,pck.object_name  pck_nm
   ,pck.owner        pck_prp
   ,pck.status       pck_tt
   ,pck.*
FROM 
   all_objects pck
WHERE 1=1
   AND pck.owner       = 'FAX' 
   AND pck.object_type = 'PACKAGE'
;


-- Package
-- Par nom et par propri�taire
SELECT 
   'Package: '
   ,pck.object_name  pck_nm
   ,pck.owner        pck_prp
   ,pck.status       pck_tt
   ,pck.*
FROM 
   all_objects pck
WHERE 1=1
   AND pck.owner         =   'PEGASE' 
   AND pck.object_type   =   'PACKAGE'
  -- AND pck.object_name   =   'PCK_ACTIF_PASSIF'
;


-- Package
-- Pour propri�taire et nom approximatif
SELECT 
   'Package: '
   ,pck.object_name  pck_nm
   ,pck.owner        pck_prp
   ,pck.status       pck_tt
   ,pck.*
FROM 
   all_objects pck
WHERE 1=1
   AND pck.owner         =   'PTOP' 
   AND pck.object_type   =   'PACKAGE'
   AND pck.object_name   LIKE   '%TOOL%'
;

------------------------------------------------------------------------
----------------------------- Contenu du package ---------------------
------------------------------------------------------------------------

-- Contenu du package
-- sans owner
SELECT 
   prc.object_name,
   prc.procedure_name,
prc.*
FROM 
   user_procedures prc
WHERE 1=1
   AND prc.object_type = 'PACKAGE'
   --AND prc.object_name = 'PCK_OST_ATTRIBUTION'
   AND prc.procedure_name IS NOT NULL
ORDER BY prc.object_name, prc.procedure_name ASC
;

-- Contenu du package
-- avec owner
SELECT 
   pck_cnt.object_name,  pck_cnt.procedure_name      
FROM 
   all_procedures   pck_cnt
WHERE 1=1
   AND   pck_cnt.owner             =   'PEGASE' 
   AND   pck_cnt.object_type       =   'PACKAGE' -- ('PROCEDURE','FUNCTION')
   --AND   procedure_name   IS   NOT NULL
;

-- Contenu du package
-- par nom d'objet (prc/fct)
SELECT 
   prc.object_name,
   prc.procedure_name,
   prc.*
FROM  
   user_procedures prc
WHERE 1=1
   AND prc.object_type = 'PACKAGE'
--   AND prc.object_name = 'PCK_SGR_REMISE_FAX'
--      AND lower(prc.procedure_name) LIKE ('fct_generate_%');
   AND lower(prc.procedure_name) LIKE '%between%'
ORDER BY prc.object_name, prc.procedure_name ASC
;


-- Contenu du package
-- par nom d'objet (prc/fct) - liste
SELECT 
   prc.object_name,
   prc.procedure_name,
   prc.*
FROM  
   user_procedures prc
WHERE 1=1
   AND prc.object_type = 'PACKAGE'
--   AND prc.object_name = 'PCK_SGR_REMISE_FAX'
--      AND lower(prc.procedure_name) LIKE ('fct_generate_%');
   AND lower(prc.procedure_name) IN (
         'fct_generate_fax_tffds',
         'fct_generate_fax_emitf',
         'fct_generate_fax_ac_sgr',
         'fct_generate_fax_conf_emitf',
         'fct_generate_fax_conf_emifrais')
ORDER BY prc.object_name, prc.procedure_name ASC
;


-- Package contenant une fonction
-- par nom de fonction

SELECT 
   prc.object_name,
   prc.procedure_name,
   prc.*
FROM user_procedures prc
WHERE 1=1--
   AND prc.object_type = 'PACKAGE'
   AND LOWER(prc.procedure_name) = 'fct_ctrl_entrant_arbitot'
ORDER BY prc.object_name, prc.procedure_name ASC
;

-- Package contenant une fonction
-- par nom de fonction approximatif
SELECT 
   prc.object_name,
   prc.procedure_name,
   prc.*
FROM user_procedures prc
WHERE 1=1--
   AND prc.object_type = 'PACKAGE'
   AND LOWER(prc.procedure_name) LIKE '%capi%'
ORDER BY prc.object_name, prc.procedure_name ASC
;

------------------------------------------------------------------------
----------------------------- Param�tre ----------------------------------
------------------------------------------------------------------------


-- Param�tre d'une fonction
-- Pour fonction / nom
SELECT 
   'Param�tre=>'        rqt_cnt
   ,prm.owner           pck_prp
   ,prm.package_name    pck_nm
   ,prm.object_name     bjt_nm
   ,lower(prm.argument_name)   prm_nm
   ,prm.in_out          prm_sns
   ,prm.data_type       prm_typ 
   ,prm.data_length     prm_typ_spc
   ,'-'
   --,prm.*
FROM 
   all_arguments prm
WHERE 1=1
   AND prm.owner          =   'DBOFAP'
   --AND prm.package_name   =   'PKG_GEN_FILIERE'
  -- AND prm.object_name    =   UPPER('p_ctl_active_filiere')
   AND prm.argument_name IS NOT NULL
--   AND   prm.argument_name LIKE %attendu%
ORDER BY 
    prm.package_name   ASC 
   ,prm.object_name    ASC
   ,prm.in_out         ASC
   ,prm.sequence       ASC
;


-- Param�tre d'une fonction
-- Pour param�tre / nom (approximatif)
SELECT 
   'Param�tre=>'        rqt_cnt
   ,prm.owner           pck_prp
   ,prm.package_name    pck_nm
   ,prm.object_name     bjt_nm
   ,lower(prm.argument_name)   prm_nm
   ,prm.in_out          prm_sns
   ,prm.data_type       prm_typ 
   ,prm.data_length     prm_typ_spc
   ,'-'
   ,prm.*
FROM 
   all_arguments prm
WHERE 1=1
   AND prm.owner          =   'PEGASE'
 --  AND prm.package_name   =   'PCK_DOC'
   AND prm.argument_name    LIKE   UPPER('%erreur%')
--   AND prc.procedure_name IS NOT NULL
ORDER BY 
    prm.package_name   ASC 
   ,prm.object_name    ASC
   ,prm.in_out         ASC
   ,prm.sequence       ASC
;




SELECT 
   prc.object_name,
   prc.procedure_name,
prc.*
FROM user_procedures prc
WHERE 1=1
   AND prc.object_type = 'PACKAGE'
   AND prc.object_name = 'PCK_GEN_FLUX_FAX'
   AND prc.procedure_name IS NOT NULL
ORDER BY prc.object_name, prc.procedure_name ASC
;


select t.status  from all_objects t;

-- Invalides
SELECT 
   pck.owner,
   pck.object_type,
   pck.object_name,
   pck.status
FROM
   all_objects pck
WHERE  1=1
   AND   pck.owner         =   'PTOP'
   AND   pck.object_type   =   'PACKAGE'
   AND   pck.status        =   'INVALID'
ORDER BY 
   pck.owner, 
   pck.object_type, 
   pck.object_name;
    

-- Valides
SELECT 
   pck.owner,
       object_type,
       object_name,
       status
FROM   dba_objects pck
WHERE  1=1
   AND   pck.owner         =   'PTOP'
   AND   pck.object_type   =   'PACKAGE'
   AND   pck.status        =   'VALID'
ORDER BY owner, object_type, object_name;



-- DEBUG 
SELECT 
   bjt.object_type,
   bjt.owner,
   bjt.object_name,
   bjt.debuginfo
   -- 'ALTER ' || object_type || ' ' || owner || '.' || object_name || '     compile;'
FROM   
   sys.all_probe_objects bjt
WHERE 1=1
   AND bjt.owner         =   'FAP'
   AND bjt.object_type   =   'PROCEDURE'
   AND bjt.object_name   =   'PRC_TST'
ORDER BY owner, object_type, object_name
;

-- DEBUG = N
SELECT 
   bjt.object_type,
   bjt.owner,
   bjt.object_name,
   bjt.debuginfo,
   'ALTER ' || object_type || ' ' || owner || '.' || object_name || ' COMPILE;',
   'ALTER ' || object_type || ' ' || owner || '.' || object_name || ' COMPILE DEBUG;'

FROM   
   sys.all_probe_objects bjt
WHERE 1=1
   AND bjt.owner         =   'IFU'
   AND bjt.object_type   =   'PACKAGE'
   --AND bjt.debuginfo     =   'T'
ORDER BY owner, object_type, object_name
;


-- DEBUG = Y
SELECT 
   bjt.object_type,
   bjt.owner,
   bjt.object_name,
   bjt.debuginfo,
   'ALTER ' || object_type || ' ' || owner || '.' || object_name || ' COMPILE;',
   'ALTER ' || object_type || ' ' || owner || '.' || object_name || ' COMPILE DEBUG ;'

FROM   
   sys.all_probe_objects bjt
WHERE 1=1
   AND bjt.owner         =   'PTOP'
   AND bjt.object_type   =   'PACKAGE'
   AND bjt.debuginfo     =   'T'
ORDER BY owner, object_type, object_name
;
