SELECT * FROM 
V$DIAG_INFO
WHERE NAME = 'Diag Trace'
;

SELECT PID, PROGRAM, TRACEFILE FROM V$PROCESS
;

SELECT * 
FROM gv$parameter 
   WHERE NAME LIKE '%trace%'
;

SELECT * 
FROM 
   v$parameter 
WHERE 1=1
   AND NAME  = 'sql_trace'
;


SELECT * 
FROM 
   v$parameter 
WHERE 1=1
   AND NAME  = 'timed_statistics'
;

SELECT * 
FROM gv$parameter 
   WHERE NAME LIKE '%trace%'
;


SELECT 
* 
FROM gv$parameter 
   WHERE NAME = 'timed_statistics'
;

SELECT * 
FROM gv$parameter 
   WHERE NAME = 'sql_trace'
;
