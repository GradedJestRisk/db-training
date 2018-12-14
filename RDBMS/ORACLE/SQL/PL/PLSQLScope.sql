SELECT 
   *
FROM 
   all_errors err
WHERE 1=1
   AND err.owner       =   'DBOFAP'
   AND err.attribute   =   'ERROR'
   AND err.type       IN   ('PACKAGE','PACKAGE BODY')
ORDER BY    
   err.name
;


SELECT * FROM 
   user_errors
;

ALTER SESSION SET PLSCOPE_SETTINGS='IDENTIFIERS:ALL';
ALTER PACKAGE pkg_gen_filiere COMPILE;


ALTER PROCEDURE prc_plsqlscope_nousage COMPILE; 

SELECT 
   bjc_set.name,
   bjc_set.plsql_optimize_level,
   bjc_set.plscope_settings
--   *--plscope_settings
FROM 
   user_plsql_object_settings bjc_set
WHERE 1=1
   AND type =  'PROCEDURE'
   AND name =  UPPER('prc_plsqlscope_nousage')
;



SELECT 
    dnt.object_type
   ,dnt.object_name   
   ,' - '
   ,dnt.type
   ,dnt.name
   ,dnt.usage
   ,dnt.line
--   ,' - '
--   ,dnt.*
FROM 
   user_identifiers dnt
WHERE 1=1
   AND dnt.object_name   =   UPPER('prc_plsqlscope_nousage')
  -- AND dnt.name          =   UPPER('l_object_name')
 --  AND dnt.name          LIKE   'L%'
ORDER BY
   dnt.name ASC
   ,dnt.line ASC
;


select * from all_identifiers
;


SELECT 
    dnt.name
   ,dnt.type
   ,dnt.usage
   ,dnt.line
   ,' - '
   ,dnt.*
FROM 
   all_identifiers dnt
WHERE 1=1
   and dnt.owner = 'DBOFAP'
   AND dnt.object_name   =   UPPER('pkg_gen_filiere')
--   AND dnt.name          =   UPPER('l_indice')
   AND dnt.name          LIKE   'L%'
ORDER BY
   dnt.name ASC
   ,dnt.line ASC
;

ALTER SESSION SET PLSCOPE_SETTINGS='IDENTIFIERS:NONE';

-- Space used by PL/SQL scope 
-- SYSTEM
SELECT 
   space_usage_kbytes,
   TRUNC(space_usage_kbytes  / 1000)  AS usage_mo
FROM   v$sysaux_occupants
WHERE  occupant_name = 'PL/SCOPE';

