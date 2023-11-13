
-- On database
SELECT [File Name] = name,
[File Location] = physical_name,
[Total Size (MB)] = size/128.0,
[Available Free Space (MB)] = size/128.0
- CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0,
[Type] = type_desc
FROM sys.database_files;

-- On table