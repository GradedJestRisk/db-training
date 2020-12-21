DROP TABLE IF EXISTS foo;
DROP TABLE IF EXISTS bar;

CREATE TABLE foo (id SERIAL);
INSERT INTO foo DEFAULT VALUES;
SELECT * FROM foo;
INSERT INTO foo VALUES (2);

CREATE TABLE bar (id SERIAL);
INSERT INTO bar DEFAULT VALUES;
SELECT * FROM bar;

SHOW default_transaction_isolation;
-- read committed

-- Transaction id
SELECT txid_current();
-- 1

SELECT txid_current();
-- 2

BEGIN;
SELECT txid_current();
-- 3
BEGIN;
--there is already a transaction in progress
SELECT txid_current();
-- 3




-- Change table data
-- Check values in another transaction
BEGIN;

SELECT txid_current();

INSERT INTO foo VALUES (3);
INSERT INTO foo VALUES (4);

COMMIT;
ROLLBACK;


-- Change table structure
BEGIN;

SELECT txid_current();
ALTER TABLE foo ADD COLUMN label TEXT;

SELECT 'Now, in another transaction, execute SELECT * FROM foo INNER JOIN bar b ON f.id = b.id;';
ALTER TABLE bar ADD COLUMN label TEXT;
-- No deadlock !

COMMIT;
ROLLBACK;



-- Change table structure (deadlock)
BEGIN;

SELECT txid_current();

ALTER TABLE foo ADD COLUMN label TEXT;
SELECT 'Now, in another transaction, execute LOCK TABLE bar IN ACCESS SHARE MODE';

ALTER TABLE bar ADD COLUMN label TEXT;
SELECT 'Now, in another transaction, execute LOCK TABLE foo IN ACCESS SHARE MODE';

-- In the other transaction, you get the following error
-- ERROR:  deadlock detected
-- DETAIL:  Process 678 waits for AccessShareLock on relation 29009 of database 13442; blocked by process 673.
-- Process 673 waits for AccessExclusiveLock on relation 29015 of database 13442; blocked by process 678.

ROLLBACK;
COMMIT;


postgres=# LOCK TABLE bar IN ACCESS SHARE MODE;
LOCK TABLE
postgres=# SELECT txid_current();
 txid_current
--------------
        22645
(1 row)

postgres=# LOCK TABLE foo IN ACCESS SHARE MODE;
