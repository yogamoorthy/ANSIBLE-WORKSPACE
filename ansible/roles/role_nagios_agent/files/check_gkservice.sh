#!/usr/bin/env bash

if [ -z "$1" ];
  then
    echo "Missing Parameters! Syntax: ./$(basename $0) GK-Application-Name"
    exit 3
  else
    app="$1"
fi

server=$(hostname -f)
username="gktomcatadmin"
password=$(echo U2FsdGVkX18MNp08zOZ6RV0VlOIi4jTPuchxlN2zS4zXKJwqKKuXIfG2/D+D00Do | openssl enc -aes-128-cbc -a -d -salt -pass pass:asdffdsa)

check_service() {
  app_status=$(curl --user $username:$password http://$server:8080/manager/text/list -s | grep $app | awk -F: '{ print $2 }')
  app_connections=$(curl --user $username:$password http://$server:8080/manager/text/list -s | grep $app | awk -F: '{ print $3 }')
  case ${app_status} in
    running)
      echo "OK - $app is Running | Connections=$app_connections"
      exit 0
      ;;
    stopped)
      echo "Warning - ${app} is Stopped | Connections=$app_connections"
      exit 1
      ;;
    *)
      echo "UNKNOWN - ${app} is not found."
      exit 3
      ;;
  esac
}

check_service