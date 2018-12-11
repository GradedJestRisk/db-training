-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/fks_ref_table_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the foreign keys that reference the specified table.
-- Call Syntax  : @fks_ref_table_ddl (schema) (table-name)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('REF_CONSTRAINT', ac1.constraint_name, ac1.owner)
FROM   all_constraints ac1
       JOIN all_constraints ac2 ON ac1.r_owner = ac2.owner AND ac1.r_constraint_name = ac2.constraint_name
WHERE  ac2.owner      = UPPER('&1')
AND    ac2.table_name = UPPER('&2')
AND    ac2.constraint_type IN ('P','U')
AND    ac1.constraint_type = 'R';

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON





-- https://asktom.oracle.com/pls/asktom/f?p=100:11:::::P11_QUESTION_ID:399218963817 

COLUMN ddl FORMAT a80 word_wrapped

SELECT 
      'ALTER TABLE "' || child_tname || '"' || chr(10) 
   || 'ADD CONSTRAINT "' || child_cons_name || '"' || chr(10) 
   || 'FOREIGN KEY ( ' || child_columns || ' ) ' || chr(10) 
   || 'REFERENCES "'   ||  parent_tname || '" ( ' || parent_columns || ');' ddl
FROM (SELECT a.table_name child_tname,
             a.constraint_name child_cons_name,
             b.r_constraint_name parent_cons_name,
             MAX(decode(position, 1, '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 2, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 3, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 4, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 5, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 6, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 7, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 8, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 9, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 10, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 11, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 12, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 13, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 14, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 15, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 16, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) child_columns
      FROM user_cons_columns a, user_constraints b
      WHERE a.constraint_name = b.constraint_name
      AND b.constraint_type = 'R'
      GROUP BY a.table_name, a.constraint_name, b.r_constraint_name) child,
     (SELECT a.constraint_name parent_cons_name,
             a.table_name parent_tname,
             MAX(decode(position, 1, '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 2, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 3, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 4, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 5, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 6, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 7, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 8, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 9, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 10, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 11, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 12, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 13, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 14, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 15, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) ||
             MAX(decode(position, 16, ', ' || '"' || substr(column_name, 1, 30) || '"', NULL)) parent_columns
      FROM user_cons_columns a, user_constraints b
      WHERE a.constraint_name = b.constraint_name
      AND b.constraint_type IN ('P', 'U')
      GROUP BY a.table_name, a.constraint_name) PARENT
WHERE 1=1
   AND child.parent_cons_name = PARENT.parent_cons_name
   AND PARENT.parent_tname    = upper('tbl_test')
/