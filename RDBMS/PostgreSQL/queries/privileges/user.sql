
SELECT "current_user"();

SELECT *
FROM pg_user
WHERE 1=1
 --   AND
;

SELECT
  usename AS role_name,
  CASE
     WHEN usesuper AND usecreatedb THEN
	   CAST('superuser, create database' AS pg_catalog.text)
     WHEN usesuper THEN
	    CAST('superuser' AS pg_catalog.text)
     WHEN usecreatedb THEN
	    CAST('create database' AS pg_catalog.text)
     ELSE
	    CAST('' AS pg_catalog.text)
  END role_attributes
FROM pg_catalog.pg_user
ORDER BY role_name desc


--  Create
CREATE USER user;

-- Prevent login
ALTER USER "user" WITH NOLOGIN;

-- Enable login
ALTER USER "user" WITH LOGIN;

-- Check login (role)
SELECT
       rolname,
       rolcanlogin
from pg_roles
where 1=1
-- AND rolname='user'
;

-- Change password
ALTER USER migration WITH PASSWORD 'foo';

-- Drop user
DROP USER IF EXISTS user1;
