SELECT * FROM all_directories
;

SELECT * FROM all_directories
;


SELECT 
   * 
FROM 
   all_directories dir
WHERE 1=1
   AND dir.directory_name = UPPER('FAP_DMBSHP')
;


CREATE DIRECTORY  
   tmp 
AS 
   '/product/FAP/tmp'
;


GRANT 
   READ, WRITE 
ON DIRECTORY 
   tmp 
TO 
   dbofap
;

