-- referency

DROP TABLE source;
CREATE TABLE source (
   id NUMBER,
   id2 NUMBER,
   status VARCHAR2(100)
)
;

DROP TABLE target;

CREATE TABLE target (
   id NUMBER,
   id2 NUMBER,
   status VARCHAR2(100)
)
;

TRUNCATE TABLE source;
INSERT INTO source (id, id2, status) VALUES (1, 1, 'Test');
INSERT INTO source (id, id2, status) VALUES (2, 2, 'Test');
INSERT INTO source (id, id2, status) VALUES (2, 3, 'Test');

TRUNCATE TABLE target;
INSERT INTO target (id, id2, status) VALUES (1, 4, 'Test');

COMMIT;


SELECT * FROM source;
SELECT * FROM target;

