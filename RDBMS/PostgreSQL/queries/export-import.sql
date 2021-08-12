
-----------------------------------
-- Load from dump               --
-----------------------------------

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id   INTEGER
 );

INSERT INTO foo
  (id)
SELECT *
FROM generate_series( 1, 10000);

CREATE USER activity;
GRANT CONNECT ON DATABASE database TO activity;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE foo TO activity;

-- Create a dump
-- pg_dump --help

--------------- BASICS -------------------

-- Text files created by pg_dump are intended to be read in by the psql program.
-- The general command form to restore a dump is
-- psql dbname < dumpfile

-- If PostgreSQL was built on a system with the zlib compression library installed, the custom dump format will compress data as it writes it to the output file.
-- This will produce dump file sizes similar to using gzip, but it has the added advantage that tables can be restored selectively.
-- The following command dumps a database using the custom dump format:
-- pg_dump -Fc dbname > filename
-- A custom-format dump is not a script for psql, but instead must be restored with pg_restore, for example:
-- pg_restore -d dbname filename

-- Single table
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo database

-- Single table (no schema, data including indexes)
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo --data-only database


-- Single table (custom format = compressed)
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo -Fc database

-- Monitor with pipe viewer
-- pg_dump --host localhost --port 5432 --username activity --table public.foo database | pv | gzip > foo.sql.gz

-- Check produced file

-- Size
-- ls -ltrh foo.sql.gz

-- Content
-- zcat foo.sql.gz  | tail -100


-- Restore it
-- pg_restore --help
--  -c, --clean                  clean (drop) database objects before recreating

DROP TABLE foo CASCADE;
GRANT ALL ON schema public TO activity;

-- Restore with psql
-- zcat foo.sql.gz | psql --host localhost --port 5432 --username activity --dbname "database"
-- zcat foo.sql.gz | psql postgres://activity@localhost:5432/database

-- Restore with psql and view progress
-- pv foo.sql.gz | zcat | psql postgres://postgres@localhost:5432/database

-- Restore with pg_restore (custom format only)
-- DROP TABLE foo CASCADE;
-- pg_restore --host localhost --port 5432 --username postgres --dbname "database" --verbose "/tmp/foo.dmp"

-- Restore with pg_restore (custom format only)
-- pg_restore --host localhost --port 5432 --username postgres --dbname "database" --table public.foo --clean --verbose "/tmp/foo.dmp"

-- ?
-- pg_restore --host localhost --port 5432 --username postgres --dbname "database" --table public.foo --clean --verbose "/tmp/foo.dmp"
-- pg_restore: connecting to database for restore
-- pg_restore: implied data-only restore


SELECT * FROM foo;
