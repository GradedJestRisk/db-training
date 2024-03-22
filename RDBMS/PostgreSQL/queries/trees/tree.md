# Trees

## Dataset

```postgresql
DROP TABLE IF EXISTS tree ;
CREATE TABLE tree(  
    id INT,
    name TEXT,
    parentId INT
);
```

```postgresql
INSERT INTO tree (id, name, parentId)
VALUES (0, 'parent 1 with 2 childrens', NULL);
INSERT INTO tree (id, name, parentId)
VALUES (1, 'child 1 of parent 1', 0);
INSERT INTO tree (id, name, parentId)
VALUES (2, 'child 2 of parent 1', 0);
INSERT INTO tree (id, name, parentId)
VALUES (3, 'parent 1 with no children', NULL);
```

```postgresql
SELECT id, name, parentId
FROM tree
```

## Naive

Children with parent

```postgresql
WITH "primary" AS (SELECT 
    id, name
FROM tree
WHERE 1=1 
    AND tree.parentid IS NULL )
SELECT "primary".id AS parentId, "primary".name AS parentName,
       secondary.id AS childId, secondary.name AS childName
FROM tree AS secondary
    INNER JOIN "primary" ON secondary.parentid = "primary".id
```

## With CTE

https://dba.stackexchange.com/questions/63153/how-do-i-sort-the-results-of-a-recursive-query-in-an-expanded-tree-like-fashion

```postgresql
WITH RECURSIVE cte AS (
    SELECT 1 AS level, *
           ,ARRAY[id] AS path
    FROM tree AS parents
    WHERE parents.parentid is NULL
    UNION ALL
    SELECT c.level + 1, childrens.*
          ,c.path || childrens.id AS path
    FROM cte c
           INNER JOIN tree AS childrens ON childrens.parentid = c.id
)
SELECT * FROM cte
ORDER BY path 
```

PG >= 14 (generate path)

```postgresql
WITH RECURSIVE cte AS (
    SELECT 1 AS level, *
    FROM tree AS parents
    WHERE parents.parentid is NULL
    UNION ALL
    SELECT c.level + 1, childrens.*
    FROM cte c
           INNER JOIN tree AS childrens ON childrens.parentid = c.id
) SEARCH DEPTH FIRST BY id SET path
SELECT * FROM cte
ORDER BY path
```



## With CONNECTBY

```postgresql
CREATE EXTENSION tablefunc;
SELECT *
FROM pg_extension WHERE extname = 'tablefunc';
```

Parameters:
- relname:  Defines the name of the source relation (table)
- keyid_fld: Name of the key field
- parent_keyid_fld:  Name of the parent-key field
- orderby_fld: Name of the field to order siblings by (optional)
- start_with: Value of the row where the query should start
- max_depth: Max depth, or zero for unlimited depth
- branch_delim: String to separate keys with in branch output (optional)

```postgresql
SELECT * FROM 
         CONNECTBY('tree', 'id', 'parentid', '0', 0, '->') 
             AS t(id INT, parentId INT, level INT, ord TEXT)
```