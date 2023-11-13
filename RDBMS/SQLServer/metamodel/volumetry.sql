-- Partitions
SELECT *
FROM sys.partitions prt
WHERE 1=1
    AND prt.object_id = 191092217
;
-- You may have many partition for a single column store index


-- Index - Tables - Partitions
SELECT
    prt.partition_id prt_id
    ,ndx.name index_name
    ,ndx.type_desc index_type
    ,bjc.name object_name
    ,bjc.type_desc object_type
    ,'indexes=>'
    ,ndx.*
--     ,'objects=>'
--     ,bjc.*
    ,'partitions=>'
    ,prt.*
FROM
    sys.partitions prt
        INNER JOIN sys.objects bjc ON bjc.object_id = prt.object_id
        INNER JOIN sys.indexes ndx ON ndx.index_id = prt.index_id AND ndx.object_id =bjc.object_id
WHERE 1=1
    AND bjc.type_desc = 'USER_TABLE'
    AND bjc.is_ms_shipped = 0
    AND bjc.name = 'T_CONNEXIONS_WEB'
--     AND ndx.is_primary_key = 0
  --  AND ndx.name LIKE '%PK%'
;

-- total_pages 	bigint 	Total number of pages allocated or reserved by this allocation unit.
-- used_pages 	bigint 	Number of total pages actually in use.
-- https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-allocation-units-transact-sql?view=sql-server-ver16

-- SQL Server writes all data rows on pages, and all data pages are the same size: 8 KB.
-- https://learn.microsoft.com/en-us/sql/relational-databases/pages-and-extents-architecture-guide?view=sql-server-ver16

-- Allocation units
SELECT
    'usage:'
     ,llc.type_desc
     ,llc.used_pages
    ,llc.total_pages
    ,'sys.allocation_units=>'
    ,llc.*
FROM sys.allocation_units llc
WHERE 1=1
    AND llc.container_id = 72057594068664320 -- <= partition_id
--     AND llc.type_desc NOT IN ('IN_ROW_DATA', 'LOB_DATA', 'ROW_OVERFLOW_DATA')
;


-- Index - Tables - Partitions - Allocation
SELECT
     'usage:'
     ,bjc.object_id
    ,bjc.name object_name
    ,prt.rows row_count
    ,llc.used_pages
    ,llc.total_pages
     ,ndx.index_id
     ,ndx.name index_name
    ,ndx.type_desc index_type
--    ,bjc.type_desc object_type
--     ,'indexes=>'
--     ,ndx.*
--     ,'objects=>'
--     ,bjc.*
    ,'partitions=>'
    ,prt.*
    ,'sys.allocation_units=>'
    ,llc.*
FROM
    sys.objects bjc
        INNER JOIN sys.indexes ndx ON ndx.object_id = bjc.object_id
        INNER JOIN sys.partitions prt ON prt.object_id = bjc.object_id AND prt.index_id = ndx.index_id
        INNER JOIn sys.allocation_units llc ON llc.container_id = prt.partition_id
WHERE 1=1
    AND bjc.type_desc = 'USER_TABLE'
    AND bjc.is_ms_shipped = 0
   -- AND bjc.name = 'T_CONNEXIONS_WEB'
     AND ndx.is_primary_key = 'false' -- No PK
     AND ndx.is_unique_constraint = 'false' -- No PK
  --  AND ndx.name LIKE '%PK%'
    AND ndx.name = 'CCS_FACTURATION_ODS'
;


-- https://dba.stackexchange.com/questions/284247/table-size-without-indexes-in-sql-server
select * FROM sys.dm_db_partition_stats
;

-- https://stackoverflow.com/questions/63068634/how-inaccurate-can-the-sys-dm-db-partition-stats-row-count-be-in-getting-an-azur
SELECT
    (SCHEMA_NAME(A.schema_id) + '.' + A.Name) as table_name,
    B.object_id, B.index_id, B.row_count
FROM
    sys.dm_db_partition_stats B
LEFT JOIN
    sys.objects A
    ON A.object_id = B.object_id
WHERE
    SCHEMA_NAME(A.schema_id) <> 'sys'
    AND (B.index_id = '0' OR B.index_id = '1')
ORDER BY
    B.row_count DESC
;2


-- Row count (1)
SELECT
    tbl.name,
    SUM(prt.rows) row_count
FROM sys.tables tbl
    INNER JOIN sys.partitions prt ON tbl.object_id = prt.object_id
    INNER JOIN sys.indexes ndx ON prt.object_id = ndx.object_id AND prt.index_id = ndx.index_id
WHERE 1=1
    AND ndx.index_id < 2
GROUP BY tbl.object_id, tbl.name
ORDER BY row_count DESC;

-- Row count(2)
SELECT
      bjc.name tableName
      , SUM(ptn.rows) row_count
FROM
      sys.objects bjc
        INNER JOIN sys.partitions ptn ON bjc.object_id = ptn.object_id
WHERE 1=1
      AND bjc.type = 'U'
      AND bjc.is_ms_shipped = 0x0
      AND index_id < 2 -- 0:Heap, 1:Clustered
GROUP BY
    bjc.name
ORDER BY
    row_count DESC
;

-- Index size
SELECT
    OBJECT_NAME(i.OBJECT_ID) AS TableName,
    i.name AS IndexName,
--     i.index_id AS IndexID,
    (8 * SUM(a.used_pages))/1024 AS 'Indexsize(MB)'
FROM
    sys.indexes AS i
        JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
        JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE
    i.is_primary_key = 0 -- fix for size discrepancy
GROUP BY
    i.OBJECT_ID,
    i.index_id,
    i.name
HAVING (8 * SUM(a.used_pages)/1024) > 100
ORDER BY
    'Indexsize(MB)' DESC
;

-- Data size

SELECT
    t.name AS TableName,
--     s.name AS SchemaName,
--     p.rows,
--     SUM(a.total_pages) * 8 AS TotalSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB
--     ,SUM(a.used_pages) * 8 AS UsedSpaceKB,
--     CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB,
--     (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
--     CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM
    sys.tables t
INNER JOIN
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN
    sys.schemas s ON t.schema_id = s.schema_id
WHERE
    t.name NOT LIKE 'dt%'
    AND t.is_ms_shipped = 0
    AND i.object_id > 255
GROUP BY
    t.name, s.name, p.rows
HAVING
      CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2))  > 100
ORDER BY
    TotalSpaceMB DESC, t.name
;

-- https://dba.stackexchange.com/questions/284247/table-size-without-indexes-in-sql-server
-- Index and data, separate - Trustworthy
WITH stats as (
    SELECT
    t.name as TableName,
    SUM (s.used_page_count) as used_pages_count,
    SUM (CASE
                WHEN (i.index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
                ELSE lob_used_page_count + row_overflow_used_page_count
            END) as pages
    FROM sys.dm_db_partition_stats  AS s
    JOIN sys.tables AS t ON s.object_id = t.object_id
    JOIN sys.indexes AS i ON i.[object_id] = t.[object_id] AND s.index_id = i.index_id
    GROUP BY t.name
    )
SELECT
    stats.TableName,
    cast((stats.pages * 8.)/1024 as decimal(10,3)) as TableSizeInMB,
    cast(((CASE WHEN stats.used_pages_count > stats.pages
                THEN stats.used_pages_count - stats.pages
                ELSE 0
          END) * 8./1024) as decimal(10,3)) as IndexSizeInMB
FROM stats
ORDER BY 2 DESC
;

--  https://dba.stackexchange.com/questions/284247/table-size-without-indexes-in-sql-server
--  Table size (no index)
SELECT
    t.name as TableName
    , SUM (CASE WHEN (i.index_id < 2)
              THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
              ELSE lob_used_page_count + row_overflow_used_page_count
         END) * 8 as table_size_kb
FROM sys.dm_db_partition_stats  AS s
    JOIN sys.tables AS t ON s.object_id = t.object_id
    JOIN sys.indexes AS i ON i.[object_id] = t.[object_id] AND s.index_id = i.index_id
WHERE 1=1
--     t.object_id = OBJECT_ID('schema.table')
    AND t.name LIKE 'T_%'
GROUP BY t.name
ORDER BY table_size_kb DESC
;




SELECT
    bjc.name
--     ,'sys.tables=>'
--     ,tbl.*
--     ,'sys.schemas=>'
--     ,sch.*
--     ,'sys.objects=>'
--     ,bjc.*
    ,'sys.partitions=>'
    ,prt.*
FROM sys.partitions prt
    INNER JOIN sys.objects bjc  ON bjc.object_id = prt.object_id
        INNER JOIN sys.schemas sch On sch.schema_id = bjc.schema_id
            INNER JOIN sys.tables tbl ON tbl.schema_id = sch.schema_id AND tbl.object_id = bjc.object_id
WHERE 1=1
    AND bjc.type_desc = 'USER_TABLE'
--     AND sch.name <> 'sys'
    AND bjc.is_ms_shipped = 'false'
;

-- Index - Tables
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
;

SELECT
    prt.object_id
    ,'sys.partitions=>'
    ,prt.*
FROM sys.partitions prt
WHERE 1=1
--     AND prt.object_id <>
;

-- Index - Tables - Partitions
SELECT
    prt.partition_id prt_id
    ,ndx.name index_name
    ,ndx.type_desc index_type
    ,bjc.name object_name
    ,bjc.type_desc object_type
    ,'indexes=>'
    ,ndx.*
--     ,'objects=>'
--     ,bjc.*
    ,'partitions=>'
    ,prt.*
FROM
    sys.partitions prt
        INNER JOIN sys.objects bjc ON bjc.object_id = prt.object_id
        INNER JOIN sys.indexes ndx ON ndx.index_id = prt.index_id AND ndx.object_id =bjc.object_id
WHERE 1=1
    AND bjc.type_desc = 'USER_TABLE'
    AND bjc.is_ms_shipped = 0
--     AND ndx.is_primary_key = 0
  --  AND ndx.name LIKE '%PK%'
;