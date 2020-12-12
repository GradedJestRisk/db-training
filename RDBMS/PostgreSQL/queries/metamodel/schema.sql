SELECT
       schema_name
FROM
information_schema.schemata sch
WHERE 1=1
--    AND sch.schema_name = 'tests'
ORDER BY sch.schema_name ASC
;