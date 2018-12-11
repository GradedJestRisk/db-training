-- Query
SELECT    
    qry.last_active_time
   ,qry.first_load_time
   ,qry.program_id
   --,qry.sql_text
   ,SUBSTR(qry.sql_text, 1, 30)
   ,qry.*
FROM 
   v$sql qry
WHERE 1=1
    AND qry.sql_id = '7wuhdkxrw9q26'
ORDER BY
   qry.last_active_time
;


-- Query
SELECT    
    qry.last_active_time
   ,qry.first_load_time
   ,qry.program_id
   --,qry.sql_text
   ,SUBSTR(qry.sql_text, 1, 30)
   ,qry.*
FROM 
   v$sql qry
WHERE 1=1
 --   AND qry.sql_id = '9atcf48r9w0sv'
   AND qry.sql_text LIKE 'UPDATE%WRK_EXP_FAP%'
   --AND TRUNC(qry.last_active_time) = TRUNC(SYSDATE)
   --AND command_type = 6
ORDER BY
   qry.last_active_time
;


-- Query + container
SELECT    
    ao.object_name
   ,qry.last_active_time
   ,qry.first_load_time
   ,qry.program_id
   ,qry.program_line#
   ,qry.plan_hash_value
   --,qry.sql_text
   ,SUBSTR(qry.sql_text, 1, 30)
   ,qry.*
FROM 
   v$sql        qry
      INNER JOIN all_objects  ao ON ao.object_id = qry.program_id
WHERE 1=1
 --   AND qry.sql_id = '9atcf48r9w0sv'
--   AND qry.sql_text                LIKE  'MERGE%FILIERE%'
--   AND TRUNC(qry.last_active_time) =   TRUNC(SYSDATE)
   AND  ao.owner                   =   'DBOFAP'
   AND  ao.object_type             =   'PACKAGE BODY'
   AND  ao.object_name             =   'PKG_GEN_FILIERE'
ORDER BY
   qry.last_active_time
;


-- 
SELECT * FROM v$sqlarea
where sql_id = '185qpt4cbaj1h'
;



SELECT * FROM all_objects ao WHERE ao.object_id = 63904;


-- Full-text query
SELECT 
   qry_txt.* 
FROM 
   v$sqltext qry_txt
WHERE 1=1
   AND qry_txt.sql_id = '185qpt4cbaj1h'
ORDER BY
   qry_txt.piece ASC
;

select * from DBA_HIST_SQLTEXT 
where sql_id = '185qpt4cbaj1h'
;

select * from v$sqlstats
where sql_id = '185qpt4cbaj1h'
;
