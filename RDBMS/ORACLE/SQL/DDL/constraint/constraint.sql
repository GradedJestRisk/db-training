---------------------------------------------------------------------------
--------------      Overview                   -------------
---------------------------------------------------------------------------
--
-- Constraints:
-- - can be disabled
-- - can't be modified, you had to drop/create , but can use ENABLE NOVALIDATE no to check data

-- What happen is table creation based on another table => see table


-- constraint_type --
/* 
P - Primary key  
R - Referential integrity    (FK)

U - Unique key  
C - Check constraint on a table  

V - With check option, on a view  
O - With read only, on a view  
H - Hash expression  
F - Constraint that involves a REF column  
S - Supplemental logging
*/


---------------------------------------------------------------------------
--------------      CREATE                   -------------
---------------------------------------------------------------------------

-- ADD 
ALTER TABLE table_name
ADD CONSTRAINT constraint_name constraint_definition;

---------------------------------------------------------------------------
--------------      Relationship with indexes                   -------------
---------------------------------------------------------------------------

-- ADD 
ALTER TABLE table_name
ADD CONSTRAINT constraint_name constraint_definition;

DROP TABLE source;
CREATE TABLE source (
   id     NUMBER,
   status VARCHAR2(100)
)
;

DELETE FROM source;

INSERT INTO source (id, status) VALUES (1, 'Test');
INSERT INTO source (id, status) VALUES (2, 'Test');
INSERT INTO source (id, status) VALUES (3, 'Test');

COMMIT;

CREATE UNIQUE INDEX ndx_source_id ON source(id);

ALTER TABLE source
ADD CONSTRAINT unique_source 
PRIMARY KEY (id) 
USING INDEX ndx_source_id;

SELECT 
   cnt.table_name,
   cnt.constraint_name, 
   cnt.index_name 
FROM 
   all_constraints cnt
WHERE 1=1   
   AND cnt.constraint_name = UPPER('unique_source')
;

ALTER INDEX ndx_source_id UNUSABLE;

DELETE FROM source WHERE ID = 1;
-- ORA01502 - index is in unusable state

INSERT INTO source (id, status) VALUES (1, 'Test');
-- ORA01502 - index is in unusable state

DROP INDEX ndx_source_id;
-- ORA-02429 - cannot drop index used for reinforcement of unique/primry key

---------------------------------------------------------------------------
--------------      MODIFY                   -------------
---------------------------------------------------------------------------

-- ENABLE
ALTER TABLE table_name
ENABLE CONSTRAINT constraint_name;

-- DISABLE
ALTER TABLE table_name
DISABLE CONSTRAINT constraint_name;


---------------------------------------------------------------------------
--------------      REMOVE                   -------------
---------------------------------------------------------------------------

-- DROP 
ALTER TABLE table_name
DROP CONSTRAINT constraint_name;



---------------------------------------------------------------------------
--------------      Constraint                  -------------
---------------------------------------------------------------------------


-- Contraintes
-- Pour nom approximatif
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
   ,cnt.constraint_type
   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
  -- AND   cnt.index_owner = 'DBOFAP'
--   AND   cnt.constraint_name  =   'DB_HISTO_MODIF_RGA_TX_FK'
--   AND   cnt.constraint_name  NOT LIKE 'SYS%'
ORDER BY
   cnt.constraint_name ASC
;


-- Contraintes
-- Pour nom approximatif
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
   ,cnt.constraint_type
   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
  -- AND   cnt.index_owner = 'DBOFAP'
--   AND   cnt.constraint_name  =   'DB_HISTO_MODIF_RGA_TX_FK'
   AND   cnt.constraint_name  NOT LIKE 'SYS%'
;

-- Constraints
-- Given an owner
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
--   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
   AND   cnt.owner  =   'DBOFAP'
ORDER BY
   cnt.constraint_name ASC
;


-- Contraintes
-- Pour nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
--   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
   AND   cnt.constraint_name  =   'LK_STATUT_FK'
;


-- Contraintes
-- Pour table /  nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
--   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
   AND   cnt.table_name  =   UPPER('troncon')
;



-- Contraintes FK et PK
-- Pour table / nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
   AND   cnt.table_name        =   UPPER('filiere')
   AND   cnt.constraint_type   NOT IN ('P','R')
--   AND   cnt.constraint_name  =   'LK_STATUT_FK'
;



-- Contraintes désactivées
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.status            tt
   ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,' - '
--   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
  -- AND   cnt.constraint_type   IN   ('R')
   AND   cnt.r_owner             =   'DBOFAP'
   AND  ( cnt.status <> 'ENABLED'  OR validated <> 'VALIDATED' )
ORDER BY
   cnt.table_name ASC
;


---------------------------------------------------------------------------
--------------      Constraints - Columns                    -------------
---------------------------------------------------------------------------


-- Constraints + Columns
-- Given table / name
SELECT 
   'Contrainte PK=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
   ,cnt_cln.column_name   src_cln
   --,cnt.*
FROM 
   all_constraints cnt
      INNER JOIN all_cons_columns cnt_cln ON cnt_cln.constraint_name = cnt.constraint_name
WHERE 1=1
   AND   cnt.owner           =   'DBOFAP'
--   AND   cnt.table_name      =   'FILIERE'   
   AND   cnt.constraint_name   =   'SYS_C00504337'
;


-- Constraints + Columns
-- Given constraint / name
SELECT 
   'Contraint columns=>'  rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
   ,cnt_cln.column_name   src_cln
   --,cnt.*
FROM 
   all_constraints cnt
      INNER JOIN all_cons_columns cnt_cln ON cnt_cln.constraint_name = cnt.constraint_name
WHERE 1=1
   AND   cnt.owner           =   'DBOFAP'
   AND   cnt.constraint_name   =   'SYS_C00504337'
;



---------------------------------------------------------------------------
--------------      Constraint check time                    -------------
---------------------------------------------------------------------------

-- Contraint enforcing will be deferred (postponed) until COMMIT

-- 1) AS soon as constraint is created
ALTER TABLE 
   dbofap.tbl_test 
ADD CONSTRAINT 
   fk_tbl_tst
FOREIGN KEY 
   (foo)
REFERENCES
   dbofap.tbl_foo (foo)
   DEFERRABLE 
   INITIALLY DEFERRED
;

-- 2) Later..
ALTER TABLE 
   dbofap.tbl_test 
ADD CONSTRAINT 
   fk_tbl_tst
FOREIGN KEY 
   (foo)
REFERENCES
   dbofap.tbl_foo (foo)
   DEFERRABLE 
   INITIALLY IMMEDIATE
;

-- Now 
SET CONSTRAINT 
   fk_tbl_tst 
DEFERRED; 

-- Back to no postponing..
SET CONSTRAINT 
   fk_tbl_tst 
IMMEDIATE; 


-- FIL_ID_FILPRD => ID_FILPRD
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.r_constraint_name cnt_nm
   ,cnt.status            tt
   ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,DECODE(cnt.deferred,        'IMMEDIATE', 'ON QUERY',    'DEFERRED', 'ON COMMIT') cnt_check_time
   ,DECODE(cnt.deferrable, 'NOT DEFERRABLE',        'NO',  'DEFERRABLE',       'NO') cnt_check_time_modifiable
   ,' - '
   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
  -- AND   cnt.constraint_type   IN   ('R')
   AND   cnt.r_owner             =   'DBOFAP'
   AND   cnt.table_name          =   'FILIERE'   
   AND   cnt.constraint_name     =   'FK_FILIERE_CFGFIL_FILIERE'
;


-- FK - Check on query
SELECT 
   'Contrainte=>'         rqt_cnt   
   ,cnt.table_name        tbl
   ,cnt.constraint_name cnt_nm
   ,cnt.status            tt
   ,' - '
   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
   AND   cnt.constraint_type     =   'R'
   AND   cnt.r_owner             =   'DBOFAP'
 --  AND   cnt.table_name          =   'FILIERE'   
 --  AND   cnt.constraint_name     =   'FK_FILIERE_CFGFIL_FILIERE'
   AND cnt.deferred              =   'IMMEDIATE'
ORDER BY 
   cnt.table_name ASC
;

-- FK - Check on COMMIT
SELECT 
   'Contrainte=>'         rqt_cnt   
   ,cnt.table_name        tbl
   ,cnt.constraint_name cnt_nm
   ,cnt.status            tt
   ,' - '
   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
 --  AND   cnt.constraint_type     =   'R'
 --  AND   cnt.table_name          =   'FILIERE'   
   AND   cnt.r_owner             =   'DBOFAP'
   AND   cnt.deferred            =   'DEFERRED'
ORDER BY 
   cnt.table_name ASC
;


