SELECT *
FROM pg_locks
;

select pid;

-- Get ungranted locks
DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER UNIQUE);

-- Client 1
BEGIN; LOCK TABLE foo IN ACCESS EXCLUSIVE MODE;

-- Client 2
BEGIN; LOCK TABLE foo IN ACCESS EXCLUSIVE MODE;

-- Ungranted locks
SELECT
  pid, relation::regclass, lck.locktype, lck.mode, lck.waitstart started_from,
  ( current_timestamp - lck.waitstart) waiting_since,
lck.*
FROM pg_locks lck
WHERE 1=1
  AND NOT granted
  --AND lck.waitstart > current_timestamp - interval '30 second'
  --AND lck.waitstart > current_timestamp - interval '1 hour'
;

-- Ungranted locks + session
SELECT
   lck.pid session_id
  ,lck.relation::regclass
  ,lck.locktype
  ,lck.mode
  ,lck.waitstart started_from
  ,substring(ssn.query from 1 for 30) query
  ,ssn.wait_event_type
FROM pg_locks lck
  INNER JOIN pg_stat_activity ssn ON ssn.pid = lck.pid
WHERE 1=1
  AND NOT granted
  --AND lck.waitstart > current_timestamp - interval '30 second'
  --AND lck.waitstart > current_timestamp - interval '1 hour'
;


-- Lock
SELECT
       sch.nspname,
       tbl.relname,
       tbl.relkind,
       lck.mode,
       lck.granted,
       lck.pid
      ,'pg_locks=>'
      ,lck.*
FROM pg_locks lck
    INNER JOIN pg_class tbl ON tbl.oid = lck.relation
        INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
WHERE 1=1
    --AND tbl.relkind  = 'r'
    --AND lck.locktype = 'relation'
    AND sch.nspname  = 'public'
;


-- Table-level lock
SELECT
       lck.virtualtransaction,
       sch.nspname,
       tbl.relname,
       lck.mode,
       lck.pid,
       lck.granted
      ,'pg_locks=>'
      ,lck.*
FROM pg_locks lck
    INNER JOIN pg_class tbl ON tbl.oid = lck.relation
        INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
WHERE 1=1
    AND tbl.relkind  = 'r'
    AND lck.locktype = 'relation'
    AND sch.nspname  = 'public'
ORDER BY
         lck.virtualtransaction
;



-- Table-level lock + Queries
SELECT
      'Lock:'
      ,qry.query
      ,tbl.relname
      --,qry.client_addr
      ,lck.virtualtransaction
      ,lck.mode
      ,lck.granted
      ,tbl.relname tbl_nm
      ,'pg_locks=>'
      ,lck.*
      ,'pg_stat_activity=>'
      ,qry.*
FROM pg_locks lck
    INNER JOIN pg_class tbl ON tbl.oid = lck.relation
        INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
    INNER JOIN pg_stat_activity qry ON qry.pid = lck.pid
WHERE 1=1
    AND tbl.relkind  = 'r'
    AND lck.locktype = 'relation'
    AND sch.nspname  = 'public'
    AND tbl.relname  = 'knowledge-elements'
;

-- Table-level lock + Queries (KISS)
SELECT
      'Lock:'
      ,SUBSTRING(qry.query FROM 1 for 10)
      ,lck.mode
      ,lck.granted
      ,tbl.relname tbl_nm
FROM pg_locks lck
    INNER JOIN pg_class tbl ON tbl.oid = lck.relation
        INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
    INNER JOIN pg_stat_activity qry ON qry.pid = lck.pid
WHERE 1=1
    AND tbl.relkind  = 'r'
    AND lck.locktype = 'relation'
    AND sch.nspname  = 'public'
    AND tbl.relname  = 'users'
;



-- Row-level lock
SELECT
       lck.virtualtransaction,
       sch.nspname,
       tbl.relname,
       lck.mode,
       lck.pid,
       lck.granted
      ,'pg_locks=>'
      ,lck.*
FROM pg_locks lck
    INNER JOIN pg_class tbl ON tbl.oid = lck.relation
        INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
WHERE 1=1
    AND tbl.relkind  = 'r'
    AND lck.locktype = 'tuple'
    AND sch.nspname  = 'public'
ORDER BY
         lck.virtualtransaction
;


-- Blocking

SELECT
   'blocked=>',
   blocked_locks.pid         AS pid,
--          blocked_activity.usename  AS user,
--          blocked_activity.client_addr AS blocked_IP,
   blocked_activity.query    AS statement,
   blocked_locks.mode        AS type,
  'blocking=>',
   blocking_locks.pid        AS pid,
--          blocking_activity.usename AS user,
--          blocking_activity.client_addr AS blocking_IP,
   blocking_activity.query   AS current_statement_in_blocking_process,
   blocking_locks.mode       AS type
FROM
   pg_catalog.pg_locks         blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks         blocking_locks
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE 1=1
   AND NOT blocked_locks.granted;
