-- Execute program Using COPY
ALTER ROLE <rolename> WITH SUPERUSER;

CREATE TABLE log (
    tt_id serial PRIMARY KEY,
    command_output TEXT
);

TRUNCATE TABLE log;

-- return 1
COPY log (command_output) FROM PROGRAM '/bin/false';
COPY log (command_output) FROM PROGRAM 'whoami';
COPY log (command_output) FROM PROGRAM 'cat /etc/os-release';
-- 12:31:27      68 be/4 postgres    0.00 B/s    0.00 B/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) CREATE INDEX
-- 12:31:32      68 be/4 postgres   61.90 M/s   64.72 M/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) CREATE INDEX
-- 12:31:37      68 be/4 postgres   55.04 M/s   60.32 M/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) CREATE INDEX
-- 12:31:42      68 be/4 postgres   14.31 M/s  167.44 M/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) CREATE INDEX
-- 12:31:47      68 be/4 postgres    3.85 M/s  169.68 M/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) CREATE INDEX
-- 12:31:52      68 be/4 postgres   17.64 M/s  168.72 M/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) CREATE INDEX
-- 12:31:57      68 be/4 postgres    9.30 M/s  197.21 M/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) CREATE INDEX
-- 12:32:02      68 be/4 postgres    5.99 M/s   89.78 M/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) idle
-- 12:32:08      68 be/4 postgres    0.00 B/s    0.00 B/s  ?unavailable?  postgres: postgres postgres 127.0.0.1(57416) idle


COPY log (command_output) FROM PROGRAM 'iotop --pid=68 --batch --iter=10 --delay=5 --time -qqq';

-- https://unix.stackexchange.com/questions/206252/know-which-process-does-i-o-without-iotop
COPY log (command_output) FROM PROGRAM 'grep ^write_bytes: /proc/68/io'; \watch 10


SELECT * FROM log;

-- docker pull scalingo/postgresql
-- https://hub.docker.com/layers/scalingo/postgresql/13.6.0-3/images/sha256-92eff993f9687ddad1a7cc3529f9d60e9ee592714d01e4405093a59e4d8a0fdf?context=explore
-- https://doc.scalingo.com/platform/internals/stacks/scalingo-18-stack
-- https://big-elephants.com/2015-10/writing-postgres-extensions-part-i/


