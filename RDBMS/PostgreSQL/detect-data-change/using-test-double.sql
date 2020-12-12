------------------------------------------------------
-- Prepare for first execution
------------------------------------------------------
DROP VIEW IF EXISTS invalid_assertions;
DROP TABLE IF EXISTS actual_calls;
DROP TABLE IF EXISTS expected_calls;


CREATE TABLE expected_calls (
    object    VARCHAR,
    arguments VARCHAR,
    sequence  INTEGER,
    PRIMARY KEY (object, arguments)
);

CREATE TABLE actual_calls (
    id        SERIAL,
    object    VARCHAR,
    arguments VARCHAR,
    called_at TIMESTAMP DEFAULT NOW(),
    sequence  INTEGER,
    PRIMARY KEY (object, arguments)
);


CREATE VIEW invalid_assertions AS
    SELECT object, arguments, sequence FROM actual_calls
    EXCEPT
    SELECT object, arguments, sequence FROM expected_calls
;


------------------------------------------------------
-- Create test double
------------------------------------------------------

CREATE OR REPLACE FUNCTION test_double( p_first_parameter INTEGER, p_second_parameter TEXT)
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE
   -- Stubbed value
    value CONSTANT TEXT = 'foo';
BEGIN

    INSERT INTO actual_calls ( object, arguments )
    VALUES ('test_double', 'p_first_parameter=' || p_first_parameter || 'p_second_parameter='  || p_second_parameter);

    RETURN value;

END
$BODY$;

------------------------------------------------------
-- Create SUT
------------------------------------------------------

CREATE OR REPLACE PROCEDURE sut()
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE
    value TEXT;
BEGIN

    -- Do stuff

    -- Expected behaviour: call an object a first time(here, the test double)
    SELECT  test_double(p_first_parameter := 1, p_second_parameter := 'foo') INTO value;

    -- Do stuff with returned value
    PERFORM pg_sleep(1);

    -- Expected behaviour: call an object another a second time  (here, the test double)
    SELECT  test_double(p_first_parameter := 1, p_second_parameter := 'bar') INTO value;

    -- Do stuff with returned value
    PERFORM pg_sleep(1);

    -- Unexpected behaviour: call an object a third time (here, the test double)
    SELECT  test_double(p_first_parameter := 3, p_second_parameter := 'foobar') INTO value;

END
$BODY$;


------------------------------------------------------
-- Prepare for each execution
------------------------------------------------------
TRUNCATE TABLE actual_calls;

------------------------------------------------------
-- Set up expectations
------------------------------------------------------
INSERT INTO expected_calls ( object, arguments, sequence )
VALUES ('test_double', 'p_first_parameter=' || 1 || 'p_second_parameter='  || 'foo', 1);

INSERT INTO expected_calls ( object, arguments, sequence )
 VALUES ('test_double', 'p_first_parameter=' || 2 || 'p_second_parameter='  || 'bar', 2);


------------------------------------------------------
-- Call SUT
------------------------------------------------------
CALL sut();

------------------------------------------------------
-- Compute call sequences
------------------------------------------------------

-- TRUNCATE TABLE actual_calls;
--
-- INSERT INTO actual_calls ( object, arguments )
-- VALUES ('test_double', 'p_first_parameter=' || 1 || 'p_second_parameter='  || 'k');
--
-- SELECT pg_sleep(1);
--
-- INSERT INTO actual_calls ( object, arguments )
-- VALUES ('test_double', 'p_first_parameter=' || 2 || 'p_second_parameter='  || 'm');
--
-- SELECT pg_sleep(1);
--
-- INSERT INTO actual_calls ( object, arguments )
-- VALUES ('test_double', 'p_first_parameter=' || 8 || 'p_second_parameter='  || 'l');
--
-- SELECT
--     *
-- FROM
--    actual_calls;
--
-- SELECT id, object, called_at, rank()
-- OVER (PARTITION BY object ORDER BY called_at ASC)
-- FROM actual_calls;

WITH actual_sequence AS (
    SELECT  id, object, called_at, rank()
    OVER (PARTITION BY object ORDER BY called_at ASC)
    FROM actual_calls )
UPDATE actual_calls
SET sequence = actual_sequence.rank
FROM actual_sequence
WHERE actual_calls.id = actual_sequence.id
;

-- SELECT *
-- FROM actual_calls;

------------------------------------------------------
-- Assert
------------------------------------------------------

SELECT object, COUNT(1)
FROM invalid_assertions
GROUP BY object;

SELECT
    object,
    sequence,
    arguments
FROM invalid_assertions
ORDER BY
    object,
    sequence,
    arguments;

SELECT
    *
FROM
   expected_calls
;


SELECT
    object,
    sequence,
    arguments
FROM
   actual_calls;


