
-- Get sequence definition
SELECT
   sqn.sequencename,
   sqn.data_type,
   sqn.start_value,
   sqn.increment_by
--    ,'pg_sequences=>'
--    ,sqn.*
FROM
     pg_sequences sqn
WHERE 1=1
    AND sqn.schemaname = 'public'
;


-- get current value (psql only)

select $$with data as ($$ || (select string_agg(format(
                                                        $$select %L table_name, (select last_value from %s) last_value, (select max(id) from %I) max_id$$,
                                                        rel.relname, pg_get_serial_sequence(rel.relname, 'id'),
                                                        rel.relname), ' UNION ')
                              from pg_attribute att
                                       inner join pg_class rel on att.attrelid = rel.oid
                              where rel.relkind = 'r'
                                and attname = 'id') ||
       $$) select *, max_id - last_value "max_id - last_value" from data order by table_name $$
\gexec


--             table_name            | last_value |  max_id  | max_id - last_value
-- ----------------------------------+------------+----------+---------------------
--  account-recovery-demands         |   10000000 |   100065 |            -9899935
--  answers                          |   10000000 |   106057 |            -9893943
--  assessment-results               |   10000000 |   105663 |            -9894337
--  assessments                      |   10000000 |   106044 |            -9893956
--  authentication-methods           |   10000000 |   106658 |            -9893342
--  badge-acquisitions               |   10000000 |   105888 |            -9894112
--  badge-criteria                   |   10000000 |   100508 |            -9899492



-- Check if a sequence is used
SELECT
    c.table_name,
    c.column_name,
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length,
    'columns=>',
     c.*
  FROM information_schema.columns c
WHERE 1=1
    AND c.table_catalog = 'pix'
    AND c.table_schema  = 'public'
--    AND c.table_name = 'challenges'
    AND c.column_name = 'id'
    AND c.column_default ILIKE 'nextval(%'
--    AND c.column_name LIKE '%Id'
ORDER BY
    c.table_name, c.column_name ASC
;