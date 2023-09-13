DROP TABLE IF EXISTS foo;
DROP TABLE IF EXISTS foo_tmp;


CREATE TABLE foo (id INTEGER , name TEXT);
INSERT INTO foo (id, name) VALUES (1, 'a');
INSERT INTO foo (id, name) VALUES (2, 'b');
INSERT INTO foo (id, name) VALUES (3, 'c');


CREATE TABLE foo_tmp (id INTEGER , name TEXT);
INSERT INTO foo_tmp (id, name) VALUES (1, 'a');
INSERT INTO foo_tmp (id, name) VALUES (2, 'b');
INSERT INTO foo_tmp (id, name) VALUES (4, 'd');

SELECT
    *
FROM
	"foo" a FULL OUTER JOIN "foo_tmp" a_tmp USING (id)
WHERE 1=1
    AND (a.id IS NULL OR a_tmp.id IS NULL);

SELECT
    *
FROM
	"foo" a FULL OUTER JOIN "foo_tmp" a_tmp USING (id, name)
WHERE 1=1
    AND (a.id IS NULL OR a_tmp.id IS NULL);