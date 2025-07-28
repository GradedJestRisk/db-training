SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: gtt.sql
REM Author......: Christian Antognini
REM Date........: June 2014
REM Description.: This script shows that in 12c global temporary tables have
REM               session-level statistics.
REM Notes.......: The script only works in 12c.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 25.02.2016 Explicitly set global_temp_table_stats at the table level +
REM            Added example with direct-path insert
REM 25.05.2016 Explicitly set optimizer_features_enable + test with pre-12c 
REM            values + use EXPLAIN PLAN to avoid "ORA-01403: no data found"
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET SERVEROUTPUT OFF

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

DROP TABLE t PURGE;

CREATE GLOBAL TEMPORARY TABLE t (id NUMBER, pad VARCHAR2(1000));

REM the following call is only necessary in case the default value was changed at the global level

execute dbms_stats.set_table_prefs(ownname => user, tabname => 't', pname => 'global_temp_table_stats', pvalue => 'session')

ALTER SESSION SET optimizer_features_enable = '12.1.0.1';

PAUSE

REM
REM Conventional INSERT
REM

INSERT INTO t SELECT rownum, rpad('*',1000,'*') FROM dual CONNECT BY level <= 1000;

PAUSE

execute dbms_stats.gather_table_stats(ownname => user, tabname => 't')

PAUSE

SELECT num_rows, blocks, avg_row_len, scope
FROM user_tab_statistics
WHERE table_name = 'T';

PAUSE

EXPLAIN PLAN FOR
SELECT count(*)
FROM t
WHERE id BETWEEN 10 AND 100;

PAUSE

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM Session statistics are not used when OFE < 12.1

ALTER SESSION SET optimizer_features_enable = '11.2.0.4';

PAUSE

EXPLAIN PLAN FOR
SELECT count(*)
FROM t
WHERE id BETWEEN 10 AND 100;

PAUSE

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER SESSION SET optimizer_features_enable = '12.1.0.1';

REM But when OFE is specified through an hint...

EXPLAIN PLAN FOR
SELECT /*+ optimizer_features_enable('11.2.0.4') */ count(*)
FROM t
WHERE id BETWEEN 10 AND 100;

PAUSE

SELECT * FROM table(dbms_xplan.display(format=>'outline'));

PAUSE

REM
REM Direct-path INSERT
REM

ALTER SESSION SET optimizer_features_enable = '12.1.0.1';

TRUNCATE TABLE t;

INSERT /*+ append */ INTO t SELECT rownum, rpad('*',1000,'*') FROM dual CONNECT BY level <= 2000;

COMMIT;

PAUSE

SELECT num_rows, blocks, avg_row_len, scope
FROM user_tab_statistics
WHERE table_name = 'T';

PAUSE

REM Session statistics are not gathered when OFE < 12.1

ALTER SESSION SET optimizer_features_enable = '11.2.0.4';

TRUNCATE TABLE t;

INSERT /*+ append */ INTO t SELECT rownum, rpad('*',1000,'*') FROM dual CONNECT BY level <= 3000;

COMMIT;

PAUSE

SELECT num_rows, blocks, avg_row_len, scope
FROM user_tab_statistics
WHERE table_name = 'T';

PAUSE

REM
REM Clean up
REM

DROP TABLE t PURGE;
