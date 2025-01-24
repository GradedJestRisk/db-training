set linesize 300
column name format a30
column value format a10
column description format a100

prompt ---- Automatic memory management ----

SELECT name, display_value value, description
FROM v$parameter
WHERE name IN ('memory_target',
               'memory_max_target');

prompt ---- SGA - System Global Area ----

SELECT
       mem.name AS zone
     , TO_CHAR(ROUND(bytes/1024/1024)) || ' MB' AS size_human
FROM v$sgainfo mem
WHERE 1=1
    AND mem.name IN ('Buffer Cache Size',
                     'Shared Pool Size',
                     'Large Pool Size',
                     'Redo Buffers')
ORDER BY bytes DESC;

prompt  ---- PGA - Program Global Area ----

SELECT name, display_value value, description
FROM v$parameter
WHERE name IN ( 'workarea_size_policy',
               'pga_aggregate_target'
                );

SELECT
    mem.name,
    TO_CHAR(ROUND(value/1024/1024)) || ' MB' AS size_human
FROM v$pgastat mem
WHERE 1=1
  AND mem.name IN ('aggregate PGA target parameter', 'maximum PGA allocated')
  AND mem.unit = 'bytes';

EXIT;