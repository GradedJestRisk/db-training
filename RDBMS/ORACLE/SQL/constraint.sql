
----------------- Constraints --------------
--
-- Constraints:
-- - can be disabled
-- - can't be modified, you had to drop/create , but can use ENABLE NOVALIDATE no to check data

-- What happen is table creation based on another table => see table

-- Indexes 

ALTER TABLE table_name
DROP CONSTRAINT constraint_name;


/*

 -- constraint_type --
 
C - Check constraint on a table  
P - Primary key  
U - Unique key  
R - Referential integrity    (FK)
V - With check option, on a view  
O - With read only, on a view  
H - Hash expression  
F - Constraint that involves a REF column  
S - Supplemental logging
*/




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
   AND   cnt.table_name  =   UPPER('db_produit_support')
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


