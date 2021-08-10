-------------------------
-- FK and NOT NULL  ---
-------------------------

-- TL, DR:
-- - you can create a FK without NOT NULL constraint
-- - you cannot create a FK referencing NULLABLE column

DROP TABLE IF EXISTS foo;
-- CREATE TABLE foo (id SERIAL PRIMARY KEY);
-- PRIMARY KEY is a shorthand for NOT NULL UNIQUE
CREATE TABLE foo (id INTEGER NOT NULL UNIQUE);

INSERT INTO foo (id) VALUES (NULL);
-- [23502] ERROR: null value in column "id" violates not-null constraint

INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (0);
-- [23505] ERROR: duplicate key value violates unique constraint "foo_id_key"

INSERT INTO foo (id) VALUES (1);

SELECT * FROM foo;

DROP TABLE IF EXISTS bar;
CREATE TABLE bar (id SERIAL PRIMARY KEY, id_foo INTEGER REFERENCES foo(id));
INSERT INTO bar (id, id_foo) VALUES (0, NULL);
INSERT INTO bar (id, id_foo) VALUES (1, 1);
SELECT * FROM bar;

DROP TABLE IF EXISTS foobar;
CREATE TABLE foobar (id SERIAL PRIMARY KEY, id_foo INTEGER REFERENCES foo(id) NOT NULL);
INSERT INTO foobar (id, id_foo) VALUES (0, NULL);
-- [23502] ERROR: null value in column "id_foo" violates not-null constraint

INSERT INTO foobar (id, id_foo) VALUES (1, 1);
SELECT * FROM foobar;


