-- Generate text sample
SELECT t.data
FROM (
     SELECT '123AB' AS data UNION
     SELECT '123A'  AS data
         ) t
;

SELECT char_length('foo');

SELECT char_length('foo');

SELECT substring('foo-bar' from 5 for 3);

SELECT repeat('FOO-', 2)
;


---- Regular expression --------
-- https://www.postgresql.org/docs/current/functions-matching.html

SELECT
 'abc' ~ 'abc',
 'abc' ~ '[a-z]{3}',
 'abc' ~ '[a-z]{4}',
 '123abc' ~ '^[0-9]{3}[a-z]{3}',
 '123abc' ~ '^[0-9]{4}[a-z]{3}'
;


SELECT
       t.data
FROM (
     SELECT '123A'  AS data UNION
     SELECT '12AB'  AS data UNION
     SELECT 'ABC' AS data
         ) t
WHERE 1=1
    AND NOT (    t.data ~ '^[0-9]{3}[a-zA-Z]{1}'
           OR  t.data ~ '^[0-9]{2}[a-zA-Z]{2}')
;

