
-- Types
--SEQUENCE
--PACKAGE
--SYNONYM
--FUNCTION
--TABLE
--VIEW
--TYPE


SELECT 
   dpd.*
FROM
   all_dependencies dpd
WHERE 1=1
   AND dpd.owner = 'DBOFAP'
;

SELECT 
   *
FROM
   all_dependencies dpd
WHERE 1=1
   AND dpd.owner = 'DBOFAP'
;

-- All objects referencing X
SELECT 
   dpd.type,
   dpd.name
FROM
   all_dependencies dpd
WHERE 1=1
   AND dpd.owner           = 'DBOFAP'
   AND dpd.referenced_owner <> 'SYS'
   AND dpd.referenced_type = 'TABLE'
   AND dpd.referenced_name = 'FILIERE'
;

-- All objects referenced by X
SELECT 
   dpd.*,
   dpd.referenced_type,
   dpd.referenced_name
FROM
   all_dependencies dpd
WHERE 1=1
   AND dpd.owner           = 'DBOFAP'
   AND dpd.referenced_owner <> 'SYS'
   AND dpd.type            = 'PACKAGE'
   AND dpd.name            = 'PKG_GEN_FILIERE'

;