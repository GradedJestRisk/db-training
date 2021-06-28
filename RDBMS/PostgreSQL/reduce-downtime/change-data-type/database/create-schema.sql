CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION pg_buffercache;



DROP TABLE IF EXISTS foo;

-- https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER,
   referenced_value INTEGER CONSTRAINT referenced_value_unique UNIQUE
 );

INSERT INTO foo (value, referenced_value)
SELECT 1, floor(random() * 2147483627 + 1)::int
FROM
  --generate_series( 1, 5000000) -- 5 million => 2 minutes
    generate_series( 1, 1000000) -- 1 million => 40 seconds
ON CONFLICT ON CONSTRAINT referenced_value_unique DO NOTHING;

DROP TABLE IF EXISTS bar;

CREATE TABLE bar (
   value_foo INTEGER REFERENCES foo(referenced_value)
 );

INSERT INTO bar (value_foo)
SELECT f.referenced_value FROM foo f;
