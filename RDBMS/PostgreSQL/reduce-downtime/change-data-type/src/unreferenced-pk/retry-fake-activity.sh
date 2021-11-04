#!/bin/bash
while ! npm run fake_activity 2>/dev/null & npm run fake_activity 2>/dev/null & wait
do
  sleep 1
  printf X
done

