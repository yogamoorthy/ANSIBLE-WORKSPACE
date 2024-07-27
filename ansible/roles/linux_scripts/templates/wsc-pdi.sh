#!/bin/bash

# Is WSC already running?
wsc_running=$(ps -ef | grep "/usr/bin/ksh ./WSC.sh" | grep -v grep | wc -l)

if [ "$wsc_running" != "0" ];
  then
    echo "WSC is still running"
    exit
fi

# WSC Directory
wsc_dir="/manh/apps/scope/wmsprod/tools/bin/WMSnapShotCollector"

# Move into the wsc directory and run the collector script
cd $wsc_dir
./WSC.sh &> /dev/null
echo "The Process is Starting.. Please Hold..."
sleep 60

# Wait for WSC To compleate

wsc_running=$(ps -ef | grep "/usr/bin/ksh ./WSC.sh" | grep -v grep | wc -l)
while [ "$wsc_running" != "0" ];
  do
    echo "The Process is Still Running.. Please Hold.."
    sleep 45
    wsc_running=$(ps -ef | grep "/usr/bin/ksh ./WSC.sh" | grep -v grep | wc -l)
done

##
# Zip File Name
zip_logs="logs-`date '+%Y%m%d-%R'`.zip"
cd $wsc_dir
zip -r $wsc_dir/$zip_logs ./logs &> /dev/null