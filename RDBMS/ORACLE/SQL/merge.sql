---------------------------------------------------------------------------
--------------      merge sur NUMBER               -------------
---------------------------------------------------------------------------


DROP TABLE source;
CREATE TABLE source(
   id      NUMBER,
   status  VARCHAR2(100)
);

INSERT INTO source (id, status) VALUES (0,'in source and target (originally:source)');
INSERT INTO source (id, status) VALUES (1,'in source only');
INSERT INTO source (id, status) VALUES (NULL,'in source only - NULL id');

SELECT * FROM source;

DROP TABLE target;
CREATE TABLE target(
   id NUMBER,
   status  VARCHAR2(100)
);

INSERT INTO target (id, status) VALUES (0,'in source and target (originally:target)');
INSERT INTO target (id, status) VALUES (2,'in target only');

SELECT * FROM target;

MERGE INTO target t
  USING source s
    ON (s.id = t.id)
  WHEN MATCHED THEN
    UPDATE SET t.status = s.status
  WHEN NOT MATCHED THEN
    INSERT (id, status)
    VALUES (s.id, s.status)
;?

SELECT * FROM target;


---------------------------------------------------------------------------
--------------      merge sur NUMBER (2 colonnes)              -------------
---------------------------------------------------------------------------


DROP TABLE source;
CREATE TABLE source(
   id1      NUMBER,
   id2      NUMBER,
   status  VARCHAR2(100)
);

INSERT INTO source (id1, id2, status) VALUES (0,0,'in source and target with 0 (originally:source)');
INSERT INTO source (id1, id2, status) VALUES (0,NULL,'in source and target with NULL (originally:source)');
INSERT INTO source (id1, id2, status) VALUES (1,0,'in source only');


SELECT * FROM source;

DROP TABLE target;
CREATE TABLE target(
   id1      NUMBER,
   id2      NUMBER,
   status  VARCHAR2(100)
);

INSERT INTO target (id1, id2, status) VALUES (0,0,'in source and target with 0 (originally:target)');
INSERT INTO target (id1, id2, status) VALUES (0,NULL,'in source and target with NULL (originally:target)');
INSERT INTO target (id1, id2, status) VALUES (2,0,'in target only');


SELECT * FROM target;

MERGE INTO target t
  USING source s
    ON (s.id1 = t.id1 AND s.id2 = t.id2)
  WHEN MATCHED THEN
    UPDATE SET t.status = s.status
  WHEN NOT MATCHED THEN
    INSERT (id1, id2, status)
    VALUES (s.id1, s.id2, s.status)
;?

SELECT * FROM target;


---------------------------------------------------------------------------
--------------      merge sur VARCHAR               -------------
---------------------------------------------------------------------------

DROP TABLE source;
CREATE TABLE source(
   col1    VARCHAR2(100),
   col2    VARCHAR2(100)
);

INSERT INTO source (col1, col2) VALUES ('A','in source and target (originally:source)');
INSERT INTO source (col1, col2) VALUES ('B','in source only');
INSERT INTO source (col1, col2) VALUES ('','in source only - col1 = '''' ');
INSERT INTO source (col1, col2) VALUES (NULL,'in source only - col1 = NULL ');

SELECT * FROM source;

DROP TABLE target;
CREATE TABLE target(
   col1    VARCHAR2(100),
   col2    VARCHAR2(100)
);

INSERT INTO target (col1, col2) VALUES ('A','in source and target (originally:target)');
INSERT INTO target (col1, col2) VALUES ('C','in target only');

SELECT * FROM target;

MERGE INTO target t
  USING source s
    ON (s.col1 = t.col1)
  WHEN MATCHED THEN
    UPDATE SET t.col2 = s.col2
  WHEN NOT MATCHED THEN
    INSERT (col1, col2)
    VALUES (s.col1, s.col2)
;

SELECT * FROM target;
    
    