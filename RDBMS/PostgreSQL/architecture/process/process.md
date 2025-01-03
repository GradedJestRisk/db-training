# Process

## Stop database (properly)

Use `pg_ctl`
```shell
docker exec  --user postgres --tty  postgresql bash -c "pg_ctl stop"
```

https://www.postgresql.org/docs/current/app-pg-ctl.html

In docker, you can stop the container.
Docker will send a `SIGTERM` to PG, which will stop gracefully most of the time before docker stop timeout. If it takes more time, docker will send a `SIGKILL`, so you may change the timeout.  

To allow 30 seconds to stop.
```shell
docker stop --time 30 $CONTAINER_NAME
```

https://docs.docker.com/reference/cli/docker/container/stop/

## Stop query

### Unproperly

#### If you kill the backend_process using OS, the database will stop to recover  

You will see the database shut down and went through a recovery
```text
2024-12-24 17:58:02.037 GMT [1] LOG:  server process (PID 2340) was terminated by signal 9: Killed
2024-12-24 17:58:02.037 GMT [1] DETAIL:  Failed process was running: SELECT pg_sleep(3000)
2024-12-24 17:58:02.037 GMT [1] LOG:  terminating any other active server processes
2024-12-24 17:58:02.038 GMT [1] LOG:  all server processes terminated; reinitializing
2024-12-24 17:58:02.055 GMT [3501] LOG:  database system was interrupted; last known up at 2024-12-24 17:48:45 GMT
2024-12-24 17:58:02.108 GMT [3501] LOG:  database system was not properly shut down; automatic recovery in progress
2024-12-24 17:58:02.110 GMT [3501] LOG:  redo starts at 0/1950438
2024-12-24 17:58:02.110 GMT [3501] LOG:  invalid record length at 0/1950520: expected at least 24, got 0
2024-12-24 17:58:02.110 GMT [3501] LOG:  redo done at 0/19504E8 system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 0.00 s
2024-12-24 17:58:02.114 GMT [3502] LOG:  checkpoint starting: end-of-recovery immediate wait
2024-12-24 17:58:02.123 GMT [3502] LOG:  checkpoint complete: wrote 3 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.003 s, sync=0.001 s, total=0.010 s; sync files=2, longest=0.001 s, average=0.001 s; distance=0 kB, estimate=0 kB; lsn=0/1950520, redo lsn=0/1950520
2024-12-24 17:58:02.127 GMT [1] LOG:  database system is ready to accept connections
```

#### backend_process are NOT stopped if the caller is killed using OS

Start a query
```postgresql
just run-query
```

Look at it in `pg_stat_activity`
```postgresql
SELECT pid
FROM pg_stat_activity ssn
WHERE 1=1
    AND ssn.backend_type = 'client_backend'
    --AND ssn.query LIKE '%INSERT%'
```

Kill it (Ctrl-C would cancel it, which is NOT what we want)
```shell
kill -s SIGKILL $(pidof -s just)
```

Or to target a command
```shell
ps -efw | grep "just create" | grep -v grep | awk '{print $2}' | xargs kill -s SIGKILL
```

The query is still running, even though the caller does not exist anymore.
```postgresql
SELECT pid
FROM pg_stat_activity ssn
WHERE ssn.query LIKE '%INSERT%'
```

### Properly

Get its PID in `pg_stat_activity`
```postgresql
SELECT pid
FROM pg_stat_activity ssn
WHERE 1=1
    AND ssn.backend_type = 'client_backend'
    --AND ssn.query LIKE '%INSERT%'
```

Then ask to stop, do `cancel`
```postgresql
SELECT pg_cancel_backend(90701);
```

If it won't, do `terminate`
```postgresql
SELECT pg_terminate_backend(90701);
```