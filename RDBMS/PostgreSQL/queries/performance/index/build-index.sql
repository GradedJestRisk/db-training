DROP TABLE IF EXISTS foo CASCADE;

TRUNCATE TABLE foo;

CREATE TABLE foo (
   id    INTEGER PRIMARY KEY
 );

INSERT INTO foo (id)
SELECT *
FROM
  --generate_series( 1, 5000000) -- 5 million => 2 minutes
  --  generate_series( 1, 1000000) -- 1 million => 40 seconds
     generate_series( 1, 10000000) -- 10 million => 33 seconds ?
  --generate_series( 1, 100000000) -- 100 million => 4 minutes
;

CREATE UNIQUE INDEX foo_index_id ON foo (id);
-- 10 million => 6 seconds
-- 100 million => 1 minute

DROP INDEX foo_index_id;

-- see resource usage

-- docker exec -it pix-api-postgres bash

-- check CPU and memory
-- top

-- Mem: 15898816K used, 298604K free, 1206476K shrd, 860300K buff, 7353648K cached
-- CPU:   9% usr   7% sys   0% nic  75% idle   7% io   0% irq   0% sirq
-- Load average: 3.56 2.02 2.48 4/1511 538
--   PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
--   385     1 postgres R     359m   2%   3   9% postgres: postgres pix 172.21.0.1(32976) CREATE INDEX


-- check IO

-- in container
-- apk add iotop
-- iotop

-- issue (fixed)
-- Traceback (most recent call last):
--   File "/usr/bin/iotop", line 17, in <module>
--     main()
--   File "/usr/lib/python3.9/site-packages/iotop/ui.py", line 620, in main
-- https://gitlab.alpinelinux.org/alpine/aports/-/issues/4451

-- in host OS
-- sudo iotop --delay=10

-- Total DISK READ:        15.23 M/s | Total DISK WRITE:        87.07 M/s
-- Current DISK READ:      15.29 M/s | Current DISK WRITE:      85.12 M/s
--     TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
--   62204 be/4 70          7.66 M/s   43.30 M/s  ?unavailable?  postgres: postgres pix 172.21.0.1(32976) CREATE INDEX
--   65601 be/4 70          7.57 M/s   43.30 M/s  ?unavailable?  postgres: parallel worker for PID 385

-- A typical 7200 RPM HDD will deliver a read/write speed of 80-160MB/s.
-- A typical SSD will deliver read/write speed of between 200 MB/s to 550 MB/s.

SELECT
    'IO on index'
    ,t.idx_blks_hit
    ,t.idx_blks_read
    ,'pg_statio_all_indexes=>'
    ,t.*
FROM
 pg_statio_all_indexes t
WHERE 1=1
    AND t.indexrelname = 'foo_index_id';