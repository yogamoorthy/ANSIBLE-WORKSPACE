#!/bin/bash

file=`find /manh/transfer/Global/OfRoute/error/ -maxdepth 1 -type f |wc -l`

if [ "$file" -ge 1 ]; then
  echo "Global Order failed transfer | Errors = $file"
  exit 2
else
  echo "Global Order transfer OK | Errors = $file"
  exit 0
fi
else # If inputs are not as expected, print help.
sName="`echo $0|awk -F '/' '{print $NF}'`"
echo -e "# Usage:\t$sName -c -e"
echo -e "\t\t= warnlevel and critlevel is numeric value"
echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_globalerr.sh"
exit
fi
