-- User
SELECT
    'User:' x
    ,prn.principal_id id
    ,prn.name name
    ,prn.type_desc type
     ,prn.default_schema_name
     ,prn.authentication_type_desc
     ,prn.sid
    ,'database_principals=>'
    ,prn.*
FROM
    sys.database_principals prn
WHERE 1=1
--     AND  prn.name = ''
     AND  prn.name NOT IN ('guest','sys','INFORMATION_SCHEMA')
    AND prn.type_desc <> 'DATABASE_ROLE'
ORDER BY  prn.type_desc DESC
;

-- Login (logged) + user
SELECT
     usr.name usr
    ,lgn.name login
    ,lgn.sid
    ,'database_principals=>'
    ,usr.*
    ,'login_token=>'
    ,lgn.*
FROM
    sys.database_principals usr
        INNER JOIN sys.login_token lgn on usr.sid = lgn.sid
;

select * from sys.user_token;

-- Users (all)
select
     usr.name
    ,usr.type_desc
     ,usr.sid
    ,'server_principals=>'
    ,usr.*
from
 sys.server_principals usr
Where 1=1
    AND usr.type_desc = 'SQL_LOGIN'
    AND usr.is_disabled = 'false'
;

-- Login
SELECT
    lgn.name
     ,lgn.sid
     ,'sql_logins=>'
     , lgn.*
FROM sys.sql_logins lgn
    WHERE 1=1
    AND lgn.is_disabled = 'false'
;

-- User
select
    usr.uid,
    usr.name,
    usr.sid
    ,'sys.sysusers=>'
    ,usr.*
from sys.sysusers usr
WHERE 1=1
    AND usr.issqlrole = 0
    AND usr.hasdbaccess = 1
;