-- A
-- Session / By status
--active: executing a query.
--idle: waiting for a new client command.
--idle in transaction: The backend is in a transaction, but is not currently executing a query.

SELECT
  ssn.state,
  COUNT(1)
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.backend_type = 'client backend'
GROUP BY ssn.state
;




-- If there is some active session, are they long running ?
-- Session / Active
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,SUBSTRING(ssn.query from 1 for 30) query
  ,TO_CHAR(ssn.query_start,'HH24:MI:SS') query_started_at
  ,TO_CHAR(NOW() - ssn.query_start,'HH24:MI:SS') query_duration
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.pid = 12768
  AND ssn.backend_type = 'client backend'
  AND ssn.state = 'active'
  AND ssn.wait_event IS NULL
  AND pid <> pg_backend_pid() -- Not me
;


-- If there is some waiting session, check for what

-- https://www.postgresql.org/docs/current/monitoring-stats.html#WAIT-EVENT-ACTIVITY-TABLE
-- Session / Waiting
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,SUBSTRING(ssn.query from 1 for 30) query
  ,TO_CHAR(ssn.query_start,'HH24:MI:SS') query_started_at
  ,TO_CHAR(NOW() - ssn.query_start,'HH24:MI:SS') query_duration
  ,ssn.wait_event
  ,ssn.wait_event_type
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.pid = 12768
  AND ssn.backend_type = 'client backend'
  AND ssn.state = 'active'
  AND ssn.wait_event IS NOT NULL
  AND ssn.wait_event_type NOT IN ('IO')
  AND ssn.wait_event_type IN ('Lock', 'LWLock')
  AND pid <> pg_backend_pid() -- Not me
;

