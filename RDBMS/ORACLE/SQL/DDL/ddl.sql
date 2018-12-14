GRANT SELECT_CATALOG_ROLE TO fap;
GRANT SELECT ANY DICTIONARY TO fap;

---------------------------------------------------------------------------
--------------      Table                   -------------
---------------------------------------------------------------------------


-- ALL: Table structure + PK + FK + check

exec DBMS_METADATA.SET_TRANSFORM_PARAM( DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE',          TRUE);
exec DBMS_METADATA.SET_TRANSFORM_PARAM( DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS',      TRUE);
exec DBMS_METADATA.SET_TRANSFORM_PARAM( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS',  TRUE)

SELECT 
   dbms_metadata.get_ddl(
         object_type    =>   'TABLE', 
         name           =>   'FILIERE', 
         schema         =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;

-- ONLY Table structure 

exec DBMS_METADATA.SET_TRANSFORM_PARAM( DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE',          FALSE);
exec DBMS_METADATA.SET_TRANSFORM_PARAM( DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS',      FALSE);
exec DBMS_METADATA.SET_TRANSFORM_PARAM( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS',  FALSE)

SELECT 
   dbms_metadata.get_ddl(
         object_type    =>   'TABLE', 
         name           =>   'FILIERE', 
         schema         =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;


---------------------------------------------------------------------------
--------------      Table dependants                    -------------
---------------------------------------------------------------------------

-- Constraints PK + check + inline (not FK)
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'CONSTRAINT', 
      base_object_name    =>   'FILIERE', 
      base_object_schema  =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;


-- Constraints FK 
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'REF_CONSTRAINT', 
      base_object_name    =>   'FILIERE', 
      base_object_schema  =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;

SELECT 
   dbms_metadata.get_ddl (
      object_type   =>   'REF_CONSTRAINT', 
      name          =>   cnt_fk.constraint_name) ddl
FROM   
   user_constraints cnt_fk
       JOIN user_constraints cnt_pk ON cnt_fk.r_constraint_name = cnt_pk.constraint_name
WHERE  1=1
   AND   cnt_pk.table_name       = UPPER('filiere')
   AND   cnt_pk.constraint_type IN ('P','U')
   AND   cnt_fk.constraint_type  = 'R'
;

---------------------------------------------------------------------------
--------------     Index                   -------------
---------------------------------------------------------------------------

-- Indexes
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'INDEX', 
      base_object_name    =>   UPPER('tbl_test'), 
      base_object_schema  =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;

-- Always exeute get_dependent_ddl INDEX before CONSTRAINTS
-- see ddl_indexes.sql for more


---------------------------------------------------------------------------
--------------      Privileges                  -------------
---------------------------------------------------------------------------

-- Grants on a table
SELECT 
   dbms_metadata.get_dependent_ddl( 
      object_type         =>   'OBJECT_GRANT', 
      base_object_name    =>   'FILIERE', 
      base_object_schema  =>   'DBOFAP'
   ) table_ddl
FROM 
   dual
;


         
---------------------------------------------------------------------------
--------------      Test in sqlplus                    -------------
---------------------------------------------------------------------------

SET SERVEROUTPUT ON;

DECLARE 
   l_clob CLOB;
BEGIN

   SELECT 
      dbms_metadata.get_ddl( 'TABLE', 'FILIERE', 'DBOFAP') table_ddl
   INTO 
      l_clob
   FROM 
      dual;
      
    DBMS_OUTPUT.PUT_LINE(l_clob);  
      
END;
/


---------------------------------------------------------------------------
--------------      Other                   -------------
---------------------------------------------------------------------------


SELECT 
   dbms_metadata.get_ddl('INDEX', 'PK_FILIERE', 'DBOFAP') index_ddl 
FROM 
   dual
;




SELECT 
    cnt.constraint_type 
   ,cnt.constraint_name   cnt_nm
   ,cnt.table_name        tbl
   ,cnt.search_condition
--   ,cnt.*
FROM 
   all_constraints cnt
WHERE 1=1
   AND   LOWER(cnt.table_name)   = 'filiere'
   AND   cnt.constraint_type NOT IN ('P','R')
;


