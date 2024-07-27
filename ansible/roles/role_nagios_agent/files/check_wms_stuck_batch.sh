#!/bin/bash

#Description: Checks for stuck batches and alerts the WMS team.
#             I don't know what this actually does,  I just wrote the check.
#             Designed to be executed from Nagios.
#
#Author:      Tony Welder
#Author Email:twelder@hy-vee.com

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-e" ]; then

    ENVIRONMENT=$4

    echo "$ENVIRONMENT" | egrep '^chr' >/dev/null
    if [ "$?" -eq 0 ]; then
        CHRENV=`echo "$ENVIRONMENT" | awk -F '-' '{print $3}'`
        source /opt/hy-vee/scripts/${CHRENV}/env-setup.sh
    else
        source /opt/hy-vee/scripts/env-setup.sh
    fi

    secret=$(echo $wm_db_pass | openssl enc -aes-128-cbc -a -d -salt -pass pass:$wm_db_salt)

    export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.x86_64"
    export ANT_HOME="/manh/3rdparty/swtools/ant/apache-ant-1.9.4"
    export ORACLE_HOME="/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1"
    export JBOSS_HOME="/manh/3rdparty/swtools/jboss/jboss-eap-6.3"

    PATH=$PATH:$HOME/.local/bin:$HOME/bin:$ORACLE_HOME/bin
    export DATABASE_HOME=$ORACLE_HOME
    PATH=$ANT_HOME/bin:$JAVA_HOME/bin:$ORACLE_HOME/bin:$JBOSS_HOME/bin:$PATH
    export PATH

query() {
    sqlplus -S $wm_db_username/$secret@$wm_db_servicename <<ENDOFSQL
SELECT COUNT(1) FROM $wm_db_schemaname.LABOR_MSG WHERE STATUS = 10 AND MSG_STAT_CODE IN (40,50) AND LOGIN_USER_ID <> 'MONITOR' AND CREATED_DTTM < SYSDATE-2/24;
ENDOFSQL
}

    query_output=$(query | tail -n2 | sed -r 's/\s+//g')
    if [ "$query_output" == "0" ]; then
        echo "WMS Team - OK: No stuck batches detected"
        exit 0
    fi


    if [ "$query_output" -ge "$2" ]; then
        echo "WMS Team - Critical: Stuck batches detected"
        exit 2
    fi

else
    # If inputs are not as expected, print help.
    sName="`echo $0|awk -F '/' '{print $NF}'`"
    echo -e "# Usage:\t$sName -w -c"
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_stuck_batch -c 1 -e (XI HOSTNAME VARIABLE HERE)"
    exit
fi

