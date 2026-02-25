Overview
=================
This will provide you:
* a running PostgreSQL database in a docker container
* with persisting data on local filesystem
* moderate (50 000) to high (25 000 000) volume
* in a single table 
 
It's self-supporting, you only need as a pre-requisite:
* Docker
* Linux 

The only non-yet-automated is a data file download, as curl doesn't look able to do it

Download data file
================= 
Choose:
* [30 MB](http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-monthly-update-new-version.csv)
* [4 GB](http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-complete.csv)


Download code
================= 

<pre>
mkdir bootstrap
cd bootstrap
curl https://github.com/GradedJestRisk/db-training/blob/master/RDBMS/PostgreSQL/bootstrap/bootstrap.sh --output bootstrap.sh 
curl https://github.com/GradedJestRisk/db-training/blob/master/RDBMS/PostgreSQL/bootstrap/create_db_and_load_data.sql --output create_db_and_load_data.sql
chmod +x bootstrap.sh
</pre>

Select the data file 
================= 
Uncomment variable SAMPLE_DATA_FILENAME the corresponding data file name

Default is pp-monthly-update-new-version.csv (30 Mb)

<pre>
# 30 MB
SAMPLE_DATA_FILENAME=pp-monthly-update-new-version.csv
SAMPLE_DATA_URL=http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-monthly-update-new-version.csv

# 4 GB
#SAMPLE_DATA_FILENAME=pp-complete.csv
#SAMPLE_DATA_URL=http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-complete.csv
</pre>

Execute 
================= 
Run <code> ./bootstrap.sh</code>

4 Gb file take less than 5 minutes

Below a sample output
<pre>
╰─$ ./bootstrap.sh                           
+ set -u
+ echo '=> setup environment variables'
=> setup environment variables
+ POSTGRES_DB_CONTAINER=PostgreSQL
+ POSTGRES_DB_IMAGE=postgres:alpine
+ POSTGRES_PORT=5482
+ POSTGRES_PASSWORD=password
+ POSTGRES_OS_USER=postgres
+ POSTGRES_DB_DATA_IMAGE=alpine
+ POSTGRES_DB_DATA_CONTAINER=PostgreSQLData
+ POSTGRES_DB_DATA_PATH=/var/lib/postgresql/bootstrap/data
+ TEMPORARY_DIRECTORY=/tmp/bootstrap
+ CREATE_DB_LOAD_DATA_SCRIPT_NAME=create_db_and_load_data.sql
+ SAMPLE_DATA_FILENAME=pp-complete.csv
+ SAMPLE_DATA_PATH=/tmp/bootstrap/pp-complete.csv
+ set +e
+ docker stop PostgreSQLData
PostgreSQLData
+ docker stop PostgreSQL
PostgreSQL
+ docker rm PostgreSQLData
PostgreSQLData
+ docker rm PostgreSQL
PostgreSQL
+ set -e
+ cp ./pp-complete.csv /tmp/bootstrap/pp-complete.csv
+ cp ./create_db_and_load_data.sql /tmp/bootstrap/create_db_and_load_data.sql
+ echo '=> create data volume'
=> create data volume
+ docker create --volume /var/lib/postgresql/bootstrap/data --name PostgreSQLData alpine
fb4ecb894d2162bb1ed88af033693058c41f02c58e8f7c3aef83fdcd83e8576b
+ echo '=> spin up container'
=> spin up container
+ docker run --publish 5482:5432 --name PostgreSQL --env POSTGRES_PASSWORD=password --env SAMPLE_DATA_PATH=/tmp/bootstrap/pp-complete.csv --detach --volumes-from PostgreSQLData --volume /tmp/bootstrap:/tmp/bootstrap postgres:alpine
1843c53eb506a9fd473ed12d7f204906c86a3d5685906c38ab8f28916c64d793
+ echo '=> wait for it to start'
=> wait for it to start
+ sleep 3
+ echo '=> create and load data'
=> create and load data
+ docker exec --interactive --tty --user postgres PostgreSQL psql -f /tmp/bootstrap/create_db_and_load_data.sql
psql:/tmp/bootstrap/create_db_and_load_data.sql:4: NOTICE:  => Create database
DO
CREATE DATABASE
psql:/tmp/bootstrap/create_db_and_load_data.sql:7: NOTICE:  => Connect to database
DO
You are now connected to database "bootstrap" as user "postgres".
psql:/tmp/bootstrap/create_db_and_load_data.sql:10: NOTICE:  => Create table land_registry_price_paid_uk
DO
CREATE TABLE
psql:/tmp/bootstrap/create_db_and_load_data.sql:29: NOTICE:  Loading data into land_registry_price_paid_uk
DO
psql:/tmp/bootstrap/create_db_and_load_data.sql:31: NOTICE:  Starting at 2020-05-03 16:54:17.382474+00
DO
COPY 25231356
psql:/tmp/bootstrap/create_db_and_load_data.sql:33: NOTICE:  Finished at 2020-05-03 16:56:46.251857+00
DO
psql:/tmp/bootstrap/create_db_and_load_data.sql:35: NOTICE:  Table record count is:
DO
 records_in_table 
------------------
   25 231 356
(1 row)

psql:/tmp/bootstrap/create_db_and_load_data.sql:38: NOTICE:  First 5 record are:
DO
   to_char    | transfer_date | postcode 
--------------+---------------+----------
       42 000 | 1995-12-21    | NE4 9DN
       95 000 | 1995-03-03    | RM16 4UR
       74 950 | 1995-10-03    | CW10 9ES
       43 500 | 1995-11-14    | TS23 3LA
       63 000 | 1995-09-08    | CA25 5QH
(5 rows)

psql:/tmp/bootstrap/create_db_and_load_data.sql:41: NOTICE:  Disconnecting..
DO
+ exit 0

</pre>
