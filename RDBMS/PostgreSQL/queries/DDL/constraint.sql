-- https://stackoverflow.com/questions/4107915/postgresql-default-constraint-names
--
-- The standard names for indexes in PostgreSQL are:
--
-- {tablename}_{columnname(s)}_{suffix}
--
-- where the suffix is one of the following:
--
--     pkey for a Primary Key constraint
--     key for a Unique constraint
--     excl for an Exclusion constraint
--     idx for any other kind of index
--     fkey for a Foreign key
--     check for a Check constraint
--
-- Standard suffix for sequences is
--
--     seq for all sequences



------- ADD -----------

-- See table for supplying constraint in CREATE TABLE

-- UNIQUE
ALTER TABLE foo
ADD CONSTRAINT value_unique
UNIQUE(value);


-- FOREIGN KEY
ALTER TABLE bar
ADD CONSTRAINT value_foreign_key
FOREIGN KEY (value_foo)
REFERENCES foo (value);


------- DROP -----------
ALTER TABLE users_pix_roles
DROP CONSTRAINT test
;
