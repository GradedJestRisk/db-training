## Foreign Data Wrapper (FDW)

## Setup

We need 2 databases with each a password-authenticated user.
They can be run by the same server, [here a local one](./docker-compose.yml).

Start containers
````shell
docker-compose up --detach
````

Check the initialization script has been executed.
````shell
docker-compose logs database
# /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init.sql
````

Connect to source.
````shell
psql postgres://source_user@localhost/source_database
CREATE TABLE source_table (id SERIAL);
INSERT INTO source_table DEFAULT VALUES;
````

Connect to target.
````shell
psql postgres://target_user@localhost/target_database
CREATE TABLE target_table (id SERIAL);
INSERT INTO target_table DEFAULT VALUES;
````

## Setup wrapper

[Reference](https://help.aiven.io/en/articles/977358-postgresql-dblink-extension-use-example)

Wrap connection to source database as source_user
```` sql
CREATE SERVER source_database
FOREIGN DATA WRAPPER dblink_fdw
OPTIONS (dbname 'source_database');

CREATE USER MAPPING FOR target_user
SERVER source_database
OPTIONS (user 'source_user', password 'source_user_password');

GRANT USAGE ON FOREIGN SERVER source_database TO target_user;
````

We use a local connection for convenience, but remote is as easy with this syntax
```` sql
OPTIONS (host 'postgres.demoproject.aivencloud.com', dbname 'db2', port '11254');
````

## Test

TODO
