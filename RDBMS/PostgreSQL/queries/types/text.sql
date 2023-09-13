-- Generate text sample
SELECT t.data
FROM (
     SELECT '123AB' AS data UNION
     SELECT '123A'  AS data
         ) t
;

-- Pattern matching
SELECT
    t.data
FROM (
     SELECT '123AB' AS data UNION
     SELECT '123A'  AS data
         ) t
WHERE 1=1
--     AND t.data LIKE '123A%'
--     AND t.data LIKE '123A'
    AND t.data LIKE '123'
;

-- Length
SELECT CHAR_LENGTH('foo');

SELECT char_length('foo');

SELECT
    substring('foo-bar' from 5 for 3),
    substring('foo-bar' from 1 for 3) || repeat('*', CHAR_LENGTH('foo-bar') - 3 - 1),
    'mister foo bar',
    SUBSTRING('mister foo bar' from 1 for 3) || REPEAT('*', CHAR_LENGTH('mister foo bar') - 3 - 1)
    ;

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

CREATE TABLE test ( text TEXT);
INSERT INTO test (text) VALUES (E'\u0000');

INSERT INTO test (text) VALUES (\0x00);