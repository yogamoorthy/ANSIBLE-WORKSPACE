#!/bin/bash
# This is the Export step of the Agilence ucon process after transactions have been compressed.
# Exported transactions are stored at $workdir/hv_transaction_export_$date.zip
#
# This script runs on a cronjob at /etc/crontab on gkprodsdc1-v
# 47 1 * * * root /opt/hy-vee/scripts/export_transactions.sh 1

workdir=/usr/local/gkretail/ucon/tenants/001/dataexchange/export_channel/export
logfile=/var/log/gk/export_transactions.log
# loglevel of 2 is default and will show all messages except debug messages
loglevel=2

newer_than="$1"
ignore_today="_$(date +%F)"
yesterday=`date +%F --date="yesterday"`
file_name="hv_transaction_export_${yesterday}.zip"

# Color Variables
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
nc='\033[0m'

logging() {
  logtime=$(date "+%d-%b-%Y %H:%M:%S:%3N")
  level="$1"
  function="$2"
  msg="$3"

  if [ "$level" == "debug" ]; then
    if [ "$loglevel" -ge "3" ]; then
      echo "$logtime DEBUG: {$function} $msg" >> $logfile
    fi
  elif [ "$level" == "info" ]; then
    if [ "$loglevel" -ge "2" ]; then
      echo "$logtime INFO: {$function} $msg" >> $logfile
    fi
  elif [ "$level" == "warn" ]; then
    if [ "$loglevel" -ge "1" ]; then
      echo -e "${yellow}$logtime WARN: {$function} $msg${nc}" >> $logfile
    fi
  elif [ "level" == "error" ]; then
    if [ "$loglevel" -ge "0" ]; then
      echo -e "${red}$logtime ERROR: {$function} $msg${nc}" >> $logfile
    fi
  else
    echo -e "${red}$logtime CRIT: {$function} $msg${nc}" >> $logfile
  fi
}

cleanup() {
  for file in `ls $workdir | grep "hv_transaction_export"`; do
    logging info cleanup "Deleting old file $workdir/${file}"
    /bin/rm -f $workdir/${file}
  done;
}

discovery() {
  logging info discovery "Beginning discovery of compressed data..."
  for file in `find $workdir -type f -name "*.zip" -not -path "*${ignore_today}*" -mtime -${newer_than}`; do
    zip -j $workdir/${file_name} $file
  done
  logging info discovery "Done discovering compressed transaction data."
}

export() {
  logging info export "Beginning export of compressed data..."
  scp $workdir/${file_name} hyvee-agi@sftp.hyvee.agilenceinc.com:/Production/HyVeeGKTLOGParser/
  transfer=$?
  if [ "$transfer" != "0" ]; then
    logging error export "Failed while transfering data to hyvee-agi@sftp.hyvee.agilenceinc.com:/Production/HyVeeGKTLOGParser/"
    exit 2
  else 
    logging info export "Successfully transfered data to hyvee-agi@sftp.hyvee.agilenceinc.com:/Production/HyVeeGKTLOGParser/"
  fi
}

logging info main "Starting script..."
cleanup
discovery
export
