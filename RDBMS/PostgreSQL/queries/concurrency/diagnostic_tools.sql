-- https://momjian.us/main/writings/pgsql/locking.pdf

DROP VIEW IF EXISTS lockview1;
DROP VIEW IF EXISTS lockview2;
DROP VIEW IF EXISTS lockview;

CREATE VIEW lockview AS
SELECT
     pid, virtualtransaction AS vxid, locktype AS lock_type,
     mode AS lock_mode, granted,
    CASE
        WHEN virtualxid IS NOT NULL AND transactionid IS NOT NULL
        THEN virtualxid || ' ' || transactionid
        WHEN virtualxid::text IS NOT NULL
        THEN virtualxid
        ELSE transactionid::text
    END AS xid_lock, relname,
    page, tuple, classid, objid, objsubid
FROM
     pg_locks
         LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)
WHERE 1=1
    -- do not show our view’s locks
    AND  pid != pg_backend_pid()
    -- no need to show self-vxid locks
    AND virtualtransaction IS DISTINCT FROM virtualxid
ORDER BY
    -- granted is ordered earlier
    1, 2, 5 DESC, 6, 3, 4, 7;

SELECT relname, *
FROM
     pg_locks
         LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)
;

SELECT * FROM lockview;

CREATE VIEW lockview1 AS
SELECT
       pid, vxid, lock_type, lock_mode,
    granted, xid_lock, relname
FROM lockview
ORDER BY
-- granted is ordered earlier
         1, 2, 5 DESC, 6, 3, 4, 7;


SELECT * FROM lockview1;

CREATE VIEW lockview2 AS
SELECT
       pid, vxid, lock_type, page,
    tuple, classid, objid, objsubid
FROM lockview
ORDER BY
    -- granted is first
    1, 2, granted DESC,
    -- add non-display columns to match ordering of lockview
    vxid, xid_lock::text, 3, 4, 5, 6, 7, 8
;

SELECT * FROM lockview2;

CREATE TABLE lockdemo (col int);
INSERT INTO lockdemo VALUES (1);

SELECT * FROM lockview;
SELECT * FROM lockview1;
SELECT * FROM lockview2;