-- https://www.postgresql.org/docs/current/catalog-pg-type.html
SELECT *
FROM pg_type tp
WHERE 1=1
  AND tp.typcategory = 'U'
;

--Table 53.65. typcategory Codes
--Code 	Category
--A 	Array types
--B 	Boolean types
--C 	Composite types
--D 	Date/time types
--E 	Enum types
--G 	Geometric types
--I 	Network address types
--N 	Numeric types
--P 	Pseudo-types
--R 	Range types
--S 	String types
--T 	Timespan types
--U 	User-defined types
--V 	Bit-string types
--X 	unknown type
--Z 	Internal-use types

-- user +
SELECT
  nm.nspname,
  sr.rolname,
  tp.typname,
  tp.typcategory,
  'pg_type=>',
  tp.*
FROM pg_type tp
  INNER JOIN pg_authid sr ON sr.oid = tp.typowner
  INNER JOIN pg_namespace nm ON nm.oid = tp.typnamespace
WHERE 1=1
  AND nm.nspname = 'pgboss'
  --AND tp.typcategory IN ('U','E','C','A')
  --AND sr.rolname = 'postgresql'
  --AND tp.typname = 'job_state'
;


SELECT
  nm.nspname,
  tp.typname,
  tp.typcategory,
  'pg_type=>',
  tp.*
FROM pg_type tp
  INNER JOIN pg_namespace nm ON nm.oid = tp.typnamespace
WHERE 1=1
  AND nm.nspname = 'pgboss'
;
