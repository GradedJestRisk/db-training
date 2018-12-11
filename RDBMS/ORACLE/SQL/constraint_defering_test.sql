---------------------------------------------------------------------------
--------------     ON QUERY            -------------
---------------------------------------------------------------------------

-- referency

DROP TABLE test_read_consistency;

CREATE TABLE test_read_consistency (
   id          NUMBER PRIMARY KEY,
   id_parent   NUMBER,
   node_level  NUMBER
);

ALTER TABLE 
   test_read_consistency
ADD CONSTRAINT 
   fk_test_read_consistency
FOREIGN KEY 
   (id_parent)
REFERENCES
   test_read_consistency (id)   
;


INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (1, NULL, 1);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (2, 1,    2);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (3, NULL, 1);

INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (4, -1, 1);

/*
ERROR at line 1:
ORA-0022911: integrity constraint (FK_TEST_READ_CONSISTENCY) violated - parent key not found
*/


---------------------------------------------------------------------------
--------------   ON COMMIT:   DEFERRABLE  INITIALLY DEFERRED            -------------
---------------------------------------------------------------------------

-- referency

DROP TABLE test_read_consistency;

CREATE TABLE test_read_consistency (
   id          NUMBER PRIMARY KEY,
   id_parent   NUMBER,
   node_level  NUMBER
);

ALTER TABLE 
   test_read_consistency
ADD CONSTRAINT 
   fk_test_read_consistency
FOREIGN KEY 
   (id_parent)
REFERENCES
   test_read_consistency (id)
   DEFERRABLE 
   INITIALLY DEFERRED
;


INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (1, NULL, 1);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (2, 1,    2);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (3, NULL, 1);

INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (4, -1, 1);

SELECT * FROM test_read_consistency;

SELECT
   tst.node_level,
   tst.ID
FROM
    test_read_consistency tst
WHERE 1=1
CONNECT BY PRIOR
   tst.id = tst.id_parent
START WITH
   tst.id = 1
;

COMMIT;

/*
ERROR at line 1:
ORA-02091: transaction rolled back
ORA-00001: integrity constraint (fk_test_read_consistency) violated - parent key not found
*/


---------------------------------------------------------------------------
--------------   ON COMMIT:   DEFERRABLE  INITIALLY IMMEDIATE            -------------
---------------------------------------------------------------------------

-- referency

DROP TABLE test_read_consistency;

CREATE TABLE test_read_consistency (
   id          NUMBER PRIMARY KEY,
   id_parent   NUMBER,
   node_level  NUMBER
);

ALTER TABLE 
   test_read_consistency
ADD CONSTRAINT 
   fk_test_read_consistency
FOREIGN KEY 
   (id_parent)
REFERENCES
   test_read_consistency (id)
   DEFERRABLE 
   INITIALLY IMMEDIATE
;


INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (1, NULL, 1);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (2, 1,    2);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (3, NULL, 1);

INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (4, -1, 1);
/*
ERROR at line 1:
ORA-0022911: integrity constraint (FK_TEST_READ_CONSISTENCY) violated - parent key not found
*/

SET CONSTRAINTS fk_test_read_consistency DEFERRED;

INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (4, -1, 1);
-- 1 row inserted

COMMIT;
/*
ERROR at line 1:
ORA-02091: transaction rolled back
ORA-00001: integrity constraint (fk_test_read_consistency) violated - parent key not found
*/

SET CONSTRAINTS fk_test_read_consistency IMMEDIATE;

INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (4, -1, 1);
/*
ERROR at line 1:
ORA-0022911: integrity constraint (FK_TEST_READ_CONSISTENCY) violated - parent key not found
*/
