-----------------------
-- INTEGER   ---
----------------------

-- Range
SELECT
    1::integer,
    POWER(2,4 * 8 )/2 max_integer, -- 4 * 8-bit bytes (4 octet)
    POWER(2,32)/2 max_integer
--  ,(POWER(2,32)/2 +1 )::integer --[22003] ERROR: integer out of range
;


-- Range exceeded
DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER UNIQUE);

INSERT INTO foo VALUES (1);
INSERT INTO foo(id) VALUES( (POWER(2, 32) / 2) + 1 );
--[22003] ERROR: integer out of range

ALTER TABLE foo ALTER COLUMN id TYPE BIGINT;

INSERT INTO foo(id) VALUES((POWER(2,32)/2) + 1 );

SELECT * from foo;

------------------------
-- NUMBER   ---
----------------------


-- https://www.postgresql.org/docs/current/functions-formatting.html
SELECT
    1050445 amount,
    TO_CHAR(
        1050445,
        '999G999G999G999D99'
    ) formatted_amount
;

-- Locale used for number formatting
SHOW lc_numeric;

-- Does not alter behaviour ?
SET lc_numeric = 'en_US.utf8';

SET lc_numeric = 'fr_FR.utf8';