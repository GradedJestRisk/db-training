-- In SQL Server, the primary key constraint automatically creates a clustered index on that particular column.
-- If no PK is specified, and no index is create, then the table use an anonymous heap index
-- https://www.sqlshack.com/what-is-the-difference-between-clustered-and-non-clustered-indexes-in-sql-server/

-- Why heap ?
-- https://www.sqlshack.com/clustered-index-vs-heap/

-- Table using heap
-- https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-indexes-transact-sql?view=sql-server-ver16
SELECT
     t.name table_name
    ,i.type_desc
    ,a.used_pages
    ,'sys.indexes=>'
    ,i.*
FROM
    sys.tables t
        INNER JOIN sys.indexes i ON t.object_id = i.object_id
        INNER JOIN sys.partitions p ON p.object_id = i.object_id AND p.index_id = i.index_id
        INNER JOIN sys.allocation_units a ON a.container_id = p.partition_id
WHERE 1=1
    --AND t.name NOT LIKE 'T_TMP%'
    AND t.is_ms_shipped = 'false'
    --AND i.object_id > 255
    AND i.type_desc = 'HEAP'
ORDER BY a.total_pages DESC
;