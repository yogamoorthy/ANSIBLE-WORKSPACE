#!/bin/bash

app_name="$1"

server_name=$(hostname -f)

url="http://$server_name:8080/$app_name/heartbeat/GrmgCall"
status_code=$(curl -o /dev/null --silent --request GET --data '<scenario><scenname>Test-GRMG</scenname><scenversion>001</scenversion><sceninst>001</sceninst><component><compname>APP</compname><compversion>unknown</compversion></component></scenario>' --write-out '%{http_code}\n' ${url})

if [ "$status_code" -ne "200" ]; then
  echo "$app_name has HTTP Status Code $status_code"
  exit 2
elif [ "$status_code" -eq "200" ]; then
  echo "$app_name has HTTP Status Code $status_code"
  exit 0
else
  echo "SDC Status Code is $status_code"
  exit 3
fi