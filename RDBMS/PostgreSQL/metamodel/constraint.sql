
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


-- FOREIGN KEY constraints
SELECT COUNT(1) FROM pg_constraint pgc  WHERE pgc.contype = 'f';



-- FOREIGN KEY constraints + Referencing/referenced tables
SELECT
    tc.constraint_name ,
    tc.table_name    AS referencing_table_name,
    kcu.column_name  AS referencing_table_name,
    ccu.table_name   AS referenced_table_name,
    ccu.column_name  AS referenced__column_name
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
  AND tc.table_name       IN ('answers', 'feedbacks')
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








-- CHECK constraints
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
    AND ccu.table_name = 'memberships'
ORDER BY
    pgc.conname ASC;

