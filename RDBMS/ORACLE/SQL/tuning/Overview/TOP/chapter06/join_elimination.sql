SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: join_elimination.sql
REM Author......: Christian Antognini
REM Date........: August 2008
REM Description.: This script provides examples of join elimination.
REM Notes.......: At least Oracle Database 10g Release 2 is required to run
REM               this script.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 24.06.2010 Fixed typo in description
REM 14.09.2011 Added example with new join syntax
REM 22.08.2013 Added examples with NOVALIDATE, RELY and DEFERRABLE constraint
REM 22.09.2015 Added examples with query_rewrite_integrity + added comments 
REM            about expected usage of join elimination
REM 18.03.2017 Added expected usage of join elimination in 12.2.0.1
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

COLUMN table_name FORMAT A10

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

@@create_tx.sql

PAUSE

REM
REM Example with legacy join syntax
REM

DROP VIEW v;

CREATE VIEW v AS
SELECT t1.id AS t1_id, t1.n AS t1_n, t2.id AS t2_id, t2.n AS t2_n
FROM t1, t2
WHERE t1.id = t2.t1_id;

ALTER SESSION SET query_rewrite_integrity = enforced;

PAUSE

REM FK enabled novalidate --> no join elimination

ALTER TABLE t2 ENABLE NOVALIDATE CONSTRAINT t2_t1_fk;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM FK enabled --> join elimination takes place

ALTER TABLE t2 ENABLE CONSTRAINT t2_t1_fk;

ALTER SESSION SET events '10053 trace name context forever';

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

ALTER SESSION SET events '10053 trace name context off';

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM FK disabled --> no join elimination

ALTER TABLE t2 DISABLE CONSTRAINT t2_t1_fk;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM FK disabled or enabled novalidate + marked as reliable + query_rewrite_integrity=enforced
REM 10.2.0.5-12.1.0.1 --> join elimination takes place
REM 12.1.0.2-12.2.0.1 --> no join elimination

ALTER SESSION SET query_rewrite_integrity = enforced;

PAUSE

ALTER TABLE t2 DISABLE CONSTRAINT t2_t1_fk;
ALTER TABLE t2 MODIFY CONSTRAINT t2_t1_fk RELY;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER TABLE t2 ENABLE NOVALIDATE CONSTRAINT t2_t1_fk;
ALTER TABLE t2 MODIFY CONSTRAINT t2_t1_fk RELY;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM FK disabled or enabled novalidate + marked as reliable + query_rewrite_integrity=trusted/stale_tolerated
REM 10.2.0.5-11.1.0.7 --> no join elimination
REM 11.2.0.1-12.2.0.1 --> join elimination takes place

ALTER TABLE t2 DISABLE CONSTRAINT t2_t1_fk;
ALTER TABLE t2 MODIFY CONSTRAINT t2_t1_fk RELY;

PAUSE

ALTER SESSION SET query_rewrite_integrity = trusted;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER SESSION SET query_rewrite_integrity = stale_tolerated;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER TABLE t2 ENABLE NOVALIDATE CONSTRAINT t2_t1_fk;
ALTER TABLE t2 MODIFY CONSTRAINT t2_t1_fk RELY;

PAUSE

ALTER SESSION SET query_rewrite_integrity = trusted;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

ALTER SESSION SET query_rewrite_integrity = stale_tolerated;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM FK enabled deferrable
REM 10.2.0.5-11.2.0.4 --> join elimination takes place
REM 12.1.0.x --> no join elimination
REM 12.2.0.1 --> join elimination takes place

ALTER TABLE t2 DROP CONSTRAINT t2_t1_fk;
ALTER TABLE t2 ADD CONSTRAINT t2_t1_fk FOREIGN KEY (t1_id) REFERENCES t1 DEFERRABLE;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM
REM Example with new join syntax (join elimination works as 10.2.0.3 only)
REM

DROP VIEW v;

CREATE VIEW v AS
SELECT t1.id AS t1_id, t1.n AS t1_n, t2.id AS t2_id, t2.n AS t2_n
FROM t1 JOIN t2 ON t1.id = t2.t1_id;

ALTER SESSION SET query_rewrite_integrity = enforced;

ALTER TABLE t2 DROP CONSTRAINT t2_t1_fk;
ALTER TABLE t2 ADD CONSTRAINT t2_t1_fk FOREIGN KEY (t1_id) REFERENCES t1;

PAUSE

REM FK enabled --> join elimination takes place

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM FK disabled --> no join elimination

ALTER TABLE t2 DISABLE CONSTRAINT t2_t1_fk;

EXPLAIN PLAN FOR SELECT t2_id, t2_n FROM v;

SELECT * FROM table(dbms_xplan.display);

PAUSE

REM
REM Cleanup
REM

DROP TABLE t4;
PURGE TABLE t4;
DROP TABLE t3;
PURGE TABLE t3;
DROP TABLE t2;
PURGE TABLE t2;
DROP TABLE t1;
PURGE TABLE t1;
DROP VIEW v;
