SET ECHO OFF
REM ***************************************************************************
REM ***************************** T R I V A D I S *****************************
REM ******************** Oracle Database 12c New Features *********************
REM ************************ http://www.trivadis.com **************************
REM ***************************************************************************
REM
REM Privileges..: DBA
REM File name...: adaptive_plan_lob.sql
REM Author......: Christian Antognini
REM Date........: December 2014
REM Description.: This script shows that an adaptive join method cannot be used
REM               when a row source operation under the statistics collector
REM               produces a LOB.
REM Notes.......: -
REM Parameters..: -
REM Requirements: Oracle Database 12c Enterprise Edition Release 1 - 12.1
REM
REM Changes:
REM DD.MM.YYYY Author Description
REM ---------------------------------------------------------------------------
REM 
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET SERVEROUTPUT OFF

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

DROP TABLE t1 PURGE;
DROP TABLE t2 PURGE;
DROP TABLE t1l PURGE;
DROP TABLE t2l PURGE;

CREATE TABLE t1 (id, n, pad)
AS
SELECT rownum, rownum, lpad('*',100,'*')
FROM dual
CONNECT BY level <= 10000;

INSERT INTO t1
SELECT 10000+rownum, 666, lpad('*',100,'*')
FROM dual
CONNECT BY level <= 150;

COMMIT;

ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id);

execute dbms_stats.gather_table_stats(user,'t1')

CREATE TABLE t2 (id, n, pad)
AS
SELECT rownum, rownum, lpad('*',100,'*')
FROM dual
CONNECT BY level <= 10000;

ALTER TABLE t2 ADD CONSTRAINT t2_pk PRIMARY KEY (id);

execute dbms_stats.gather_table_stats(user,'t2')

CREATE TABLE t1l
AS
SELECT id, n, to_clob(pad) AS pad
FROM t1;

ALTER TABLE t1l ADD CONSTRAINT t1l_pk PRIMARY KEY (id);

execute dbms_stats.gather_table_stats(user,'t1l')

CREATE TABLE t2l
AS
SELECT id, n, to_clob(pad) AS pad
FROM t2;

ALTER TABLE t2l ADD CONSTRAINT t2l_pk PRIMARY KEY (id);

execute dbms_stats.gather_table_stats(user,'t2l')

ALTER SYSTEM FLUSH SHARED_POOL;

ALTER SESSION SET optimizer_adaptive_features = TRUE;
ALTER SESSION SET optimizer_adaptive_reporting_only = FALSE;

PAUSE

REM
REM Joining t1 and t2 --> the plan is adaptive
REM

REM ALTER SESSION SET events = '10053 trace name context forever';

EXPLAIN PLAN FOR
SELECT *
FROM t1, t2
WHERE t1.id = t2.id
AND t1.n = 666;

REM ALTER SESSION SET events = '10053 trace name context off';

PAUSE

SELECT * FROM table(dbms_xplan.display(format=>'basic +predicate +note +adaptive'));

PAUSE

REM
REM Joining t1 and t2l --> the plan is adaptive
REM

REM ALTER SESSION SET events = '10053 trace name context forever';

EXPLAIN PLAN FOR
SELECT *
FROM t1, t2l
WHERE t1.id = t2l.id
AND t1.n = 666;

REM ALTER SESSION SET events = '10053 trace name context off';

PAUSE

SELECT * FROM table(dbms_xplan.display(format=>'basic +predicate +note +adaptive'));

PAUSE

REM
REM Joining t1l and t2 --> the plan is NOT adaptive
REM

REM ALTER SESSION SET events = '10053 trace name context forever';

EXPLAIN PLAN FOR
SELECT *
FROM t1l, t2
WHERE t1l.id = t2.id
AND t1l.n = 666;

REM ALTER SESSION SET events = '10053 trace name context off';

PAUSE

SELECT * FROM table(dbms_xplan.display(format=>'basic +predicate +note +adaptive'));

PAUSE

REM
REM Joining t1l and t2l --> the plan is NOT adaptive
REM

REM ALTER SESSION SET events = '10053 trace name context forever';

EXPLAIN PLAN FOR
SELECT *
FROM t1l, t2l
WHERE t1l.id = t2l.id
AND t1l.n = 666;

REM ALTER SESSION SET events = '10053 trace name context off';

PAUSE

SELECT * FROM table(dbms_xplan.display(format=>'basic +predicate +note +adaptive'));

PAUSE

REM
REM Cleanup
REM

DROP TABLE t1 PURGE;
DROP TABLE t2 PURGE;
DROP TABLE t1l PURGE;
DROP TABLE t2l PURGE;
