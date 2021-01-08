-- Change table data
BEGIN;

    SELECT txid_current();
    -- 504

    SELECT DISTINCT virtualtransaction FROM pg_locks WHERE pid = pg_backend_pid();
    -- 7/17

    INSERT INTO to_foo (id_foo) VALUES (2);
    -- RowShareLock     on foo    => granted
    -- RowExclusiveLock on to_foo => granted

COMMIT;
ROLLBACK;