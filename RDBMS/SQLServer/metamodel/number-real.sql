-- Decimal and numeric are synonyms and can be used interchangeably.
DROP TABLE test;

CREATE TABLE test
(
  id   INT NOT NULL PRIMARY KEY ,
  one  decimal(10,2), -- 12 345 678,90
  two  numeric(10,2)  -- 12 345 678,90
);



INSERT INTO test VALUES (1, 12345678.90, 12345678.90);


SELECT *
FROM test
;

-- Real
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