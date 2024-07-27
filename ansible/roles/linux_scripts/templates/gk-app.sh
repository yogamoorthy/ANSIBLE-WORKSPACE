#!/bin/bash

server=$(hostname -f)
username="gktomcatadmin"
password="gktomcatadmin123!"

# Color Variables
red='\033[0;31m'
green='\033[0;32m'
lightgreen='\033[1;32m'
yellow='\033[1;33m'
nc='\033[0m'

display_help() {
    echo
    echo -e "${green}Usage: $0 [options]...${nc}" >&2
    echo
    echo -e "${lightgreen}\tstatus\t\t\tShow State of all apps on the system${nc}"
    echo -e "${yellow}\tExample: $0 status${nc}"
    echo
    echo -e "${lightgreen}\tstart\t\t\tPresents a list of application which can be started.${nc}"
    echo -e "${yellow}\tExample: $0 start${nc}"
    echo
    echo -e "${lightgreen}\tstart [app-context]\tAllows you to pass an argument of the tomcat context to start.${nc}"
    echo -e "${yellow}\tExample: $0 start swee-cis${nc}"
    echo
    echo -e "${lightgreen}\tstop\t\t\tPresents a list of application which can be stopped.${nc}"
    echo -e "${yellow}\tExample: $0 stop${nc}"
    echo
    echo -e "${lightgreen}\tstop [app-context]\tAllows you to pass an argument of the tomcat context to stop.${nc}"
    echo -e "${yellow}\tExample: $0 stop swee-cis${nc}"
    echo
    echo -e "${lightgreen}\treload\t\t\tPresents a list of application which can be Reloaded (Reapplies the configuration).${nc}"
    echo -e "${yellow}\tExample: $0 reload${nc}"
    echo
    echo -e "${lightgreen}\treload [app-context]\tAllows you to pass an argument of the tomcat context to reload.${nc}"
    echo -e "${yellow}\tExample: $0 reload swee-cis${nc}"
    echo
    echo -e "${lightgreen}\trestart [app-context]\tPresents a list of application which can be Restarted (Stops and starts applcaitoins).${nc}"
    echo -e "${yellow}\tExample: $0 restart swee-cis${nc}"
    echo
    echo -e "${lightgreen}\tundeploy\t\tPresents a list of application which can be undeployed (Use with caution, this will remove the app).${nc}"
    echo -e "${yellow}\tExample: $0 reload${nc}"
    echo
    echo -e "${lightgreen}\tundeploy [app-context]\tAllows you to pass an argument of the tomcat context to undeploy.${nc}"
    echo -e "${yellow}\tExample: $0 reload swee-cis${nc}"
    echo
    echo -e "${lightgreen}\tlist-apps\t\tlists all application context names on this tomcat server.${nc}"
    echo -e "${yellow}\tExample: $0 list-apps${nc}"
    echo
    exit 1
}

# Removed log_info because this only captured current time, and not the app's uptime.
# log_info() {
#     timestamp=$(date +'%D_%H:%M:%S:%3N')
#     log_info="$timestamp | INFO:"
#     echo "$log_info"
# }

dynamic_list() {
    # Formats all of the apps in a list that is used to start, stop, reload, and undeploy apps.
    fmt_data
    readarray -t lines < <(echo "$input")
    echo "Please select an Option:"
    select choice in "${lines[@]}"; do
      [[ -n $choice ]] || { echo "Invalid choice. Please try again." >&2; continue; }
      break
    done
    read -r dylist_choice <<<"$choice"
    echo "$dylist_choice"
}

fmt_data() {
    # Formats the Status Data
    get_status
    input=$(echo "$app_status" | awk -F: '{ print $4 }')
}

get_status() {
  app_status=$(curl --user $username:$password http://$server:8080/manager/text/list -s | grep '^/' )
}

print_status() {
  for item in $app_status;
    do
      path=$(echo $item | awk -F: '{ print $1 }')
      status=$(echo $item | awk -F: '{ print $2 }')
      connections=$(echo $item | awk -F: '{ print $3 }')
      name=$(echo $item | awk -F: '{ print $4 }')
      if [ "$status" == "running" ];
        then
          echo -e "${green} $name is $status${nc}"
      elif [ "$status" == "stopped" ];
        then
          echo -e "${red} $name is $status${nc}"
      fi
  done
}

undeploy() {
    # Removes the Configureation
    if [ -n "$1" ];
        then
            app_name="$1"
            curl --user $username:$password http://$server:8080/manager/text/undeploy?path=/$app_name
        else
            get_status
            dynamic_list
            app_name="${dylist_choice}"
            # app_name=$(echo "$app_status" | grep "$application" | awk -F: '{ print $4 }')
            curl --user $username:$password http://$server:8080/manager/text/undeploy?path=/$app_name
    fi
}

start() {
    # Starts the Applciaton
    if [ -n "$1" ];
        then
            app_name="$1"
            curl --user $username:$password http://$server:8080/manager/text/start?path=/$app_name
        else
            get_status
            dynamic_list
            app_name="${dylist_choice}"
            curl --user $username:$password http://$server:8080/manager/text/start?path=/$app_name
    fi
}

stop() {
    # Stops the Application
    if [ -n "$1" ];
        then
            app_name="$1"
            curl --user $username:$password http://$server:8080/manager/text/stop?path=/$app_name
        else
            get_status
            dynamic_list
            app_name="${dylist_choice}"
            curl --user $username:$password http://$server:8080/manager/text/stop?path=/$app_name
    fi
}

reload() {
    # Reload the Application (Fastest Way of reloading configuration)
    if [ -n "$1" ];
        then
            app_name="$1"
            curl --user $username:$password http://$server:8080/manager/text/reload?path=/$app_name
        else
            get_status
            dynamic_list
            app_name="${dylist_choice}"
            curl --user $username:$password http://$server:8080/manager/text/reload?path=/$app_name
    fi
}

status() {
    # Gathers information about the Environment
    get_status
    print_status
}

restart() {
    # Runs the Start and Stop Funcations
    if [ -z "$1" ];
      then
        echo "Error: Application Context Must be an argument. See help..."
        exit 1
    else
        stop $1
        start $1
    fi
}

case "$1" in
    start)
        start $2
        ;;

    stop)
        stop $2
        ;;

    status)
        status
        ;;

    restart)
        restart $2
        ;;

    undeploy)
        undeploy $2
        ;;

    reload)
        reload $2
        ;;

    list-apps)
        fmt_data
        app_list=$(echo "$input" | egrep -v "examples|host-manager|manager|docs|ROOT")
        if [ -z "$2" ];
          then
            echo "$app_list" | grep "$2"
          else
            echo "$app_list"
        fi
        ;;

    *)
        display_help
esac