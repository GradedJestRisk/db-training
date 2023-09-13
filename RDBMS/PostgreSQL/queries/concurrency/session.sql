--https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW

-- Session (short)
SELECT
   'session=>'
  ,ssn.pid     session_id
--  ,ssn.query
  ,substring(ssn.query from 1 for 30) query
  ,ssn.wait_event_type
  ,ssn.state
--    ,'pg_stat_activity=>' ,ssn.*
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.pid = 12768
  AND ssn.backend_type = 'client backend'
  --AND ssn.state = 'active'
  --AND ssn.wait_event IS NOT NULL
--  AND ssn.query ILIKE '%VALUES%'
  --AND pid <> pg_backend_pid() -- Not me
;

-- Session
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,ssn.usename user_name
  ,ssn.datname database_name
  ,ssn.client_port
  ,ssn.pid -- in database, not on client
  ,ssn.query
  ,substring(ssn.query from 1 for 14)
  ,ssn.state
  --,'pg_stat_activity=>' ,ssn.*
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.state = 'active'

--  AND ssn.query ILIKE '%VALUES%'
  --AND pid <> pg_backend_pid() -- Not me
;


-- Session / By status
SELECT
  ssn.state,
  COUNT(1)
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.backend_type = 'client backend'
GROUP BY ssn.state
;



-- Session / Active
SELECT
   'session=>'
  ,ssn.pid     session_id
--  ,ssn.query
  ,substring(ssn.query from 1 for 30) query
  ,ssn.wait_event_type
  ,ssn.state
--    ,'pg_stat_activity=>' ,ssn.*
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.pid = 12768
  AND ssn.backend_type = 'client backend'
  --AND ssn.state = 'active'
  --AND ssn.wait_event IS NOT NULL
--  AND ssn.query ILIKE '%VALUES%'
  --AND pid <> pg_backend_pid() -- Not me
;


-- My session
SELECT pg_backend_pid()
;

-- Server timeout (millis)
SHOW statement_timeout;
-- 0
-- Set 10 seconds
SET statement_timeout = 10000;
-- Wait 15s
SELECT pg_sleep(15);
SET statement_timeout = 10000;
-- [57014] ERROR: canceling statement due to statement timeout


-- Idle connection timeout (millis)
SHOW idle_in_transaction_session_timeout;


-- Client messages
-- https://www.postgresql.org/docs/9.2/runtime-config-client.html

-- Default
SHOW client_min_messages;
-- INFO

SELECT * from pg_database;
-- [2021-08-22 11:37:58] 5 rows retrieved starting from 1 in 54 ms (execution: 5 ms, fetching: 49 ms)

SET client_min_messages = DEBUG5;
SELECT * from pg_database;
-- [2021-08-22 11:37:10] [00000] parse <unnamed>: SELECT * from pg_database
-- [2021-08-22 11:37:10] [00000] StartTransaction(1) name: unnamed; blockState: DEFAULT; state: INPROGRESS, xid/subid/cid: 0/1/0
-- [2021-08-22 11:37:10] [00000] bind <unnamed> to <unnamed>
-- [2021-08-22 11:37:10] [00000] CommitTransaction(1) name: unnamed; blockState: STARTED; state: INPROGRESS, xid/subid/cid: 0/1/0
-- [2021-08-22 11:37:10] 5 rows retrieved starting from 1 in 108 ms (execution: 18 ms, fetching: 90 ms)

SET client_min_messages = INFO;


-- Read-only transaction
-- https://www.postgresql.org/docs/9.2/runtime-config-client.html
CREATE TABLE foo (id INTEGER);

SHOW default_transaction_read_only;
-- off

INSERT INTO foo (id) VALUES (1);
-- [2021-08-22 11:45:57] 1 row affected in 4 ms

SET default_transaction_read_only = ON;

INSERT INTO foo (id) VALUES (1);
-- [25006] ERROR: cannot execute INSERT in a read-only transaction

SET default_transaction_read_only = OFF;

INSERT INTO foo (id) VALUES (1);
-- [2021-08-22 11:45:57] 1 row affected in 4 ms





-- Session
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,ssn.usename user_name
  ,ssn.datname database_name
  ,ssn.client_port
  ,ssn.pid -- in database, not on client
  ,ssn.query
  ,substring(ssn.query from 1 for 14)
  ,ssn.state
--  ,'pg_stat_activity=>' ,ssn.*
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.usename = 'pix_api_prod_4785'
  AND ssn.datname = 'pix_api_prod_4785'
  AND ssn.state = 'active'
--  AND ssn.query ILIKE '%VALUES%'
  AND pid <> pg_backend_pid()
;


-- Session
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,ssn.usename user_name
  ,ssn.datname database_name
  ,ssn.client_port
  ,ssn.pid -- in database, not on client
  ,ssn.query

  ,ssn.state
  ,'pg_stat_activity=>'
  --,ssn.*
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.usename = 'activity'
--  AND ssn.datname = 'database'
  AND ssn.state = 'active'
--  AND ssn.query ILIKE '%VALUES%'
   AND pid <> pg_backend_pid() -- exclude this very quert
    --AND ssn.query = 'CREATE UNIQUE INDEX ndx_pk_foo ON foo(id)'
ORDER BY
    backend_start DESC
;


-- Terminate all sessions on database, but me
-- Given database name
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE 1=1
  AND datname = 'database'
  AND pid <> pg_backend_pid() -- Not me
LIMIT 1
;
