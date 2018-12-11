SELECT
   t.used_ublk, 
   gb(t.used_ublk), 
   t.*
FROM  
   v$transaction t
;

select  
   s.sid,s.serial#,
   username,
   s.machine,
   t.used_ublk ,
   t.used_urec,
   rn.name,
    ROUND((t.used_ublk *8)/1024/1024, 2) SizeGB 
from    
   v$transaction  t,
   v$session      s,
   v$rollstat     rs, 
   v$rollname     rn
where 1=1
   AND t.addr     =  s.taddr 
   AND rs.usn     =  rn.usn 
   AND rs.usn     =  t.xidusn 
   AND rs.xacts   >  0
;
