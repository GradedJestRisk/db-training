
/* 
SEGMENT_TYPE
------------
TABLE
INDEX
LOBINDEX
LOBSEGMENT

CLUSTER
INDEX PARTITION
LOB PARTITION
NESTED TABLE
ROLLBACK
TABLE PARTITION
TABLE SUBPARTITION
TYPE2 UNDO
*/

---------------------------------------------------------------------------
--------------      Segment                    -------------
---------------------------------------------------------------------------

-- Segment
-- For an owner
SELECT 
   'Segment=>' 
   ,sgm.segment_type
   ,sgm.*
FROM
   dba_segments sgm
WHERE 1=1
   AND sgm.owner = 'DBOFAP'
;


SELECT 
   ao.object_id,
   ao.data_object_id
FROM 
   all_objects ao
WHERE 1=1
   AND ao.owner = 'DBOFAP'
 --  AND ao.object_type = 'SEGMENT'
   AND ao.object_name = 'FILIERE'
;

---------------------------------------------------------------------------
--------------      Tablespace                    -------------
---------------------------------------------------------------------------

-- Segment
-- For a tablespace
SELECT 
   'Segment=>'         rpr_cnt
  ,sgm.segment_name    sgm_nm
  ,sgm.segment_type    sgm_typ
  ,ROUND(sgm.bytes / POWER(1024, 3) ,2) size_gb
  ,'DBA_SEGMENT=>'    
  ,sgm.*
FROM
   dba_segments  sgm
WHERE  1=1
   AND   sgm.tablespace_name = 'FAP_DATA'
;


-- Segment size
-- For a tablespace
SELECT 
   'Segment size=>'         rpr_cnt
  ,sgm.tablespace_name    sgm_nm
  ,ROUND(SUM(sgm.bytes) / POWER(1024, 3) ,2) size_gb
FROM
   dba_segments  sgm
WHERE  1=1
   AND   sgm.tablespace_name = 'FAP_DATA'
GROUP BY
   sgm.tablespace_name 
;




---------------------------------------------------------------------------
--------------   Table data (*LOB excluded) space usage                    -------------
---------------------------------------------------------------------------



SELECT 
   owner, table_name, owner segment_owner, table_name segment_name 
FROM
   dba_tables t
WHERE 1=1
   AND t.table_name = 'TRACE'
;


SELECT 
   sgm.*  
FROM
   dba_segments sgm
WHERE 1=1
   AND sgm.segment_type = 'TABLE'
   AND sgm.segment_name = 'TRONCON'
;

SELECT 
  sgm.*
  ROUND(sgm.bytes / POWER(1024, 3) ,2) size_gb
FROM
   dba_tables   tbl
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = tbl.table_name AND sgm.owner = tbl.owner)
WHERE  1=1
   AND   tbl.owner      = 'DBOFAP'
   AND   tbl.table_name = 'TRONCON'
;


SELECT 
  --sgm.*
  ROUND(SUM(sgm.bytes / POWER(1024, 3) ) ,2) size_gb
FROM
   dba_tables   tbl
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = tbl.table_name AND sgm.owner = tbl.owner)
WHERE  1=1
   AND   tbl.owner      = 'DBOFAP'
   AND   tbl.table_name = 'TRONCON'
;


--  Space used by a table
SELECT 
  --sgm.*
  ROUND( (SUM(sgm.blocks) * 8192 / POWER(1024,3) ), 2) size_gb 
FROM
   dba_segments  sgm
WHERE  1=1
   AND   sgm.owner        = 'DBOFAP'
   AND   sgm.segment_name = 'TRACE'
;


-- Total space used by list of tables
SELECT 
  ROUND( (SUM(sgm.blocks) * 8192 / POWER(1024,3) ), 2) size_gb 
FROM
   dba_segments sgm
WHERE 1=1
   AND sgm.segment_name IN   (
         'ECM_ELEMENT_COUT_MODELE',
         'TRONCON',
         'ALT_ALERT_LOGI_FAP',
         'ALT_TAR',
         'EVT_FAP_DETAIL',
         'L_CCO_FAP',
         'UL_FILIERE ',
         'FILIERE' )   
;


-- Total space per table
-- All >  1 GB
SELECT 
   tbl.table_name,
   ROUND( (SUM(sgm.blocks) * 8192 / POWER(1024,3) ), 2) size_gb 
FROM
   dba_tables   tbl
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = tbl.table_name AND sgm.owner = tbl.owner)
WHERE 1=1
GROUP BY
   tbl.table_name
HAVING 
   ROUND(SUM(sgm.blocks)*8/1024/1024, 2) > 1
ORDER BY 
   SUM(sgm.blocks) DESC 
;

-- Table - Reclaimable space
SELECT 
   'Used/Tota/Reclaimable (Gb) =>' qr_cnt,
   table_name tables,
   used,
   total,
   (total - used) reclaimable,
   ROUND( ((total - used) / total) * 100, 2) || ' %' reclaimable_pct
FROM
   (SELECT 
      table_name,
      ROUND(ROUND((blocks*8), 2) / 1024 / 1024, 2)                    total,
      ROUND(ROUND(((num_rows*avg_row_len/1024)), 2) / 1024 / 1024, 2) used
   FROM 
      dba_tables  tbl
   WHERE 1=1
      AND tbl.owner   =   'DBOFAP'
      AND blocks      IS   NOT NULL
      AND blocks      >   0   ) t
WHERE 1=1
   AND total <> 0
ORDER BY
   total DESC
;



---------------------------------------------------------------------------
--------------   Index space usage                    -------------
---------------------------------------------------------------------------


SELECT 
   ndx.index_name,
   ROUND( (sgm.blocks * 8192 / POWER(1024,3) ), 2) size_gb 
   --   owner, table_name, owner segment_owner, table_name segment_name 
FROM
   dba_indexes   ndx
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = ndx.index_name)
WHERE  1=1
   AND   ndx.index_name = 'TRCNAT_FK'
--GROUP BY 
--   ndx.index_name
;



SELECT 
   ndx.index_name segment_name,
   ndx.*
--   owner, table_name, owner segment_owner, table_name segment_name 
FROM
   dba_indexes ndx
WHERE  1=1
   AND   ndx.table_name = 'FILIERE'
;



SELECT 
   --ndx.index_name,
   ROUND( (SUM(sgm.blocks) * 8192 / POWER(1024,3) ), 2) size_gb 
   --   owner, table_name, owner segment_owner, table_name segment_name 
FROM
   dba_indexes   ndx
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = ndx.index_name)
WHERE  1=1
   AND   ndx.table_name = 'FILIERE'
--GROUP BY 
--   ndx.index_name
;


-- Total space
-- Given a table
SELECT 
   ndx.table_name,
   ROUND( (SUM(sgm.blocks) * 8192 / POWER(1024,3) ), 2) size_gb    
FROM
   dba_indexes   ndx
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = ndx.index_name)
WHERE  1=1
   AND   ndx.table_name = 'FILIERE'
GROUP BY
    ndx.table_name
ORDER BY
    ndx.table_name
;

-- Total space
-- Given a list of tables
SELECT 
   ndx.table_name,
   ROUND( (SUM(sgm.blocks) * 8192 / POWER(1024,3) ), 2) size_gb    
FROM
   dba_indexes   ndx
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = ndx.index_name)
WHERE  1=1
   AND   ndx.table_name IN (
         'ALT_ALERT_LOGI_FAP',
         'ALT_TAR',
         'EVT_FAP_DETAIL',         
         'ECM_ELEMENT_COUT_MODELE',
         'FILIERE',
         'L_CCO_FAP',
         'TRONCON',
         'UL_FILIERE')        
GROUP BY
    ndx.table_name
ORDER BY
    ndx.table_name
;





-- Total space used 
-- Per table > 1 GB
SELECT 
   ndx.table_name,
   ROUND(SUM(blocks)*8/1024/1024, 2) size_gb
   --   owner, table_name, owner segment_owner, table_name segment_name 
FROM
   dba_indexes   ndx
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = ndx.index_name)
WHERE  1=1
   AND   ndx.owner = 'DBOFAP'
GROUP BY 
   ndx.table_name
HAVING 
   ROUND(SUM(blocks)*8/1024/1024, 2) > 1
ORDER BY    
   ROUND(SUM(blocks)*8/1024/1024, 2)  DESC
;




select 
   round(blocks*8/1024)      size_mb, 
   round(blocks*8/1024/1024) size_gb
from
   dba_segments sgm
where 1=1
   AND sgm.segment_name = 'FILIERE'
;


-- http://www.oaktable.net/content/largest-tables-including-indexes-and-lobs   
WITH 

   segment_rollup as (
     select owner, table_name, owner segment_owner, table_name segment_name 
     from dba_tables
       UNION ALL
     select table_owner, table_name, owner segment_owner, index_name segment_name 
     from dba_indexes
       UNION ALL
     select owner, table_name, owner segment_owner, segment_name 
     from dba_lobs
       UNION ALL
     select owner, table_name, owner segment_owner, index_name segment_name 
     from dba_lobs
   ),

  ranked_tables AS (
     select 
        rank() over (order by sum(blocks) desc) rank, 
        sum(blocks) blocks, 
        r.owner, 
        r.table_name
     from 
      segment_rollup r 
         INNER JOIN dba_segments s ON (s.owner = r.segment_owner and s.segment_name = r.segment_name)
     WHERE 1=1
        AND r.owner=upper('DBOFAP')
     GROUP BY 
        r.owner, r.table_name
   )
      
SELECT 
   rank, 
--   round(blocks*8/1024, )      size_mb, 
   ROUND( blocks*8/1024/1024, 2) size_gb, 
   ROUND( ((blocks*8/1024/1024) / 386  * 100), 2 ) size_gb_pct,
   table_name
FROM 
   ranked_tables
WHERE 1=1
   AND rank <= 20
   AND round(blocks*8/1024/1024) > 1
--   table_name = UPPER('evt_fap_detail')
;   

-- With %
SELECT 
   rank, 
--   round(blocks*8/1024, )      size_mb, 
   ROUND( blocks*8/1024/1024, 2) size_gb, 
   ROUND( ((blocks*8/1024/1024) / 386  * 100), 2 ) size_gb_pct,
   table_name
FROM 
   ranked_tables
WHERE 1=1
   AND rank <= 20
   AND round(blocks*8/1024/1024) > 1
--   table_name = UPPER('evt_fap_detail')


-- Total size
SELECT 
   ROUND(SUM(blocks*8/1024/1024), 2) total_size_gb
FROM 
   ranked_tables
WHERE 1=1
;
-- 386.31



---------------------------------------------------------------------------
--------------    LOB                   -------------
---------------------------------------------------------------------------

-- Colonne 
-- Par nom exact
SELECT 
   atc.owner,
   atc.table_name,
   atc.column_name,
   atc.*
FROM 
   all_tab_columns atc
WHERE 1=1
   AND atc.owner         =   'DBOFAP'
   --AND UPPER(atc.column_name)   =   UPPER('cd_ass')
   AND atc.data_type LIKE '%LOB'
ORDER BY 
   atc.table_name ASC,
   atc.table_name ASC
;

SELECT 
   table_name,
   column_name, 
   segment_name, 
   a.bytes,
   round(a.bytes/1024/1054)      size_mb,
   round(a.bytes/1024/1024/1024)      size_gb
--    round(SUM(sgm.blocks)*8/1024)      size_mb, 
--   round(SUM(sgm.blocks)*8/1024/1024) size_gb 
FROM 
   dba_segments a 
      JOIN dba_lobs b USING (owner, segment_name)
WHERE 1=1
   AND b.table_name = 'TIB_IN';

-- TBC http://www.idevelopment.info/data/Oracle/DBA_tips/LOBs/LOBS_85.shtml
--ALTER TABLE tib_in MODIFY LOB (tib_data) (SHRINK SPACE);
