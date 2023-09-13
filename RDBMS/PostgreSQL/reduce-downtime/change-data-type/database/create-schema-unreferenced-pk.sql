CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION pg_buffercache;

----------
-- Data  -
----------

-- Handle table dependencies
DROP TABLE IF EXISTS foo;

--------- Loading data outside script -----------

-- FOO --
--CREATE TABLE foo (
--   id INTEGER
-- );

--------- Loading data inside script -----------

---- Primary key using INTEGER
-- CREATE TABLE foo (
--   id    INTEGER PRIMARY KEY
-- );

CREATE TABLE foo (
  id    INTEGER
);


---- Insert some data
INSERT INTO foo(id)
SELECT *
FROM
   generate_series( 1, 2)
--  generate_series( 1, 1000000) -- 1 million => seconds
--  generate_series( 1, 2000000) -- 2 million =>  seconds
--  generate_series( 1, 5000000) -- 5 million =>
--  generate_series( 1, 7000000) -- 7 million =>  30 seconds
--  generate_series( 1, 70000000) -- 70 million => 2 minutes
--    generate_series( 1, 700000000) -- 700 million => 20 minutes
;

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY;

DROP SEQUENCE IF EXISTS foo_id_seq;
CREATE SEQUENCE foo_id_seq AS INTEGER START 7000001;
ALTER TABLE foo ALTER COLUMN id SET DEFAULT nextval('foo_id_seq');

----------
-- User  -
----------
CREATE USER activity;

----------
-- Privileges  -
----------
GRANT CONNECT ON DATABASE database TO activity;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE foo TO activity;
GRANT ALL PRIVILEGES ON SEQUENCE foo_id_seq TO activity;

----------
-- Views  -
----------

-- https://www.postgresql.org/docs/13/pgstatstatements.html#PGSTATSTATEMENTS-COLUMNS
CREATE VIEW cumulated_statistics AS
SELECT
    TRUNC(SUM(stt.total_time))                  execution_time_ms
   ,pg_size_pretty(SUM(wal_bytes))                   disk_wal_size
   ,pg_size_pretty(SUM(wal_bytes))                   disk_wal_size
   ,pg_size_pretty(SUM(temp_blks_written) * 8192)    disk_temp_size
FROM pg_stat_statements stt
    INNER JOIN pg_authid usr ON usr.oid = stt.userid
    INNER JOIN pg_database db ON db.oid = stt.dbid
WHERE db.datname = 'database'
;
