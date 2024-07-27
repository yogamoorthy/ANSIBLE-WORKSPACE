#!/bin/bash

if [ "$1" = "-c" ] && [ "$2" -gt "0" ] && [ "$3" = "-e" ] && [ "$5" = "-s" ]; then
    ENVIRONMENT=$4
    APPLICATION=$6

    export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.x86_64"
    export ANT_HOME="/manh/3rdparty/swtools/ant/apache-ant-1.9.4"
    export ORACLE_HOME="/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1"
    export JBOSS_HOME="/manh/3rdparty/swtools/jboss/jboss-eap-6.3"

    echo "$ENVIRONMENT" | egrep '^chr' >/dev/null
    if [ "$?" -eq 0 ]; then
        CHRENV=`echo "$ENVIRONMENT" | awk -F '-' '{print $3}'`
        source /opt/hy-vee/scripts/${CHRENV}/env-setup.sh
        BOUNCEDIR=/opt/hy-vee/scripts/${CHRENV}
        STATUS=`sudo -u scopeadm sh -lc "$BOUNCEDIR/$CHRENV status" |grep "$APPLICATION" | awk {'print $3'}`
    else
        source /opt/hy-vee/scripts/env-setup.sh
        BOUNCEDIR=/opt/hy-vee/scripts
        STATUS=`sudo -u scopeadm sh -lc "$BOUNCEDIR/app status" |grep "$APPLICATION" | awk {'print $3'}`

    fi

    if [ "$STATUS" != "Running" ]; then
        STATUS_CODE=1
    else
        STATUS_CODE=0
    fi

    if [ "$STATUS_CODE" -ne "0" ]; then
        echo "$APPLICATION is DOWN - $wm_env"
        exit 2
    else
        echo "$APPLICATION is UP - $wm_env"
        exit 0
    fi
else # If inputs are not as expected, print help.
    sName="`echo $0|awk -F '/' '{print $NF}'`"
    echo -e "# Usage:\t$sName -c -e -s"
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_ship -w 1 -c 2"
    exit
fi
