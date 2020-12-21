-- Change table data
BEGIN;

    SELECT txid_current();
    -- 505

    SELECT DISTINCT virtualtransaction FROM pg_locks WHERE pid = pg_backend_pid();
    -- 6/17

    SELECT * FROM foo INNER JOIN bar b ON f.id = b.id;
    -- AccessShareLock on foo => NOT granted (until T1 validate its transaction)

COMMIT;
ROLLBACK;