--------------------------------------------------------------------------
--------------      Date format                    -------------
---------------------------------------------------------------------------

ALTER SESSION SET NLS_DATE_FORMAT = 'HH24:MI:SS';
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYYMMDD-HH24:MI:SS';

SELECT * FROM nls_session_parameters 
WHERE parameter = 'NLS_DATE_FORMAT'
; 




---------------------------------------------------------------------------
--------------      Date                   -------------
---------------------------------------------------------------------------


-- Specify date from string using date mask
SELECT 
   TO_DATE('00010101', 'YYYYMMDD')  date_type
FROM 
   dual
;

-- Extract minute
SELECT 
   EXTRACT(MINUTE FROM DATE '20180101-16:02:01') minute
FROM 
   DUAL
;


-- Extract other
SELECT 
   'Extract fields from date=>'
   ,SYSDATE                   system_date 
   ,TO_CHAR(SYSDATE,  'YYYY') year
   ,TO_CHAR(SYSDATE,  'MM')   month
   ,TO_CHAR(SYSDATE,  'DD')   day_of_month
   ,TO_CHAR(SYSDATE, 'HH24')  hour
   ,TO_CHAR(SYSDATE, 'MI')    minute
   ,TO_CHAR(SYSDATE, 'SS')    second
FROM 
   dual
;

-- Julian start
-- 5th millenium
--  saw the spread of agriculture from Western Asia throughout Southern and Central Europe.
SELECT
  'Julian start at BC: =>' 
  ,TO_CHAR(
    TO_DATE(1, 'J'),
    'DD/MM/YYYY')
FROM 
  dual
;


-- Julian (number) to date
SELECT
  'Julian to Gregorian =>' 
   ,TO_DATE(2459725, 'J')
FROM 
  dual
;

-- Julian Epoch (start)
SELECT
  'Julian Epoch =>' 
   ,TO_DATE(1, 'J')
FROM 
  dual
;

-- Julian end
SELECT
  'Julian Epoch =>' 
   ,TO_DATE(5373484, 'J')
FROM 
  dual
;

-- Julian to Gregorian
SELECT
  'Julian to Gregorian =>' 
  ,TO_CHAR(
    TO_DATE(2459725, 'J'),
    'DD/MM/YYYY')
FROM 
  dual
;


-- Gregorian to Julian 
SELECT
  'Gregorian to Julian =>' 
  ,        TO_DATE('20000101', 'YYYYMMDD')       dt_gregorian
  ,TO_CHAR(TO_DATE('19830404', 'YYYYMMDD'), 'J') dt_julian
  ,TO_NUMBER(TO_CHAR(TO_DATE('19830404', 'YYYYMMDD'), 'J')) dt_julian_number
FROM 
  dual
;


-- Bith in julian
SELECT
   FLOOR(MONTHS_BETWEEN (SYSDATE, TO_DATE(2445429,'J')) / 12)  age_completed
FROM  
  dual
;


-- Birth this year
SELECT
   FLOOR(MONTHS_BETWEEN (SYSDATE, TO_DATE('20190101', 'YYYYMMDD')) / 12)  age_completed
   ,CEIL(MONTHS_BETWEEN (SYSDATE, TO_DATE('20190101', 'YYYYMMDD')) / 12)  age_incoming
FROM  
  dual
;

-- Previous birth
SELECT
   FLOOR(MONTHS_BETWEEN (SYSDATE, TO_DATE('19830404', 'YYYYMMDD')) / 12)  age_completed
   ,CEIL(MONTHS_BETWEEN (SYSDATE, TO_DATE('19830404', 'YYYYMMDD')) / 12)  age_incoming
FROM  
  dual
;

---------------------------------------------------------------------------
--------------      Timestamp                   -------------
---------------------------------------------------------------------------


SELECT 
   'Extract fields form timestamp'
   ,SYSTIMESTAMP
   ,EXTRACT(HOUR   FROM SYSTIMESTAMP)  hour
   ,EXTRACT(MINUTE FROM SYSTIMESTAMP)  minute
   ,EXTRACT(SECOND FROM SYSTIMESTAMP)  second
FROM 
   dual
;


---------------------------------------------------------------------------
--------------      Interval                   -------------
---------------------------------------------------------------------------

WITH 
   base AS(
      SELECT 
          TO_DATE('20181201-16:02:01','YYYYMMDD-HH24:MI:SS')  start_time,
          TO_DATE('20181206-18:06:04','YYYYMMDD-HH24:MI:SS')  end_time
      FROM DUAL ),

   duration AS(
      SELECT
         end_time - start_time                           elapsed_days,
         NUMTODSINTERVAL(end_time - start_time , 'DAY')  elapsed_interval
      FROM base )
SELECT 
   duration.elapsed_days,
   duration.elapsed_interval,
--   EXTRACT( YEAR   FROM duration.elapsed_interval)  year_from_interval,
--   EXTRACT( MONTH  FROM duration.elapsed_interval)  month_from_interval,
   EXTRACT( DAY    FROM duration.elapsed_interval)  day_from_interval,
   EXTRACT( HOUR   FROM duration.elapsed_interval)  hour_from_interval,
   EXTRACT( MINUTE FROM duration.elapsed_interval)  minute_from_interval,
   EXTRACT( SECOND FROM duration.elapsed_interval)  second_from_interval
FROM 
   duration
;


---------------------------------------------------------------------------
--------------      Operations on dates                    -------------
---------------------------------------------------------------------------

-- Add minute to a date (not working with PL variable)
SELECT 
   sysdate                        current_date, 
   sysdate + interval '5' minute  future_date
from dual;

-- Add minute to a date (working with PL variable)
start_date           := SYSDATE;
max_duration_minutes := '1';
max_end_date         := start_date + NUMTODSINTERVAL(max_duration_minutes, 'MINUTE');


-- Duration (elapsed time between dates)
WITH 
   period AS(
      SELECT 
          TO_DATE('20181201-16:00:01','YYYYMMDD-HH24:MI:SS')  period_start
   --      ,SYSDATE      period_start
         ,TO_DATE('20181201-19:02:02','YYYYMMDD-HH24:MI:SS') period_end
   --      ,SYSDATE     period_end
      FROM DUAL ), 

   duration AS (
      SELECT
         period.period_end - period.period_start    days,   
          24 * 60 * 60                              seconds_per_day,
          24 * 60                                   minutes_per_day,
          24                                        hours_per_day
      FROM period
   )
SELECT 
   'COUNTS=>' rpr_cnt
   ,      duration.days * seconds_per_day          seconds
   ,ROUND(duration.days * seconds_per_day, 0)      seconds_rounded
   ,      duration.days * minutes_per_day          minutes
   ,ROUND(duration.days * minutes_per_day, 0)      minutes_rounded
   ,      duration.days                            days
   ,ROUND(duration.days )                          days_rounded
   ,'BASE=>' rpr_cnt
   ,MOD(TRUNC(duration.days * hours_per_day)   , 24) hours
   ,MOD(TRUNC(duration.days * minutes_per_day ), 60) minutes
   ,MOD(TRUNC(duration.days * seconds_per_day),  60) seconds
FROM 
   duration
;
