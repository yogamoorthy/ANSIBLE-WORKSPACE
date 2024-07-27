#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ]; then

source /opt/hy-vee/scripts/env-setup.sh

smokes=`find /apps/scope/mif/transfer/cherokee/taxright/drop -maxdepth 1 -type f -cmin +10 |wc -l`

if [ "$smokes" -ge "$4" ]; then
  echo "Cigarette path 2 has $smokes errors - $wm_env | Errors = $smokes"
  exit 2
elif [ "$smokes" -ge "$2" ]; then
  echo "Cigarette path 2 has $smokes errors - $wm_env | Errors = $smokes"
  exit 1
else
  echo "Cigarette path 2 has $smokes errors - $wm_env | Errors = $smokes"
  exit 0
fi
else # If inputs are not as expected, print help.
sName="`echo $0|awk -F '/' '{print $NF}'`"
echo -e "# Usage:\t$sName -w -c "
echo -e "\t\t= warnlevel and critlevel is numeric value"
echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_cig1.sh -w 1 -c 2"
exit
fi
