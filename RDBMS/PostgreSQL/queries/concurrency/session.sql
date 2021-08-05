
-- My session
SELECT pg_backend_pid()
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
  ,'pg_stat_activity=>'
  ,ssn.*
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.usename = 'activity'
--  AND ssn.datname = 'database'
--  AND ssn.query ILIKE '%VALUES%'
--   AND pid <> pg_backend_pid()
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