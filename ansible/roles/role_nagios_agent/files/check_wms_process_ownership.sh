#!/bin/bash

# quick and dirty process ownership check
# if it finds that any java processes are owned by root, then it shoots a critical

ROOT_JAVA_PROCESSES="$(ps auxww | grep java | grep -v grep |  awk '{print $1}' | grep "root"| wc -l)"

if [ $ROOT_JAVA_PROCESSES -gt 0 ]; then
    echo "CRITICAL: There are currently $ROOT_JAVA_PROCESSES java processes owned by root!"
    exit 2
elif [ $ROOT_JAVA_PROCESSES -lt 1 ]; then
    echo "OK: there are $ROOT_JAVA_PROCESSES java processes owned by root"
    exit 0
fi

#To resolve, do the following steps:
#SSH into the affected host and become root. do 'ps auxww | grep java | grep root'
#to discover which processes are affected, remember the affected processes.
#stop the affected processes as root, one by one (do not use /opt/hy-vee/scripts/app)
#once all root process are stopped. do a 'chown -R scopeadm:manh /man/apps/scope/'
#to fix the permissions.  Now stop the rest of the processes normally by
#changing to the proper user, do 'su - scopeadm' and
#execute '/opt/hy-vee/scripts/app stop', Once complete.. ensure that
#the app is truly down by executing '/opt/hy-vee/scripts/app status'.  If all apps are
#down, then bring them back up by '/opt/hy-vee/scripts/app start'.
#THE FINAL STEP is to find out who started manh wrong and yell at them.

