# VALUES

[VALUES](https://www.postgresql.org/docs/current/queries-values.html) instantiates a pseudo-table.

## Basic

Usage : returns unnamed properties`column1`
```postgresql
SELECT *
FROM ( VALUES 
           (1, 'one'), 
           (2, 'two'), 
           (3, 'three') ) ordinal;
```

## Name properties

Use `AS` with property list.

```postgresql
SELECT 
    ordinal.value, ordinal.name
FROM (
    VALUES (1, 'one'), (2, 'two'), (3, 'three')
    ) AS ordinal (value ,name);
```

first_name;last_name;identifier
('doe','jane',1234567)
('shelley','mary',89101112)


## CSV to VALUES

```csv
first_name;last_name;identifier
doe;jane;1234567
shelley;mary;89101112
```

Add quotes for text `'$VALUE'`.
Map `;` to comma `,`
Add parentheses and comma (but for last)`( $VALUES ),`


```postgresql
SELECT 
    people.first_name, 
    people.last_name, 
    people.identifier
FROM (
    VALUES 
        ('doe', 'jane', 1234567),
        ('shelley', 'mary', 89101112)
    ) AS people (first_name, last_name, identifier) ;
```
