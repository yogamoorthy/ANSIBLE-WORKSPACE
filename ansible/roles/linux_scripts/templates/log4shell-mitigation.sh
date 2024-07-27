#!/bin/bash
# Description:  A simple bash script used to rip out the affected log4j class for CVE-2021-44228.
# finds all jars matching log4j-core2, backs them up and then removes the class from the zip(jar)
#########################
# RUN THIS AS ROOT ONLY #
#########################
##################################
# Use Fully Qualified Paths ONLY #
##################################

# ./badtouch.sh <BASE SEARCH PATH> <IDIOT DETECTION> <ACTION TO BE EXECUTED> <OPTIONAL ARGUMENT>

# example executions
# ./badtouch.sh /manh please dryrun
##### shows what files would of have been modified

# ./badtouch.sh /manh please remove_class
##### will backup files and then modify them in place

# ./badtouch.sh /manh please backup_only
##### will backup all files, preserving permissions and file path

# ./badtouch.sh /manh please recover
##### will copy orginals back

# ./badtouch.sh /manh please generate_outfile
##### will find vulnerable jars and store a list for future use and backup

# ./badtouch.sh /manh please remove_class_from_outfile
##### will read from outfile and remediate

# ./badtouch.sh /manh please remove_class ignore_nfs
##### will do everything remove_class does but ignore nfs mounts for search

#gkqasdc1-v:/home/twelder # mount | grep nfs | awk -F  ' on ' '{print $2}' | a
#/mnt/aggnmon
#/usr/local/gkretail
base_search_path="$1"
idiot_detection="$2"
verb="$3"
option="$4"

home_dir=`echo ~`
backup_dir="${home_dir}/CVE-2021-44228_backup"

function all_the_fail {
  echo "READ SCRIPTS BEFORE YOU RUN THEM!"
  echo "If you're attempting to execute this script without knowing what it does then"
  echo "Please go work for a competitor... they would love to have you."
  exit 1
}

function execute_backup {
  echo "Beginning backup operation"
  mkdir -p $backup_dir
  for jar in `find $base_search_path -type f -name "log4j-core-2*.jar" -not -path "*.snapshot*" -not -path "/root/CVE-2021-44228_backup/*" 2> /dev/null`; do
    if [ -f "${backup_dir}${jar}" ]; then
      #for accidental double execution
      echo "skipping backup for ${backup_dir}${jar}"
    else
      cp --parents -p $jar ${backup_dir}/
      if [ -f "${backup_dir}${jar}" ]; then
        echo "SUCCESSFULLY backed up ${backup_dir}${jar}"
      else
        echo "FAILED to back up ${backup_dir}${jar}"
        exit 1
      fi
    fi
  done
}

#check if running as root
whoami | grep root > /dev/null
if [ $? -ne 0 ]; then
  all_the_fail
fi
#check if using fully qualified paths
echo $base_search_path | egrep "^/" > /dev/null
if [ $? -ne 0 ]; then
  all_the_fail
fi
#check if they failed to read the script
echo $idiot_detection | egrep "^please$" > /dev/null
if [ $? -ne 0 ]; then
  all_the_fail
fi

#turning off astrisk expansion to avoid what can only be described as hell
set -f
default_ignore=`echo "-not -path *.snapshot* -not -path /root/CVE-2021-44228_backup/*"`
if [ "$option" = "ignore_nfs" ]; then
  ignore="$default_ignore $(mount | grep nfs | grep -v .snapshot| awk -F  ' on ' '{print $2}' | awk -v ORS=' ' -F ' type ' '{print " -not -path " $1"/*"}')"
else
  ignore=$default_ignore
fi

if [ "$verb" = "dryrun" ]; then
  echo "#################################################"
  echo "badtouch.sh would of modified the following files"
  echo "#################################################"
  find $base_search_path -type f -name "log4j-core-2*.jar" $ignore 2> /dev/null
  set +f
  exit 0
fi

if [ "$verb" = "backup_only" ]; then
  execute_backup
  set +f
  exit 0
fi

if [ "$verb" = "recover" ]; then
  for jar in `find $base_search_path -type f -name "log4j-core-2*.jar" $ignore 2> /dev/null`; do
    echo "Recovering $jar"
    echo "size before $(ls -al $jar | awk '{print $5}')"
    cp -fp ${backup_dir}/${jar} $jar
    echo "size after $(ls -al $jar | awk '{print $5}')"
    echo "################################################"
  done
  set +f
  exit 0
fi

if [ "$verb" = "remove_class" ]; then
  execute_backup
  for jar in `find $base_search_path -type f -name "log4j-core-2*.jar" $ignore 2> /dev/null`; do
    echo "attempting to modify $jar"
    echo "size before $(ls -al $jar | awk '{print $5}')"
    zip -q -d $jar org/apache/logging/log4j/core/lookup/JndiLookup.class
    echo "size after $(ls -al $jar | awk '{print $5}')"
    echo "############################"
  done
  set +f
  exit 0
fi

if [ "$verb" = "generate_outfile" ]; then
  execute_backup
  echo "begin generation of out file"
  find $base_search_path -type f -name "log4j-core-2*.jar" $ignore 2> /dev/null > $home_dir/log4jshell_migitation_outfile
  echo "done!"
  set +f
  exit 0
fi

if [ "$verb" = "remove_class_from_outfile" ]; then
  echo "begin read of outfile"
  for jar in `cat $home_dir/log4jshell_migitation_outfile`; do
    echo "attempting to modify $jar"
    echo "size before $(ls -al $jar | awk '{print $5}')"
    zip -q -d $jar org/apache/logging/log4j/core/lookup/JndiLookup.class
    echo "size after $(ls -al $jar | awk '{print $5}')"
    echo "############################"
  done
  set +f
  echo "done!"
  exit 0
fi

set +f
exit 1

