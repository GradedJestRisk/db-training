


SELECT *
FROM pg_stat_progress_create_index p
;

SELECT
  p.phase,
  p.blocks_done,
  p.blocks_total,
  CASE WHEN blocks_total = 0 THEN 'N/A' ELSE TRUNC((p.blocks_done :: decimal / p.blocks_total ::decimal ) * 100) || '%' END progress_blocks,
  p.tuples_total,
  p.tuples_done,
  CASE WHEN tuples_total = 0 THEN 'N/A' ELSE TRUNC((p.tuples_done :: decimal / p.tuples_total ::decimal ) * 100) || '%' END progress_tuples
FROM pg_stat_progress_create_index p
;

-- internals
SELECT
    'internals =>'
    ,cnn.backend_type
    ,cnn.pid
    ,cnn.state
    ,cnn.wait_event
    ,cnn.wait_event_type
    ,cnn.query
    ,' pg_stat_activity =>'
    ,cnn.*
FROM
   pg_stat_activity cnn
WHERE 1=1
  --  AND cnn.backend_type IN ('autovacuum launcher', 'logical replication launcher', 'background writer', 'checkpointer', 'walwriter')
;

-- internals
SELECT
    'internals =>'
    ,cnn.backend_type
    ,cnn.pid
    ,cnn.state
    ,cnn.wait_event
    ,cnn.wait_event_type
    ,cnn.query
    ,' pg_stat_activity =>'
    ,cnn.*
FROM
   pg_stat_activity cnn
WHERE 1=1
    AND cnn.backend_type IN ('autovacuum launcher', 'logical replication launcher', 'background writer', 'checkpointer', 'walwriter', 'parallel worker')
    AND cnn.query = 'CREATE UNIQUE INDEX foo_index_id ON foo (id)'
;

-- client connexions
SELECT
    'client=>'
    ,cnn.client_port   cnn_port
    ,cnn.pid           pid
    ,cnn.backend_start::DATE cnn_start_date
    ,cnn.datname       database_name
    ,cnn.state
    ,cnn.wait_event
    ,cnn.wait_event_type
    ,cnn.query
     ,' pg_stat_activity =>'
     ,cnn.*
FROM
   pg_stat_activity cnn
WHERE 1=1
    AND cnn.backend_type = 'client backend'
    AND cnn.query = 'CREATE UNIQUE INDEX foo_index_id ON foo (id)'
    --AND cnn.query ILIKE 'INSERT INTO foo (id)%'
;