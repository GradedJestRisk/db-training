-- hot, see https://www.cybertec-postgresql.com/en/hot-updates-in-postgresql-for-better-performance/
select t.relname as table_name,
       t.reloptions
from pg_class t
  join pg_namespace n on n.oid = t.relnamespace
where t.relname in ('organization-learners')
  and n.nspname = 'public';



DROP TABLE IF EXISTS foo;

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER
 );

ALTER TABLE foo SET (AUTOVACUUM_ENABLED=FALSE);

INSERT INTO foo
  (value)
SELECT
  floor(random() * 2147483627 + 1)::int
FROM
    generate_series( 1, 1000000) -- 1 million => 2 seconds
;

UPDATE foo SET value = value - 1;



-- HOT
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   'hot-update=>',
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
   'events=>',
   stt.n_tup_ins,
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
   stt.n_tup_del,
   'analyze=>',
   stt.last_analyze,
   stt.analyze_count,
   stt.last_autoanalyze,
   stt.autoanalyze_count,
   'vacuum=>',
   stt.last_vacuum,
   stt.vacuum_count,
   stt.last_autovacuum,
   stt.autovacuum_count,
   'pg_stat_user_tables=>'
   ,stt.*
FROM pg_stat_user_tables stt
WHERE 1=1
     AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY stt.n_tup_hot_upd DESC
;


ALTER TABLE foo SET ( fillfactor = 50);
VACUUM FULL foo;


UPDATE foo SET value = value - 1;



-- HOT
SELECT
   stt.relname,
   stt.n_live_tup,
   stt.n_dead_tup,
   'hot-update=>',
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
   'events=>',
   stt.n_tup_ins,
   stt.n_tup_upd,
   stt.n_tup_hot_upd,
   stt.n_tup_del,
   'analyze=>',
   stt.last_analyze,
   stt.analyze_count,
   stt.last_autoanalyze,
   stt.autoanalyze_count,
   'vacuum=>',
   stt.last_vacuum,
   stt.vacuum_count,
   stt.last_autovacuum,
   stt.autovacuum_count,
   'pg_stat_user_tables=>'
   ,stt.*
FROM pg_stat_user_tables stt
WHERE 1=1
     AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY stt.n_tup_hot_upd DESC
;
-- n_hot_tup_upd
-- 1 000 000