SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: join_elimination2.sql
REM Author......: Christian Antognini
REM Date........: June 2010
REM Description.: This script provides examples of self-join elimination.
REM Notes.......: At least Oracle Database 11g Release 2 is required to run 
REM               this script successfully.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 03.08.2016 Fixed description + added comments about expected usage of join
REM            elimination
REM 18.03.2017 Added more examples with query_rewrite_integrity + Added
REM            expected usage of join elimination in 12.2.0.1
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

@../connect.sql

DROP TABLE t PURGE;

SET ECHO ON

REM
REM Setup test environment
REM

CREATE TABLE t (
  id NUMBER NOT NULL,
  n NUMBER,
  pad VARCHAR2(4000), 
  CONSTRAINT t_pk PRIMARY KEY(id)
);

INSERT INTO t SELECT rownum, rownum, rpad('*',42,'*') FROM dual CONNECT BY level <= 1000;

execute dbms_stats.gather_table_stats(user,'t')

ALTER SESSION SET query_rewrite_integrity = enforced;

PAUSE

REM
REM Run test with 11.1.0.7 optimizer --> no join elimination
REM

EXPLAIN PLAN FOR SELECT /*+ optimizer_features_enable('11.1.0.7') */ t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM
REM Run test with default optimizer --> join elimination takes place
REM

EXPLAIN PLAN FOR SELECT t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM
REM Run test with disabled constraint --> no join elimination
REM

ALTER TABLE t DISABLE CONSTRAINT t_pk;

EXPLAIN PLAN FOR SELECT t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM
REM Run test with disabled constraint marked as reliable
REM 11.2.0.1-12.1.0.2 --> no join elimination
REM 12.2.0.1 and enforced --> no join elimination
REM 12.2.0.1 and stale_tolerated/trusted --> join elimination takes place
REM

ALTER TABLE t MODIFY CONSTRAINT t_pk RELY;

PAUSE

ALTER SESSION SET query_rewrite_integrity = enforced;

EXPLAIN PLAN FOR SELECT t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER SESSION SET query_rewrite_integrity = stale_tolerated;

EXPLAIN PLAN FOR SELECT t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER SESSION SET query_rewrite_integrity = trusted;

EXPLAIN PLAN FOR SELECT t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER TABLE t MODIFY CONSTRAINT t_pk NORELY;

ALTER SESSION SET query_rewrite_integrity = enforced;

PAUSE

REM
REM Run test with enabled but not-validated constraint
REM 11.2.0.1-12.1.0.2 --> join elimination takes place
REM 12.2.0.1 --> no join elimination
REM

ALTER TABLE t ENABLE CONSTRAINT t_pk;
ALTER TABLE t MODIFY CONSTRAINT t_pk NOVALIDATE;

EXPLAIN PLAN FOR SELECT t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM
REM Run test with deferrable enabled constraint
REM 11.2.0.1-12.1.0.2 --> no join elimination
REM 12.2.0.1 --> join elimination takes place
REM

ALTER TABLE t DROP CONSTRAINT t_pk;
ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id) DEFERRABLE;

EXPLAIN PLAN FOR SELECT t1.*, t2.* FROM t t1, t t2 WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM
REM Cleanup
REM

DROP TABLE t PURGE;
