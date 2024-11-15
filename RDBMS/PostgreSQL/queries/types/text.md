# Text

## Generate

Delimited by simple quotes (`'`).
Double quotes (\"\) are for column names.
```postgresql
SELECT 'Hello, world!'
```

Even so, double quote can be used
```postgresql
SELECT '"Hello, world!", says Emma'
```

### Long text

[Several ways](https://stackoverflow.com/questions/35068285/how-to-create-a-huge-string-in-postgresql)

Repeating fixed pattern
```postgresql
SELECT REPEAT('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 3);
```

#### Lorem ipsum

##### Custom

```postgresql
create or replace function lorem_ipsum( quantity_ integer ) returns character varying
    language plpgsql
    as $$
  declare
    words_       text[];
    returnValue_ text := '';
    random_      integer;
    ind_         integer;
  begin
  words_ := array['lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing', 'elit', 'a', 'ac', 'accumsan', 'ad', 'aenean', 'aliquam', 'aliquet', 'ante', 'aptent', 'arcu', 'at', 'auctor', 'augue', 'bibendum', 'blandit', 'class', 'commodo', 'condimentum', 'congue', 'consequat', 'conubia', 'convallis', 'cras', 'cubilia', 'cum', 'curabitur', 'curae', 'cursus', 'dapibus', 'diam', 'dictum', 'dictumst', 'dignissim', 'dis', 'donec', 'dui', 'duis', 'egestas', 'eget', 'eleifend', 'elementum', 'enim', 'erat', 'eros', 'est', 'et', 'etiam', 'eu', 'euismod', 'facilisi', 'facilisis', 'fames', 'faucibus', 'felis', 'fermentum', 'feugiat', 'fringilla', 'fusce', 'gravida', 'habitant', 'habitasse', 'hac', 'hendrerit', 'himenaeos', 'iaculis', 'id', 'imperdiet', 'in', 'inceptos', 'integer', 'interdum', 'justo', 'lacinia', 'lacus', 'laoreet', 'lectus', 'leo', 'libero', 'ligula', 'litora', 'lobortis', 'luctus', 'maecenas', 'magna', 'magnis', 'malesuada', 'massa', 'mattis', 'mauris', 'metus', 'mi', 'molestie', 'mollis', 'montes', 'morbi', 'mus', 'nam', 'nascetur', 'natoque', 'nec', 'neque', 'netus', 'nibh', 'nisi', 'nisl', 'non', 'nostra', 'nulla', 'nullam', 'nunc', 'odio', 'orci', 'ornare', 'parturient', 'pellentesque', 'penatibus', 'per', 'pharetra', 'phasellus', 'placerat', 'platea', 'porta', 'porttitor', 'posuere', 'potenti', 'praesent', 'pretium', 'primis', 'proin', 'pulvinar', 'purus', 'quam', 'quis', 'quisque', 'rhoncus', 'ridiculus', 'risus', 'rutrum', 'sagittis', 'sapien', 'scelerisque', 'sed', 'sem', 'semper', 'senectus', 'sociis', 'sociosqu', 'sodales', 'sollicitudin', 'suscipit', 'suspendisse', 'taciti', 'tellus', 'tempor', 'tempus', 'tincidunt', 'torquent', 'tortor', 'tristique', 'turpis', 'ullamcorper', 'ultrices', 'ultricies', 'urna', 'ut', 'varius', 'vehicula', 'vel', 'velit', 'venenatis', 'vestibulum', 'vitae', 'vivamus', 'viverra', 'volutpat', 'vulputate'];
    for ind_ in 1 .. quantity_ loop
      ind_ := ( random() * ( array_upper( words_, 1 ) - 1 ) )::integer + 1;
      returnValue_ := returnValue_ || ' ' || words_[ind_];
    end loop;
    return returnValue_;
  end;
$$;
```

Then use : specify how much words you want (no fixed length)
```postgresql
select lorem_ipsum( 3 );
```

##### Using extension
```postgresql
SELECT anon.lorem_ipsum()
```

### Multi-line

> Two string constants that are only separated by whitespace with at least one newline are concatenated and effectively treated as if the string had been written as one constant 

[Doc] https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-STRINGS

```postgresql
SELECT 
    'Hello, ' 
    'world !'
```


## Escape

You should escape
- simple quote `'`
- newline `\n`

Backslash does not need to be escaped
```postgresql
SELECT 'I need a backslash: \'
```

### Using simple quote

If you need a simple quote, escape it using another simple quote.

```postgresql
SELECT 'Lovely day, isn''t it ?'
```

### Using CHR

This is cumbersome but works.
```postgresql
SELECT 'Lovely day, isn' || CHR(39)|| 't it ?'
```

### Using dollar-quoting `$$`

[Heredoc](https://en.wikipedia.org/wiki/Here_document) whose tag delimiter is `$$`
https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-DOLLAR-QUOTING

Tag is bot mandatory
```postgresql
SELECT $$Lovely day, isn't it ?$$
```

But in doubt, use it
```postgresql
SELECT $STRING$Lovely day, isn't it ?$STRING$
```

### Using `E`

Escape newline
```postgresql
SELECT E'a \n b'
```

## Generate text sample

```postgresql
SELECT t.data
FROM (
     SELECT '123AB' AS data UNION
     SELECT '123A'  AS data
         ) t
;

```

## Concatenate

```postgresql
SELECT
 'a' || 'b',
 CONCAT('a','b'),
 CONCAT('a','b') ESCAPE '/'
```


## Pattern matching 

### Like

```postgresql
SELECT
    t.data
FROM (
     SELECT '123AB' AS data UNION
     SELECT '123A'  AS data
         ) t
WHERE 1=1
--     AND t.data LIKE '123A%'
--     AND t.data LIKE '123A'
    AND t.data LIKE '123'
;
```


### Regular expression: ~ (POSIX)

https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-POSIX-REGEXP

#### Language

https://www.postgresql.org/docs/current/functions-matching.html#POSIX-SYNTAX-DETAILS

##### Quantifiers

* 	[ 0 ; 
+ 	] 0 ;
? 	[ 0 ; 1] 
m   [ m ; m]


##### NOT
Does not contain a word

`(?!word)`
https://stackoverflow.com/questions/406230/regular-expression-to-match-a-line-that-doesnt-contain-a-word


```postgresql
SELECT
 '[ { "a": "1", "b": "2" }, { "a": "3", "b": "4" } ]' ~ 
  CONCAT('^.*',
         '"a":."', 
         '1', 
         '"',
--          '.*',
         '[^}]*',
         '"b": "',
         '2',
         '"',
         '.*$')

```

#### Sandbox


```postgresql
SELECT
 'abc' ~ 'abc',
 'abc' ~ '[a-z]{3}',
 'abc' ~ '[a-z]{4}',
 '123abc' ~ '^[0-9]{3}[a-z]{3}',
 '123abc' ~ '^[0-9]{4}[a-z]{3}'
;


SELECT
       t.data
FROM (
     SELECT '123A'  AS data UNION
     SELECT '12AB'  AS data UNION
     SELECT 'ABC' AS data
         ) t
WHERE 1=1
    AND NOT (    t.data ~ '^[0-9]{3}[a-zA-Z]{1}'
           OR  t.data ~ '^[0-9]{2}[a-zA-Z]{2}')
;

CREATE TABLE test ( text TEXT);
INSERT INTO test (text) VALUES (E'\u0000');

INSERT INTO test (text) VALUES (\0x00);
```

#### Extent

Match from beginning to end: use `^` and `$`

```postgresql
SELECT
    t.data
FROM (
         SELECT 'apple and pears'  AS data UNION
         SELECT 'apple'  AS data UNION
         SELECT 'pears' AS data
     ) t
WHERE 1=1
  AND t.data ~ '^apple$'
;
```

Match into: skip `^` and `$`

```postgresql
SELECT
    t.data
FROM (
         SELECT 'apple and pears'  AS data UNION
         SELECT 'apple'  AS data UNION
         SELECT 'pears' AS data
     ) t
WHERE 1=1
  AND t.data ~ '.*apple.*'
;
```

#### Escape

Use backslash (`\`) to escape :
- dot (`.`)
- star (`*`)
- bracket (`[`)

```postgresql
SELECT
    t.data
FROM (
         SELECT 'adresse.a=1(*)'  AS data UNION
         SELECT 'adresse.b=2()'  AS data UNION
         SELECT 'adresse=2(*)' AS data
     ) t
WHERE 1=1
  AND t.data ~ '^adresse\..*(\*)'
;
```

##### ASCI code

https://www.postgresql.org/docs/current/functions-matching.html#POSIX-CLASS-SHORTHAND-ESCAPES-TABLE

Escaping `[` using ASCII code : 
- 133 is octal, use `\133`
- 5B is hexadecimal , use `\u005B`
- 5B is hexadecimal , use `\u005B`

```postgresql
SELECT
    t.value, 
    t.value ~ '^\[foo$',
    t.value ~ '^\133foo$',
    t.value ~ '^\u005Bfoo$'
FROM ( VALUES 
           ('[foo'), 
           ('foo')
     ) AS t (value)
```

To get the octal value, get the decimal first
```postgresql
SELECT ASCII('[')
```
Here we get 91

Then [translate to octal](https://www.rapidtables.com/convert/number/decimal-to-octal.html?x=91) to get `133`.

Sandbox
```postgresql
SELECT
    '[ { "a": "1"} ]' ~ CONCAT('^.*', '\[ {' , '.*$')
```

## Length

```postgresql
SELECT CHAR_LENGTH('foo');
```

## Extract

```postgresql
SELECT
    substring('foo-bar' from 5 for 3),
    substring('foo-bar' from 1 for 3) || repeat('*', CHAR_LENGTH('foo-bar') - 3 - 1),
    'mister foo bar',
    SUBSTRING('mister foo bar' from 1 for 3) || REPEAT('*', CHAR_LENGTH('mister foo bar') - 3 - 1)
    ;
```

## Repeat

Repeat a pattern N times
```postgresql
SELECT REPEAT('TAKA-', 3)
```


## Mapping

Replace a character by another
```postgresql
WITH data AS (
     SELECT ' ' AS string UNION
     SELECT 'a ' AS string
         )
SELECT
    data.string,
    REPLACE(data.string, ' ', '¤')
FROM data    
```

Replace a string by another
```postgresql
WITH data AS (
     SELECT 'I like apples'     AS string UNION
     SELECT 'I like pears too ' AS string
         )
SELECT
    data.string,
    REPLACE(data.string, 'apples', 'mangoes')
FROM data    
```

