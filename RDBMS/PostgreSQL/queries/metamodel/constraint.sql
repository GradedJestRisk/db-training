-- Constraint type
SELECT
       pgc.contype, COUNT(1)
FROM pg_constraint pgc
GROUP BY pgc.contype
;
-- p primary
-- c check
-- u unique
-- f foreign

-- Deferabble
--  => see https://begriffs.com/posts/2017-08-27-deferrable-sql-constraints.html

-- Constraints
SELECT
    'constraint=>'
    ,pgc.convalidated
    ,pgc.condeferrable
    ,pgc.condeferred
    ,pgc.contype
   ,'pg_constraint=>'
   ,pgc.*
FROM pg_constraint pgc
WHERE 1=1
--    AND pgc.conname = 'id_not_null'
      AND pgc.conname ILIKE '%recovery%'
  AND pgc.contype = 'f'
--     AND pgc.condeferrable IS TRUE
;

-- Constraints
SELECT
       'constraint=>'    qry
       ,pgc.contype      cnt_type
       ,pgc.conname      constraint_name
       ,ccu.table_schema "schema"
       ,ccu.table_name   "table"
       ,ccu.column_name  "column"
       ,pg_get_constraintdef(pgc.oid) definition
       --pgc.*
FROM pg_constraint pgc
    JOIN pg_namespace nsp ON nsp.oid = pgc.connamespace
    JOIN pg_class  cls     ON pgc.conrelid = cls.oid
    JOIN information_schema.constraint_column_usage ccu ON pgc.conname = ccu.constraint_name AND nsp.nspname = ccu.constraint_schema
WHERE 1=1
--    AND pgc.contype = 'p'
   -- AND ccu.table_name = 'memberships'
ORDER BY
    pgc.conname ASC;


-------------------------
-- PRIMARY KEY constraints  ---
-------------------------

-- PRIMARY KEY constraints
SELECT
       'PRIMARY KEY Constraint=>' qry
       ,pgc.conname      constraint_name
       ,ccu.table_schema "schema"
       ,ccu.table_name   "table"
       ,ccu.column_name  "column"
       ,pgc.contype
       ,pg_get_constraintdef(pgc.oid) definition
       --pgc.*
FROM pg_constraint pgc
    JOIN pg_namespace nsp ON nsp.oid = pgc.connamespace
    JOIN pg_class  cls     ON pgc.conrelid = cls.oid
    JOIN information_schema.constraint_column_usage ccu ON pgc.conname = ccu.constraint_name AND nsp.nspname = ccu.constraint_schema
WHERE 1=1
    AND pgc.contype = 'p'
   -- AND ccu.table_name = 'memberships'
ORDER BY
    pgc.conname ASC;


-------------------------
-- FOREIGN KEY constraints  ---
-------------------------


-- FOREIGN KEY constraints
SELECT *
FROM pg_constraint pgc  WHERE pgc.contype = 'f';

-- FOREIGN KEY constraints + Referencing/referenced tables
SELECT
    tc.constraint_name ,
    tc.table_name    AS referencing_table_name,
    kcu.column_name  AS referencing_column_name,
    ccu.table_name   AS referenced_table_name,
    ccu.column_name  AS referenced_column_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE 1=1
  AND tc.constraint_type = 'FOREIGN KEY'
--  AND tc.table_name       IN ('answers', 'feedbacks')
    AND tc.table_name = 'authentication-methods'
;


-- FOREIGN KEY constraints + Referencing/referenced tables + columns
SELECT
    tc.constraint_name,
    tc.table_name    AS referencing_table_name,
    kcu.column_name  AS referencing_column_name,
    c.*,
    ccu.table_name   AS referenced_table_name,
    ccu.column_name  AS referenced_column_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN  information_schema.columns c
        ON  c.table_name = tc.table_name
        AND c.column_name = kcu.column_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE 1=1
  AND tc.constraint_type = 'FOREIGN KEY'
--  AND tc.table_name       IN ('answers', 'feedbacks')
    AND tc.table_name = 'authentication-methods'
;


-- Tables with FK
SELECT
     DISTINCT tc.table_name    AS referencing_table_name
     --ccu.table_name   AS referenced_table_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE 1=1
  AND tc.constraint_type = 'FOREIGN KEY'
 -- AND tc.table_name      = 'answers'
;


-------------------------
-- UNIQUE constraints  ---
-------------------------

-- UNIQUE constraints
SELECT
       'UNIQUE Constraint=>' qry
       ,pgc.conname      constraint_name
       ,ccu.table_schema "schema"
       ,ccu.table_name   "table"
       ,ccu.column_name  "column"
       ,pgc.contype
       ,pg_get_constraintdef(pgc.oid) definition
       --pgc.*
FROM pg_constraint pgc
    JOIN pg_namespace nsp ON nsp.oid = pgc.connamespace
    JOIN pg_class  cls     ON pgc.conrelid = cls.oid
    JOIN information_schema.constraint_column_usage ccu ON pgc.conname = ccu.constraint_name AND nsp.nspname = ccu.constraint_schema
WHERE 1=1
    AND pgc.contype = 'u'
   -- AND ccu.table_name = 'memberships'
ORDER BY
    pgc.conname ASC;


-------------------------
-- CHECK constraints  ---
-------------------------

SELECT
       'CHECK Constraint=>' qry
       ,pgc.conname      constraint_name
       ,ccu.table_schema "schema"
       ,ccu.table_name   "table"
       ,ccu.column_name  "column"
       ,pg_get_constraintdef(pgc.oid) definition
       --pgc.*
FROM pg_constraint pgc
    JOIN pg_namespace nsp ON nsp.oid = pgc.connamespace
    JOIN pg_class  cls     ON pgc.conrelid = cls.oid
    JOIN information_schema.constraint_column_usage ccu ON pgc.conname = ccu.constraint_name AND nsp.nspname = ccu.constraint_schema
WHERE 1=1
    AND pgc.contype = 'c'
   -- AND ccu.table_name = 'memberships'
ORDER BY
    pgc.conname ASC;


-------------------------
-- NOT NULL constraints  ---
-------------------------
SELECT
       ttr.attnotnull
       ,ttr.*
FROM pg_attribute ttr
;

-- NOT NULL columns
SELECT
    c.table_name,
    c.column_name,
    c.data_type,
    c.numeric_precision,
    c.character_maximum_length,
    c.is_nullable,
    'columns=>',
     c.*
  FROM information_schema.columns c
WHERE 1=1
    --AND c.table_catalog = 'pix'
--    AND c.table_schema  = 'public'
--    AND c.table_name = 'authentication-methods'
--    AND c.data_type     LIKE 'timestamp%'
--    AND c.data_type     = 'character varying'
    AND c.column_name LIKE '%Id'
    AND is_nullable = 'YES'
ORDER BY
    c.column_name ASC
;



-------------------------
-- Missing FK constraints  ---
-------------------------


-- Missing FK constraint
 SELECT c.table_name,
        c.column_name
 FROM information_schema.columns c
 WHERE 1 = 1
   AND c.table_catalog = 'pix'
   AND c.table_schema = 'public'
   -- AND c.table_name = 'answers'
   AND c.column_name LIKE '%Id'
   AND length(c.column_name) > 2
   AND c.data_type = 'integer'
 --
 EXCEPT
 --
 SELECT tc.table_name,
        kcu.column_name
 FROM information_schema.table_constraints AS tc
          JOIN information_schema.key_column_usage AS kcu
               ON tc.constraint_name = kcu.constraint_name
                   AND tc.table_schema = kcu.table_schema
          JOIN information_schema.constraint_column_usage AS ccu
               ON ccu.constraint_name = tc.constraint_name
                   AND ccu.table_schema = tc.table_schema
 WHERE 1 = 1
   AND tc.constraint_type = 'FOREIGN KEY'
 -- AND tc.constraint_name = 'answers_assessmentid_foreign'
--  AND tc.table_name       IN ('answers', 'feedbacks')
 --   AND ccu.table_name = 'users'
;


SELECT * FROM answers
;

select * from information_schema.table_constraints
WHERE constraint_name = 'answers_assessmentid_foreign';



SELECT
    tc.constraint_name ,
    tc.table_name    AS referencing_table_name,
    kcu.column_name  AS referencing_column_name,
    ccu.table_name   AS referenced_table_name,
    ccu.column_name  AS referenced_column_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE 1=1
  AND tc.constraint_type = 'FOREIGN KEY'
--  AND tc.table_name       IN ('answers', 'feedbacks')
    AND ccu.table_name = 'answers'
;


-------------------------
-- Missing NOT NULL on FK constraints  ---
-------------------------

-- FK may be mandatory, which can be enforced by adding NOT NULL constraint

-- Candidates
SELECT
    tc.constraint_name,
    tc.table_name    AS referencing_table_name,
    kcu.column_name  AS referencing_column_name,
    c.is_nullable,
    ccu.table_name   AS referenced_table_name,
    ccu.column_name  AS referenced_column_name,
    'SELECT id FROM  "' ||  tc.table_name || '" WHERE "' || kcu.column_name ||'" IS NULL LIMIT 1;' AS check
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN  information_schema.columns c
        ON  c.table_name = tc.table_name
        AND c.column_name = kcu.column_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE 1=1
  AND tc.constraint_type = 'FOREIGN KEY'
  AND c.is_nullable   = 'YES'
--  AND tc.table_name       IN ('answers', 'feedbacks')
--     AND tc.table_name   = 'authentication-methods'
--     AND ccu.table_name  = 'users'
ORDER BY
   tc.table_name,
   kcu.column_name
;



