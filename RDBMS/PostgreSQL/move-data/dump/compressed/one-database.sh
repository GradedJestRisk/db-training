#!/usr/bin/env bash

if [ -z ${FILE_PATH+x} ]; then echo "FILE_PATH variable is not set. Exiting"; exit 1; fi
if [ -z ${SOURCE_CONNECTION_STRING+x} ]; then echo "SOURCE_CONNECTION_STRING variable is not set. Exiting"; exit 1; fi
if [ -z ${TARGET_CONNECTION_STRING+x} ]; then echo "TARGET_CONNECTION_STRING variable is not set. Exiting"; exit 1; fi

echo "Exporting data ..."
pg_dump \
  --dbname="$SOURCE_CONNECTION_STRING" \
  --format=directory --jobs=10 \
  --encoding="UTF-8" \
  --verbose \
  --file="$FILE_PATH"

echo "Data exported"

#if [ -z ${SCHEMA_NAME+x} ]; then echo "SCHEMA_NAME variable is not set. Exiting"; exit 1; fi
#
#echo "Creating schema ..."
#psql \
#  --dbname="$TARGET_CONNECTION_STRING" \
#  --command="DROP SCHEMA $SCHEMA_NAME CASCADE"
#
#psql \
#  --dbname="$TARGET_CONNECTION_STRING" \
#  --command="CREATE $SCHEMA_NAME acl"
#
#echo "Schema created"

echo "Importing data ..."

pg_restore \
  --dbname="$TARGET_CONNECTION_STRING" \
  --jobs=10 --verbose \
  "$FILE_PATH"

echo "Data imported"
