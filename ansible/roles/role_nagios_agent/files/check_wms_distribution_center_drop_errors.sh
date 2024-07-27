#!/bin/bash

if [ "$1" = "-c" ] && [ "$2" -gt "0" ]; then

  result=""
  input=$'find /apps/scope/mif/transfer/ -type d -wholename '*/error' -print0'

  while read -d $'\0' -r dir; do
    files=("$dir"/*.xml)
    if [ $(echo "${files[0]}" | grep -v '[*]') ]; then
      result+="\n"
      printf -v line "%5d files in directory %s\n" "${#files[@]}" "$dir"
      result+="${line}"
    fi
  done < <($input)

  if [ -z "$result" ]; then
    echo "Drop error folders empty, no errors"
    exit 0
  else
    echo -e $result
    exit 2
    echo -e $result
  fi
else # If inputs are not as expected, print help.
  sName="$(echo $0 | awk -F '/' '{print $NF}')"
  echo -e "# Usage:\t$sName -c"
  echo -e "\t\t= warnlevel and critlevel is numeric value"
  echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_fulfillment_drop_errors.sh -c 1"
  exit
fi