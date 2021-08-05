DROP TABLE IF EXISTS foo;

-- Named constraint
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER CONSTRAINT value_unique UNIQUE
 );

-- Default-named constraint
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER UNIQUE
 );

-- Out of column
CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER,
   UNIQUE(value)
 );

-- FOREIGN KEY

DROP TABLE IF EXISTS bar;

CREATE TABLE bar (
   value_foo INTEGER REFERENCES foo(id)
 );

CREATE TABLE bar
(
    value_foo INTEGER REFERENCES foo (id)
        CONSTRAINT bar_value_foo_fkey
        FOREIGN KEY (value_foo)
        REFERENCES foo (id)
);

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
    AND ccu.table_name = 'foo'
;

