---------------------------------------------------------------------------
--------------      Param                    -------------
---------------------------------------------------------------------------

-- Statistic type
SELECT
   table_name, 
   DECODE(stattype_locked, NULL, 'AUTO', 'ALL', 'LOCKED', '?')
FROM 
   dba_tab_statistics 
WHERE 1=1
   --AND --table_name = 'EVT_' 
   AND owner = 'DBOFAP'
--   AND stattype_locked IS NOT NULL
   AND stattype_locked <> ''
;



select sample_size/100000 * 100 pct from all_tables
where  table_name = 'ECM_ELEMENT_COUT_MODELE';

-- Prefs stored for job
select * from 
   sys.user_tab_stat_prefs ;


select * from user_source
where  lower(text) like '%gather%stats%'
;

/* 

job for statistic collection VS dbms_stats.gather_schema_stats

Both activities use the same parameters. 
So the stats will look the same - IF they get created. 
The real difference between 
- the Automatic Statistics Gathering job 
- and a manual invocation of GATHER_SCHEMA_STATS
is that the latter will refresh ALL statistics whereas the Automatic Statistics Gathering job will refresh only statistics on objects where statistics are missing or marked as STALE.
*/

-- Is job for statistic collection enabled ?
SELECT client_name, status 
FROM dba_autotask_client 
WHERE client_name='auto optimizer stats collection'
;

-- Parameters value

SET ECHO OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
SET TIMING OFF
DECLARE
   v1  varchar2(100);
   v2  varchar2(100);
   v3  varchar2(100);
   v4  varchar2(100);
   v5  varchar2(100);
   v6  varchar2(100);
   v7  varchar2(100);
   v8  varchar2(100);
   v9  varchar2(100);
   v10 varchar2(100);        
BEGIN
   dbms_output.put_line('Automatic Stats Gathering Job - Parameters');
   dbms_output.put_line('==========================================');
   v1 := dbms_stats.get_prefs('AUTOSTATS_TARGET');
   dbms_output.put_line(' AUTOSTATS_TARGET:  ' || v1);
   v2 := dbms_stats.get_prefs('CASCADE');
   dbms_output.put_line(' CASCADE:           ' || v2);
   v3 := dbms_stats.get_prefs('DEGREE');
   dbms_output.put_line(' DEGREE:            ' || v3);
   v4 := dbms_stats.get_prefs('ESTIMATE_PERCENT');
   dbms_output.put_line(' ESTIMATE_PERCENT:  ' || v4);
   v5 := dbms_stats.get_prefs('METHOD_OPT');
   dbms_output.put_line(' METHOD_OPT:        ' || v5);
   v6 := dbms_stats.get_prefs('NO_INVALIDATE');
   dbms_output.put_line(' NO_INVALIDATE:     ' || v6);
   v7 := dbms_stats.get_prefs('GRANULARITY');
   dbms_output.put_line(' GRANULARITY:       ' || v7);
   v8 := dbms_stats.get_prefs('PUBLISH');
   dbms_output.put_line(' PUBLISH:           ' || v8);
   v9 := dbms_stats.get_prefs('INCREMENTAL');
   dbms_output.put_line(' INCREMENTAL:       ' || v9);
   v10:= dbms_stats.get_prefs('STALE_PERCENT');
   dbms_output.put_line(' STALE_PERCENT:     ' || v10);
END;
/

/*
Automatic Stats Gathering Job - Parameters
==========================================
 AUTOSTATS_TARGET:  AUTO
 CASCADE:           DBMS_STATS.AUTO_CASCADE
 DEGREE:            NULL
 ESTIMATE_PERCENT:  DBMS_STATS.AUTO_SAMPLE_SIZE
 METHOD_OPT:        FOR ALL COLUMNS SIZE AUTO
 NO_INVALIDATE:     DBMS_STATS.AUTO_INVALIDATE
 GRANULARITY:       AUTO
 PUBLISH:           TRUE
 INCREMENTAL:       FALSE
 STALE_PERCENT:     10
*/


-- Statistics status
SELECT 
   'Stat freshness=> ' rpr_cnt
   ,stt.table_name
   ,stt.stale_stats
   ,stt.last_analyzed stt_xct_dt
   ,stt.sample_size
   ,stt.num_rows
   ,ROUND(stt.sample_size / stt.num_rows, 2) * 100 || ' %' pct
   ,stt.*
FROM 
   dba_tab_statistics stt
WHERE 1=1
--   AND stt.stale_stats   =   'YES'
   AND stt.owner         =   'DBOFAP'
   AND stt.table_name    =   'TRONCON' 
;



-- Stale statistics
SELECT 
   'Stat freshness=> ' rpr_cnt
   ,stt.table_name
   ,stt.stale_stats
   ,stt.last_analyzed stt_xct_dt
   ,stt.sample_size
   ,stt.num_rows
   ,ROUND(stt.sample_size / stt.num_rows, 2) * 100 || ' %' pct
   ,stt.*
FROM 
   dba_tab_statistics stt
WHERE 1=1
   AND stt.stale_stats   =   'YES'
   AND stt.owner         =    'DBOFAP'
--   AND stt.table_name    =   'TRONCON' 
;


-- Missing statistics
SELECT 
   'Stat freshness=> ' rpr_cnt
   ,stt.table_name
   ,stt.stale_stats
   ,stt.last_analyzed stt_xct_dt
   ,stt.sample_size
   ,stt.num_rows
   ,ROUND(stt.sample_size / stt.num_rows, 2) * 100 || ' %' pct
   ,stt.*
FROM 
   dba_tab_statistics stt
WHERE 1=1
--   AND stt.stale_stats   =   'YES'
   AND stt.owner         =    'DBOFAP'
   --AND stt.table_name    =   'TRONCON' 
   --AND stt.table_name    NOT LIKE 'WRK%' 
   AND stt.last_analyzed IS NULL
;



select * from dba_tab_col_statistics
;

-- Missing statistics
SELECT 
   'Stat freshness=> ' rpr_cnt
--   ,stt_cnt.table_name
   ,stt_cnt.column_name
   ,stt_cnt.last_analyzed stt_xct_dt
   ,stt_cnt.sample_size
   ,stt_cnt.num_distinct
  -- ,ROUND(stt_cnt.num_distinct / stt_cnt.sample_size, 2) * 100 || ' %' dst_pct
   ,stt_cnt.low_value
   ,stt_cnt.high_value
   ,stt_cnt.num_nulls
  -- ,ROUND(stt_cnt.num_nulls   / stt_cnt.sample_size, 2) * 100 || ' %' nll_pct
   ,stt_cnt.density
   ,'DBA_TAB_COL_STATISTICS=>'
   ,stt_cnt.*
FROM 
   dba_tab_col_statistics stt_cnt
WHERE 1=1
--   AND stt_cnt.stale_stats   =   'YES'
   AND stt_cnt.owner         =    'DBOFAP'
   AND stt_cnt.table_name    =   'TRONCON' 
   --AND sstt_cnttt.table_name    NOT LIKE 'WRK%'    
;



---------------------------------------------------------------------------
--------------      Stats                    -------------
---------------------------------------------------------------------------


-- Table last statistics collected
SELECT 
    'Table'         rqt_cnt 
--   ,tbl.owner      tbl_prp
   ,tbl.table_name tbl_nm
--   ,tbl.num_rows   tbl_nrg_nmb
   ,tbl.last_analyzed
--   ,tbl.*
FROM 
   all_tables tbl
WHERE 1=1
   AND tbl.owner               =   'DBOFAP'
--   AND UPPER(tbl.table_name)   =   UPPER('EVT_FAP_DETAIL')
   AND tbl.last_analyzed  IS NOT NULL
ORDER BY
    tbl.last_analyzed DESC
;

-- Table last statistsics gathering
SELECT 
--   'Table'         rqt_cnt 
--   ,tbl.owner      tbl_prp
--   ,tbl.table_name tbl_nm
--   ,tbl.num_rows   tbl_nrg_nmb
   tbl.last_analyzed
--   ,tbl.*
FROM 
   all_tables tbl
WHERE 1=1
   AND tbl.owner               =   'DBOFAP'
   AND UPPER(tbl.table_name)   =   UPPER('EVT_FAP_DETAIL')
ORDER BY
   
;

-- estimate_percent => dbms_stats.auto_sample_size ?? 
SELECT 
   t.table_name,
   t.last_analyzed,
   n(t.num_rows),
   n(t.sample_size)
FROM
   dba_tables t
WHERE 1=1
   AND t.owner = 'DBOFAP'
   AND t.num_rows IS NOT NULL
   AND t.table_name = 'ECM_ELEMENT_COUT_MODELE'
ORDER BY
   t.num_rows DESC
;

-- For a table
SELECT 
   t.table_name,
   t.last_analyzed,
   n(t.num_rows),
   n(t.sample_size)
FROM
   dba_tables t
WHERE 1=1
   AND t.owner = 'DBOFAP'
   AND t.num_rows IS NOT NULL
   AND t.table_name = 'ECM_ELEMENT_COUT_MODELE'
;

---------------------------------------------------------------------------
--------------      Gather                    -------------
---------------------------------------------------------------------------


/*
Procedure	            Collects
GATHER_INDEX_STATS      Index statistics
GATHER_TABLE_STATS      Table, column, and index statistics
GATHER_SCHEMA_STATS     Statistics for all objects in a schema
GATHER_DATABASE_STATS   Statistics for all objects in a database
GATHER_SYSTEM_STATS     CPU and I/O statistics for the system
*/

-- sqlplus
EXEC DBMS_STATS.GATHER_TABLE_STATS('FAP', 'FILIERE_TMP');
EXEC DBMS_STATS.GATHER_TABLE_STATS(NULL, 'TEST');

EXEC dbms_stats.gather_table_stats( ownname           =>   NULL,  tabname           =>   UPPER('filiere_histo_svg'),    estimate_percent  =>   dbms_stats.auto_sample_size);

BEGIN
   dbms_stats.gather_table_stats(
       ownname           =>   NULL, 
       tabname           =>   'TRONCON_GARDE',
       estimate_percent  =>   10);
END;
/


--plsql

 dbms_stats.gather_table_stats(
       ownname           =>   NULL, 
       tabname           =>   'ECM_ELEMENT_COUT_MODELE',
       estimate_percent  =>   dbms_stats.auto_sample_size);

       
   
