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
