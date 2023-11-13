-- Tables
SELECT
    tbl.object_id,
    tbl.name,
    tbl.schema_id,
    'tables=>',
    tbl.*
FROM sys.tables tbl
WHERE 1=1
--    AND name = 'T_PROCEDURE'
--    AND tbl.schema_id = 1
;


SLECT

-- Schemas
SELECT
    sch.schema_id,
    sch.name
FROM sys.schemas sch
WHERE 1=1
--    AND name = 'T_PROCEDURE'
;


-- Databases
SELECT
    dtb.database_id id,
    dtb.name,
    'databases=>',
    dtb.*
FROM sys.databases dtb
WHERE 1=1
--    AND name = 'T_PROCEDURE'
;
