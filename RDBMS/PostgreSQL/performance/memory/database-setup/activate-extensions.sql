CREATE EXTENSION pg_buffercache;

CREATE FUNCTION buffercache(rel regclass)
    RETURNS TABLE(
                     bufferid integer, relfork text, relblk bigint,
                     isdirty boolean, usagecount smallint, pins integer
                 ) AS $$
SELECT bufferid,
       CASE relforknumber
           WHEN 0 THEN 'main'
           WHEN 1 THEN 'fsm'
           WHEN 2 THEN 'vm'
           END,
       relblocknumber,
       isdirty,
       usagecount,
       pinning_backends
FROM pg_buffercache
WHERE relfilenode = pg_relation_filenode(rel)
ORDER BY relforknumber, relblocknumber;
$$ LANGUAGE sql;

GRANT EXECUTE ON FUNCTION buffercache() TO jane;
GRANT SELECT ON buffercache TO jane;

GRANT EXECUTE ON FUNCTION pg_buffercache_pages() TO jane;
GRANT SELECT ON pg_buffercache TO jane;

-- CREATE EXTENSION pg_prewarm;
-- ALTER SYSTEM SET shared_preload_libraries = 'pg_prewarm';

-- GRANT EXECUTE ON FUNCTION pg_log_backend_memory_contexts() TO jane;
-- ERROR:  function pg_log_backend_memory_contexts() does not exist

--  \df pg_log_backend_memory_contexts

-- List of functions
--    Schema   |              Name              | Result data type | Argument data types | Type
-- ------------+--------------------------------+------------------+---------------------+------
--  pg_catalog | pg_log_backend_memory_contexts | boolean          | integer             | func
--
-- thinking...

