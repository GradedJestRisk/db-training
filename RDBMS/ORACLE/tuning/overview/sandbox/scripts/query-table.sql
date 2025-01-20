SET LINESIZE 200;

SELECT distinct sid FROM v$mystat;
CALL dbms_session.set_identifier('query-table');

SELECT MAX(id)
FROM simple_table;

SELECT prev_sql_id AS sql_id FROM v$session WHERE sid=sys_context('userenv','sid');

EXIT;