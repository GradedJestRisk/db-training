# Dirtied

## Introduction

[Code](https://medium.com/@varunjain2108/unraveling-disk-i-o-with-postgresql-reads-does-every-query-trigger-a-write-ab331362c715)

## On SELECT

> I'm running SELECT . I end up seeing something like Buffers: shared hit=166416 dirtied=2 in the output. This sounds to me like the process of marking a block dirty should only happen when updating data though. My query is a SELECT, however, and only reads data.

> In PostgreSQL a row has to go through a visibility check. On the first read, the system checks if a row can be seen by everybody. If it is, it will be "frozen". This is where the writes come from.

https://dba.stackexchange.com/questions/81184/why-does-a-select-statement-dirty-cache-buffers-in-postgres


Example using copy and `vmstat`

https://www.cybertec-postgresql.com/en/speeding-up-things-with-hint-bits/#when-the-query-is-executed-again-the-io-pattern-is-totally-different

