#!/bin/bash

if [ "$2" = "-w" ] && [ "$3" ] && [ "$4" = "-c" ] && [ "$5" ]; then

URL=$1

API_GET=`curl --request GET -w "@/usr/lib64/nagios/plugins/curl-format.txt" -o /dev/null -s "$URL"`
TIME_NAMELOOKUP=`echo "$API_GET" | grep "time_namelookup" | awk -F ':  ' '{print $2}'`
TIME_CONNECT=`echo "$API_GET" | grep "time_connect" | awk -F ':  ' '{print $2}'`
TIME_APPCONNECT=`echo "$API_GET" | grep "time_appconnect" | awk -F ':  ' '{print $2}'`
TIME_PRETRANSFER=`echo "$API_GET" | grep "time_pretransfer" | awk -F ':  ' '{print $2}'`
TIME_REDIRECT=`echo "$API_GET" | grep "time_redirect" | awk -F ':  ' '{print $2}'`
TIME_STARTTRANSFER=`echo "$API_GET" | grep "time_starttransfer" | awk -F ':  ' '{print $2}'`
TIME_TOTAL=`echo "$API_GET" | grep "time_total" | awk -F ':  ' '{print $2}'`

if (( $(echo "$TIME_TOTAL >= $5" |bc -l) )); then
  echo "$URL API: CRITICAL Total: $TIME_TOTAL|TOTAL=$TIME_TOTAL;;;; STARTTRANSFER=$TIME_STARTTRANSFER;;;; REDIRECT=$TIME_REDIRECT;;;; PRETRASFER=$TIME_PRETRANSFER;;;; APPCONNECT=$TIME_APPCONNECT;;;; CONNECT=$TIME_CONNECT;;;; NAMELOOKUP=$TIME_NAMELOOKUP"
  exit 2
elif (( $(echo "$TIME_TOTAL >= $3" |bc -l ) )); then
  echo "$URL API: WARNING Total: $TIME_TOTAL|TOTAL=$TIME_TOTAL;;;; STARTTRANSFER=$TIME_STARTTRANSFER;;;; REDIRECT=$TIME_REDIRECT;;;; PRETRASFER=$TIME_PRETRANSFER;;;; APPCONNECT=$TIME_APPCONNECT;;;; CONNECT=$TIME_CONNECT;;;; NAMELOOKUP=$TIME_NAMELOOKUP"
  exit 1
else
  echo "$URL API: OK Total: $TIME_TOTAL|TOTAL=$TIME_TOTAL;;;; STARTTRANSFER=$TIME_STARTTRANSFER;;;; REDIRECT=$TIME_REDIRECT;;;; PRETRASFER=$TIME_PRETRANSFER;;;; APPCONNECT=$TIME_APPCONNECT;;;; CONNECT=$TIME_CONNECT;;;; NAMELOOKUP=$TIME_NAMELOOKUP"
  exit 0
fi

fi
