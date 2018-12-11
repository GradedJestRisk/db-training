---------------------------------------------------------------------------
--------------     Segments                    -------------
---------------------------------------------------------------------------

-- Available types
/*
LOBINDEX
INDEX PARTITION
TABLE PARTITION
NESTED TABLE
ROLLBACK
LOB PARTITION
LOBSEGMENT
INDEX
TABLE
CLUSTER
TYPE2 UNDO
*/

-- Used types
SELECT 
   segment_type,
   COUNT(1)
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
GROUP BY 
   segment_type
;

--SEGMENT_TYPE	COUNT(1)
--LOBINDEX	     3
--LOBSEGMENT	  3
--INDEX	      267
--TABLE	      185


-- Total size per segment
SELECT 
   segment_type,
   TRUNC(SUM(sgm.bytes/1024/1024/1024)) size_gb
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
GROUP BY 
   segment_type
;

-- Used types
SELECT 
   *
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'LOBSEGMENT' 
;


---------------------------------------------------------------------------
--------------      Size (data + lob + index)                    -------------
---------------------------------------------------------------------------

-- http://www.oaktable.net/content/largest-tables-including-indexes-and-lobs   
with segment_rollup as (
  select owner, table_name, owner segment_owner, table_name segment_name from dba_tables
    union all
  select table_owner, table_name, owner segment_owner, index_name segment_name from dba_indexes
    union all
  select owner, table_name, owner segment_owner, segment_name from dba_lobs
    union all
  select owner, table_name, owner segment_owner, index_name segment_name from dba_lobs
), ranked_tables as (
  select rank() over (order by sum(blocks) desc) rank, sum(blocks) blocks, r.owner, r.table_name
  from segment_rollup r, dba_segments s
  where s.owner=r.segment_owner and s.segment_name=r.segment_name
    and r.owner=upper('DBOFAP')
  group by r.owner, r.table_name
)
select 
   rank, 
   round(blocks*8/1024)      size_mb, 
   round(blocks*8/1024/1024) size_gb, 
   table_name
from 
   ranked_tables
where 
--   rank<=20
   table_name = UPPER('evt_fap_detail');   
   


---------------------------------------------------------------------------
--------------     Table             -------------
---------------------------------------------------------------------------


-- Total size
SELECT 
   TRUNC(SUM(sgm.bytes/1024/1024/1024)) size_gb
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'TABLE' 
;


-- Table size
SELECT 
   sgm.segment_name         table_name,
   sgm.bytes/1024/1024/1024 size_gb,
   sgm.bytes/1024/1024      size_mb   
      --sgm.*,
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'TABLE' 
 --AND segment_name='TRACE'
ORDER BY
   sgm.bytes DESC   
;


-- Table size
SELECT 
   sgm.segment_name         table_name,
   sgm.bytes/1024/1024/1024 size_gb,
   sgm.bytes/1024/1024      size_mb   
      --sgm.*,
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'TABLE' 
   AND segment_name       =   UPPER('EVT_FAP_DETAIL')
ORDER BY
   sgm.bytes DESC   
;

---------------------------------------------------------------------------
--------------     Index             -------------
---------------------------------------------------------------------------

-- Total size
SELECT 
   TRUNC(SUM(sgm.bytes/1024/1024/1024)) size_gb
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'TABLE' 
;


-- Table size
SELECT 
   sgm.segment_name         table_name,
   sgm.bytes/1024/1024/1024 size_gb,
   sgm.bytes/1024/1024      size_mb   
      --sgm.*,
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'TABLE' 
 --AND segment_name='TRACE'
ORDER BY
   sgm.bytes DESC   
;


---------------------------------------------------------------------------
--------------     ALL             -------------
---------------------------------------------------------------------------


-- Total size
SELECT 
   TRUNC(SUM(sgm.bytes/1024/1024/1024)) size_gb
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'TABLE' 
;


-- Table size
SELECT 
   sgm.segment_name         table_name,
   sgm.bytes/1024/1024/1024 size_gb,
   sgm.bytes/1024/1024      size_mb   
      --sgm.*,
FROM 
   dba_segments sgm
WHERE 1=1
   AND sgm.owner          =   'DBOFAP'
   AND sgm.segment_type   =   'TABLE' 
 --AND segment_name='TRACE'
ORDER BY
   sgm.bytes DESC   
;
