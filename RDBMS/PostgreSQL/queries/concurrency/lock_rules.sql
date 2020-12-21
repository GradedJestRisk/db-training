-- https://momjian.us/main/writings/pgsql/locking.pdf

-- https://www.postgresql.org/docs/current/explicit-locking.html

-------------------

Levels:
- table
- row
- page

-------------------

Table level

From less (cause no conflict except the higest lock) to more restrictive (cause conflict with all other lock)
- ACCESS SHARE (SELECT)
- ROW SHARE
- ROW EXCLUSIVE
- SHARE UPDATE EXCLUSIVE
- SHARE
- SHARE ROW EXCLUSIVE
- EXCLUSIVE
- ACCESS EXCLUSIVE (ALTER TABLE ADD COLUMN)

- ACCESS SHARE
Acquired by: SELECT
Conflicts with: ACCESS EXCLUSIVE

- ROW SHARE
Acquired by: SELECT FOR UPDATE / SELECT FOR SHARE
Conflicts with: EXCLUSIVE, ACCESS EXCLUSIVE

- ROW EXCLUSIVE
Acquired by: UPDATE, DELETE, and INSERT
Conflicts:  SHARE, SHARE ROW EXCLUSIVE, EXCLUSIVE, ACCESS EXCLUSIVE

- SHARE UPDATE EXCLUSIVE
Acquired by: VACUUM (without FULL), ANALYZE, CREATE INDEX CONCURRENTLY, REINDEX CONCURRENTLY, CREATE STATISTICS, and certain ALTER INDEX and ALTER TABLE
Conflicts: SHARE UPDATE EXCLUSIVE, SHARE, SHARE ROW EXCLUSIVE, EXCLUSIVE, ACCESS EXCLUSIVE

- SHARE
Acquired by : CREATE INDEX (without CONCURRENTLY).
Conflicts with: ROW EXCLUSIVE, SHARE UPDATE EXCLUSIVE, SHARE ROW EXCLUSIVE, EXCLUSIVE, ACCESS EXCLUSIVE lock modes

- SHARE ROW EXCLUSIVE
Acquired by: REATE TRIGGER and certain ALTER TABLE
Conflicts with: ROW EXCLUSIVE, SHARE UPDATE EXCLUSIVE, SHARE, SHARE ROW EXCLUSIVE, EXCLUSIVE, ACCESS EXCLUSIVE

- EXCLUSIVE
Acquired by REFRESH MATERIALIZED VIEW CONCURRENTLY.
Conflicts with: ROW SHARE, ROW EXCLUSIVE, SHARE UPDATE EXCLUSIVE, SHARE, SHARE ROW EXCLUSIVE, EXCLUSIVE, ACCESS EXCLUSIVE

- ACCESS EXCLUSIVE
Acquired by the DROP TABLE, TRUNCATE, REINDEX, CLUSTER, VACUUM FULL, and REFRESH MATERIALIZED VIEW (without CONCURRENTLY) and certain ALTER INDEX and ALTER TABLE
This mode guarantees that the holder is the only transaction accessing the table in any way.
Conflicts with: all locks  (ACCESS SHARE, ROW SHARE, ROW EXCLUSIVE, SHARE UPDATE EXCLUSIVE, SHARE, SHARE ROW EXCLUSIVE, EXCLUSIVE, ACCESS EXCLUSIVE)


-------------------

Row-level locks
Note that
- a transaction can hold conflicting locks on the same row
- two transactions can never hold conflicting locks on the same row.

Row-level locks do not affect data querying; they block only writers and lockers to the same row.
Row-level locks are released at transaction end or during savepoint rollback, just like table-level locks.


From less (cause no conflict except the higest lock) to more restrictive (cause conflict with all other lock)

FOR KEY SHARE

FOR SHARE

FOR NO KEY UPDATE

FOR UPDATE
Will block: UPDATE, DELETE, SELECT FOR UPDATE, SELECT FOR SHARE or SELECT FOR KEY SHARE


---------------
 ALTER TABLE
---------------
An ACCESS EXCLUSIVE lock is acquired unless explicitly noted
ADD COLUMN

---------------
SELECT *
---------------

CREATE TABLE foo (id SERIAL);
INSERT INTO foo DEFAULT VALUES;
SELECT * FROM foo;
INSERT INTO foo VALUES (2);

CREATE TABLE bar (id SERIAL);
INSERT INTO bar DEFAULT VALUES;
SELECT * FROM bar;


BEGIN;
SELECT * FROM foo; => AccessShareLock
LOCK TABLE foo IN ACCESS SHARE MODE;




---------------
SELECT * FOR UPDATE
---------------
BEGIN;
LOCK TABLE foo IN ACCESS SHARE MODE;
SELECT * FROM foo FOR UPDATE; => AccessShareLock
