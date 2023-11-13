-- sys.stats
-- https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-stats-transact-sql?view=sql-server-ver16

-- dm_db_stats_properties
-- https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-stats-properties-transact-sql?view=sql-server-ver16

--- Statistics + Details
SELECT
--         sp.stats_id,
       stt.name
       ,stt.stats_generation_method_desc
--        filter_definition,
       ,sp.last_updated
       ,sp.rows
       ,sp.rows_sampled
--        sp.steps,
--        sp.unfiltered_rows,
       ,sp.modification_counter change_since_last_stat
--        ,'sys.stats=>'
--        ,stt.*
--        ,'dm_db_stats_properties=>'
--        ,sp.*
FROM sys.stats stt
     CROSS APPLY sys.dm_db_stats_properties(stt.object_id, stt.stats_id) sp
WHERE 1=1
    AND stt.name LIKE 'T_%'
ORDER BY sp.rows DESC
;


-- Update statistics for whole database
sp_updatestats