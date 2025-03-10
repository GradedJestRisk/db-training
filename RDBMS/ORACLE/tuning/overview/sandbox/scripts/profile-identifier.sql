-- To remove annoying SQL> SQL>
-- https://forums.oracle.com/ords/apexds/post/sqlplus-with-many-numbers-4873
SET SQLNUMBER OFF;
SET SQLPROMPT '';

-- Show queries (should run sqlplus with @script.sql, NOT cat script.sql| sqlplus )
SET ECHO ON;

SET LINESIZE 200;

CALL dbms_session.set_identifier('profiling');

SELECT distinct sid FROM v$mystat;

CALL dbms_monitor.client_id_trace_enable(
          client_id => 'profiling' ,
          waits     => TRUE,
          binds     => TRUE,
          plan_stat => 'all_executions');


-- INSERT INTO simple_table VALUES(4);
SELECT MAX(id)
FROM simple_table;

CALL dbms_monitor.client_id_trace_disable(client_id => 'profiling');

EXIT;