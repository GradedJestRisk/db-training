-- https://www.postgresql.org/docs/current/functions-formatting.html
SELECT
    1050445,
    TO_CHAR(
        1050445,
        '999G999G999G999D99'
    ) amount_format;