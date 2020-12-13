-- Remove container
-- docker rm postgres_node

-- Install using dockerHub
-- docker run --detach --name postgres_node clkao/postgres-plv8:10-2

-- Install using docker
-- curl https://github.com/clkao/docker-postgres-plv8/blob/master/12-2/Dockerfile > Dockerfile
-- docker build -t plv8:12-2 .
-- docker run --detach  --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --name postgres_node plv8:12-2

-- docker start postgres_node
-- docker logs postgres_node
-- psql -U postgres
-- docker exec -it postgres_node bash -c 'psql -U postgres -c "CREATE EXTENSION plv8; SELECT extversion FROM pg_extension WHERE extname = ''plv8'';"'


SELECT *
FROM pg_extension
WHERE 1=1
--extname = ''plv8'';
;

-- test
CREATE EXTENSION plv8;
SELECT plv8_version();
DO $$plv8.elog(NOTICE, "Hello, world!"); $$ LANGUAGE plv8;

---------
-- use --
---------


-- Return JSON
CREATE OR REPLACE FUNCTION hello(name TEXT) RETURNS JSON AS $$
    const greeting =  { hello: name } ;
    return greeting;
$$ LANGUAGE plv8 IMMUTABLE STRICT;

SELECT hello(name := 'world');
--  {"hello":"world"}

-- Read database
CREATE OR REPLACE FUNCTION hello(location TEXT) RETURNS JSON AS $$
    const response = plv8.execute('SELECT current_user');
    const greeting =  { hello: response[0].current_user, location: location } ;
    return greeting;
$$ LANGUAGE plv8 IMMUTABLE STRICT;

SELECT hello(location := 'world');
-- {"hello":"postgres","location":"world"}

