# Session

## Session identifier

Session id (`SID`), not to be confused with Site identifier (connecstring.)
[Audit session identifier AUDSID and Session identifier - SID](https://mwidlake.wordpress.com/2010/06/17/what-is-audsid/)

### Another session

Get session identifiers
```oracle
SELECT sid, audsid
FROM V$SESSION
WHERE 1=1
    AND CLIENT_IDENTIFIER = 'profiling'
```

### This session

Get session identifier (SID)
```oracle
SELECT distinct sid FROM v$mystat;
```

Get session identifier (AUDSID)
```oracle
SELECT sys_context('userenv','sessionid') AS audsid FROM dual;
select userenv('SESSIONID') AS audsid from dual;
```

## Session

### All 

But oracle
```oracle
SELECT 
    'session:'
    ,ssn.sid
    ,ssn.logon_time started_at
    ,ssn.username
    ,ssn.program
    ,ssn.client_info
    ,ssn.status   
    ,ssn.state       
   --,ssn.action        
   ,ssn.event

   ,ssn.wait_time      --wtn_tm
   ,ssn.wait_class     --wtn_cls
   ,ssn.sql_id
   ,'v$session=>'
   ,ssn.*
FROM 
   v$session   ssn
WHERE 1=1
  -- AND ssn.sid IN (1165,1152,23)
--    AND ssn.username   =  'DBOFAP'
   AND ssn.osuser   <>  'oracle'
  -- AND ssn.status     =   'ACTIVE'
--    AND ssn.program    LIKE    'sqlplus%'
  -- AND ssn.client_info IS NULL
ORDER BY
   ssn.sid
;
```

### Active
```oracle
SELECT 
    'session:'
    ,ssn.sid
    ,ssn.logon_time started_at
    ,ssn.username
    ,ssn.program
    ,ssn.client_info
    ,ssn.status   
    ,ssn.state       
   --,ssn.action        
   ,ssn.event
   ,ssn.sql_id
   ,'wait:'
   ,ssn.wait_time      --wtn_tm
   ,ssn.wait_class     --wtn_cls

   ,'v$session=>'
   ,ssn.*
FROM 
   v$session   ssn
WHERE 1=1
  -- AND ssn.sid IN (1165,1152,23)
--    AND ssn.username   =  'DBOFAP'
   AND ssn.osuser   <>  'oracle'
   AND ssn.status     =   'ACTIVE'
--    AND ssn.program    LIKE    'sqlplus%'
  -- AND ssn.client_info IS NULL
ORDER BY
   ssn.sid
;
```

### client identifier, information, module

Set
```oracle

CALL dbms_session.set_identifier('profiling');
SELECT sys_context('USERENV','CLIENT_IDENTIFIER') FROM dual;

CALL dbms_application_info.set_client_info('some client info');

CALL dbms_application_info.set_module (
        module_name => 'queries', 
        action_name => 'session-identify-step1');

CALL dbms_application_info.set_action (
        action_name => 'session-identify-step2'); 
```

Get
```oracle
SELECT 
    'session:'
    ,ssn.sid
    ,ssn.SERIAL#
    ,ssn.logon_time started_at
    ,ssn.username
    ,ssn.program
    ,'identify=>'
    ,ssn.client_identifier
    ,ssn.client_info
    ,ssn.module
    ,ssn.action
    ,'state=>'
    ,ssn.status   
    ,ssn.state       
    ,ssn.event
    ,ssn.wait_time      --wtn_tm
    ,ssn.wait_class     --wtn_cls
    ,'v$session=>'
    ,ssn.*
FROM 
   v$session   ssn
WHERE 1=1
  -- AND ssn.sid IN (1165,1152,23)
   AND ssn.osuser   <>  'oracle'
   AND ssn.status     =   'ACTIVE'
   --AND ssn.client_identifier = 'parsing'
--    AND ssn.client_identifier LIKE 'parsing-%'
--   AND ssn.program    LIKE    'sqlplus%'
ORDER BY
   ssn.sid
;
```
Kill as administrator
```oracle
-- ALTER SYSTEM KILL SESSION '<sid, serial#>'
ALTER SYSTEM KILL SESSION '22, 18210';
```

## Wait

Get wait time (distribution) for session
```oracle
SELECT wait_class,
       round(time_waited, 3) AS time_waited,
       round(1E2 * ratio_to_report(time_waited) OVER (), 1) AS "%"
FROM (
  SELECT sid, wait_class, time_waited / 1E2 AS time_waited
  FROM v$session_wait_class
  WHERE total_waits > 0
  UNION ALL
  SELECT sid, 'CPU', value / 1E6
  FROM v$sess_time_model
  WHERE stat_name = 'DB CPU'
)
WHERE sid = 31
ORDER BY 2 DESC;
```


## Session + Query


For username
```oracle
select ssn.sid,
       ssn.sql_id,
       qry.sql_text
       --,ssn.*
FROM v$sqltext qry
    INNER JOIN v$session ssn 
        ON  ssn.sql_hash_value = qry.hash_value AND ssn.sql_address = qry.address
WHERE 1=1
  AND ssn.username = 'USERNAME'
--   AND ssn.id = 
ORDER BY ssn.sid, qry.piece;
```

For session id
```oracle
select ssn.sid,
       ssn.sql_id,
       qry.sql_text
       --,ssn.*
FROM v$sqltext qry
    INNER JOIN v$session ssn 
        ON  ssn.sql_hash_value = qry.hash_value AND ssn.sql_address = qry.address
WHERE 1=1
  AND ssn.username = 'USERNAME'
  AND ssn.sid = 44 
ORDER BY ssn.sid, qry.piece;
```

For client_identifier
```oracle
select ssn.sid,
       ssn.sql_id,
       qry.sql_text
       --,ssn.*
FROM v$sqltext qry
    INNER JOIN v$session ssn 
        ON  ssn.sql_hash_value = qry.hash_value AND ssn.sql_address = qry.address
WHERE 1=1
  --AND ssn.client_info LIKE 'parsing-%'
  AND ssn.program    LIKE    'sqlplus%'
--   AND ssn.id = 
ORDER BY ssn.sid, qry.piece;
```

## Session history (ASH)