SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: dynamic_in_conditions.sql
REM Author......: Christian Antognini
REM Date........: November 2014
REM Description.: This script shows examples on how to handle dynamic IN
REM               conditions with many expressions.
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
SET SERVEROUTPUT ON
SET VERIFY OFF
SET SCAN OFF

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

DROP TABLE t PURGE;
DROP TABLE tt PURGE;
DROP TYPE nt;
DROP FUNCTION f;

CREATE TABLE t 
AS
SELECT rownum AS id, rpad('*',100,'*') AS pad
FROM dual
CONNECT BY level <= 1E3;

BEGIN
  dbms_stats.gather_table_stats(
    ownname          => user,
    tabname          => 'T'
  );
END;
/

PAUSE

REM
REM IN condition based on a subquery using a (temporary) table
REM

CREATE GLOBAL TEMPORARY TABLE tt (n NUMBER);

PAUSE

DECLARE
  l_cnt NUMBER;
  l_min NUMBER;
  l_max NUMBER;
BEGIN
  -- prepare temporary table (insert values from 42 to 666)
  INSERT INTO tt SELECT 41+rownum FROM dual CONNECT BY level<626;
  -- use temporary table
  SELECT count(*), min(id), max(id) 
  INTO l_cnt, l_min, l_max
  FROM t 
  WHERE id IN (SELECT n FROM tt);
  -- display result
  dbms_output.put_line(l_cnt || ' ' || l_min || ' ' || l_max);
END;
/

PAUSE

DROP TABLE tt PURGE;

PAUSE

REM
REM IN condition based on a subquery using a nested table
REM

CREATE TYPE nt AS TABLE OF NUMBER;
/

PAUSE

DECLARE
  l_nt nt;
  l_cnt NUMBER;
  l_min NUMBER;
  l_max NUMBER;
BEGIN
  -- initialize nested table (insert values from 42 to 666)
  SELECT 41+rownum BULK COLLECT INTO l_nt FROM dual CONNECT BY level<626;
  -- use nested table
  SELECT count(*), min(id), max(id) 
  INTO l_cnt, l_min, l_max
  FROM t 
  WHERE id IN (SELECT * FROM table(l_nt));
  -- display result
  dbms_output.put_line(l_cnt || ' ' || l_min || ' ' || l_max);
END;
/
  
PAUSE

DROP TYPE nt;

REM
REM IN condition based on a subquery using a user-defined table function that parses a CSV string
REM

CREATE TYPE nt AS TABLE OF NUMBER;
/

PAUSE

CREATE FUNCTION f (p_list CLOB) RETURN nt PIPELINED
AS
BEGIN
  FOR i IN 1..regexp_count(p_list,',')+1
  LOOP
    PIPE ROW(to_number(regexp_substr(p_list,'[^,]+',1,i)));
  END LOOP;
  RETURN;
END;
/

PAUSE

DECLARE
  l_list CLOB;
  l_cnt NUMBER;
  l_min NUMBER;
  l_max NUMBER;
BEGIN
  -- initialize nested table (concatenate values from 42 to 666)
  FOR i IN 42..666
  LOOP
    l_list := l_list || i || ','; 
  END LOOP;
  -- use nested table
  SELECT count(*), min(id), max(id) 
  INTO l_cnt, l_min, l_max
  FROM t 
  WHERE id IN (SELECT * FROM table(f(l_list)));
  -- display result
  dbms_output.put_line(l_cnt || ' ' || l_min || ' ' || l_max);
END;
/
  
PAUSE

DROP FUNCTION f;
DROP TYPE nt;

REM
REM MEMBER condition that tests whether an element is in a nested table
REM

CREATE TYPE nt AS TABLE OF NUMBER;
/

PAUSE

DECLARE
  l_nt nt;
  l_cnt NUMBER;
  l_min NUMBER;
  l_max NUMBER;
BEGIN
  -- initialize nested table (insert values from 42 to 666)
  SELECT 41+rownum BULK COLLECT INTO l_nt FROM dual CONNECT BY level<626;
  -- use nested table
  SELECT count(*), min(id), max(id) 
  INTO l_cnt, l_min, l_max
  FROM t 
  WHERE id MEMBER OF l_nt;
  -- show result
  dbms_output.put_line(l_cnt || ' ' || l_min || ' ' || l_max);
END;
/
  
PAUSE

DROP TYPE nt;

PAUSE

REM
REM Cleanup
REM

DROP TABLE t PURGE;
