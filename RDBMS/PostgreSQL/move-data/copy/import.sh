#!/usr/bin/env bash

echo "Importing CSV files.."

psql --dbname "$CONNECTION_STRING" \
  --no-psqlrc \
  --echo-all \
  --file=import.sql

echo "Import finished"
