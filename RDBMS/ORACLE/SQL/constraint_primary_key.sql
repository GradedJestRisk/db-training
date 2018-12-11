
---------------------------------------------------------------------------
--------------     PK                  -------------
---------------------------------------------------------------------------

-- 3 ways
CREATE TABLE dbofap.tbl_foo (foo VARCHAR2(32) PRIMARY KEY, bar INTEGER);

CREATE TABLE dbofap.tbl_test (id INTEGER, foo VARCHAR2(32) NOT NULL, bar INTEGER UNIQUE, barbar INTEGER);

ALTER TABLE 
   dbofap.tbl_test 
ADD CONSTRAINT 
   pk_tbl_tst 
PRIMARY KEY (id)
;


ALTER TABLE dbofap.tbl_test DROP CONSTRAINT PK_TBL_TST;


-- Contraintes FK et PK
-- Pour table / nom
SELECT 
   'Contrainte PK=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.index_name        ndx_nm
   ,cnt.status            tt
   ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,' - ' x
   --,cnt.*
FROM 
   all_constraints cnt
WHERE 1=1
   AND   cnt.owner           =   'DBOFAP'
   AND   cnt.table_name        =   UPPER('tbl_test')
   AND   cnt.constraint_type   IN ('P')
--   AND   cnt.constraint_name  =   'LK_STATUT_FK'
;



-- Contraintes PK
-- Pour table / nom
SELECT 
   'Contrainte PK=>'         rqt_cnt
   ,cnt.constraint_name   cnt_nm
   ,cnt.index_name        ndx_nm
   ,cnt.status            tt
   ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,' - ' x
   ,cnt.*
FROM 
   all_constraints cnt
WHERE 1=1
   AND   cnt.constraint_type   IN   ('P')
   AND   cnt.owner             =   'DBOFAP'
   AND   cnt.table_name        =   'FILIERE'   
   AND   cnt.constraint_name   =   'PK_FILIERE'
;




-- Contraintes PL  + colonne
-- Pour table / nom
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
   AND   cnt.constraint_type =   'P'
   AND   cnt.owner           =   'DBOFAP'
   AND   cnt.table_name      =   'FILIERE'   
   --AND   cnt.r_constraint_name   =   'PK_TV_ETAT_FAP'
;