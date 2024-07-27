#!/usr/bin/env bash

if [ -z "$1" ];
  then
    echo "Missing Parameters! Syntax: ./$(basename $0) Service-Name"
    exit 3
  else
    app="$1"
fi

check_service() {
  app_status=$(systemctl is-active $app)
  process_name=$(systemctl status $app | grep 'Main PID' | awk '{ print $4 }' | sed 's|[()]||g')
  app_connections=$(lsof -c $process_name 2>/dev/null | tail -n +$((1+1)) | awk '{ print $2 }' | sort -u | wc -l)
  case ${app_status} in
    active)
      echo "OK - $app is Active | Connections=$app_connections"
      exit 0
      ;;
    inactive)
      echo "Warning - ${app} is Inactive | Connections=$app_connections"
      exit 1
      ;;
    failed)
      echo "Critical - ${app} is Failed | Connections=$app_connections"
      exit 1
      ;;
    *)
      echo "UNKNOWN - ${app} is not found."
      exit 3
      ;;
  esac
}

check_service