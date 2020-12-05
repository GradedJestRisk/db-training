------------------------------------------------------
-- Prepare for first execution
------------------------------------------------------

-- lsof -ti :5432 | xargs kill;
-- docker rm --force db_server_privilege_test
-- docker run --name db_server_privilege_test --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --detach postgres:alpine

-- docker run -it --rm --network host postgres:latest psql --host=localhost --username=postgres  --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"
-- psql postgres://postgres@localhost:5432 --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"

-- Connect to database POSTGRES with user POSTGRES (or any user having CREATE DATABASE and CREATE SCHEMA privilege)

SELECT "current_user"(), "current_database"(), "current_schema"();
DROP DATABASE IF EXISTS database1;
CREATE DATABASE database1;

-- Connect to database DATABASE1 with user POSTGRES
SELECT "current_user"(), "current_database"(), "current_schema"();

CREATE SCHEMA schema1;

CREATE TABLE schema1.table_one (id SERIAL PRIMARY KEY, label VARCHAR);
CREATE TABLE schema1.table_two (id SERIAL PRIMARY KEY, label VARCHAR);
CREATE TABLE schema1.table_three (id SERIAL PRIMARY KEY, label VARCHAR);

CREATE USER user1;
GRANT CONNECT ON DATABASE database1 TO user1;
GRANT USAGE ON SCHEMA schema1 TO user1;

-- DROP OWNED BY user1;
-- DROP USER IF EXISTS user1;
-- DROP TABLE IF EXISTS schema1.foo;
------------------------------------------------------
-- Prepare for each execution
------------------------------------------------------

TRUNCATE TABLE schema1.table_one;
TRUNCATE TABLE schema1.table_two;
TRUNCATE TABLE schema1.table_three;

INSERT INTO schema1.table_one (label) VALUES ('some_text_inserted_by_' ||  "current_user"());
INSERT INTO schema1.table_two (label) VALUES ('some_text_inserted_by_' ||  "current_user"());
INSERT INTO schema1.table_two (label) VALUES ('some_text_inserted_by_' ||  "current_user"());
INSERT INTO schema1.table_three (label) VALUES ('some_text_inserted_by_' ||  "current_user"());

SELECT * FROM schema1.table_one;
SELECT * FROM schema1.table_two;
SELECT * FROM schema1.table_three;

---------------------
-- Setup expectations
---------------------

-- Setup no access tables (table_three)
-- No action required

-- Setup read only tables
GRANT SELECT ON TABLE schema1.table_one TO user1;

-- Setup read/write only tables
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE schema1.table_two TO user1;

-- You need privilege to INSERT on a sequence-based table
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA schema1 TO user1;

-- Table privilege
SELECT
   table_catalog, table_schema, table_name, privilege_type, grantor, grantee
FROM
   information_schema.table_privileges
WHERE 1=1
    AND grantee = 'user1'
    AND table_schema = 'schema1'
;

-----------------
-- Exercise SUT --
-----------------

-- Connect to database DATABASE1 with user USER1
SELECT "current_user"(), "current_database"(), "current_schema"();

-- Allowed actions
SELECT * FROM schema1.table_one;
INSERT INTO schema1.table_two (label) VALUES ('some_text_inserted_by_' ||  "current_user"());
SELECT * FROM schema1.table_two;

-- Disallowed actions

SELECT * FROM schema1.table_three;
-- ERROR: permission denied for table table_three

INSERT INTO schema1.table_one (label) VALUES ('some_text_inserted_by_' ||  "current_user"());
-- ERROR: permission denied for table table_one


