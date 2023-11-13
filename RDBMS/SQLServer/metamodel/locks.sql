--  Locks type
-- https://www.sqlpassion.at/archive/2016/05/16/why-do-we-need-intent-locks-in-sql-server/

-- https://www.sqlpassion.at/archive/2016/10/31/disabling-row-and-page-level-locks-in-sql-server/
-- allow_row_locks = OFF, allow_page_locks = OFF

DROP TABLE test;

CREATE TABLE test
(
  id   INT NOT NULL,
  name      CHAR(10)
);
INSERT INTO test VALUES (1, 'foo')
;

SELECT * FROM test
;
create index testIndex
    on test ()
    with (allow_row_locks = OFF, allow_page_locks = OFF)
;