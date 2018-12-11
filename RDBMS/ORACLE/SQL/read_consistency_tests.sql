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


-- 1 node with 2 childrens
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (1, NULL, 1);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (2, 1,    2);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (7, 1,    2);

-- 1 node with no childrens
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (3, NULL, 1);

-- 1 node with 2 childrens
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (4, NULL, 1);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (5, 4, 2);
INSERT INTO test_read_consistency (id, id_parent, node_level) VALUES (6, 4, 2);


COMMIT;


SELECT * 
FROM test_read_consistency
;

SELECT
   LEVEL,
   tst.id
FROM
    test_read_consistency tst
WHERE 1=1
CONNECT BY PRIOR
   tst.id = tst.id_parent
START WITH
   tst.node_level = 1
;




