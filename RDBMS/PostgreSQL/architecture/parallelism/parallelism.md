# Parallel

https://www.crunchydata.com/blog/parallel-queries-in-postgres

## CPU to use

### in total (max_worker_processes)

```postgresql
SHOW max_worker_processes;
SET max_worker_processes = 8;
```

max_worker_processes: Sets the maximum number of total worker processes allowed for the entire PostgreSQL instance, the default value is 8. This number includes any workers used for parallel queries. The general rule of thumb is to make this 25% of total vCPU count or greater. Some set this to the CPU count of the machine to take advantage of the most parallel workers.



### for queries (max_parallel_workers)

```postgresql
SHOW max_parallel_workers;
SET max_parallel_workers = 8;
```

max_parallel_workers: Sets the maximum number of parallel query worker processes allowed for the entire PostgreSQL instance, the default value is 8. By setting this value equal to the max_worker_processes, when no maintenance work is being run, Postgres will use all workers for queries. Conversely, high-transaction-rate systems limit the parallel workers to allocate workers for maintenance.

### Per query (max_parallel_workers_per_gather)

```postgresql
SHOW max_parallel_workers_per_gather;
SET max_parallel_workers_per_gather = 4;
```

max_parallel_workers_per_gather: Specifies the maximum number of workers that can be started by a single query. The default value is 2. The general rule of thumb here is that 2 might not always be enough. You can safely set this to half of your CPU count, or even your full CPU count if you want to make the most out of parallel queries.

