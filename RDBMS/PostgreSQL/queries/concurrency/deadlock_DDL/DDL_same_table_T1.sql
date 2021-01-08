-- Change table structure
BEGIN;

    SELECT txid_current();
    -- 497

    SELECT DISTINCT virtualtransaction FROM pg_locks WHERE pid = pg_backend_pid();
    -- 5/8

    ALTER TABLE foo ADD COLUMN label TEXT;
    -- AccessExclusiveLock on foo => granted

    -- Execute DML_T4.sql
    ALTER TABLE to_foo ADD COLUMN label TEXT;
    -- [40P01] ERROR: deadlock detected Detail: Process 150 waits for AccessExclusiveLock on relation 17877 of database 13442; blocked by process 127.
    -- Process 127 waits for RowShareLock on relation 17830 of database 13442; blocked by process 150. Hint: See server log for query details.

COMMIT;
ROLLBACK;