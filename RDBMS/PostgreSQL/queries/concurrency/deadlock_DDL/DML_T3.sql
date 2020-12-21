-- Change table data
BEGIN;

    SELECT txid_current();
    -- 504

    SELECT DISTINCT virtualtransaction FROM pg_locks WHERE pid = pg_backend_pid();
    -- 7/17

    SELECT * FROM bar INNER JOIN foo b ON f.id = b.id;
    -- AccessShareLock on bar => granted
    -- AccessShareLock on foo => NOT granted (until T1 validate its transaction)

COMMIT;
ROLLBACK;