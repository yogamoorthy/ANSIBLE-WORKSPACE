#!/bin/bash

hostname=$(hostname)

if [ -z "$1" ] && [ -z "$2" ];
  then
    echo "Missing Parameters! Syntax: ./$(basename $0) Service-Name"
    exit 3
  else
    applicaton_name="$1"
    count="$2"
fi

if [ $(echo $hostname | grep -i prod &>/dev/null; echo $?) == "0" ]
  then
    applicaton_server="gkprod$applicaton_name$count-v"
elif [ $(echo $hostname | grep -i qa &>/dev/null; echo $?) == "0" ]
  then
    applicaton_server="gkqa$applicaton_name$count-v"
elif [ $(echo $hostname | grep -i dev &>/dev/null; echo $?) == "0" ]
  then 
    applicaton_server="gkdev$applicaton_name$count-v"
fi 

check_service() {
  server="127.0.0.1"
  master_data=$(curl -k "https://${server}:8443/jkmanager/*?mime=prop" -s)
  dataset=$(echo "$master_data" | grep -i $applicaton_server | egrep 'activation|\.busy=' | uniq)
  activation=$(echo "$dataset" | grep activation | awk -F=  '{ print $2 }')
  sessions=$(echo "$dataset" | grep '\.busy=' | awk -F=  '{ print $2 }')
  case ${activation} in
    ACT)
      echo "$applicaton_server is Active | Connections=$sessions"
      exit 0
      ;;
    DIS)
      echo "$applicaton_server is Disabled | Connections=$sessions"
      exit 1
      ;;
    STP)
      echo "$applicaton_server is Stopped | Connections=$sessions"
      exit 2
      ;;
    *)
      echo "$applicaton_server is not found."
      exit 3
      ;;
  esac
}

check_service