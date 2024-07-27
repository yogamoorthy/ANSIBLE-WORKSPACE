#!/bin/bash
# Script to gather current java memory usage, compare with maximum java memory and then calculate percentage.
# For use with Nagios monitoring and alerting.

# Variables
jps="/etc/alternatives/jps"
jstat="/etc/alternatives/jstat"
script=`basename ${BASH_SOURCE[0]}`
host=$(hostname)
# Converts input to lowercase
app="${5,,}"
env="${6,,}"
host="${host,,}"
# Default values can be overridden with the -w and -c flags
warnP=80
critP=95
testP=0

# Color Variables
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
reset='\033[0m'

while getopts w:c:t:h: flag
do
    case "${flag}" in
        w) 
          warnP=${OPTARG}
          #echo -e "Setting warnP: $warnP" #uncomment if needed when testing
          ;;
        c) 
          critP=${OPTARG}
          #echo -e "Setting critP: $critP" #uncomment if needed when testing
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

# help function
function printHelp {
    echo -e "${green}Usage: $script -w {warning} -c {critical} {application}${reset}"\\n
    echo -e "${lightgreen}Arguments are required. Default values are 80% for warning and 95% for critical."
    echo -e "-w - Sets warning value for Memory Usage."
    echo -e "-c - Sets critical value for Memory Usage."
    echo -e "-h - Displays this help message"\\n
    echo -e "You must also specify the application. Choose one of the following:"
    echo -e "{MIP, MDA, WM, LM, DB}${reset}"\\n
    echo -e "${yellow}Example: ./$script -w 80 -c 90 mip${reset}"\\n
    echo -e "${lightgreen}Chariton is different because of the three warehouses."
    echo -e "For Chariton, you must include the warehouse in the hostname like this:${reset}"\\n
    echo -e "${yellow}Example: ./$script -w 80 -c 90 mda chrdevapp1-v-gro${reset}"\\n
    exit 3
}

# Source the Environment Variables
# Check for Chariton 
# CHR is different because of the three separate instances GRO, HBC, and PER
echo "$env" | egrep '^chr' > /dev/null
if [ "$?" -eq 0 ]; then
    chr_env=`echo "$env" | awk -F '-' '{print $3}'`
    source /opt/hy-vee/scripts/${chr_env}/env-setup.sh
    mip_home="/manh/apps/scope/$mip_name"
    mda_home="/manh/apps/scope/$mda_name"
    wm_home="/manh/apps/scope/$wm_name"
    lm_home="/manh/apps/scope/$lm_name"
    db_home="/manh/apps/scope/$db_name"
else
    source /opt/hy-vee/scripts/env-setup.sh
    mip_home="$manh_home/$mip_name"
    mda_home="$manh_home/$mda_name"
    wm_home="$manh_home/$wm_name"
    lm_home="$manh_home/$lm_name"
    db_home="$manh_home/$db_name"
fi

function gatherStats() {
    #MIP
    #PDI environment is weird. So, we run a special check if the server is a PDI server
    if [[ $host = pdi* ]]; then
      mip_java_pid=$(sudo -u $admin_user $jps -v | grep $mip_home | awk '{print $1}')
      mip_java_max_mem=$(ps -ef | grep $mip_home | grep -o "\w*Xmx\w*" | sed 's/Xmx//g' | sed 's/m//g')      
    else
      mip_java_pid=$(sudo -u $admin_user $jps -v | grep "${mip_home}/profile-root" | awk '{print $1}')
      mip_java_max_mem=$(ps -ef | grep $mip_home/profile-root | grep -o "\w*Xmx\w*" | sed 's/Xmx//g' | sed 's/m//g')
    fi

    #MDA
    mda_java_pid=$(sudo -u $admin_user $jps -v | grep "${mda_home}/profile-root" | awk '{print $1}')
    mda_java_max_mem=$(ps -ef | grep $mda_home/profile-root | grep -o "\w*Xmx\w*" | sed 's/Xmx//g' | sed 's/m//g')
    
    #WM
    wm_java_pid=$(sudo -u $admin_user $jps -v | grep "${wm_home}/profile-root" | awk '{print $1}')
    wm_java_max_mem=$(ps -ef | grep $wm_home/profile-root | grep -o "\w*Xmx\w*" | sed 's/Xmx//g' | sed 's/m//g')

    #LM
    lm_java_pid=$(sudo -u $admin_user $jps -v | grep "${lm_home}/profile-root" | awk '{print $1}')
    lm_java_max_mem=$(ps -ef | grep $lm_home/profile-root | grep -o "\w*Xmx\w*" | sed 's/Xmx//g' | sed 's/m//g')

    #DB
    db_java_pid=$(sudo -u $admin_user $jps -v | grep "${db_home}/profile-root" | awk '{print $1}')
    db_java_max_mem=$(ps -ef | grep $db_home/profile-root | grep -o "\w*Xmx\w*" | sed 's/Xmx//g' | sed 's/m//g')

}

function mipCalcPercent() {
    # The output of $calc_usage is a decimal number.
    # $java_usage rounds the decimal output from $calc_usage to a whole number.
    
    mip_calc_usage=$(sudo -u $admin_user $jstat -gc $mip_java_pid 2>/dev/null | tail -n 1 | awk '{split($0,a," "); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}')
    mip_java_usage=${mip_calc_usage%.*}
    
    if [[ $mip_java_usage -eq 0 ]]; then
        echo "Something is wrong. MIP Java memory usage is at 0 MB | MIP_JVM_Mem_Usage_percent=0"
        exit 3
    else
        mip_percent=$(echo "scale=0;$mip_java_usage*100/$mip_java_max_mem" | bc -l )
    fi

}

function mdaCalcPercent() {
    # The output of $calc_usage is a decimal number.
    # $java_usage rounds the decimal output from $calc_usage to a whole number.

    mda_calc_usage=$(sudo -u $admin_user $jstat -gc $mda_java_pid 2>/dev/null | tail -n 1 | awk '{split($0,a," "); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}')
    mda_java_usage=${mda_calc_usage%.*}
    
    if [[ $mda_java_usage -eq 0 ]]; then
        echo "Something is wrong. MDA Java memory usage is at 0 MB | MDA_JVM_Mem_Usage_percent=0"
        exit 3
    else
        mda_percent=$(echo "scale=0;$mda_java_usage*100/$mda_java_max_mem" | bc -l )
    fi

}

function wmCalcPercent() {
    # The output of $calc_usage is a decimal number.
    # $java_usage rounds the decimal output from $calc_usage to a whole number.

    wm_calc_usage=$(sudo -u $admin_user $jstat -gc $wm_java_pid 2>/dev/null | tail -n 1 | awk '{split($0,a," "); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}')
    wm_java_usage=${wm_calc_usage%.*}
    
    if [[ $wm_java_usage -eq 0 ]]; then
        echo "Something is wrong. WM Java memory usage is at 0 MB | WM_JVM_Mem_Usage_percent=0"
        exit 3
    else
        wm_percent=$(echo "scale=0;$wm_java_usage*100/$wm_java_max_mem" | bc -l )
    fi

}

function lmCalcPercent() {
    # The output of $calc_usage is a decimal number.
    # $java_usage rounds the decimal output from $calc_usage to a whole number.

    lm_calc_usage=$(sudo -u $admin_user $jstat -gc $lm_java_pid 2>/dev/null | tail -n 1 | awk '{split($0,a," "); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}')
    lm_java_usage=${lm_calc_usage%.*}
    
    if [[ $lm_java_usage -eq 0 ]]; then
        echo "Something is wrong. LM Java memory usage is at 0 MB | LM_JVM_Mem_Usage_percent=0"
        exit 3
    else
        lm_percent=$(echo "scale=0;$lm_java_usage*100/$lm_java_max_mem" | bc -l )
    fi

}

function dbCalcPercent() {
    # The output of $calc_usage is a decimal number.
    # $java_usage rounds the decimal output from $calc_usage to a whole number.

    db_calc_usage=$(sudo -u $admin_user $jstat -gc $db_java_pid 2>/dev/null | tail -n 1 | awk '{split($0,a," "); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}')
    db_java_usage=${db_calc_usage%.*}
    
    if [[ $db_java_usage -eq 0 ]]; then
        echo "Something is wrong. DB Java memory usage is at 0 MB | DB_JVM_Mem_Usage_percent=0"
        exit 3
    else
        db_percent=$(echo "scale=0;$db_java_usage*100/$db_java_max_mem" | bc -l )
    fi

}

function mipOutput() {
if [[ $mip_percent -ge $critP ]]; then
  echo -e "CRITICAL: MIP Java Memory Usage is $mip_java_usage MB out of $mip_java_max_mem MB - Java Usage is $mip_percent% | MIP_JVM_Mem_Usage_percent=$mip_percent"
  exit 2
elif [[ $mip_percent -ge $warnP ]]; then
  echo -e "WARNING: MIP Java Memory Usage is $mip_java_usage MB out of $mip_java_max_mem MB - Java Usage is $mip_percent% | MIP_JVM_Mem_Usage_percent=$mip_percent"
  exit 1
else
  echo -e "OK: MIP Java Memory Usage is $mip_java_usage MB out of $mip_java_max_mem MB - Java Usage is $mip_percent% | MIP_JVM_Mem_Usage_percent=$mip_percent"
  exit 0
fi
}

function mdaOutput() {
if [[ $mda_percent -ge $critP ]]; then
  echo -e "CRITICAL: MDA Java Memory Usage is $mda_java_usage MB out of $mda_java_max_mem MB - Java Usage is $mda_percent% | MDA_JVM_Mem_Usage_percent=$mda_percent"
  exit 2
elif [[ $mda_percent -ge $warnP ]]; then
  echo -e "WARNING: MDA Java Memory Usage is $mda_java_usage MB out of $mda_java_max_mem MB - Java Usage is $mda_percent% | MDA_JVM_Mem_Usage_percent=$mda_percent"
  exit 1
else
  echo -e "OK: MDA Java Memory Usage is $mda_java_usage MB out of $mda_java_max_mem MB - Java Usage is $mda_percent% | MDA_JVM_Mem_Usage_percent=$mda_percent"
  exit 0
fi
}

function wmOutput() {
if [[ $wm_percent -ge $critP ]]; then
  echo -e "CRITICAL: WM Java Memory Usage is $wm_java_usage MB out of $wm_java_max_mem MB - Java Usage is $wm_percent% | WM_JVM_Mem_Usage_percent=$wm_percent"
  exit 2
elif [[ $wm_percent -ge $warnP ]]; then
  echo -e "WARNING: WM Java Memory Usage is $wm_java_usage MB out of $wm_java_max_mem MB - Java Usage is $wm_percent% | WM_JVM_Mem_Usage_percent=$wm_percent"
  exit 1
else
  echo -e "OK: WM Java Memory Usage is $wm_java_usage MB out of $wm_java_max_mem MB - Java Usage is $wm_percent% | WM_JVM_Mem_Usage_percent=$wm_percent"
  exit 0
fi
}

function lmOutput() {
if [[ $lm_percent -ge $critP ]]; then
  echo -e "CRITICAL: LM Java Memory Usage is $lm_java_usage MB out of $lm_java_max_mem MB - Java Usage is $lm_percent% | LM_JVM_Mem_Usage_percent=$lm_percent"
  exit 2
elif [[ $lm_percent -ge $warnP ]]; then
  echo -e "WARNING: LM Java Memory Usage is $lm_java_usage MB out of $lm_java_max_mem MB - Java Usage is $lm_percent% | LM_JVM_Mem_Usage_percent=$lm_percent"
  exit 1
else
  echo -e "OK: LM Java Memory Usage is $lm_java_usage MB out of $lm_java_max_mem MB - Java Usage is $lm_percent% | LM_JVM_Mem_Usage_percent=$lm_percent"
  exit 0
fi
}

function dbOutput() {
if [[ $db_percent -ge $critP ]]; then
  echo -e "CRITICAL: DB Java Memory Usage is $db_java_usage MB out of $db_java_max_mem MB - Java Usage is $db_percent% | DB_JVM_Mem_Usage_percent=$db_percent"
  exit 2
elif [[ $db_percent -ge $warnP ]]; then
  echo -e "WARNING: DB Java Memory Usage is $db_java_usage MB out of $db_java_max_mem MB - Java Usage is $db_percent% | DB_JVM_Mem_Usage_percent=$db_percent"
  exit 1
else
  echo -e "OK: DB Java Memory Usage is $db_java_usage MB out of $db_java_max_mem MB - Java Usage is $db_percent% | DB_JVM_Mem_Usage_percent=$db_percent"
  exit 0
fi
}

# Kick off the script
gatherStats

case "${app}" in
    mip | MIP) 
        mipCalcPercent
        mipOutput
        ;;
    mda | MDA) 
        mdaCalcPercent
        mdaOutput
        ;;
    wm | WM | wms | WMS)
        wmCalcPercent
        wmOutput
        ;;
    lm | LM) 
        lmCalcPercent
        lmOutput
        ;;
    db | DB)
        dbCalcPercent
        dbOutput
        ;;
    *)
        printHelp
        ;;
esac
