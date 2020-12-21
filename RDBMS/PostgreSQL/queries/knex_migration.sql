
SELECT
  'migration:'
  ,mgr.id
  ,mgr.name            filename
  ,mgr.migration_time  executed_at
  ,'knex_migrations=>'
  ,mgr.*
FROM knex_migrations mgr
WHERE 1=1
ORDER BY
    mgr.migration_time DESC
;