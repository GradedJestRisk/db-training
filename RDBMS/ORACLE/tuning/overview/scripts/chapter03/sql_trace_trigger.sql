SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: sql_trace_trigger.sql
REM Author......: Christian Antognini
REM Date........: June 2010
REM Description.: You can use this script to create a logon trigger that 
REM               enables SQL trace.
REM Notes.......: This script works as of 10.2 only. To use it with previous
REM               releases use event 10046 instead of the dbms_session package.
REM               To successfully run this script the following privileges are
REM               required: ALTER SESSION, CREATE TRIGGER, ADMINISTER DATABASE
REM               TRIGGER.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 30.11.2012 Replaced dbms_monitor with dbms_session.
REM 20.08.2014 Fixed typo in dbms_session call. Updated notes.
REM 20.03.2018 Because of the security fix 21622969 (refer to the MOS note 
REM            "DBMS_SESSION.IS_ROLE_ENABLED ALWAYS RETURN FALSE (2305012.1)"),
REM            removed the role to check whether SQL trace has to be enabled.
REM            Instead, a trigger checking the user name is used.
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

@../connect.sql

SET ECHO ON

REM
REM The trigger will enable SQL trace for the user owning it. As a result,
REM the variable "user" has to be set to the name of the user for which SQL
REM trace has to be enabled. Be careful that the match is case sensitive.
REM

PAUSE

CREATE OR REPLACE TRIGGER enable_sql_trace 
AFTER LOGON ON DATABASE
WHEN (user = '&user')
BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET timed_statistics = TRUE';
  EXECUTE IMMEDIATE 'ALTER SESSION SET max_dump_file_size = unlimited';
  dbms_session.session_trace_enable;
END;
/
