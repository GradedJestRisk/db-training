SET LINESIZE 200;

SELECT distinct sid FROM v$mystat;

EXPLAIN PLAN FOR
SELECT MAX(id)
FROM simple_table;

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY());

EXIT;