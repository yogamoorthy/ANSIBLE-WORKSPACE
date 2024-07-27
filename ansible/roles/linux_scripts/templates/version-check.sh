#!/bin/bash
# Checks currently installed Java Version on GK systems
function checkJavaVers {
  version=$(/usr/local/gkretail_local/3rdparty/jdk/bin/java -version 2>&1 | grep version | awk '{print $3}' | sed -e 's/^"//' -e 's/"$//')
  chunk=( ${version//./ } )
  java_major=${chunk[0]}
  java_minor=${chunk[1]}
  java_patch=${chunk[2]}
  # If there's an underscore in the patch variable; remove it.
  if [[ $java_patch =~ ^[0-9_]+$ ]]
  then
    java_patch=${java_patch//_/}
  fi
}

checkJavaVers || { echo "Version check failed" ; exit; }

if [ $1 = "major" ]
then
  echo "$java_major"
elif [ $1 = "minor" ]
then
  echo "$java_minor"
elif [ $1 = "patch" ]
then
  echo "$java_patch"
else
  echo
  echo "Please use major/minor/patch as input."
  echo "Example:"
  echo "./version-check.sh major"
fi