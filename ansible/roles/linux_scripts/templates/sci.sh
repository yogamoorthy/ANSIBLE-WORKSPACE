#!/usr/bin/env bash
# Script for managing the SCI WMS application
#------ # Color Variables -------------------------------------------------------------------------------------------#
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
nc='\033[0m'

#------ # Variables ------------------------------------------------------------------------------------------------------#
admin_user="sciadmin"

#------ # Sets Variables Based On DEV or PROD Environment ---------------------------------------------------------------------#
if grep -qi "dev" <<< "$HOSTNAME"; then
    sci_home=/manh/apps/scope/sci/cognos/c10_64/bin64
    . /manh/apps/scope/sci/manh/sci/bin/setenv.sh
else
    sci_home=/manh/apps/scope/sciprod/cognos/c10_64/bin64
    . /manh/apps/scope/sciprod/manh/sci/bin/setenv.sh
fi

#------ Ensure only sciadmin or wmsadmin user executes script ----------------------------------------------------------#
if ([ "$USER" != "$admin_user" ] && [ "$1" == "start" ]) || ([ "$USER" != "$admin_user" ] && [ "$1" == "stop" ]) || ([ "$USER" != "$admin_user" ] && [ "$1" == "restart" ]); then
    printf "\n${red}ERROR: $0 must be run as '$admin_user' user${nc}\n\n"
    exit 1
fi

#------ SCI Rolling Restart Script ------------------------------------------------------------------------------------#
help_menu () {
    echo -e "${green}Usage: $0 {start|stop|restart|status}${nc}"
    echo
    echo -e "${lightgreen}NOTE: {start|stop|restart} can only be executed by the '$admin_user' user. ${nc}"
    echo -e "${lightgreen}      {status} can be executed by any user. ${nc}"
}

gather_info () {
# Gather process ID
    sci_process=$(ps -ef | grep java | grep $sci_home | awk '{print $2}')
# Gather process start time
# If SCI is stopped then there isn't a PID
# Without a PID the $uptime var would return an error,
# So I exclude the error if $sci_process is empty
    if [ -z "$sci_process" ]; then
        uptime=$(ps -p $sci_process -o lstart > /dev/null 2>&1)
    else
        uptime=$(ps -p $sci_process -o lstart | tail -1)
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
        echo -e "${green}SCI is $status - $msg ${nc}"
    else
        echo -e "${red}SCI is $status - $msg ${nc}"
    fi
}

#------ Check if SCI is Running && Set Variable $status ---------------------------------------------------------#
application_status () {
    gather_info

    if [ -n "$sci_process" ]; then
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
        echo -e "${green}$(log_info) SCI is Starting... ${nc}"
        $sci_home/cogconfig.sh -s
    else
        echo -e "SCI is already ${green}Running${nc} - [Up Since $uptime]"
    fi
}
#------ Stops the APP -----------------------------------------------------------------------------------------------#
application_stop () {
    if [ "$status" == "Running" ]; then
        echo "$(log_info) Stopping SCI..."
        $sci_home/cogconfig.sh -stop
    else
        echo -e "SCI is already ${red}Stopped${nc} or does not exist - [$status]"
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
