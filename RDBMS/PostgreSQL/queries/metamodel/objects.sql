SELECT
    nsp.nspname as SchemaName
    ,cls.relname as ObjectName
    ,rol.rolname as ObjectOwner
    ,case cls.relkind
        when 'r' then 'TABLE'
        when 'm' then 'MATERIALIZED_VIEW'
        when 'i' then 'INDEX'
        when 'S' then 'SEQUENCE'
        when 'v' then 'VIEW'
        when 'c' then 'TYPE'
        else cls.relkind::text
    end as ObjectType
FROM pg_class cls
  JOIN pg_roles rol ON rol.oid = cls.relowner
  JOIN pg_namespace nsp ON nsp.oid = cls.relnamespace
WHERE 1=1
  AND nsp.nspname not in ('information_schema', 'pg_catalog')
  AND nsp.nspname not like 'pg_toast%'
  AND rol.rolname = 'postgres'
  --AND cls.relkind = 'c'
ORDER by nsp.nspname, cls.relkind, cls.relname
;

WITH types AS (
    SELECT n.nspname,
            pg_catalog.format_type ( t.oid, NULL ) AS obj_name,
            CASE
                WHEN t.typrelid != 0 THEN CAST ( 'tuple' AS pg_catalog.text )
                WHEN t.typlen < 0 THEN CAST ( 'var' AS pg_catalog.text )
                ELSE CAST ( t.typlen AS pg_catalog.text )
                END AS obj_type,
            coalesce ( pg_catalog.obj_description ( t.oid, 'pg_type' ), '' ) AS description
        FROM pg_catalog.pg_type t
        JOIN pg_catalog.pg_namespace n
            ON n.oid = t.typnamespace
        WHERE ( t.typrelid = 0
                OR ( SELECT c.relkind = 'c'
                        FROM pg_catalog.pg_class c
                        WHERE c.oid = t.typrelid ) )
            AND NOT EXISTS (
                    SELECT 1
                        FROM pg_catalog.pg_type el
                        WHERE el.oid = t.typelem
                        AND el.typarray = t.oid )
            AND n.nspname <> 'pg_catalog'
            AND n.nspname <> 'information_schema'
            AND n.nspname !~ '^pg_toast'
),
cols AS (
    SELECT n.nspname::text AS schema_name,
            pg_catalog.format_type ( t.oid, NULL ) AS obj_name,
            a.attname::text AS column_name,
            pg_catalog.format_type ( a.atttypid, a.atttypmod ) AS data_type,
            a.attnotnull AS is_required,
            a.attnum AS ordinal_position,
            pg_catalog.col_description ( a.attrelid, a.attnum ) AS description
        FROM pg_catalog.pg_attribute a
        JOIN pg_catalog.pg_type t
            ON a.attrelid = t.typrelid
        JOIN pg_catalog.pg_namespace n
            ON ( n.oid = t.typnamespace )
        JOIN types
            ON ( types.nspname = n.nspname
                AND types.obj_name = pg_catalog.format_type ( t.oid, NULL ) )
        WHERE a.attnum > 0
            AND NOT a.attisdropped
)
SELECT cols.schema_name,
        cols.obj_name,
        cols.column_name,
        cols.data_type,
        cols.ordinal_position,
        cols.is_required,
        coalesce ( cols.description, '' ) AS description
    FROM cols
    ORDER BY cols.schema_name,
            cols.obj_name,
            cols.ordinal_position ;

