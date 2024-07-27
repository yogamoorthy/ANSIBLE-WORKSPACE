#!/usr/bin/env bash
# Script for managing the MIF WMS application
#------ # Color Variables -------------------------------------------------------------------------------------------#
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
nc='\033[0m'

#------ # Sets Variables Based On DEV or PROD Environment ---------------------------------------------------------------------#
if grep -qi "dev" <<< "$HOSTNAME"; then
    admin_user="wmsadmin"
    mif_home=/manh/apps/scope/mif/softwareag/IntegrationServer/instances/default/bin
else
    admin_user="scopeadm"
    mif_home=/manh/apps/scope/mifprod/IntegrationServer/instances/default/bin
fi

#------ Ensure only scopeadm or wmsadmin user executes script ----------------------------------------------------------#
if ([ "$USER" != "$admin_user" ] && [ "$1" == "start" ]) || ([ "$USER" != "$admin_user" ] && [ "$1" == "stop" ]) || ([ "$USER" != "$admin_user" ] && [ "$1" == "restart" ]); then
    printf "\n${red}ERROR: $0 must be run as '$admin_user' user${nc}\n\n"
    exit 1
fi

#------ MIF Rolling Restart Script ------------------------------------------------------------------------------------#
help_menu () {
    echo -e "${green}Usage: $0 {start|stop|restart|status}${nc}"
    echo
    echo -e "${lightgreen}NOTE: {start|stop|restart} can only be executed by the '$admin_user' user. ${nc}"
    echo -e "${lightgreen}      {status} can be executed by any user. ${nc}"
}

gather_info () {
# Gather process ID
    mif_process=$(ps -ef | grep java | grep $mif_home | awk '{print $2}')
# Gather process start time
# If mif is stopped then there isn't a PID
# Without a PID the $uptime var would return an error,
# So I exclude the error if $mif_process is empty
    if [ -z "$mif_process" ]; then
        uptime=$(ps -p $mif_process -o lstart > /dev/null 2>&1)
    else
        uptime=$(ps -p $mif_process -o lstart | tail -1)
    fi
}

log_info () {
    timestamp=$(date +'%D_%H:%M:%S:%3N')
    log_info="$timestamp | INFO:"
    echo "$log_info"
}

output () {
    status="$1"
    msg="$2"

    if [ "$status" == "Running" ]; then 
        echo -e "${green}MIF is $status - $msg ${nc}"
    else
        echo -e "${red}MIF is $status - $msg ${nc}"
    fi
}

#------ Check if MIF is Running && Set Variable $status ---------------------------------------------------------#
application_status () {
    gather_info

    if [ -n "$mif_process" ]; then
        status="Running"
        output $status "[$uptime]"
    else
        status="Stopped"
        output $status "[]"
    fi
}

#------ Starts the APP -----------------------------------------------------------------------------------------------#
application_start () {
    if [ "$status" == "Stopped" ]; then
        echo -e "${green}$(log_info) MIF is Starting... ${nc}"
        $mif_home/startup.sh
    else
        echo -e "MIF is already ${green}Running${nc} - [Up Since $uptime]"
    fi
}
#------ Stops the APP -----------------------------------------------------------------------------------------------#
application_stop () {
    if [ "$status" == "Running" ]; then
        echo "$(log_info) Stopping MIF..."
        $mif_home/shutdown.sh
    else
        echo -e "MIF is already ${red}Stopped${nc} or does not exist - [$status]"
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
