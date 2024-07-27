#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ] && [ "$5" = "-e" ]; then

    ENVIRONMENT=$6

    export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.x86_64"
    export ANT_HOME="/manh/3rdparty/swtools/ant/apache-ant-1.9.4"
    export ORACLE_HOME="/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1"
    export JBOSS_HOME="/manh/3rdparty/swtools/jboss/jboss-eap-6.3"

    echo "$ENVIRONMENT" | egrep '^chr' >/dev/null
    if [ "$?" -eq 0 ]; then
        CHRENV=`echo "$ENVIRONMENT" | awk -F '-' '{print $3}'`
        source /opt/hy-vee/scripts/${CHRENV}/env-setup.sh
    else
        source /opt/hy-vee/scripts/env-setup.sh
    fi

    secret=$(echo $wm_db_pass | openssl enc -aes-128-cbc -a -d -salt -pass pass:$wm_db_salt)

    PATH=$PATH:$HOME/.local/bin:$HOME/bin:$ORACLE_HOME/bin
    export DATABASE_HOME=$ORACLE_HOME
    PATH=$ANT_HOME/bin:$JAVA_HOME/bin:$ORACLE_HOME/bin:$JBOSS_HOME/bin:$PATH
    export PATH

query() {
    sqlplus -S $wm_db_username/$secret@$wm_db_servicename <<ENDOFSQL
        select CASE
        WHEN COUNT(*) = 0 THEN '0'
        Else '2'
        END
        AS "Error Count"
        from $wm_db_schemaname.tran_Log
        where MSG_TYPE = 'WaveCube'
        AND
	      (RESULT_CODE != 25 and RESULT_CODE != 35 and RESULT_CODE != 14)
        AND (LAST_UPDATED_DTTM BETWEEN sysdate - INTERVAL '5' DAY AND sysdate - INTERVAL '10' MINUTE);
        EXIT;
ENDOFSQL
}
    query_return=$(query | tail -n +$((3+1)))

    if [ "$query_return" -ge "$4" ]; then
        echo "WMS Team - WaveCube has $query_return errors - $wm_env | Errors = $query_return"
        exit 2
    elif [ "${query_return}" -ge "$2" ]; then
        echo "WMS Team - WaveCube has $query_return errors - $wm_env | Errors = $query_return"
        exit 1
    else
        echo "WMS Team - WaveCube has $query_return errors - $wm_env | Errors = $query_return"
        exit 0
    fi
else 
    # If inputs are not as expected, print help.
    sName="`echo $0|awk -F '/' '{print $NF}'`"
    echo -e "# Usage:\t$sName -w -c "
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_tran -w 1 -c 2"
    exit
fi

