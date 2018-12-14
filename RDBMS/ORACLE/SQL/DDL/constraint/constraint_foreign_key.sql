---------------------------------------------------------------------------
--------------      Create                    -------------
---------------------------------------------------------------------------

DROP TABLE test_read_consistency;

CREATE TABLE test_read_consistency (
   id          NUMBER PRIMARY KEY,
   id_parent   NUMBER,
   node_level  NUMBER
);

-- Source and target are the same here
ALTER TABLE 
   test_read_consistency
ADD CONSTRAINT 
   fk_test_read_consistency
FOREIGN KEY 
   (id_parent)
REFERENCES
   test_read_consistency (id)   
;


---------------------------------------------------------------------------
--------------     Modify                   -------------
---------------------------------------------------------------------------

ALTER TABLE dbofap.TBL_FOO DISABLE CONSTRAINT FK_TBL_FOO;
ALTER TABLE dbofap.TBL_FOO ENABLE CONSTRAINT FK_TBL_FOO;

-- Query to disable
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

---------------------------------------------------------------------------
--------------     Delete                   -------------
---------------------------------------------------------------------------

ALTER TABLE dbofap.TBL_FOO DROP CONSTRAINT FK_TBL_FOO;



---------------------------------------------------------------------------
--------------     SELECT                  -------------
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
   AND   cnt.table_name          =   'TRONCON'   
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


-- FK constraint
-- Deferred check
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
 --  AND   cnt.table_name          =   'FILIERE'   
 --  AND   cnt.r_constraint_name   =   'PK_TV_ETAT_FAP'
   AND   cnt.DEFERRED            <> 'IMMEDIATE'
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
   AND   cnt_cln.constraint_name    =   'T'
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
   ,cnt.constraint_name cnt_nm
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
   AND   cnt.constraint_type   IN   ('R')
   AND   cnt.r_owner             =   'DBOFAP'
   AND   cbl_cln.table_name      =   'TRONCON'   
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
--------------     Index and Foreign keys                   -------------
---------------------------------------------------------------------------


-- PRO
/* https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:9534815800346986002*
Have you got an index on the child table on the FK columns?
If the answer's no, then Oracle Database will do a full scan of the child table for each row you delete from the parent. 
*/

-- FK without index
SELECT 
   cnt.table_name,
   cnt.constraint_name  cnt_fk_nm,
   src_cln.column_name  src_column
FROM 
   all_constraints cnt 
            INNER JOIN all_cons_columns src_cln ON src_cln.constraint_name = cnt.constraint_name
WHERE 1=1
   AND cnt.owner = 'DBOFAP'
--   AND cnt.table_name             =   'TEST_READ_CONSISTENCY'
   AND cnt.constraint_type   IN   ('R')
   AND NOT EXISTS (   
      SELECT 1 
      FROM all_indexes ndx 
         INNER JOIN all_ind_columns ndx_cln ON ndx_cln.index_name = ndx.index_name
      WHERE 1=1
         AND   ndx_cln.column_name = src_cln.column_name )
;


-- CON
/*
https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:292016138754

So, when do you NOT need to index a foriegn key. In general when the following conditions are met:
o you do NOT delete from the parent table. (especially with delete cascade -- it is a double whammy)
o you do NOT update the parent tables unique/primary key value.
o you do NOT join from the PARENT to the CHILD (like DEPT->EMP).

If you satisfy all three above, feel free to skip the index, it is not needed. 
If you do any of the above, be aware of the consequences.  
*/

-- FK with indexes (targeting some specific-named tables, here _TV) / Name
SELECT 
   ndx.table_name       child_table,
   ndx.index_name       ndx_fk_nm, 
   ndx_cln.column_name  ndx_fk_cln,  
   cnt.constraint_name  cnt_fk_nm,
   cbl_cln.table_name   parent_table
FROM 
   all_indexes ndx 
      INNER JOIN all_ind_columns ndx_cln ON ndx_cln.index_name = ndx.index_name
      INNER JOIN all_constraints cnt ON cnt.table_name = ndx.table_name
            INNER JOIN all_cons_columns src_cln ON src_cln.constraint_name = cnt.constraint_name
            INNER JOIN all_cons_columns cbl_cln ON cbl_cln.constraint_name = cnt.r_constraint_name 
WHERE 1=1
--   AND table_name = 'TRONCON'
   AND cnt.constraint_type   IN   ('R')
   AND ndx.index_name      LIKE   '%_FK'
   AND cbl_cln.table_name  LIKE   'TV_%'
   AND cbl_cln.column_name = ndx_cln.column_name
ORDER BY
   ndx.table_name, 
   ndx.index_name
;

-- FK with indexes (targeting some specific-named tables, here _TV) / Size
SELECT 
   --ndx.table_name,
   --ndx.index_name,
   --ROUND( (sgm.blocks * 8192 / POWER(1024,3) ), 2) size_gb 
   ROUND( (SUM(sgm.blocks) * 8192 / POWER(1024,3) ), 2) size_gb 
FROM
   dba_indexes   ndx
      INNER JOIN dba_segments  sgm  ON (sgm.segment_name = ndx.index_name)
WHERE  1=1
   AND   ndx.index_name IN (
      SELECT 
         ndx.index_name
      FROM 
         all_indexes ndx 
            INNER JOIN all_ind_columns ndx_cln ON ndx_cln.index_name = ndx.index_name
            INNER JOIN all_constraints cnt ON cnt.table_name = ndx.table_name
                  INNER JOIN all_cons_columns src_cln ON src_cln.constraint_name = cnt.constraint_name
                  INNER JOIN all_cons_columns cbl_cln ON cbl_cln.constraint_name = cnt.r_constraint_name 
      WHERE 1=1
      --   AND table_name = 'TRONCON'
         AND cnt.constraint_type   IN   ('R')
         AND ndx.index_name      LIKE   '%_FK'
         AND cbl_cln.table_name  LIKE   'TV_%'
         AND cbl_cln.column_name = ndx_cln.column_name
)
;
