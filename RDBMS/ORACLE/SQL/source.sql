
-------------------- Code source --------------------------

/*
object_type

FUNCTION
PACKAGE
PACKAGE BODY
PROCEDURE

*/


-- Code source 
-- par package - body
SELECT 
   src.name,
   --src.*
   src.line,
   src.text
FROM 
   all_source src
WHERE 1=1
   AND src.owner = 'DBOFAP'
--   AND src.object_type = '
--   AND src.name = 'PCK_GEN_FLUX_FAX'  
--   AND src.type = 'PACKAGE BODY'
   AND lower(src.text) LIKE '%autonomous%'
ORDER BY 
   src.name, 
   src.line ASC
;




-- Code source 
-- par nom d'objet
SELECT 
   --src.name,
   --src.*
   src.line,
   src.text
FROM user_source src
WHERE 1=1
--   AND src.object_type = '
   AND src.name = 'PCK_GEN_FLUX_FAX'  
   AND src.type = 'PACKAGE BODY'
ORDER BY src.name, src.line ASC
;




-- Code source 
-- par package - body
SELECT 
   --src.name,
   --src.*
   src.line,
   src.text
FROM user_source src
WHERE 1=1
--   AND src.object_type = '
   AND src.name = 'PCK_GEN_FLUX_FAX'  
   AND src.type = 'PACKAGE BODY'
ORDER BY src.name, src.line ASC
;


-- Code source 
-- Nombre lignes
SELECT COUNT(1)
FROM user_source src
;


-- Code source 
-- par package - body + contenu
SELECT 
   --src.name,
   --src.*
   src.line,
   src.text
FROM user_source src
WHERE 1=1
--   AND src.object_type = '
   AND src.name = 'PCK_GEN_FLUX_FAX'  
   AND src.type = 'PACKAGE BODY'
 --  AND src.text LIKE '%FUNCTION fct_maj_statut_fax_pegase%'
ORDER BY src.name, src.line ASC
;

SELECT 
*
--SUBSTR(src.text, 11, 30)
      FROM user_source src
      WHERE 1=1
         AND src.name = 'PCK_GEN_FLUX_FAX'  
         AND src.type = 'PACKAGE BODY'
         AND src.text LIKE '%- IN      :%'
         AND src.line BETWEEN 60 AND 78
;



