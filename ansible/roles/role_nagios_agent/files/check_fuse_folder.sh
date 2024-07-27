#!/bin/bash
#fuseStaging version of stale_drops
if [ "$1" = "-c" ] && [ "$2" -gt "0" ] && [ "$3" -gt "0" ]; then

  FUSE_ERRORS="$(for a in `find /apps/scope/mif/transfer/fuseStaging -name "*fuseStaging" | grep -v complete`; do find $a -type f -mmin +"$3";done;)"
  fuse_error_count=$(echo "$FUSE_ERRORS" | grep -v '^\s*$' | grep -v complete | wc -l)

  if [ "$fuse_error_count" -ge "$2" ]; then
    echo "CRITICAL: FUSE ERRORS EXIST - $fuse_error_count"
    exit 2
  else
    echo "NO FUSE ERRORS EXIST"
    exit 0
  fi
else # If inputs are not as expected, print help.
    sName="$(echo $0 | awk -F '/' '{print $NF}')"
    echo -e "# Usage:\t$sName -w -c "
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_pix -w 1 -c 2"
    exit
fi
