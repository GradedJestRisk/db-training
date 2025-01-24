# Data access

> The most efficient access path is able to process the data by consuming the least amount of resources. Therefore, to recognize whether an access path is efficient, you have to recognize whether the amount of resources used for its processing is acceptable. 
> To do so, it’s necessary to define both 
> - how to measure the utilization of resources 
> - what “acceptable” means
> - how much effort is needed to implement a check

> Keep in mind that this section focuses on efficiency, not on speed alone. It’s essential to understand that the most efficient access path isn’t always the fastest one. With parallel processing, it’s sometimes possible to achieve a better response time even though the amount of resources used is higher. Of course, when you consider the whole system, the fewer resources used by SQL statements (in other words, the higher their efficiency is), the more scalable, and faster, the system is. This is true because, by definition, resources are limited.

> In an ideal world, you would like to measure the resource consumption by considering all four main types of resources used by the database engine: CPU, memory, the disk, and the network. Certainly, this can be done, but unfortunately getting and assessing all these figures takes a lot of time and effort and can usually be done only for a limited number of SQL statements in an optimization session. 

> As a first approximation, the amount of resources used by an access path is acceptable when it’s proportional to the amount of returned rows (that is, the number of rows that are returned to the parent operation in the execution plan). In other words, when few rows are returned, the expected utilization of resources is low, and when lots of rows are returned, the expected utilization of resources is high. Consequently, the check should be based on the amount of resources used to return a single row.

> It’s, in fact, not uncommon at all to see long-running SQL statements that use a modest amount of memory and are without disk or network access.

> Fortunately, there’s a single database metric, which is very easy to collect, that can tell you a lot about the amount of work done by the database engine: the number of logical reads—that is, the number of blocks that are accessed during the execution of a SQL statement. 

## metric: logical reads

### Metrics

> Fortunately, there’s a single database metric, which is very easy to collect, that can tell you a lot about the amount of work done by the database engine: the number of logical reads—that is, the number of blocks that are accessed during the execution of a SQL statement. There are five good reasons for this
> - First, a logical read is a CPU-bound operation and, therefore, reflects CPU utilization very well.
> - Second, a logical read might lead to a physical read, and therefore, if you reduce the number of logical reads, you likely reduce the disk I/O operations as well. Third, a logical read is an operation subject to serialization. Because you usually have to optimize for a multiuser load, minimizing the logical reads is good for avoiding scalability problems.
> - Fourth, the number of logical reads is readily available at the SQL statement and execution plan operation levels, in both SQL trace files and dynamic performance views.  - Fifth, the number of logical reads is independent of the load to which the CPU and the disk I/O subsystem are subject.

> TLDR: Logical reads are very good at approximating overall resource consumption
> Check should be based on the amount of resources used to return a single row.


> You can concentrate (at least for the first round of optimization) on access paths that have a high number of logical reads per returned rows. The following are generally considered good “rules of thumb”: access paths that lead to (logical reads / returned row)
> -  < 5 : good.
>  -  10–15 : acceptable.
> -  >= 20 : inefficient
     
> To check the number of logical reads per row:
> - explain plan : logical reads `Buffers`/  rows returned `A-Rows`, eg. 28/3 = 10 : acceptable
> - SQL trace :  logical reads `cr`/  rows returned `Rows`, eg. 28/3 = 10 : acceptable

```text
-----------------------------------------------------------------
| Id  | Operation                   | Name   | A-Rows | Buffers |
-----------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |    3   |     28  |
|*  1 |  TABLE ACCESS BY INDEX ROWID| T      |  **3** |   **28**|
|*  2 |   INDEX RANGE SCAN          | T_N2_I |     24 |       4 |
-----------------------------------------------------------------

Rows     Row Source Operation
-------  ---------------------------------------------------
  **3**  TABLE ACCESS BY INDEX ROWID T (**cr= 28** pr=0 pw=0 time=80 us)
     24   INDEX RANGE SCAN T_N2_I (cr=4 pr=0 pw=0 time=25 us)(object id 39684)
```

> You must consider the figures at the access-path level only, not for the whole SQL statement. In fact, the figures at the SQL statement level might be misleading.

### pitfalls

> While examining the number of logical reads, you must be aware of two pitfalls that might distort the figures.

#### read consistency

> For every SQL statement, the database engine has to guarantee the consistency of the processed data. For that purpose, based on current data blocks and undo blocks, consistent copies of data blocks might be created at runtime. 
> To execute such an operation, several logical reads are performed. Therefore, the number of logical reads performed by an access path operation is strongly dependent on the number of blocks that have to be reconstructed. 
> Eg, for teh same query and rows, 354 lofical reads may be performed instead of 28
> That effect is because of another session that modified the blocks needed to process this query. Because the changes weren’t committed at the time the query was started, the database engine had to reconstruct the blocks.


### row prefetching

> row prefetching: when a client retrieves data from a database, it will do it:
> - not row by row
> - but retrieving several rows at the same time. 
 
> this is good, as from a performance point of view, you should always avoid row-based processing.

> With a full table scan, there are two extremes :
> - row prefetching is set to 1, approximately one logical read per returned row is performed
> - row prefetching is set to a number greater than the number of rows stored in each table’s block, the number of logical reads is close to the number of the table’s blocks.

> In SQL*Plus, you manage the number of prefetched rows through the arraysize system variable (default is 15). Given the dependency of the number of logical reads on row prefetching, whenever you execute a SQL statement for testing purposes in a tool such as SQL*Plus, you should carefully set row prefetching like the application does. 
> The tool you use for the tests should prefetch the same number of rows as the application. Failing to do so may cause severely misleading results.

Aggregation

> When blocking operations (for example, aggregation operations) are executed, the SQL engine uses row prefetching internally. Every time it accesses a block, it extracts all rows contained in it (regardless of the row prefetching setting).  
> As a result, the number of logical reads of an access path is very close to the number of blocks.

## cause of inefficient access paths

> There are several main causes of inefficient access paths:
> - no suitable access structures (for example, indexes) are available.
> - a suitable access structure is available, but the syntax of the SQL statement doesn’t allow the query optimizer to use it.
> - the table or the index is partitioned, but no pruning is possible. As a result, all partitions are accessed.
> - the table or the index, or both, aren’t suitably partitioned.
> - when the query optimizer makes wrong estimations because of a lack of object statistics, object statistics that aren’t up-to-date, or a wrong query optimizer configuration is in place.

## solutions

> The objective is to minimize the number of logical reads, to use the access path that accesses fewer blocks. To reach this objective, it may be necessary to 
> - add new access structures (for example, indexes)
> - change the physical layout (for example, partition some tables or their indexes)

> It’s possible to classify SQL statements (or better, data access operations) in two main categories with regard to selectivity:
> - operations with weak selectivity
> - operations with strong selectivity

> The selectivity is important because the access structures and layouts that work well with operations with very weak selectivity work badly for operations with very strong selectivity, and vice versa

> It’s absolutely wrong to say that selectivity up to 0.1 is necessarily strong, and above this value, it’s necessarily weak. 
> In spite of this, it may be said that, in practice, the limit commonly ranges between 0.05 and 0.25. Only for values close to 0 or 1 can you be certain.

3 situations:
-  strong selectivities: index (and rowid or hash cluster)
-  in between: partitioned tables and hash clusters
-  weak selectivities : reading the whole table (full-table scan)

#### single row

3 access structure:
- heap table with a primary key
- index-organized table
- single-table hash cluster that has the primary key as the cluster key

3 dataset:  10, 10,000, and 1,000,000 rows

Access on primary key

> Four main facts:
> - all access structures, a single logical read is performed through a rowid
> - heap table, at least two logical reads are necessary: 
>   - one for the index
>   - one for the table
>   - as the number of rows increases, the height of the index increases, and the number of logical reads increases as well.
> - index-organized table: requires one less logical read than through the heap table.
> - single-table hash cluster: not only is the number of logical reads independent of the number of rows, but in addition, it always leads to a single logical read.

> For retrieving **a single row**, a regular table (with an index) is the least efficient access structure. However, they are the most commonly used because you can take advantage of the other access structures only in specific situations.


#### many rows



## appendix

### hash cluster

To find a row in a hash cluster:
 - apply the hash function to (predicate cluster key) value, eg `trialno=8` => `hash(8)`
 - get you a hash value, which is a reference to a data block in the cluster
 - this block is read 

```oracle
CREATE CLUSTER trial_cluster (
    trialno NUMBER
)
HASH IS trialno 
HASHKEYS 150;

CREATE TABLE trial (
    trialno NUMBER PRIMARY KEY,
    defended INTEGER,
    description VARCHAR2(100)
)
CLUSTER trial_cluster (trialno);
```

### access path, by data structures

| Access Path               | Heap-Organized Tables | B-Tree Indexes and IOTs | Bitmap Indexes | Table Clusters |
|---------------------------|-----------------------|-------------------------|----------------|----------------|
| Full Table Scans          | x                     |                         |                |                |
| Table Access by Rowid     | x                     |                         |                |                |
| Sample Table Scans        | x                     |                         |                |                |
| Index Unique Scans        |                       | x                       |                |                |
| Index Range Scans         |                       | x                       |                |                |
| Index Full Scans          |                       | x                       |                |                |
| Index Fast Full Scans     |                       | x                       |                |                |
| Index Skip Scans          |                       | x                       |                |                |
| Index Join Scans          |                       | x                       |                |                |
| Bitmap Index Single Value |                       |                         | x              |                |
| Bitmap Index Range Scans  |                       |                         | x              |                |
| Bitmap Merge]             |                       |                         | x              |                |
| Bitmap Index Range Scans  |                       |                         | x              |                |
| Cluster Scans             |                       |                         |                | x              |
| Hash Scans                |                       |                         |                | x              |