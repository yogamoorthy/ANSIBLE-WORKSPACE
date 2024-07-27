 #!/bin/bash
###################################################################################################
# This script gathers information from the MIP Trust Store and outputs it for easier consumption. #
###################################################################################################

# Variables
script=`basename ${BASH_SOURCE[0]}`
# Converts input to lowercase
warehouse="${1,,}"
env="${2,,}"
chr="${3,,}"

# Check for Chariton 
# CHR is different because of the three separate instances GRO, HBC, and PER
# This is probably more complicated than it needs to be right now, but future me (or you) will simplify it
if [ $warehouse == "chr" ]; then
  if [ $env == "dev" ]; then
    if [ $chr == "gro" ]; then
      mip_home="/manh/apps/scope/mip_gro"
    elif [ $chr == "hbc" ]; then
      mip_home="/manh/apps/scope/mip_hbc"
    elif [ $chr == "per" ]; then 
      mip_home="/manh/apps/scope/mip_per"
    fi
  else 
  # CHR Prod has different ports
    if [ $chr == "gro" ]; then
      mip_home="/manh/apps/scope/gro/mip"
    elif [ $chr == "hbc" ]; then
      mip_home="/manh/apps/scope/hbc/mip"
    elif [ $chr == "per" ]; then 
      mip_home-="/manh/apps/scope/per/mip"
    fi
  fi
elif [ $warehouse == "che" ]; then
# CHE DEV has a different directory structure
  if [ $env == "dev" ]; then
    mip_home="/manh/scope/mip"
  fi
else
  mip_home="/manh/apps/scope/mip*"
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

function mipPass {
  file=$(find $mip_home/profile-root -name "server.xml")
  pass=$(grep "mip-keys" $file | awk '{print $5}' | sed 's/keystorePass=//g' | sed 's/"//g')
}

function miptrustCert {
  mipPass

  host="MIP SAML Truststore"
  keystore=$(find $mip_home -name "mip-trustcerts.jks" | grep -i "$mip_home/profile-root/mip")
  issue_date=$(keytool -storepass $pass -list -v -keystore $keystore -alias sp | grep -i "valid" | awk '{print $4,$5,$8}')
  exp_date=$(keytool -storepass $pass -list -v -keystore $keystore -alias sp | grep -i "valid" | awk '{print $11,$12,$15}')
  
  echo
  echo "$host"
  echo "Located: $keystore"
  echo "Issued: $issue_date"
  echo "Expires: $exp_date"
  echo
  checkExpiration
}

case $1 in 
  che | CHE | chr | CHR | ctl | CTL | ldc | LDC | lmr | LMR | pdi | PDI)
  miptrustCert
  ;;
  *)
  printHelp
  ;;
esac