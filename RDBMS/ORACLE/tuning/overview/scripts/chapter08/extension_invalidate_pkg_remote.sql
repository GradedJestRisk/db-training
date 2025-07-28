SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: extension_invalidate_pkg_remote.sql
REM Author......: Christian Antognini
REM Date........: March 2016
REM Description.: This script shows that an extension manually created by a
REM               user can invalidate a package that depends, remotely, on the
REM               altered table.
REM Notes.......: This scripts works as of Oracle Database 11g only.
REM               
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
SET SCAN ON

@../connect.sql

COLUMN column_name FORMAT A30
COLUMN object_name FORMAT A15
COLUMN object_type FORMAT A15
COLUMN extension FORMAT A30
COLUMN referenced_owner FORMAT A16
COLUMN referenced_name FORMAT A15
COLUMN referenced_type FORMAT A15
COLUMN referenced_link_name FORMAT A30
COLUMN specification_timestamp FORMAT A23

SET ECHO ON

REM
REM Setup environment
REM

DROP DATABASE LINK loopback;

CREATE DATABASE LINK loopback 
CONNECT TO &user IDENTIFIED BY &password 
USING '&connect_string';

DROP TABLE t PURGE;

CREATE TABLE t (id, n1, n2, pad)
AS
SELECT rownum, mod(rownum,113), mod(rownum,113), lpad('*',100,'*')
FROM dual
CONNECT BY level <= 10000;

execute dbms_stats.gather_table_stats(user,'t')

CREATE OR REPLACE PACKAGE p AS
 PROCEDURE p;
END p;
/

CREATE OR REPLACE PACKAGE BODY p AS
 PROCEDURE p IS
   c NUMBER;
 BEGIN
   SELECT count(*) INTO c
   FROM t@loopback;
 END p;
END p;
/

PAUSE

REM
REM Display the objects on which the package body P depends
REM

SELECT referenced_owner, referenced_name, referenced_type, referenced_link_name
FROM user_dependencies 
WHERE name = 'P' 
AND type = 'PACKAGE BODY';

PAUSE

SELECT o.remoteowner AS referenced_owner, 
       o.name AS referenced_name, 
       o.linkname AS referenced_link_name,
       to_char(o.stime, 'YYYY-MM-DD HH24:MI:SS') AS specification_timestamp
FROM sys.obj$ o, 
     (SELECT p_obj#
      FROM sys.dependency$ 
      WHERE d_obj# = (SELECT object_id 
                      FROM user_objects 
                      WHERE object_name = 'P' 
                      AND object_type = 'PACKAGE BODY')) d
WHERE o.obj# = d.p_obj#
AND o.name = 'T';

PAUSE

REM
REM The package is valid and no virtual column exists
REM

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'P'
AND status = 'INVALID';

SELECT column_name
FROM user_tab_cols@loopback
WHERE table_name = 'T'
AND hidden_column = 'YES';

PAUSE

REM
REM Create extended statistic
REM

DECLARE
  l_extension VARCHAR2(30);
BEGIN
  l_extension := dbms_stats.create_extended_stats@loopback(user, 'T', '(n1,n2)');
END;
/

PAUSE

REM
REM The package is valid and one virtual column exists
REM

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'P'
AND status = 'INVALID';

SELECT column_name
FROM user_tab_cols@loopback
WHERE table_name = 'T'
AND hidden_column = 'YES';

PAUSE

REM
REM Compile an anonymous PL/SQL block that access the same
REM remote table than the package P
REM

DECLARE
  c NUMBER;
BEGIN
  SELECT count(*) INTO c
  FROM t@loopback;
END p;
/

PAUSE

REM
REM The body package is invalid
REM

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'P'
AND status = 'INVALID';

PAUSE

REM
REM The specification timestamp of the remote object on which
REM the package body P depends has changed
REM

SELECT o.remoteowner AS referenced_owner, 
       o.name AS referenced_name, 
       o.linkname AS referenced_link_name,
       to_char(o.stime, 'YYYY-MM-DD HH24:MI:SS') AS specification_timestamp
FROM sys.obj$ o, 
     (SELECT p_obj#
      FROM sys.dependency$ 
      WHERE d_obj# = (SELECT object_id 
                      FROM user_objects 
                      WHERE object_name = 'P' 
                      AND object_type = 'PACKAGE BODY')) d
WHERE o.obj# = d.p_obj#
AND o.name = 'T';

PAUSE

REM
REM Cleanup
REM

DROP PACKAGE p;
DROP TABLE t PURGE;
DROP DATABASE LINK loopback;
