TRUNCATE TABLE foo;

INSERT INTO foo (id)
SELECT floor(random() * 100 + 1)::int
FROM generate_series( 1, 10000);


SELECT *
FROM foo;

CREATE INDEX on foo(id);

SELECT count(1) FROM foo;

SELECT f1.id, f2.id FROM foo f1, foo f2 LIMIT 100;

SELECT COUNT(1) FROM (SELECT f1.id, f2.id FROM foo f1, foo f2) t