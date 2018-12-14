-- Contains:
-- - standalone functions/procedures
-- - packaged functions/procedures
-- - packages

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
   AND prc.owner         =   'DBOFAP'
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