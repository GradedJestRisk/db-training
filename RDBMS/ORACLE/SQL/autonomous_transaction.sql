SELECT 
   src.owner,
   src.name,
   src.type,
   src.line,
   src.text
FROM 
   all_source src
WHERE 1=1
   AND src.owner NOT IN ('SYS', 'SYSTEM')
   AND UPPER(src.text) LIKE '%AUTONOMOUS%'
ORDER BY 
   src.name, 
   src.line ASC
;
--
--OWNER  NAME  TYPE  LINE  TEXT
--RDOP  PFL_K_QRCODE  PACKAGE BODY  45      PRAGMA AUTONOMOUS_TRANSACTION;
