-- Change table structure
BEGIN;

    SELECT txid_current();
    -- 497

    SELECT DISTINCT virtualtransaction FROM pg_locks WHERE pid = pg_backend_pid();
    -- 5/8

    ALTER TABLE foo ADD COLUMN label TEXT;
    -- AccessExclusiveLock on foo => granted

    -- Execute any of DML_T2.sql / DML_T3.sql

    ALTER TABLE bar ADD COLUMN label TEXT;
    -- [40P01] ERROR: deadlock detected Detail: Process 55 waits for AccessExclusiveLock on relation 16393 of database 16384; blocked by process 62.
    -- Process 62 waits for AccessShareLock on relation 16387 of database 16384; blocked by process 55.
    -- Hint: See server log for query details.

COMMIT;
ROLLBACK;