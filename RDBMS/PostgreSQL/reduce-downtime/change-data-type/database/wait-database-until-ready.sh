#!/bin/sh
# https://starkandwayne.com/blog/how-to-know-when-your-postgres-service-is-ready/
until pg_isready -h localhost -p 5432 -U postgres -d database
do
  echo "Database is not ready, next try in 10 s"
  sleep 10;
done
