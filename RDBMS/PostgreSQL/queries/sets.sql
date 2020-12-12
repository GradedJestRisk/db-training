-- Eliminates duplicate rows from its result, in the same way as DISTINCT, unless UNION ALL is used.

-- UNION
-- All rows that are both in the result of query1 OR in the result of query2
-- Appends the result of query2 to the result of query1

SELECT 1 AS id
UNION
SELECT 2 AS id
;
-- 1
-- 2

-- INTERSECT
-- all rows that are both in the result of query1 AND in the result of query2

(SELECT 1 AS id UNION SELECT 2 AS id)
INTERSECT
(SELECT 1 AS id  UNION SELECT 3 AS id );
-- 1


-- EXCEPT
-- EXCEPT returns all rows that are in the result of query1 AND NOT in the result of query2

(SELECT 1 AS id UNION SELECT 2 AS id)
EXCEPT
(SELECT 1 AS id )
;
-- 2

(SELECT 1 AS id )
EXCEPT
(SELECT 1 AS id UNION SELECT 2 AS id)
;
-- (no rows)