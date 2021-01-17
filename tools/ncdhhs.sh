#!/bin/bash
# requires csvkit, coreutils (for GNU date)
# MacOSX: brew install csvkit coreutils

date() { if type -t gdate &>/dev/null; then gdate "$@"; else date "$@"; fi }

source .env

curl --silent $NCDHHS_DATA_ENDPOINT -o /tmp/current.xlsx

FILE_SUFFIX='_ncdhhs_data'

# what's the new run date?
DATA_DATE=$(date --date "$(in2csv -H --sheet 'Vaccinations Data' /tmp/current.xlsx | csvgrep -c 1 -m "data from" | csvjson | jq ".[0].a" | cut -c 16-28)" +%Y%m%d)
# echo $DATA_DATE

# existing file list
DATA_CURRENT_DATES=$(ls ./data/*${FILE_SUFFIX}.xlsx | cut -c 8-15)
# echo $DATA_CURRENT_DATES

if [[ ${DATA_CURRENT_DATES[*]} =~ $DATA_DATE ]]
then
    echo "Dashboard data for $DATA_DATE already exists, discarding"
    rm -f /tmp/current.xlsx
else
    echo "Dashboard data for $DATA_DATE is new, creating ./data/${DATA_DATE}${FILE_SUFFIX}.xlsx"
    mv /tmp/current.xlsx ./data/${DATA_DATE}${FILE_SUFFIX}.xlsx
fi