CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION pg_buffercache;

----------
-- Data  -
----------

-- Handle table dependencies
DROP TABLE IF EXISTS bar;
DROP TABLE IF EXISTS foobar;
DROP TABLE IF EXISTS foo;

-- FOO --
-- Primary key using INTEGER
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY, -- https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL
   value INTEGER,
   referenced_value INTEGER CONSTRAINT referenced_value_unique UNIQUE
 );

INSERT INTO foo
  (value, referenced_value)
SELECT
  floor(random() * 2147483627 + 1)::int,
  floor(random() * 2147483627 + 1)::int
FROM
  --generate_series( 1, 5000000) -- 5 million => 2 minutes
    generate_series( 1, 1000000) -- 1 million => 40 seconds
ON CONFLICT ON CONSTRAINT referenced_value_unique DO NOTHING;

DROP TABLE IF EXISTS bar;


-- BAR --
-- FK on regular column using INTEGER
CREATE TABLE bar (
   value_foo INTEGER REFERENCES foo(referenced_value)
 );

INSERT INTO bar (value_foo)
SELECT f.referenced_value FROM foo f;

-- FOOBAR --
-- FK and NOT NULL on column with INTEGER type
CREATE TABLE foobar (
   id    SERIAL PRIMARY KEY,
   foo_id INTEGER NOT NULL REFERENCES foo(id)
 );

INSERT INTO foobar (foo_id)
SELECT f.id FROM foo f ORDER BY RANDOM() LIMIT 1000000; -- 1 million => 40 seconds

----------
-- User  -
----------
CREATE USER activity;
CREATE USER migration;

----------
-- Privileges  -
----------
GRANT CONNECT ON DATABASE database TO activity, migration;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE foo, bar TO activity, migration;
GRANT ALL PRIVILEGES ON SEQUENCE foo_id_seq TO activity, migration;

----------
-- Views  -
----------

-- https://www.postgresql.org/docs/13/pgstatstatements.html#PGSTATSTATEMENTS-COLUMNS
CREATE VIEW cumulated_statistics AS
SELECT
    TRUNC(SUM(stt.total_exec_time))                  execution_time_ms
   ,pg_size_pretty(SUM(wal_bytes))                   disk_wal_size
   ,pg_size_pretty(SUM(temp_blks_written) * 8192)    disk_temp_size
FROM pg_stat_statements stt
    INNER JOIN pg_authid usr ON usr.oid = stt.userid
    INNER JOIN pg_database db ON db.oid = stt.dbid
WHERE db.datname = 'database'
;
