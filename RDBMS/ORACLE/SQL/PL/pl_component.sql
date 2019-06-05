-- Contains:
-- - standalone functions/procedures
-- - packaged functions/procedures
-- - packages


-- Object type
SELECT 
   DISTINCT object_type 
FROM 
   all_procedures prc
;   
-- OBJECT_TYPE
-- PROCEDURE
-- FUNCTION
-- TYPE
-- TRIGGER
-- PACKAGE



-- All
-- Given a name (package & procedure)
SELECT 
   DECODE( prc.object_type,
    'PACKAGE', prc.object_name || '.' || prc.procedure_name ,
    prc.object_name --'',        ''     
    ) bjt,
    prc.*
FROM 
   all_procedures prc
WHERE 1=1
   AND prc.owner         =   'RDOP'
  -- AND prc.object_type   =   'PROCEDURE'
  AND (    REGEXP_LIKE(prc.object_name,     'p_pfl_demande', 'i') 
        OR REGEXP_LIKE(prc.procedure_name,  'p_pfl_demande', 'i') )
ORDER BY
    prc.object_name     ASC
;


--
SELECT 
   'Procedures=>'
   ,prc.procedure_name
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
   AND prc.owner         =   'DBOFAP'
--   AND prc.object_type   IN   ('PACKAGE', 'FUNCTION', 'PROCEDURE')
--   AND prc.authid        IN   ('DEFINER', 'CURRENT_USER')
   AND prc.pipelined       IN   ('YES','NO')
   AND prc.parallel        IN   ('YES','NO')
   AND prc.deterministic   IN   ('YES','NO')
;

-- Package 
SELECT 
   'Procedures=>'
   ,prc.object_name     pkg_nm
   ,prc.procedure_name  prc_nm
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
  --AND prc.owner         =   'DBOFAP'
   AND prc.object_type   =   'PACKAGE'
   AND prc.procedure_name  IS NULL
ORDER BY
    prc.object_name     ASC
;


-- Package 
SELECT 
   'Procedures=>'
   ,prc.object_name     pkg_nm
   ,prc.procedure_name  prc_nm
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
  AND prc.owner         =   'RDOP'
   AND prc.object_type   =   'PACKAGE'
   AND prc.procedure_name  IS NULL
ORDER BY
    prc.object_name     ASC
;


-- Package-contained function and procedures
SELECT 
   'Procedures=>'
   ,prc.object_name     pkg_nm
   ,prc.procedure_name  prc_nm
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
   AND prc.owner         =   'DBOFAP'
   AND prc.object_type   =   'PACKAGE'
ORDER BY
    prc.object_name     ASC
   ,prc.procedure_name  ASC
;


-- Standalone function
SELECT 
   'Procedures=>'
   ,prc.object_name     fct_nm
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
   AND prc.owner         =   'DBOFAP'
   AND prc.object_type   =   'FUNCTION'
ORDER BY
    prc.object_name     ASC
;


-- Standalone procedure
SELECT 
   'Procedures=>'
   ,prc.object_name     fct_nm
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
   AND prc.owner         =   'DBOFAP'
   AND prc.object_type   =   'PROCEDURE'
ORDER BY
    prc.object_name     ASC
;


-- All
-- Given a name
SELECT 
   'Procedures=>'
   ,prc.object_name     fct_nm
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
   AND prc.owner         =   'RDOP'
  -- AND prc.object_type   =   'PROCEDURE'
  AND prc.object_name LIKE '%GEN%O%'
ORDER BY
    prc.object_name     ASC
;


-- All
-- Given a name (package & procedure)
SELECT 
   'Procedures=>'
   ,prc.object_name     fct_nm
   ,'ALL_PROCEDURES=>'
   ,prc.*
FROM 
   all_procedures prc
WHERE 1=1
   AND prc.owner         =   'RDOP'
  -- AND prc.object_type   =   'PROCEDURE'
  AND (    REGEXP_LIKE(prc.object_name,     'f_Ctl_CPDest', 'i') 
        OR REGEXP_LIKE(prc.procedure_name,  'f_Ctl_CPDest', 'i') )
ORDER BY
    prc.object_name     ASC
;

------------------------------------------------------------------------
----------------------------- Compilation (level) ----------------------------------
------------------------------------------------------------------------

-- plsql_optimize_level
-- 1 = Debug
-- 2 = Normal (with optimization)

SELECT 
   *
FROM 
   all_plsql_object_settings p
WHERE 1=1
   AND p.owner                =   'RDOP'
   AND p.type                IN   ('PACKAGE','PACKAGE BODY')
   --AND p.plsql_optimize_level <   2
   AND p.name                 =   'PFL_K_QRCODE'
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


SELECT * FROM 
   v$parameter
WHERE 1=1
   AND name = 'plsql_optimize_level'
--   AND lower(name) LIKE '%optim%'
;


SELECT 'ALTER ' || object_type || ' ' || owner || '.' || object_name || '     compile;'
FROM   SYS.ALL_PROBE_OBJECTS
WHERE DEBUGINFO = 'T'
ORDER BY owner, object_type, object_name;