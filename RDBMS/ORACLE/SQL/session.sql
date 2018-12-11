-------------------------------
---------- Session parameter -------
-------------------------------

-- Parameter
SELECT 
   name, 
   value
FROM 
   v$parameter sss_prm
WHERE 1=1
   AND sss_prm.name = LOWER('nls_date_format')
;


-- NLS
ALTER SESSION SET nls_date_format = 'DD/MM/YY HH24:MI:SS';

-- NLS
SELECT 
   name, 
   value
FROM 
   v$parameter sss_prm
WHERE 1=1
   AND sss_prm.name = LOWER('nls_date_format')
;

-- Statistics for execution plan
SELECT 
   name, 
   value
FROM 
   v$parameter sss_prm
WHERE 1=1
   AND sss_prm.name = LOWER('statistics_level')
;

ALTER SESSION SET statistics_level = 'TYPICAL';
ALTER SESSION SET statistics_level = 'ALL';


-- Dumps
SELECT 
   name, 
   value
FROM 
   v$parameter sss_prm
WHERE 1=1
   AND sss_prm.name = LOWER('USER_DUMP_DEST')
;


ALTER SYSTEM SET user_dump_dest = '/product/FAP/tmp/sqltrace'  SCOPE=BOTH;

-- SQL Trace
SELECT 
   name, 
   value
FROM 
   v$parameter sss_prm
WHERE 1=1
   AND sss_prm.name = UPPER('SQL_TRACE')
;

ALTER SESSION SET sql_trace = TRUE;




-------------------------------
---------- Session -------
-------------------------------

-- wait_class : 
-- User I/O => wait on disk operations performed directly

-- All sessions
SELECT 
   *
FROM 
   v$session   sss
WHERE 1=1
--   AND sss.sid = 866
--   AND serial# = 38573
;


-- Session 
-- Given username
SELECT    
    sss.logon_time
   ,sss.program   
   ,sss.sid
   ,sss.serial#
   --,sss.username       --tls_dtf
  -- ,sss.osuser
   --,sss.program
   --,sss.client_info
   --,sss.action         --sss_act
   ,sss.event
   ,sss.status         --sss_tt
   ,sss.state          --ctn_tt
   ,sss.wait_time      --wtn_tm
   ,sss.wait_class     --wtn_cls
   ,sss.sql_id
   ,'V$SESSION=>'
   ,sss.*
FROM 
   v$session   sss
WHERE 1=1
   AND TRUNC(sss.logon_time) = TRUNC(SYSDATE)
  -- AND sss.sid IN (1165,1152,23)
--   AND sss.username   =  'DBOFAP'
--   AND sss.osuser     =  'fap'
   --AND sss.status     =   'ACTIVE'
--   AND sss.program    LIKE    'sqlplus%'
--   AND sss.program    NOT LIKE 'oracle%'         -- System
--   AND sss.program    <>    'plsqldev.exe'       -- PL/SQL Developper
--   AND sss.program    <>    'SQL Developer'      -- SQL Developper
--   AND sss.program    <>    'JDBC Thin Client'   -- ??  
   --AND sss.client_info IS NULL    --NOT LIKE '%PKG_TAR2%'
ORDER BY
   sss.logon_time ASC
;

-- ?
SELECT 
   *
--   MIN(sample_time),
--   MAX(sample_time)
FROM
   v$active_session_history
WHERE session_id = 866 
   AND session_serial# = 38573
   AND sql_id = '9atcf48r9w0sv'
;

select *--sid, seq#, EVENT,  WAIT_CLASS,  SECONDS_IN_WAIT 
from v$session_wait 
where sid=866
;


-- Hash
SELECT 
   DECODE (sss.sql_hash_value, 0, sss.prev_hash_value, sss.sql_hash_value)  hash, 
   DECODE (sss.sql_id, NULL, sss.prev_sql_id, sss.sql_id)                   sql_id
FROM
   v$session sss
WHERE 1=1
   AND   sss.sid = 308
;



---------------------------------------------------------------------------
--------------      Active session                   -------------
---------------------------------------------------------------------------

-- Session active (hors debug et requ�te courante)
-- Pour utilisateur / nom
SELECT 
   'Verrou => '        rqt_cnt
   ,sss.sid            sss_dtf
   ,sss.username       tls_dtf
   ,sss.status         sss_tt
   ,sss.action         sss_act
   ,sss.state          ctn_tt
   ,sss.wait_class     ctn_bjt
   ,sss.*
  -- ,sss.sid ||  ' '  || sss.username ||  ' '  || sss.status ||  ' '  || sss.action ||  ' '  || sss.state  || ' '  || sss.wait_class  
FROM 
   v$session   sss
WHERE 1=1
   --AND sss.username   =   'PTOP'
   --AND sss.osuser   =   'lgrimonpont'
   AND sss.status     =   'ACTIVE'
   AND sss.action     NOT LIKE   'Debug%' 
--   AND  sss.action     NOT LIKE   '%session%'
;

-- KILL session
ALTER SYSTEM KILL SESSION 'sid,serial#';
ALTER SYSTEM KILL SESSION '1166,14875';

-- Hash
SELECT 
   DECODE (sss.sql_hash_value, 0, sss.prev_hash_value, sss.sql_hash_value)  hash, 
   DECODE (sss.sql_id, NULL, sss.prev_sql_id, sss.sql_id)                   sql_id
FROM
   v$session sss
WHERE 1=1
   AND   sss.sid = 308
;

-- Execution plan
SELECT 
   t.plan_table_output xct_plan
FROM 
   v$session   sss,
   gv$sql v,
   TABLE(
         DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', 
                             NULL, 
                             'ADVANCED ALLSTATS LAST', 
                             'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number) ) t
WHERE 1=1
   AND TRUNC(sss.logon_time) = TRUNC(SYSDATE)
   --AND sss.username      =  'DBOFAP'
 --  AND sss.osuser      =  'fap'
   AND sss.status        =   'ACTIVE'
   --AND sss.program       LIKE    'sqlplus%'
   --AND sss.client_info IS NOT NULL
   AND v.sql_id          = sss.sql_id
   ;

