
# Execution plan

https://blogs.oracle.com/optimizer/post/how-to-generate-a-useful-sql-execution-plan


## Human

```oracle
EXPLAIN PLAN FOR
SELECT /*+ gather_plan_statistics */
    MAX(id)
FROM simple_table;
```

```oracle
SELECT *
FROM table(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'ALL +OUTLINE'));
```


## Raw

```oracle


SELECT *
FROM plan_table pln
ORDER BY pln.timestamp DESC
;
```

## report monitor

Execute a query
```oracle
SELECT /*+ gather_plan_statistics */
    MAX(id)
FROM simple_table;
```

Get sqlId
```oracle
select prev_sql_id
from   v$session
where  sid=userenv('sid')
and    username is not null
and    prev_hash_value <> 0;
```
4md9qy2kqhckn

Run report
```oracle
set linesize 250 pagesize 0 trims on tab off long 1000000
column report format a220

select
   DBMS_SQL_MONITOR.REPORT_SQL_MONITOR
        (sql_id=>'4md9qy2kqhckn',report_level=>'ALL') report
from dual;
```