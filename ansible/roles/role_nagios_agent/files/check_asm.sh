#!/bin/bash

# ENV Vars are handeled by the env-setup.sh
# This is loaded in on arg6

# Required ENV Vars
# wm_db_pass
# wm_db_salt
# ora_home
# wm_db_servicename

if [ -z "$1" ];
  then
    echo "no diskgroup passed"
    exit 3
fi

if [ "$2" == "-w" ] && [ "$4" == "-c" ];
  then
    warn="$3"
    crit="$5"
  elif [ "$2" == "-c" ] && [ "$4" == "-w" ];
    then
      warn="$5"
      crit="$3"
  else
    warn="80"
    crit="95"
fi

if [ "$ENVIRONMENT" = "chrdevapp1-v-per" ]; then
  source /opt/hy-vee/scripts/per/env-setup.sh
elif [ "$ENVIRONMENT" = "chrapp1a-v-per" ]; then
  source /opt/hy-vee/scripts/per/env-setup.sh
elif [ "$ENVIRONMENT" = "chrdevapp1-v-gro" ]; then
  source /opt/hy-vee/scripts/gro/env-setup.sh
elif [ "$ENVIRONMENT" = "chrapp1a-v-gro" ]; then
  source /opt/hy-vee/scripts/gro/env-setup.sh
elif [ "$ENVIRONMENT" = "chrdevapp1-v-hbc" ]; then
  source /opt/hy-vee/scripts/hbc/env-setup.sh
elif [ "$ENVIRONMENT" = "chrapp1a-v-hbc" ]; then
  source /opt/hy-vee/scripts/hbc/env-setup.sh
else
  source /opt/hy-vee/scripts/env-setup.sh
fi

secret=$(echo $wm_db_pass | openssl enc -aes-128-cbc -a -d -salt -pass pass:$wm_db_salt)
export ORACLE_HOME="$ora_home"
export ORACLE_SID="$wm_db_servicename"

function usedspace() {
  $ORACLE_HOME/bin/sqlplus -S $wm_db_username/$secret@$wm_db_servicename <<ENDOFSQL
    set heading off echo off feed off linesize 100 pagesize 0
    col state for a12
    col NAME for a30
    select state, TOTAL_MB, USABLE_FILE_MB, NAME from v\$asm_diskgroup;
ENDOFSQL
}

sqlData=$(usedspace)
sqlData=( $sqlData )

if [ "$1" == "fra" ];
  then
    dataSet=${sqlData[@]:0:4}
  elif [ "$1" == "data" ];
    then
      dataSet=${sqlData[@]:4:4}
  elif [ "$1" == "log" ];
   then
     dataSet=${sqlData[@]:8:4}
fi

dgstate=$(echo $dataSet | awk '{ print $1 }')
totalmb=$(echo $dataSet | awk '{ print $2 }')
freemb=$(echo $dataSet | awk '{ print $3 }')
dgname=$(echo $dataSet | awk '{ print $4 }')

percentage=$((100-(($freemb*100)/$totalmb)))
totalmb=$(echo "scale=2; $totalmb / 1024" | bc)
freemb=$(echo "scale=2; $freemb / 1024" | bc)

# Round floats
totalmb=${totalmb%.*}
freemb=${freemb%.*}

# Get used space
usedgb="$((totalmb-freemb))"

if [ "$percentage" -lt "$warn" ] && [ "$percentage" -lt "$crit" ];
  then
    echo "DISKGROUP $dgname: OK - Percent: $percentage% - Total: $totalmb GB - Used: $usedgb GB|Total=$totalmb;;;; Used=$usedgb;;;;"
    exit 0
  elif [ "$percentage" -ge "$warn" ] && [ "$percentage" -lt "$crit" ];
    then
      echo "DISKGROUP $dgname: WARN - Percent: $percentage% - Total: $totalmb GB - Used: $usedgb GB|Total=$totalmb;;;; Used=$usedgb;;;;"
      exit 1
  elif [ "$percentage" -ge "$crit" ];
    then
      echo "DISKGROUP $dgname: CRIT - Percent: $percentage% - Total: $totalmb GB - Used: $usedgb GB|Total=$totalmb;;;; Used=$usedgb;;;;"
      exit 2
  else
    echo "DISKGROUP $dgname: UNKNOWN"
    exit 3
fi
