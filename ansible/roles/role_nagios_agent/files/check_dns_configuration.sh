#!/bin/bash

#Description:  A simple script that verifies that DNS is configured as expected
#              It also verifies that network manager is off
#
#Execution:    Simply run the command with no arguments
#Author:       Tony Welder
#Author Email: twelder@hy-vee.com

check_return_code () {
        local return_code="$1"
        local message="$2"
        if [ "$return_code" == "0" ]; then
                echo "check good, nothing to do" > /dev/null
        else
                echo "Critical: ${message}"
                exit 1
        fi
}

expected_md5_of_resolv="da636e07980195018de1ae3b20bebc54"
current_md5_of_resolv="$(md5sum /etc/resolv.conf | awk '{print $1}')"

echo $expected_md5_of_resolv | grep $current_md5_of_resolv > /dev/null
check_return_code $? "resolv.conf has changed, verify /etc/resolv.conf for correct DNS configuration"

systemctl status NetworkManager.service | grep Active: | grep dead > /dev/null
check_return_code $? "NetworkManager is turned on, turn off NetworkManager and discover who turned it on"

systemctl list-unit-files | grep NetworkManager\.service | grep disabled > /dev/null
check_return_code $? "NetworkManager is enabled to start on boot, disable it and discover who enabled it"

echo "OK: DNS configuration is as expected"
exit 0

