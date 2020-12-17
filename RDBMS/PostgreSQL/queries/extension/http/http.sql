---------------
-- Install   --
---------------

-- Create image
-- git clone https://github.com/pramsey/pgsql-http.git
-- cd pgsql-http
-- rm -rf .git
-- docker build --tag pgsql-http:latest --file ../Dockerfile .


-- Create container
-- docker rm postgres_http
-- docker run --detach  --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --name postgres_http pgsql-http:latest

-------------
-- Start --
-------------

-- docker start postgres_http
-- docker logs postgres_http

-------------
-- Connect --
-------------

-- Locally
-- psql postgres://postgres@localhost:5432
-- psql -U postgres -h localhost

-- In container
-- docker exec -it postgres_http bash -c 'psql -U postgres'

-- Test
CREATE EXTENSION IF NOT EXISTS http;

SELECT *
FROM pg_extension
WHERE 1=1
    AND extname = 'plpgsql';
;

-- Set option
SELECT http_set_curlopt('CURLOPT_PROXYPORT', '12345');

-- List options
SELECT * FROM http_list_curlopt();


---------------
-- Use       --
---------------

-- Full documentation
-- https://github.com/pramsey/pgsql-http/blob/master/README.md

-- GET
SELECT content FROM http_get('http://httpbin.org/ip');

-- PUT
SELECT status, content_type, content::json->>'data' AS data
  FROM http_put('http://httpbin.org/put', 'some text', 'text/plain');

