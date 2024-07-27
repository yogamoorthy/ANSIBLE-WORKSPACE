#!/bin/bash

if [ "$1" = "-c" ] && [ "$2" -gt "0" ] && [ "$3" = "-e" ]; then

ENVIRONMENT=$4



file=`find /apps/scope/mif/transfer/$ENVIRONMENT/salesorder/error/ -maxdepth 1 -type f |wc -l`


if [ "$file" -ge "$2" ]; then
  echo "SC/DC - SalesOrder failed transfer - $ENVIRONMENT | Errors = $file"
  exit 2
else
  echo "SC/DC - SalesOrder transfer OK - $ENVIRONMENT | Errors = $file"
  exit 0
fi
else # If inputs are not as expected, print help.
sName="`echo $0|awk -F '/' '{print $NF}'`"
echo -e "# Usage:\t$sName -c -e"
echo -e "\t\t= warnlevel and critlevel is numeric value"
echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_fileerr.sh -c 1 -e pdi"
exit
fi
