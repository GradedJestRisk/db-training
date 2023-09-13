-- https://www.postgresql.org/docs/current/functions-datetime.html

SELECT
    CURRENT_DATE,
    EXTRACT(DAY FROM CURRENT_DATE),
    EXTRACT(MONTH FROM CURRENT_DATE),
    EXTRACT(YEAR FROM CURRENT_DATE)
;

-- Litteral
WITH t AS ( SELECT '2021-06-11' :: DATE as date )
SELECT
    t.date,
    EXTRACT(DAY FROM t.date)
FROM t
WHERE t.date BETWEEN '2021-06-1' AND '2021-06-12'
;




SELECT
    t.min_time
FROM pg_stat_statements t
WHERE 1=1
   AND t.min_time BETWEEN '2021-06-11' AND '2021-06-11'
;
