---------------------------------------------------------------------------
--------------      DBA tables                    -------------
---------------------------------------------------------------------------

-- Raw
SELECT 
   table_name,    
   blocks,
   num_rows,
   avg_row_len,
   (blocks * 8192)             blocks_X_8192,
   (num_rows * avg_row_len)    num_rows_X_avg_row_len 
FROM 
   dba_tables 
WHERE 1=1
   AND owner      =   'DBOFAP'
   AND table_name =   'TRACE'
;

-- Readable
SELECT 
   'Fragmentation' rpr_cnt
   ,t.table_name         
   ,'Size=>'
   ,t.total
   ,t.used
   ,( t.total - t.used)     wasted
   ,ratio_pct(
         numerator   => (t.total - t.used), 
         denominator =>  t.total
   )                        wasted_pct
FROM
   (SELECT 
      table_name                                table_name,
      ROUND( gb_from_block(blocks),        2)   total,
      ROUND( gb( num_rows * avg_row_len ), 2)   used
   FROM 
      dba_tables 
   WHERE 1=1
      AND owner      =   'DBOFAP'
     -- AND table_name =   'TRACE'
      AND blocks     IS NOT NULL 
      AND blocks     <> 0
      AND num_rows  <> 0
      ) t
WHERE 1=1
   AND ( t.total - t.used ) > 1 -- Wasted > 1 Gb
ORDER BY
   t.total DESC
;

---------------------------------------------------------------------------
--------------      Reorganization                            -------------
---------------------------------------------------------------------------

-- Prototype
ALTER TABLE <TABLE_NAME > MOVE TABLESPACE <TABLESPACE_NAME>
ALTER INDEX <INDEX_NAME> REBUILD ONLINE PARALLEL 2


-- Generate index REBUILD commands
SELECT
   'Rebuild all indexes on table =>' rpr_cnt
   ,ndx.table_name       tbl_nm
   ,ndx.index_name       ndx_nm
   ,'ALTER INDEX ' || ndx.index_name  || ' REBUILD ONLINE PARALLEL 2;' cmm   
FROM
   all_indexes ndx
WHERE 1=1
   AND ndx.owner      = 'DBOFAP'
   AND ndx.table_name = 'TRACE'
;
   
-- Sample
ALTER TABLE TRACE     MOVE TABLESPACE FAP_DATA;    --   1 minute
ALTER INDEX TRACE_IDX REBUILD ONLINE PARALLEL 2;   -- < 1 minute

-- Check fragmentation

SELECT 
   'Fragmentation' rpr_cnt
   ,t.table_name         
   ,'Size=>'
   ,t.total
   ,t.used
   ,( t.total - t.used)     wasted
   ,ratio_pct(
         numerator   => (t.total - t.used), 
         denominator =>  t.total
   )                        wasted_pct
FROM
   (SELECT 
      table_name                                table_name,
      ROUND( gb_from_block(blocks),        2)   total,
      ROUND( gb( num_rows * avg_row_len ), 2)   used
   FROM 
      dba_tables 
   WHERE 1=1
      AND owner      =   'DBOFAP'
      AND table_name =   'TRACE'
      AND blocks     IS NOT NULL 
      AND blocks     <> 0
      AND num_rows  <> 0
      ) t
WHERE 1=1
 --  AND ( t.total - t.used ) > 1 -- Wasted > 1 Gb
ORDER BY
   t.total DESC
;





---------------------------------------------------------------------------
--------------      ASA recommendations                    -------------
---------------------------------------------------------------------------

-- Reclaimable space
-- Given a tablespace
SELECT  
   rcl_spc.segment_type,
   rcl_spc.segment_owner, 
   rcl_spc.segment_name, 
   rcl_spc.recommendations,
 --  ROUND(rcl_spc.used_space / 1024 / 1024 / 1024, 2)        usd_spc_gb,
 --  ROUND(rcl_spc.reclaimable_space / 1024 / 1024 / 1024, 2) rcl_spc_gb,
   ' RCL_SPC =>',
   rcl_spc.*
FROM 
   TABLE (dbms_space.asa_recommendations ('FALSE', 'FALSE', 'FALSE')) rcl_spc
WHERE 1=1
   AND rcl_spc.tablespace_name =   'FAP_DATA'
ORDER BY
   rcl_spc.segment_type, 
   rcl_spc.segment_name
;

-- Reclaimable space
-- Given a tablespace + segment / name
SELECT  
   rcl_spc.segment_type,
   rcl_spc.segment_owner, 
   rcl_spc.segment_name, 
   rcl_spc.recommendations,
 --  ROUND(rcl_spc.used_space / 1024 / 1024 / 1024, 2)        usd_spc_gb,
 --  ROUND(rcl_spc.reclaimable_space / 1024 / 1024 / 1024, 2) rcl_spc_gb,
   ' RCL_SPC =>',
   rcl_spc.*
FROM 
   TABLE (dbms_space.asa_recommendations ('FALSE', 'FALSE', 'FALSE')) rcl_spc
WHERE 1=1
   AND rcl_spc.tablespace_name =   'FAP_DATA'
   AND rcl_spc.segment_name    =   ''
   
ORDER BY
   rcl_spc.segment_type, 
   rcl_spc.segment_name
;


-- Reclaimable space
-- Given a tablespace + segment / name
SELECT  
    sgm.segment_type
   ,sgm.segment_name
   ,rcl_spc.recommendations
   ,'Space (Go)=>'
   ,ROUND(rcl_spc.allocated_space   / POWER(1024, 3), 2)    alloc
   ,ROUND(rcl_spc.used_space        / POWER(1024, 3), 2)    used
   ,ROUND(rcl_spc.reclaimable_space / POWER(1024, 3), 2)    reclaim
   ,' RCL_SPC =>'
   ,rcl_spc.*
FROM 
   TABLE (
      dbms_space.asa_recommendations ('FALSE', 'FALSE', 'FALSE'))   
                  rcl_spc
   INNER JOIN dba_segments   sgm ON sgm.segment_name = rcl_spc.segment_name
WHERE 1=1
   AND rcl_spc.tablespace_name  =   'FAP_DATA'
--   AND rcl_spc.segment_name     =   'PK_FILIERE'
   AND rcl_spc.recommendations LIKE  '%shrink%'   
--   AND rcl_spc.segment_type     =   'TABLE'   
ORDER BY
   rcl_spc.segment_type, 
   rcl_spc.segment_name
;


/*
   all_runs        IN    VARCHAR2 DEFAULT := TRUE,
   show_manual     IN    VARCHAR2 DEFAULT := TRUE,
   show_findings   IN    VARCHAR2 DEFAULT := FALSE
*/


SELECT *
FROM 
   TABLE (dbms_space.asa_recommendations (
             all_runs      => 'FALSE', 
             show_manual   => 'FALSE', 
             show_findings => 'FALSE') )
;

/*

Recommendations

DBA_ADVISOR_RECOMMENDATIONS

If a segment would benefit from a segment shrink, reorganization, or compression, the Segment Advisor generates a recommendation for the segment. Table 19-5 shows examples of generated findings and recommendations.

Findings

DBA_ADVISOR_FINDINGS

Findings are a report of what the Segment Advisor observed in analyzed segments. Findings include space used and free space statistics for each analyzed segment. Not all findings result in a recommendation. (There may be only a few recommendations, but there could be many findings.) When running the Segment Advisor manually with PL/SQL, if you specify 'TRUE' for recommend_all in the SET_TASK_PARAMETER procedure, then the Segment Advisor generates a finding for each segment that qualifies for analysis, whether or not a recommendation is made for that segment. For row chaining advice, the Automatic Segment Advisor generates findings only, and not recommendations. If the Automatic Segment Advisor has no space reclamation recommendations to make, it does not generate findings. However, the Automatic Segment Advisor may generate findings for tables that could benefit from advanced row compression.

Actions

DBA_ADVISOR_ACTIONS

Every recommendation is associated with a suggested action to perform: either segment shrink, online redefinition (reorganization), or compression. The DBA_ADVISOR_ACTIONS view provides either the SQL that you can use to perform a segment shrink or table compression, or a suggestion to reorganize the object.

Objects

DBA_ADVISOR_OBJECTS

All findings, recommendations, and actions are associated with an object. If the Segment Advisor analyzes multiple segments, as with a tablespace or partitioned table, then one entry is created in the DBA_ADVISOR_OBJECTS view for each analyzed segment. Table 19-2 defines the columns in this view to query for information on the analyzed segments. You can correlate the objects in this view with the objects in the findings, recommendations, and actions views.
*/

/*
DBA_ADVISOR_RECOMMENDATIONS
DBA_ADVISOR_FINDINGS
DBA_ADVISOR_ACTIONS
DBA_ADVISOR_OBJECTS
*/


Select a.execution_end, b.type, b.impact, d.rank, d.type, 
'Message           : '||b.message MESSAGE,
'Command To correct: '||c.command COMMAND,
'Action Message    : '||c.message ACTION_MESSAGE
From dba_advisor_tasks a, dba_advisor_findings b,
Dba_advisor_actions c, dba_advisor_recommendations d
Where a.owner=b.owner and a.task_id=b.task_id
And b.task_id=d.task_id and b.finding_id=d.finding_id
And a.task_id=c.task_id and d.rec_id=c.rec_Id
And a.task_name like 'ADDM%' and a.status='COMPLETED'
Order by b.impact, d.rank;
Here is some sample output from


select * from 
   dba_advisor_tasks tsk
WHERE 1=1
   AND tsk.task_name = 'SYS_AUTO_SPCADV_05002223112018'
;

select * from 
   dba_advisor_tasks tsk
WHERE 1=1
   AND tsk.task_name = 'SYS_AUTO_SPCADV_05002223112018'
;

-- Task
SELECT 
   'Task=>' rpr_cnt
   ,tsk.execution_end        
   ,tsk.* 
FROM 
   dba_advisor_tasks tsk
WHERE 1=1
   --AND tsk.task_name = 'SYS_AUTO_SPCADV_05002223112018'
   AND tsk.description = 'Auto Space Advisor'
ORDER BY
   tsk.execution_end DESC   
;


-- Task - Last execution
SELECT 
   task_id
FROM
(SELECT 
   tsk.task_id
FROM 
   dba_advisor_tasks tsk
WHERE 1=1
   --AND tsk.task_name = 'SYS_AUTO_SPCADV_05002223112018'
   AND tsk.description = 'Auto Space Advisor'
ORDER BY
   tsk.execution_end DESC)
WHERE ROWNUM <= 1
;



SELECT 
   'Recomm=> ' rpr_cnt
--   ,rcm.task_id
--   ,rcm.execution_name
   ,rcm.finding_id
   ,rcm.* 
FROM 
   dba_advisor_recommendations rcm
WHERE 1=1
 --  AND rcm.type = 'Segment Tuning'         
     AND rcm.task_name = 'SYS_AUTO_SPCADV_05002223112018'
     AND rcm.benefit_type LIKE '%shrink%'
;

SELECT 
   fnd.more_info,
   fnd.* 
FROM 
   dba_advisor_findings fnd
WHERE 1=1
--   AND fnd.task_id = 
     AND fnd.task_name = 'SYS_AUTO_SPCADV_05002223112018'
--   AND fnd.execution_name = 'EXEC_44521'
--   AND fnd.message LIKE '%shrink%'
--   AND execution_name IS NOT NULL
   AND fnd.finding_id = 4
;

SELECT * 
FROM 
   dba_advisor_actions act
WHERE 1=1
   AND act.task_name = 'SYS_AUTO_SPCADV_05002223112018'
;

select * from 
   dba_advisor_objects bjt
WHERE 1=1
   AND bjt.task_name = 'SYS_AUTO_SPCADV_05002223112018'
   AND bjt.object_id = 14
;


select 
  *
from 
   dba_autotask_client 
where 1=1
--   client_name='sql tuning advisor'
;

select * from
   DBA_AUTOTASK_JOB_HISTORY t
WHERE 1=1
   and T.CLIENT_NAME = 'auto space advisor'
ORDER BY
   TO_DATE( SUBSTR(job_start_time, 0, 8), 'DD/MM/YY') DESC
;


-- Execution slots
SELECT 
   * 
FROM 
   dba_autotask_window_clients
WHERE 1=1
   AND segment_advisor = 'ENABLED'
   AND TO_DATE( SUBSTR(window_next_time, 0, 8), 'DD/MM/YY') >= TO_DATE('20181128','YYYYMMDD')
;


select * from dba_jobs;

-- Jobs execution detail
SELECT * FROM
   dba_scheduler_job_run_details t
WHERE 1=1
  -- AND task_id = 45371
ORDER BY 
   t.actual_start_date DESC
;



-- Reclaimable space
-- Given a tablespace + table
SELECT  
   rcl_spc.segment_type,
   rcl_spc.segment_owner, 
   rcl_spc.segment_name, 
   rcl_spc.recommendations,
   rcl_spc.used_space
   ,rcl_spc.reclaimable_space
   --ROUND(rcl_spc.used_space / 1024 / 1024 / 1024, 2)        usd_spc_gb,
   --ROUND(rcl_spc.reclaimable_space / 1024 / 1024 / 1024, 2) rcl_spc_gb,
   --,' RCL_SPC =>'
   --rcl_spc.*
FROM 
   TABLE (dbms_space.asa_recommendations ('FALSE', 'FALSE', 'FALSE')) rcl_spc
WHERE 1=1
   AND rcl_spc.tablespace_name =   'FAP_DATA'
   AND rcl_spc.segment_owner   =   'DBOFAP'
   AND rcl_spc.segment_name    =   'TRACE'   
   AND rcl_spc.segment_type    =   'TABLE'
ORDER BY
   rcl_spc.segment_type, 
   rcl_spc.segment_name
;



---------------------------------------------------------------------------
--------------      Old-school                   -------------
---------------------------------------------------------------------------



-- ?

-- Reclaimable space
-- Given a tablespace
SELECT
  segment_owner ,
  segment_name,
  round(allocated_space/1024/1024) ALLOC_MB ,
  round(used_space/1024/1024) USED_MB ,
  round(reclaimable_space/1024/1024) RECLAIM_MB    ,
  (1-ROUND((used_space/allocated_space),2))*100 AS reclaim_pct
   FROM TABLE(dbms_space.asa_recommendations('TRUE', 'TRUE', 'FALSE'))
WHERE 1=1
   --AND --tablespace_name IN ('TS_DATA')
   AND segment_type         = 'TABLE'
   AND segment_owner LIKE '%'
   AND segment_name LIKE '%'
   AND (reclaimable_space >= 1000000
            OR (((1-ROUND((used_space/allocated_space),2))*100)) > 30)
ORDER BY 
   reclaimable_space DESC
;



-- DBA
select owner,table_name,
round((blocks*8),2) "size (kb)", 
round((num_rows*avg_row_len/1024),2) "actual_data (kb)",
(round((blocks*8),2) - round((num_rows*avg_row_len/1024),2)) "wasted_space (kb)"
from 
   dba_tables
where (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 5 desc;



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




-- Reclaimable space
-- Given a tablespace
SELECT
  segment_owner ,
  segment_name,
  round(allocated_space/1024/1024) ALLOC_MB ,
  round(used_space/1024/1024) USED_MB ,
  round(reclaimable_space/1024/1024) RECLAIM_MB    ,
  (1-ROUND((used_space/allocated_space),2))*100 AS reclaim_pct
   FROM TABLE(dbms_space.asa_recommendations('TRUE', 'TRUE', 'FALSE'))
WHERE 1=1
   --AND --tablespace_name IN ('TS_DATA')
   AND segment_type         = 'TABLE'
   AND segment_owner LIKE '%'
   AND segment_name LIKE '%'
   AND (reclaimable_space >= 1000000
            OR (((1-ROUND((used_space/allocated_space),2))*100)) > 30)
ORDER BY 
   reclaimable_space DESC
;
