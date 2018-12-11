
-- Used space (marked as such by FS)
-- allocated by Oracle in datafile                   DBA_DATAFILE : bytes 

-- Really used space
-- 1) used for data                                  DBA_TABLES : num_row * avg_row_len
-- 2) lost by fragmentation                          DBA_TABLES : size - (num_row * avg_row_len)

-- Free space:
-- 1) In datafile                                    DBA_FREE_SPACE
-- 2) Allocatable by Oracle ON FS (by auto-extend):  DBA_DATAFILE (maxbytes - bytes) + space may not be available on FS (check with df -h)


---------------------------------------------------------------------------
--------------      Storage parameters                    -------------
---------------------------------------------------------------------------

select DBID from v$database;
-- 1479869384

SELECT 
   value      size_block_bytes,
   kb(value)  size_block_kilo_bytes,
   mb(value)  size_block_mega_bytes
FROM   
   v$parameter
WHERE 1=1
   AND UPPER (NAME) = 'DB_BLOCK_SIZE'
;

/*
SIZE_BLOCK_BYTES	SIZE_BLOCK_KILO_BYTES	SIZE_BLOCK_MEGA_BYTES
	         8192	                    8	                  0,01
*/

-- 1 bytes    = 1 octet    =  8      bits
-- 8192 bytes = 8192 octet =  65 536 bits


-- Datafile / Extent Management
SELECT 
   DISTINCT df.autoextensible
FROM 
   dba_data_files df
WHERE 1=1 
   AND df.tablespace_name  = 'FAP_DATA'
;
-- YES


---------------------------------------------------------------------------
--------------      Datafile                    -------------
---------------------------------------------------------------------------

-- Datafile 
-- All
SELECT 
   df.file_name,
  -- df.tablespace_name,
  -- df.autoextensible,
   gb(df.bytes)       used_size_gb,
   gb(df.maxbytes)    allocated_size_gb
   ,df.*
FROM 
   dba_data_files df
WHERE 1=1
   --AND df.tablespace_name = 'FAP_DATA'
ORDER BY 
   file_id DESC
;

-- Datafile / Actual size
-- Given a tablespace
-- For last created datafile
SELECT 
    df.file_name
   ,ROUND( (df.bytes       / 1024 / 1024 / 1024) , 1) actual_size_gb
--   ,df.*      
FROM 
   dba_data_files df
WHERE 1=1 
   AND df.tablespace_name  = 'FAP_DATA'
--   df.file_name = '/product/oradat/FAP/datafile/o1_mf_fap_data_fzf2b1my_.db'
ORDER BY
   df.file_id DESC   
;

-- Datafile / Size
-- Given a tablespace
SELECT 
   'Datafile => '        rpr_cnt
   ,df.tablespace_name  tbl_nm 
   ,df.file_id
   ,df.file_name        df_os_name
  -- df.autoextensible,
   ,gb(df.maxbytes)            allocated_gb
   ,gb(df.bytes)               used_gb
   ,gb(df.maxbytes - df.bytes) free_gb
   ,'DBA_DATA_FILES => '       
   ,df.*
FROM 
   dba_data_files df
WHERE 1=1
   AND df.tablespace_name = 'FAP_DATA'
ORDER BY 
   df.file_id DESC
;



-- v$datafile,     accessible during db mounting
-- dba_data_files, accessible when   db is open
SELECT * FROM V$DATAFILE;

---------------------------------------------------------------------------
--------------     DATA datafiles                  -------------
---------------------------------------------------------------------------


-- cd /product/oradat/FAP/datafile/
-- ls -ltrh *fap_data*

-- du -csh *fap_data* | tail -1 | cut -f 1
/*
[fap@LNXFRH099700850][/product/oradat/FAP/datafile]>du -csh *fap_data* | tail -1 | cut -f 1
602 G
*/

-- Tablespace + Datafile
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
   ,df.file_id
   ,df.file_name        df_os_name
   ,'DBA_DATA_FILES=> '    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
      INNER JOIN  dba_data_files df ON df.tablespace_name = tbls.tablespace_name
WHERE 1=1
   AND tbls.contents            =   'PERMANENT'
   AND tbls.tablespace_name     =   'FAP_DATA'
;


-- Space used by datafile
-- Given tablespace / name
SELECT 
    ROUND( SUM(   df.bytes                  / POWER(1024, 3) ), 0)    used_gb, 
    ROUND( SUM(   df.maxbytes               / POWER(1024, 3) ), 0)    max_gb,
    ROUND( SUM(  (df.maxbytes - df.bytes)   / POWER(1024, 3) ), 0)    free_gb 
FROM 
   dba_tablespaces tbls
      INNER JOIN  dba_data_files df ON df.tablespace_name = tbls.tablespace_name
WHERE 1=1
   AND tbls.contents            =   'PERMANENT'
   AND tbls.tablespace_name     =   'FAP_DATA'
;
-- 602 Gb


select * from dba_free_space;

---------------------------------------------------------------------------
--------------     UNDO datafiles                  -------------
---------------------------------------------------------------------------


-- cd /product/oradat/FAP/datafile/
-- ls -ltrh *undo*

/*
[fap@LNXFRH099700850][/product/oradat/FAP/datafile]>ls -ltrh *undo*
-rw-r----- 1 oracle oinstall 32G Nov 23 15:02 o1_mf_undo02_frhhb7vj_.dbf
*/

-- du -csh /product/oradat/FAP/datafile/*undo* | tail -1 | cut -f 1
-- 33 G

-- Tablespace + Datafile
-- Given tablespace / name
SELECT 
   'Tablespace=>'         rpr_cnt
   ,tbls.tablespace_name  tbls_nm
   ,tbls.contents         tbls_typ 
   ,df.file_id
   ,df.file_name        df_os_name
   ,'DBA_DATA_FILES=> '    
   ,tbls.*    
FROM 
   dba_tablespaces tbls
      INNER JOIN  dba_data_files df ON df.tablespace_name = tbls.tablespace_name
WHERE 1=1
   AND tbls.contents            =   'UNDO'
   AND tbls.tablespace_name     =   'UNDO02'
;

-- Space used by datafile
-- Given tablespace / name
SELECT 
    ROUND( SUM( (df.bytes      / 1024 / 1024 / 1024)) , 0)    used_gb, 
    ROUND( SUM( (df.maxbytes   / 1024 / 1024 / 1024)) , 0)    max_gb
FROM 
   dba_tablespaces tbls
      INNER JOIN  dba_data_files df ON df.tablespace_name = tbls.tablespace_name
WHERE 1=1
   AND tbls.contents            =   'UNDO'
   AND tbls.tablespace_name     =   'UNDO02'
;
-- 32 Gb






---------------------------------------------------------------------------
--------------     TEMP datafiles                  -------------
---------------------------------------------------------------------------

-- temp datafile
SELECT 
   *
FROM 
   v$tempfile
;

-- temp datafile
SELECT * 
FROM 
   dba_temp_files
;


-- TEMP space
-- For all files
SELECT 
   'Temp space=>'                      rpr_cnt
   ,free_space.tablespace_name
   ,free_space.file_id
   ,ROUND(free_space.bytes_used / 1024 / 1024 / 1024, 0) used_gb
   ,ROUND(free_space.bytes_free / 1024 / 1024 / 1024, 0) free_gb
   ,'V$TEMP_SPACE_HEADER=>'
   ,free_space.*   
FROM  
   v$temp_space_header free_space
WHERE 1=1
--   AND free_space.bytes_used
ORDER BY
   free_space.file_id DESC
;


-- TEMP space
-- Total
SELECT 
   'Temp space=>'                      rpr_cnt
--   gb(free_space.bytes_used) space_used,
--   gb(free_space.bytes_free) space_free
  ,ROUND(SUM(free_space.bytes_used) / 1024 / 1024 / 1024, 0) used_gb
  ,ROUND(SUM(free_space.bytes_free) / 1024 / 1024 / 1024, 0) free_gb
--   free_space.*   
FROM  
   v$temp_space_header free_space
WHERE 1=1
--   AND free_space.bytes_used
;


-- free space real-time..
SELECT 
   ROUND(free_space / 1024 / 1024 / 1024, 0) actual_free_gb
  -- gb(free_space) 
FROM 
   dba_temp_free_space
;


---------------------------------------------------------------------------
--------------     Free space (FS + datafile)                    -------------
---------------------------------------------------------------------------

--  Free space (FS + datafile)  
-- Given a tablespace
SELECT 
   dtf.file_id,
   dtf.tablespace_name, 
   dtf.file_name, 
   'Allocation on FS =>'  x
   ,ROUND( (dtf.bytes                    / POWER(1024, 3)) , 0)   actual
   ,ROUND( ((dtf.maxbytes - dtf.bytes)   / POWER(1024, 3)) , 0)   remaining
   ,ROUND( (dtf.maxbytes                 / POWER(1024, 3)) , 0)   max
   ,'Free in datafile =>'  x
   ,ROUND( (free.free_bytes              / POWER(1024, 3)) , 0)   actual
FROM 
   dba_data_files dtf
      INNER JOIN
         (SELECT file_id, SUM(bytes) free_bytes
          FROM dba_free_space b GROUP BY file_id)   free   ON    dtf.file_id         =  free.file_id
WHERE 1=1
   AND dtf.tablespace_name = 'FAP_DATA' 
ORDER BY 
   dtf.file_id DESC
;



---------------------------------------------------------------------------
--------------     Free space on datafile                    -------------
---------------------------------------------------------------------------


SELECT *
FROM 
   dba_free_space
WHERE 1=1
--   AND TABLESPACE_NAME = '
;


-- Datafile / Free space for each datafile
-- Given a tablespace
SELECT 
   'Free space DF=>' rpr_cnt
   ,dtf.file_id
   ,dtf.tablespace_name
   ,dtf.file_name
   ,ROUND( (free.free_bytes  / POWER(1024, 3)) , 0)   actual_gb
FROM 
   dba_data_files dtf
      INNER JOIN
         (SELECT file_id, SUM(bytes) free_bytes
          FROM dba_free_space b GROUP BY file_id)   free   ON    dtf.file_id         =  free.file_id
WHERE 1=1
   AND dtf.tablespace_name = 'FAP_DATA' 
ORDER BY 
   dtf.file_id DESC
;



-- Datafile / Total free space 
-- Given a tablespace
SELECT 
   'Free space DF=>' rpr_cnt
   ,ROUND( (SUM(free.free_bytes)  / POWER(1024, 3)) , 0)   actual_gb
FROM 
   dba_data_files dtf
      INNER JOIN
         (SELECT file_id, SUM(bytes) free_bytes
          FROM dba_free_space b GROUP BY file_id)   free   ON    dtf.file_id         =  free.file_id
WHERE 1=1
   AND dtf.tablespace_name = 'FAP_DATA' 
;


-- Free zone
-- Given a tablespace
SELECT 
   'Free extents=>'  rpr_cnt
   ,fr_xt.file_id    df_dtf
   ,fr_xt.block_id   xt_blk_start
   ,fr_xt.block_id   xt_size_blk
   ,fr_xt.block_id   xt_size_oct
FROM 
   dba_free_space  fr_xt --free_extents
WHERE 1=1
   AND fr_xt.tablespace_name = 'FAP_DATA'
--   AND fr_xt.file_id         =  42  
ORDER BY
   fr_xt.file_id, 
   fr_xt.block_id   
;


-- Free zone
-- Given a tablespace
SELECT 
   fr_xt.file_id,
   COUNT(1)
FROM 
   dba_free_space  fr_xt --free_extents
WHERE 1=1
   AND fr_xt.tablespace_name = 'FAP_DATA'
--   AND fr_xt.file_id         =  42  
GROUP BY
   fr_xt.file_id
ORDER BY
   COUNT(1) DESC
;

