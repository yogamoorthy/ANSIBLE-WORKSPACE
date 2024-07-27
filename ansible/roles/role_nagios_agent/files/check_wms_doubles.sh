#!/bin/bash
if [ "$1" = "-c" ] && [ "$2" -gt "0" ]; then
    ENVIRONMENT=$4
    echo "$ENVIRONMENT" | egrep '^chr' >/dev/null
    if [ "$?" -eq 0 ]; then
        CHRENV=`echo "$ENVIRONMENT" | awk -F '-' '{print $3}'`
        source /opt/hy-vee/scripts/${CHRENV}/env-setup.sh
    else
        source /opt/hy-vee/scripts/env-setup.sh
    fi
    secret=$(echo $wm_db_pass | openssl enc -aes-128-cbc -a -d -salt -pass pass:$wm_db_salt)
    export JAVA_HOME="/usr/lib/jvm/java"
    export ANT_HOME="/manh/3rdparty/swtools/ant/apache-ant-1.10.5"
    export ORACLE_HOME="/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1"
    export JBOSS_HOME="/manh/3rdparty/swtools/jboss/jboss-eap-6.3"
    PATH=$PATH:$HOME/.local/bin:$HOME/bin:$ORACLE_HOME/bin
    export DATABASE_HOME=$ORACLE_HOME
    PATH=$ANT_HOME/bin:$JAVA_HOME/bin:$ORACLE_HOME/bin:$JBOSS_HOME/bin:$PATH
    export PATH
query() {
    sqlplus -S $wm_db_username/$secret@$wm_db_servicename <<ENDOFSQL
        SET PAGESIZE 50000
        SET LINESIZE 200
        SELECT distinct cm.source_id
        FROM $wm_db_schemaname.cl_message cm
        INNER JOIN $wm_db_schemaname.cl_endpoint_queue ceq on cm.msg_id = ceq.msg_id
        INNER JOIN (SELECT tc_lpn_id
        FROM $wm_db_schemaname.lpn
        where lpn_facility_status = 10) ll
        on cm.data LIKE '%' || ll.tc_lpn_id || '%'
        AND ceq.endpoint_id = 21;
        EXIT;
ENDOFSQL
}
    query_return=$(query | tail -n +$((3 + 1)) | grep -v "rows selected" | grep $4 | xargs)
    doubles=$(query | tail -n +$((3 + 1)) | grep -v "rows selected" | awk '{print $1}' | uniq | xargs)
    if [ ! -z "$doubles" ]; then
        echo "There is a double picking scenario. - $wm_env - Errors = $doubles"
        exit 2
    else
        echo "There are no double picking scenarios. - $wm_env"
        exit 0
    fi
else 
    # If inputs are not as expected, print help.
    sName="`echo $0|awk -F '/' '{print $NF}'`"
    echo -e "# Usage:\t$sName -w -c "
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_doubles -c 1 -e (XI HOSTNAME VARIABLE HERE)"
    exit
fi
