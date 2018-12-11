-- ORACLE implicitly create an index SYS_C* to ensure PRIMERY KEY constraints when
-- - using "PRIMARY KEY"
-- - using "PRIMARY KEY USING INDEX (no index name)"


-- ORACLE explictly use existing index to ensure PRIMERY KEY constraints when
-- - using "PRIMARY KEY"
-- - using "PRIMARY KEY USING INDEX <INDEX_NAME>"$

-- Because get_dependent_ddl INDEX include implicitly-created indexes
-- If get_dependent_ddl CONSTRAINT result is executed beforehand (so implictly create indexes)
-- Then  when get_dependent_ddl INDEX result is executed, it fails with  ORA-01408 such column list already_indexed
-- SO execute INDEX before CONSTRAINTS !!


drop table tbl_index;
create table tbl_index (id INTEGER PRIMARY KEY);

drop table tbl_index;
create table tbl_index (id INTEGER PRIMARY KEY USING INDEX);

drop table tbl_index;
create table tbl_index (id INTEGER);

ALTER TABLE tbl_index
ADD CONSTRAINT 
   tbl_index_pk
PRIMARY KEY (id);


DROP TABLE tbl_index;
CREATE TABLE tbl_index (id INTEGER);
CREATE INDEX ndx_pk ON tbl_index(id);

ALTER TABLE tbl_index
ADD CONSTRAINT 
   tbl_index_pk
PRIMARY KEY (id)
   USING INDEX ndx_pk;


SELECT 
  *
FROM 
   all_indexes ndx
WHERE 1=1
--   AND ndx.table_name   =  UPPER('tbl_test')
     AND ndx.table_name   =  UPPER('tbl_index')
;


SELECT cnt.constraint_name   cnt_nm
FROM 
   user_constraints cnt
WHERE 1=1
   AND   cnt.table_name        =    UPPER('tbl_index')
   AND   cnt.constraint_type   IN ('P')
;


-- Indexes
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'INDEX', 
      base_object_name    =>   UPPER('tbl_index')
--      base_object_schema  =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;

  CREATE UNIQUE INDEX "FAP"."SYS_C00503824" ON "FAP"."TBL_INDEX" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "FAP_DATA" 
;

-- Constraints PK + check + inline (not FK)
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'CONSTRAINT', 
      base_object_name    =>    UPPER('tbl_index')
   ) table_ddl
FROM 
   dual
;

  ALTER TABLE "FAP"."TBL_INDEX" ADD PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "FAP_DATA"  ENABLE

  ;
  
  
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
   user_constraints cnt
WHERE 1=1
---   AND   cnt.owner           =   'DBOFAP'
   AND   cnt.table_name        =    UPPER('tbl_index')
   AND   cnt.constraint_type   IN ('P')
--   AND   cnt.constraint_name  =   'LK_STATUT_FK'
;



---------------------------------------------------------------------------
--------------     Unsuccessful scenario              -------------
---------------------------------------------------------------------------
--  constraints THEN index

CREATE TABLE tbl_index (id INTEGER);

ALTER TABLE tbl_index
ADD CONSTRAINT 
   tbl_index_pk
PRIMARY KEY (id);

-- Constraints PK + check + inline (not FK)
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'CONSTRAINT', 
      base_object_name    =>    UPPER('tbl_index')
   ) table_ddl
FROM 
   dual
;


-- Indexes
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'INDEX', 
      base_object_name    =>   UPPER('tbl_index')
--      base_object_schema  =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;

SELECT cnt.constraint_name   cnt_nm
FROM 
   user_constraints cnt
WHERE 1=1
   AND   cnt.table_name        =    UPPER('tbl_index')
   AND   cnt.constraint_type   IN ('P')
;

SELECT ndx.index_name
FROM 
   all_indexes ndx
WHERE 1=1
AND ndx.table_name   =  UPPER('tbl_index')
;

ALTER TABLE tbl_index DROP CONSTRAINT TBL_INDEX_PK;


  ALTER TABLE "FAP"."TBL_INDEX" ADD PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "FAP_DATA"  ENABLE
  ;

    CREATE UNIQUE INDEX "FAP"."TBL_INDEX_PK" ON "FAP"."TBL_INDEX" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "FAP_DATA" 
  ;
  
  CREATE UNIQUE INDEX "FAP"."TBL_INDEX_PK" ON "FAP"."TBL_INDEX" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "FAP_DATA" ;

--ORA-01408 such column list already_indexed

---------------------------------------------------------------------------
--------------      Successful scenario               -------------
---------------------------------------------------------------------------


-- Successful scenario: index THEN constraints

--  constraints THEN index

DROP TABLE tbl_index;
CREATE TABLE tbl_index (id INTEGER);

ALTER TABLE tbl_index
ADD CONSTRAINT 
   tbl_index_pk
PRIMARY KEY (id);

-- Constraints PK + check + inline (not FK)
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'CONSTRAINT', 
      base_object_name    =>    UPPER('tbl_index')
   ) table_ddl
FROM 
   dual
;


-- Indexes
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'INDEX', 
      base_object_name    =>   UPPER('tbl_index')
--      base_object_schema  =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;

SELECT cnt.constraint_name   cnt_nm
FROM 
   user_constraints cnt
WHERE 1=1
   AND   cnt.table_name        =    UPPER('tbl_index')
   AND   cnt.constraint_type   IN ('P')
;

SELECT ndx.index_name
FROM 
   all_indexes ndx
WHERE 1=1
AND ndx.table_name   =  UPPER('tbl_index')
;

ALTER TABLE tbl_index DROP CONSTRAINT TBL_INDEX_PK;



  CREATE UNIQUE INDEX "FAP"."TBL_INDEX_PK" ON "FAP"."TBL_INDEX" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "FAP_DATA" ;


  ALTER TABLE "FAP"."TBL_INDEX" ADD CONSTRAINT "TBL_INDEX_PK" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "FAP_DATA"  ENABLE;
  
  -- OK
