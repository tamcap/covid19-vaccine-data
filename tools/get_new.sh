#!/bin/bash

source .env

curl --silent $CDC_DATA_ENDPOINT -o /tmp/current.json

FILE_SUFFIX='_cdc_data'

# what's the new run date?
DATA_DATE=$(cat /tmp/current.json | jq ".vaccination_data[0].Date" | sed  's/[-"]//g')
# echo $DATA_DATE

# what's the new run id?
DATA_RUNID=$(cat /tmp/current.json | jq ".runid")
# echo $DATA_RUNID

# existing run id list
DATA_CURRENT_RUNS=$(jq ".runid" ./data/*${FILE_SUFFIX}.json)
# echo $DATA_CURRENT_RUNS

if [[ ${DATA_CURRENT_RUNS[*]} =~ $DATA_RUNID ]]
then
    echo "Run $DATA_RUNID ($DATA_DATE) already exists, discarding"
    rm -f /tmp/current.json
else
    echo "Run $DATA_RUNID ($DATA_DATE) is new, creating ./data/${DATA_DATE}_${DATA_RUNID}${FILE_SUFFIX}.json"
    mv /tmp/current.json ./data/${DATA_DATE}_${DATA_RUNID}${FILE_SUFFIX}.json
fi