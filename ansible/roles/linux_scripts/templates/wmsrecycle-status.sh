#!/bin/bash

if [ -z '$1' ] && [ -z "$2" ];
  then
    echo "Supply an application name as an argument"
    exit 1
  else
    app_home="$1"
    app="$2"
fi

app_status=$(ps -ef | grep $app_home/$app | grep -c java)

if [ "$app_status" == "1" ];
  then
    echo "Running"
  elif [ "$app_status" == "0" ];
    then
      echo "Stopped"
  elif [ "$app_status" -ge "2" ];
    then
      echo "Corrupt, it is recomended to restart the application."
  else
    echo "We recived an unplanned response. Contact an Administrator."
fi
