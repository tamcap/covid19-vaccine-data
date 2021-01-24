#!/bin/bash

source .env

curl --silent $CDC_DATA_ENDPOINT -o /tmp/current.json
curl --silent $CDC_DATA_LTC_ENDPOINT -o /tmp/current-ltc.json

FILE_SUFFIX='_cdc_data'
LTC_FILE_SUFFIX="_cdc_ltc_data"

# what's the new run date?
DATA_DATE=$(cat /tmp/current.json | jq ".vaccination_data[0].Date" | sed  's/[-"]//g')
LTC_DATA_DATE=$(cat /tmp/current-ltc.json | jq ".vaccination_ltc_data[0].Date" | sed  's/[-"]//g')
# echo $DATA_DATE

# what's the new run id?
DATA_RUNID=$(cat /tmp/current.json | jq ".runid")
LTC_DATA_RUNID=$(cat /tmp/current-ltc.json | jq ".runid")
# echo $DATA_RUNID

# existing run id list
DATA_CURRENT_RUNS=$(jq ".runid" ./data/*${FILE_SUFFIX}.json)
LTC_DATA_CURRENT_RUNS=$(jq ".runid" ./data/*${LTC_FILE_SUFFIX}.json)
# echo $LTC_DATA_CURRENT_RUNS

if [[ ${DATA_CURRENT_RUNS[*]} =~ $DATA_RUNID ]]
then
    echo "Run $DATA_RUNID ($DATA_DATE) already exists, discarding"
    rm -f /tmp/current.json
else
    echo "Run $DATA_RUNID ($DATA_DATE) is new, creating ./data/${DATA_DATE}_${DATA_RUNID}${FILE_SUFFIX}.json"
    mv /tmp/current.json ./data/${DATA_DATE}_${DATA_RUNID}${FILE_SUFFIX}.json
fi

if [[ ${LTC_DATA_CURRENT_RUNS[*]} =~ $LTC_DATA_RUNID ]]
then
    echo "LTC run $LTC_DATA_RUNID ($DATA_DATE) already exists, discarding"
    rm -f /tmp/current-ltc.json
else
    echo "LTC run $LTCDATA_RUNID ($DATA_DATE) is new, creating ./data/${DATA_DATE}_${DATA_RUNID}${LTC_FILE_SUFFIX}.json"
    mv /tmp/current-ltc.json ./data/${DATA_DATE}_${DATA_RUNID}${LTC_FILE_SUFFIX}.json
fi
