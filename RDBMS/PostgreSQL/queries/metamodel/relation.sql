-- https://www.postgresql.org/docs/current/catalog-pg-class.html
-- When we mean all of these kinds of objects we speak of “relations”
-- relkind = content
-- r = ordinary table
-- i = index
-- S = sequence
-- v = view
-- m = materialized view
-- c = composite type
-- t = TOAST table
-- f = foreign table


-- Relation
SELECT
   rl.oid     obj_dtf,
   rl.relkind rlt_typ,
   CASE
        WHEN rl.relkind = 'r' THEN 'table'
        WHEN rl.relkind = 'i' THEN 'index'
        WHEN rl.relkind = 'S' THEN 'sequence'
        WHEN rl.relkind = 'v' THEN 'view'
        WHEN rl.relkind = 'm' THEN 'materialized view'
        WHEN rl.relkind = 'c' THEN 'composite type'
        WHEN rl.relkind = 't' THEN 'TOAST table'
        WHEN rl.relkind = 'f' THEN 'foreign table'
    END AS rlt_typ,
   rl.relname rlt_nm,
   rl.*
FROM
     pg_class rl
WHERE 1=1
    --AND relkind = 'r'
--    AND oid     IN ( 138183, 30074)
ORDER BY
    relname ASC
;


-- Relation
-- Given OID (object identifier)
SELECT 16393::regclass
;


-- Relation
-- Given OID (object identifier)
SELECT
   rl.oid     obj_dtf,
   rl.relkind rlt_typ,
   rl.relname rlt_nm,
   rl.*
FROM
     pg_class rl
WHERE 1=1
    --AND relkind = 'r'
--    AND oid     IN ( 138183, 30074)
ORDER BY
    relname ASC
;


-- Relation + Namespace
-- Given namespace/name
SELECT
   rl.oid     obj_dtf,
   rl.relkind rlt_typ,
   rl.relname rlt_nm,
   ns.nspname ns_nm,
   ns.*,
   rl.*
FROM
     pg_class rl
        INNER JOIN pg_namespace ns ON ns.oid = rl.relnamespace
WHERE 1=1
    --AND relkind = 'r'
--    AND oid     IN ( 138183, 30074)
    AND ns.nspname = 'public'
ORDER BY
    relname ASC
;


SELECT *
FROM pg_namespace
;