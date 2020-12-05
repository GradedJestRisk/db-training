WITH source AS
    (SELECT 1 AS id
    UNION
    SELECT 2 AS id)
SELECT
   id
FROM source
WHERE id >= 0
;


WITH RECURSIVE t(n) AS (
    VALUES (1)
  UNION ALL
    SELECT n+1 FROM t WHERE n < 3
)
-- 1
-- 2
-- 3
SELECT * FROM t;
-- Serie 1 + 2 + 3 = 6
SELECT SUM(n) FROM t;