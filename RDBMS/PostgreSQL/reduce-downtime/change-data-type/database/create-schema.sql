CREATE EXTENSION pg_stat_statements;

DROP TABLE IF EXISTS foo;

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER
 );

INSERT INTO foo (value)
SELECT floor(random() * 2147483627 + 1)::int
FROM generate_series( 1, 10000000);
