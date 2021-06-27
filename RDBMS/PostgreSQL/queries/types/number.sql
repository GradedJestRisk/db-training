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