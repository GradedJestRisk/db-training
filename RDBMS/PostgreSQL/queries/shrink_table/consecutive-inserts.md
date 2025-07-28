# Allocate


```postgresql
DROP TABLE mytable;

CREATE TABLE mytable (
                         id  integer PRIMARY KEY,
                         val integer NOT NULL
) WITH (fillfactor= 100, autovacuum_enabled = off);

CREATE INDEX myindex ON mytable (id, val);
```

Special tuple
```postgresql
INSERT INTO mytable (id,val)
VALUES (666, 0)
```

Its ctid (to check dead afterwards)
```postgresql
SELECT
    ctid
FROM mytable
WHERE id = 666
```
(0,1)

Block 0
```postgresql
SELECT
    (ctid::text::point)[0]::bigint AS block
FROM mytable
WHERE id = 666
```

Stuff block
```postgresql
INSERT INTO mytable (id,val)
SELECT *, 0
FROM generate_series(1, 235) AS n;
```

Rows per block
```postgresql
SELECT
    (ctid::text::point)[0]::bigint AS block,
    COUNT(1) rows_per_block
FROM mytable
GROUP BY (ctid::text::point)[0]::bigint
;
```
| block | rows\_per\_block |
|:------|:-----------------|
| 0     | 226              |
| 1     | 9                |


Update special tuple
```postgresql
UPDATE mytable
SET val = 1
WHERE id = 666
```

Block 1
```postgresql
SELECT
    (ctid::text::point)[0]::bigint AS block
FROM mytable
WHERE id = 666
```

Its ctid (to check dead afterwards)
```postgresql
SELECT
    ctid
FROM mytable
WHERE id = 666
```
(1,12)

Stuff one more block
```postgresql
INSERT INTO mytable (id,val)
SELECT *, 0
FROM generate_series(236, 500) AS n;
```

Update special tuple
```postgresql
UPDATE mytable
SET val = 2
WHERE id = 666
```

Its ctid (to check dead afterwards)
```postgresql
SELECT
    ctid
FROM mytable
WHERE id = 666
```
(1,13)

Block 2
```postgresql
SELECT
    (ctid::text::point)[0]::bigint AS block
FROM mytable
WHERE id = 666
```

Rows per block
```postgresql
SELECT
    (ctid::text::point)[0]::bigint AS block,
    COUNT(1) rows_per_block
FROM mytable
GROUP BY (ctid::text::point)[0]::bigint
ORDER BY (ctid::text::point)[0]::bigint ASC
```

| block | rows_per_block |
|:------|:---------------|
| 0     | 225            |
| 1     | 224            |
| 2     | 52             |


Update special tuple
```postgresql
UPDATE mytable
SET val = 4
WHERE id = 666
```

Its ctid (to check dead afterward)
```postgresql
SELECT
    ctid
FROM mytable
WHERE id = 666
```
(1,229)

## Pageinspect

[Doc](https://www.postgresql.org/docs/current/pageinspect.html#PAGEINSPECT-B-TREE-FUNCS)

```postgresql
CREATE EXTENSION pageinspect
```

I use the [source](https://www.postgresql.fastware.com/pzone/2025-01-understanding-the-mechanics-of-postgresql-b-tree-indexes) from there

See also [this example](https://medium.com/@nikolaykudinov/understanding-postgresql-block-page-layout-part-4-07260d1bbc87)

### block header

[](https://www.postgresql.fastware.com/pzone/2025-01-postgresql-row-storage)
```postgresql
SELECT 
    (hdr.upper - hdr.lower) free_space,
    hdr.* 
FROM page_header(get_raw_page('mytable', 2)) AS hdr
; 
```


### index metapage

```postgresql
SELECT 
     map.level tree_depth
    ,map.root  root_block_number
     ,'bt_metap=>'
    ,map.* 
FROM bt_metap('myindex') map
```

### Single block info

Start at root block (2nd parameter)
```postgresql
SELECT
    CASE blk.type
        WHEN 'r' THEN 'root'
        WHEN 'i' THEN 'node'
        WHEN 'l' THEN 'leaf'
        ELSE 'ignored or deleted'
     END AS type       
     ,blk.live_items
     ,blk.dead_items
     ,pg_size_pretty(blk.free_size::numeric) free_space
     ,'bt_page_stats=>'
    ,blk.*
FROM bt_page_stats('myindex', 3) blk;
```

### multi-block info

```postgresql
SELECT 
    blk.blkno block_number,
    CASE blk.type
        WHEN 'r' THEN 'root'
        WHEN 'i' THEN 'node'
        WHEN 'l' THEN 'leaf'
        ELSE 'ignored or deleted'
    END AS type
    ,blk.live_items
    ,blk.dead_items
    ,pg_size_pretty(blk.free_size::numeric) free_space
    ,'bt_multi_page_stats'
    ,blk.* 
FROM 
    bt_multi_page_stats('myindex', 1, 412) AS blk
WHERE 1=1
--     AND blk.dead_items <> 0
ORDER BY blk.type, blk.blkno
```


```postgresql
SELECT 
    CASE blk.type
        WHEN 'r' THEN 'root'
        WHEN 'i' THEN 'node'
        WHEN 'l' THEN 'leaf'
        ELSE 'ignored or deleted'
    END AS type,
    COUNT(1)
FROM 
    bt_multi_page_stats('myindex', 1, 412) AS blk
WHERE 1=1
GROUP BY blk.type
ORDER BY COUNT(1) ASC 
```

### Block content


> tid shows a heap TID for the tuple, regardless of the underlying tuple representation. This value may match ctid, or may be decoded (..)

For a block (2nd parameter)
```postgresql
SELECT 
    itemoffset 
    ,ctid
    ,(ctid::text::point)[0]::bigint AS block
    --,nulls 
    --,vars 
    ,data 
    ,dead 
    ,htid 
    --,tids[0:2] AS some_tids
--     ,'bt_page_items=>'   
    --blk_cnt.*
FROM bt_page_items('myindex', 2) AS blk_cnt
WHERE 1=1
--     AND blk_cnt.dead = true
--     AND ctid = '(0,1)'
--    AND (ctid::text::point)[0]::bigint = 1
ORDER BY itemoffset
```

```postgresql
SELECT
    ctid,*
FROM mytable
WHERE ctid = '(0,2)'
```


### Walking

#### start at root

Get block number of root 
```postgresql
SELECT 
     map.level tree_depth
    ,map.root  root_block_number
     ,'bt_metap=>'
    ,map.* 
FROM bt_metap('myindex') map
```

Check it is a root
```postgresql
SELECT
    CASE blk.type
        WHEN 'r' THEN 'root'
        WHEN 'i' THEN 'node'
        WHEN 'l' THEN 'leaf'
        ELSE 'ignored or deleted'
     END AS type       
     ,blk.live_items
     ,blk.dead_items
     ,pg_size_pretty(blk.free_size::numeric) free_space
     ,'bt_page_stats=>'
    ,blk.*
FROM bt_page_stats('myindex', 412) blk;
```

Get its content (pointer to nodes)
```postgresql
SELECT 
    itemoffset item
    ,ctid
    ,(ctid::text::point)[0]::bigint AS node_block_number
    --,nulls 
    --,vars 
    ,data 
    ,dead 
    ,htid 
    --,tids[0:2] AS some_tids
--     ,'bt_page_items=>'   
    --blk_cnt.*
FROM bt_page_items('myindex', 412) AS blk_cnt
WHERE 1=1
--     AND blk_cnt.dead = true
--     AND ctid = '(0,1)'
--    AND (ctid::text::point)[0]::bigint = 1
ORDER BY itemoffset
```

| item | ctid     | node_block_number |
|:-----|:---------|:------------------|
| 1    | (3,0)    | 3                 |
| 2    | (411,1)  | 411               |
| 3    | (698,1)  | 698               |
| 4    | (984,1)  | 984               |
| 5    | (1270,1) | 1270              |


#### go on with node (tree traversal)

Go on with first node, block 3
```postgresql
SELECT
    CASE blk.type
        WHEN 'r' THEN 'root'
        WHEN 'i' THEN 'node'
        WHEN 'l' THEN 'leaf'
        ELSE 'ignored or deleted'
     END AS type       
     ,blk.live_items
     ,blk.dead_items
     ,pg_size_pretty(blk.free_size::numeric) free_space
     ,'bt_page_stats=>'
    ,blk.*
FROM bt_page_stats('myindex', 3) blk;
```

Get its content (pointer to nodes)
```postgresql
SELECT 
    itemoffset item
    ,ctid
    ,(ctid::text::point)[0]::bigint AS node_block_number
    --,nulls 
    --,vars 
    ,data 
    ,dead 
    ,htid 
    --,tids[0:2] AS some_tids
--     ,'bt_page_items=>'   
    --blk_cnt.*
FROM bt_page_items('myindex', 3) AS blk_cnt
WHERE 1=1
--     AND blk_cnt.dead = true
--     AND ctid = '(0,1)'
--    AND (ctid::text::point)[0]::bigint = 1
ORDER BY itemoffset
```

| item | ctid    | node_block_number |
|:-----|:--------|:------------------|
| 1    | (287,1) | 287               |
| 2    | (1,0)   | 1                 |  < =  HWM
| 3    | (2,1)   | 2                 |
| 4    | (4,1)   | 4                 |
| 4    | (5,1)   | 5                 |


```postgresql
SELECT 
    ctid, id, val
FROM mytable
WHERE ctid IN (
               '(287,1)',
               '(2,1)'
               '(4,1)'
               '(5,1)'
    )               
```

#### end on leaf

Go on with first item, 287
```postgresql
SELECT
    CASE blk.type
        WHEN 'r' THEN 'root'
        WHEN 'i' THEN 'node'
        WHEN 'l' THEN 'leaf'
        ELSE 'ignored or deleted'
     END AS type       
     ,blk.live_items
     ,blk.dead_items
     ,pg_size_pretty(blk.free_size::numeric) free_space
     ,'bt_page_stats=>'
    ,blk.*
FROM bt_page_stats('myindex', 287) blk;
```
It is a leaf


Get its content (pointer to heap)
```postgresql
SELECT 
    itemoffset item
    ,ctid
    ,(ctid::text::point)[0]::bigint AS node_block_number
    --,nulls 
    --,vars 
    ,data 
    ,dead 
    ,htid 
    --,tids[0:2] AS some_tids
--     ,'bt_page_items=>'   
    --blk_cnt.*
FROM bt_page_items('myindex', 287) AS blk_cnt
WHERE 1=1
--     AND blk_cnt.dead = true
--     AND ctid = '(0,1)'
--    AND (ctid::text::point)[0]::bigint = 1
ORDER BY itemoffset
```
| item | ctid      | node_block_number |
|:-----|:----------|:------------------|
| 1    | (463,1)   | 463               | < = HWM
| 2    | (461,125) | 461               |
| 3    | (461,126) | 461               |
| 4    | (461,127) | 461               |



```postgresql
SELECT 
    ctid, id, val
FROM mytable
WHERE ctid IN (
               '(461,125)',
               '(461,126)',
               '(461,127)'
    )               
```

Values are sorted, as expected !

| ctid      | id     | val |
|:----------|:-------|:----|
| (461,125) | 104311 | 0   |
| (461,126) | 104312 | 0   |
| (461,127) | 104313 | 0   |




### html
https://www.louisemeta.com/blog/indexes-btree/

```postgresql
SELECT id, val
FROM mytable
```


```postgresql
ANALYZE mytable;
ANALYZE myindex;
REINDEX INDEX myindex;
VACUUM mytable;
```

```postgresql
CREATE INDEX myindex ON mytable (id, val);
```

## How to find the fillfactor ?

## Density

```postgresql
SELECT 
    'index =>'
    ,ndx_stt.tree_level tree_depth
    ,ndx_stt.internal_pages node_block_count
    ,ndx_stt.leaf_pages leaves_block_count
    ,pg_size_pretty(index_size) size
    ,'changes=>' 
    ,ndx_stt.avg_leaf_density density
    ,ndx_stt.empty_pages empty_block_count
    ,ndx_stt.deleted_pages deleted_block_count
    ,ndx_stt.leaf_fragmentation fragmentation_rate
    --, 'pgstatindex.*'
    --,ndx_stt.*
FROM pgstatindex('myindex') ndx_stt;
```


```postgresql
TRUNCATE TABLE mytable;
    
INSERT INTO mytable (id,val)
SELECT *, 0
FROM generate_series(1, 500000) AS n;
```