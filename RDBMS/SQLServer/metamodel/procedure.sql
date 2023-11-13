-- Source
SELECT
    mdl.object_id
    ,mdl.definition source
    ,'sys.sql_modules=>'
    ,mdl.*
FROM sys.sql_modules mdl
WHERE 1=1
    AND mdl.definition LIKE '%_EXT_%'
;

-- Name
SELECT
    bjc.name
    ,bjc.type_desc
FROM sys.objects bjc
WHERE 1=1
    AND bjc.is_ms_shipped = 'false'
--     AND bjc.name LIKE '%P_%'
     AND bjc.type_desc = 'SQL_STORED_PROCEDURE'
;

-- Name + Code
SELECT
    bjc.name
    ,bjc.type_desc
    ,prc.definition source
FROM sys.objects bjc
    INNER JOIN sys.sql_modules prc ON prc.object_id = bjc.object_id
WHERE 1=1
    AND bjc.is_ms_shipped = 'false'
--     AND bjc.name LIKE '%P_%'
     AND bjc.type_desc = 'SQL_STORED_PROCEDURE'
;


-- Parameter
SELECT
    bjc.name
    ,prm.*
FROM sys.objects bjc
    INNER JOIN sys.parameters prm ON prm.object_id = bjc.object_id
WHERE 1=1
    AND bjc.is_ms_shipped = 'false'
--     AND bjc.name LIKE '%P_%'
     AND bjc.type_desc = 'SQL_STORED_PROCEDURE'
    AND prm.is_nullable  = 'false'
;

-- Parameter, max
SELECT
    bjc.name
    ,COUNT(1)
FROM sys.objects bjc
    INNER JOIN sys.parameters prm ON prm.object_id = bjc.object_id
WHERE 1=1
    AND bjc.is_ms_shipped = 'false'
--     AND bjc.name LIKE '%P_%'
     AND bjc.type_desc = 'SQL_STORED_PROCEDURE'
GROUP BY
        bjc.name
HAVING COUNT(1) < 10
ORDER BY COUNT(1) DESC
;


-- Parameter + Types

SELECT
    p.name AS ParameterName, t.name AS ParameterType, p.max_length AS ParameterLength
FROM sys.parameters AS p
    JOIN sys.types AS t ON t.user_type_id = p.user_type_id
WHERE object_id = OBJECT_ID('YourProcedureName')