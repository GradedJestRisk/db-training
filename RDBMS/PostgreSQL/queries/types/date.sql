-- https://www.postgresql.org/docs/current/functions-datetime.html

SELECT CURRENT_DATE
;



SELECT
    *
FROM pg_stat_statements t
WHERE 1=1
   AND t.min_time BETWEEN '2021-06-11' AND '2021-06-11'
;
