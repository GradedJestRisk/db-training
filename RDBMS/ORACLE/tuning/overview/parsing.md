# Parsing

Create table
```oracle
SELECT * FROM simple_table;
```

Get count
```oracle
SELECT COUNT(1) FROM simple_table;
```

Analyze
```oracle
CALL dbms_stats.gather_table_stats ( null, 'simple_table' );
```

Get count
```oracle
SELECT 
   'Table'         rqt_cnt 
   ,tbl.table_name tbl_nm
   ,tbl.num_rows   tbl_nrg_nmb
   ,tbl.last_analyzed
--    ,'all_t&ables=>'
--    ,tbl.*
FROM 
   all_tables tbl
WHERE 1=1
   AND UPPER(tbl.table_name)   =   UPPER('simple_table')
ORDER bY
   tbl.num_rows DESC
;
```

Get size
```oracle
SELECT segment_name, SUM(bytes)/1024/1024 size_mb
FROM user_segments 
WHERE 1=1
    --AND segment_name = UPPER('simple_table')
GROUP BY segment_name
;
```

Cache
```oracle
SELECT
   name, bytes/1024/1024 size_mb
FROM v$sgainfo
WHERE 1=1
    AND name = 'Buffer Cache Size'
```

```oracle
SELECT TRUNC(dbms_random.value(1,100000)) FROM DUAL;
SELECT MAX(id) FROM simple_table WHERE id > 1;
SELECT MAX(id) FROM simple_table WHERE id > TRUNC(dbms_random.value(1,100000));
```

```oracle
SELECT MAX(id) FROM simple_table WHERE id > 1;
SELECT prev_sql_id FROM v$session WHERE sid=sys_context('userenv','sid');
-- 4md9qy2kqhckn
SELECT MAX(id) FROM simple_table WHERE id > 1;
SELECT prev_sql_id FROM v$session WHERE sid=sys_context('userenv','sid');
-- 4md9qy2kqhckn
SELECT MAX(id) FROM simple_table WHERE id > 2;
SELECT prev_sql_id FROM v$session WHERE sid=sys_context('userenv','sid');
--4md9qy2kqhckn
SELECT MAX(id) FROM simple_table WHERE id > CAST( '2' AS INTEGER);
SELECT prev_sql_id FROM v$session WHERE sid=sys_context('userenv','sid');
--4md9qy2kqhckn
VAR i INTEGER;
SELECT 
```

PL/SQL
```oraclesqlplus
DECLARE
    throwaway INTEGER;
    sqlId VARCHAR2(100);
BEGIN
    FOR i IN 1..2
    LOOP
        SELECT MAX(id)
        INTO throwaway
        FROM simple_table
        WHERE id > i;
        
        SELECT prev_sql_id INTO sqlId FROM v$session WHERE sid=sys_context('userenv','sid');
        dbms_output.put_line(sqlId);
    END LOOP;
END;
/
```
d3d7q56sqr8wf
d3d7q56sqr8wf