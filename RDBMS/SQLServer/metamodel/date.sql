-- https://www.red-gate.com/simple-talk/databases/sql-server/learn/when-use-char-varchar-varcharmax/
DROP TABLE test;

CREATE TABLE test
(
  id   INT NOT NULL PRIMARY KEY ,
  creation date,
  modification  datetime
);

select * from test
;




SELECT
    tbl.name tbl
    ,clm.name clm_nm
    ,clm.column_id clm_dtf
    ,typ.name typ
    ,clm.max_length as size
    ,'columns=>'
    ,clm.*
FROM sys.columns clm
    INNER JOIN sys.tables tbl ON clm.object_id = tbl.object_id
    INNER JOIN sys.types typ ON typ.system_type_id = clm.system_type_id
WHERE 1=1
--    AND tbl.schema_id = 1
--    AND clm.is_identity = 'true'
   --  AND tbl.name = 'test'
--     AND clm.name  = 'name'
--      AND typ.name  IN ( 'datetime', 'date')
     AND typ.name  IN (  'datetime')
--      AND typ.name  IN (  'date')
--     AND clm.max_length > 100
ORDER BY clm.max_length DESC
;

-- VARCHAR(N) - Best bet
SELECT
    tbl.name tbl
    ,clm.name clm_nm
    ,clm.column_id clm_dtf
    ,typ.name typ
    ,clm.max_length as size
    ,'columns=>'
    ,clm.*
FROM sys.columns clm
    INNER JOIN sys.tables tbl ON clm.object_id = tbl.object_id
    INNER JOIN sys.types typ ON typ.system_type_id = clm.system_type_id
WHERE 1=1
--    AND tbl.schema_id = 1
--    AND clm.is_identity = 'true'
     --AND tbl.name = 'test'
     --AND clm.name  = 'name'
  --  AND typ.name = 'varchar'
     AND clm.max_length <> -1
ORDER BY clm.max_length DESC
;

-- VARCHAR(MAX) - Slow performance but no constraints
SELECT
    tbl.name tbl
    ,clm.name clm_nm
    ,clm.column_id clm_dtf
    ,typ.name typ
    ,clm.max_length as size
    ,'columns=>'
    ,clm.*
FROM sys.columns clm
    INNER JOIN sys.tables tbl ON clm.object_id = tbl.object_id
    INNER JOIN sys.types typ ON typ.system_type_id = clm.system_type_id
WHERE 1=1
--    AND tbl.schema_id = 1
--    AND clm.is_identity = 'true'
    -- AND tbl.name = 'test'
   --  AND clm.name  = 'name'
  --  AND typ.name = 'varchar'
     AND clm.max_length = -1
ORDER BY clm.max_length DESC
;