DROP TABLE foobar;
DROP TABLE bar;
DROP TABLE foo;

CREATE TABLE foo (id INTEGER PRIMARY KEY);
-- Row to delete
INSERT INTO foo (id) VALUES(1);
-- Row to keep
INSERT INTO foo (id) VALUES(2);

CREATE TABLE bar (
    id INTEGER PRIMARY KEY,
    id_foo INTEGER REFERENCES foo (id)
);
-- Dependents rows of row to delete
INSERT INTO bar (id, id_foo) VALUES (1, 1);
INSERT INTO bar (id, id_foo) VALUES (2, 1);
INSERT INTO bar (id, id_foo) VALUES (3, 1);
-- Rows to keep
INSERT INTO bar (id, id_foo) VALUES (4, 2);
INSERT INTO bar (id, id_foo) VALUES (5, 2);

CREATE TABLE foobar (
    id INTEGER PRIMARY KEY,
    id_bar INTEGER REFERENCES bar (id),
    id_foo INTEGER REFERENCES foo (id)
);
-- Dependents rows of row to delete (via bar)
INSERT INTO foobar (id, id_bar, id_foo) VALUES (1, 1, 1);
INSERT INTO foobar (id, id_bar, id_foo) VALUES (2, 2, 1);
INSERT INTO foobar (id, id_bar, id_foo) VALUES (3, 2, 1);
-- Rows to keep
INSERT INTO foobar (id, id_bar, id_foo) VALUES (4, 4, 2);
INSERT INTO foobar (id, id_bar, id_foo) VALUES (5, 5, 2);


SELECT delete_dependent_rows('public','foo','1') || ' rows deleted';
-- 7 rows deleted

SELECT * FROM foo WHERE id = 1;
SELECT * FROM bar WHERE id_foo = 1;
SELECT * FROM foobar WHERE id_bar IN (1,2,3);

SELECT delete_dependent_rows('public','certification-centers','4') || ' rows deleted';