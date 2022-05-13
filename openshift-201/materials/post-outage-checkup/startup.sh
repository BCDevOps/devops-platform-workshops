#!/bin/bash
echo 'Starting Crash App'
for i in {1..5}; do 
  echo "Starting App $i..."
  sleep 1
done 

if [[ -z "${DEPLOY_ENV}" ]]; then 
  echo 'ERROR: Missing DEPLOY_ENV variable'
  exit 1
else 
 sleep infinite 
fi