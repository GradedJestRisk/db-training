-- Get WAL size
SELECT
  name,
  setting size_megabytes
FROM pg_settings
WHERE name IN ('min_wal_size','max_wal_size')
;

select name, setting
from pg_settings
where name like '%wal_size%' or name like '%checkpoint%' order by name
;

-- Toggle WAL on table

-- Deactivate WAL on creation

DROP TABLE IF EXISTS foo;

CREATE UNLOGGED TABLE foo(
    id INTEGER
);

-- WAL activated  : 3 seconds
-- WAL deactivated: 8 seconds
INSERT INTO foo (id) VALUES (generate_series( 1, 10000000))
;

TRUNCATE TABLE foo;

-- Deactivate WAL
ALTER TABLE foo SET UNLOGGED;

-- Raeactivate WAL
ALTER TABLE foo SET LOGGED;