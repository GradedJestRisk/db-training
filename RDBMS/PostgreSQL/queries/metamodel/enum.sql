-- Get them
SELECT
    t.typname AS name,
    e.enumlabel AS value
FROM pg_type t
   INNER JOIN pg_enum e ON t.oid = e.enumtypid
   INNER JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
;

-- Usage in table
SELECT data_type, count(data_type)
FROM information_schema.columns clm
WHERE 1=1
AND data_type = 'enum'
GROUP BY data_type
ORDER BY data_type ASC
;