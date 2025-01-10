# Statement


Stats
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
     ,'v$sql=>'
     ,sql_stt.*
FROM v$sqlstats sql_stt
WHERE 1=1
--   AND sql_stt.sql_id IN ('fzmcf1yg2fwf4','cnzyjqgnv17vb')
  AND sql_stt.sql_id = 'ggrbm9uz2pf6g'
--   AND sql_stt.sql_text LIKE '%simple%'
ORDER BY sql_stt.elapsed_time DESC
```

## Statements (history)

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
