SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************ http://top.antognini.ch **************************
REM ***************************************************************************
REM
REM File name...: cardinality_feedback.sql
REM Author......: Christian Antognini
REM Date........: Mai 2011
REM Description.: This script shows that cardinality feedback might be used for
REM               queries based on a table function.
REM Notes.......: This script works as of 11gR2 only.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 08.01.2015 Added query against V$SQL_REOPTIMIZATION_HINTS to show the hints
REM            used to provide the feedback
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

@../connect.sql

COLUMN is_shareable FORMAT A12
COLUMN use_feedback_stats FORMAT A18
COLUMN pad FORMAT A10 TRUNC

COLUMN sql_id NEW_VALUE sql_id

SET ECHO ON

REM
REM Setup test environment
REM

ALTER SYSTEM FLUSH SHARED_POOL;

ALTER SESSION SET cursor_sharing = 'EXACT';

DROP TABLE t PURGE; 

CREATE TABLE t AS SELECT rownum AS n, rpad('*',100,'*') AS pad FROM dual CONNECT BY level <= 10000;

CREATE INDEX i ON t (n);

execute dbms_stats.gather_table_stats(user,'t')

CREATE OR REPLACE TYPE number_t AS TABLE OF number;
/

CREATE OR REPLACE function f(p_count NUMBER) RETURN number_t PIPELINED AS
BEGIN
  FOR i in 1..p_count
  LOOP
    pipe row(i);
  END LOOP;
  RETURN;
END;
/

PAUSE

REM 
REM The first execution is based on wrong estimations
REM 

SELECT * 
FROM t, table(f(10)) f 
WHERE t.n = f.column_value;

PAUSE

SELECT prev_sql_id AS sql_id
FROM v$session
WHERE sid = sys_context('userenv','sid');

SELECT * FROM table(dbms_xplan.display_cursor('&sql_id', NULL));

PAUSE

SELECT child_number, is_shareable
FROM v$sql
WHERE sql_id = '&sql_id';

PAUSE

REM
REM Display hints used to provide feedback (the query works as of 12.1.0.1 only)
REM

SELECT hint_text 
FROM v$sql_reoptimization_hints
WHERE sql_id = '&sql_id';

PAUSE

REM
REM For the second execution cardinality feedback is used
REM

SELECT * 
FROM t, table(f(10)) f 
WHERE t.n = f.column_value;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor);

PAUSE

SELECT child_number, is_shareable
FROM v$sql
WHERE sql_id = '&sql_id';

PAUSE

REM The following query works as of 11.2.0.2 only

SELECT child_number, use_feedback_stats
FROM v$sql_shared_cursor
WHERE sql_id = '&sql_id';

PAUSE

REM
REM Deactivating cardinality feedback via hint
REM

SELECT /*+ opt_param('_optimizer_use_feedback','false') */ * 
FROM t, table(f(10)) f 
WHERE t.n = f.column_value;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor);

PAUSE

SELECT /*+ opt_param('_optimizer_use_feedback','false') */ * 
FROM t, table(f(10)) f 
WHERE t.n = f.column_value;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor);

PAUSE

REM
REM Cleanup environment
REM

DROP TYPE number_t;

DROP FUNCTION f;

DROP TABLE t PURGE;

UNDEFINE sql_id
