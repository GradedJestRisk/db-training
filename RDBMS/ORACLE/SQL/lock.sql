

-------------------------------
---------- Verrou -------
-------------------------------

-- Verrou PL/SQL Developper
select l.*, o.owner object_owner, o.object_Name
from  sys.all_objects o, v$lock l
where 1=1
--and l.sid = 288-- Session ID
and l.type = 'TM' and o.object_id = l.id1
ANd object_Name = 'TRONCON'
;



-- Verrou
-- Pour utilisateur / nom
SELECT 
   'Verrou => '        rqt_cnt
    ,bjt.owner                bjr_prp
    ,bjt.object_name          bjt_nm
    ,TRUNC(vrr.ctime/60)      vrr_tmps_min  
    ,DECODE (vrr.lmode, 2, 'Partag�', 3, 'Exclusif', vrr.lmode) vrr_md
   -- ,vrr.*
FROM
   sys.all_objects   bjt,
   v$lock            vrr
WHERE  1=1
 --  AND   vrr.sid         =   306
  -- AND   vrr.lmode       =    vrr.id1
   AND   vrr.type        =   'TM'      -- Sur table
 --  AND   vrr.lmode       =   3         -- Exclusif
   AND   bjt.object_id   =    vrr.id1
;


-- Verrou
-- Pour utilisateur / nom
SELECT 
   'Verrou => '        rqt_cnt
     ,sss.sid                 sss_dtf
     ,sss.osuser
     ,sss.program
     ,sss.client_info
--     ,sss.*
    ,bjt.owner                bjr_prp
    ,bjt.object_name          bjt_nm
    ,TRUNC(vrr.ctime/60)      vrr_tmps_min  
    ,DECODE (vrr.lmode, 2, 'Partag�', 3, 'Exclusif', vrr.lmode) vrr_md
    --,vrr.*
FROM
   v$session         sss,   
   sys.all_objects   bjt,
   v$lock            vrr
WHERE  1=1
   --AND   sss.username    =   'PTOP'
   AND   vrr.sid         =   sss.sid
   AND   vrr.type        =   'TM'      -- Sur table
   --AND   vrr.lmode       =   3         -- Exclusif
   AND   bjt.object_id   =    vrr.id1
ORDER BY
   sss.osuser, 
   bjt.object_name
;


-- Verrou partag�
-- Pour utilisateur / nom
SELECT 
   'Verrou => '        rqt_cnt
     ,sss.sid                 sss_dtf
    ,bjt.owner                bjr_prp
    ,bjt.object_name          bjt_nm
    ,TRUNC(vrr.ctime/60)      vrr_tmps_min  
    ,DECODE (vrr.lmode, 2, 'Partag�', 3, 'Exclusif', vrr.lmode) vrr_md
    ,vrr.*
FROM
   v$session         sss,   
   sys.all_objects   bjt,
   v$lock            vrr
WHERE  1=1
   AND   sss.username    =   'PTOP'
   AND   vrr.sid         =   sss.sid
   AND   vrr.type        =   'TM'      -- Sur table
   AND   vrr.lmode       =    2        -- Partag�
   AND   bjt.object_id   =    vrr.id1
;


---------------------------------------------------------------------------
--------------      Exclusif                  -------------
---------------------------------------------------------------------------


-- Verrou exclusif
-- Pour tous
SELECT 
   'Verrou exclusif=> '        rqt_cnt
   ,sss.sid            sss_dtf
   ,sss.username       tls_dtf
   ,sss.osuser         tls_os
   ,sss.status         sss_tt
   ,sss.action         sss_jbt
   ,bjt.owner                bjr_prp
   ,bjt.object_name          bjt_nm
   ,TRUNC(vrr.ctime/60)      vrr_tmps_min  
   ,DECODE (vrr.lmode, 2, 'Partag�', 3, 'Exclusif', vrr.lmode) vrr_md
  -- ,vrr.*
FROM
   v$session         sss,   
   sys.all_objects   bjt,
   v$lock            vrr
WHERE  1=1
   --AND   sss.username    =   'PTOP'
   AND   vrr.sid         =   sss.sid
   AND   vrr.type        =   'TM'      -- Sur table
   AND   vrr.lmode       =    3        -- Exclusif
   AND   bjt.object_id   =    vrr.id1
ORDER BY
   sss.USERNAME ASC
;


-- Verrou exclusif
-- Pour utilisateur / nom
SELECT 
   'Verrou exclusif => '        rqt_cnt
   ,sss.sid            sss_dtf
   ,sss.username       sch_nm
   ,sss.osuser         tls_dtf
   ,SUBSTR(sss.program, 1, 10)        prg_nm
   ,sss.status         sss_tt
   ,SUBSTR(sss.action, 1, 20)         sss_jbt
   ,SUBSTR(sss.client_info, 1, 20)    sss_action
--   ,sss.*
   ,bjt.owner                bjr_prp
   ,bjt.object_name          bjt_nm
   ,TRUNC(vrr.ctime/60)      vrr_tmps_min  
   ,DECODE (vrr.lmode, 2, 'Partagé', 3, 'Exclusif', vrr.lmode) vrr_md
  -- ,vrr.*
FROM
   v$session         sss,   
   sys.all_objects   bjt,
   v$lock            vrr
WHERE  1=1
   --AND   sss.username    =   'PTOP'
   AND   vrr.sid         =   sss.sid
   AND   vrr.type        =   'TM'      -- Sur table
   AND   vrr.lmode       =    3        -- Exclusif
   AND   bjt.object_id   =    vrr.id1
ORDER BY
   sss.username ASC,
   sss.action
;

-- Verrou mutuel
SELECT 
   'Verrou mutuel => '        rqt_cnt
   ,'Bloquant  => '    
   ,s1.username
   ,s1.machine
   ,s1.osuser
   ,s1.program
   ,s1.module
   ,s1.action
   ,s1.sid
   ,'Bloqu�  => '    
   ,s2.username
   ,s2.machine
   ,s2.osuser
   ,s2.sid
FROM   
   v$lock    l1,
   v$session s1,
   v$lock    l2,
   v$session s2
WHERE  1=1
   AND   s1.sid      =   l1.sid
   AND   s2.sid      =   l2.sid
   AND   l1.block    =   1
   AND   l2.request  >   0
   AND   l1.id1      =   l2.id1
   AND   l2.id2      =   l2.id2
; 

---------------------------------------------------------------------------
--------------      DBA                   -------------
---------------------------------------------------------------------------

SELECT 
   DECODE(request,0,'Holder: ','Waiter: ')||sid sess, 
   id1, 
   id2, 
   lmode, 
   request, 
   type
FROM 
   v$lock
WHERE (id1, id2, type) IN
      (SELECT id1, id2, type FROM V$LOCK WHERE request>0)
ORDER BY 
   id1, 
   request
;

SELECT S.SID "SID", 
       S.SERIAL# "SER", 
       O.OBJECT_NAME "TABLE", 
       O.OWNER, 
       S.OSUSER "OS USER", 
       S.MACHINE "NODE", 
       S.TERMINAL "TERMINAL", 
       DECODE (S.LOCKWAIT, NULL, 'DETIENT LE(S) LOCK(S)', 'BLOQUEE PAR LA SESSION <' || B.SID || '>') "MODE", 
       SUBSTR (C.SQL_TEXT, 1, 150) "SQL TEXT" 
FROM V$LOCK L, 
     V$LOCK D, 
     V$SESSION S, 
     V$SESSION B, 
     V$PROCESS P, 
     V$TRANSACTION T, 
     SYS.DBA_OBJECTS O, 
     V$OPEN_CURSOR C 
WHERE L.SID = S.SID 
AND O.OBJECT_ID (+) = L.ID1 
AND C.HASH_VALUE (+) = S.SQL_HASH_VALUE 
AND C.ADDRESS (+) = S.SQL_ADDRESS 
AND S.PADDR = P.ADDR 
AND D.KADDR (+) = S.LOCKWAIT 
AND D.ID2 = T.XIDSQN (+) 
AND B.TADDR (+) = T.ADDR 
AND L.TYPE ='TM'
GROUP BY O.OBJECT_NAME, 
         O.OWNER, 
         S.OSUSER, 
         S.MACHINE, 
         S.TERMINAL, 
         P.SPID, 
         S.PROCESS, 
         S.SID, 
         S.SERIAL#, 
         DECODE (S.LOCKWAIT, NULL, 'DETIENT LE(S) LOCK(S)', 'BLOQUEE PAR LA SESSION <' || B.SID || '>'), 
         SUBSTR (C.SQL_TEXT, 1, 150) 
ORDER BY DECODE (S.LOCKWAIT, NULL, 'DETIENT LE(S) LOCK(S)', 'BLOQUEE PAR LA SESSION <' || B.SID || '>') DESC, 
         O.OBJECT_NAME ASC, 
         S.SID ASC;