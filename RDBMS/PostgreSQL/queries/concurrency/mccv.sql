-- Multi-Version Concurrency Control
-- https://www.postgresql.org/docs/current/mvcc.html

CREATE EXTENSION pageinspect;

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER PRIMARY KEY
 );

insert into foo (id) values (1);
insert into foo (id) values (2);

BEGIN TRANSACTION;
-- get transaction ID
SELECT txid_current();
insert into foo (id) values (3);
insert into foo (id) values (4);
insert into foo (id) values (5);

-- https://www.postgresql.org/docs/current/ddl-system-columns.html
-- Transaction identifiers are also 32-bit (4 bytes)
SELECT
  'data=>',
  id,
  'system columns=>', -- hidden
  cmin qry_min, -- query_number_inside_transaction
  cmax qry_max, --
  xmin trn_min, --transaction_number_created_row,
  xmax trn_max, --transaction_number_changed_row
  ctid --physical_location,
FROM foo;

-- Cannot be sorted
--    AND xmax <> 0
--    AND cmin <> 0
--ORDER BY cmin::bigint DESC
;


--  ?column? | id |     ?column?     | qry_min | qry_max | trn_min | trn_max | ctid
-- ----------+----+------------------+---------+---------+---------+---------+-------
--  data=>   |  1 | system columns=> |       0 |       0 |    1470 |       0 | (0,1)
--  data=>   |  2 | system columns=> |       0 |       0 |    1472 |       0 | (0,2)
--  data=>   |  3 | system columns=> |       0 |       0 |    1478 |       0 | (0,3)
--  data=>   |  4 | system columns=> |       1 |       1 |    1478 |       0 | (0,4)
--  data=>   |  5 | system columns=> |       2 |       2 |    1478 |       0 | (0,5)

COMMIT;

-- Show physical location change
UPDATE foo set id = -1 * id;

--  ?column? | id |     ?column?     | qry_min | qry_max | trn_min | trn_max |  ctid
-- ----------+----+------------------+---------+---------+---------+---------+--------
--  data=>   | -1 | system columns=> |       0 |       0 |    1479 |       0 | (0,6)
--  data=>   | -2 | system columns=> |       0 |       0 |    1479 |       0 | (0,7)
--  data=>   | -3 | system columns=> |       0 |       0 |    1479 |       0 | (0,8)
--  data=>   | -4 | system columns=> |       0 |       0 |    1479 |       0 | (0,9)
--  data=>   | -5 | system columns=> |       0 |       0 |    1479 |       0 | (0,10

ALTER TABLE foo ADD COLUMN bar INTEGER DEFAULT 3;


-- Types
SELECT
    pg_typeof(xmin), -- xid
    pg_typeof(xmax), --
    pg_typeof(cmin), -- cid
    pg_typeof(cmax), --
    pg_typeof(ctid)  -- tid
FROM foo
LIMIT 1
;


-- https://habr.com/en/company/postgrespro/blog/477648/

-- Inspect
SELECT * FROM
heap_page_items(get_raw_page('foo',0))
;

SELECT '(0,'||lp||')' AS ctid,
       CASE lp_flags
         WHEN 0 THEN 'unused'
         WHEN 1 THEN 'normal'
         WHEN 2 THEN 'redirect to '||lp_off
         WHEN 3 THEN 'dead'
       END AS state,
       t_xmin as xmin,
       t_xmax as xmax,
       (t_infomask & 256) > 0  AS xmin_commited,
       (t_infomask & 512) > 0  AS xmin_aborted,
       (t_infomask & 1024) > 0 AS xmax_commited,
       (t_infomask & 2048) > 0 AS xmax_aborted,
       t_ctid
FROM heap_page_items(get_raw_page('foo',0))
WHERE 1=1
-- AND t_xmax <> 0 -- not yet visible
;

