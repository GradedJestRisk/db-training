## Create several databases on the same host
You can create and host 2 database on docker-compose startup

Start containers
````shell
docker-compose up --detach
````

Check the initialization script has been executed
````shell
docker-compose logs database
# /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init.sql
````

Connect to source
````shell
psql postgres://source_user@localhost/source_database
CREATE TABLE source_table (id SERIAL);
INSERT INTO source_table DEFAULT VALUES;
````

Connect to target
````shell
psql postgres://target_user@localhost/target_database
CREATE TABLE target_table (id SERIAL);
INSERT INTO target_table DEFAULT VALUES;
````
