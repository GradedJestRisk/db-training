CREATE TABLE IF NOT EXISTS cacheme (id integer)
WITH (autovacuum_enabled = off);

INSERT INTO cacheme (id)
SELECT id FROM GENERATE_SERIES(1, 10000000) AS id;