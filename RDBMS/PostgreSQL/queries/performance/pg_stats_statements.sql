CREATE EXTENSION pg_stat_statements;

SELECT *
FROM pg_available_extensions
WHERE 1=1
  AND name = 'pg_stat_statements'
  AND installed_version IS NOT NULL
;

-- Reset
select pg_stat_statements_reset();

-- https://www.postgresql.org/docs/current/pgstatstatements.html

-- Statements + User + Database
SELECT
   usr.rolname,
   db.datname,
   stt.*
FROM pg_stat_statements stt
    INNER JOIN pg_authid usr ON usr.oid = stt.userid
    INNER JOIN pg_database db ON db.oid = stt.dbid
WHERE 1=1
--    AND usr.rolname <> 'postgres'
    AND db.datname = 'database'
;


SELECT
   stt.*
FROM pg_stat_statements stt
WHERE 1=1
    AND stt.query = 'ALTER TABLE foo ALTER COLUMN value TYPE BIGINT'

;

SELECT
       stt.query query_text,
       'count=>',
       stt.calls,
       stt.rows  affected_rows,
       stt.wal_records  wal,
       'time=>',
       stt.total_exec_time cumulated_excution_time,
       stt.min_exec_time,
       stt.max_exec_time,
       stt.mean_exec_time,
       'pg_stat_statements =>',
       stt.*
FROM pg_stat_statements stt
WHERE 1=1
    --AND stt.query ILIKE '%ALTER%'
    AND stt.query ILIKE '%foo%'
    --AND stt.query ILIKE  'INSERT INTO foo (value)%'
    --AND stt.query = 'ALTER TABLE foo ALTER COLUMN value TYPE BIGINT'
;