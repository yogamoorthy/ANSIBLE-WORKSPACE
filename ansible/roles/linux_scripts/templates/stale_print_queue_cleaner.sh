#!/bin/bash
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# >>>>>>>>>>>> MANAGED BY ANSIBLE <<<<<<<<<<<
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Do not attempt to make modifications to this file directly because it will not persist
# Modify the script in github and submit a PR!
#
#
# Description: Queries cups for the current print queue and deletes
#       print jobs older than 24 hours
#       Can be run every hour.. every minute.. every day.. whenever
# Author: Tony Welder
# Email: twelder@hy-vee.com


TODAY=$(date +%"s")
YESTERDAY=`echo "$TODAY - 86400" | bc`
OLDIFS=$IFS
IFS=$'\n'
for PRINT_JOB in `lpstat -o`; do
  PRINT_JOB_DATE=`echo $PRINT_JOB | awk '{print $4" "$5" "$6" "$7" "$8" "$9" "$10}'`
  PRINT_JOB_EPOCH=`date -d "$PRINT_JOB_DATE" +"%s"`
  if [ $YESTERDAY -gt $PRINT_JOB_EPOCH ]; then
    PRINT_JOB_ID=`echo $PRINT_JOB | awk '{print $1}'`
    logger "stale_print_queue_cleaner.sh cron removed print job ID $PRINT_JOB_ID from queue"
    cancel $PRINT_JOB_ID
  fi
done
IFS=$OLDIFS
