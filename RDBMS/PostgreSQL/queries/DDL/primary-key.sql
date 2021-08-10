-- Primary key is
-- - UNIQUE
-- - NOT NULL

DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER);
INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (NULL);

CREATE UNIQUE INDEX idx ON foo(id);

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY
USING INDEX idx;

-- [23502] ERROR: column "id" of relation "foo" contains null values

DELETE FROM foo WHERE id IS NULL;

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY
USING INDEX idx;
-- [00000] ALTER TABLE / ADD CONSTRAINT USING INDEX will rename index "idx" to "foo_pkey"
-- completed in 8 ms

INSERT INTO foo (id) VALUES (1);
INSERT INTO foo (id) VALUES (NULL);
-- [23502] ERROR: null value in column "id" of relation "foo" violates not-null constraint