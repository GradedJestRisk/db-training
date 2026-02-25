# Statistics

For the planner

Setting `default_statistics_target`
[Dablibo](https://blog.dalibo.com/2025/07/25/statistics-target.html)


ANALYZE update this table
```postgresql
SELECT *
FROM  pg_statistic
```

This view is based upon pg_statistic
```postgresql
SELECT * 
FROM pg_stats s
WHERE 1=1
    AND s.schemaname <> 'pg_catalog'
    AND s.tablename = 'foo'
--- AND s.attname = ''
```
