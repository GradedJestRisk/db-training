-----------------------
-- INTEGER   ---
----------------------

-- Range
SELECT
    1::integer,
    8     byte_size_in_bits,
    4 * 8 integer_size,  -- 4 bytes (4 octet)
    POWER(2, 4 * 8 )     max_unsigned_integer,
    POWER(2, 4 * 8 ) / 2 max_signed_integer,
    POWER(2, 8 * 8 ) / 2 max_signed_biginteger
--  ,(2147483648 + 1 )::integer --[22003] ERROR: integer out of range
;
--             2 147 483 648 -- INT
-- 9 223 372 036 854 776 000 -- BIGINT
--     9 007 199 254 740 991 -- MAX_SAFE_JS
--     9 007 199 254 740 992 -- INSERT


SELECT
    1::integer,
    1::integer::bigint
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

SELECT
TRUNC(1 :: decimal / 3 :: decimal * 100) || '%';