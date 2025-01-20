# Query optimizer

## fundamentals

>The query optimizer, to choose an execution plan, has to answer questions like the following:

    Which is the optimal access path to extract data from each table referenced in the SQL statement?
    Which are the optimal join methods and join orders through which the data of the referenced tables will be processed?
    When should aggregations and/or sorts be processed during SQL statement execution?
    Is it beneficial to use parallel processing?


To log optimizer operations, trace event 10053 
```oraclesqlplus
ALTER SESSION SET events '10053 trace name context forever';
```
## query rewrite

Optimization:
- Filter Push Down
- Distinct Placement: Eliminating duplicates earlier (keeps intermediate result sets as small as possible), see Group-by Placement
- Distinct Elimination: when a SELECT clause references all columns of a primary key/unique not null key
- Order-By Elimination:  when an ORDER BY is followed by an operation that doesn’t guarantee that it will return the rows ordered
- Subquery Unnesting
- Subquery Coalescing:  combine equivalent semi- and anti-join subqueries into a single query block
- join elimination : remove redundant joins
- Outer Join to Inner Join, if a restriction is specified making it superfluous (eg. IS NOT NULL)
- Set to Join Conversion

## systems statistics

### overview

> system statistics supply the following information:

    Performance of the disk I/O subsystem
    Performance of the CPU

The cost model used is named `CPU cost model`
> CPU cost model takes into consideration the cost of physical reads as well. But instead of basing the I/O costs on the number of physical reads only, the performance of the disk I/O subsystem is also considered.

You can store system statistics out of data dictionary to prevent making them available to the query optimizer, using `dbms_stats.gather_system_statistics('my_stats-table')`

2 statistics in `aux_stats$ `
- noworkload : always available, you can do `dbms_stats.gather_system_stats(gathering_mode => 'noworkload')`
- workload :  available only when explicitly gathered:
  - start: `dbms_stats.gather_system_stats(gathering_mode => 'start')`
  - stop: `dbms_stats.gather_system_stats(gathering_mode => 'stop')`
  - or decide how much time, gg. 10 min: `dbms_stats.gather_system_stats(gathering_mode => 'interval', interval       => 10)`

Noworkload: 
>To measure the CPU speed, most likely some kind of calibrating operation is executed in a loop. To measure the disk I/O performance, some reads of different sizes are performed on several data files of the database.


### Get statistics


Administrator only
```oracle
SELECT sname, pname, pval1, pval2
FROM aux_stats$
```

| SNAME         | PNAME      | PVAL1            | PVAL2            |
|:--------------|:-----------|:-----------------|:-----------------|
| SYSSTATS_INFO | STATUS     | null             | COMPLETED        |
| SYSSTATS_INFO | DSTART     | null             | 10-18-2024 02:22 |
| SYSSTATS_INFO | DSTOP      | null             | 10-18-2024 02:22 |
| SYSSTATS_INFO | FLAGS      | 1                | null             |
| SYSSTATS_MAIN | CPUSPEEDNW | 3464.71674002556 | null             |
| SYSSTATS_MAIN | IOSEEKTIM  | 10               | null             |
| SYSSTATS_MAIN | IOTFRSPEED | 4096             | null             |

> SREADTIM : Average time a single-block read operation
> MREADTIM: Average time a multiblock read operation
> MBRC : Average number of blocks read during multiblock read operations*


### Set manually

You can set them yourselves 

```oraclesqlplus
BEGIN
  dbms_stats.delete_system_stats();
  dbms_stats.set_system_stats(pname => 'CPUSPEED', pvalue => 772);
  dbms_stats.set_system_stats(pname => 'SREADTIM', pvalue => 5.5);
  dbms_stats.set_system_stats(pname => 'MREADTIM', pvalue => 19.4);
  dbms_stats.set_system_stats(pname => 'MBRC',     pvalue => 53);
  dbms_stats.set_system_stats(pname => 'MAXTHR',   pvalue => 1136136192);
  dbms_stats.set_system_stats(pname => 'SLAVETHR', pvalue => 16870400);
END;
```

Choosing between the two types of available system statistics is about choosing between simplicity and control. The absolute simplest approach is to choose the default statistics.

To use `noworkload` after choosing `workload`
```oraclesqlplus
delete_system_stats
```

They're saved for 31 days (you can change that)
```oracle
SELECT *
FROm wri$_optstat_aux_history
```

### Restore

If you don't remember
```oracle
BEGIN
  dbms_stats.delete_system_stats();
  dbms_stats.restore_system_stats(as_of_timestamp => systimestamp - INTERVAL '1' DAY);
END;
```

### History

To check if anyone has done something
```oracle
 SELECT operation, start_time,
          (end_time-start_time) DAY(1) TO SECOND(0) AS duration
FROM dba_optstat_operations
WHERE start_time > to_date(:now,'YYYYMMDDHH24MISS')
 ORDER BY start_time;
```

> Only with workload statistics, through the maxthr and slavethr statistics, can you control the costing of parallel operations.


```oracle
SELECT statement_id, cpu_cost AS total_cpu_cost,
        cpu_cost-lag(cpu_cost) OVER (ORDER BY statement_id) AS cpu_cost_1_coll,
       io_cost
FROM plan_table
 WHERE id = 0
ORDER BY statement_id;
```

## objects statistics

`dbms_stats` provides collecting, modifying and exporting statistics.

You can operate on
- database
- schema
- object (eg. table)

3 types of statistics:
- table
- column
- index

You can get statistics values in 
- tables: `user_tab_statistics`
- columns: `user_tab_col_statistics` and `user_tab_histograms`
- indexes : `user_ind_statistics`


### Dataset

Generate
```oracle
DROP TABLE t;
CREATE TABLE t
AS
SELECT rownum AS id,
       50+round(dbms_random.normal*4) AS val1,
       100+round(ln(rownum/3.25+2)) AS val2,
       100+round(ln(rownum/3.25+2)) AS val3,
       dbms_random.string('p',250) AS pad
FROM dual
CONNECT BY level <= 1000
ORDER BY dbms_random.value;

UPDATE t SET val1 = NULL WHERE val1 < 0;

ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id);

CREATE INDEX t_val1_i ON t (val1);

CREATE INDEX t_val2_i ON t (val2);

CALL
  dbms_stats.gather_table_stats(
          ownname          => user,
          tabname          => 'T',
          estimate_percent => 100,
          method_opt       => 'for columns size skewonly id, val1 size 15, val2, val3 size 5, pad',
          cascade          => TRUE
  );
```

Peek
```oracle
SELECT *
FROM t;
```

### Watermark

> The high watermark is the boundary between used and unused space in a segment. The used blocks are below the high watermark, and therefore, the unused blocks are above the high watermark. Blocks above the high watermark have never been used or initialized.

> Operations requiring space (for example, INSERT statements) increase the high watermark only if there is no more free space available below the high watermark.

> Operations releasing space (for example, DELETE statements) don’t decrease the high watermark. They simply make space available to other operations.

>  If the free space is released at a rate <= the rate the space is reused, the use of the blocks below the high watermark should be optimal. Otherwise, the free space below the high watermark would increase steadily.
>
> Long-term, this would cause 
> - unnecessary increase in the size of the segment
> - suboptimal performance

> In fact, full scans access all blocks below the high watermark. This occurs even if they’re empty. The segment should be reorganized to solve such a problem.

Get block count
```oracle
analyze table t compute statistics;
```

```oracle
SELECT 
       num_rows, 
       blocks       AS blk_count_below_hwm, 
       empty_blocks AS blk_count_above_hwm, 
       avg_space free_space, 
       avg_row_len
FROM user_tab_statistics
WHERE table_name = 'T';
```

### Table

empty_blocks, avg_space is not computed by `dbms_stats`.
```oracle
SELECT 
    num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len
    ,sample_size
FROM user_tab_statistics
WHERE table_name = 'T';
```

### Columns

```oracle
SELECT 
  column_name,
  num_distinct,
--   low_value,
  utl_raw.cast_to_number(low_value) AS low_value,
--   high_value,
  utl_raw.cast_to_number(high_value) AS high_value,
  density, -- default: 1/num_distinct => selectivity
  num_nulls,
  avg_col_len,
  histogram,
  num_buckets AS "#BKT"
FROM user_tab_col_statistics
WHERE 1=1
 AND table_name = 'T'
 AND column_name IN ('ID','VAL1')
ORDER BY column_name
```

### Histograms

#### Overview

Histograms is when data is not uniformly distributed.
A primary key is uniformly distributed, as each value exists only once.

The optimizer should know this 
- in order to estimate cardinality
- = how much rows will be retrieved by a predicate, eg. `val2 = 105`.

We know this predicate will return half the rows.
```oracle
SELECT val2, count(*)
FROM t
GROUP BY val2
ORDER BY val2;
```


4 types of histograms:
- frequency : how much rows match the value in range
- height-balanced
- top frequency
- hybrid

Maximum  2,048 buckets per statistic.


```oracle
SELECT 
  column_name,
  histogram
FROM user_tab_col_statistics
WHERE 1=1
 AND table_name = 'T'
  --AND histogram = 'HEIGHT BALANCED'
ORDER BY column_name
```

#### frequency

Frequency:
- stored in buckets, not distinct values
- cumulated 

```oracle
SELECT 
  column_name,
  histogram
FROM user_tab_col_statistics
WHERE 1=1
 AND table_name = 'T'
  AND histogram = 'FREQUENCY'
ORDER BY column_name
```

```oracle
SELECT endpoint_value, endpoint_number,
       endpoint_number - lag(endpoint_number,1,0)
                         OVER (ORDER BY endpoint_number) AS frequency
FROM user_tab_histograms
WHERE table_name = 'T'
AND column_name = 'VAL2'
ORDER BY endpoint_number;
```
| ENDPOINT\_VALUE | ENDPOINT\_NUMBER | FREQUENCY |
|:----------------|:-----------------|:----------|
| 101             | 0                | 0         |
| 106             | 1                | 1         |


That means 2 buckets:
- [0;101]: no values
- ]101;106]: all values

Better: 6 buckets

| ENDPOINT\_VALUE | ENDPOINT\_NUMBER | FREQUENCY |
|:----------------|:-----------------|:----------|
| 101             | 8                | 8         |
| 102             | 33               | 25        |
| 103             | 101              | 68        |
| 104             | 286              | 185       |
| 105             | 788              | 502       |
| 106             | 1000             | 212       |

> The essential characteristics of a frequency histogram are the number of buckets (in other words, the number of categories) is the same as the number of distinct values

Check cardinality in execution plan
```oracle
EXPLAIN PLAN SET STATEMENT_ID '101' FOR SELECT * FROM t WHERE val2 = 101;
EXPLAIN PLAN SET STATEMENT_ID '098' FOR SELECT * FROM t WHERE val2 = 98;


SELECT statement_id, cardinality
FROM plan_table
WHERE id = 0
ORDER BY statement_id;
```

> The values appearing several times in the histogram are called popular values and are especially handled by the query optimizer.


#### height-balanced

TODO: val2 is not height-balanced, val1 rather ?

> When the number of distinct values > maximum number of allowed buckets, you can’t use frequency histograms because they support a single value per bucket. Use height-balanced histograms.

Like a frequency histogram, flattened and divided into several buckets of exactly the same height (count of rows).

```oracle
SELECT 
  column_name,
  histogram
FROM user_tab_col_statistics
WHERE 1=1
 AND table_name = 'T'
  AND histogram = 'HEIGHT BALANCED'
ORDER BY column_name
```


Generate buckets manually
```oracle
SELECT count(*), max(val2) AS endpoint_value, endpoint_number
FROM (
  SELECT val2, ntile(5) OVER (ORDER BY val2) AS endpoint_number
  FROM t
)
GROUP BY endpoint_number
ORDER BY endpoint_number;
```

What if a value spans many bucket, like 105 ?

Actual histogram

```oracle
SELECT endpoint_value, endpoint_number
FROM user_tab_histograms
WHERE table_name = 'T'
AND column_name = 'VAL1'
ORDER BY endpoint_number;
```



```oracle
SELECT val1, count(*)
FROM t
GROUP BY val1
ORDER BY val1;
```

Cardinality

```oracle
DELETE FROM plan_table;
EXPLAIN PLAN SET STATEMENT_ID '101' FOR SELECT * FROM t WHERE val1 = 101;
EXPLAIN PLAN SET STATEMENT_ID '102' FOR SELECT * FROM t WHERE val1 = 102;
EXPLAIN PLAN SET STATEMENT_ID '103' FOR SELECT * FROM t WHERE val1 = 103;
EXPLAIN PLAN SET STATEMENT_ID '104' FOR SELECT * FROM t WHERE val1 = 104;
EXPLAIN PLAN SET STATEMENT_ID '105' FOR SELECT * FROM t WHERE val1 = 105;
EXPLAIN PLAN SET STATEMENT_ID '106' FOR SELECT * FROM t WHERE val1 = 106;
 
SELECT statement_id, cardinality
FROM plan_table
WHERE id = 0;
```

> If the value is outside the range covered by the histogram, the frequency depends on the distance from the lowest/maximum value

```oracle
DELETE FROM plan_table;

EXPLAIN PLAN SET STATEMENT_ID '010' FOR SELECT * FROM t WHERE val1 = 10;
EXPLAIN PLAN SET STATEMENT_ID '042.5' FOR SELECT * FROM t WHERE val1 = 42.5;
 
SELECT statement_id, cardinality
FROM plan_table
WHERE id = 0
ORDER BY statement_id;
```

You get :
- cardinality = 1 when value < lower_bound (37)
- cardinality = interpolation when value between buckets

| STATEMENT\_ID | CARDINALITY |
|:--------------|:------------|
| 010           | 3           |
| 042.5         | 25          |


| VAL1 | COUNT\(\*\) |
|:-----|:------------|
| 42   | 13          |
| 43   | 21          |




> it’s apparent that frequency histograms are more accurate than height-balanced histograms. The main problem with height-balanced histograms is not only that the precision is lower, but also that sometimes it might be by chance that a value is recognized as popular or not


> Eeven a small change in the data distribution might lead to a different histogram and to different estimations. Therefore, in practice, height-balanced histograms may not only be misleading but may also lead to instability in query optimizer estimations. For this reason, top frequency histograms and hybrid histograms replace height-balanced histograms.

#### top frequency

> In of a frequency histogram, every value is represented in the histogram. Because of the limit in the number of buckets, sometimes they can’t be created. In case some of the values represent a small percentage of the data, they can be safely discarded because they’re statistically insignificant. 
> If it’s possible to discard enough values to void surpassing the limit of the number of buckets, a top frequency histogram, which is based only on the top-n values, may be created.

We've got 6 values
```oracle
SELECT val3, count(*) AS frequency, ratio_to_report(count(*)) OVER ()*100 AS percent
FROM t
GROUP BY val3
ORDER BY val3;
```

> Five buckets are sufficient because, as the output of the following query shows, the top-3 values already account for more than 80% of the rows:

Histogram is
```oracle
SELECT endpoint_value, endpoint_number,
       endpoint_number - lag(endpoint_number,1,0)
                         OVER (ORDER BY endpoint_number) AS frequency
FROM user_tab_histograms
WHERE table_name = 'T'
AND column_name = 'VAL3'
ORDER BY endpoint_number;
```
> The bucket for the value 102 doesn’t exist. And that, even though the frequency of value 102 is higher than the frequency of value 101.  The fact is that a histogram must always contain the minimum and maximum values. If, as in this case, one of the two values should be discarded because it’s not part of the top-n values, another value is discarded (the one with the lowest frequency), and the frequency of the minimum/maximum value is set to 1 (lowest)


#### hybrid

If no satisfying solution (neither a frequency histogram nor a top frequency histogram) can be built, the database engine creates a hybrid histogram.

> The process to build them starts in the same way as for height-balanced histograms, but:
> - every distinct value is associated to a single bucket (no popular value). 
> => As a result, every bucket may be based on a different number of rows (different value)
> - a frequency is added to the endpoint value of every bucket. Hence, for the endpoint values, and only for the endpoint values, a kind of frequency histogram is available.

```oracle
SELECT val1, count(*), ratio_to_report(count(*)) OVER ()*100 AS percent
FROM t
GROUP BY val1
ORDER BY val1;
```


a frequency histogram : no, because the number of buckets is greater than the number of distinct values. 
top-frequency: the top-10 values represent only about 80% of the rows


Histogram
```oracle
SELECT endpoint_value, endpoint_number,
       endpoint_number - lag(endpoint_number,1,0)
                         OVER (ORDER BY endpoint_number) AS count,
       endpoint_repeat_count
FROM user_tab_histograms
WHERE table_name = 'T'
AND column_name = 'VAL1'
ORDER BY endpoint_number;
```

The bucket size can be anything:  1, 2, or 12 

> The information provided by a hybrid histogram is much better than that provided by a height-balanced histogram. For this reason, should be completely avoided.


#### extended statistics

Extensions can also be automatically created by the database engine.

For correlated columns
```oracle
country='Denmark' AND language='Danish'
```

> a hidden column, called an extension, is created, based on either an expression or a group of columns. Then regular object statistics and histograms are gathered on it.

Create
```oracle
SELECT dbms_stats.create_extended_stats(ownname   => user,
                                        tabname   => 'T',
                                        extension => '(upper(pad))') AS ext1,
       dbms_stats.create_extended_stats(ownname   => user,
                                        tabname   => 'T',
                                        extension => '(val2,val3)') AS ext2
FROM dual;
```

| EXT1 | EXT2 |
| :--- | :--- |
| SYS\_STU0KSQX64#I01CKJ5FPGFK3W9 | SYS\_STUPS77EFBJCOTDFMHM8CHP7Q1 |


Check histogram
```oracle
SELECT column_name, data_type, hidden_column, data_default
FROM user_tab_cols
WHERE table_name = 'T'
ORDER BY column_id;
```

You get

| COLUMN\_NAME                    | DATA\_TYPE | HIDDEN\_COLUMN | DATA\_DEFAULT                            |
|:--------------------------------|:-----------|:---------------|:-----------------------------------------|
| VAL2                            | NUMBER     | NO             | null                                     |
| VAL3                            | NUMBER     | NO             | null                                     |
| PAD                             | VARCHAR2   | NO             | null                                     |
| SYS\_STU0KSQX64#I01CKJ5FPGFK3W9 | VARCHAR2   | YES            | UPPER\("PAD"\)                           |
| SYS\_STUPS77EFBJCOTDFMHM8CHP7Q1 | NUMBER     | YES            | SYS\_OP\_COMBINED\_HASH\("VAL2","VAL3"\) |

> Because the extended statistics for a group of columns are based on a hash function (sys_op_combined_hash), they work only with predicates based on equality , not on BETWEEN and < or >. They are  used to estimate the cardinality of GROUP BY clauses and DISTINCT operator in SELECT clauses.

> It’s not necessarily a trivial thing deciding which group of columns it’s sensible to create an extension on. The following approach can be used 

Record usage
```oracle
CALL dbms_stats.seed_col_usage(sqlset_name => NULL,
                            owner_name  => NULL,
                            time_limit  => 30);
```

Query

The check result
```oracle
SELECT dbms_stats.report_col_usage(ownname => user, tabname => 't')
FROM dual;
```

2 patterns
```text
1. VAL1                                : EQ RANGE                              
2. VAL2                                : EQ                                    
```

### SQL plan directives

> Their purpose is to help the query optimizer cope with misestimates. To do so, they store in the data dictionary information about the expressions that cause misestimates. In some cases, SQL plan directives instruct the database engine to automatically create extended statistics (specifically, column groups). When extended statistics can’t be created, they instruct the query optimizer to use dynamic sampling.

```oracle
SELECT
    directive_id,state,created,last_modified,last_used
from dba_sql_plan_directives 
where 1=1
    AND state = 'USABLE'
--     AND directive_id=2183573658076085153
;



SELECT 
    object_type, object_name
FROM dba_sql_plan_dir_objects
WHERE 1=1
  AND owner = 'USERNAME'
  AND object_type = 'COLUMN'
```

### index statistics

```oracle
SELECT index_name AS name,
       blevel,
       leaf_blocks AS leaf_blks,
       distinct_keys AS dst_keys,
       num_rows,
       clustering_factor AS clust_fact,
       avg_leaf_blocks_per_key AS leaf_per_key,
       avg_data_blocks_per_key AS data_per_key
FROM user_ind_statistics
WHERE table_name = 'T';
```

| NAME       | BLEVEL | LEAF\_BLKS | DST\_KEYS | NUM\_ROWS | CLUST\_FACT | LEAF\_PER\_KEY | DATA\_PER\_KEY |
|:-----------|:-------|:-----------|:----------|:----------|:------------|:---------------|:---------------|
| T\_PK      | 1      | 2          | 1000      | 1000      | 977         | 1              | 1              |
| T\_VAL1\_I | 1      | 2          | 27        | 1000      | 491         | 1              | 18             |
| T\_VAL2\_I | 1      | 3          | 6         | 1000      | 180         | 1              | 30             |

> avg_leaf_blocks_per_key is the average number of leaf blocks that store a single key.

> clustering_factor indicates how many adjacent index entries don’t refer to the same data block in the table. 
> If the table and the index are sorted similarly, the clustering factor is low. The minimum value is the number of nonempty data blocks in the table. 
> If the table and the index are sorted differently, the clustering factor is high. The maximum value is the number of keys in the index

### partitions statistics

```oracle
CREATE TABLE partitions (id NUMBER, tstamp DATE, pad VARCHAR2(1000))
PARTITION BY RANGE (tstamp)
SUBPARTITION BY HASH (id)
SUBPARTITION TEMPLATE
(
  SUBPARTITION sp1,
  SUBPARTITION sp2,
  SUBPARTITION sp3,
  SUBPARTITION sp4
)
(
    PARTITION q1 VALUES LESS THAN (to_date('2014-04-01', 'YYYY-MM-DD')),
    PARTITION q2 VALUES LESS THAN (to_date('2014-07-01', 'YYYY-MM-DD')),
    PARTITION q3 VALUES LESS THAN (to_date('2014-10-01', 'YYYY-MM-DD')),
    PARTITION q4 VALUES LESS THAN (to_date('2015-01-01', 'YYYY-MM-DD'))
)
```

> For partitioned objects, the database engine is able to handle all object statistics discussed in the previous sections (in other words, table statistics, column statistics, histograms and index statistics) at the table/index-level as well as at the partition and subpartition levels. 
> Having object statistics at all levels is useful because, depending on the SQL statement to be processed, the query optimizer considers the object statistics that most closely describe the segments to be accessed. 
> Simply put, the query optimizer uses the partition and subpartition statistics only when, during the parse phase, it can determine whether a specific partition or subpartition is accessed. Otherwise, the query optimizer generally uses the table/index-level statistics.

### gather statistic


```oracle
gather_database_stats
gather_dictionary_stats
gather_schema_stats
gather_table_stats
gather_table_stats
```

> CREATE INDEX and ALTER INDEX statements automatically gather object statistics while building an index
> CTAS statements and direct-path inserts into empty tables automatically gather object statistics. 
> You can’t always rely, in every case, on the automatically gathered statistics.

3 parameters:
- target
- options
- backup

#### Staleness

> To recognize whether object statistics are stale, the database engine counts (approximately), for each table, the number of rows modified through SQL statements. 

```oracle
UPDATE t set val1=val1;
SELECT inserts, updates, deletes, truncated
FROM user_tab_modifications
WHERE table_name = 'T';
```

Object statistics are considered stale if at least 10 percent  (default) of the rows have been modified.

```oracle
SELECT DBMS_STATS.GET_PREFS('STALE_PERCENT') FROM dual;
```

#### Sample size
Valid values are decimal numbers between 0.000001 and 100.
```oracle
SELECT DBMS_STATS.GET_PREFS('estimate_percent') FROM dual;
```
DBMS_STATS.AUTO_SAMPLE_SIZE

> In fact, in most cases, using the default value not only gathers statistics that are more accurate than a sampling of, say, 10%, but it results in their being gathered more quickly. Some features (top frequency histograms, hybrid histograms, and incremental statistics) only work when dbms_stats.auto_sample_size is specified. 

#### Column usage history
> The query optimizer tracks which columns are referenced in the WHERE clause and stores the information it finds in the SGA. Then, at regular intervals, the database engine stores this information in the data dictionary table col_usage$

```oracle
SELECT c.name, cu.timestamp,
        cu.equality_preds AS equality, cu.equijoin_preds AS equijoin,
        cu.nonequijoin_preds AS noneequijoin, cu.range_preds AS range,
        cu.like_preds AS "LIKE", cu.null_preds AS "NULL"
 FROM sys.col$ c, sys.col_usage$ cu, sys.obj$ o, dba_users u
 WHERE c.obj# = cu.obj# (+)
 AND c.intcol# = cu.intcol# (+)
 AND c.obj# = o.obj#
 AND o.owner# = u.user_id
AND o.name = 'T'
AND u.username = user
ORDER BY c.col#;
```

Human-readable
> if the function seed_col_usage isn’t used, the report returned by the report_col_usage function won’t contain information about potential column groups
```oracle
SELECT dbms_stats.report_col_usage(ownname => user, tabname => 't')
FROM dual;
```

You can reset using  `reset_col_usage`

#### concurrent

`degree` parameter : degree of parallelism used while gathering statistics for a **single** object.
> Note that the processing of several objects is serialized except when concurrent statistics gathering is used. This means parallelization is useful only for speeding up the gathering of statistics on large objects

#### set statistics params

>  you can set the global defaults, you can also set defaults at the table level

These are parameter, not statistics:
- autostats_target
- cascade
- concurrent
- estimate_percent
- degree
- method_opt
- no_invalidate
- granularity
- publish
- incremental
- stale_percent
- table_cached_blocks
- global_temp_table_stats
- incremental_staleness
- incremental_level

#### temporary table

You must gather statistic for GTT manually

> if session statistics are used (which is the default for global temporary tables), every session can gather a set of object statistics that won’t be visible to other sessions.

#### delay publication

> Usually, as soon as the gathering is finished, the object statistics are published  to the query optimizer. This means that it’s not possible (for testing purposes, for instance) to gather statistics without overwriting the current object statistic.

> It’s possible to separate gathering statistics from publishing them, and it’s possible to use objects statistics that are unpublished, which are called pending statistics, for testing purposes.  

Disable automatic publish
```oracle
CALL dbms_stats.set_table_prefs(ownname => user,
                           tabname => 'T',
                           pname   => 'PUBLISH',
                           pvalue  => 'FALSE')
```

Gather stats
```oracle
CALL dbms_stats.gather_table_stats(ownname => user, tabname => 'T')
```

Check stats gathered
```oracle
user_tab_pending_stats
user_ind_pending_stats
user_col_pending_stats 
user_tab_histgrm_pending_stats 
```

Then :
- session level: set the `optimizer_use_pending_statistics` initialization parameter to TRUE 
- SQL level: use the opt_param('optimizer_use_pending_statistics' 'true') hint

If statistics are worthwhile, publish
```oracle
EXEC dbms_stats.publish_pending_stats(ownname => user, tabname => 'T')
```

If not, delete
```oracle
dbms_stats.delete_pending_stats(ownname => user, tabname => 'T')
```

Reactivate automatic publishing
```oracle
EXEC dbms_stats.set_table_prefs(ownname => user,
                           tabname => 'T',
                           pname   => 'PUBLISH',
                           pvalue  => 'TRUE')
```

####  on partitions

> 2 ways:
> - global statistics : gather object statistics at the object, partition, and, if available, subpartition level by means of queries that are independently executed at each level => more resources to gather
> - derived statistics : gather object statistics at the physical level only (either the partition or subpartition level) and use those results to derive the object statistics for the other levels.

> Whenever possible, the dbms_stats package gathers global statistics. It gathers derived statistics only when, for example, the gathering granularity is explicitly limited to the subpartition level and no object statistics are available at the partition and table/index level.


Check which is used
```oracle
SELECT global_stats
FROM user_tab_col_statistics
WHERE table_name = 'T'
AND column_name = 'VAL1';
```

##### incremental

> In practice, therefore, for big tables it’s important to find a good balance between the required accuracy and the time and resources needed to achieve it. The goal of incremental statistics is to offer the same accuracy than global, and lowering the time and resources required to gather object statistics.

Set incremental
```oracle
EXEC dbms_stats.set_table_prefs(ownname => user,
                           tabname => 't',
                           pname   => 'incremental',
                           pvalue  => 'TRUE');
```

And gather new object statistics on all partitions.

> Then dbms_stats package uses the monitoring information to know which partition (or subpartition) was modified and, therefore, requires new object statistics.

##### copy

> In situations where partitions are frequently added and their content changes significantly over time, keeping a representative set of partition level statistics requires very frequent gatherings. 
 
> These frequent gatherings represent significant overhead in terms of resource utilization. In addition, under normal conditions, it’s not good to leave a recently added partition without object statistics. Doing so leads to dynamic sampling.

> To cope with such issues, the dbms_stats package, through the copy_table_stats procedure, provides the functionality to copy object statistics from one partition or subpartition to another. Note that the copy takes care of column statistics as well as dependent objects like subpartitions and local indexes.

```oracle
EXEC dbms_stats.copy_table_stats(ownname      => user,
                            tabname      => 't',
                            srcpartname  => 'p_2014_q1',
                            dstpartname  => 'p_2015_q1',
                            scale_factor => 1);
```


#### Scheduling

> the gathering is integrated in the automated maintenance tasks. 

```oracle
SELECT task_name, status
FROM dba_autotask_task
WHERE client_name = 'auto optimizer stats collection';
```

```oracle
SELECT program_action, number_of_arguments, enabled
FROM dba_scheduler_programs
WHERE owner = 'SYS'
AND program_name = 'GATHER_STATS_PROG';
```

```oracle
SELECT window_group
FROM dba_autotask_client
WHERE client_name = 'auto optimizer stats collection';
```

```oracle
SELECT w.window_name, w.repeat_interval, w.duration, w.enabled
FROM dba_autotask_window_clients c, dba_scheduler_windows w
WHERE c.window_name = w.window_name
AND c.optimizer_stats = 'ENABLED';
```

Enable
```oracle
CALL dbms_auto_task_admin.enable(client_name => 'auto optimizer stats collection',
                            operation   => NULL,
                            window_name => NULL);
```

Disable
```oracle
CALL dbms_auto_task_admin.disable(client_name => 'auto optimizer stats collection',
                             operation   => NULL,
                             window_name => NULL)
```

### Restore statistics 

> Whenever object statistics are gathered through the dbms_stats package or through the ALTER INDEX statement, instead of simply overwriting current statistics with the new statistics, the current statistics are saved in other data dictionary tables that keep a history of all changes occurring within a retention period. 
> The purpose is to be able to restore old statistics in case new statistics lead to inefficient execution plans.


Get retention
```oracle
SELECT dbms_stats.get_stats_history_retention() AS retention FROM dual;
CALL dbms_stats.alter_stats_history_retention(retention => 14);
```
31 days

Get history
```oracle
SELECT table_name, stats_update_time
FROM dba_tab_stats_history
WHERE 1=1
  AND owner = 'USERNAME' 
--   and table_name = 'T'
ORDER bY table_name ASC
```

restore 
- for a user you can do at table level)
- at point-in-time
```oracle
dbms_stats.restore_schema_stats(ownname         => 'USERNAME',
                                as_of_timestamp => systimestamp – INTERVAL '1' DAY,
                                force           => TRUE)
```

### Locking Object Statistics

> In some situations, you want to make sure that object statistics for part of the database aren’t available or can’t be changed, either because 
> - you want to use dynamic sampling
> - you have to use object statistics that aren’t up-to-date (for example, because the content of some tables changes very frequently and you want to carefully gather stats only when the table contains a representative set of rows)
> - because gathering statistics isn’t possible (for example, because of bugs).

Lock
```oracle
CALL dbms_stats.lock_table_stats(ownname => user, tabname => 'T');
```

Unlock
```oracle
CALL dbms_stats.unlock_table_stats(ownname => user, tabname => 'T');
```

> Most procedures that modify object statistics can override the lock by setting the force parameter to TRUE.

Get locks
```oracle
SELECT table_name
FROM user_tab_statistics
WHERE stattype_locked IS NOT NULL;
```

> CREATE/ALTER INDEX, when the object statistics of a table are locked, may behave differently or even fail.

### Compare statistics

> To know the differences between two sets of object statistics

```oracle
EXEC dbms_stats.diff_table_stats_in_stattab(ownname      => user,
                                       tabname      => 'T',
                                       stattab1     => 'MYSTATS',
                                       statid1      => 'SET1',
                                       stattab1own  => user,
                                       pctthreshold => 10)
```

### delete 

> Except for testing purposes, this is usually not necessary. Nevertheless, it might happen that a table shouldn’t have object statistics because you want to take advantage of dynamic sampling

```oracle
delete_database_stats
delete_dictionary_stats
delete_fixed_objects_stats
delete_schema_stats
delete_table_stats
delete_column_stats
delete_index_stats.
```

For a column
```oracle
EXEC dbms_stats.delete_column_stats(ownname       => user,
                               tabname       => 'T',
                               colname       => 'VAL',
                               col_stat_type => 'HISTOGRAM')
```

### log

Operations
```oracle
SELECT operation, start_time,
       (end_time-start_time) DAY(1) TO SECOND(0) AS duration,
       parameter

FROM dba_optstat_operations
ORDER BY start_time DESC;
```

Parameters (not XML)
```oracle
SELECT x.*
FROM dba_optstat_operations o,
     XMLTable('/params/param'
              PASSING XMLType(notes)
              COLUMNS name VARCHAR2(20) PATH '@name',
                      value VARCHAR2(30) PATH '@val') x
WHERE operation = 'gather_database_stats (auto)'
AND start_time = (SELECT max(start_time)
                  FROM dba_optstat_operations
                  WHERE operation = 'gather_database_stats (auto)');
```

### conclusion

> The question is, how and when should you use them to achieve a successful configuration? Answering this question is difficult. Probably no definitive answer exists.

#### perimeter


> The general rule, and probably the most important one, is that the query optimizer needs object statistics that describe the data stored in the database.
>
> As a result, when data changes, object statistics should change as well. 
> For example, one statistic that commonly changes is the low/high value of columns that contain data such as a timestamp associated to a transaction, a sale, or a phone call. True, not many of them change in typical tables, but usually those that do change are critical because they’re used over and over again in the application. In practice, I run into many more problems caused by object statistics that aren’t up-to-date than the other way around.

> Only stale object statistics should be regathered. Therefore, it’s essential to take advantage of the feature that logs the number of modifications occurring to each table. In this way, you regather object statistics only for those tables experiencing substantial modifications.

#### frequency

> In any case, when the staleness of the tables is used as a basis to regather object statistics, intervals that are too long can lead to an excess of stale objects, which in turn leads to excessive time required for statistics gathering and a peak in resource usage. 
> For this reason, I like to schedule them frequently (to spread out the load) and keep single runs as short as possible. 

> If you have jobs that load or modify lots of data (for example, the ETL jobs in a data warehouse environment), you shouldn’t wait for a scheduled gathering of object statistics. Simply make the gathering of statistics for the modified objects part of the job itself. 

#### problems ?

>If gathering statistics leads to inefficient execution plans, you can do two things. 
 
> The first is to fix the problem by restoring the object statistics that were successfully in use before gathering statistics. 

> The second is to find out why inefficient execution plans are generated by the query optimizer with the new object statistics. To do this, you should first check whether the newly gathered statistics correctly describe the data. For example, it’s possible that sampling along with a new data distribution will lead to different histograms. If object statistics aren’t good, then the gathering itself, or possibly a parameter used for their gathering, is the problem. If the object statistics are in fact good, there are two more possible causes. Either the query optimizer isn’t correctly configured or the query optimizer is making a mistake. You have little control over the latter, but you should be able to find a solution for the former. 
> In any case, you should avoid thinking too hastily that gathering object statistics is inherently problematic and, as a result, stop gathering them regularly.

> In other words, if you know something that the dbms_stats package ignores or isn’t able to discover, it’s legitimate to inform the query optimizer by fudging the object statistics.

## configure optimizer

> In fact, without an optimal configuration, the query optimizer may generate inefficient execution plans that lead to poor performance.