CREATE EXTENSION pg_stat_statements;

DROP TABLE IF EXISTS foo;

-- https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER
 );

INSERT INTO foo (value)
SELECT floor(random() * 2147483627 + 1)::int
FROM generate_series( 1, 10000000);

DROP TABLE IF EXISTS bar;

CREATE TABLE bar (
   value_foo INTEGER REFERENCES foo(value)
 );

INSERT INTO bar (value_foo)
SELECT value_foo FROM foo;
