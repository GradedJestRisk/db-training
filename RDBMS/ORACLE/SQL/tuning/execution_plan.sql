---------------------------------------------------------------------------
--------------     History                    -------------
---------------------------------------------------------------------------

-- Execution plan historic
-- For query / id
SELECT 
    DISTINCT 
   'Exec plan histo=> '     qry_cnt
   ,xp_hst.sql_id           qry_id  
   ,xp_hst.plan_hash_value  xp_id
   ,xp_hst.timestamp        exec_date
--   ,'XPH=>'
--   ,xp_hst.*
FROM 
   dba_hist_sql_plan xp_hst
WHERE 1=1
   AND xp_hst.sql_id = '8fdpq6vt69qpp'
ORDER BY
   xp_hst.timestamp DESC
; 


-- Execution plan historic
-- For query / id + execution plan / id 
SELECT 
   'Exec plan histo=> '     qry_cnt
   ,xp_hst.sql_id           qry_id  
   ,xp_hst.plan_hash_value  xp_id
   ,xp_hst.timestamp        exec_date
   ,'XPH=>'
   ,xp_hst.*
FROM 
   dba_hist_sql_plan xp_hst
WHERE 1=1
   AND xp_hst.sql_id          =   'c4phfzzkjpsw8'
   AND xp_hst.plan_hash_value =   '1863236027'
ORDER BY
   xp_hst.timestamp DESC
; 

-- Execution plan historic - Explain plan
-- For query / id + execution plan / id 
SELECT 
   --SYSDATE   timestamp,   
   operation,    options,    object_node,    object_owner,    object_name,
   0 object_instance,    optimizer,    search_columns,    id,    parent_id,     position,    cost,
   cardinality,   bytes,   other_tag,   partition_start,   partition_stop,   partition_id,   other,
   distribution,   cpu_cost,  io_cost,   temp_space,   access_predicates,   filter_predicates
FROM 
   dba_hist_sql_plan xp_hst
WHERE 1=1
   AND xp_hst.sql_id          = 'c4phfzzkjpsw8'
   AND xp_hst.plan_hash_value = '1863236027'
; 

---------------------------------------------------------------------------
--------------      Last execution plan                    -------------
---------------------------------------------------------------------------

   
-- Last execution plan
-- For query  / id  
SELECT 
   'XP' qry_cnt
   ,xp.plan_hash_value xp_dtf   
   ,'XP=>'    
   ,xp.*
FROM 
   v$sql_plan xp 
WHERE 1=1
--   AND xp.plan_hash_value = 1863236027
   AND xp.sql_id = 'c4phfzzkjpsw8'
;

-- Last execution plan (Old-school)
-- For query  / id  
SELECT
  -- rawtohex(address) || '_' || child_number statement_id,
   -- SYSDATE   timestamp,   
   operation,    options,    object_node,    object_owner,    object_name,
   0 object_instance,    optimizer,    search_columns,    id,    parent_id,     position,    cost,
   cardinality,   bytes,   other_tag,   partition_start,   partition_stop,   partition_id,   other,
   distribution,   cpu_cost,  io_cost,   temp_space,   access_predicates,   filter_predicates
FROM
   v$sql_plan xp
WHERE 1=1
   AND xp.sql_id = 'c4phfzzkjpsw8'
;



-- Classic execution
SELECT 
   plan_table_output 
FROM 
   TABLE(dbms_xplan.display_cursor('c4phfzzkjpsw8'));

-- Parralel execution
SELECT 
   RPAD('Inst: ' || v.inst_id, 9 )|| ' ' || RPAD('Child: ' || v.child_number, 11) inst_child, 
   t.plan_table_output
FROM 
   gv$sql v,
   TABLE(
         DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', 
                             NULL, 
                             'ADVANCED ALLSTATS LAST', 
                             'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number) ) t
WHERE 1=1
   AND v.sql_id = 'bd2v111bbvvfd'
;


--Monitoring Usage
SELECT 
   /*+ gather_plan_statistics */ 
   COUNT(*)  
FROM  
   soh_dev.sx3_gaccentry  p, 
   soh_dev.sx3_gaccentryd d,  
   soh_dev.sx3_gaccentrya a 
WHERE  1=1
   AND p.NUM_0 = a.NUM_0 
   AND d.NUM_0 = a.NUM_0 
   AND p.NUM_0= d.NUM_0
;

 
SELECT 
   /*+ gather_plan_statistics */ 
   COUNT(1) 
FROM 
   filiere
;
-- ????

SELECT * FROM 
   TABLE(dbms_xplan.display_cursor( NULL, NULL, 'ADVANCED LAST +IOSTATS +MEMSTATS'))
;

--real-time-sql-monitoring
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SELECT 
   DBMS_SQLTUNE.report_sql_monitor(
     sql_id       => '97nkvz29a24nr',
     type         => 'TEXT',
     report_level => 'ALL') AS report
FROM dual;


---------------------------------------------------------------------------
--------------     Tell optimizer to gather statistics                    -------------
---------------------------------------------------------------------------

ALTER SESSION SET statistics_level = ALL;
SELECT * FROM TRONCON ORDER BY id_trc DESC;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +IOSTATS +MEMSTATS'));

/*
E = Estimated 
A = Actual


SQL_ID  5mft9d8kmrj8y, child number 1
-------------------------------------
SELECT * FROM TRONCON
 
Plan hash value: 3036419563
 
----------------------------------------------------------------------------------------------------
| Id  | Operation            | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |          |      0 |        |      0 |00:00:00.01 |       0 |      0 |
|   1 |  PX COORDINATOR      |          |      0 |        |      0 |00:00:00.01 |       0 |      0 |
|   2 |   PX SEND QC (RANDOM)| :TQ10000 |      0 |    292M|      0 |00:00:00.01 |       0 |      0 |
|   3 |    PX BLOCK ITERATOR |          |      1 |    292M|    250 |00:00:00.01 |       5 |     62 |
|*  4 |     TABLE ACCESS FULL| TRONCON  |      1 |    292M|    250 |00:00:00.01 |       5 |     62 |
----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access(:Z>=:Z AND :Z<=:Z)
 
Note
-----
   - automatic DOP: Computed Degree of Parallelism is 8 because of degree limit
 
 */


   