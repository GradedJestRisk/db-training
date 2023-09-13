------------------------------------------------------
-- Prepare for first execution
------------------------------------------------------

-- lsof -ti tcp:5432 | xargs kill;
-- docker rm --force db_server_dump_test
-- pg_dump --version
-- docker run --name db_server_dump_test --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --detach postgres:12.4-alpine postgres:alpine -- use client version <= pg_dump_version

-- docker run -it --rm --network host postgres:latest psql --host=localhost --username=postgres  --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"
-- psql postgres://postgres@localhost:5432 --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"

-- docker ps
-- docker logs db_server_dump_test

DROP SCHEMA schema1;
CREATE SCHEMA schema1;

CREATE TABLE schema1.table_one (
    id SERIAL,
    property_one   REAL DEFAULT random(),
    property_two   REAL DEFAULT random(),
    property_three REAL DEFAULT random()
);

------------------------------------------------------
-- Prepare for each execution
------------------------------------------------------

TRUNCATE TABLE schema1.table_one;

INSERT INTO schema1.table_one (property_one)
SELECT random()
FROM generate_series( 1, 100)
;

SELECT *
FROM schema1.table_one
;

------------------------------------------------------
-- Take before snapshot
------------------------------------------------------

-- pg_dump postgres://postgres@localhost:5432 --schema=schema1 > before.sql


------------------------------------------------------
-- Constraints
------------------------------------------------------

psql postgres://postgres@localhost:5432/

DROP DATABASE IF EXISTS source_database;
CREATE DATABASE source_database;

DROP DATABASE IF EXISTS target_database;
CREATE DATABASE target_database;

\c source_database
CREATE TABLE foo (id INTEGER PRIMARY KEY);
INSERT INTO foo (id) VALUES (1);
INSERT INTO foo (id) VALUES (2);

CREATE TABLE foobar (id_foo INTEGER REFERENCES foo(id));
INSERT INTO foobar (id_foo) VALUES (1);


\c target_database
CREATE TABLE foo (id INTEGER);
CREATE TABLE foobar (id_foo INTEGER);

-- SOURCE_DATABASE_URL=postgres://postgres@localhost:5432/source_database DATABASE_URL=postgres://postgres@localhost:5432/target_database TABLE_TO_COPY=foobar npm run unreferenced-pk:copy-dataset
--
-- pg_restore: error: could not execute query: ERROR:  relation "public.foo" does not exist
-- Command was: ALTER TABLE ONLY public.foobar
--     ADD CONSTRAINT foobar_id_foo_fkey FOREIGN KEY (id_foo) REFERENCES public.foo(id);
