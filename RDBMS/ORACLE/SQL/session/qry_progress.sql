-- Monitor info (including queries not in v$sql)
SELECT 
   'Monitoring info=>'                          qry_cnt
   ,t.sql_exec_start                            start_time
   ,t.status                                    stt  
   ,t.sid
   ,t.session_serial#                           session_dtf
   ,t.sql_id                                    qry_dtf   
   ,t.sql_text                                  qry_txt
   ,t.sql_plan_hash_value                       xct_dtf
   --
   ,'Duration (min) =>'                               p1
   ,ROUND(t.elapsed_time          / 1000000 / 60, 1)  total
--   ,ROUND(t.plsql_exec_time / 1000000 / 60, 1)    pl_duration_min
   ,ROUND(t.cpu_time              / 1000000 / 60, 1)  cpu
   ,ROUND(t.user_io_wait_time     / 1000000 / 60, 1)  io
   ,ROUND(t.concurrency_wait_time / 1000000 / 60, 1)  conc --concurrency
   ,'IO (gb) =>'                                       p2
   ,ROUND(t.physical_read_bytes  / 1024 / 1024 / 1024, 1)  read
   ,ROUND(t.physical_write_bytes / 1024 / 1024 / 1024, 1)  write
   ,'V$SQLMONITOR=> '
   ,t.* 
FROM  
   v$sql_monitor t
WHERE 1=1
 --  AND t.sid = 1166
 --  AND t.session_serial# = 15047
--   AND t.SQL_TEXT LIKE '%PKG_FAP_PE_EXP_FAP.MAIN%'
   AND t.username        NOT IN ('SYS')
   AND t.sql_text        IS NOT NULL
   AND t.plsql_exec_time IS NOT NULL
   AND t.status          NOT IN ('DONE', 'DONE (FIRST N ROWS)', 'DONE (ALL ROWS)', 'DONE (ERROR)')
ORDER BY
   t.elapsed_time DESC
;


-- Monitor info (including queries not in v$sql)
-- For sid
SELECT 
   'Monitoring info=>'                          qry_cnt
   ,TO_CHAR(t.sql_exec_start, 'HH24:MI')        start_
   ,t.status                                    stt  
  ,' Query=> '                                    p0
   ,t.sql_id                                    dtf   
   ,t.sql_text                                  txt
   ,t.sql_plan_hash_value                       xct_pln_dtf
   --
   ,' Duration (min) => '                               p1
   ,ROUND(t.elapsed_time          / 1000000 / 60, 1)  total
--   ,ROUND(t.plsql_exec_time / 1000000 / 60, 1)    pl_duration_min
   ,ROUND(t.cpu_time              / 1000000 / 60, 1)  cpu
   ,ROUND(t.user_io_wait_time     / 1000000 / 60, 1)  io
   ,ROUND(t.concurrency_wait_time / 1000000 / 60, 1)  conc --concurrency
   ,' IO (gb) => '                                       p2
   ,ROUND(t.physical_read_bytes  / 1024 / 1024 / 1024, 1)  read
   ,ROUND(t.physical_write_bytes / 1024 / 1024 / 1024, 1)  write
 --  ,'V$SQLMONITOR=> '
 --  ,t.* 
FROM  
   v$sql_monitor t
WHERE 1=1
   AND t.sid             = 1166
   AND t.session_serial# = 15047
ORDER BY
   t.status       DESC
   ,t.elapsed_time DESC
;


select * from v$active_session_history;