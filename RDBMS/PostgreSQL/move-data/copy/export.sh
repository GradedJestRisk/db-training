#!/usr/bin/env bash

if [ -z ${IDENTIFIER+x} ]; then echo "IDENTIFIER variable is not set. Exiting"; exit 1; fi

echo "Deleting CSV files.."
rm ./*.csv

echo "Exporting data"

psql --dbname "$CONNECTION_STRING" \
 --echo-all \
 --variable IDENTIFIER="'${IDENTIFIER}'" \
 --file=export.sql

echo "Export finished"
