WITH source AS
    (SELECT 1 AS id
    UNION
    SELECT 2 AS id)
SELECT
   id
FROM source
WHERE id >= 0
;

WITH people AS
    (SELECT 1 AS id, 'John' AS name
    UNION
    SELECT 2 AS id, 'Mary' AS name )
SELECT
   name
FROM people
WHERE id >= 0
;


-- Values
SELECT name
FROM ( VALUES
           (1, 'John'),
           (2, 'Mary') )
    AS people(id, name)
WHERE people.id >= 0
;

-- UNION
SELECT name
FROM  (
    SELECT 1 AS id, 'John' AS name
    UNION
    SELECT 2 AS id, 'Mary' AS name ) people
WHERE people.id >= 0
;


-- WITH + Values
WITH people AS (
SELECT id, name FROM(
    VALUES
           (1, 'John'),
           (2, 'Mary')
    )
    AS tmp(id, name)
)
SELECT
   id
FROM people
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