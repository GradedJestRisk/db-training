# Aggregate

## Single group

```sql
SELECT
    id_contrat,
    COUNT(*) AS nombre_de_sinistres
FROM
    sinistres
GROUP BY
    id_contrat
HAVING
    COUNT(*) > 2;
```

```sql
SELECT
    id_contrat,
    COUNT(*) AS nombre_de_sinistres
FROM
    sinistres
WHERE date_sinistre > '2023-01-01'
GROUP BY
    id_contrat
;
```

## Mind the NULLs

```sql
SELECT id_sinistre, id_gestionnaire
FROM sinistres;
```

| id\_sinistre | id\_gestionnaire |
|:-------------|:-----------------|
| 0            | null             |
| 1            | 1                |



Will count all rows
```sql
SELECT id_sinistre, COUNT(*)
FROM sinistres
GROUP BY id_sinistre;
```

| id\_sinistre | count |
|:-------------|:------|
| 0            | 1     |
| 1            | 1     |


Will count all rows whose `id_gestionnaire` IS NOT NULL
```sql
SELECT id_sinistre, COUNT(id_gestionnaire)
FROM sinistres
GROUP BY id_sinistre;
```

## Group by NULL

`NULL` is grouped if used an aggregate key

```sql
SELECT id_gestionnaire, COUNT(*)
FROM sinistres
GROUP BY id_gestionnaire;
```
| id_gestionnaire | count |
|:----------------|:------|
| null            | 1     |
| 1               | 1     |
