# Filesystem

Storage:
 - metadata: header
 - data blocks : column1, column2 (pointer to migrated-chained)
 - block
 - row
 - table  
 - extents
 - segment
 - tablespace

Header (metadata):
- high watermark of the segment
- a list of the extents
- free space: freelist or automatic segment space management info

Block size
```oracle
select value from v$parameter where name = 'db_block_size'
```
8192 bytes => 8 octets

Size of value
```oracle
select id, vsize(id) 
from simple_table
```


Data in a row is not fixed
- cannot access a column without accessing previous
- put most-accessed columns first


Migrated row

Row chaining

Intra-block

PCTFREE


insert using direct-path: `/*+ append */` hint

## type
heap
index-organized tables
external tables
cluster tables

## contention

to access a block in the buffer cache, the process has 
- to get the (cache buffers chains) latch 
- to hold a pin (shared or exclusive)

event `buffer busy waits`

pin : short-term lock, shared (read) or exclusive (write)

latch

contention on data block:
- very high frequency of data block accesses on a given segment : frequent data block accesses of the same blocks, because of inefficient related-combine operations (for example, nested loops joins (even two or three SQL statements executed concurrently might be enough) => put efficient execution plan
- very high frequency of executions :  high number of SQL statements executed concurrently against (few) blocks => is it really necessary to execute those SQL statements against the same data so often, does application unnecessarily execute the same SQL statement too often ? Usually, the goal is to spread the activities over a greater number of blocks, the only exception is when several sessions wait from the same row.
  - you can reduce the number of rows per block (higher PCTFREE or smaller blocks), but this will harm performance cause more blocks will have to be read 
  - if INSERT, increase freelist (spread concurrent INSERT statements over several blocks)
  - if on index blocks, use REVERSE or partition index

contention on header block:
    - modified when:
        - INSERT statements make it necessary to increase the high watermark
        - INSERT statements make it necessary to allocate new extents
        - DELETE, INSERT, and UPDATE statements make it necessary to modify a freelist
    - partition the segment in order to spread the load over several segment header blocks
    - use bigger extents
    - use freelist groups (which store freelist outside of header); if using increase their size
    - use automatic segment space management


To speed I/O for full scan operations, you can use data compression
Few CPU overhead, cause the default compression is based on a fairly simple algorithm that only deduplicates repeated column values.

usage:
- standard : Use it on read-only data, as PCTFREE is 0 (migrated rows in uncompressed blocks risk)
- advanced: support tables experiencing regular INSERT statements and also modifications (data compression doesn’t take place for every INSERT statement or modification; instead, it takes place when a given block contains enough uncompressed data)
- hybrid: same as standard, read-only (columns of a specific row are no longer stored sequentially, instead, data is stored column by column and, as a result, columns of the same rows can be stored in different blocks.)