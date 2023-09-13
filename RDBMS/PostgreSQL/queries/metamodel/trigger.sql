-- https://www.postgresql.org/docs/current/catalog-pg-trigger.html

SELECT *
FROM pg_trigger trg
WHERE 1=1
--    AND trg.
 AND trg.tgrelid = 'answers'::regclass
;


-- Trigger name + Table
SELECT
    tgname "name"
  , relname tableName
  , tgenabled state
--  , nspname namespace
from pg_trigger
         join pg_class on (pg_class.oid = pg_trigger.tgrelid)
         join pg_namespace on (nspowner = relowner);


-- tgenabled (To check if its disabled)
--
-- O = trigger fires in "origin" and "local" modes,
-- D = trigger is disabled,
-- R = trigger fires in "replica" mode,
-- A = trigger fires always.



-- Trigger name + source
SELECT
    trg.tgname trg_name,
    p.prosrc   trg_src
FROM
    pg_trigger trg INNER JOIN pg_proc p ON p.oid = trg.tgfoid
WHERE 1=1
    AND trg.tgrelid = 'public.answers'::regclass
    AND trg.tgname = 'trg_answers'
ORDER BY
    trg.tgname;



SELECT event_object_table
      ,trigger_name
      ,event_manipulation
      ,action_statement
      ,action_timing
FROM  information_schema.triggers
WHERE 1=1
-- AND event_object_table = 'tableName'
ORDER BY event_object_table
     ,event_manipulation
;