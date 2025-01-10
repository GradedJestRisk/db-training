SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************ http://top.antognini.ch **************************
REM ***************************************************************************
REM
REM File name...: system_stats_get.sql
REM Author......: Christian Antognini
REM Date........: February 2016
REM Description.: This script shows the system statistics. Instead of selecting
REM               SYS.AUX_STATS$, it uses dbms_stats.get_system_stats.
REM Notes.......: By default, every user that can connect to a database 
REM               instance is also able to execute dbms_stats.get_system_stats.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 
REM ***************************************************************************

SET TERMOUT ON SERVEROUTPUT ON

DECLARE
  stat_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(stat_does_not_exist, -20004);
  TYPE t_pname IS VARRAY(9) OF VARCHAR2(30);
  l_pname t_pname := t_pname('CPUSPEEDNW','IOSEEKTIM','IOTFRSPEED','CPUSPEED','SREADTIM','MREADTIM','MBRC','MAXTHR','SLAVETHR');
  l_status VARCHAR2(30);
  l_dstart DATE;
  l_dstop DATE;
  l_pvalue VARCHAR2(255);
BEGIN
  FOR i IN l_pname.FIRST..l_pname.LAST
  LOOP
    BEGIN
      dbms_stats.get_system_stats(l_status, l_dstart, l_dstop, l_pname(i), l_pvalue);
    EXCEPTION
      WHEN stat_does_not_exist THEN
        l_pvalue := '<MISSING>';
    END;
    IF (i = 1)
    THEN
      dbms_output.put_line(rpad('STATUS', 12) || nvl(l_status, '<NULL>'));
      dbms_output.put_line(rpad('DSTART', 12) || nvl(to_char(l_dstart, 'YYYY-MM-DD HH24:MI:SS'), '<NULL>'));
      dbms_output.put_line(rpad('DSTOP', 12) || nvl(to_char(l_dstop, 'YYYY-MM-DD HH24:MI:SS'), '<NULL>'));
    END IF;
    dbms_output.put_line(rpad(l_pname(i), 12) || nvl(l_pvalue, '<NULL>'));
  END LOOP;
END;
/

SET ECHO ON
