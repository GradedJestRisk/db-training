# Cursor

## get cursors

```oracle
SELECT sql_id, sql_text, executions
FROM v$sqlarea
WHERE sql_text LIKE '%1234';
```

## shared cursor

```oracle
SELECT *, reason
FROM $sql_shared_cursor
WHERE sql_id = '5tjqf7sx5dzmj'
AND child_number = 1;
```

## adaptative cursor sharing

```oracle
SELECT child_number, is_bind_sensitive, is_bind_aware, is_shareable, plan_hash_value
FROM v$sql
WHERE sql_id = 'asth1mx10aygn';
```

Check why it has been used
```oracle
SELECT child_number, peeked, executions, rows_processed, buffer_gets
FROM v$sql_cs_statistics
WHERE sql_id = 'asth1mx10aygn'
ORDER BY child_number;
```

Check if because of selectivity
```oracle
SELECT child_number, trim(predicate) AS predicate, low, high
FROM v$sql_cs_selectivity
WHERE sql_id = 'asth1mx10aygn'
ORDER BY child_number;
```

```text
CHILD_NUMBER PREDICATE LOW        HIGH
------------ --------- ---------- ----------
           1 <ID       0.890991   1.088989
           2 <ID       0.008108   0.009910
```

Bucket to compare expected and actual
```oracle
SELECT child_number, bucket_id, count
FROM v$sql_cs_histogram
WHERE sql_id = 'asth1mx10aygn'
ORDER BY child_number, bucket_id;
```

