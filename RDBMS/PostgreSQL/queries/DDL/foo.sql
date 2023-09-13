
-----------------------------------
-- PRIMARY KEY (NOT NULL UNIQUE) --
-----------------------------------

DROP TABLE IF EXISTS foo;
CREATE TABLE foo (id INTEGER);

INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (1);

ALTER TABLE foo ADD CONSTRAINT id_not_null
CHECK (id IS NOT NULL);

DROP INDEX IF EXISTS id_unique_index;
CREATE UNIQUE INDEX CONCURRENTLY id_unique_index  ON foo (id);


CREATE UNIQUE NOT NULL INDEX CONCURRENTLY id_unique_index  ON foo (id);

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY
USING INDEX id_unique_index;
