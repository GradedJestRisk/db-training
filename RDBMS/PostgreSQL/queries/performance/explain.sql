--https://www.postgresql.org/docs/current/auto-explain.html
LOAD 'auto_explain';
SET auto_explain.log_min_duration = 0;
SET auto_explain.log_analyze = true;


EXPLAIN ANALYZE
SELECT * FROM foo
;