---------------------------------------------------------------------------
--------------    Create profiler tables                -------------
---------------------------------------------------------------------------

-- Transfert proftab to server

-- Execute 
-- sqlplus / @proftab.sql


---------------------------------------------------------------------------
--------------  Grant access on profiler table to FAP                    -------------
---------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE ON dbofap.PLSQL_PROFILER_DATA TO fap;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbofap.PLSQL_PROFILER_RUNS TO fap;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbofap.PLSQL_PROFILER_UNITS TO fap;

CREATE OR REPLACE SYNONYM fap.PLSQL_PROFILER_DATA FOR dbofap.PLSQL_PROFILER_DATA;
CREATE OR REPLACE SYNONYM fap.PLSQL_PROFILER_RUNS FOR dbofap.PLSQL_PROFILER_RUNS;
CREATE OR REPLACE SYNONYM fap.PLSQL_PROFILER_UNITS FOR dbofap.PLSQL_PROFILER_UNITS;



---------------------------------------------------------------------------
--------------      Profiler queries                     -------------
---------------------------------------------------------------------------

-- Run
SELECT 
   runid,
   run_date,
   run_comment,
    run_total_time
FROM   
   plsql_profiler_runs
ORDER BY 
   runid
;


-- Execution details
-- For a run
SELECT 
   u.runid,
   u.unit_number,
   u.unit_type,
   u.unit_owner,
   u.unit_name,
   d.line#,
   d.total_occur,
   d.total_time,
   d.min_time,
    d.max_time
FROM   
   plsql_profiler_units u
       JOIN plsql_profiler_data d ON u.runid = d.runid AND u.unit_number = d.unit_number
WHERE  1=1
   AND   u.runid   =   1
ORDER BY 
   u.unit_number, 
   d.line#
;

-- Time per units
-- For a run
SELECT 
   u.runid,
   u.unit_number,
   u.unit_type,
   u.unit_owner,
   u.unit_name,
   d.line#,
   d.total_occur,
   d.total_time,
   d.min_time,
    d.max_time
FROM   
   plsql_profiler_units u
       JOIN plsql_profiler_data d ON u.runid = d.runid AND u.unit_number = d.unit_number
WHERE  
   u.runid = 1
ORDER BY 
   u.unit_number, 
   d.line#
;



-- Line count
-- For a run
SELECT 
 COUNT(1)
FROM   
   plsql_profiler_units u
       JOIN plsql_profiler_data d ON u.runid = d.runid AND u.unit_number = d.unit_number
WHERE  
   u.runid = 1
ORDER BY 
   u.unit_number, 
   d.line#
;

-- Total time
SELECT 
   TRUNC(SUM(d.total_time)  / 1000000000 / 60) tps_max_min
FROM   
   plsql_profiler_units u
       JOIN plsql_profiler_data d ON u.runid = d.runid AND u.unit_number = d.unit_number
WHERE  
   u.runid = 1
;


-- Trace
-- Aujourd'hui
SELECT
    'Trace =>'      rqt_cnt    
    ,trc.dt           dt
    ,SUBSTR(trc.info, 1, INSTR(trc.info, ']', 2)) composant
    ,trc.info         info
    ,trc.lvl          niveau
    ,' - '
    ,trc.*
FROM
    trace trc
WHERE 1=1
   AND TRUNC(trc.dt) = TRUNC(SYSDATE)
   AND trc.dt    >=    TO_DATE('20180808-14:40','YYYYMMDD-HH24:MI')
   AND trc.info  LIKE  '%MAIN_GEN_FILIERE%'
ORDER BY
   trc.dt ASC
;  



-- Time per units + Source
-- Per max elapsed time 
-- For a run
SELECT 
   u.runid,
   u.unit_number,
   u.unit_type,
   u.unit_owner,
   u.unit_name,
   d.line#,
   d.total_occur,
   d.total_time              total_time_ns,
   d.total_time / 1000000000 time_s,
   d.min_time,
   d.max_time,
   src.text
FROM   
   plsql_profiler_units u
       JOIN plsql_profiler_data d ON u.runid = d.runid AND u.unit_number = d.unit_number
       JOIN all_source          src ON src.type = u.unit_type AND src.name = u.unit_name AND src.line = d.line#       
WHERE  1=1
   AND   u.runid = 1
--   AND   d.line# = 1740 
   AND   src.owner = 'DBOFAP'   
ORDER BY 
   d.total_time DESC
;


SELECT 
   line,
   text,
   aso.*
FROM
   all_source aso
WHERE 1=1
   AND   owner IN ('FAP','DBOFAP')
   AND   type  = 'PACKAGE BODY'
   AND   name  = 'PKG_GEN_FILIERE'
   AND   line = 1740
;

-- Time per units + Source
-- Per max total occur
-- For a run
SELECT 
   u.runid,
   u.unit_number,
   u.unit_type,
   u.unit_owner,
   u.unit_name,
   d.line#,
   d.total_occur,
   d.total_time              total_time_ns,
   d.total_time / 1000000000 time_s,
   d.min_time,
   d.max_time,
   src.text
FROM   
   plsql_profiler_units u
       JOIN plsql_profiler_data d ON u.runid = d.runid AND u.unit_number = d.unit_number
       JOIN all_source          src ON src.type = u.unit_type AND src.name = u.unit_name AND src.line = d.line#       
WHERE  1=1
   AND   u.runid = 1
--   AND   d.line# = 1740 
   AND   src.owner = 'DBOFAP'   
ORDER BY 
   d.total_occur DESC
;







