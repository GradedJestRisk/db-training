SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: extension_invalidate_pkg.sql
REM Author......: Christian Antognini
REM Date........: December 2015
REM Description.: This script shows that an extension explicitly created by a
REM               user can invalidate packages that depend on the altered table.
REM Notes.......: This scripts works as of Oracle Database 11g only.
REM               In 12c the bug 19450314 (Unnecessary compiled PL/SQL
REM               invalidations in 12c) is related to it. It goes without saying
REM               that when the patch solving that bug is installation, this 
REM               script is no longer able to reproduce the "expected" behavior.
REM               
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 02.03.2016 Added note about bug 19450314
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

@../connect.sql

COLUMN column_name FORMAT A30
COLUMN object_name FORMAT A15
COLUMN object_type FORMAT A15
COLUMN extension FORMAT A30

SET ECHO ON

REM
REM Setup environment
REM

DROP TABLE t PURGE;

CREATE TABLE t (id, n1, n2, pad)
AS
SELECT rownum, mod(rownum,113), mod(rownum,113), lpad('*',100,'*')
FROM dual
CONNECT BY level <= 10000;

execute dbms_stats.gather_table_stats(user,'t')

REM notice that in the following package the implementation uses "count(1)"

CREATE OR REPLACE PACKAGE p1 AS
 PROCEDURE p;
END p1;
/

CREATE OR REPLACE PACKAGE BODY p1 AS
 PROCEDURE p IS
   c NUMBER;
 BEGIN
   SELECT count(1) INTO c
   FROM t;
 END p;
END p1;
/

REM notice that in the following package the implementation uses "count(*)"

CREATE OR REPLACE PACKAGE p2 AS
 PROCEDURE p;
END p2;
/

CREATE OR REPLACE PACKAGE BODY p2 AS
 PROCEDURE p IS
   c NUMBER;
 BEGIN
   SELECT count(*) INTO c
   FROM t;
 END p;
END p2;
/

PAUSE

REM
REM Both packages are valid and no virtual column exists
REM

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('P1', 'P2')
AND status = 'INVALID';

SELECT column_name
FROM user_tab_cols
WHERE table_name = 'T'
AND hidden_column = 'YES';

PAUSE

REM
REM Create extended statistic
REM

SELECT dbms_stats.create_extended_stats(user, 'T', '(n1,n2)') AS extension
FROM dual;

PAUSE

REM
REM One package body is invalid and a virtual column exists
REM

SELECT column_name
FROM user_tab_cols
WHERE table_name = 'T'
AND hidden_column = 'YES';

SELECT object_name, object_type
FROM user_objects
WHERE object_name IN ('P1', 'P2')
AND status = 'INVALID';

PAUSE

REM
REM Cleanup
REM

DROP PACKAGE p1;
DROP PACKAGE p2;
DROP TABLE t PURGE;
