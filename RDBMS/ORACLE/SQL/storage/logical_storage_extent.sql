SELECT 
   ROUND(xtn.bytes / POWER(1024, 1)  ,2) size_kb
   ,xtn.*
FROM 
   dba_extents xtn
WHERE 1=1
   AND xtn.tablespace_name  = 'FAP_DATA'
   AND xtn.segment_name     = 'TRONCON'
;


SELECT 
   ROUND(SUM(xtn.bytes) / POWER(1024, 3)  ,2) size_gb
FROM 
   dba_extents xtn
WHERE 1=1
   AND xtn.tablespace_name  = 'FAP_DATA'
   AND xtn.segment_name     = 'TRONCON'
;

SELECT 
   ROUND(SUM(xtn.bytes) / POWER(1024, 3)  ,2) size_gb
FROM 
   dba_extents xtn
WHERE 1=1
   AND xtn.tablespace_name  = 'FAP_DATA'
   AND xtn.segment_name     = 'TRACE'
;

---------------------------------------------------------------------------
--------------      Compare                   -------------
---------------------------------------------------------------------------


-- Actual DATA:  dba_tables num_rows * avg_row_len   dba_extents.bytes  dba_segments.blocks = 0.01 Go
-- Actual SIZE:  dba_tables.blocks                                                          = 5.48 Go  

-- extents
SELECT 
   ROUND(SUM(xtn.bytes) / POWER(1024, 3)  ,2) size_gb
FROM 
   dba_extents xtn
WHERE 1=1
   AND xtn.tablespace_name  = 'FAP_DATA'
   AND xtn.segment_name     = 'TRACE'
;
--  0,01


-- frag
SELECT 
   'Size (Go) =>'                                rpt_cnt
   ,ROUND( (t.blocks * 8192             / POWER(1024,3) ),2)   used 
   ,ROUND( (t.num_rows * t.avg_row_len  / POWER(1024,3) ),2)   actual
   ,ROUND( (t.blocks * 8192             / POWER(1024,3) ),2)
    -
   ROUND( (t.num_rows * t.avg_row_len  / POWER(1024,3) ),2)    wasted 
FROM 
   dba_tables t
WHERE 1=1
   AND t.owner      = 'DBOFAP'
   AND t.table_name = 'TRACE'
;   	
/*
RPT_CNT	      USED	ACTUAL	WASTED
Size (Go) =>	5,48	0,01	   5,47
*/

--  Space used by a table
SELECT 
  --sgm.*
  ROUND( (SUM(sgm.bytes) / POWER(1024,3) ), 2) size_gb 
FROM
   dba_segments  sgm
WHERE  1=1
   AND   sgm.owner        = 'DBOFAP'
   AND   sgm.segment_name = 'TRACE'
;

/*
 	SIZE_GB
	0,01
*/

SELECT 
  sgm.*
FROM
   dba_segments  sgm
WHERE  1=1
   AND   sgm.owner        = 'DBOFAP'
   AND   sgm.segment_name = 'TRACE'
;