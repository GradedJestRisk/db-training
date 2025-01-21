# SQL optimization

> When the query optimizer is unable to automatically generate an efficient execution plan, some manual optimization is required: 7 techniques are available:
> - altering access structures
> - altering SQL statement
> - hints
> - altering the execution environment
> - stored outline
> - SQL profile
> - SQL plans

> To choose one of them, it’s essential to ask yourself three basic questions:
> - Is the SQL statement known and static?
> - Should the measures to be taken have an impact on a single SQL statement or on all SQL statements executed by a single session (or even on the whole system)?
> - Is it possible to change the SQL statement?

> First, sometimes the SQL statements are simply unknown because they’re generated at runtime and change virtually for each execution. In other situations, the query optimizer can’t correctly deal with specific constructs that are used by lots of SQL statements. 
> In both cases, you have to use techniques that solve the problem at the session or system level, not at the SQL statement level. 

> This fact leads to two main problems:
> - several techniques can be used only for specific SQL statements ( not applicable at the session or system level)
> - if your database schema is good and query optimizer properly setup, you usually have to optimize a small number of SQL statements. 

> Therefore, you want to avoid techniques impacting the SQL statements for which the query optimizer automatically provides an efficient execution plan (regression).
> Second, whenever you deal with an application for which you have no control over the SQL statements, you can’t use techniques that require changes to the code. 

If you can change the SQL statements themselves, and only a few of them are under-performing, you're in cool situation.


## altering access structures

> The first thing you have to do while questioning the performance of a SQL statement is verify which access structures are in place.

> Based on the information you find in the data dictionary, you should answer the following questions:
> - What is the organization type of the tables involved? 
>   - Is it heap, index-organized, or external? 
>   - Or is the table stored in a cluster?
> -  Are materialized views containing the needed data available?
> -  What indexes exist on the tables, clusters, and materialized views? 
> -  Which columns do the indexes contain and in what order?
> -  How are all these segments partitioned?

> Next you have to assess whether the available access structures are adequate to efficiently process the SQL statement you’re optimizing. For example, during this analysis, you may discover that an additional index is necessary to efficiently support the WHERE clause of the SQL statement.


## altering SQL statement

> Basically, although the method used to access the data is always the same, the method used to combine the data to produce the result set is different. In this specific case, the two tables are very small, and consequently, you wouldn’t notice any real performance difference with these execution plans. Naturally, if you’re dealing with much bigger tables, that may not necessarily be the case. Generally speaking, whenever you process a large amount of data, every small difference in the execution plan could lead to substantial differences in the response time or resource utilization.

> The key point here is to realize that the very same data can be extracted by means of different SQL statements.

> Whenever you’re optimizing a SQL statement, you should ask yourself whether other equivalent SQL statements exist. If they do, compare their execution plans carefully to assess which one provides the best performance.

## hints in code : comments

> The important thing to understand is that you can’t tell the query optimizer, “I want a full table scan on the emp table, so search for an execution plan containing it.” However, you can tell it, “If you have to decide between a full table scan and an index scan on the emp table, take a full table scan.” This is a slight but fundamental difference.

Take care:
- if there is a table aliases, use it as reference in hint
- some hint should be repeated in subqueries
- do not mix hints with comments
- hints error are silent

## altering the execution environment

### session level ( v$sys_optimizer_env and v$ses_optimizer_env)

You can do this using a trigger.
```oracle
ALTER SESSION SET optimizer_adaptive_plans = false
```

Get execution environment at the instance (database) level
```oracle
SELECT
    'execution env: ' 
    ,xct.name 
    ,xct.value 
    ,xct.default_value
    ,xct.isdefault
--     ,'v$sys_optimizer_env=>'
--     ,xct.*
FROM 
    v$sys_optimizer_env xct
WHERE 1=1
  --AND name     = 'parallel_execution_enabled'
  --AND value = 'false'
  AND isdefault = 'NO'
ORDER BY isdefault, name
;
```

Get execution environment at session level (modified)
```oracle
SELECT
    'execution env (session) ' 
    ,xct.name 
    ,xct.value
    ,'v$ses_optimizer_env=>'
    ,xct.*
FROM
    v$ses_optimizer_env xct
WHERE 1=1
  AND isdefault = 'NO'
  --AND name NOT LIKE '\_%'  ESCAPE '\'
  AND sid = (SELECT sid FROM v$session WHERE audsid = userenv('SESSIONID'))
  AND name     = 'optimizer_adaptive_plans'
    ;
  --AND value = 'false'
  --AND isdefault = 'NO'
```

### cursor level (v$sql_optimizer_en)

> `v$sql_optimizer_env` gives information about the execution environment for each child cursor present in the library cache.

2 child cursors have same parent, but different exectuion environment
```oracle
SELECT e0.sql_id, 
       e0.name, 
       e0.value AS value_child_0, 
       e1.value AS value_child_1
FROM 
    v$sql_optimizer_env e0 
        INNER JOIN v$sql_optimizer_env e1 ON e0.sql_id = e1.sql_id
WHERE 1=1
    AND e0.sql_id = '7kaq4kd6jc8nk'
    AND e0.child_number = 0
    AND e1.child_number = 1
    AND e0.name = e1.name
    AND e0.value <> e1.value
;
```

```text
NAME                 VALUE_CHILD_0 VALUE_CHILD_1
-------------------- ------------- -------------
hash_area_size       33554432      131072
optimizer_mode       first_rows_10 all_rows
cursor_sharing       force         exact
workarea_size_policy manual        auto
```

## hints not in code : stored outline 

> Stored outlines are designed to provide stable execution plans in case of changes in the execution environment or object statistics. For this reason, this feature is also called plan stability

> A stored outline is a set of hints or, more precisely, all the hints that are necessary to force the query optimizer to consistently generate a specific execution plan for a given SQL statement.

> From version 11.1 onward, stored outlines are deprecated in favor of SQL plan management


Hints that cannot be stored (most of the hints don’t impact execution plans )
```oracle
SELECT name FROM v$sql_hint WHERE version_outline IS NULL
```

> One of the advantages of a stored outline is that it applies to a specific SQL statement, but you don’t need to modify the SQL statement (in application, adding hints ) in order to apply the stored outline.

### create

>  You can use two main methods to create stored outlines:
>  - let the database automatically create them 
>  - you do it manually

Automatically :  set `create_stored_outlines` to true (`default` category) or a category.

Manually, supplying query (you should not provide hints, or the query will not be matched, see private outlines!)
```oracle
CREATE OR REPLACE OUTLINE outline_from_text
FOR CATEGORY test ON
SELECT * FROM emp WHERE empno = 7369;
```

Manually, reparsing a cursor (the execution plan associated to the stored outline isn’t necessarily identical to the one associated to the cursor) :
- get hash
- pass hash to `dbms_outln.create_outline`

```oracle
SELECT hash_value, child_number, sql_text
FROM v$sql
WHERE 1=1
--     AND sql_text = 'SELECT * FROM emp WHERE empno = 7369'
    AND sql_text LIKE '%7369%'
    AND sql_text NOT LIKE '%v$sql%'
```

```oracle 
BEGIN
  dbms_outln.create_outline(hash_value   => '308120306',
                            child_number => 0,
                            category     => 'test');
END;
```

> With stored outlines, it’s possible to lock up execution plans. However, this is useful only if the query optimizer is able to generate an efficient execution plan that can later be captured and frozen by a stored outline.

> If that’s not the case, the first thing you should investigate is the possibility of modifying the execution environment, the access structures, or the object statistics just for the creation of the stored outline storing an efficient execution plan.

> For instance, if the execution plan for a given SQL statement uses an index scan that you want to avoid, you could drop (or make invisible) the index on a test system, generate a stored outline there, and then move the stored outline in production.


### get (user_outlines, user_outline_hints )

Outline
```oracle
SELECT category, sql_text, signature, used
FROM user_outlines
WHERE name = 'OUTLINE_FROM_TEXT';
```

You get
```text 
CATEGORY SQL_TEXT                       SIGNATURE
-------- ------------------------------ --------------------------------
TEST     SELECT * FROM t WHERE n = 1970 73DC40455AF10A40D84EF59A2F8CBFFE
```

Hints
```oracle                        
SELECT name, hint
FROM user_outline_hints
WHERE 1=1
    AND name = 'OUTLINE_FROM_TEXT'
    AND hint LIKE '%INDEX_RS_ASC%'
;
```

You get index range scan
```text
OUTLINE_FROM_TEXT,"INDEX_RS_ASC(@""SEL$1"" ""EMP""@""SEL$1"" (""EMP"".""EMPNO""))"
```

### modify

Rename
```oracle
ALTER OUTLINE SYS_OUTLINE_13072411155434901 RENAME TO outline_from_sqlarea
```

Move to category
```oracle
execute dbms_outln.update_by_cat(oldcat => 'TEST', newcat => 'DEFAULT')
```

Recreate
```oracle
ALTER OUTLINE outline_from_text REBUILD;
```

Reset usage
```oracle
execute dbms_outln.clear_used(name => 'OUTLINE_FROM_TEXT')
```

#### private

If you want to change the hints one by one (eg the full table scan instead of an index with `+full`) , you should work on private stored outline and publish it.

```oracle
-- From query
CREATE OR REPLACE PRIVATE OUTLINE p_outline_editing ON 
SELECT * FROM emp WHERE empno = 7369;

-- From existing
CREATE OR REPLACE PRIVATE OUTLINE p_outline_editing FROM PUBLIC outline_from_text;

-- Create one with hint (to get what we want)
CREATE OR REPLACE PRIVATE OUTLINE p_outline_editing_hinted ON 
SELECT /*+ full(emp) */ * FROM emp WHERE empno = 7369;

-- Check
SELECT ol_name, hint_text
FROM ol$hints
WHERE 1=1
    AND ol_name IN ('P_OUTLINE_EDITING_HINTED', 'P_OUTLINE_EDITING')
    AND (    hint_text LIKE 'INDEX_RS_ASC%'
          OR hint_text LIKE 'FULL%')
ORDER BY ol_name, hint_text;

-- Copy the hinted over the original (tedious)
UPDATE ol$
SET hintcount = (SELECT hintcount
                 FROM ol$
                 WHERE ol_name = 'P_OUTLINE_EDITING_HINTED')
WHERE ol_name = 'P_OUTLINE_EDITING';

DELETE ol$hints
WHERE ol_name = 'P_OUTLINE_EDITING';

UPDATE ol$hints
SET ol_name = 'P_OUTLINE_EDITING'
WHERE ol_name = 'P_OUTLINE_EDITING_HINTED';

EXECUTE dbms_outln_edit.refresh_private_outline('P_OUTLINE_EDITING');

-- Test
ALTER SESSION SET use_private_outlines = TRUE ;

EXPLAIN PLAN FOR 
SELECT * FROM emp WHERE empno = 7369;

SELECT * FROM table(dbms_xplan.display(NULL,NULL,'basic +note'));

-- Publish
CREATE PUBLIC OUTLINE outline_editing FROM PRIVATE p_outline_editing;

ALTER SESSION SET use_private_outlines = FALSE ;
```

```oracle
EXPLAIN PLAN FOR 
SELECT * FROM emp WHERE empno = 7369;

SELECT * FROM table(dbms_xplan.display(NULL,NULL,'basic +note'));
```

You get
- `TABLE ACCESS FULL` on `EMP`
- `outline "P_OUTLINE_EDITING" used for this statement`

```oracle
DROP OUTLINE p_outline_editing;
```


### use

Activate default category
```oracle
ALTER SESSION SET use_stored_outlines = true;
```

Activate category
```oracle
ALTER SESSION SET use_stored_outlines = test;
```

Activate outline
```oracle
ALTER OUTLINE outline_from_text ENABLE;
ALTER OUTLINE outline_from_text DISABLE;
```

> Because the use_stored_outlines initialization parameter supports a single category, at a given time a session can activate only a single category.

### find if used

Check `Notes` section in execution plan
```text
Note
-----
   - outline "OUTLINE_FROM_TEXT" used for this statement
```

For a cursor on which you don't have the plan
> For a cursor stored in the library cache, the outline_category column of the v$sql view informs whether a stored outline was used during the generation of the execution plan. Unfortunately, only the category is given. The name of the stored outline itself remains unknown. If no stored outline was used, the column is set to NULL.
```oracle
SELECT t.sql_id, 
       t.outline_category, 
       t.*
FROM v$sql t
WHERE 1=1
    --AND t.outline_category IS NOT NULL
```

> One of the most important properties of stored outlines is that they’re detached from the code. Nevertheless, that could lead to problems. In fact, because there is no direct reference between the stored outline and the SQL statement, it’s possible that a developer will completely ignore the existence of the stored outline. 
> As a result, if the developer modifies the SQL statement in a way that leads to a modification of its signature, the stored outline will no longer be used.

As the contrary, a hint in the code is explicit.


It may not be used if 
- you did not activate it
- it is invalid: the object referenced (eg. an index) has been dropped;
- the query text has changed

Whenever a SQL statement has, at the same time:
- a stored outline 
- a SQL profile
- a SQL plan baseline 
The query optimizer uses only the stored outline.

## sql profile

### overview

> You can delegate SQL optimization to a component of the query optimizer called the `Automatic Tuning Optimizer`

> In fact, in normal circumstances the query optimizer is constrained to generate a suboptimal execution plan because it must operate very quickly, typically in the subsecond range. 
> Instead, much more time can be given to the Automatic Tuning Optimizer to carry out an efficient execution plan. It will use time-consuming techniques such as what-if analyses and make strong utilization of dynamic sampling techniques to verify its estimations.

> The Automatic Tuning Optimizer is exposed through the SQL Tuning Advisor which will suggest :
> - gathering missing or stale object statistics
> - creating new indexes
> - altering the SQL statement
> - accepting a SQL profile

> SQL profiles, officially, can be generated only through the SQL Tuning Advisor. Nevertheless, you can also create them manually.

> A SQL profile is an object containing information that helps the query optimizer find an efficient execution plan for a specific SQL statement
>  - execution environment
>  - object statistics
>  - corrections related to the estimations performed by the query optimizer

> Here are the steps in detail:
> - The user passes the poorly performing SQL statement to the SQL Tuning Advisor.
> - The SQL Tuning Advisor asks the Automatic Tuning Optimizer to give advice aimed at optimizing the SQL statement.
> - The query optimizer gets the system statistics, the object statistics related to the objects referenced by the SQL statement, and the initialization parameters that set up the execution environment.
> - The SQL statement is analyzed. During this phase, the Automatic Tuning Optimizer performs its analysis and partially executes the SQL statement to confirm its guesses.
> - The Automatic Tuning Optimizer returns the SQL profile to the SQL Tuning Advisor.
> - The user accepts the SQL profile.
> - The SQL profile is stored in the data dictionary.

### warning

> the aim of SQL profiles is to provide the query optimizer with additional information about the data to be processed and about the execution environment. 
> So, don’t use this technique if you need to force a specific execution plan for a specific SQL statement. For that purpose, you should use either stored outlines or SQL plan management.

> The only exception is when you want to take advantage of the text normalization feature related to the force_match parameter. In fact, neither stored outlines nor SQL plan management offer a similar feature.

> Whenever a SQL statement has a SQL profile and an active stored outline, the query optimizer uses only the stored outline.


### create a tuning task to suggest a profile

Package `dbms_sqltune` is SQL Tuning Advisor

To create a profile, start a tuning task that will create a tuning set.

For this query
```oracle
CREATE TABLE simple_table (id INTEGER, text VARCHAR2(100));
INSERT INTO simple_table VALUES(1, 'foo');
SELECT MAX(id) FROM simple_table
```

Create a tuning task
```oracle
SELECT *
FROM v$sql
WHERE 1=1
    AND sql_id = '1rnrcq1j05pq6'
    AND lower(sql_fulltext) LIKE '%simple_table%'
    AND sql_fulltext NOT LIKE '%v$sql%'
```

```oracle
DECLARE
   tuning_task VARCHAR2(1000);
BEGIN
   -- you can also supply a sql text
   tuning_task := dbms_sqltune.create_tuning_task(sql_id=> '1rnrcq1j05pq6' );
   DBMS_OUTPUT.PUT_LINE('Tuning task ' || tuning_task || ' created');
   dbms_sqltune.execute_tuning_task(tuning_task);
END;
/
```

Get the analysis
```oracle
SELECT 
    dbms_sqltune.report_tuning_task('TASK_58')
FROM dual
```

You get
```text
GENERAL INFORMATION SECTION
-------------------------------------------------------------------------------
Tuning Task Name   : TASK_54
Tuning Task Owner  : USERNAME
Workload Type      : Single SQL Statement
Scope              : COMPREHENSIVE
Time Limit(seconds): 1800
Completion Status  : COMPLETED
Started at         : 01/21/2025 15:50:06
Completed at       : 01/21/2025 15:50:06

-------------------------------------------------------------------------------
Schema Name   : USERNAME
Container Name: FREEPDB1
SQL ID        : 9xz7yas8z9pd9
SQL Text      : SELECT MAX(id)
                FROM simple_table

-------------------------------------------------------------------------------
FINDINGS SECTION (1 finding)
-------------------------------------------------------------------------------

1- Statistics Finding
---------------------
  Table "USERNAME"."SIMPLE_TABLE" was not analyzed.

  Recommendation
  --------------
  - Consider collecting optimizer statistics for this table.
    BEGIN    
     dbms_stats.gather_table_stats(
      ownname => 'USERNAME',
      tabname => 'SIMPLE_TABLE',
      estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
      method_opt => 'FOR ALL COLUMNS SIZE AUTO');
    END;    
    /    

  Rationale
  ---------
    The optimizer requires up-to-date statistics for the table in order to
    select a good execution plan.

-------------------------------------------------------------------------------
EXPLAIN PLANS SECTION
-------------------------------------------------------------------------------

1- Original
-----------
Plan hash value: 1067509040

-----------------------------------------------------------------------------------
| Id  | Operation          | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |     1 |    13 |     3   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE    |              |     1 |    13 |            |          |
|   2 |   TABLE ACCESS FULL| SIMPLE_TABLE |  1001 | 13013 |     3   (0)| 00:00:01 |
-----------------------------------------------------------------------------------

-------------------------------------------------------------------------------
```

Now you read
- `There are no recommendations to improve the statement.` : bad luck
- `A potentially better execution plan was found for this statement.` : good

Now drop this advice
```oracle
dbms_sqltune.drop_tuning_task('TASK_54');
```

### accept the profile

> If the SQL statement contains literals that change, it’s likely that the signature, which is a hash value, changes as well. Because of this, the SQL profile may be useless because it’s tied to a very specific SQL statement that will possibly never be executed again. 
> To avoid this problem, the database engine is able to remove literals during the normalization phase. This is done by setting the `force_match` parameter to TRUE while accepting the SQL profile.

```oracle
call dbms_sqltune.accept_sql_profile(
        task_name   => 'TASK_58',
        task_owner  => user,
        name        => 'opt_estimate',
        description => NULL,
        category    => 'TEST',
        force_match => TRUE,
        replace     => TRUE
     );
```

> As a result, if no category is specified when accepting the SQL profile, by default the SQL profile is activated.

Check if accepted
```oracle
SELECT category, sql_text, force_matching
FROM dba_sql_profiles
WHERE name = 'opt_estimate'
;
```

### activate it

```oracle
ALTER SESSION SET sqltune_category = test
```

Check it is used: check `Notes`
```text
Note
-----
   - SQL profile "import_sql_profile" used for this statement
```

### read definition

```oracle
SELECT 
    extractValue(value(h),'.') AS hint
FROM sys.sqlobj$data od, sys.sqlobj$ so,
     table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/hint'))) h
WHERE 1=1
    --AND so.name = 'all_rows'
    AND so.signature = od.signature
    AND so.category = od.category
    AND so.obj_type = od.obj_type
    AND so.plan_id = od.plan_id;
```

You get
```text
HINT
----------------------------------
ALL_ROWS
OPTIMIZER_FEATURES_ENABLE(default)
IGNORE_OPTIM_EMBEDDED_HINTS
```

You can get, for estimated <> actual rows
```text
OPT_ESTIMATE(@"SEL$1", INDEX_SCAN, "T1"@"SEL$1", "T1_COL1_COL2_I", SCALE_ROWS=477.9096254)
```

> The important thing to note is the presence of the opt_estimate undocumented hint. With that particular hint, it’s possible to inform the query optimizer that some of its estimations are wrong and by how much. 
> For example, the first hint tells the query optimizer to scale up the estimation of the operation that accesses the t1 table by about 478 times

You can also see statistics here
```text
TABLE_STATS("CHRIS"."T2", scale, blocks=735 rows=5000)
INDEX_STATS("CHRIS"."T2", "T2_PK", scale, blocks=14 index_rows=5000)
COLUMN_STATS("CHRIS"."T2", "PAD", scale, length=1000)
COLUMN_STATS("CHRIS"."T2", "COL2", scale, length=3)
COLUMN_STATS("CHRIS"."T2", "COL1", scale, length=3)
COLUMN_STATS("CHRIS"."T2", "ID", scale, length=3 distinct=5000 nulls=0 min=2 max=10000)
```



### deactivate

```oracle
CALL dbms_sqltune.alter_sql_profile(name           => 'opt_estimate',
                               attribute_name => 'status',
                               value          => 'disabled');
```


### drop

```oracle
CALL dbms_sqltune.drop_sql_profile(
        name   => 'opt_estimate',
        ignore => TRUE
);
```

### create by yourslef (not tuning task)


Create dataset
```oracle
DROP TABLE t;
CREATE TABLE t AS 
SELECT rownum AS n, rpad('*',100,'*') AS id
FROM dual
CONNECT BY level <= 1000;
```

Eg., for hint `first_rows(42)`
```oracle
CALL dbms_sqltune.import_sql_profile(
  name        => 'import_sql_profile',
  description => 'SQL profile created manually',
  category    => 'TEST',
  sql_text    => 'SELECT * FROM t ORDER BY id',
  profile     => sqlprof_attr('first_rows(42)','optimizer_features_enable(default)'),
  replace     => FALSE,
  force_match => FALSE
);
```

Check if created
```oracle
SELECT category, sql_text, force_matching
FROM dba_sql_profiles
WHERE name = 'import_sql_profile'
;
```

Check definition
```oracle
SELECT 
    extractValue(value(h),'.') AS hint
FROM sys.sqlobj$data od, sys.sqlobj$ so,
     table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/hint'))) h
WHERE 1=1
    AND so.name = 'import_sql_profile'
    AND so.signature = od.signature
    AND so.category = od.category
    AND so.obj_type = od.obj_type
    AND so.plan_id = od.plan_id;
```

Activate
```oracle
ALTER SESSION SET sqltune_category = test
```

Run query
```oracle
EXPLAIN PLAN FOR
SELECT * FROM t ORDER BY id;
SELECT * FROM table(dbms_xplan.display(NULL,NULL,'basic +note'));
```

You'll get
```text
   - SQL profile "import_sql_profile" used for this statement
```

Deactivate
```oracle
CALL dbms_sqltune.alter_sql_profile(name           => 'import_sql_profile',
                               attribute_name => 'status',
                               value          => 'disabled');
```

Drop
```oracle
CALL dbms_sqltune.drop_sql_profile(
        name   => 'import_sql_profile',
        ignore => TRUE
);
```


## sql plans

Alternative to [stored outline](#hints-not-in-code--stored-outline-).

> Actually, it can be considered an enhanced version of stored outlines.
> Unfortunately, SQL plan baselines are available only with Enterprise Edition. With Standard Edition, use stored outline instead.

Hints that cannot be stored (most of the hints don’t impact execution plans )
```oracle
SELECT name FROM v$sql_hint WHERE version_outline IS NULL
```

### concepts

> Here are the key elements SQL Plan Management consists of:
> - SQL plan baselines: The actual objects that are used to make execution plans stable (can contain several execution plan, each with a cost)
> - Statement log: A list of SQL statements that were executed in the past.
> - SQL Management Base (SMB): Where the SQL plan baselines and the statement log are stored.



### capturing baselines (`optimizer_capture_sql_plan_baselines`)

> When the `optimizer_capture_sql_plan_baselines` initialization parameter is set to TRUE, the query optimizer automatically stores new SQL plan baselines.

Create dataset
```oracle
DROP TABLE t;
CREATE TABLE t AS 
SELECT rownum AS n, rpad('*',100,'*') AS pad
FROM dual
CONNECT BY level <= 1000;
```

Capture
```oracle
ALTER SESSION SET optimizer_capture_sql_plan_baselines = TRUE;
```

Run some queries..
```oracle
SELECT /*+ full(t) */ count(pad) FROM t WHERE n = 42;
```

Once you're done
```oracle
ALTER SESSION SET optimizer_capture_sql_plan_baselines = FALSE;
```



Check baseline are activated
```oracle
SELECT value 
FROM v$parameter WHERE name = 'optimizer_use_sql_plan_baselines';
```


Check if used (first time)
```oracle
EXPLAIN PLAN FOR
SELECT /*+ full(t) */ count(pad) FROM t WHERE n = 42;

SELECT * FROM table(dbms_xplan.display(format=>' basic +note'));
```

You should get
```text
Note
-----
   - SQL plan baseline SQL_PLAN_3u6sbgq7v4u8z3fdbb376 used for this statement
```

Check
```oracle
SELECT 
    t.plan_name, t.sql_handle, t.enabled, t.accepted, t.executions, t.sql_text
    ,t.*
FROM dba_sql_plan_baselines t
WHERE 1=1
    AND plan_name = 'SQL_PLAN_0kwsbznj1yrfr21a18e41'
    AND sql_handle = 'SQL_09730bfd221f5dd7'
;
```




First time
> This means that the first time a specific SQL statement is executed, its signature is inserted only into the log. 

Second time
> Then, when the same SQL statement is executed for the second time, a SQL plan baseline containing only the current execution plan is created and marked as accepted.

Third time
> From the third execution on, because a SQL plan baseline is already associated with the SQL statement, the query optimizer also compares the current execution plan with the execution plan generated with the help of the SQL plan baseline. 
> If they don’t match, it means that according to the current query optimizer estimations, the optimal execution plan isn’t the one stored in the SQL plan baseline. To save that information, the current execution plan is added to the SQL plan baseline and marked as nonaccepted. 
> As you’ve seen before, however, the current execution plan can’t be used. The query optimizer is forced to use the execution plan generated with the help of the SQL plan baseline.

### manual from cache (`load_plans_from_cursor_cache`)

> To manually load SQL plan baselines into the data dictionary based on cursors stored in the library cache, the load_plans_from_cursor_cache function in the dbms_spm package is available.
> This is relevant only if you want to ensure that the current execution plan will also be used in the future.

For all queries containing `MySqlStm` text in comments (source code)
```oracle
ret := dbms_spm.load_plans_from_cursor_cache(attribute_name  => 'sql_text',
                                             attribute_value => '%/* MySqlStm */%');
```

For sql id
```oracle
ret := dbms_spm.load_plans_from_cursor_cache(sql_id          => '2y5r75r8y3sj0',
                                             plan_hash_value => NULL);
```

> Execution plans loaded with these functions are stored as accepted, and so the query optimizer might immediately take advantage of them.


### replace a baseline with another (hack query)


```oracle
ret := dbms_spm. load_plans_from_cursor_cache(sql_handle      => 'SQL_3d1b0b7d8fb2691f',
                                             sql_id          => 'dat4n4845zdxc',
                                             plan_hash_value => '3694077449');
 
ret := dbms_spm. drop_sql_plan_baseline(sql_handle => 'SQL_3d1b0b7d8fb2691f',
                                       plan_name  => 'SQL_PLAN_3u6sbgq7v4u8z3fdbb376');
```

Check if used

```oracle
SELECT sql_id, sql_text, sql_plan_baseline
FROM v$sql
WHERE 1=1
  AND sql_fulltext LIKE '%SELECT % count(pad) FROM t WHERE n = %'
  AND sql_text NOT LIKE '%v$sql%'
```

### load from SQL tuning set (`load_plans_from_sqlset`)

```oracle
ret := dbms_spm.load_plans_from_sqlset(sqlset_name  => 'test_sqlset',
                                       sqlset_owner => user);
```

> Execution plans loaded with this function are stored as accepted. Therefore, the query optimizer is immediately able to take advantage of them.

```oracle
SELECT *
 FROM table(dbms_xplan.display_sql_plan_baseline(sql_handle => 'SQL_09730bfd221f5dd7'));
 
```

Get hints from `sqlobj$data`
```oracle
SELECT extractValue(value(h),'.') AS hint
FROM sys.sqlobj$data od, sys.sqlobj$ so,
     table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/hint'))) h
WHERE so.name = 'SQL_PLAN_0kwsbznj1yrfr21a18e41'
    AND so.signature = od.signature
    AND so.category = od.category
    AND so.obj_type = od.obj_type
    AND so.plan_id = od.plan_id;
```

You'll get
```text
FULL(@"SEL$1" "T"@"SEL$1")
```

Or better use `display_sql_plan_baseline`
```oracle
SELECT *
FROM table(dbms_xplan.display_sql_plan_baseline(sql_handle => 'SQL_09730bfd221f5dd7',
                                                  format     => 'outline' ));
```

### evolving baseline (`dbms_spm.evolve_sql_plan_baseline`)

> When the query optimizer generates an execution plan different from one present in the SQL plan baseline associated to the SQL statement it’s optimizing, a new nonaccepted execution plan is automatically added to the SQL plan baseline. 
> This happens even if the query optimizer can’t immediately use the nonaccepted execution plan. The idea is to keep the information that another and possibly better execution plan exists. 
> To verify whether one of the nonaccepted execution plans will in fact perform better than the ones generated with the help of accepted SQL plan baselines, an **evolution** must be attempted

```oracle
SELECT dbms_spm.evolve_sql_plan_baseline(
    sql_handle => 'SQL_492bdb47e8861a89',
    plan_name  => '',
    time_limit => 10,
    verify     => 'yes',
    commit     => 'yes')
FROM dual;
```

You'll be know if plan is better
```text
Plan passed performance criterion: 24.59 times better than baseline plan. Plan was changed to an accepted plan.
```

Full output
```text
-------------------------------------------------------------------------------
                        Evolve SQL Plan Baseline Report
-------------------------------------------------------------------------------
 
Inputs:
-------
  SQL_HANDLE = SQL_492bdb47e8861a89
  PLAN_NAME  =
  TIME_LIMIT = 10
  VERIFY     = yes
  COMMIT     = yes
 
Plan: SQL_PLAN_4kayv8zn8c6n959340d78
------------------------------------
  Plan was verified: Time used .05 seconds.
  Plan passed performance criterion: 24.59 times better than baseline plan.
  Plan was changed to an accepted plan.
 
                            Baseline Plan      Test Plan       Stats Ratio
                            -------------      ---------       -----------
  Execution Status:              COMPLETE       COMPLETE
  Rows Processed:                       1              1
  Elapsed Time(ms):                  .527           .054              9.76
  CPU Time(ms):                      .333           .111                 3
  Buffer Gets:                         74              3             24.67
  Physical Read Requests:               0              0
  Physical Write Requests:              0              0
  Physical Read Bytes:                  0              0
  Physical Write Bytes:                 0              0
  Executions:                           1              1
 
-------------------------------------------------------------------------------
                                 Report Summary
-------------------------------------------------------------------------------
Number of plans verified: 1
```

To automatically do evolutions, set accept_sql_profiles to TRUE
```oracle
CALL dbms_auto_sqltune.set_auto_tuning_task_parameter(parameter => 'ACCEPT_SQL_PROFILES',
                                                 value     => 'TRUE');
```


Check
```oracle
SELECT task_name, parameter_name, parameter_value
FROM dba_advisor_parameters
WHERE 1=1
--     AND task_name LIKE '%SPM%'
    AND task_name = 'SYS_AUTO_SQL_TUNING_TASK'
    AND parameter_name = 'ACCEPT_SQL_PROFILES'
--     AND parameter_name LIKE '%PROFILES%'
;   
```

> SPM evolve advisor
> Its purpose is to execute an evolution for the nonaccepted execution plans associated to SQL plan baselines. It runs during the maintenance window, just as other advisors do.

Check SPm evolve advisor
```oracle
SELECT *
FROM (
  SELECT task_name, execution_name, execution_start
  FROM dba_advisor_executions
  WHERE task_name = 'SYS_AUTO_SPM_EVOLVE_TASK'
  ORDER BY execution_start DESC
)
WHERE rownum <= 3;
```

Then
```oracle
SELECT dbms_spm.report_auto_evolve_task(execution_name => 'TASK_58')
FROM dual;
```

### altering a baseline

> In the following call, an execution plan associated to a specific SQL plan baseline is disabled
```oracle
ret := dbms_spm.alter_sql_plan_baseline(sql_handle      => 'SQL_492bdb47e8861a89',
                                        plan_name       => 'SQL_PLAN_4kayv8zn8c6n93fdbb376',
                                        attribute_name  => 'enabled',
                                        attribute_value => 'no');
```

### drop


```oracle
ret := dbms_spm.drop_sql_plan_baseline(sql_handle => 'SQL_492bdb47e8861a89',
                                       plan_name  => 'SQL_PLAN_4kayv8zn8c6n93fdbb376');
```

> Unused SQL plan baselines (that don’t have the fixed attribute set to yes) are automatically removed after a retention period. The default retention period is 53 weeks. 

```oracle
SELECT parameter_value
FROM dba_sql_management_config
WHERE parameter_name = 'PLAN_RETENTION_WEEKS';
```

Change
```oracle
CALL dbms_spm.configure(parameter_name  => 'plan_retention_weeks',
                   parameter_value => 12);
```