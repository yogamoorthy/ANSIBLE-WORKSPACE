#!/bin/bash
# Script to gather current java memory usage, compare with maximum java memory and then calculate percentage.
# For use with Nagios monitoring and alerting.

# Default values can be overridden with the -w and -c flags
warnP=80
critP=95
testP=0

while getopts w:c:t:h: flag
do
    case "${flag}" in
        w) 
          warnP=${OPTARG}
          # echo -e "Setting warnP: $warnP" #uncomment if needed when testing
          ;;
        c) 
          critP=${OPTARG}
          # echo -e "Setting critP: $critP" #uncomment if needed when testing
          ;;
        t) 
          testP=${OPTARG}
          # echo -e "Setting testP: $testP" #uncomment if needed when testing
          ;;
        h) 
          printHelp
          ;;
    esac
done

# Variables
java_bin="/usr/local/gkretail_local/3rdparty/jdk/bin"
java_pid=$(sudo -u gkadmin $java_bin/jps -v | grep 'Bootstrap' | awk '{ print $1 }')
script=`basename ${BASH_SOURCE[0]}`

# Color Variables
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
reset='\033[0m'

# help function
function printHelp {
  echo -e "${green}Usage: $script -w {warning} -c {critical} -t {test percentage}${reset}"\\n
  echo -e "${lightgreen}Command switches are optional, default values are 80% for warning and 95% for critical."
  echo -e "-w - Sets warning value for Memory Usage. Default is 80%"
  echo -e "-c - Sets critical value for Memory Usage. Default is 95%"
  echo -e "-t - Set a test percentage and ignore actual JAVA values - for testing script output"
  echo -e "-h - Displays this help message${reset}"\\n
  echo -e "${yellow}Example: ./$script -w 80 -c 90${reset} -t 99"\\n
  exit 3
}

function calcPercent {
  java_max_mem=$(cat /usr/local/gkretail_local/3rdparty/tomcat/bin/setenv.sh | grep -i "xms" | awk '{ print $3 }' | sed 's/-Xms//g' | sed 's/M"//g')
  # The output of $calc_usage is a decimal number.
  calc_usage=$(sudo -u gkadmin $java_bin/jstat -gc $java_pid 2>/dev/null | tail -n 1 | awk '{split($0,a," "); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}')
  # $java_usage rounds the decimal output from $calc_usage to a whole number.
  java_usage=${calc_usage%.*}
  if [[ $java_usage -eq 0 ]]; then
    echo "Something is wrong. Java memory usage is at 0 MB | JVM_Mem_Usage_percent=0"
    exit 3
  else
    percent=$(echo "scale=0;$java_usage*100/$java_max_mem" | bc -l )
  fi
}

if [ "$testP" -gt "0" ]; then
  calcPercent
  percent=$testP
  echo -e "Testing!"
  echo -e "percent: $percent; critP: $critP; warnP: $warnP; testP: $testP"
else
  calcPercent
fi
# Output
if [[ $percent -ge $critP ]]; then
  echo -e "CRITICAL: GK JAVA Memory Usage is $java_usage MB out of $java_max_mem MB - Java Usage is $percent% | JVM_Mem_Usage_percent=$percent"
  exit 2
elif [[ $percent -ge $warnP ]]; then
  echo -e "WARNING: GK JAVA Memory Usage is $java_usage MB out of $java_max_mem MB - Java Usage is $percent% | JVM_Mem_Usage_percent=$percent"
  exit 1
else
  echo -e "OK: GK JAVA Memory Usage is $java_usage MB out of $java_max_mem MB - Java Usage is $percent% | JVM_Mem_Usage_percent=$percent"
  exit 0
fi
