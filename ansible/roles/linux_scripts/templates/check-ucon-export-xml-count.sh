#!/bin/bash

scriptname="$(basename $0 | sed s'/\.sh//'g)"
lockfile="/tmp/$scriptname.pid"
logfile="/var/log/gk/$scriptname.log"
loglevel=2
export_dir="/usr/local/gkretail/ucon/tenants/001/dataexchange/export_channel/export"

timestamp() {
  date "+%d-%b-%Y %H:%M:%S:%3N"
}

# Exit Handler
trap cleanup EXIT

cleanup() {
  exit_code=$?

  if [ "${exit_code}" == "0" ]; then
    rm -f $lockfile
    exit 0
  elif [ "${exit_code}" == "101" ]; then
    exit 1
  else
    rm -f $lockfile
    logging debug 0000 cleanup "Recived unknown exit code - $exit_code"
    logging debug 0000 cleanup "Forcing cleanup of $lockfile"
    exit 2
  fi
}

pid_lock() {
  for pid in $(cat "$lockfile"); do
      if [ $pid != $$ ]; then
        logging debug 0000 pid_lock "Another process with PID $pid"
        exit 101
      fi
  done
}

logging() {
  level="$1"
  store_code="$2"
  function="$3"
  msg="$4"

  if [ "$level" == "debug" ]; then
    if [ "$loglevel" -ge "3" ]; then
      echo "$(date "+%d-%b-%Y %H:%M:%S:%3N") DEBUG: [$store_code] {$function} $msg" >> $logfile
    fi
  elif [ "$level" == "info" ]; then
    if [ "$loglevel" -ge "2" ]; then
      echo "$(date "+%d-%b-%Y %H:%M:%S:%3N") INFO: [$store_code] {$function} $msg" >> $logfile
    fi
  elif [ "$level" == "warn" ]; then
    if [ "$loglevel" -ge "1" ]; then
      echo "$(date "+%d-%b-%Y %H:%M:%S:%3N") WARN: [$store_code] {$function} $msg" >> $logfile
    fi
  elif [ "level" == "error" ]; then
    if [ "$loglevel" -ge "0" ]; then
      echo "$(date "+%d-%b-%Y %H:%M:%S:%3N") ERROR: [$store_code] {$function} $msg" >> $logfile
    fi
  else
    echo "$(date "+%d-%b-%Y %H:%M:%S:%3N") CRIT: [$store_code] {$function} $msg" >> $logfile
  fi
}

if [ -f "$lockfile" ]; then
  logging debug 0000 main "lockfile found - $lockfile"
  pid_lock
else
  logging debug 0000 main "No lockfile found"
  logging debug 0000 main "Adding lockfile - $lockfile"
  echo $$ > $lockfile
fi

file_count=$(ls -U ${export_dir} | grep -c "xml")
logging info 0000 main "UCON export directory file count - $file_count"
