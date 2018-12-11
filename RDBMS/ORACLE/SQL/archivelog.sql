SELECT 
   'ArchiveLog (go) =>'                        rpr_cnt 
   ,ROUND ( t.space_used   / POWER(1024,3), 2) used
   ,ROUND ( t.space_limit  / POWER(1024,3), 2) max
FROM 
   v$recovery_file_dest t
WHERE 1=1
--   AND t.
;