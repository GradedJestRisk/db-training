--
DROP TABLE test;

CREATE TABLE test
(
  id   INT NOT NULL PRIMARY KEY ,
  number float,
  another  numeric
);

select * from test
;


-- All types
SELECT
    tbl.name tbl
    ,clm.name clm_nm
    ,clm.column_id clm_dtf
    ,typ.name typ
    ,clm.*
    ,'columns=>'
    ,clm.*
FROM sys.columns clm
    INNER JOIN sys.tables tbl ON clm.object_id = tbl.object_id
    INNER JOIN sys.types typ ON typ.system_type_id = clm.system_type_id
WHERE 1=1
--    AND tbl.schema_id = 1
--    AND clm.is_identity = 'true'
   --  AND tbl.name = 'test'
--      AND clm.name  NOT LIKE 'ID%'
       AND typ.name IN ('numeric','decimal', 'money')
--        AND typ.name IN ('real','float')
--       AND typ.name IN ( 'bigint', 'smallint', 'int')
--      AND typ.name IN ('int')
--      AND typ.name IN ('smallint')
--     AND clm.max_length > 100
ORDER BY clm.max_length DESC
;

-- Group
SELECT
    typ.name, count(1)
FROM sys.columns clm
    INNER JOIN sys.tables tbl ON clm.object_id = tbl.object_id
    INNER JOIN sys.types typ ON typ.system_type_id = clm.system_type_id
WHERE 1=1
--    AND tbl.schema_id = 1
--    AND clm.is_identity = 'true'
   --  AND tbl.name = 'test'
--     AND clm.name  = 'name'

  -- Integer
--      AND typ.name IN ( 'bigint', 'smallint', 'int')
       AND typ.name IN ('numeric','decimal', 'money')
--      AND typ.name IN ('numeric','decimal', 'bigint', 'smallint', 'int', 'money')
--     AND clm.max_length > 100
GROUP BY typ.name
ORDER BY count(1) desc
;

-- Integer
SELECT
    tbl.name tbl
    ,clm.name clm_nm
    ,clm.column_id clm_dtf
    ,typ.name typ
    ,clm.*
    ,'columns=>'
    ,clm.*
FROM sys.columns clm
    INNER JOIN sys.tables tbl ON clm.object_id = tbl.object_id
    INNER JOIN sys.types typ ON typ.system_type_id = clm.system_type_id
WHERE 1=1
--    AND tbl.schema_id = 1
--    AND clm.is_identity = 'true'
   --  AND tbl.name = 'test'
--      AND clm.name  NOT LIKE 'ID%'
       AND typ.name IN ( 'bigint', 'smallint', 'int')
--      AND typ.name IN ('int')
--      AND typ.name IN ('smallint')
--     AND clm.max_length > 100
ORDER BY clm.max_length DESC
;