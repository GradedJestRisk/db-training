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
-- Given name
SELECT
    'constraint=>'
    ,pgc.convalidated
    ,pgc.condeferrable
    ,pgc.condeferred
    ,pgc.contype
    --,'pg_constraint=>'
    --,pgc.*
FROM pg_constraint pgc
WHERE 1=1
  AND pgc.conname = 'users_email_unique'
--  AND pgc.conname ILIKE '%recovery%'
  AND pgc.contype = 'u'
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
    AND pgc.contype = 'c'
    --AND ccu.table_name IN('knowledge-elements')
--     AND pg_get_constraintdef(pgc.oid)  NOT ILIKE '%array%'
ORDER BY
    pgc.conname ASC;




-- Constraints with ENUM-emulation
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
    AND pgc.contype = 'c'
    --AND ccu.table_name IN('knowledge-elements')
    AND pg_get_constraintdef(pgc.oid)  NOT ILIKE '%array%'
ORDER BY
    pgc.conname ASC;



select * from pg_constraint
;

select * from pg_catalog.pg_constraint
;

select * from pg_catalog.pg_class
WHERE relname = 'knowledge-elements'
;

SELECT true as sametable, conname,
  pg_catalog.pg_get_constraintdef(r.oid, true) as condef,
  conrelid::pg_catalog.regclass AS ontable
FROM pg_catalog.pg_constraint r
WHERE 1=1
 --r.conrelid = '24975' AND
 -- r.contype = 'f'
     AND conparentid = 0
     AND conrelid = 24975
ORDER BY conname
;




-- Constraints
SELECT
--       COUNT(1)
    pgc.conname
FROM pg_constraint pgc
    JOIN pg_namespace nsp ON nsp.oid = pgc.connamespace
    JOIN pg_class  cls     ON pgc.conrelid = cls.oid
    JOIN information_schema.constraint_column_usage ccu ON pgc.conname = ccu.constraint_name AND nsp.nspname = ccu.constraint_schema
WHERE 1=1
   AND ccu.table_schema = 'public'
ORDER BY
    pgc.conname ASC
;


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
    AND ccu.table_schema = 'public'
   -- AND ccu.table_name = 'memberships'
ORDER BY
    pgc.conname ASC;


-------------------------
-- FOREIGN KEY constraints  ---
-------------------------


-- FOREIGN KEY constraints
SELECT *
FROM pg_constraint pgc  WHERE pgc.contype = 'f';

-- FOREIGN KEY constraints
SELECT
    tc.*
FROM
    information_schema.table_constraints tc
WHERE 1=1
  AND tc.constraint_type = 'FOREIGN KEY'
  --AND tc.constraint_name = 'knowledge_elements_answerid_foreign'
  AND tc.table_name       IN ('answers', 'feedbacks')
--    AND tc.table_name = 'authentication-methods'
    -- references
--     AND ccu.table_name   = 'answers'
--     AND ccu.column_name  = 'id'
;

-- Valid or not valid ?
SELECT
    cls.relname table_name,
    con.conname fk_name,
    con.convalidated is_valid
FROM
    pg_constraint AS con
        JOIN pg_class AS cls ON con.conrelid = cls.oid
WHERE 1=1
  AND cls.relname = 'knowledge-elements'
  AND conname = 'knowledge_elements_answerid_foreign'
  --AND convalidated IS FALSE
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
  -- referencing_table_name
--  AND tc.table_name       IN ('answers', 'feedbacks')
--    AND tc.table_name = 'authentication-methods'
    -- referenced_table_name
    AND ccu.table_name = 'answers_bigint'
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
    AND c.table_name = 'knowledge-elements'
--    AND c.data_type     LIKE 'timestamp%'
--    AND c.data_type     = 'character varying'
--    AND c.column_name LIKE '%Id'
    AND is_nullable = 'NO'
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



