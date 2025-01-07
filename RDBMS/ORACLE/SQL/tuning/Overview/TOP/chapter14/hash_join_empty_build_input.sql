SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: hash_join_empty_build_input.sql
REM Author......: Christian Antognini
REM Date........: November 2014
REM Description.: This script shows that the probe input of a hash join is not
REM               always executed.
REM Notes.......: -
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 03.12.2014 Replaced ROWSTATS (12c only) with IOSTATS
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

DROP TABLE t2 PURGE;
DROP TABLE t1 PURGE;

CREATE TABLE t1 
AS
SELECT rownum AS id, rownum AS n, rpad('*',100,'*') AS pad
FROM dual
CONNECT BY level <= 10;

CREATE TABLE t2
AS
SELECT rownum AS id, rownum AS t1_id, rownum AS n, rpad('*',100,'*') AS pad
FROM dual
WHERE 0 = 1;

BEGIN
  dbms_stats.gather_table_stats(user, 'T1');
  dbms_stats.gather_table_stats(user, 'T2');
END;
/

ALTER SESSION SET optimizer_adaptive_features = FALSE;

PAUSE

REM
REM HASH JOIN -> probe input *not* executed
REM

SELECT /*+ gather_plan_statistics leading(t1) use_hash(t2) swap_join_inputs(t2) */ *
FROM t1 INNER JOIN t2 ON t1.id = t2.t1_id;

SELECT * FROM table(dbms_xplan.display_cursor(format=>'iostats last'));

PAUSE

REM
REM HASH JOIN OUTER -> probe input *not* executed
REM

SELECT /*+ gather_plan_statistics leading(t1) use_hash(t2) swap_join_inputs(t2) */ *
FROM t1 RIGHT OUTER JOIN t2 ON t1.id = t2.t1_id;

SELECT * FROM table(dbms_xplan.display_cursor(format=>'iostats last'));

PAUSE

REM
REM HASH JOIN RIGHT OUTER -> probe input executed
REM

SELECT /*+ gather_plan_statistics leading(t1) use_hash(t2) swap_join_inputs(t2) */ *
FROM t1 LEFT OUTER JOIN t2 ON t1.id = t2.t1_id;

SELECT * FROM table(dbms_xplan.display_cursor(format=>'iostats last'));

PAUSE

REM
REM HASH JOIN FULL OUTER -> probe input executed
REM

SELECT /*+ gather_plan_statistics leading(t1) use_hash(t2) swap_join_inputs(t2) */ *
FROM t1 FULL OUTER JOIN t2 ON t1.id = t2.t1_id;

SELECT * FROM table(dbms_xplan.display_cursor(format=>'iostats last'));

PAUSE

REM
REM Clean up
REM

DROP TABLE t2 PURGE;
DROP TABLE t1 PURGE;
