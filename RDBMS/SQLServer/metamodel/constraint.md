# Constraints

## Hands-on

```
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
```

## Primary

Constraint
````sql
select
    tbl_cnt.CONSTRAINT_NAME,
    tbl_cnt.TABLE_NAME,
    tbl_cnt.CONSTRAINT_TYPE
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tbl_cnt
WHERE 1=1
--      AND tbl_cnt.TABLE_NAME = 'test'
    AND tbl_cnt.CONSTRAINT_TYPE = 'PRIMARY KEY'
ORDER BY table_name ASC
;
````

Constraint and column
```sql
select 
    t.TABLE_NAME,
    C.COLUMN_NAME 
FROM
INFORMATION_SCHEMA.TABLE_CONSTRAINTS T
    JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C ON C.CONSTRAINT_NAME=T.CONSTRAINT_NAME
WHERE 1=1
--     AND C.TABLE_NAME='Employee'
    AND T.CONSTRAINT_TYPE='PRIMARY KEY'
;
```

PK with more than 1 column
```sql
select 
    t.TABLE_NAME, COUNT(1)
FROM
INFORMATION_SCHEMA.TABLE_CONSTRAINTS T
    JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C ON C.CONSTRAINT_NAME=T.CONSTRAINT_NAME
WHERE 1=1
--     AND C.TABLE_NAME='Employee'
    AND T.CONSTRAINT_TYPE='PRIMARY KEY'
GROUP BY t.TABLE_NAME
HAVING COUNT(1) > 1
ORDER BY COUNT(1) DESC
;
```

## Others
```

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