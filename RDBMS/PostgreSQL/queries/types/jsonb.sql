
-- Display
SELECT
       '{"what": "is this", "nested": {"items 1": "are the best", "items 2": [1, 2, 3]}}'::jsonb;


-- Pretty-print
SELECT
       jsonb_pretty('{"what": "is this", "nested": {"items 1": "are the best", "items 2": [1, 2, 3]}}'::jsonb);



-- https://www.postgresql.org/docs/current/datatype-json.html
-- The json and jsonb data types accept almost identical sets of values as input.
-- The major practical difference is one of efficiency.
-- jsonb also supports indexing, which can be a significant advantage.
--
-- The json data type stores an exact copy of the input text, which processing functions must reparse on each execution;
-- while jsonb data is stored in a decomposed binary format that makes it slightly slower to input due to added conversion overhead,
-- but significantly faster to process, since no reparsing is needed.


DROP TABLE IF EXISTS foo;
CREATE TABLE foo (bar JSONB);
INSERT INTO foo (bar) VALUES ('{ "foz": "old"}');
SELECT * FROM foo;
UPDATE foo SET bar = jsonb_set("bar", '{foz}', '"{new}"');

-- Insert
CREATE TABLE books (
  id   SERIAL NOT NULL,
  data JSONB
);

-- https://www.compose.com/articles/faster-operations-with-the-jsonb-data-type-in-postgresql/
INSERT INTO books VALUES (1, '{"title": "Sleeping Beauties", "genres": ["Fiction", "Thriller", "Horror"], "published": false}');
INSERT INTO books VALUES (2, '{"title": "Influence", "genres": ["Marketing & Sales", "Self-Help ", "Psychology"], "published": true}');
INSERT INTO books VALUES (3, '{"title": "The Dictator''s Handbook", "genres": ["Law", "Politics"], "authors": ["Bruce Bueno de Mesquita", "Alastair Smith"], "published": true}');
INSERT INTO books VALUES (4, '{"title": "Deep Work", "genres": ["Productivity", "Reference"], "published": true}');
INSERT INTO books VALUES (5, '{"title": "Siddhartha", "genres": ["Fiction", "Spirituality"], "published": true}');

-- Display
SELECT
    data->'title' AS title
FROM books;

-- Filter
SELECT
   data->'genres'
FROM books
WHERE 1=1
    AND data->'published' = 'false'
;

-- Create rows from JSONB single value
-- 0-based
SELECT
   jsonb_array_elements_text(data->'genres') AS genre
FROM books
WHERE id = 1
;

SELECT
   jsonb_array_elements(data->'genres') AS genre
FROM books
WHERE id = 1
;

-- Which row have data that contains an attribute ?
SELECT *
FROM books
WHERE 1=1
 AND data ? 'authors'
;

-- Inclusion
SELECT '["Fiction", "Thriller", "Horror"]'::jsonb
        @>
       '["Fiction", "Horror"]'::jsonb
;
-- true

SELECT '["Fiction", "Thriller"]'::jsonb
        @>
       '["Fiction", "Horror", "Thriller"]'::jsonb
;
-- false


-- Other operators: -> ->> #> #>> @? ?& ...
-- https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-JSON-OP-TABLE




-- indexing
CREATE INDEX
    idx_published
ON books ((data->'published'));

-- Indexes
SELECT
       'Indexes=>' qry
       ,ndx.indexname ndxl_nm
       ,ndx.tablename tbl_nm
       ,ndx.indexdef  dfn
       ,'pg_indexes=>' qry
       ,ndx.*
FROM pg_indexes ndx
WHERE 1=1
    AND ndx.indexname = 'idx_published'
;



-- Instantiate
WITH json AS (SELECT 'to' AS data)
SELECT json.data
FROM json
;

WITH json AS (SELECT '[ ' ||
                     '{ "name": "foo", "email": "foo@bar.com" }, ' ||
                     '{ "name": "foo", "email": "foo@bar.com" }' ||
                     ']' AS data)
SELECT CAST(json.data AS JSONB)
FROM json
;


-- Transform JSONB (update a part of the value, without altering the other part)
WITH json AS (SELECT '[ ' ||
                     '{ "name": "foo", "email": "foo@bar.com" }, ' ||
                     '{ "name": "foo", "email": "foo@bar.com" }' ||
                     ']' AS data)
SELECT
   jsonb_set(
        CAST(json.data AS JSONB),
       '{0,name}',
       '"bar"')
FROM json
;
-- [
-- {"name": "bar", "email": "foo@bar.com"},
-- {"name": "foo", "email": "foo@bar.com"}
-- ]


-- https://www.freecodecamp.org/news/how-to-update-objects-inside-jsonb-arrays-with-postgresql-5c4e03be256a/

create table customers (
    name varchar(256),
    contacts jsonb)
;

insert into customers (name, contacts) values (
  'Jimi',
  '[
    {"type": "phone", "value": "+1-202-555-0105"},
    {"type": "email", "value": "jimi@gmail.com"}
  ]'
);

insert into customers (name, contacts) values (
  'Janis',
  '[
	{"type": "email", "value": "janis@gmail.com"}
   ]'
);

SELECT * FROM customers;


-- Get index of "email" contact type
select index-1 as index
  from customers
      ,jsonb_array_elements(contacts) with ordinality arr(contact, index)
 where contact->>'type' = 'email'
   and name = 'Jimi';


-- Update
with contact_email as (
  select ('{'||index-1||',value}')::text[] as path
    from customers
        ,jsonb_array_elements(contacts) with ordinality arr(contact, index)
   where contact->>'type' = 'email'
     and name = 'Jimi'
)
update customers
   set contacts = jsonb_set(contacts, contact_email.path, '"jimi.hendrix@gmail.com"', false)
  from contact_email
 where name = 'Jimi';


-- https://stackoverflow.com/questions/45849494/how-do-i-search-for-a-specific-string-in-a-json-postgres-data-type-column
SELECT
    c.contacts
FROM
    customers c
WHERE 1=1
    AND c.name = 'Jimi'
    AND CAST (c.contacts AS TEXT) LIKE '%hendrix%'
    AND c.contacts::text          LIKE '%hendrix%'

;