SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: spd_invalidate_pkg.sql
REM Author......: Christian Antognini
REM Date........: December 2015
REM Description.: This script shows that an extension created by a SQL plan
REM               directive can invalidate packages that depend on the
REM               altered table.
REM Notes.......: The script requires version 12.1.0.2. This is because version
REM               12.1.0.1 does not have the DBA_SQL_PLAN_DIRECTIVES.NOTES
REM               column. Hence, some queries fail.
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
SET SCAN ON

@../connect.sql

COLUMN STATE FORMAT A15
COLUMN internal_state FORMAT A15
COLUMN object_name FORMAT A15
COLUMN object_type FORMAT A15
COLUMN status FORMAT A15
COLUMN column_name FORMAT A30

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

ALTER SESSION SET optimizer_adaptive_features = TRUE;
ALTER SESSION SET optimizer_adaptive_reporting_only = FALSE;
ALTER SESSION SET optimizer_dynamic_sampling = 2;
ALTER SESSION SET optimizer_index_caching = 0;

PAUSE

REM
REM Create a SPD that instructs the database engine to create an extension
REM

REM Step 1 - INTERNAL_STATE=NEW

SELECT count(*)
FROM t
WHERE n1 = 42 AND n2 = 42;

execute dbms_spd.flush_sql_plan_directive

SELECT state, extractvalue(notes, '/spd_note/internal_state') AS internal_state
FROM dba_sql_plan_directives
WHERE directive_id IN (SELECT directive_id
                       FROM dba_sql_plan_dir_objects
                       WHERE owner = user
                       AND object_name IN ('T'));

PAUSE

REM Step 2 - INTERNAL_STATE=MISSING_STATS

ALTER /* executed to force an hard parse */ SESSION SET optimizer_index_caching = 1;

SELECT count(*)
FROM t
WHERE n1 = 42 AND n2 = 42;

execute dbms_spd.flush_sql_plan_directive

SELECT state, extractvalue(notes, '/spd_note/internal_state') AS internal_state
FROM dba_sql_plan_directives
WHERE directive_id IN (SELECT directive_id
                       FROM dba_sql_plan_dir_objects
                       WHERE owner = user
                       AND object_name IN ('T'));

PAUSE

REM
REM Gather statistics to show that:
REM - A (virtual) column is added
REM - The body of the package P1 is make invalid
REM

REM Both packages are valid and no virtual column exists

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('P1', 'P2')
AND status = 'INVALID';

SELECT column_name
FROM user_tab_cols
WHERE table_name = 'T'
AND hidden_column = 'YES';

PAUSE

REM Gather statistics

execute dbms_stats.gather_table_stats(user,'t')

PAUSE

REM One package body is invalid and a virtual column exists

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
