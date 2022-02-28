----------- IO
--
-- D'après nos hypothèses, la limitation ici serait lié aux IOPS.
-- Pourquoi ? Lors de vos opérations intenses en lectures/écritures, vous pouvez voir que le CPU ne monte pas tellement
-- considérant qu'ils y a 8 cores disponibles avec 4 garanties (400% CPU) pour le plan 16G de pix-int-to-bigint-test.

-- La base de données de production a un disque dédié d'une capacité de 1.5TB.
-- Le nombre d'IOPS disponible est proportionnel à cette valeur à savoir 3 × capacité, donc 4500 IOPS
-- IOPS = 3 * capacité (GBytes) = 3 * 1 500 GBytes = 4 500 IO/s

-- IOPS (Input/output OPerations / Seconds)
-- IOPS * Transfer size (bytes) = Bytes / sec

-- IO rate
-- Transfert size = block size = 64 kBytes
-- 4 500 IO/s = 300 MBytes/s

-- Time elapsed
-- 5 GBytes to write, 300 MBytes/s = 17 seconds
SELECT (5 * 1024) / 300;

-- blocks
-- - local
-- - temp
-- - shared
-- - WAL

DROP TABLE IF EXISTS foo CASCADE;

CREATE TABLE foo (
   id    INTEGER PRIMARY KEY
 );

SELECT pg_stat_statements_reset();

SET track_io_timing TO on;
-- ERROR:  permission denied to set parameter "track_io_timing"

--https://www.postgresql.org/docs/13/pgstatstatements.html


INSERT INTO foo (id)
SELECT *
FROM
  --generate_series( 1, 5000000) -- 5 million => 2 minutes
  --  generate_series( 1, 1000000) -- 1 million => 40 seconds
  --   generate_series( 1, 10000000) -- 10 million => 33 seconds ?
  generate_series( 1, 100000000) -- 100 million => 4 minutes
;


SELECT pg_size_pretty(pg_total_relation_size('foo'));
-- 5 600 MB

SELECT
    query,
    TRUNC(blk_write_time)      write_time_milliseconds,
    TRUNC(blk_write_time/1000) write_time_seconds,
    TRUNC(total_time)          total_time_milliseconds,
    TRUNC ( ( pg_total_relation_size('foo') / 1024  / 1024) / (blk_write_time / 1000) ) megaBytes_per_second,
    'pg_stat_statements=>',
    p.*
FROM pg_stat_statements p
WHERE 1=1
    AND query ILIKE 'INSERT INTO FOO%'
    AND calls = 1
;

SELECT * FROM foo;
SELECT COUNT(1) FROM foo;


SELECT pg_stat_statements_reset();

SET track_io_timing TO on;
-- ERROR:  permission denied to set parameter "track_io_timing"

DROP INDEX foo_index_id;
CREATE UNIQUE INDEX foo_index_id ON foo (id);

-- ps -ef | grep CREATE
-- sudo iotop --pid=12583 --batch
--    TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
--  12583 be/4 70          0.00 B/s  271.72 M/s  ?unavailable?  postgres: postgres database 172.18.0.1(57426) CREATE INDEX
--  12583 be/4 70         35.05 M/s   85.00 M/s  ?unavailable?  postgres: postgres database 172.18.0.1(57426) CREATE INDEX

-- => from 50 to 300 MB/s

-- Index size
SELECT pg_size_pretty(pg_indexes_size('foo'));
-- 4284 MB

-- IO rate speed
SELECT
    'I/O rate=>'
    ,TRUNC ( pg_indexes_size('foo') / blk_write_time ) "B/ms"
    ,TRUNC ( ( pg_indexes_size('foo') / 1024  / 1024 ) / (blk_write_time / 1000) ) "MB/s"
    ,TRUNC ( ( pg_indexes_size('foo') / 1024  / 1024 / 1024 ) / (blk_write_time / 1000) ) "GB/s"
    ,'size=>'
    ,pg_size_pretty(pg_indexes_size('foo')) bytes
    ,'timings=>'
--     ,query
--     ,TRUNC(blk_write_time)      write_millis
    ,TRUNC(blk_read_time/1000)  read_sec
    ,TRUNC(blk_write_time/1000) write_sec

--     ,TRUNC(total_time)          total_millis
    ,TRUNC(total_time/1000)     total_sec
    ,'write=>'
    ,p.local_blks_written, p.shared_blks_written, p.temp_blks_written, p.blk_write_time
    ,'pg_stat_statements=>'
    ,p.*
FROM pg_stat_statements p
WHERE 1=1
   AND query = 'CREATE UNIQUE INDEX foo_index_id ON foo (id)'
   --AND blk_write_time <> 0
   --AND calls = 1
ORDER BY total_time DESC
;

-- Total time = 1 minute = table read from disk (full) + index tree build (memory) + index write to disk (full) + WAL write to disk (full)
-- Write time = let's say half = 30 seconds (not 1 second as in pg_stat_statements.blk_write_time)
-- 4 GBytes to write in 30 seconds = 146 MBytes/seconds => match !
SELECT (4.284 * 1024) / 30;

-- ❯ dd if=/dev/zero of=/tmp/test1.img bs=2G count=1 oflag=dsync
-- 0+1 records in
-- 0+1 records out
-- 2147479552 bytes (2,1 GB, 2,0 GiB) copied, 2,35198 s, 913 MB/s

SELECT COUNT(1) FROM foo;

UPDATE foo
SET id = -1 * id;

DROP INDEX foo_index_id;
DROP TABLE IF EXISTS foo CASCADE;