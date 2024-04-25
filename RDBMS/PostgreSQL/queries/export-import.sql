-----------------------------------
-- BASICS              --
-----------------------------------

-- Text files created by pg_dump are intended to be read in by the psql program.
-- The general command form to restore a dump is
-- psql dbname < dumpfile

-- If PostgreSQL was built on a system with the zlib compression library installed, the custom dump format will compress data as it writes it to the output file.
-- This will produce dump file sizes similar to using gzip, but it has the added advantage that tables can be restored selectively.
-- The following command dumps a database using the custom dump format:
-- pg_dump -Fc dbname > filename
-- A custom-format dump is not a script for psql, but instead must be restored with pg_restore, for example:
-- pg_restore -d dbname filename


-----------------------------------
-- Create a dump (back up data)  --
-----------------------------------
CREATE DATABASE database;
DROP OWNED BY CURRENT_USER;

DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER PRIMARY KEY);

INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (1);

SELECT * FROM foo;

DROP TABLE IF EXISTS bar;
CREATE TABLE bar (id INTEGER PRIMARY KEY, id_foo INTEGER NOT NULL REFERENCES foo(id));
INSERT INTO bar (id, id_foo) VALUES (0, 0);
INSERT INTO bar (id, id_foo) VALUES (1, 0);
INSERT INTO bar (id, id_foo) VALUES (2, 1);

SELECT * FROM bar;

-- pg_dump postgres://postgres@localhost:5432/pix --format plain --verbose
-- Output below:
-- - no index is backed up
-- - data are loaded first
-- - then constraints are created (finishing by FK)


CREATE TABLE public.bar (
    id integer NOT NULL,
    id_foo integer NOT NULL
);

CREATE TABLE public.foo (
    id integer NOT NULL
);

COPY public.bar (id, id_foo) FROM stdin;
0	0
1	0
2	1
\.

COPY public.foo (id) FROM stdin;
0
1
\.

ALTER TABLE ONLY public.bar
    ADD CONSTRAINT bar_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.foo
    ADD CONSTRAINT foo_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.bar
    ADD CONSTRAINT bar_id_foo_fkey FOREIGN KEY (id_foo) REFERENCES public.foo(id);

-- Create a dump
-- pg_dump --help


-- Single table
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo database

-- Single table (no schema, data including indexes)
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo --data-only database


-- Single table (custom format = compressed)
-- pg_dump --host localhost --port 5432 --username postgres --format plain --verbose --file /tmp/foo.dmp --table public.foo -Fc database
-- pg_dump --host pix-datawar-7855.postgresql.dbs.scalingo.com --port 30278 --username pix_datawar_7855 --format plain --verbose --file ./ke.dmp --table public.knowledge-elements -Fc pix_datawar_7855

-- Monitor with pipe viewer
-- pg_dump --host localhost --port 5432 --username activity --table public.foo database | pv | gzip > foo.sql.gz

-- Check produced file

-- Size
-- ls -ltrh foo.sql.gz

-- Content
-- zcat foo.sql.gz  | tail -100

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

-----------------------------------
-- Restore a dump               --
-----------------------------------

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

-- Restore it
-- pg_restore --help
--  -c, --clean                  clean (drop) database objects before recreating

-- tar -czf test.tar.gz test.md
--
-- tar --to-stdout -xzvf test.tar.gz | cat
-- tar --to-stdout -xzvf test.tar.gz | pv | cat
--
-- tar --to-stdout -xzvf test.tar.gz | pv cat
--
-- pv test.tar.gz | tar --to-stdout -xzv test.tar.gz | cat
-- pv output.tar.gz | tar --to-stdout -xzv test.tar.gz | pg_restore --verbose --no-owner --dbname=$DATABASE_URL
--
-- tar --to-stdout -xzvf output.tar.gz | pg_restore --verbose --no-owner --dbname=$DATABASE_URL

SELECT * FROM foo;
