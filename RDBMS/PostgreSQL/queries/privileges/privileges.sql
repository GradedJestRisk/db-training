SELECT "current_user"()
;


-- Do you have `USAGE` on the schema?
--     No:  Reject access.
--     Yes: Do you also have the appropriate rights on the table?
--         No:  Reject access.
--         Yes: Check column privileges.


-- Roles are users
SELECT
       rl.oid     rl_dtf,
       rl.rolname rl_nm
FROM pg_roles rl;

-- Superuser
select
       usename, usesuper
from pg_user
where 1=1
    AND usename = ''
;


-- Table privilege
SELECT
   table_catalog, table_schema, table_name, privilege_type, grantor, grantee
FROM
   information_schema.table_privileges
WHERE 1=1
    AND grantee = 'administrator'
--    AND grantee <> 'postgres'
    AND table_schema <> 'pg_catalog'
--    AND table_schema <> 'information_schema'
--    AND table_schema <> 'public'
;


-- Schema privilege
select schema_name
from information_schema.schemata;


-- Database privilege
WITH db_user AS  (SELECT rolname AS name FROM pg_roles WHERE rolname = 'postgres')
SELECT
       db_user.name,
       datname,
       array(SELECT privs
             FROM unnest(
               ARRAY[
                    (CASE WHEN has_database_privilege(db_user.name,c.oid,'CONNECT')   THEN 'CONNECT'   ELSE NULL END),
                    (CASE WHEN has_database_privilege(db_user.name,c.oid,'CREATE')    THEN 'CREATE'    ELSE NULL END),
                    (CASE WHEN has_database_privilege(db_user.name,c.oid,'TEMPORARY') THEN 'TEMPORARY' ELSE NULL END),
                    (CASE WHEN has_database_privilege(db_user.name,c.oid,'TEMP')      THEN 'CONNECT'   ELSE NULL END)
               ] ) foo (privs)
             WHERE privs IS NOT NULL)
FROM
     pg_database c, db_user
WHERE 1=1
  AND has_database_privilege( db_user.name, c.oid, 'CONNECT,CREATE,TEMPORARY,TEMP')
  AND datname not in ('template0')
;


SELECT $1, datname, array(select privs from unnest(ARRAY[
( CASE WHEN has_database_privilege($1,c.oid,'CONNECT') THEN 'CONNECT' ELSE NULL END),
(CASE WHEN has_database_privilege($1,c.oid,'CREATE') THEN 'CREATE' ELSE NULL END),
(CASE WHEN has_database_privilege($1,c.oid,'TEMPORARY') THEN 'TEMPORARY' ELSE NULL END),
(CASE WHEN has_database_privilege($1,c.oid,'TEMP') THEN 'CONNECT' ELSE NULL END)])foo(privs) WHERE privs IS NOT NULL) FROM pg_database c WHERE
has_database_privilege($1,c.oid,'CONNECT,CREATE,TEMPORARY,TEMP') AND datname not in ('template0');



-- Create function
CREATE OR REPLACE FUNCTION database_privs(text) RETURNS table(username text,dbname name,privileges  text[])
AS
$$
SELECT $1, datname, array(select privs from unnest(ARRAY[
( CASE WHEN has_database_privilege($1,c.oid,'CONNECT') THEN 'CONNECT' ELSE NULL END),
(CASE WHEN has_database_privilege($1,c.oid,'CREATE') THEN 'CREATE' ELSE NULL END),
(CASE WHEN has_database_privilege($1,c.oid,'TEMPORARY') THEN 'TEMPORARY' ELSE NULL END),
(CASE WHEN has_database_privilege($1,c.oid,'TEMP') THEN 'CONNECT' ELSE NULL END)])foo(privs) WHERE privs IS NOT NULL) FROM pg_database c WHERE
has_database_privilege($1,c.oid,'CONNECT,CREATE,TEMPORARY,TEMP') AND datname not in ('template0');
$$ language sql;

-- Get results
select * from database_privs('postgres');


-- Elevate user privilege to administrator (postgres)
ALTER USER myuser WITH SUPERUSER;

-- Lower  user privilege to non-administrator user
ALTER USER username WITH NOSUPERUSER;