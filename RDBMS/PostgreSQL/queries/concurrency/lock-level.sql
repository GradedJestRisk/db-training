-- https://medium.com/compass-true-north/postgresql-lessons-we-learned-the-hard-way-663ddf666e4
-- Lock by idle query

-- Log locks
-- https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-LOCK-WAITS


-- https://www.postgresql.org/docs/13/sql-lock.html
-- LOCK TABLE obtains a table-level lock, waiting if necessary for any conflicting locks to be released.
-- Once obtained, the lock is held for the remainder of the current transaction.
-- There is no UNLOCK TABLE command; locks are always released at transaction end.
--
-- If NOWAIT is specified, LOCK TABLE does not wait to acquire the desired lock.
-- if it cannot be acquired immediately, the command is aborted and an error is emitted.

--https://medium.com/@clairesimmonds/postgresql-decoding-deadlocks-183e6a792fd3

DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER UNIQUE);

DROP TABLE IF EXISTS bar;
CREATE TABLE bar (id SERIAL, id_foo INTEGER REFERENCES foo(id));

INSERT INTO foo VALUES (1);
INSERT INTO foo VALUES (2);

INSERT INTO bar(id_foo) VALUES (1);
INSERT INTO bar(id_foo) VALUES (2);

-- Client 1
BEGIN TRANSACTION;
INSERT INTO foo VALUES (3);
-- Go to Client 2
INSERT INTO bar(id_foo) VALUES (2);
COMMIT TRANSACTION;
ROLLBACK TRANSACTION;

SELECT * FROM foo;

-- Client 2
BEGIN TRANSACTION;
INSERT INTO bar(id_foo) VALUES (1);
-- Go to client 1
INSERT INTO foo VALUES (4);
COMMIT TRANSACTION;
ROLLBACK TRANSACTION;


-- Explicit lock
LOCK TABLE foo IN ACCESS EXCLUSIVE MODE;
LOCK TABLE bar IN ACCESS EXCLUSIVE MODE;


-- Table-level lock + Queries
SELECT
      'Lock=>'
      ,qry.pid "queryId"
      ,qry.query "query"
      ,tbl.relname "tableName"
      ,lck.mode "level"
      ,lck.granted "lockAcquired"
FROM pg_locks lck
    INNER JOIN pg_class tbl ON tbl.oid = lck.relation
        INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
    INNER JOIN pg_stat_activity qry ON qry.pid = lck.pid
WHERE 1=1
    AND tbl.relkind  = 'r'
    AND tbl.relname  IN ('foo','bar')
ORDER BY qry.query, tbl.relname, lck.mode
;
-- #|?column?|query|relname|mode|granted
-- 1|Lock:|LOCK TABLE bar IN ACCESS EXCLUSIVE MODE;|foo|AccessExclusiveLock|true
-- 2|Lock:|LOCK TABLE bar IN ACCESS EXCLUSIVE MODE;|bar|AccessExclusiveLock|true


-- Deadlock


-- Client 1
BEGIN TRANSACTION;
ALTER TABLE foo ADD COLUMN comment TEXT;
-- Go to Client 2
INSERT INTO bar(id_foo) VALUES (2);
COMMIT TRANSACTION;
ROLLBACK TRANSACTION;

SELECT * FROM foo;

-- Client 2
BEGIN TRANSACTION;
ALTER TABLE bar ADD COLUMN code TEXT;
-- Go to client 1
INSERT INTO foo VALUES (4);
COMMIT TRANSACTION;
ROLLBACK TRANSACTION;


-- Explicit lock
LOCK TABLE foo IN ACCESS EXCLUSIVE MODE;
LOCK TABLE bar IN ACCESS EXCLUSIVE MODE;
