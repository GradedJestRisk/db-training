SELECT name, value/1024/1024/1024 SGA_GB FROM v$sga;


select 
   t.NAME,
   t.BYTES / 1024 / 1024 size_gb
from v$sgainfo t;