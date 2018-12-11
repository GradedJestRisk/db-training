
---------------------------------------------------------------------------
--------------     FK                  -------------
---------------------------------------------------------------------------





-- FIL_ID_FILPRD => ID_FILPRD
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.r_constraint_name cnt_nm
   ,cnt.status            tt
   ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,DECODE(cnt.deferred,        'IMMEDIATE', 'ON COMMIT',    'DEFERRED', 'ON QUERY') cnt_check_time
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


/*
Source / r�f�ren�ante : FILIERE.ID_ETATFIL
Cible / r�f�ren��e : TV_ETAT_FAP.ID_ETATFIL
*/


-- Contraintes FK (ensemble)
-- Pour table r�f�ren�ante (ex: FILIERE) / nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.r_constraint_name cnt_nm
   ,cnt.status            tt
   ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,DECODE(cnt.deferred,        'IMMEDIATE', 'ON COMMIT',    'DEFERRED', 'ON QUERY') cnt_check_time
   ,DECODE(cnt.deferrable, 'NOT DEFERRABLE',        'NO',  'DEFERRABLE',       'NO') cnt_check_time_modifiable
   ,' - '
   ,cnt.* 
FROM 
   all_constraints cnt
WHERE 1=1
  -- AND   cnt.constraint_type   IN   ('R')
   AND   cnt.r_owner             =   'DBOFAP'
   AND   cnt.table_name          =   'FILIERE'   
   AND   cnt.r_constraint_name   =   'PK_TV_ETAT_FAP'
;


-- Contraintes FK (table r�f�ren�ante : FILIERE)
-- Pour contrainte / nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt_cln.constraint_name   nm
   ,cnt_cln.table_name        tbl
   ,cnt_cln.column_name       on_delete
   ,' - '
   --,cnt_cln.* 
FROM 
   all_cons_columns cnt_cln
WHERE 1=1
   AND   cnt_cln.owner              =   'DBOFAP'
   AND   cnt_cln.constraint_name    =   'FK_FILIERE_FPRETA_TV_ETAT_'
;


-- Contraintes FK (table r�f�ren��e : TV_ETAT_FAP)
-- Pour contrainte / nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt_cln.constraint_name   nm
   ,cnt_cln.table_name        tbl
   ,cnt_cln.column_name       cln
   ,' - '
   ,cnt_cln.* 
FROM 
   all_cons_columns cnt_cln
WHERE 1=1
   AND   cnt_cln.owner              =   'DBOFAP'
   AND   cnt_cln.constraint_name    =   'PK_TV_ETAT_FAP'
;

-- Contraintes FK (table r�f�ren��e : TV_ETAT_FAP)
-- Pour table / nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt_cln.constraint_name   nm
   ,cnt_cln.table_name        tbl
   ,cnt_cln.column_name       on_delete
   ,' - '
   --,cnt_cln.* 
FROM 
   all_cons_columns cnt_cln
WHERE 1=1
   AND   cnt_cln.owner        =   'DBOFAP'
   AND   cnt_cln.table_name   =   'ASS_ASSORT'
;


-- Contraintes FK (ensemble)
-- Pour table cible / nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.r_constraint_name cnt_nm
   ,cnt.status            tt
  -- ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,' SRC => '
   ,src_cln.table_name    src_tbl
   ,src_cln.column_name   src_cln
   ,' CBL => '
   ,cbl_cln.table_name    cbl_tbl
   ,cbl_cln.column_name   cbl_cln
FROM 
   all_constraints cnt
      INNER JOIN all_cons_columns src_cln ON src_cln.constraint_name = cnt.constraint_name
      INNER JOIN all_cons_columns cbl_cln ON cbl_cln.constraint_name = cnt.r_constraint_name
WHERE 1=1
  -- AND   cnt.constraint_type   IN   ('R')
   AND   cnt.r_owner             =   'DBOFAP'
   AND   cbl_cln.table_name      =   'TV_NATURE_DE_TRONCON'   
   --AND   cnt.r_constraint_name   =   'PK_TV_ETAT_FAP'
;

-- Contraintes FK (ensemble)
-- Pour table source / nom
SELECT 
   'Contrainte=>'         rqt_cnt
   ,cnt.r_constraint_name cnt_nm
   ,cnt.status            tt
  -- ,cnt.table_name        tbl
   ,cnt.delete_rule       on_delete
   ,' SRC => '
   ,src_cln.table_name    src_tbl
   ,src_cln.column_name   src_cln
   ,' CBL => '
   ,cbl_cln.table_name    cbl_tbl
   ,cbl_cln.column_name   cbl_cln
FROM 
   all_constraints cnt
      INNER JOIN all_cons_columns src_cln ON src_cln.constraint_name = cnt.constraint_name
      INNER JOIN all_cons_columns cbl_cln ON cbl_cln.constraint_name = cnt.r_constraint_name
WHERE 1=1
  -- AND   cnt.constraint_type   IN   ('R')
   AND   cnt.r_owner             =   'DBOFAP'
   AND   src_cln.table_name      =   'ASS_ASSORT'   
   --AND   cnt.r_constraint_name   =   'PK_TV_ETAT_FAP'
;


---------------------------------------------------------------------------
--------------     Enable/disable referencing FK                    -------------
---------------------------------------------------------------------------


SELECT 
    'ALTER TABLE '|| cnt_fk_source.table_name || ' DISABLE CONSTRAINT ' || cnt_fk_source.constraint_name || ';' 
--  'ALTER TABLE '|| cnt_fk_source.table_name || ' ENABLE CONSTRAINT ' || cnt_fk_source.constraint_name || ';' 
  --cnt_fk_source.*
FROM 
   all_constraints cnt_fk_source
      INNER JOIN all_constraints cnt_pk_cible ON cnt_fk_source.r_constraint_name =  cnt_pk_cible.constraint_name
WHERE 1=1
   AND cnt_fk_source.constraint_type =   'R' 
   AND cnt_pk_cible.constraint_type  IN   ('P', 'U')
   AND cnt_pk_cible.table_name       =   upper('tbl_test')
   --AND cnt_fk_source.status          =   'ENABLED' 
;
ALTER TABLE dbofap.TBL_FOO DISABLE CONSTRAINT FK_TBL_FOO;
       ALTER TABLE TBL_FOO DISABLE CONSTRAINT FK_TBL_FOO
ALTER TABLE dbofap.TBL_FOO ENABLE CONSTRAINT FK_TBL_FOO;




select * from tbl_foo;

SELECT 
    cnt_fk_source.table_name,
    cnt_fk_source.constraint_name,
    cnt_fk_source.status
FROM 
   all_constraints cnt_fk_source
      INNER JOIN all_constraints cnt_pk_cible ON cnt_fk_source.r_constraint_name =  cnt_pk_cible.constraint_name
WHERE 1=1
   AND cnt_fk_source.constraint_type =   'R' 
   AND cnt_pk_cible.constraint_type  IN   ('P', 'U')
   AND cnt_pk_cible.table_name       =   UPPER('filiere')
--   AND cnt_fk_source.status          =   'ENABLED' 
;



