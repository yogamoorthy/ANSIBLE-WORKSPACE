#!/bin/bash
##############################################################################################
# This script gathers WMS SSL certificate information and outputs it for easier consumption. #
##############################################################################################

# Variables
script=`basename ${BASH_SOURCE[0]}`
# Converts input to lowercase
warehouse="${1,,}"
env="${2,,}"
chr="${3,,}"

# Check for Chariton 
# CHR ports are different because of the three separate instances GRO, HBC, and PER
# This is probably more complicated than it needs to be right now, but future me (or you) will simplify it
if [ $warehouse == "chr" ]; then
  if [ $env == "dev" ]; then
    if [ $chr == "gro" ]; then
      port=16001
    elif [ $chr == "hbc" ]; then
      port=24001
    elif [ $chr == "per" ]; then 
      port=26001
    fi
  else 
  # CHR Prod has different ports
    if [ $chr == "gro" ]; then
      port=10001
    elif [ $chr == "hbc" ]; then
      port=15001
    elif [ $chr == "per" ]; then 
      port=20001
    fi
  fi
elif [ $warehouse == "che" ]; then
# CHE DEV has a different port
  if [ $env == "dev" ]; then
    port=13001
  fi
else
  port=10001
fi

# Color Variables
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
reset='\033[0m'

# help function
function printHelp {
  echo -e "${green}Usage: ./$script {warehouse} {environment} ${reset}"\\n
  echo -e "${lightgreen}Options: (Required)"
  echo -e "  Warehouse: CHE, CTL, CHR, LMR, PDI"
  echo -e "  Environment: DEV or PROD"
  echo -e "Options: (Chariton Only)"
  echo -e "  Chariton: GRO, HBC, PER ${reset}"
  echo
  echo -e "${yellow}Example Usage: ./$script lmr dev"
  echo -e "or for Chariton ./$script chr prod hbc ${reset}"\\n
  exit 1
}

function sslCert {
  # Check to see if DEV environment was specificed
  # The DEV environments are not standardized so the checks here get a bit complicated
  if [ $env == "dev" ]; then
    host="https://${warehouse}devwms.hy-vee.net:$port"
    issue_date=$(curl https://${warehouse}devwms.hy-vee.net:$port -vI --stderr - | grep "start date" | cut -d ":" -f 2- | awk '{print $1,$2,$4}')
    exp_date=$(curl https://${warehouse}devwms.hy-vee.net:$port -vI --stderr - | grep "expire date" | cut -d ":" -f 2- | awk '{print $1,$2,$4}')
    if [ $warehouse == "che" ] || [ $warehouse == "pdi" ] || [ $warehouse == "chr" ]; then
      host="https://${warehouse}devapp1-v.hy-vee.net:$port"
      issue_date=$(curl https://${warehouse}devapp1-v.hy-vee.net:$port -vI --stderr - | grep "start date" | cut -d ":" -f 2- | awk '{print $1,$2,$4}')
      exp_date=$(curl https://${warehouse}devapp1-v.hy-vee.net:$port -vI --stderr - | grep "expire date" | cut -d ":" -f 2- | awk '{print $1,$2,$4}')    
    fi
  else
    host="https://${warehouse}wms.hy-vee.net:$port"
    issue_date=$(curl https://${warehouse}wms.hy-vee.net:$port -vI --stderr - | grep "start date" | cut -d ":" -f 2- | awk '{print $1,$2,$4}')
    exp_date=$(curl https://${warehouse}wms.hy-vee.net:$port -vI --stderr - | grep "expire date" | cut -d ":" -f 2- | awk '{print $1,$2,$4}')
  fi
  
  echo
  echo "$host"
  echo "Issued: $issue_date" 
  echo "Expires: $exp_date"
  echo
  checkExpiration
}

function gatherDates {
  # Converts date from "May 6 2030" format to "2030-05-06" format
  future_date=$(date -d "$exp_date" +%Y-%m-%d)
  today_date=$(date +%Y-%m-%d)
}

function checkExpiration {
  gatherDates
  # Converts dates to seconds and then subtracts the difference to determine the number of days until expiration
  days_left=$((($(date -d "$future_date" +%s) - $(date -d "$today_date" +%s))/86400))

  if [[ $days_left -le 14 ]]; then
    msg="${red}CRITICAL: Certificate expires in $days_left days!${reset}"
    echo -e "$msg"
    exit 2
  elif [[ $days_left -le 30 ]]; then
    msg="${yellow}WARNING: Certificate expires in $days_left days. Replace certificate soon.${reset}"
    echo -e "$msg"
    exit 1
  elif [[ $days_left -le 60 ]]; then
    msg="${lightgreen}Certificate expires in $days_left days. Please begin planning to replace certificate.${reset}"
    echo -e "$msg"
    exit 1
  else
    msg="${green}Certificate expires in $days_left days.${reset}"
    echo -e "$msg"
    exit 0
  fi
}

case $1 in 
  che | CHE | chr | CHR | ctl | CTL | ldc | LDC | lmr | LMR | pdi | PDI)
  sslCert
  ;;
  *)
  printHelp
  ;;
esac
