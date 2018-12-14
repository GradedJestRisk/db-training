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




---------------------------------------------------------------------------
--------------     Sample table => To move elsewhere                  -------------
---------------------------------------------------------------------------

DROP TABLE tbl_foo;

CREATE TABLE tbl_foo (foo VARCHAR2(32) PRIMARY KEY)
;

INSERT INTO tbl_foo (foo) VALUES ('bar');
INSERT INTO tbl_foo (foo) VALUES ('barbar');

COMMIT
;

SELECT * FROM tbl_foo
;


DROP TABLE tbl_test
;

CREATE TABLE tbl_test (id INTEGER, foo VARCHAR2(32) NOT NULL)
;

INSERT INTO tbl_test (id, foo) VALUES (1, 'bar');
INSERT INTO tbl_test (id, foo) VALUES (2, 'barbar');

SELECT * FROM tbl_test
;

ALTER TABLE 
   tbl_test 
ADD CONSTRAINT 
   pk_tbl_tst 
PRIMARY KEY (id)
;

ALTER TABLE 
   tbl_test 
ADD CONSTRAINT 
   fk_tbl_tst
FOREIGN KEY (foo)
REFERENCES
   tbl_foo (foo)
;


CREATE INDEX 
   ndx_tbl_tst 
ON 
   tbl_test(foo);



COMMIT
;

CREATE SYNONYM syn_tbl_test
FOR tbl_test
;

SELECT *
FROM syn_tbl_test
;


GRANT SELECT 
ON tbl_test
TO system
;

SELECT *
FROM all_tab_privs prv_tls
WHERE 1=1
   AND prv_tls.grantee      =   'SYSTEM'
   AND prv_tls.table_name   =   'TBL_TEST'
;

SELECT 
   pck.status   
--   ,pck.*
FROM 
   all_objects pck
WHERE 1=1
   AND pck.object_type   =   'PROCEDURE'
   AND pck.owner         =   'FAP'
   AND pck.object_name   =   UPPER('prc_test')
;


RENAME tbl_test TO tbl_test_cible;

DROP TABLE 
   tbl_test;

SELECT * FROM tbl_test_cible;




