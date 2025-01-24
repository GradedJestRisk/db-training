# Join

> From a conceptual point of view, a SQL statement containing join conditions and restrictions is executed in the following way:
> - the two sets of data are joined, based on the join conditions.
> - the restrictions are applied (to the result set returned by the join)

> From an implementation point of view, it’s not unusual that the query optimizer takes advantage of both 
> - restrictions
> - join conditions. 
> On the one hand, join conditions might be used to filter out data. On the other hand, restrictions might be evaluated before join conditions to minimize the amount of data to be joined.

```oracle
SELECT emp.ename
FROM emp, dept
WHERE emp.deptno = dept.deptno
AND dept.loc = 'DALLAS'
```

Here, the restriction (`dept.loc = 'DALLAS') is applied before the join
```text
-----------------------------------
| Id  | Operation          | Name |
-----------------------------------
|   0 | SELECT STATEMENT   |      |
|*  1 |  HASH JOIN         |      |
|*  2 |   TABLE ACCESS FULL| DEPT |
|   3 |   TABLE ACCESS FULL| EMP  |
-----------------------------------
 
   1 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
   2 - filter("DEPT"."LOC"='DALLAS')
```

## nested loops

### description

The two sets of data processed by a nested loops join are called 
- outer loop (also known as driving row source), which is left input (as executed first)
- inner loop : right input

the outer loop is executed once
for each row returned by it, the inner loop is executed once 

characteristics:
- left input executed only once, right input is potentially executed many times.
- able to return the first row of the result set **before** completely processing all rows
- can take advantage of indexes to apply both restrictions and join conditions
- support all types of joins


### basic

hint: `leading($TABLE_OUTER $TABLE_INNER) use_nl($TABLE_INNER)` - `nl` stands for **n**ested **l**oops

Here the restriction has been applied before the join
```text
SELECT /*+ leading(t1 t2) use_nl(t2) full(t1) full(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19
 
-----------------------------------
| Id  | Operation          | Name |
-----------------------------------
|   0 | SELECT STATEMENT   |      |
|   1 |  NESTED LOOPS      |      |
|*  2 |   TABLE ACCESS FULL| T1   |
|*  3 |   TABLE ACCESS FULL| T2   |
-----------------------------------
 
   2 - filter("T1"."N"=19)
   3 - filter("T1"."ID"="T2"."T1_ID")
```

So:
> - all rows in table t1 are read through a full scan
> - the n = 19 restriction is applied.
> - (as many times as the number of rows returned by the previous step)
>   - The full scan of table t2 is executed
>   - data are filtered out
>   - the join condition is applied

> Clearly, when operation 2 (TABLE ACCESS FULL) returns more than one row, the previous execution plan is inefficient and, therefore, almost never chosen by the query optimizer. For this reason, to produce this specific example, specifying two access hints (full) is necessary to force the query optimizer to use this execution plan. 

> On the other hand
> - if the outer loop returns a single row 
> - and the selectivity of the inner loop is weak
> the full scan of table t2 might be good

```text
SELECT /*+ full(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19
 
---------------------------------------------
| Id  | Operation                    | Name |
---------------------------------------------
|   0 | SELECT STATEMENT             |      |
|   1 |  NESTED LOOPS                |      |
|   2 |   TABLE ACCESS BY INDEX ROWID| T1   |
|*  3 |    INDEX UNIQUE SCAN         | T1_N |
|*  4 |   TABLE ACCESS FULL          | T2   |
---------------------------------------------

3 - access("T1"."N"=19)
4 - filter("T1"."ID"="T2"."T1_ID")
```

If the selectivity is strong, using an index scan makes sense. 
So if the inner loop join condition field selectivity is strong, the index will be used as access path, and the rows need not be filtered out afterwards.

Below operation 5 has no filtering
```text
SELECT /*+ ordered use_nl(t2) index(t1) index(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19
 
-------------------------------------------------
| Id  | Operation                    | Name     |
-------------------------------------------------
|   0 | SELECT STATEMENT             |          |
|   1 |  NESTED LOOPS                |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| T1       |
|*  3 |    INDEX UNIQUE SCAN         | T1_N     |
|   4 |   TABLE ACCESS BY INDEX ROWID| T2       |
|*  5 |    INDEX RANGE SCAN          | T2_T1_ID |
-------------------------------------------------
 
   3 - access("T1"."N"=19)
   5 - access("T1"."ID"="T2"."T1_ID")
```

Ideal case:
 - outer loop : does not return too many rows 
 - inner loop :
   - few rows in table 
   - if many rows: access paths with strong selectivity, very few logical reads

### left-deep join 

```text
SELECT /*+ ordered use_nl(t2 t3 t4) */ t1.*, t2.*, t3.*, t4.*
FROM t1, t2, t3, t4
WHERE t1.id = t2.t1_id
AND t2.id = t3.t2_id
AND t3.id = t4.t3_id
AND t1.n = 19
 
---------------------------------------------------
| Id  | Operation                      | Name     |
---------------------------------------------------
|   0 | SELECT STATEMENT               |          |
|   1 |  NESTED LOOPS                  |          |
|   2 |   NESTED LOOPS                 |          |
|   3 |    NESTED LOOPS                |          |
|   4 |     TABLE ACCESS BY INDEX ROWID| T1       |
|*  5 |      INDEX RANGE SCAN          | T1_N     |
|   6 |     TABLE ACCESS BY INDEX ROWID| T2       |
|*  7 |      INDEX RANGE SCAN          | T2_T1_ID |
|   8 |    TABLE ACCESS BY INDEX ROWID | T3       |
|*  9 |     INDEX RANGE SCAN           | T3_T2_ID |
|  10 |   TABLE ACCESS BY INDEX ROWID  | T4       |
|* 11 |    INDEX RANGE SCAN            | T4_T3_ID |
---------------------------------------------------
 
   5 - access("T1"."N"=19)
   7 - access("T1"."ID"="T2"."T1_ID")
   9 - access("T2"."ID"="T3"."T2_ID")
  11 - access("T3"."ID"="T4"."T3_ID")
```

If row prefetching is disabled:
- outer loop, loop 1 : the first rows that satisfies `t1.n = 19` is returned
- inner loop 1, loop 1 : the first row returned by access path called by parent loop row is fetched
- inner loop 2, loop 1 : the first row returned by access path called by parent loop row is fetched
- inner loop 2, loop 1 : the first row returned by access path called by parent loop row is fetched
- the first row of the result set is ready, and sent immediately to the client
>- the processing is restarted from the position following the last match (that could be the second row that matches in table t4, if any)

### buffer cache prefetches

> Basically, each access path (eg. index), except for full scans, leads to single-block physical reads - in the event of a cache miss. 
> For nested loops joins, especially when many rows are processed, these single-block reads can be very inefficient. In fact, it’s not unusual for nested loops joins to access blocks with many single-block physical reads.

> To improve the efficiency of nested loops joins, the database engine is able to take advantage of optimization techniques that substitute single-block physical reads with multiblock physical reads. 
> Three features use such an approach : 
>  - table prefetching
>  - batching
>  - buffer cache prewarm

Notice the 2 nested loops, instead of 1
```text
--------------------------------------------------
| Id  | Operation                     | Name     |
--------------------------------------------------
|   0 | SELECT STATEMENT              |          |
|   1 |  NESTED LOOPS                 |          |
|   2 |   NESTED LOOPS                |          |
|   3 |    TABLE ACCESS BY INDEX ROWID| T1       |
|*  4 |     INDEX RANGE SCAN          | T1_N     |
|*  5 |    INDEX RANGE SCAN           | T2_T1_ID |
|   6 |   TABLE ACCESS BY INDEX ROWID | T2       |
--------------------------------------------------
 
   4 - access("T1"."N"=19)
   5 - access("T1"."ID"="T2"."T1_ID")
```

> Looking at an execution plan can’t tell you whether the database engine actually uses table prefetching or batching. The fact is, even though the query optimizer produces an execution plan that can take advantage of either table prefetch or batching, it’s the execution engine that decides whether using that plan is sensible. 

> The only way to know whether an optimization technique is used is to look at the physical reads performed by the server process—specifically, the wait events associated with them:
> - `db file sequential read` event is associated with single-block physical reads. Therefore, if it occurs, either no optimization technique took place or one was not needed (for example, because the required blocks are already in the buffer cache).
> - `db file scattered read` and `db file parallel read` events are associated with multiblock physical reads. The difference between the two is that the former is used for physical reads of adjacent blocks, and the latter is used for physical reads of nonadjacent blocks. 
> Therefore, if one of them occurs for rowid accesses or index range scans, it means that an optimization technique took place.

## merge join

### description

> In the general case :
> - both sets of data are read 
> - and sorted according to the columns of the join condition. 
> - the data contained in the two work areas is merged

Characteristics:
> - The left input is executed only once.
> - The right input is executed at most once (in the event the left input doesn’t return any row, the right input isn’t executed at all)
> - the data returned by both inputs must be sorted according to the columns of the join condition ( except when a Cartesian product is executed)
> -  when data is sorted, both inputs must be fully read and sorted before returning the first row of the result set.
> -  all types of joins are supported

> Merge joins aren’t used very often. The reason is that in most situations either nested loops joins or hash joins perform better than merge joins.

### basic

> It’s interesting to notice in the previous execution plan that the join condition is applied by the SORT JOIN operation of the right input, not by the MERGE JOIN operation as you might expect. This is because for each row returned by the left input, the MERGE JOIN operation accesses the memory structure associated to the right input to check whether rows fulfilling the join condition exist.

TODO: I don't understand. Which does check the join condition ? `SORT JOIN` or `MERGE JOIN` ? 

> The MERGE JOIN operation is of type unrelated combine. This means the two children are processed at most once and independently of each other. The most important limitation of the MERGE JOIN operation (like for the other unrelated-combine operations) is its inability to take advantage of indexes to apply join conditions. In other words, indexes can be used only as an access path to evaluate restrictions (if specified) before sorting the inputs.

The join condition is based on equality implemented by walking a sorted collection.
This collection is not indexed, as it is now in a temporary work area (not in the table anymore) for which indexes wouldn't make sense.

```text
SELECT /*+ ordered use_merge(t2) */ *
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19
 
------------------------------------
| Id  | Operation           | Name |
------------------------------------
|   0 | SELECT STATEMENT    |      |
|   1 |  MERGE JOIN         |      |
|   2 |   SORT JOIN         |      |
|*  3 |    TABLE ACCESS FULL| T1   |
|*  4 |   SORT JOIN         |      |
|   5 |    TABLE ACCESS FULL| T2   |
------------------------------------
 
   3 - filter("T1"."N"=19)
   4 - access("T1"."ID"="T2"."T1_ID")
       filter("T1"."ID"="T2"."T1_ID")
```

> To execute merge joins, a non-negligible amount of resources may be spent on sort operations. To improve performance, the query optimizer avoids performing sort operations whenever it saves resources. But of course, this is possible only when the data is already sorted according to the columns used as the join condition. 
> That happens in two situations:
> - when an index range scan taking advantage of an index built on the columns used as the join condition is used
> - when a step preceding the merge join (for example, another merge join) already sorted the data in the right order

No more `SORT JOIN`
```text
----------------------------------------------
| Id  | Operation                    | Name  |
----------------------------------------------
|   0 | SELECT STATEMENT             |       |
|   1 |  MERGE JOIN                  |       |
|*  2 |   TABLE ACCESS BY INDEX ROWID| T1    |
|   3 |    INDEX FULL SCAN           | T1_PK |
|*  4 |   SORT JOIN                  |       |
|   5 |    TABLE ACCESS FULL         | T2    |
----------------------------------------------
 
   2 - filter("T1"."N"=19)
   4 - access("T1"."ID"="T2"."T1_ID")
       filter("T1"."ID"="T2"."T1_ID")
```

> An important caveat about execution plans such as the previous one is that, because no sort operation takes place for the left input, no work area is associated to it. As a result, there’s no place to store data resulting from the left input while the right input is executed. The processing of the previous execution plan can be summarized as follows:
> - A first batch of rows is extracted from the t1 table through the t1_pk index. It’s essential to understand that this first batch contains all rows only when the result set is very small. Remember, there’s no work area to temporarily store many rows.
> - Provided the previous step returns some data, all rows in the t2 table are read through a full scan, sorted according to the columns used as the join condition, and stored in the work area, possibly spilling temporary data to the disk.
> - The two sets of data are joined together, and the resulting rows are r/eturned. 
> - When the first batch of rows extracted from the left input has been completely processed
>   - more rows are extracted from the t1 table, if necessary,
>   - and joined to the data of the right input already present in a work area.

The join order (`leading` hint) is important to avoid sort 
> The same doesn’t apply to the right input even though the access path of the right input returns data in the correct order, the data has to go through a SORT JOIN operation, because the MERGE JOIN operation needs to access the memory structure associated to the right input to check whether rows fulfilling the join condition exist. And that access must be performed in a memory structure that not only contains the data in a specific order, but also allows performing efficient lookups based on the join condition.

Here the right input can be read sorted from the index (`INDEX FULL SCAN`), but it would lack the lookup-optimized features.

### work areas

> To process a merge join, up to two work areas in memory are used to sort data.
> Two types of sort:
> - in-memory sort: the sort is completely processed in memory
> - on-dist sort: the sort needs to spill temporary data to the disk


#### in-memory sort
> all data must be loaded into the work area, not only the columns referenced as the join condition. Therefore, to avoid wasting a lot of memory, only the columns that are really necessary should be referenced in the SELECT clause. 

> In the following example, all columns in all tables are referenced in the SELECT clause. 

work areas usage : 
- OMem : estimated amount of memory needed for an in-memory sort (if the actual number of rows match the expected)
- Used-Mem: actual amount of memory used by the operation during execution 
- (0) : means that the sorts were fully processed in memory

The sorts were fully processed in memory here.
```text

SELECT t1.*, t2.*, t3.*, t4.*
FROM t1, t2, t3, t4
WHERE t1.id = t2.t1_id
AND t2.id = t3.t2_id
AND t3.id = t4.t3_id
AND t1.n = 19
 
-----------------------------------------------------------
| Id  | Operation               | Name |  OMem | Used-Mem |
-----------------------------------------------------------
|   0 | SELECT STATEMENT        |      |       |          |
|   1 |  MERGE JOIN             |      |       |          |
|   2 |   SORT JOIN             |      | 34816 |30720  (0)|
|   3 |    MERGE JOIN           |      |       |          |
|   4 |     SORT JOIN           |      |  5120 | 4096  (0)|
|   5 |      MERGE JOIN         |      |       |          |
|   6 |       SORT JOIN         |      |  3072 | 2048  (0)|
|*  7 |        TABLE ACCESS FULL| T1   |       |          |
|*  8 |       SORT JOIN         |      | 21504 |18432  (0)|
|   9 |        TABLE ACCESS FULL| T2   |       |          |
|* 10 |     SORT JOIN           |      |   160K|  142K (0)|
|  11 |      TABLE ACCESS FULL  | T3   |       |          |
|* 12 |   SORT JOIN             |      |  1045K|  928K (0)|
|  13 |    TABLE ACCESS FULL    | T4   |       |          |
-----------------------------------------------------------
```

#### on-disk sort

- the data is read from the table and stored in the work area
- a structure is built that organizes the data according to the sort criteria
- when the work area is full, **part** of its content is spilled into a temporary segment in the user’s temporary tablespace. This type of data batch is called a sort run
- continue reading / storing / sorting the input data in the work area, an another sort run is stored in the temporary segment
- when all data has been sorted merge it (each sort run is sorted independently of each other).
  - read back head of each sort run in the work area
  - as soon as some data sorted in the right way is available, it can be returned to the parent operation.

> Here, the data has been written and read into/from the temporary segment only once. This type of sort is called a **one-pass sort**. 
> When the size of the work area is much smaller than the amount of data to be sorted, several merge phases are necessary. In such a situation, the data is written and read into/from the temporary segment several times. This kind of sort is called a **multipass **.

To know which pass-type occurred:
- 1Mem : estimated amount of memory needed for a one-pass sort
- Used-Tmp: actual size of the temporary segment (Mb, not B) used by the operation during the execution
- Used-Mem(X): X is number of passes

```text
-----------------------------------------------------------------------------
| Id  | Operation               | Name |  OMem |  1Mem | Used-Mem | Used-Tmp|
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |      |       |       |          |         |
|   1 |  MERGE JOIN             |      |       |       |          |         |
|   2 |   SORT JOIN             |      | 34816 | 34816 |30720  (0)|    1024 |
|   3 |    MERGE JOIN           |      |       |       |          |         |
|   4 |     SORT JOIN           |      |  5120 |  5120 | 4096  (0)|         |
|   5 |      MERGE JOIN         |      |       |       |          |         |
|   6 |       SORT JOIN         |      |  3072 |  3072 | 2048  (0)|         |
|*  7 |        TABLE ACCESS FULL| T1   |       |       |          |         |
|*  8 |       SORT JOIN         |      |  9216 |  9216 |18432  (0)|    1024 |
|   9 |        TABLE ACCESS FULL| T2   |       |       |          |         |
|* 10 |     SORT JOIN           |      |    99K|    99K|32768  (1)|    1024 |
|  11 |      TABLE ACCESS FULL  | T3   |       |       |          |         |
|* 12 |   SORT JOIN             |      |   954K|   532K|41984  (9)|    2048 |
|  13 |    TABLE ACCESS FULL    | T4   |       |       |          |         |
-----------------------------------------------------------------------------
```

## hash join

### description

> The two sets of data processed by a hash join are called 
> - build input: left input
> - probe input: right input
   
> Using every row of the build input, a hash table in memory (also using temporary space, if not enough memory is available) is built. The hash key used for that purpose is computed based on the columns used as the join condition. 
> Once the hash table contains all data from the build input, the processing of the probe input begins. Every row is probed against the hash table to find out whether it fulfills the join condition. Obviously, only matching rows are returned.


> Characteristics:
> - the build input is executed only once.
> - the probe input is executed at most once (not at all if the build input doesn’t return any row)
> - the hash table is built on the build input only (smallest is better)
> - before returning the first row, only the build input must be fully processed.
> - cross joins, theta joins, and partitioned outer joins aren’t supported.


### basic

```text
SELECT /*+ leading(t1 t2) use_hash(t2) */ 
*
FROM t1, t2
WHERE t1.id = t2.t1_id
AND t1.n = 19
 
-----------------------------------
| Id  | Operation          | Name |
-----------------------------------
|   0 | SELECT STATEMENT   |      |
|*  1 |  HASH JOIN         |      |
|*  2 |   TABLE ACCESS FULL| T1   |
|   3 |   TABLE ACCESS FULL| T2   |
-----------------------------------
 
   1 - access("T1"."ID"="T2"."T1_ID")
   2 - filter("T1"."N"=19)
```

HASH JOIN operation is of  type unrelated combine. This means that the two children are processed at most once and independently of each other. 

Process:
- all rows of table t1 are read through a full scan, the n = 19 restriction is applied
- a hash table is built with the resulting rows : a hash function is applied to the columns used as the join condition (id).
- all rows of table t2 are read through a full scan
- the hash function is applied to the columns used as the join condition (t1_id)
- the hash table is probed (operation 1 `access`) : if a match is found, the resulting row is returned.

> The most important limitation of the HASH JOIN operation (as for other unrelated-combine operations) is the inability to take advantage of indexes to apply join conditions. This means that indexes can be used as the access path only if restrictions are specified.


### right-deep

> One peculiar property of hash joins is that they also support right-deep and zig-zag trees.

```text
SELECT /*+ leading(t3 t4 t2 t1) use_hash(t1 t2 t4) swap_join_inputs(t1)
           swap_join_inputs(t2) */ t1.*, t2.*, t3.*, t4.*
FROM t1, t2, t3, t4
WHERE t1.id = t2.t1_id
AND t2.id = t3.t2_id
AND t3.id = t4.t3_id
AND t1.n = 19
 
-------------------------------------
| Id  | Operation            | Name |
-------------------------------------
|   0 | SELECT STATEMENT     |      |
|*  1 |  HASH JOIN           |      |
|*  2 |   TABLE ACCESS FULL  | T1   |
|*  3 |   HASH JOIN          |      |
|   4 |    TABLE ACCESS FULL | T2   |
|*  5 |    HASH JOIN         |      |
|   6 |     TABLE ACCESS FULL| T3   |
|   7 |     TABLE ACCESS FULL| T4   |
-------------------------------------
 
   1 - access("T1"."ID"="T2"."T1_ID")
   2 - filter("T1"."N"=19)
   3 - access("T2"."ID"="T3"."T2_ID")
   5 - access("T3"."ID"="T4"."T3_ID")
```

> One of the differences between left-deep tree and right-deep tree is the number of active work areas (hash tables) that are being used at a given time. 
> - left-deep tree, at most two work areas are used at the same time. In addition, when the last table is processed, only a single work area is needed. 
> - right-deep tree, during almost the entire execution a number of work areas (that is equal to the number of joins) are allocated and probed. 
> Another difference is the size of their work areas. 
> -  right-deep tree work areas contain data from a single table
> -  left-deep tree work areas can contain data resulting from the join of several tables. Therefore, the size of the left-deep tree work areas varies depending on whether the joins restrict the amount of data that’s returned.

### follow memory usage

```oracle
select count(1) from simple_table;
```
```oracle
EXPLAIN PLAN FOR
SELECT /*+ leading(t1 t2) use_hash(t2) */ *
FROM simple_table t1
    INNER JOIN simple_table t2 ON t1.id <> t2.id
```

```oracle
SELECT * 
FROM table(dbms_xplan.display);
SELECT *
FROM
    table(dbms_xplan.display_cursor('0jnwmfd1bhdkv', 0));
```

```oracle
SELECT operation_id, operation_type, actual_mem_used, tempseg_size, tablespace
FROM v$session s, v$sql_workarea_active w
WHERE 1=1
    AND s.sid = w.sid
    AND s.sid = 193 
ORDER BY operation_id;
```

## index join

> Index joins can be executed only with hash joins. Because of this, they can be considered a special case of hash joins. Their purpose is to avoid expensive table scans by joining two or more indexes belonging to the same table. 
> This may be very useful when a table has many indexed columns and few of them are referenced by a SQL statement. 

Here, a join is executed on the dataset returned by index 
- id 
- n

No table access by rowid is done at all.
```text
SELECT /*+ index_join(t4 t4_n t4_pk) */ id, n
FROM t4
WHERE id BETWEEN 10 AND 20
AND n < 100
 
-----------------------------------------------
| Id  | Operation          | Name             |
-----------------------------------------------
|   0 | SELECT STATEMENT   |                  |
|*  1 |  VIEW              | index$_join$_001 |
|*  2 |   HASH JOIN        |                  |
|*  3 |    INDEX RANGE SCAN| T4_N             |
|*  4 |    INDEX RANGE SCAN| T4_PK            |
-----------------------------------------------
 
   1 - filter("ID"<=20 AND "N"<100 AND "ID">=10)
   2 - access(ROWID=ROWID)
   3 - access("N"<100)
```

### choosing the join method

To choose a join method, you must consider the following issues:
- optimizer goal—that is, first-rows and all-rows optimization
- type of join to be optimized and the selectivity of the predicates
- whether to execute the join in parallel