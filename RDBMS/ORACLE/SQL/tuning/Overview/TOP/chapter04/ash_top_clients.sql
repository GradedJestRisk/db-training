SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: ash_top_clients.sql
REM Author......: Christian Antognini
REM Date........: January 2014
REM Description.: Display top clients for the period specified as parameter.
REM Notes.......: To run this script the Diagnostic Pack license is required. 
REM Parameters..: &1 period begin
REM               &2 period end
REM
REM               The two parameters supports three main formats:
REM               - Timestamp without day: HH24:MI:SSXFF
REM               - Timestamp with day: YYYY-MM-DD_HH24:MI:SSXFF
REM               - Expression: any SQL expression that returns a DATE value
REM
REM               Caution: the expression, to be recognized by SQL*Plus as a
REM                        single parameter, cannot contain spaces.
REM
REM               Examples:
REM               - 23:15:35             (today at 23:15:35.000000000)
REM               - 2014-10-13_23:15     (13 Oct 2014 at 23:15:00.000000000)
REM               - sysdate              (now)
REM               - sysdate-(1/24/60)*10 (10 minutes ago)
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 07.01.2015 Aligned headings with other ash_top_*.sql scripts
REM 09.01.2015 Input parameters are more flexible and support an expression +
REM            Added information about period and number of ASH samples
REM ***************************************************************************

SET TERMOUT ON LINESIZE 120 SCAN ON VERIFY OFF FEEDBACK OFF

VARIABLE t1 VARCHAR2(250)
VARIABLE t2 VARCHAR2(250)

COLUMN begin_timestamp FORMAT A30 HEADING "Period Begin"
COLUMN end_timestamp FORMAT A30 HEADING "Period End"
COLUMN ash_samples FORMAT 9,999,999,999 HEADING "Total Sample Count"
COLUMN activity_pct FORMAT 990.0 HEADING "Activity%"
COLUMN db_time FORMAT 9,999,999 HEADING "DB Time"
COLUMN cpu_pct FORMAT 990.0 HEADING "CPU%"
COLUMN user_io_pct FORMAT 990.0 HEADING "UsrIO%"
COLUMN wait_pct FORMAT 990.0 HEADING "Wait%"
COLUMN client_id FORMAT A40 TRUNCATE HEADING "Client ID"

DECLARE
  FUNCTION validate(p_value IN VARCHAR2) RETURN VARCHAR2 IS
    c_format_mask_date CONSTANT VARCHAR2(24) := 'YYYY-MM-DD_HH24:MI:SS';
    c_format_mask_timestamp CONSTANT VARCHAR2(24) := c_format_mask_date || 'XFF';
  BEGIN
    -- Check if the input value can be parsed by adding as prefix the current day.
    -- The followings are examples of valid values:
    --  * HH24:MI:SSXFF (e.g. 23:15:35.123456789)
    --  * HH24:MI:SS    (e.g. 23:15:35)
    --  * HH24:MI       (e.g. 23:15)
    --  * HH24          (e.g. 23)
    BEGIN
      RETURN to_char(to_timestamp(to_char(sysdate, 'YYYY-MM-DD_') || p_value, c_format_mask_timestamp), c_format_mask_timestamp);
    EXCEPTION
      WHEN others THEN NULL;
    END;

    -- Check if the input value can be parsed as is.
    -- The followings are examples of valid values:
    --  * YYYY-MM-DD_HH24:MI:SSXFF (e.g. 2014-10-13_23:15:35.123456789)
    --  * YYYY-MM-DD_HH24:MI:SS    (e.g. 2014-10-13_23:15:35)
    --  * YYYY-MM-DD_HH24:MI       (e.g. 2014-10-13_23:15)
    --  * YYYY-MM-DD_HH24          (e.g. 2014-10-13_23)
    --  * YYYY-MM-DD               (e.g. 2014-10-13)
    BEGIN
      RETURN to_char(to_timestamp(p_value, c_format_mask_timestamp), c_format_mask_timestamp);
    EXCEPTION
      WHEN others THEN NULL;
    END;

    -- Check if the input value is a valid expression.
    -- The followings are examples of valid expressions:
    --  * systimestamp-1/24/60 (one minute ago)
    --  * systimestamp         (now)
    --  * sysdate-(1/24/60)*10 (10 minutes ago)
    --  * sysdate              (now)
    DECLARE
      l_ret VARCHAR2(21);
    BEGIN
      EXECUTE IMMEDIATE 'SELECT to_char(' || p_value || ', ''' || c_format_mask_date || ''') FROM dual' INTO l_ret;
      RETURN l_ret;
    EXCEPTION
      WHEN others THEN NULL;
    END;

    RAISE_APPLICATION_ERROR (-20000, 'Invalid input value: "' || p_value || '"', FALSE);
  END validate;
BEGIN
 :t1 := validate('&1');
 :t2 := validate('&2');
END;
/

SELECT :t1 AS begin_timestamp, :t2 AS end_timestamp, count(*) AS ash_samples
FROM v$active_session_history
WHERE sample_time > to_timestamp(:t1,'YYYY-MM-DD_HH24:MI:SSXFF')
AND sample_time <= to_timestamp(:t2,'YYYY-MM-DD_HH24:MI:SSXFF');

SELECT ash.activity_pct,
       ash.db_time,
       round(ash.cpu_time / ash.db_time * 100, 1) AS cpu_pct,
       round(ash.user_io_time / ash.db_time * 100, 1) AS user_io_pct,
       round(ash.wait_time / ash.db_time * 100, 1) AS wait_pct,
       ash.client_id
FROM (
  SELECT round(100 * ratio_to_report(sum(1)) OVER (), 1) AS activity_pct,
         sum(1) AS db_time,
         sum(decode(session_state, 'ON CPU', 1, 0)) AS cpu_time,
         sum(decode(session_state, 'WAITING', decode(wait_class, 'User I/O', 1, 0), 0)) AS user_io_time,
         sum(decode(session_state, 'WAITING', 1, 0)) - sum(decode(session_state, 'WAITING', decode(wait_class, 'User I/O', 1, 0), 0)) AS wait_time,
         client_id 
  FROM v$active_session_history
  WHERE sample_time > to_timestamp(:t1,'YYYY-MM-DD_HH24:MI:SSXFF')
  AND sample_time <= to_timestamp(:t2,'YYYY-MM-DD_HH24:MI:SSXFF')
  GROUP BY client_id
  ORDER BY sum(1) DESC
) ash
WHERE rownum <= 10;

UNDEFINE 1
UNDEFINE 2
