SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: sql_trace.sql
REM Author......: Christian Antognini
REM Date........: September 2015
REM Description.: This script was used to generated the trace file used as 
REM               example in Chapter 3 (see page 68).
REM Notes.......: -
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN OFF

@../connect.sql

SET ECHO ON

DROP TABLE t PURGE;

CREATE TABLE t
AS 
WITH t1000 AS (SELECT /*+ materialize */ rownum AS n FROM dual CONNECT BY level <= 1000)
SELECT rownum AS id, mod(rownum,123) AS n, trunc(sysdate-t1.n) AS d, rpad('*',250,'*') AS pad
FROM t1000 t1, t1000 t2;

ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id);

execute dbms_stats.gather_table_stats(user,'t')

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

ALTER SESSION SET workarea_size_policy = manual;
ALTER SESSION SET sort_area_size = 65536;

EXECUTE dbms_session.session_trace_enable(binds=>TRUE, waits=>TRUE, plan_stat=>'all_executions')

DECLARE
  l_count INTEGER;
BEGIN
  FOR c IN (SELECT extract(YEAR FROM d), id, pad
            FROM t
            ORDER BY extract(YEAR FROM d), id)
  LOOP
    NULL;
  END LOOP;
  FOR i IN 1..10
  LOOP
    SELECT count(n) INTO l_count
    FROM t
    WHERE id < i*123;
  END LOOP;
END;
/

EXECUTE dbms_session.session_trace_disable

SELECT value
FROM v$diag_info
WHERE name = 'Default Trace File';

DROP TABLE t PURGE;
