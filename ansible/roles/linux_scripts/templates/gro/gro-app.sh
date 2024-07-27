#!/usr/bin/env bash

#------ Source the ENV Vars -------------------------------------------------------------------------------------------#
. /opt/hy-vee/scripts/gro/env-setup.sh

#------ # Color Variables -------------------------------------------------------------------------------------------#
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
nc='\033[0m'

#------ # Sets $manh_home Variable Based On DEV or PROD Environment ---------------------------------------------------------------------#
if grep -qi "dev" <<< "$HOSTNAME"; then
    manh_home=/manh/apps/scope
else
    manh_home=/manh/apps/scope/gro
fi

#------ # Variables -------------------------------------------------------------------------------------------#
mip_home="$manh_home/$mip_name"
mda_home="$manh_home/$mda_name"
wm_home="$manh_home/$wm_name"
lm_home="$manh_home/$lm_name"
db_home="$manh_home/$db_name"

mip_sd="$mip_home/.sd"
mda_sd="$mda_home/.sd"
wm_sd="$wm_home/.sd"
lm_sd="$lm_home/.sd"
db_sd="$db_home/.sd"

#------ Ensure only scopeadm or wmsadmin user executes script ----------------------------------------------------------#
if ([ "$USER" != "$admin_user" ] && [ "$1" == "start" ]) || ([ "$USER" != "$admin_user" ] && [ "$1" == "stop" ]) || ([ "$USER" != "$admin_user" ] && [ "$1" == "restart" ]); then
    printf "\n${red}ERROR: $0 must be run as '$admin_user' user${nc}\n\n"
    exit 1
fi

#------ WMS Rolling Restart Script ------------------------------------------------------------------------------------#
help_menu () {
  echo -e "${green}Usage: $0 {start|stop|restart|status}${nc}"
  echo
  echo -e "${lightgreen}NOTE: {start|stop|restart} can only be executed by the '$admin_user' user. ${nc}"
  echo -e "${lightgreen}      {status} can be executed by any user. ${nc}"
}

gather_info () {
  # Gather process IDs
  mip_process=$(ps -ef | grep java | grep $mip_home/profile-root | awk '{print $2}')
  mda_process=$(ps -ef | grep java | grep $mda_home/profile-root | awk '{print $2}')
  wm_process=$(ps -ef | grep java | grep $wm_home/profile-root | awk '{print $2}')
  lm_process=$(ps -ef | grep java | grep $lm_home/profile-root | awk '{print $2}')
  db_process=$(ps -ef | grep java | grep $db_home/profile-root | awk '{print $2}')
  # Gather uptime stats
  if [ -n "$mip_process" ]; then
    mip_uptime=$(ps -p $mip_process -o lstart | tail -1)
  fi
  if [ -n "$mda_process" ]; then
    mda_uptime=$(ps -p $mda_process -o lstart | tail -1)
  fi
  if [ -n "$wm_process" ]; then
    wm_uptime=$(ps -p $wm_process -o lstart | tail -1)
  fi
  if [ -n "$lm_process" ]; then
    lm_uptime=$(ps -p $lm_process -o lstart | tail -1)
  fi
  if [ -n "$db_process" ]; then
    db_uptime=$(ps -p $db_process -o lstart | tail -1)
  fi
}

log_info () {
    timestamp=$(date +'%D_%H:%M:%S:%3N')
    log_info="$timestamp | INFO:"
    echo "$log_info"
}

output () {
  app="$1"
  status="$2"
  msg="$3"

  if [ "$status" == "Running" ]; then 
    echo -e "${green}$app is $status - $msg ${nc}"
  else
    echo -e "${red}$app is $status - $msg ${nc}"
  fi
}

#------ Check if apps are Running && Set Variable $status ---------------------------------------------------------#
application_status () {
  gather_info

  if [ -n "$mip_process" ] && [ "$mip_name" != "null" ]; then
    mip_status="Running"
    output MIP $mip_status "[$mip_uptime]"
  else
    mip_status="Stopped"
    output MIP $mip_status "[]"
  fi

  if [ -n "$mda_process" ] && [ "$mda_name" != "null" ]; then
    mda_status="Running"
    output MDA $mda_status "[$mda_uptime]"
  else
    mda_status="Stopped"
    output MDA $mda_status "[]"
  fi

  if [ -n "$wm_process" ] && [ "$wm_name" != "null" ]; then
    wm_status="Running"
    output WM $wm_status "[$wm_uptime]"
  else
    wm_status="Stopped"
    output WM $wm_status "[]"
  fi

  if [ -n "$lm_process" ] && [ "$lm_name" != "null" ]; then
    lm_status="Running"
    output LM $lm_status "[$lm_uptime]"
  else
    lm_status="Stopped"
    output LM $lm_status "[]"
  fi

  if [ -n "$db_process" ] && [ "$db_name" != "null" ]; then
    db_status="Running"
    output DB $db_status "[$db_uptime]"
  else
    db_status="Stopped"
    output DB $db_status "[]"
  fi
}

#------ Starts the APPS -----------------------------------------------------------------------------------------------#
application_start () {
  if [ "$mip_status" == "Stopped" ] && [ "$mip_name" != "null" ]; then
    echo -e "${green}$(log_info) MIP is Starting... ${nc}"
    $mip_sd/start.sh
  else
    echo -e "MIP is already ${green}Running${nc} - [$mip_uptime]"
  fi

  if [ "$mda_status" == "Stopped" ] && [ "$mda_name" != "null" ]; then
    echo -e "${green}$(log_info) MDA is Starting... ${nc}"
    $mda_sd/start.sh
  else
    echo -e "MDA is already ${green}Running${nc} - [$mda_uptime]"
  fi

  if [ "$wm_status" == "Stopped" ] && [ "$wm_name" != "null" ]; then
    echo -e "${green}$(log_info) WM is Starting... ${nc}"
    $wm_sd/start.sh
  else
    echo -e "WM is already ${green}Running${nc} - [$wm_uptime]"
  fi

  if [ "$lm_status" == "Stopped" ] && [ "$lm_name" != "null" ]; then
    echo -e "${green}$(log_info) LM is Starting... ${nc}"
    $lm_sd/start.sh
  else
    echo -e "LM is already ${green}Running${nc} - [$lm_uptime]"
  fi

  if [ "$db_status" == "Stopped" ] && [ "$db_name" != "null" ]; then
    echo -e "${green}$(log_info) DB is Starting... ${nc}"
    $db_sd/start.sh
  else
    echo -e "DB is already ${green}Running${nc} - [$db_uptime]"
  fi
}
#------ Stops the APPS -----------------------------------------------------------------------------------------------#
application_stop () {
  if [ "$mip_status" == "Running" ] && [ "$mip_name" != "null" ]; then
    echo "$(log_info) MIP Stopping"
    $mip_sd/stop.sh
  else
    echo -e "MIP is already ${red}Stopped${nc} or does not exist - [$mip_status:$mip_name]"
  fi

  if [ "$mda_status" == "Running" ] && [ "$mda_name" != "null" ]; then
    echo "$(log_info) MDA Stopping"
    $mda_sd/stop.sh
  else
    echo -e "MDA is already ${red}Stopped${nc} or does not exist - [$mda_status:$mda_name]"
  fi

  if [ "$wm_status" == "Running" ] && [ "$wm_name" != "null" ]; then
    echo "$(log_info) WM Stopping"
    $wm_sd/stop.sh
  else
    echo -e "WM is already ${red}Stopped${nc} or does not exist - [$wm_status:$wm_name]"
  fi

  if [ "$lm_status" == "Running" ] && [ "$lm_name" != "null" ]; then
    echo "$(log_info) LM Stopping"
    $lm_sd/stop.sh
  else
    echo -e "LM is already ${red}Stopped${nc} or does not exist - [$lm_status:$lm_name]"
  fi

  if [ "$db_status" == "Running" ] && [ "$db_name" != "null" ]; then
    echo "$(log_info) DB Stopping"
    $db_sd/stop.sh
  else
    echo -e "DB is already ${red}Stopped${nc} or does not exist - [$db_status:$db_name]"
  fi
}

stop () {
  application_status > /dev/null 2>&1
  application_stop
}

start () {
  application_status > /dev/null 2>&1
  application_start
}

status () {
  application_status
}

case "$1" in
    start)
        start
        ;;

    stop)
        stop
        ;;

    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    *)
        help_menu
        exit 1

esac
