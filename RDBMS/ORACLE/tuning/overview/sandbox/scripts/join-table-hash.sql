SET LINESIZE 200;

SELECT distinct sid AS session_id
FROM v$mystat;

CALL dbms_session.set_identifier('query-table');

set rowprefetch 500
set arraysize 500

SET TERMOUT OFF;

SELECT /*+ leading(t1 t2) use_hash(t2) */ *
FROM simple_table t1
         INNER JOIN simple_table t2 ON t1.id = t2.id
;
-- WHERE 1=1
--     AND t1.id = 1;

SET TERMOUT ON;

SELECT prev_sql_id AS sql_id
FROM v$session WHERE sid=sys_context('userenv','sid');

EXIT;