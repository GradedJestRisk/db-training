-- To remove annoying SQL> SQL>
-- https://forums.oracle.com/ords/apexds/post/sqlplus-with-many-numbers-4873
SET SQLNUMBER OFF;
SET SQLPROMPT '';

-- Show queries (should run sqlplus with @script.sql, NOT cat script.sql| sqlplus )
SET ECHO ON;

SET LINESIZE 200;

BEGIN
    dbms_session.session_trace_enable(waits     => TRUE,
                                      binds     => TRUE,
                                      plan_stat => 'all_executions');
END;
/

INSERT INTO simple_table VALUES(4);

BEGIN
    dbms_session.session_trace_disable;
END;
/

EXIT