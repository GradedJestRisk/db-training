--
SELECT pg_backend_pid();

SELECT virtualtransaction AS vxid,
       transactionid::text
FROM pg_locks
WHERE pid = pg_backend_pid();

SELECT id backend_id
FROM pg_stat_get_backend_idset() AS t(id)
WHERE pg_stat_get_backend_pid(id) = pg_backend_pid();


SELECT
       pid,
       --age(clock_timestamp(), query_start) duration,
       query_start,
       usename usr,
       query   qry,
       state,
       wait_event, -- if relation, table may be locked...
       qry.*
FROM
     pg_stat_activity qry
WHERE 1=1
  AND query != '<IDLE>'
  AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY
         query_start DESC;


-- kill running query
SELECT pg_cancel_backend(<PID>);