----------------
-- Create ---
----------------

-- https://www.postgresql.org/docs/13/sql-createsequence.html

DROP SEQUENCE IF EXISTS foo_id_seq;

-- Create
CREATE SEQUENCE foo_id_seq;
CREATE SEQUENCE foo_id_seq AS INTEGER;

CREATE SEQUENCE foo_id_seq AS INTEGER START 2147483646;

SELECT NEXTVAL('foo_id_seq');
-- 1

-- Create with starting value
CREATE SEQUENCE foo_id_seq AS BIGINT START 2147483649;
SELECT NEXTVAL('foo_id_seq');
-- 2147483649

drop table users;

CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    name TEXT
);
insert into users (name)  values ('alex');
select * from users;

----------------
-- ALTER ---
----------------

ALTER SEQUENCE foo_id_seq RESTART;
SELECT NEXTVAL('foo_id_seq');
-- 1

ALTER SEQUENCE foo_id_seq RESTART WITH 105;
SELECT NEXTVAL('complementary-certifications_id_seq');
SELECT NEXTVAL('granted-accreditations_id_seq');
-- 105

----------------
-- ALTER use ---
----------------

-- Add use by relation
ALTER TABLE foo ALTER COLUMN id SET DEFAULT nextval('foo_id_seq');

-- Remove use by relation
ALTER TABLE foo ALTER COLUMN id DROP DEFAULT;

-- Detach sequence from id TO new_id
ALTER SEQUENCE foo_id_seq OWNED BY foo.new_id;
ALTER TABLE foo ALTER COLUMN new_id SET DEFAULT nextval('foo_id_seq');
ALTER TABLE foo ALTER COLUMN id DROP DEFAULT;

-- Change type
ALTER SEQUENCE foo_id_seq AS BIGINT;

----------------
-- DROP ---
----------------
DROP SEQUENCE foo_id_seq;