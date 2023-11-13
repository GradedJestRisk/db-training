DROP TABLE test;

CREATE TABLE test
(
  id   INT NOT NULL PRIMARY KEY ,
  name VARCHAR(50) NULL
);

select * from test
;

INSERT INTO test (name) VALUES ('joe')
;

-- Primary  + Foreign key
select
    tbl_cnt.CONSTRAINT_NAME,
    tbl_cnt.TABLE_NAME,
    tbl_cnt.CONSTRAINT_TYPE
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tbl_cnt
WHERE 1=1
--      AND tbl_cnt.TABLE_NAME = 'test'
--    AND tbl_cnt.CONSTRAINT_TYPE = 'PRIMARY KEY'
--      AND tbl_cnt.CONSTRAINT_TYPE = 'FOREIGN KEY'
    -- AND tbl_cnt.CONSTRAINT_TYPE = 'CHECK'
ORDER BY table_name ASC
;

-- NULL constraint
SELECT  *
FROM information_schema.columns
WHERE 1=1
    AND table_schema = 'dbo'
--     AND table_name = 'test'
     AND table_name = 'T_UTILISATEURS'
    AND is_nullable = 'NO'
;

-- UNIQUE constraint
select
    tbl_cnt.CONSTRAINT_NAME,
    tbl_cnt.TABLE_NAME,
    tbl_cnt.CONSTRAINT_TYPE
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tbl_cnt
WHERE 1=1
--      AND tbl_cnt.TABLE_NAME = 'test'
    AND tbl_cnt.CONSTRAINT_TYPE = 'UNIQUE'
ORDER BY table_name ASC
;

-- CHECK constraint
select
    tbl_cnt.CONSTRAINT_NAME,
    tbl_cnt.TABLE_NAME,
    tbl_cnt.CONSTRAINT_TYPE
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tbl_cnt
WHERE 1=1
--      AND tbl_cnt.TABLE_NAME = 'test'
    AND tbl_cnt.CONSTRAINT_TYPE = 'CHECK'
ORDER BY table_name ASC
;