#!/bin/bash

# Description: discovers log directories and cleans vocollect logs after 1 month
#              any other logs after 2 weeks
#              any cores after 2 week
#              any artifacts used to generate cores after 1 day
# Author: Tony Welder
# E-Mail: twelder@hy-vee.com


BASE="/manh/apps/scope"
#dealing wtih yet another standard I've found
if [ -d "/manh/scope" ]; then
  BASE="/manh/scope"
fi

delete_file () {
  /bin/rm -rf $1
  if [ -e $1 ]; then
    logger "ERROR: WMS log_killer.sh cron failed to delete $1"
  else
    logger "INFO: WMS log_killer.sh cron deleted $1"
  fi
}

#discover if we need to deal with app clusters or just a single apps
#in other words, we need to deal with differnt directory structures
SINGLE_APP=false
for directory in `ls ${BASE}`; do
  if [ -d ${BASE}/${directory}/profile-root ]; then
    SINGLE_APP=true
    break
  fi
done

if [ "$SINGLE_APP" = true ];then
  for app in `ls ${BASE}`; do
    if [ -d ${BASE}/${app}/profile-root ]; then
      if [ -d ${BASE}/${app}/tools/bin/WMSnapShotCollector ]; then
          for snapshot_dir in `find ${BASE}/${app}/tools/bin/WMSnapShotCollector \
          -maxdepth 1 -type d -name '*log*'  -mtime +1`; do
            delete_file $snapshot_dir
          done
      fi
      if [ -d ${BASE}/${app}/cbs/logs ]; then
          for log in `find ${BASE}/${app}/cbs/logs \
          -maxdepth 1 -type f -name '*.log'  -mtime +30`; do
            delete_file $log
          done
      fi
      if [ -d ${BASE}/${app}/cbs/logs/cores ]; then
          for core in `find ${BASE}/${app}/cbs/logs/cores \
          -maxdepth 2 -type f -name 'core*'  -mtime +14`; do
            delete_file $core
          done
      fi
      for subfolder in `ls ${BASE}/${app}/profile-root/`; do
        if [ -d ${BASE}/${app}/profile-root/${subfolder}/log ] \
        || [ -d ${BASE}/${app}/profile-root/${subfolder}/logs ]; then
          for log in `find ${BASE}/${app}/profile-root/${subfolder}/log \
          -maxdepth 1 -type f -name '*[._]log.*'  -mtime +14 2> /dev/null`; do
            delete_file $log
          done
          for log in `find ${BASE}/${app}/profile-root/${subfolder}/logs \
          -maxdepth 1 -type f -name '*[._]log.*'  -mtime +14 2> /dev/null`; do
            delete_file $log
          done
        fi
      done
    fi
  done
else
# runtime
  for app_cluster in `ls ${BASE}`; do
    for app in `ls ${BASE}/${app_cluster}`; do
      if [ -d ${BASE}/${app_cluster}/${app}/profile-root ]; then
        if [ -d ${BASE}/${app_cluster}/${app}/tools/bin/WMSnapShotCollector ]; then
            for snapshot_dir in `find ${BASE}/${app_cluster}/${app}/tools/bin/WMSnapShotCollector \
            -maxdepth 1 -type d -name '*log*'  -mtime +1`;do
              delete_file $snapshot_dir
            done
        fi
        if [ -d ${BASE}/${app_cluster}/${app}/cbs/logs ]; then
            for log in `find ${BASE}/${app_cluster}/${app}/cbs/logs \
            -maxdepth 1 -type f -name '*.log'  -mtime +30`;do
              delete_file $log
            done
        fi
        if [ -d ${BASE}/${app_cluster}/${app}/cbs/logs/cores ]; then
            for core in `find ${BASE}/${app_cluster}/${app}/cbs/logs/cores \
            -maxdepth 2 -type f -name 'core*'  -mtime +14`; do
              delete_file $core
            done
        fi
        for subfolder in `ls ${BASE}/${app_cluster}/${app}/profile-root/`; do
          if [ -d ${BASE}/${app_cluster}/${app}/profile-root/${subfolder}/log ] \
          || [ -d ${BASE}/${app_cluster}/${app}/profile-root/${subfolder}/logs ]; then
            for log in `find ${BASE}/${app_cluster}/${app}/profile-root/${subfolder}/log \
            -maxdepth 1 -type f -name '*[._]log.*'  -mtime +14 2> /dev/null`; do
              delete_file $log
            done
            for log in `find ${BASE}/${app_cluster}/${app}/profile-root/${subfolder}/logs \
            -maxdepth 1 -type f -name '*[._]log.*'  -mtime +14 2> /dev/null`; do
              delete_file $log
            done
          fi
        done
      fi
    done
  done
fi
