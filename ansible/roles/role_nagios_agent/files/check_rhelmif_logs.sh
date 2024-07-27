#!/bin/bash

if [ "$1" = "-c" ] && [ "$2" -gt "0" ]; then

  date="$(date +"%Y%m%d")"
  result=""
  server_log="/var/log/mif/server.log"
  error_log="/var/log/mif/WMERROR_${date}_000000.log"
  input="$(grep -i "error" $server_log)"

  if [ -z "$input" ]; then
    echo "Server logs are good. No errors."
    exit 0
  else
    echo -e "There are errors in the logs. See $error_log for more information."
    exit 2
  fi
else # If inputs are not as expected, print help.
  script=`basename ${BASH_SOURCE[0]}`
  echo -e "# Usage:\t$script -c 1"
  echo -e "\t\t= warnlevel and critlevel is numeric value"
  echo "# EXAMPLE:  /usr/lib64/nagios/plugins/$script -c 1"
  exit
fi
