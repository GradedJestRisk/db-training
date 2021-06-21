SELECT
   NOW(),
   current_timestamp,
   DATE(current_timestamp)
;


SELECT
    TO_CHAR(NOW(),'HH:MI:SS')
;

SELECT
    t.xact_start
FROM pg_stat_activity t
WHERE 1=1
   AND t.xact_start BETWEEN current_timestamp - interval '1 day' AND current_timestamp
;

