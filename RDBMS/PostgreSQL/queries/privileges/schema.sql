-- Schemas
SELECT schema_name
FROM information_schema.schemata
;


-- Do you have `USAGE` on the schema?
--     No:  Reject access.
--     Yes: Do you also have the appropriate rights on the table?
--         No:  Reject access.
--         Yes: Check column privileges.

-- To avoid prefixing with schema name
--
-- SHOW search_path;
-- SET search_path = schema1, "$user", public;
-- SHOW search_path;

-- docker rm db_server_schema_test

-- docker run --name db_server_schema_test --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --detach postgres:latest
-- psql postgres://postgres@localhost:5432
-- docker ps
-- docker logs db_server_schema_test


-- CONNECT postgres postgres;

SELECT "current_user"(), "current_database"(), "current_schema"();
DROP DATABASE IF EXISTS database1;
CREATE DATABASE database1;

-- CONNECT database1 postgres;
SELECT "current_user"(), "current_database"(), "current_schema"();

CREATE SCHEMA schema1;
DROP TABLE IF EXISTS schema1.foo;
CREATE TABLE schema1.foo (id SERIAL PRIMARY KEY, label VARCHAR);
INSERT INTO schema1.foo (label) VALUES ('some_text_inserted_by_' ||  "current_user"());
SELECT * FROM schema1.foo;

DROP OWNED BY user1;
DROP USER IF EXISTS user1;
CREATE USER user1;
GRANT CONNECT ON DATABASE database1 TO user1;
GRANT USAGE ON SCHEMA schema1 TO user1;


-----------------
-- Read only   --
-----------------

--GRANT SELECT ON ALL TABLES IN SCHEMA schema1 TO user1;
GRANT SELECT ON TABLE schema1.foo TO user1;

-- Table privilege
SELECT
   table_catalog, table_schema, table_name, privilege_type, grantor, grantee
FROM
   information_schema.table_privileges
WHERE 1=1
--    AND grantee = 'user1'
    AND table_schema = 'schema1'
;

-- CONNECT database1 user1;
SELECT "current_user"(), "current_database"(), "current_schema"();

SELECT * FROM schema1.foo;

INSERT INTO schema1.foo (label) VALUES ('some_text_inserted_by_' ||  "current_user"());
-- Permission denied


-----------------
-- Read / write --
-----------------


GRANT USAGE ON SCHEMA schema1 TO user1;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA schema1 TO user1;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA schema1 TO user1;

-- CONNECT database1 user1;
SELECT "current_user"(), "current_database"(), "current_schema"();

SELECT * FROM schema1.foo;
INSERT INTO schema1.foo (label) VALUES ('some_text_inserted_by_' ||  "current_user"());


-----------------
-- Move objects -
-----------------

DROP SCHEMA IF EXISTS tests CASCADE;

CREATE SCHEMA tests;
SELECT current_schema();

-- Table
ALTER TABLE item SET SCHEMA tests;
SELECT * FROM tests.item;

-- Function
ALTER PROCEDURE update_quality
SET SCHEMA tests;

-- Procedure
DROP PROCEDURE IF EXISTS tests.update_quality;

ALTER PROCEDURE update_quality
SET SCHEMA tests;


do $$
begin
	call tests.update_quality();
end
$$;