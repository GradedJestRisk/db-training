# Sizing instance

## total cache

OS cache + database cache

### formula 1: pgtune

75% RAM

[Source](https://github.com/le0pard/pgtune/blob/9ae57d0a97ba6c597390d43b15cd428311327939/src/features/configuration/configurationSlice.js#L152C33-L152C56)


### formula 2: dalibo

> Le planificateur se base sur ce paramètre pour évaluer les chances
de trouver des pages de données en mémoire.
> Généralement, il se positionne à 75% de la mémoire d’un serveur pour un serveur dédié.

> Une meilleure estimation est possible en parcourant les statistiques du système d’exploitation. Sur les systèmes Unix, ajoutez les nombres buffers+cached provenant des outils top ou free. 
> Soit 789 116 Kio, résultat de l’addition de 190 580 (colonne buffers ) et 598 536 (colonne cached). Il faut ensuite ajouter shared_buffers à cette valeur.

```text
               total        used        free      shared     buffers       cache   available
Mem:            31Gi       7,7Gi        12Gi       922Mi       466Mi        10Gi        22Gi
```

Here
- 10Gb OS cache 
- 470 Mo buffer
- 8 Gb database cache
=> 18,5 Gb, 50%, less than 75% RAM

## database cache

More the better, but you need to allow in RAM
- OS program
- OS cache
- backend memory

### formula 1 : postgresql

25 % RAM, eg 8 Gb for 32Gb

> If you have a dedicated database server with 1GB or more of RAM, a reasonable starting value for shared_buffers is 25% of the memory in your system. There are some workloads where even large settings for shared_buffers are effective, but because PostgreSQL also relies on the operating system cache, it is unlikely that an allocation of more than 40% of RAM to shared_buffers will work better than a smaller amount.

[source](https://www.postgresql.org/docs/current/runtime-config-resource.html)

### formula 2 : pgtune

25% of RAM, eg 8 Gb for 32Gb

[Source](https://github.com/le0pard/pgtune/blob/9ae57d0a97ba6c597390d43b15cd428311327939/src/features/configuration/configurationSlice.js#L131)

## process private memory : work_mem 

> Each step of an execution plan should in theory be limited by `work_mem`, but often that is not enough to estimate the memory usage:
> - a single statement may have many memory-intense execution steps, so it can allocate work_mem several times
>  -   if the statement uses parallel query, it could create dynamic shared memory segments that are not bounded by work_mem
>  - large data values, such as bytea binary data, will reside in memory and are not limited by work_mem

[Source](https://www.cybertec-postgresql.com/en/memory-context-for-postgresql-memory-management/)

### formula 1: thebuild

> The problem is that of all the parameters you can set in PostgreSQL, work_mem is about the most workload dependent. You are trying to balance two competing things:
>- First, you want to set it high enough that PostgreSQL does as many of the operations as it can (generally, sorts and sort-adjacent operations) in memory rather than on secondary storage, since it’s much faster to do them in memory, but:
> - You want it to be low enough that you don’t run out of memory while you are doing these things, because the query will then get canceled unexpectedly and, you know, people talk.

> You can prevent the second situation with a formula.
> (50% of free memory + file system buffers) / by the number of connections.

> The chance of running out of memory using that formula is very low. It’s not zero, because 
> - a single query can use more than work_mem if there are multiple execution nodes demanding it in a query, but that’s very unlikely
> - it’s even less likely that every connection will be running a query that has multiple execution nodes that require full work_mem
> The system will have almost certainly melted down well before that.

> The problem with using a formula like that is that you are, to mix metaphors, leaving RAM on the table. That means that a query that needs 64MB, even if it is the only one on the system that needs that much memory, will be spilled to disk while there’s a ton of memory sitting around available.

> If you absolutely must use a formula
> work_mem = (average freeable memory * 4) / max_connections

free memory = 4 * work_mem * max_connections
= each backend use 4 chunks

[source](https://thebuild.com/blog/2023/03/13/everything-you-know-about-setting-work_mem-is-wrong/)

So a server with
- 32 GB RAM
- 13 Gb free (25% cache, 25% OS cache, 10% OS misc) = 40% of 32 GB
- 200 connexions

work_mem = 13 GB * 4 / 200 = 2 % 13 GB = 260 MB

Check cache size: `cache` column
```shell
free --wide --human
```
[Source](https://stackoverflow.com/questions/47412846/how-to-find-the-size-of-buffer-cache-used-in-file-system-of-linux)

### formula 2: pgtune

Free memory doesn't include the OS cache, which is more optimistic than thebuild.

Much more pessimistic than thebuild (lower values) :
- all process use several chunks (3 instead of 3)
- and each process is parallelized

> work_mem is assigned any time a query calls for a sort, or a hash, or any other structure that needs a space allocation, which can happen multiple times per query. So you're better off assuming max_connections * 2 or max_connections * 3 is the amount of RAM that will actually use in reality. At the very least, you need to subtract shared_buffers from the amount you're distributing to connections in work_mem.
> The other thing to consider is that there's no reason to run on the edge of available memory. If you do that, there's a very high risk the out-of-memory killer will come along and start killing PostgreSQL backends. Always leave a buffer of some kind in case of spikes in memory usage. 
> So your maximum amount of memory available in work_mem should be 
> ((RAM - shared_buffers) / (max_connections * 3 ) / max_parallel_workers_per_gather).

More explicit

Available memory for backend process = RAM - shared_buffers
Nominal memory needed for each process = 3 chunks per worker (parallel)
Total memory for backend process = max_connections * 3 chunks
Available memory for backend process >= Total memory for backend process
RAM - shared_buffers >= max_connections * 3 chunks
chunk (work_mem) = (RAM - shared_buffers) / 3 * max_connections * workers

when 32 GB RAM, 8 GB cache, 4 parallel workers, 200 connections
work_mem = ( 32 - 8 ) / 3 * 200 * 4 = 24 GB / 2400 =  10 000 = 10 Mo

## maximum active connexions : max_connections

### constraints

If setting to a too high value
- OOM : as each connection may at least allocate one chunk of `work_mem`, actual connections (<= max_connexions) * `work_mem` < free RAM, but keeping `work_mem` high is good to avoid temp files (I/O)
- slowdown
> your CPU and/or I/O subsystem will be overloaded. The CPU will be busy switching between the processes or waiting for I/O from the storage subsystem, and none of your database sessions will make much progress. The whole system can “melt down” and become unresponsive, so that all you can do is reboot.

[Source](https://www.cybertec-postgresql.com/en/tuning-max_connections-in-postgresql/)

### formula 1 : PG Wiki

> A formula which has held up pretty well across a lot of benchmarks for years is that for optimal throughput the number of active connections should be somewhere near ((core_count * 2) + effective_spindle_count). 
> Effective spindle count is 
> - zero if the active data set is fully cached
> - approaches the actual number of spindles as the cache hit rate falls.
> There hasn't been any analysis so far regarding how well the formula works with SSDs.

[Source](https://wiki.postgresql.org/wiki/Number_Of_Database_Connections)

A spindle is a hard disk, so `effective_spindle_count` is the number of hard disk.

> It is essentially a measure of how many concurrent I/O request your server can manage. 
> Rotating harddisks can (typically) only handle one I/O request at a time. 
> If you have 16, your system can handle 16 I/O requests at the same time.
[Source](https://dba.stackexchange.com/questions/228663/what-is-effective-spindle-count)

So a server with
- 8 CPU
- one hard drive
Can handle `8 * 2 + 1` = 17 connections

So how to do with SSD ?
https://linuxreviews.org/HOWTO_Test_Disk_I/O_Performance

Look like it is `effective_io_concurrency`
number of concurrent I/O requests the disk(s) can handle = 200
[Source](https://bun.uptrace.dev/postgres/performance-tuning.html#ssd)

So a server with
- 8 CPU
- one SSD
Can handle `8 * 2 + 200` = 216 connections

### formula 2: Cybertec

#### formula

> max connections < min(num_cores, parallel_io_limit) /
    (session_busy_ratio * avg_parallelism)
> where
> -    num_cores is the number of cores available
> -    parallel_io_limit is the number of concurrent I/O requests your storage subsystem can handle
> -    session_busy_ratio is the fraction of time that the connection is active executing a statement in the database
> -    avg_parallelism is the average number of backend processes working on a single query


[Source](https://www.cybertec-postgresql.com/en/estimating-connection-pool-size-with-postgresql-database-statistics/)

#### datawarehouse

If your workload consists of big analytical queries:
- `session_busy_ratio` can be 1;
- `avg_parallelism` will be `max_parallel_workers_per_gather` + 1.

min(num_cores, parallel_io_limit) / (max_parallel_workers_per_gather + 1 )

So a server with
- 8 CPU
- one SSD

min(num_cores, parallel_io_limit) / (max_parallel_workers_per_gather + 1 )
if we use `max_parallel_workers_per_gather` = 4 from [pgtune](https://github.com/le0pard/pgtune/blob/9ae57d0a97ba6c597390d43b15cd428311327939/src/features/configuration/configurationSlice.js#L277C29-L277C49) in DWH (CPU/2)
= min (16, 200) / ( 4 +1  ) = 16 / 5 = 3

#### web

If your workload consists of many short statements:
- `session_busy_ratio` can be 0;
- `avg_parallelism` can be 1 (no parallelization)

min(num_cores, parallel_io_limit) / 0,1 

So a server with
- 8 CPU
- one SSD

min(num_cores, parallel_io_limit) / 0,1 = min(8,200) = 200

Connection pools provide an artificial bottleneck by limiting the number of active database sessions. Using them increases the `session_busy_rati`o. This way, you can get by with a much lower setting for max_connections without unduly limiting your application.

#### session_busy_ratio

`session_busy_ratio` is the fraction of time that the connection is active executing a statement in the database, eg. how much is it active (not idle).

The only metrics we have is:
- `active_time`: time spent executing **SQL statements** in the database
- `idle_in_transaction_time` : time spent idle **in a transaction** in the database

Why is  `idle_in_transaction_time` always zero here ?

So the busy ratio can be get this way.
```postgresql
SELECT pg_stat_reset();
SELECT datname database,
       sessions session_count,
       active_time,
       idle_in_transaction_time,
       ROUND( (active_time / (active_time + idle_in_transaction_time)) * 100) AS session_busy_ratio
FROM pg_stat_database
WHERE active_time > 0;
```

### formula 3 : pgtune

```text
    [DB_TYPE_WEB]: 200,
    [DB_TYPE_DW]: 40,
    [DB_TYPE_DESKTOP]: 20,
```

[Source](https://github.com/le0pard/pgtune/blob/9ae57d0a97ba6c597390d43b15cd428311327939/src/features/configuration/configurationSlice.js#L107)

### check 

Is actual connexions count << max_connections ?

From backends
```postgresql
SELECT datname, numbackends
FROM pg_stat_database
WHERE active_time > 0;
```

Or
```postgresql
SELECT datname, COUNT(1)
FROM pg_stat_activity
where backend_type = 'client backend'
GROUP BY datname;
```