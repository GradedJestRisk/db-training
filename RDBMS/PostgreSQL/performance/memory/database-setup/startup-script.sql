CREATE EXTENSION pg_buffercache;
GRANT EXECUTE ON FUNCTION pg_buffercache_pages() TO jane;
GRANT SELECT ON pg_buffercache TO jane;

CREATE EXTENSION pg_prewarm;
ALTER SYSTEM SET shared_preload_libraries = 'pg_prewarm';

GRANT EXECUTE ON FUNCTION pg_log_backend_memory_contexts() TO jane;
-- ERROR:  function pg_log_backend_memory_contexts() does not exist

--  \df pg_log_backend_memory_contexts

-- List of functions
--    Schema   |              Name              | Result data type | Argument data types | Type
-- ------------+--------------------------------+------------------+---------------------+------
--  pg_catalog | pg_log_backend_memory_contexts | boolean          | integer             | func
--
-- thinking...
