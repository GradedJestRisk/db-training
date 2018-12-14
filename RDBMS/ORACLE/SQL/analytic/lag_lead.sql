WITH data AS (
   SELECT 1 AS VALUE FROM DUAL 
   UNION ALL
   SELECT 2 AS VALUE FROM DUAL 
   UNION ALL
   SELECT 5 AS VALUE FROM DUAL  )
SELECT 
   value
FROM 
   data
;

WITH data AS (
   SELECT 1 AS value FROM DUAL 
   UNION ALL
   SELECT 2 AS value FROM DUAL 
   UNION ALL
   SELECT 5 AS value FROM DUAL  )
SELECT 
   value, 
   LAG(value)  OVER (ORDER BY value ASC) previous_value,
   LEAD(value) OVER (ORDER BY value ASC) next_value
FROM 
   data
;

