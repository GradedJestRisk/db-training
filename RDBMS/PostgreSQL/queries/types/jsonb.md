# JSONB

[Doc](https://www.postgresql.org/docs/current/datatype-json.html)

> The json and jsonb data types accept almost identical sets of values as input. The major practical difference is one of efficiency. jsonb also supports indexing, which can be a significant advantage.

> The json data type stores an exact copy of the input text, which processing functions must reparse on each execution; while jsonb data is stored in a decomposed binary format that makes it slightly slower to input due to added conversion overhead, but significantly faster to process, since no reparsing is needed.


 https://www.postgresql.org/docs/16/functions-json.html

## Create

```postgresql
SELECT 
       TO_JSON('value'::TEXT) AS quote_value,
       JSONB_BUILD_OBJECT('KEY', 'value') AS build_object 
```


```postgresql
WITH json AS (SELECT 'to' AS data)
SELECT json.data
FROM json
;

```

From string
```postgresql
WITH json AS (SELECT '[ ' ||
                     '{ "name": "foo", "email": "foo@bar.com" }, ' ||
                     '{ "name": "foo", "email": "foo@bar.com" }' ||
                     ']' AS data)
SELECT CAST(json.data AS JSONB)
FROM json
;
```



## Check if JSON

### 16 and upward
```postgresql
SELECT version(); -- > 16
SELECT 'yes'
WHERE 1=1
    AND '{"b":"foo"}' IS JSON
    AND '[{"b":"foo"}]' IS JSON ARRAY
```


### 15 and downward
https://stackoverflow.com/questions/30187554/how-to-verify-a-string-is-valid-json-in-postgresql

```postgresql
CREATE OR REPLACE FUNCTION f_is_json(_txt text)
  RETURNS bool
  LANGUAGE plpgsql IMMUTABLE STRICT AS
$func$
BEGIN
   RETURN _txt::json IS NOT NULL;
EXCEPTION
   WHEN SQLSTATE '22P02' THEN  -- invalid_text_representation
      RETURN false;
END
$func$;

COMMENT ON FUNCTION f_is_json(text) IS 'Test if input text is valid JSON.
Returns true, false, or NULL on NULL input.'
```


```postgresql
SELECT 
    f_is_json('{"b":"foo"}'),
    f_is_json('[{"b":"foo"}]'),
    f_is_json('{"b":"foo"')
```

## Update

Update a part of the value, without altering the other part

```postgresql
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
```

Result
```json
[{"name": "bar", "email": "foo@bar.com"}, {"name": "foo", "email": "foo@bar.com"}]
```

[Doc](https://www.freecodecamp.org/news/how-to-update-objects-inside-jsonb-arrays-with-postgresql-5c4e03be256a/)

##  Display

### Raw

Single-line
```postgresql
SELECT
       '{"what": "is this", "nested": {"items 1": "are the best", "items 2": [1, 2, 3]}}'::JSONB;
```

Multi-line
```postgresql
SELECT
    '{'
        '  "version": "1",'
        '  "operation": "",'
        '  "cle": [],'
        '  "changements": ['
        '    {'
        '      "champ": "adresse.adresse",'
        '      "valeur_apres": "3 RUE DE LA GARE",'
        '     "valeur_avant": "1 RUE DA GARE"'
        '    }, {'
        '      "champ": "adresse.complementAdresse",'
        '      "valeur_apres": "3E ETAGE",'
        '     "valeur_avant": ""'
        '    }'
        '  ]'
        '}' :: JSONB
```


### Pretty-print

```postgresql
SELECT
       jsonb_pretty('{"what": "is this", "nested": {"items 1": "are the best", "items 2": [1, 2, 3]}}'::jsonb);
```


## Operators

### Inclusion

```postgresql
SELECT '["Fiction", "Thriller", "Horror"]'::jsonb
        @>
       '["Fiction", "Horror"]'::jsonb
;
```
true

```postgresql
SELECT '["Fiction", "Thriller"]'::jsonb
        @>
       '["Fiction", "Horror", "Thriller"]'::jsonb
;
```
false

### Other operators

List:
- `->` 
- `->>` 
- `#>` 
- `#>>` 
- `@?`
- `?&`

[Doc](https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-JSON-OP-TABLE)

### Arrays

SELECT
'{"a": {"b":"foo"}}'::json->'a',
'[{"a":"foo"},{"b":"bar"},{"c":"baz"}]'::json->2
;

## Search

To sort:
- https://stackoverflow.com/questions/77317468/variable-substitution-for-postgres-jsonpath-operator-like-regex
- https://stackoverflow.com/questions/77036083/parameter-inside-a-jsonpath-expression-in-postgres
- https://stackoverflow.com/questions/66600968/usage-of-in-native-sql-query-on-jsonb

### JSON path 

https://www.postgresql.org/docs/16/functions-json.html#FUNCTIONS-SQLJSON-PATH

#### With equality

Search an object property by constant
```postgresql
SELECT
    t.value    
FROM ( VALUES 
           ('{ "foo" : "bar" }'::JSONB), 
           ('{ "fooz" : "baz" }'::JSONB)
     ) AS t (value)
WHERE 1=1
    AND JSONB_PATH_EXISTS( t.value, '$.foo ? (@ == "bar" )')
```

### With variable

If you use parameters
```postgresql
SELECT *
FROM ( VALUES
           ('{ "foo" : "bar" }'::JSONB),
           ('{ "fooz" : "baz" }'::JSONB)
     ) AS t (value)
WHERE 1=1
AND JSONB_PATH_EXISTS(
              t.value, '$.foo ? (@ == $VALUE )',
--               JSONB_BUILD_OBJECT('VALUE', 'bar')
              JSONB_BUILD_OBJECT('VALUE', :value) -- On prompt, type 'bar' (with quotes)
    );
```

#### With regular expression - LIKE_REGEX
https://www.postgresql.org/docs/current/functions-json.html#JSONPATH-REGULAR-EXPRESSIONS

> Keep in mind that the pattern argument of like_regex is a JSON path string literal
> This means in particular that any backslashes you want to use in the regular expression must be doubled. 

```postgresql
$.* ? (@ like_regex "^\\d+$")
```

Search an object property by constant
```postgresql
SELECT
    t.value
    ,JSONB_PATH_EXISTS( t.value, '$ ? (@.foo LIKE_REGEX "^bar$")')
FROM ( VALUES 
           ('{ "foo" : "bar" }'::JSONB), 
           ('{ "fooz" : "baz" }'::JSONB)
     ) AS t (value)
```

Search an object property by regex
```postgresql
SELECT
    t.value
    ,JSONB_PATH_EXISTS( t.value, '$ ? (@.foo LIKE_REGEX "^\\[bar$")')
    ,JSONB_PATH_EXISTS( t.value, '$ ? (@.foo LIKE_REGEX "^\133bar$")')
    ,JSONB_PATH_EXISTS( t.value, '$ ? (@.foo LIKE_REGEX "' || '[' || 'bar$")' ::JSONPATH)
FROM ( VALUES 
           ('{ "foo" : "[bar" }'::JSONB), 
           ('{ "fooz" : "baz" }'::JSONB)
     ) AS t (value)
```


## Tutorials

### Library

```postgresql
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


select * from books
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
```

#### Create rows from JSONB single value
           
0-based
Without quotes
```postgresql
SELECT
   jsonb_array_elements_text(data->'genres') AS genre
FROM books
WHERE id = 1
;
```

With quotes
```postgresql
SELECT
   jsonb_array_elements(data->'genres') AS genre
FROM books
WHERE id = 1
;
```

#### Access first element on collection

```postgresql
SELECT
    data->'genres',
    data->'genres'->0
FROM books
WHERE id = 1
;
```


#### Which row have data that contains an attribute ?

```postgresql
SELECT *
FROM books
WHERE 1=1
 AND data ? 'authors'
;
```

#### indexing

Create
```postgresql
CREATE INDEX
    idx_published
ON books ((data->'published'));
```

List
```postgresql
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

```

### Customers

#### Create
```postgresql
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
```

Get index of "email" contact type
```postgresql
select index-1 as index
  from customers
      ,jsonb_array_elements(contacts) with ordinality arr(contact, index)
 where contact->>'type' = 'email'
   and name = 'Jimi';
```

#### Update

```postgresql
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

```


https://stackoverflow.com/questions/45849494/how-do-i-search-for-a-specific-string-in-a-json-postgres-data-type-column

#### Search

```postgresql
SELECT
    c.contacts
FROM
    customers c
WHERE 1=1
    AND c.name = 'Jimi'
    AND CAST (c.contacts AS TEXT) LIKE '%hendrix%'
    AND c.contacts::text          LIKE '%hendrix%'

;
```


### Another : students

https://hevodata.com/learn/query-jsonb-array-of-objects/


#### Create

```postgresql
DROP TABLE students;

CREATE TABLE students(
   id integer PRIMARY KEY,
   name varchar(50),
   subject_marks jsonb
);

INSERT INTO students(id, name, subject_marks ) 
VALUES (1, 'Dandelions',
'[{
 "sub_id": 1,
 "sub_name": "Computer Architecture",
 "sub_marks": 130
},
{
 "sub_id": 2,
 "sub_name": "Operating Systems",
 "sub_marks": 120

}]');
```

```postgresql
SELECT *
FROM students
```

#### WITH ORDINALITY

Process collection (marks) as rows using `WITH ORDINALITY` to create a view 
```postgresql
SELECT
  s.id,
  marks.item_object
FROM students s,
  JSONB_ARRAY_ELEMENTS(subject_marks) WITH ORDINALITY marks (item_object, position)
WHERE 1=1
  AND s.id = 1
  AND marks.position = 1
  ;

```