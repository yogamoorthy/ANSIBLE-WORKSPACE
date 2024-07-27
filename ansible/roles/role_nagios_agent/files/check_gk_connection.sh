#!/bin/bash

crit="$2"
hostname=$(hostname)

if [ $(echo $hostname | grep -i prod &>/dev/null; echo $?) == "0" ]
  then
    env="prod"
elif [ $(echo $hostname | grep -i qa &>/dev/null; echo $?) == "0" ]
  then
    env="qa"
elif [ $(echo $hostname | grep -i dev &>/dev/null; echo $?) == "0" ]
  then 
    env="dev"
fi 

base_name="$1"
node1="${base_name}1"
node2="${base_name}2"

hostname_node1="gk${env}${node1}-v"
hostname_node2="gk${env}${node2}-v"

res_node1="$(nslookup $hostname_node1 | grep -A2 "Non-authoritative" | grep "Address" | awk '{ print $2 }')"
res_node2="$(nslookup $hostname_node2 | grep -A2 "Non-authoritative" | grep "Address" | awk '{ print $2 }')"

pid_list_1=$(netstat | egrep -c "$node1|$res_node1")
pid_list_2=$(netstat | egrep -c "$node2|$res_node2")

# This is for controlling single to multi node metric skew.
if [ ! -z "$res_node2" ];
  then
    total_list=$(netstat | grep -v 'TIME_WAIT' | egrep -c "$base_name|$res_node1|$res_node2")
  else
    total_list=$(netstat | grep -v 'TIME_WAIT' | egrep -c "$base_name|$res_node1")
    pid_list_2="0"
fi 

if [ "$total_list" -gt "$crit" ]; then
  echo "$total_list Connections from $base_name|TOTAL=$total_list;;;; $node1=$pid_list_1;;;; $node2=$pid_list_2;;;;"
  exit 2
elif [ "$total_list" -lt "$crit" ]; then
  echo "$total_list Connections from $base_name|TOTAL=$total_list;;;; $node1=$pid_list_1;;;; $node2=$pid_list_2;;;;"
  exit 0
else
  echo "$total_list Connections from $base_name|TOTAL=$total_list;;;; $node1=$pid_list_1;;;; $node2=$pid_list_2;;;;"
  exit 3
fi
