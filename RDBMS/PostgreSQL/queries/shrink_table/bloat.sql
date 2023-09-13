DROP TABLE IF EXISTS foo;

CREATE TABLE foo (
   id    SERIAL PRIMARY KEY,
   value INTEGER
 );

ALTER TABLE foo SET (AUTOVACUUM_ENABLED=FALSE);

INSERT INTO foo
  (value)
SELECT
  floor(random() * 2147483627 + 1)::int
FROM
    generate_series( 1, 1000000) -- 1 million => 2 seconds
;

DELETE FROM foo
WHERE MOD(id, 2) = 0;

select count(1) from foo;

-----------------------------
---- native
-----------------------------

-- https://github.com/ioguix/pgsql-bloat-estimation/blob/master/table/table_bloat.sql
SELECT
   current_database(), schemaname, tblname, bs*tblpages AS real_size,
  (tblpages-est_tblpages)*bs                            AS extra_size,
  CASE WHEN tblpages - est_tblpages > 0
    THEN 100 * (tblpages - est_tblpages)/tblpages::float
    ELSE 0
  END AS extra_pct, fillfactor,
  CASE WHEN tblpages - est_tblpages_ff > 0
    THEN (tblpages-est_tblpages_ff)*bs
    ELSE 0
  END AS bloat_size,
  CASE WHEN tblpages - est_tblpages_ff > 0
    THEN 100 * (tblpages - est_tblpages_ff)/tblpages::float
    ELSE 0
  END AS bloat_pct, is_na
  -- , tpl_hdr_size, tpl_data_size, (pst).free_percent + (pst).dead_tuple_percent AS real_frag -- (DEBUG INFO)
FROM (
  SELECT ceil( reltuples / ( (bs-page_hdr)/tpl_size ) ) + ceil( toasttuples / 4 ) AS est_tblpages,
    ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
    tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na
    -- , tpl_hdr_size, tpl_data_size, pgstattuple(tblid) AS pst -- (DEBUG INFO)
  FROM (
    SELECT
      ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
        - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
        - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
      ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages, heappages,
      toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname, fillfactor, is_na
      -- , tpl_hdr_size, tpl_data_size
    FROM (
      SELECT
        tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
        tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
        coalesce(toast.reltuples, 0) AS toasttuples,
        coalesce(substring(
          array_to_string(tbl.reloptions, ' ')
          FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
        current_setting('block_size')::numeric AS bs,
        CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
        24 AS page_hdr,
        23 + CASE WHEN MAX(coalesce(s.null_frac,0)) > 0 THEN ( 7 + count(s.attname) ) / 8 ELSE 0::int END
           + CASE WHEN bool_or(att.attname = 'oid' and att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
        sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 0) ) AS tpl_data_size,
        bool_or(att.atttypid = 'pg_catalog.name'::regtype)
          OR sum(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> count(s.attname) AS is_na
      FROM pg_attribute AS att
        JOIN pg_class AS tbl ON att.attrelid = tbl.oid
        JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
        LEFT JOIN pg_stats AS s ON s.schemaname=ns.nspname
          AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
        LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
      WHERE NOT att.attisdropped
        AND tbl.relkind in ('r','m')
      GROUP BY 1,2,3,4,5,6,7,8,9,10
      ORDER BY 2,3
    ) AS s
  ) AS s2
) AS s3
WHERE 1=1
   AND schemaname = 'public'
--   AND tblname = 'foo'
-- WHERE NOT is_na
--   AND tblpages*((pst).free_percent + (pst).dead_tuple_percent)::float4/100 >= 1
ORDER BY bloat_size DESC,
         tblname;

select pg_size_pretty(105220751360);

-- Total bloat
SELECT
    SUM(t.real_size)   size,
    SUM(t.bloat_size)  bloat_size,
    SUM(t.bloat_size)  /  SUM(t.real_size) * 100 || '%' bloat_pct
FROM (
    SELECT
       current_database(), schemaname, tblname, bs*tblpages AS real_size,
      (tblpages-est_tblpages)*bs                            AS extra_size,
      CASE WHEN tblpages - est_tblpages > 0
        THEN 100 * (tblpages - est_tblpages)/tblpages::float
        ELSE 0
      END AS extra_pct, fillfactor,
      CASE WHEN tblpages - est_tblpages_ff > 0
        THEN (tblpages-est_tblpages_ff)*bs
        ELSE 0
      END AS bloat_size,
      CASE WHEN tblpages - est_tblpages_ff > 0
        THEN 100 * (tblpages - est_tblpages_ff)/tblpages::float
        ELSE 0
      END AS bloat_pct, is_na
      -- , tpl_hdr_size, tpl_data_size, (pst).free_percent + (pst).dead_tuple_percent AS real_frag -- (DEBUG INFO)
    FROM (
      SELECT ceil( reltuples / ( (bs-page_hdr)/tpl_size ) ) + ceil( toasttuples / 4 ) AS est_tblpages,
        ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
        tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na
        -- , tpl_hdr_size, tpl_data_size, pgstattuple(tblid) AS pst -- (DEBUG INFO)
      FROM (
        SELECT
          ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
            - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
            - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
          ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages, heappages,
          toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname, fillfactor, is_na
          -- , tpl_hdr_size, tpl_data_size
        FROM (
          SELECT
            tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
            tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
            coalesce(toast.reltuples, 0) AS toasttuples,
            coalesce(substring(
              array_to_string(tbl.reloptions, ' ')
              FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
            current_setting('block_size')::numeric AS bs,
            CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
            24 AS page_hdr,
            23 + CASE WHEN MAX(coalesce(s.null_frac,0)) > 0 THEN ( 7 + count(s.attname) ) / 8 ELSE 0::int END
               + CASE WHEN bool_or(att.attname = 'oid' and att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
            sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 0) ) AS tpl_data_size,
            bool_or(att.atttypid = 'pg_catalog.name'::regtype)
              OR sum(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> count(s.attname) AS is_na
          FROM pg_attribute AS att
            JOIN pg_class AS tbl ON att.attrelid = tbl.oid
            JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
            LEFT JOIN pg_stats AS s ON s.schemaname=ns.nspname
              AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
            LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
          WHERE NOT att.attisdropped
            AND tbl.relkind in ('r','m')
          GROUP BY 1,2,3,4,5,6,7,8,9,10
          ORDER BY 2,3
        ) AS s
      ) AS s2
    ) AS s3
    WHERE 1=1
       AND schemaname = 'public'
) t;


select * from pg_statistic;

select * from pg_stats s
WHERE 1=1
-- AND s.schemaname <> 'pg_catalog'
-- AND s.attname = ''
;

-----------------------------
---- extension
-----------------------------

CREATE EXTENSION pgstattuple
;

-- Also
-- https://public.dalibo.com/exports/formation/manuels/modules/h2/h2.handout.html

-- https://www.postgresql.org/docs/13/pgstattuple.html
-- The table_len will always be greater than the sum of the tuple_len, dead_tuple_len and free_space.
-- The difference is accounted for by:
--  - fixed page overhead
--  - the per-page table of pointers to tuples
--  - padding to ensure that tuples are correctly aligned.

SELECT
    pg_size_pretty(tuple_len)       alive_size,
    tuple_percent || ' %'           alive_percent,
    pg_size_pretty(dead_tuple_len)  dead_size,
    dead_tuple_percent   || ' %'    dead_tuple_percent,
    pg_size_pretty(free_space)      unused_size,
    free_percent || ' %'            unused_percent,
    pg_size_pretty(table_len)       total_size,
    pg_size_pretty(table_len - tuple_len - dead_tuple_len - free_space) overhead
FROM pgstattuple('foo')
;

SELECT *
FROM pgstattuple('foo')
;

VACUUM foo;

-- Whereas pgstattuple always performs a full-table scan and returns an exact count of live and dead tuples (and their sizes) and free space,
-- pgstattuple_approx tries to avoid the full-table scan and returns exact dead tuple statistics along with an approximation of the number and size of live tuples and free space.

SELECT *
FROM pgstattuple_approx('foo')
;

DROP TABLE IF EXISTS foo;
CREATE TABLE foo (i integer);
ALTER TABLE foo SET (autovacuum_enabled=false);
INSERT INTO foo SELECT i FROM generate_series(1, 10000) i ;
DELETE FROM foo WHERE i < 9000 ;
