#!/bin/bash
# Script to check the status of the export_transactions job:
# Runs on gkprodsdc1-v server as root
# Runs on a cronjob in /etc/crontab
# 47 1 * * * root /opt/hy-vee/scripts/export_transactions.sh 1 
# For use with Nagios monitoring and alerting.

logfile=/var/log/gk/export_transactions.log

# $? = 0 means there were results when searching for errors
# $? = 1 means there were no results when searching for errors
tail -n1 $logfile | grep -iE 'crit|error|warn' > /dev/null 2>&1
if [ "$?" -eq 0 ]; then 
    echo "Export process is not functioning."
    exit 2
else
    echo "Export process is functioning."
    exit 0
fi
