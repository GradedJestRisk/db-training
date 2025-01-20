# Statement

Identified by `sql_id`, same as cursor ?


## Running `v$session`

```oracle
SELECT status, sql_id, sql_child_number
FROM v$session 
WHERE status = 'active';
```

For username
```oracle
select ssn.sid,
       ssn.sql_id,
       qry.sql_text
       --,ssn.*
FROM v$sqltext qry
    INNER JOIN v$session ssn 
        ON  ssn.sql_hash_value = qry.hash_value AND ssn.sql_address = qry.address
WHERE 1=1
  AND ssn.username = 'USERNAME'
--  AND ssn.status = 'active'
--   AND ssn.id = 
ORDER BY ssn.sid, qry.piece;
```

## Ran, but not archived

### Current `v$sql`

```oracle
SELECT 
    sql_id, child_number, sql_text
     --, sql.*
FROM v$sql sql
WHERE 1=1
    AND sql_fulltext LIKE '%simple%'
    AND sql_text NOT LIKE '%v$sql%';
```

You get

| SQL_ID        | CHILD_NUMBER | SQL_TEXT                           |
|:--------------|:-------------|:-----------------------------------|
| 9xz7yas8z9pd9 | 0            | SELECT MAX(id) FROM simple_table   |




### Source code `v$sqltext`

```oracle
SELECT 
    qry.sql_id,
    qry.piece,
    qry.sql_text
FROM v$sqltext qry
WHERE 1=1
    AND sql_id = 'afcz0dh295hzp'
ORDER BY qry.piece    
```

Long statements (eg. PL/SQL)
```oracle
SELECT
    sql_id, count(1)
FROM v$sqltext qry
GROUP BY sql_id
ORDER BY count(1) DESC
```


### Stats

#### `v$sqlarea`

Parent
```oracle
SELECT 
     'SQL parent:'  
    ,prn.sql_id
    ,prn.sql_text
    ,prn.executions
    ,prn.parse_calls
    ,prn.rows_processed
    ,prn.is_bind_aware
    ,'v$sqlarea=>'
    ,prn.*
FROM v$sqlarea prn
WHERE 1=1
    AND prn.module LIKE 'sqlplus%'
--     AND prn.sql_text LIKE '%SELECT%'
ORDER BY prn.elapsed_time DESC
```

#### `v$sqlstats`

```oracle
SELECT
    'SQL stats:'
     ,sql_stt.sql_id
     ,sql_stt.sql_text
     ,sql_stt.last_active_time
     ,sql_stt.executions
     ,sql_stt.parse_calls
     ,sql_stt.rows_processed
     ,sql_stt.cpu_time
     ,sql_stt.elapsed_time
     ,sql_stt.plsql_exec_time
     ,'v$sqlstats=>'
     ,sql_stt.*
FROM v$sqlstats sql_stt
WHERE 1=1
--   AND sql_stt.sql_id IN ('fzmcf1yg2fwf4','cnzyjqgnv17vb')
  AND sql_stt.sql_id = '4md9qy2kqhckn'
--   AND sql_stt.sql_text LIKE '%simple%'
ORDER BY sql_stt.elapsed_time DESC
```

## Archived `v$active_session_history`

For sqlId, all session
```oracle
SELECT
    sample_time
    ,session_id
--     ,session_serial#
    ,session_state
    ,sql_id
    ,in_sql_execution SQL
    ,in_plsql_execution PLSQL
    ,sql_plan_operation || ' ' || sql_plan_options
    ,'v$active_session_history=>'
    --,ssn_hst.*
FROM v$active_session_history ssn_hst
WHERE 1=1
    --AND session_id = 31
--     AND ssn_hst.sql_id = '2hbs39z6qg675'
    --AND  ssn_hst.client_info LIKE 'parsing-%'
    --AND  ssn_hst.client_info IS NOT NULL
ORDER BY ssn_hst.sample_time DESC;
```


More than one session ?
```oracle
SELECT DISTINCT(session_id)
FROM v$active_session_history ssn_hst
WHERE 1=1
    AND ssn_hst.sql_id = '2hbs39z6qg675'
```
