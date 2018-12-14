

-- free space real-time..
SELECT 
   gb(free_space) 
FROM 
   dba_temp_free_space
;


-- Session active (hors debug et requ�te courante)
-- Pour utilisateur / nom
SELECT 
    sss.logon_time
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
  ,sss.*
FROM 
   v$session   sss
WHERE 1=1
  -- AND sss.sid IN (1165,1152,23)
   AND sss.username   =  'DBOFAP'
   AND sss.osuser     =  'fap'
  -- AND sss.status     =   'ACTIVE'
   AND sss.program    LIKE    'sqlplus%'
  -- AND sss.client_info IS NULL
   --NOT LIKE '%PKG_TAR2%'
ORDER BY
   sss.client_info
;