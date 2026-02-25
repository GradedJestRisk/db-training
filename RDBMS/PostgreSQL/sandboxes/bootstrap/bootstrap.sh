#!/bin/bash

# print shell command
set -x

# stop if undefined variable
set -u

echo "=> setup environment variables"

# DB
POSTGRES_DB_CONTAINER=PostgreSQL
POSTGRES_DB_IMAGE=postgres:alpine
POSTGRES_PORT=5482
POSTGRES_PASSWORD=password
POSTGRES_OS_USER=postgres

# DB data
POSTGRES_DB_DATA_IMAGE=alpine
POSTGRES_DB_DATA_CONTAINER=PostgreSQLData
POSTGRES_DB_DATA_PATH=/var/lib/postgresql/bootstrap/data

TEMPORARY_DIRECTORY=/tmp/bootstrap
CREATE_DB_LOAD_DATA_SCRIPT_NAME=create_db_and_load_data.sql

# 30 MB
SAMPLE_DATA_FILENAME=pp-monthly-update-new-version.csv
SAMPLE_DATA_URL=http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-monthly-update-new-version.csv

# 4 GB
#SAMPLE_DATA_FILENAME=pp-complete.csv
#SAMPLE_DATA_URL=http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-complete.csv

SAMPLE_DATA_PATH=$TEMPORARY_DIRECTORY/$SAMPLE_DATA_FILENAME

# continue if a command fails
set +e

#echo "=> download file"
# TODO: fix curl - aws related ?
#curl ${SAMPLE_DATA_URL} --output  ./${SAMPLE_DATA_FILENAME}

# clean-up
docker stop $POSTGRES_DB_DATA_CONTAINER
docker stop $POSTGRES_DB_CONTAINER

docker rm $POSTGRES_DB_DATA_CONTAINER
docker rm $POSTGRES_DB_CONTAINER

# rm -rf  $POSTGRES_DB_DATA_STORAGE
# rm -rf  $SAMPLE_DATA_FILENAME
# rm -rf  $TEMPORARY_DIRECTORY

# stop if a command fails
set -e

# copy files
cp ./$SAMPLE_DATA_FILENAME            $TEMPORARY_DIRECTORY/$SAMPLE_DATA_FILENAME
cp ./$CREATE_DB_LOAD_DATA_SCRIPT_NAME $TEMPORARY_DIRECTORY/$CREATE_DB_LOAD_DATA_SCRIPT_NAME

echo "=> create data volume"
docker create --volume $POSTGRES_DB_DATA_PATH --name $POSTGRES_DB_DATA_CONTAINER $POSTGRES_DB_DATA_IMAGE

echo "=> spin up container"
docker run --publish $POSTGRES_PORT:5432 --name $POSTGRES_DB_CONTAINER --env POSTGRES_PASSWORD=$POSTGRES_PASSWORD --env SAMPLE_DATA_PATH=$SAMPLE_DATA_PATH --detach --volumes-from $POSTGRES_DB_DATA_CONTAINER --volume $TEMPORARY_DIRECTORY:$TEMPORARY_DIRECTORY $POSTGRES_DB_IMAGE

echo "=> wait for it to start"
sleep 3

echo "=> create and load data"
docker exec --interactive --tty --user $POSTGRES_OS_USER $POSTGRES_DB_CONTAINER psql -f $TEMPORARY_DIRECTORY/$CREATE_DB_LOAD_DATA_SCRIPT_NAME

exit 0

#echo "give you a diagnostic shell"
# docker exec --interactive --tty --user $POSTGRES_OS_USER $POSTGRES_DB_CONTAINER bash

# echo "give you a diagnostic SQL prompt"
# docker exec --interactive --tty --user $POSTGRES_OS_USER $POSTGRES_DB_CONTAINER psql