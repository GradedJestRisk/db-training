DROP TABLE IF EXISTS foo;

-- Named constraint
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER CONSTRAINT value_unique UNIQUE
 );

-- Dafault-named constraint
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER UNIQUE
 );

DROP TABLE IF EXISTS bar;

CREATE TABLE bar (
   value_foo INTEGER
 );

