-- My PID
SELECT pg_backend_pid();

SELECT virtualtransaction AS vxid,
       transactionid::text
FROM pg_locks
WHERE pid = pg_backend_pid();

SELECT id backend_id
FROM pg_stat_get_backend_idset() AS t(id)
WHERE pg_stat_get_backend_pid(id) = pg_backend_pid();

-- Queries in progress
SELECT
    qry.pid,
    qry.query,
    qry.wait_event,
    qry.wait_event_type,
    qry.state
--        qry.*
FROM
     pg_stat_activity qry
WHERE 1=1
--   AND query != '<IDLE>'
  -- AND query ILIKE '%sleep%'
   AND qry.pid = 25797
ORDER BY
         query_start DESC;


-- kill running query
SELECT pg_cancel_backend(<PID>);
SELECT pg_terminate_backend(<PID>);

SELECt current_setting('max_connections');
SELECt current_setting('superuser_reserved_connections');
SELECt current_setting('lock_timeout');
SELECt current_setting('transaction_read_only');
SELECt current_setting('statement_timeout');
SELECt current_setting('idle_in_transaction_session_timeout');
SELECt current_setting('idle_session_timeout');