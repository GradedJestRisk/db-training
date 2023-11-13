
sp_helpindex CCS_FACTURATION_ODS


-- Indexes - Tables
SELECT
    tbl.name
    ,ndx.name
    ,ndx.type_desc
    ,'indexes=>'
    ,ndx.*
FROM sys.indexes ndx
    INNER JOIN sys.tables tbl ON tbl.object_id = ndx.object_id
WHERE 1=1
    AND ndx.is_primary_key = 'false'
;

-- Index - Objects
SELECT
    ndx.name index_name
    ,ndx.type_desc index_type
    ,bjc.name object_name
    ,bjc.type_desc object_type
--     ,'indexes=>'
--     ,ndx.*
--     ,'objects=>'
--     ,bjc.*
FROM
    sys.indexes ndx
        INNER JOIN sys.objects bjc On bjc.object_id = ndx.object_id
WHERE 1=1
    AND bjc.is_ms_shipped = 0
    AND ndx.type_desc = 'CLUSTERED COLUMNSTORE'
;

-- https://www.sqlshack.com/what-is-the-difference-between-clustered-and-non-clustered-indexes-in-sql-server/
-- Indexes type
SELECT
    ndx.type_desc type,
    COUNT(1) count
FROM sys.indexes ndx
    INNER JOIN sys.tables tbl ON tbl.object_id = ndx.object_id
WHERE 1=1
     AND ndx.is_primary_key = 'false'
     AND ndx.is_unique_constraint = 'false'
     AND ndx.name NOT LIKE '%_PK'
GROUP BY ndx.type_desc
;


-- Index
SELECT
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name
    ,ind.type_desc
--       ,ind.*
--      ,ic.*
--      ,col.*
FROM
     sys.indexes ind
INNER JOIN
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id
INNER JOIN
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id
INNER JOIN
     sys.tables t ON ind.object_id = t.object_id
WHERE 1=1
     AND ind.is_primary_key = 0
     AND ind.is_unique = 0
     AND ind.is_unique_constraint = 0
     AND t.is_ms_shipped = 0
--      AND ind.name NOT LIKE '%_PK'
      AND ind.name LIKE 'T_MVT_FINANCIER_IDX%'
--      AND ind.name = 'T_SATUS_DATE_PUSH_IDX1'
ORDER BY
     t.name, ind.name, ind.index_id, ic.is_included_column, ic.key_ordinal
;