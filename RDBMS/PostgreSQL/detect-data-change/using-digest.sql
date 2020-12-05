------------------------------------------------------
-- Prepare for first execution
------------------------------------------------------

-- lsof -ti :5432 | xargs kill;
-- docker rm --force db_server_digest_test
-- docker run --name db_server_digest_test --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --detach postgres:alpine

-- docker run -it --rm --network host postgres:latest psql --host=localhost --username=postgres  --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"
-- psql postgres://postgres@localhost:5432 --command="SELECT setting FROM pg_settings WHERE name = 'server_version'"

-- Connect to database POSTGRES with user POSTGRES (or any user having CREATE EXTENSION privilege)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE state_before (
    table_name VARCHAR,
    id BIGINT,
    digest VARCHAR
);

CREATE TABLE state_after (
    table_name VARCHAR,
    id BIGINT,
    digest VARCHAR
);


CREATE MATERIALIZED VIEW created_rows AS
    SELECT table_name, id  FROM state_after
    EXCEPT
    SELECT table_name, id FROM state_before
;

CREATE MATERIALIZED VIEW deleted_rows AS
    SELECT table_name, id FROM state_before
    EXCEPT
    SELECT table_name, id  FROM state_after
;

CREATE MATERIALIZED VIEW modified_rows AS
    SELECT sb.table_name, sb.id
        FROM state_before sb
            INNER JOIN state_after sa ON sa.table_name = sb.table_name AND sa.id = sb.id
    WHERE 1=1
        AND sa.digest <> sb.digest
;


-- Sample tables

CREATE TABLE table_one (
    id SERIAL,
    property_one   REAL DEFAULT random(),
    property_two   REAL DEFAULT random(),
    property_three REAL DEFAULT random()
);

CREATE TABLE table_two (
    id SERIAL,
    property_one   REAL DEFAULT random()
);

------------------------------------------------------
-- Change without dropping whole schema
------------------------------------------------------

-- DROP TABLE IF EXISTS state_before;
-- DROP TABLE IF EXISTS state_after;
-- DROP MATERIALIZED VIEW IF EXISTS created_rows;
-- DROP MATERIALIZED VIEW IF EXISTS deleted_rows;
-- DROP MATERIALIZED VIEW IF EXISTS modified_rows;
-- DROP TABLE IF EXISTS table_one;
-- DROP TABLE IF EXISTS table_two;


------------------------------------------------------
-- Prepare for each execution
------------------------------------------------------
TRUNCATE TABLE state_after;
TRUNCATE TABLE state_before;
TRUNCATE TABLE table_one;
TRUNCATE TABLE table_two;


------------------------------------------------------
-- Set up dataset
------------------------------------------------------


-- INSERT INTO table_one (property_one) VALUES(3)
-- ;
--
-- INSERT INTO table_one DEFAULT VALUES
-- ;

INSERT INTO table_one (property_one)
SELECT random()
FROM generate_series( 1, 100)
;

INSERT INTO table_two (property_one)
SELECT random()
FROM generate_series( 1, 50)
;

-- SELECT * FROM table_one;
-- SELECT * FROM table_two;

------------------------------------------------------
-- Take before snapshot
------------------------------------------------------

INSERT INTO state_before (table_name, id, digest)
SELECT
       'table_one',
       id,
       encode(sha256(data::text::bytea), 'hex')
FROM table_one data;

INSERT INTO state_before (table_name, id, digest)
SELECT
       'table_two',
       id,
       encode(sha256(data::text::bytea), 'hex')
FROM table_two data;

------------------------------------------------------
-- Execute SUT - WHEN
------------------------------------------------------

UPDATE table_one SET property_one = 1, property_two = 2, property_three = 3
WHERE id = 53;

UPDATE table_one SET property_one = 5
WHERE id = 15;

UPDATE table_two SET property_one = 1
WHERE id = 6;

INSERT INTO table_two DEFAULT VALUES;

DELETE FROM table_two WHERE id > 11 AND id < 23;


------------------------------------------------------
-- Take after snapshot
------------------------------------------------------

INSERT INTO state_after (table_name, id, digest)
SELECT
       'table_one',
       id,
       encode(sha256(data::text::bytea), 'hex')
FROM table_one data;

INSERT INTO state_after (table_name, id, digest)
SELECT
       'table_two',
       id,
       encode(sha256(data::text::bytea), 'hex')
FROM table_two data;


------------------------------------------------------
-- Detect changes
------------------------------------------------------

REFRESH MATERIALIZED VIEW created_rows;
REFRESH MATERIALIZED VIEW deleted_rows;
REFRESH MATERIALIZED VIEW modified_rows;

------------------------------------------------------
-- Assert
------------------------------------------------------

SELECT * FROM created_rows;
-- table_two 51


SELECT * FROM deleted_rows;
-- table_two 12
-- table_two 15
-- (..)

SELECT * FROM modified_rows;
-- table_one, 15
-- table_one, 53
-- table_two, 6


--
-- SELECT * FROM state_before
-- WHERE 1=1
-- --    AND id = 1
-- ;
--
-- SELECT table_name, COUNT(1) FROM state_before
-- GROUP BY  table_name
-- ;
--
-- SELECT * FROM state_after
-- WHERE 1=1
-- --    AND id = 1
-- ;
--
-- SELECT table_name, COUNT(1) FROM state_after
-- GROUP BY  table_name
-- ;

