CREATE USER "TEST" IDENTIFIED BY "password";
GRANT CONNECT TO "TEST";
GRANT DBA TO "TEST";
GRANT CREATE SESSION TO "TEST";
DROP USER "TEST";

select * from all_users where username IN ('TEST','USERNAME');

SELECT
    username,
    default_tablespace,
    profile,
    authentication_type
FROM
    dba_users
WHERE
    account_status = 'OPEN';

select * from dba_role_privs connect by prior granted_role = grantee start with grantee = 'TEST' order by 1,2,3;
select * from dba_sys_privs  where grantee = '&USER' or grantee in (select granted_role from dba_role_privs connect by prior granted_role = grantee start with grantee = 'TEST') order by 1,2,3;
select * from dba_tab_privs  where grantee = '&USER' or grantee in (select granted_role from dba_role_privs connect by prior granted_role = grantee start with grantee = 'TEST') order by 1,2,3,4;
