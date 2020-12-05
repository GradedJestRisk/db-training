------------------------------------------------------
-- Prepare for first execution
------------------------------------------------------

-- lsof -ti :5432 | xargs kill;
-- docker rm --force db_server_dump_test
-- pg_dump --version
-- docker run --name db_server_dump_test --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --detach postgres:12.4-alpine postgres:alpine -- use client version <= pg_dump_version

-- docker run -it --rm --network host postgres:latest psql --host=localhost --username=postgres  --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"
-- psql postgres://postgres@localhost:5432 --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"

-- docker ps
-- docker logs db_server_dump_test

-- Connect with user POSTGRES (or any user having CREATE SCHEMA privilege)

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
-- Execute SUT
------------------------------------------------------

SELECT *
FROM schema1.table_one
;

DELETE FROM schema1.table_one
WHERE id = 1;

------------------------------------------------------
-- Take after snapshot
------------------------------------------------------

-- pg_dump postgres://postgres@localhost:5432 --schema=schema1 > after.sql

------------------------------------------------------
-- Assert
------------------------------------------------------
-- diff --context before.sql after.sql                                                                                                                                                   2 ↵

-- Output

-- *** before.sql	2020-12-05 11:34:03.961730955 +0100
-- --- after.sql	2020-12-05 11:35:15.253694449 +0100
-- ***************
-- *** 77,83 ****
--   --
--
--   COPY schema1.table_one (id, property_one, property_two, property_three) FROM stdin;
-- - 1	0.50607955	0.26725948	0.36225247
--   2	0.34009993	0.2829778	0.99196184
--   3	0.5807955	0.16227898	0.5079428
--   4	0.15816209	0.5463227	0.8812118
-- --- 77,82 ----
--
