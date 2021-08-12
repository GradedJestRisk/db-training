-- https://stackoverflow.com/questions/4107915/postgresql-default-constraint-names
--
-- The standard names for constraints in PostgreSQL are:
--
-- {tablename}_{columnname(s)}_{suffix}
--
-- where the suffix is one of the following:
--
--     pkey  for a Primary Key constraint
--     key   for a Unique constraint
--     excl  for an Exclusion constraint
--     idx   for any other kind of index
--     fkey  for a Foreign key
--     check for a Check constraint
--
-- Standard suffix for sequences is
--
--     seq for all sequences


-----------------------
------- ADD -----------
-----------------------

-- See table for supplying constraint in CREATE TABLE

----------------
-- NOT NULL   --
----------------

DROP TABLE IF EXISTS foo;
CREATE TABLE foo (id INTEGER);

INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (NULL);

SELECT * FROM foo;

-- First way
ALTER TABLE foo
ALTER COLUMN id SET NOT NULL;
--  ERROR: column "id" contains null values

ALTER TABLE "account-recovery-demands"
ALTER COLUMN "schoolingRegistrationId" SET NOT NULL;

ALTER TABLE "account-recovery-demands"
ALTER COLUMN "schoolingRegistrationId" DROP NOT NULL;

-- Second way
ALTER TABLE foo
ADD CONSTRAINT id_not_null
CHECK (id IS NOT NULL);


INSERT INTO foo (id) VALUES(NULL);
-- [23502] ERROR: null value in column "id" violates not-null constraint


-- Third way (validate constraint concurrently)
-- https://begriffs.com/posts/2017-08-27-deferrable-sql-constraints.html

ALTER TABLE foo
ADD CONSTRAINT id_not_null
CHECK (id IS NOT NULL) NOT VALID;

SELECT
    pgc.convalidated
FROM pg_constraint pgc
WHERE 1=1
    AND pgc.conname = 'id_not_null'
;

INSERT INTO foo (id) VALUES(NULL);
-- [23502] ERROR: null value in column "id" violates not-null constraint

ALTER TABLE foo VALIDATE CONSTRAINT id_not_null;
-- [23514] ERROR: check constraint "id_not_null" is violated by some row

DELETE FROM foo WHERE id IS NULL;

ALTER TABLE foo VALIDATE CONSTRAINT id_not_null;

SELECT
    pgc.convalidated
FROM pg_constraint pgc
WHERE 1=1
    AND pgc.conname = 'id_not_null'
;

----------------
-- UNIQUE  --
----------------

DROP TABLE IF EXISTS foo;
CREATE TABLE foo (id INTEGER UNIQUE);

INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (NULL);

-- UNIQUE does not check NULL
INSERT INTO foo (id) VALUES (NULL);
SELECT * FROM foo;
TRUNCATE TABLE foo;


-- First way
ALTER TABLE foo
ADD CONSTRAINT value_unique
UNIQUE(value);

-- Second way (eg. for reducing downtime in PK creation)
DROP INDEX id_unique_index;

DROP TABLE IF EXISTS foo;
CREATE TABLE foo (id INTEGER);

INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (1);
INSERT INTO foo (id) VALUES (2);
SELECT * FROM foo;

CREATE UNIQUE INDEX CONCURRENTLY id_unique_index  ON foo (id);
-- Detail: Key (id)=(0) is duplicated.

SELECT * FROM pg_class, pg_index
WHERE pg_index.indisvalid = false AND pg_index.indexrelid = pg_class.oid

SELECT
       'Indexes=>' qry
       ,ndx.indexname ndxl_nm
       ,ndx.tablename tbl_nm
       ,ndx.indexdef  dfn
       ,'pg_indexes=>' qry
       ,ndx.*
FROM pg_indexes ndx
WHERE 1=1
    AND ndx.indexname = 'id_unique_index'
;


DELETE FROM foo WHERE id = 0;

ALTER TABLE foo
ADD CONSTRAINT id_unique_constraint
UNIQUE USING INDEX id_unique_index;

SELECT
    pgc.convalidated
FROM pg_constraint pgc
WHERE 1=1
    AND pgc.conname = 'id_unique_constraint'
;

INSERT INTO foo (id) VALUES (1);
--[23505] ERROR: duplicate key value violates unique constraint "id_unique_constraint"




----------------
-- FOREIGN KEY  --
----------------

DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER UNIQUE);
INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (1);

DROP TABLE IF EXISTS bar CASCADE;
CREATE TABLE bar (id_foo INTEGER NOT NULL);
INSERT INTO bar (id_foo) VALUES (0);

-- Way 1 (validate existing values before creating FK)
ALTER TABLE bar
ADD CONSTRAINT bar_foo_id_fkey
FOREIGN KEY (id_foo)
REFERENCES foo (id);

-- Way 2 (skip validate existing values before creating FK)
ALTER TABLE bar
ADD CONSTRAINT bar_foo_id_fkey
FOREIGN KEY (id_foo)
REFERENCES foo (id) NOT VALID;

INSERT INTO bar (id_foo) VALUES (3);
-- [23503] ERROR: insert or update on table "bar" violates foreign key constraint "bar_foo_id_fkey"
-- Detail: Key (id_foo)=(3) is not present in table "foo".

SELECT
    'constraint=>'
    ,pgc.convalidated
   ,'pg_constraint=>'
   ,pgc.*
FROM pg_constraint pgc
WHERE 1=1
    AND pgc.conname = 'bar_foo_id_fkey'
    AND pgc.contype = 'f'
;
-- false


ALTER TABLE bar VALIDATE CONSTRAINT bar_foo_id_fkey;

SELECT
    'constraint=>'
    ,pgc.convalidated
   ,'pg_constraint=>'
   ,pgc.*
FROM pg_constraint pgc
WHERE 1=1
    AND pgc.conname = 'bar_foo_id_fkey'
    AND pgc.contype = 'f'
;
-- true

------------------------
------- DROP -----------
------------------------

-- All but NULL
ALTER TABLE foobar
DROP CONSTRAINT test;


-- NULL
ALTER TABLE bar
ALTER COLUMN id_foo DROP NOT NULL;
