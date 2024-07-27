#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ] && [ "$5" = "-h" ];  then
HOST=$6

latency_average=$(ping -c 10 $HOST | tail -1| awk '{print $4}' | cut -d '/' -f 2)

if (( $(echo "$latency_average >= $4" | bc -l) )); then
  echo "Critical latency detected pinging $HOST $latency_average ms | Latency = $latency_average"
  exit 2
elif (( $(echo "$latency_average >= $2" | bc -l) )); then
  echo "Warning latency detected pinging $HOST $latency_average ms | Latency = $latency_average"
  exit 1
else
  echo "Latency test is OK pinging $HOST $latency_average ms | Latency = $latency_average"
  exit 0
fi
else # If inputs are not as expected, print help.
  sName="`echo $0|awk -F '/' '{print $NF}'`"
  echo -e "# Usage:\t$sName -h -w -c "
  echo -e "\t\t= warnlevel and critlevel is numeric value"
  echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_ping_latency -h jira.hy-vee.com -w 15 -c 30"
  exit
fi
