#!/bin/bash

if [ "$1" = "-c" ] && [ "$2" -gt "0" ] && [ "$3" = "-e" ]; then

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
    SELECT * FROM $wm_db_schemaname.SHIP_WAVE_PARM WHERE STAT_CODE = 5
    and CREATE_DATE_TIME <= sysdate -1/72
    and CREATE_DATE_TIME > sysdate -7;
ENDOFSQL
}

    query_return=$(query | grep "rows selected" | awk '{ print $1 }')

    if [ "$query_return" == "no" ]; then
        query_return="0"
    fi


    if [ "$query_return" != "0" ]; then
        echo "WMS Team - There are $query_return stuck waves - $wm_env | Errors = $query_return | @here"
        exit 2
    else
        echo "WMS Team - There are $query_return stuck waves - $wm_env | Errors = $query_return"
        exit 0
    fi
else 
    # If inputs are not as expected, print help.
    sName="`echo $0|awk -F '/' '{print $NF}'`"
    echo -e "# Usage:\t$sName -w -c "
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_waveabrt -c 1 -e (XI HOSTNAME VARIABLE HERE)"
    exit
fi

