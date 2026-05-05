#!/usr/bin/env bash

if [ -z ${TABLE_NAME+x} ]; then echo "TABLE_NAME variable is not set. Exiting"; exit 1; fi
if [ -z ${FILE_PATH+x} ]; then echo "FILE_PATH variable is not set. Exiting"; exit 1; fi
if [ -z ${SOURCE_CONNECTION_STRING+x} ]; then echo "SOURCE_CONNECTION_STRING variable is not set. Exiting"; exit 1; fi
if [ -z ${TARGET_CONNECTION_STRING+x} ]; then echo "TARGET_CONNECTION_STRING variable is not set. Exiting"; exit 1; fi

echo "Exporting data from table $TABLE_NAME ..."
pg_dump \
  --dbname="$SOURCE_CONNECTION_STRING" \
  --format=plain \
  --encoding="UTF-8" \
  --file="$FILE_PATH" \
  --table="$TABLE_NAME"

echo "Data exported"

echo "Importing data from table $TABLE_NAME ..."
psql \
  --dbname="$TARGET_CONNECTION_STRING" \
  --file="$FILE_PATH"

echo "Data imported"
