-- https://www.postgresql.org/docs/13/sql-lock.html
-- LOCK TABLE obtains a table-level lock, waiting if necessary for any conflicting locks to be released.
-- Once obtained, the lock is held for the remainder of the current transaction.
-- There is no UNLOCK TABLE command; locks are always released at transaction end.
--
-- If NOWAIT is specified, LOCK TABLE does not wait to acquire the desired lock.
-- if it cannot be acquired immediately, the command is aborted and an error is emitted.

DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER UNIQUE);

DROP TABLE IF EXISTS bar;
CREATE TABLE bar (id SERIAL, id_foo INTEGER REFERENCES foo(id));

INSERT INTO foo VALUES (1);
INSERT INTO foo VALUES (2);

INSERT INTO bar(id_foo) VALUES (1);
INSERT INTO bar(id_foo) VALUES (2);

BEGIN TRANSACTION;
INSERT INTO foo VALUES (3);
COMMIT TRANSACTION;
ROLLBACK TRANSACTION;

SELECT * FROM foo;

BEGIN TRANSACTION;

LOCK TABLE foo IN ACCESS EXCLUSIVE MODE;
LOCK TABLE bar IN ACCESS EXCLUSIVE MODE;


-- Table-level lock + Queries
SELECT
      'Lock:'
      ,qry.query
      ,tbl.relname
      ,lck.mode
      ,lck.granted
FROM pg_locks lck
    INNER JOIN pg_class tbl ON tbl.oid = lck.relation
        INNER JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
    INNER JOIN pg_stat_activity qry ON qry.pid = lck.pid
WHERE 1=1
    AND tbl.relkind  = 'r'
    AND tbl.relname  IN ('foo','bar')
;
-- #|?column?|query|relname|mode|granted
-- 1|Lock:|LOCK TABLE bar IN ACCESS EXCLUSIVE MODE;|foo|AccessExclusiveLock|true
-- 2|Lock:|LOCK TABLE bar IN ACCESS EXCLUSIVE MODE;|bar|AccessExclusiveLock|true


ALTER TABLE foo ALTER COLUMN id TYPE BIGINT;
ALTER TABLE bar ALTER COLUMN id_foo TYPE BIGINT;
INSERT INTO foo(id) VALUES((POWER(2,32)/2) + 1 );
INSERT INTO bar(id_foo) VALUES((POWER(2,32)/2) + 1 );

COMMIT TRANSACTION;