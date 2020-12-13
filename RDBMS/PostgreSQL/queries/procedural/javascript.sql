-------------
-- Install --
-------------

-- Remove container
-- docker rm postgres_node

-- Install using dockerHub
-- docker run --detach --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --name postgres_node clkao/postgres-plv8:latest

-- Install using docker
-- curl https://github.com/clkao/docker-postgres-plv8/blob/master/12-2/Dockerfile > Dockerfile
-- docker build -t plv8:12-2 .
-- docker run --detach  --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --name postgres_node plv8:12-2

-------------
-- Start --
-------------

-- docker start postgres_node
-- docker logs postgres_node

-------------
-- Connect --
-------------

-- Locally
-- psql postgres://postgres@localhost:5432
-- psql -U postgres -h localhost

-- In container
-- docker exec -it postgres_node bash -c 'psql -U postgres'


CREATE EXTENSION plv8;

SELECT *
FROM pg_extension
WHERE 1=1
--extname = ''plv8'';
;


SELECT plv8_version();

DO $$plv8.elog(NOTICE, "Hello, world!"); $$ LANGUAGE plv8;

---------
-- use --
---------

--  Reminder of function modifier (used by optimizer)
--
--  https://www.postgresql.org/docs/current/sql-createfunction.html
--
--  IMMUTABLE/STABLE/VOLATILE --
--    IMMUTABLE : does not modify the database and always returns the same result when given the same argument values
--    STABLE:     does not modify the database, will consistently return the same result for the same argument values in single table scan
--                but not across SQL statements
--    VOLATILE :  returned value can change even within a single table scan
--                any function that has side-effects must be classified volatile, even if its result is quite predictable
--
-- LEAKPROOF : no side effects (  reveals no information about its arguments other than by its return value)
--             Note that a function which throws an error message for some argument values but not others, or includes the argument values in any error message, is NOT leakproof
--
-- CALLED ON NULL INPUT / RETURNS NULL ON NULL INPUT / STRICT
--
--      CALLED ON NULL INPUT         : the function will be called when some of its arguments are null (default
--      RETURNS NULL ON NULL INPUT   : the function is not executed when there are null arguments; a NULL is assumed automatically
--      STRICT                       : same as previous


-- IMMUTABLE STRICT LEAKPROOF
CREATE OR REPLACE FUNCTION hello() RETURNS JSON AS $$
    const greeting =  { hello: 'world' } ;
    return greeting;
$$ LANGUAGE plv8 IMMUTABLE STRICT LEAKPROOF;

SELECT hello();


-- IMMUTABLE
CREATE OR REPLACE FUNCTION hello(name TEXT) RETURNS JSON AS $$
    const greeting =  { hello: name } ;
    return greeting;
$$ LANGUAGE plv8 IMMUTABLE CALLED ON NULL INPUT;

SELECT hello(name := 'world');
--  {"hello":"world"}



-- Return JSON
CREATE OR REPLACE FUNCTION hello(name TEXT) RETURNS JSON AS $$
    const greeting =  { hello: name } ;
    return greeting;
$$ LANGUAGE plv8 IMMUTABLE CALLED ON NULL INPUT;

SELECT hello(name := 'world');
--  {"hello":"world"}


-- Call SQL function
CREATE OR REPLACE FUNCTION hello(location TEXT) RETURNS JSON AS $$
    const response = plv8.execute('SELECT current_user');
    const greeting =  { hello: response[0].current_user, location: location } ;
    return greeting;
$$ LANGUAGE plv8 IMMUTABLE;

SELECT hello(location := 'world');
-- {"hello":"postgres","location":"world"}


-- Read database
CREATE OR REPLACE FUNCTION list_users() RETURNS JSON AS $$
    const response = plv8.execute('SELECT oid AS user_id, rolname as user_name from pg_authid');
    return response;
$$ LANGUAGE plv8 STABLE STRICT;

SELECT jsonb_pretty(list_users()::jsonb);
                   jsonb_pretty
-- --------------------------------------------------
--  [                                               +
--      {                                           +
--          "user_id": 3373,                        +
--          "user_name": "pg_monitor"               +
--      },                                          +
--      {                                           +
--          "user_id": 3374,                        +
--          "user_name": "pg_read_all_settings"     +
--      },                                          +
--      {                                           +
--          "user_id": 3375,                        +
--          "user_name": "pg_read_all_stats"        +
--      },


-- Write database
CREATE OR REPLACE FUNCTION write_database()
RETURNS TEXT
AS $$

   plv8.execute('UPDATE item i SET quality = 0');

   return 'Items successfully updated';

$$ LANGUAGE plv8 VOLATILE STRICT;

SELECT write_database();



