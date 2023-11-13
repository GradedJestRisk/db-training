-- Schema is a collection of database objects (tables, SP) - segregation tool
-- Every SQL Server schema must have a database user as a schema owner
-- https://blog.quest.com/using-database-schemas-in-sql-server/


-- The dbo schema is the default schema of every database.
-- By default, users created with the CREATE USER Transact-SQL command have dbo as their default schema. The dbo schema is owned by the dbo user account.
-- https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/ownership-and-user-schema-separation?view=sql-server-ver16

-- Schema - User (owner)
SELECT
    s.name AS schema_name,
    u.name AS schema_owner
--     ,u.*
FROM sys.schemas s
    INNER JOIN sys.sysusers u ON u.uid = s.principal_id
WHERE 1=1
    AND u.issqlrole = 0
ORDER BY s.name;


-- Default schema for connected user
SELECT SCHEMA_NAME()
;

-- schema name is optional, the default is used
CREATE TABLE dbo.test
(
  id   INT NOT NULL PRIMARY KEY ,
  name      CHAR(10),
  firstname VARCHAR(10),
  lastname  VARCHAR(MAX)
);

-- Table - schema
SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name ='test'
;

-- Move test table to another schema
ALTER SCHEMA guest TRANSFER dbo.test;

-- Drop schema
DROP SCHEMA guest;

-------------------------------------------------------------------------


-- Databases
SELECT
    dtb.database_id id
    ,dtb.name
    ,dtb.owner_sid
    ,suser_sname( owner_sid ) owner
    ,'databases=>' x
    ,dtb.*
FROM
    sys.databases dtb
WHERE 1=1
--    AND name = 'T_PROCEDURE'
   AND name LIKE '%_SAM_%'
;

-- Databases + Owner (may we use sysusers directly ?)
SELECT
    dtb.database_id db_id
    ,dtb.name db_name
    ,usr.name usr_name
    ,'databases=>'
    ,dtb.*
FROM
   sys.databases dtb
        INNER JOIN sys.database_principals usr ON usr.sid = dtb.owner_sid
WHERE 1=1
--    AND name = 'T_PROCEDURE'
   AND dtb.name LIKE '%_SAM_%'
;

-- Schemas
SELECT
    sch.schema_id,
    sch.name,
    'schemas=>'
    ,sch.*
FROM sys.schemas sch
WHERE 1=1
--    AND name = 'T_PROCEDURE'
;
-- dbo is the schema

-- Schemas + user
SELECT
    sch.schema_id
    ,sch.name
    ,usr.name
    ,'schemas=>' x
    ,sch.*
FROM sys.schemas sch
        INNER JOIN sys.database_principals usr ON usr.principal_id = sch.principal_id
WHERE 1=1
--    AND name = 'T_PROCEDURE'
--     AND sch.name NOT LIKE 'db_%'
;
-- dbo is the schema for user dbo


-- Schema  + Tables
SELECT
    sch.schema_id sch_id,
    sch.name sch_name,
--     tbl.object_id,
    tbl.name tbl_name,
    'tables=>' x,
    tbl.*
FROM sys.tables tbl
    INNER JOIN sys.schemas sch ON sch.schema_id = tbl.schema_id
WHERE 1=1
--    AND name = 'T_PROCEDURE'
   --AND tbl.schema_id = 1
    AND  sch.name = 'dbo'
;

-- Object + Schema + Tables
SELECT
    bjc.name
    ,'sys.tables=>'
    ,tbl.*
    ,'sys.schemas=>'
    ,sch.*
    ,'sys.objects=>'
    ,bjc.*

FROM  sys.objects bjc
        INNER JOIN sys.schemas sch On sch.schema_id = bjc.schema_id
            INNER JOIN sys.tables tbl ON tbl.schema_id = sch.schema_id AND tbl.object_id = bjc.object_id
WHERE 1=1
    AND bjc.type_desc = 'USER_TABLE'
--     AND sch.name <> 'sys'
    AND bjc.is_ms_shipped = 'false'
;