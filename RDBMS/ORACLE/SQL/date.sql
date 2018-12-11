
-- Hour to String
SELECT
   TO_CHAR(SYSDATE,'HH24:MI')
FROM dual;



SELECT 
--   MOD(TRUNC(24 * 60 * (periode.date_fin - periode.date_debut)), 60) duree_secondes
    periode.date_fin - periode.date_debut                             duree_jour
--   ,MOD(TRUNC(24 * 60 * (periode.date_fin - periode.date_debut)), 60) duree_minutes
FROM 
   (SELECT 
       SYSDATE      date_debut
--    ,SYSDATE + 1  date_fin
      , TO_DATE('20180727-16:00','YYYYMMDD-HH24:MI') date_fin
   FROM DUAL ) periode
;


-- Add minute to a date (not working with PL variable)
SELECT 
   sysdate                        current_date, 
   sysdate + interval '5' minute  future_date
from dual;

-- Add minute to a date (working with PL variable)
start_date           := SYSDATE;
max_duration_minutes := '1';
max_end_date         := start_date + NUMTODSINTERVAL(max_duration_minutes, 'MINUTE');


