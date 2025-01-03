## WAL

### Automatic checkpointer configuration

> A checkpoint is begun every checkpoint_timeout seconds, or if max_wal_size is about to be exceeded, whichever comes first. The default settings are 5 minutes and 1 GB, respectively.

https://www.postgresql.org/docs/current/wal-configuration.html

> Checkpoints are run periodically (the frequency of requested checkpoints is defined by checkpoint_timeout), and when they complete in time and the next one naturally begins it’s considered a timed checkpoint. If checkpoints are calculating too slow or out of tune, they will be requested checkpoints.

https://thewordtim5times.com/blog/7

## Manual checkpoint

Force checkpoint (WAL)
```postgresql
CHECKPOINT
```

## Checkpoint logs 

https://www.postgresql.org/docs/14/monitoring-stats.html#MONITORING-PG-STAT-BGWRITER-VIEW

### Table (stats)

Checkpointed
```postgresql
SELECT 
    buffers_checkpoint              buffer_checkpointed,
    checkpoints_timed timed_count,
    checkpoints_req   requested_count,
    TO_CHAR(stats_reset,'HH:MI:SS') stats_since,
    '=>',
    bg.*
FROM pg_stat_bgwriter bg
```

Reset stats
```postgresql
SELECT pg_stat_reset_shared('bgwriter') ;
```

### Database logs

```text
2024-12-26 14:11:14.154 GMT [61] LOG:  checkpoint starting: time
2024-12-26 14:11:41.118 GMT [61] LOG:  checkpoint complete: wrote 44272 buffers (4.2%); 0 WAL file(s) added, 0 removed, 38 recycled; write=26.895 s, sync=0.003 s, total=26.965 s; sync files=19, longest=0.002 s, average=0.001 s; distance=626950 kB, estimate=626950 kB
```