#!/bin/bash

ENVIRONMENT=$1

echo "$ENVIRONMENT" | egrep '^chr' >/dev/null
if [ "$?" -eq 0 ]; then
    CHRENV=`echo "$ENVIRONMENT" | awk -F '-' '{print $3}'`
    source /opt/hy-vee/scripts/${CHRENV}/env-setup.sh
else
    source /opt/hy-vee/scripts/env-setup.sh
fi

voup=$(netstat -anl | grep -c $VOCOLLECT_PORT)
tnet=$(echo quit | telnet $PARTNER_NODE $VOCOLLECT_PORT | grep -ci "Escape character is")
rouge_pid=$(netstat -panl | grep $VOCOLLECT_PORT | grep -v "java" | grep -v "-" | awk '{ print $7 }')
rouge_pid_count=$(netstat -panl | grep $VOCOLLECT_PORT | grep -v "java" | grep -v "-" | awk '{ print $7 }' | wc -l)

max="100"
min="0"

if [ "$voup" -ne "0" ]; then
    used="50"
else
    used="25"
fi

perfdata="State=$used"

if [ "$voup" -ne "0" ] && [ "$rouge_pid_count" -eq "0" ]; then
    echo "OK - Vocollect UP ON $HOSTNAME | $perfdata"
    exit 0
elif [ "$tnet" -eq "1" ] && [ "$rouge_pid_count" -eq "0" ]; then
    echo "OK - Vocollect UP ON $PARTNER_NODE | $perfdata"
    exit 0
elif [ "$rouge_pid_count" -ne "0" ]; then
    echo "Warning - Vocollect has a Rouge Pid! $rouge_pid | $perfdata"
else
    echo "Critical - Vocolect DOWN!!! | $perfdata"
    exit 2
fi

