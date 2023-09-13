##

Question: How to use a table > 4 Terabytes ?

Answer:

PG can't handle a table whose size exceed 32 Terabytes.
If you still write in this table, estimate when this limit will be reached and keep reading.

Size is not relevant as long as access time are satisfying.
They vary according to raw table size and indexes existence.

If access time are lagging, you can :
- create indexes, checking the size of indexes itself (each index is a tuple of values and a pointer) and making sure write time is still acceptable;
- normalize data model to decrease the size of each item, adding joins in queries;
- shard data, putting them im partitions or in different tables.

We're running PG14 on 128 GB memory, with 2 TBytes disk
Our biggest table is 400 GBytes (100 GByte index), around a trillion records.
We have 10 millions user account.


Question: How to optimize the connection pool ?

Connection pool is should be sized to :
- stay below the database maximum connection number, eg. 7680
- allow enough queries to be run to avoid contention on each application container

In order to size all that, you can monitor:
- on server-side (database): connection count
- on client-side (application): open connection, busy connection

Question: How to get overall system performance to prevent issues?

Answer:

If you want to know :
- the average performance, add some monitor to production;
- forecast performance, you'll have to perform overall test;
- when the system will collapse, you'll have to perform a stress test.

These tests are very expensive, as you'll need:
- dedicated platform to avoid side effects;
- to generate actual data in tables;
- to simulate user actions, which involve business rules;
- to act on the system, trough UI to keep things relevant (or API at least).

So gather your service level agreement (SLA) first to focus your effort.
You don't need a top-notch performance for all features, in every scenario.

pg_basebackup
PRA, RTO

ha_proxy https://en.wikipedia.org/wiki/HAProxy
