

select 
   sid,
   serial#,
   opname,
   target,
   elapsed_seconds,
   message
from 
   v$session_longops
WHERE 1=1
   and username <> 'SYS'
   and opname <> 'Gather Table''s Index Statistics'
   and opname <> 'Gather Table Partition Statistics'
--   AND sid =
--   AND serial = #
   order by 
      elapsed_seconds DESC
;




select 
   sss.sql_exec_start,
   sss.sid,
   sss.serial#,
   sss.module,
   sss.client_info,
   --sss.*,
   opname,
   target,
   trunc(elapsed_seconds / 60) duree_min,
   message
from 
   v$session_longops lng,
   v$session   sss
WHERE 1=1
   AND to_char(sss.SQL_EXEC_START, 'YYYYMMDD') = '20181029'
   and lng.username <> 'SYS'
   and lng.opname <> 'Gather Table''s Index Statistics'
   and lng.opname <> 'Gather Table Partition Statistics'
   AND lng.sid = sss.sid
   AND lng.serial# = sss.serial#
ORDER BY 
      elapsed_seconds DESC
;

select 
   opname, 
   TRUNC(SUM(elapsed_seconds) / 60) min
from v$session_longops
WHERE 1=1
and username <> 'SYS'
and opname <> 'Gather Table''s Index Statistics'
and opname <> 'Gather Table Partition Statistics'
GROUP BY
   opname
ORDER BY 
   SUM(elapsed_seconds) DESC
;

select 
   target,
   TRUNC(SUM(elapsed_seconds) / 60) min,   
from 
   v$session_longops
WHERE 1=1
   and username <> 'SYS'
   and opname = 'Rowid Range Scan'
GROUP BY
   target
ORDER BY 
   SUM(elapsed_seconds) DESC
;

