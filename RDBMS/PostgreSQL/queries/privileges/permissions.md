# Permissions

Granted to a role (user)
```postgresql
SELECT 
    prm.grantee
    ,prm.privilege_type
    ,prm.table_name
    ,'role_table_grants=>'
    ,prm.*
FROM information_schema.role_table_grants prm
 WHERE 1=1
--     AND prm.grantee <> 'postgres'
--     AND prm.grantee = 'pg_monitor' #pre-defined role
    AND prm.table_name = 'pg_buffercache'
 
```