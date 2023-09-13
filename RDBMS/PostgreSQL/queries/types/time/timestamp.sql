-- Get actual
SELECT
   NOW() now,
   CURRENT_TIMESTAMP now
;

-- Literal
SELECT
   '2018-09-02 07:09:19'::TIMESTAMP AT TIME ZONE 'America/Los_Angeles'
;

-- Operate
SELECT
   NOW(),
   NOW() AT TIME ZONE 'UTC',
   NOW() AT TIME ZONE 'Europe/Paris',
   '2018-09-02 07:09:19'::TIMESTAMP AT TIME ZONE 'America/Los_Angeles',
   NOW() + interval '3 DAYS',
   NOW() - '2023-08-02 07:09:19'::TIMESTAMP
;

-- Filter on TIMESTAMP column
SELECT
    t.xact_start
FROM pg_stat_activity t
WHERE 1=1
   AND t.xact_start BETWEEN current_timestamp - interval '1 day' AND current_timestamp
;

-- Convert (cast)
SELECT
   NOW() moment,
   NOW() :: DATE date,
   DATE(current_timestamp) date,
   DATE(TIMEZONE('Europe/Paris', current_timestamp)) date,
   TO_CHAR(NOW(),'HH:MI:SS') hour_min_s,
   TO_CHAR(NOW(),'YYYY-MM') year_month
;

-- Create index
DROP TABLE foo;
CREATE TABLE foo ( moment TIMESTAMP WITH TIME ZONE);

INSERT INTO foo (moment) VALUES ( NOW() );
INSERT INTO foo (moment) VALUES ( NOW() + interval ' 1 DAYS' );
INSERT INTO foo (moment) VALUES ( NOW() + interval ' 3 DAYS' );
INSERT INTO foo (moment) VALUES ( NOW() + interval ' 3 YEARS' );

SELECT
    moment,
    moment :: DATE,
    TO_CHAR(moment, 'YYYY-MM') year_month
   -- year_month(moment :: TIMESTAMP)
FROM foo
WHERE TO_CHAR("moment", 'YYYY-MM') = '2021-09'
;

-- DATE index
DROP INDEX ndx_date;
CREATE INDEX ndx_date ON foo (DATE(TIMEZONE('UTC', moment)));


-- Partial date index

-- https://stackoverflow.com/questions/5973030/error-functions-in-index-expression-must-be-marked-immutable-in-postgres
CREATE OR REPLACE FUNCTION year_month(some_time TIMESTAMP WITH TIME ZONE)
  RETURNS text
AS
$BODY$
    SELECT TO_CHAR($1, 'YYYY-MM');
$BODY$
LANGUAGE sql
IMMUTABLE;

DROP INDEX ndx_year_month;
CREATE INDEX ndx_year_month ON foo (year_month(moment));

SELECT
  COUNT(1)
FROM foo
WHERE  1=1
  AND year_month(moment) = '2021-09'
;

DROP INDEX ndx_year_month_answers;
CREATE INDEX ndx_year_month_answers ON answers (year_month("createdAt"));

SELECT
    "createdAt",
    year_month("createdAt")
FROM answers
WHERE  1=1
--  AND year_month("createdAt") = '2021-09'
;

EXPLAIN
SELECT
  COUNT(1)
FROM answers
WHERE  1=1
  AND year_month("createdAt") = '2019-12'
;
-- QUERY PLAN
-- Aggregate  (cost=36.11..36.12 rows=1 width=8)
--   ->  Bitmap Heap Scan on answers  (cost=4.38..36.08 rows=13 width=0)
-- "        Recheck Cond: (year_month(""createdAt"") = '2019-12'::text)"
--         ->  Bitmap Index Scan on ndx_year_month_answers  (cost=0.00..4.38 rows=13 width=0)
-- "              Index Cond: (year_month(""createdAt"") = '2019-12'::text)"



SELECT
  COUNT(1)
FROM foo
WHERE  1=1
  AND moment BETWEEN '2021-01-01 00:00:00.000000 +00:00' AND '2022-01-01 00:00:00.000000 +00:00'
--  AND moment BETWEEN '2021-01-01 00:00:00.000000 +00:00' AND NOW()
;
SELECT COUNT(1) FROM answers WHERE "createdAt" BETWEEN '2021-08-01 00:00:00.000000 +00:00' AND '2021-08-31 23:59:00.00000 +00:00';;





