#!/bin/bash
while ! npm run fake_activity 2>/dev/null
do
  sleep 1
  printf X
done

