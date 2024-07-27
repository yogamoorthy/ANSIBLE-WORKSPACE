#!/bin/bash
# This check is specific to LDC
if [ "$1" = "-c" ] && [ "$2" -gt "0" ]; then

    export JAVA_HOME="/usr/lib/jvm/java"
    export ANT_HOME="/manh/3rdparty/swtools/ant/apache-ant-1.10.5"
    export ORACLE_HOME="/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1"
    export JBOSS_HOME="/manh/3rdparty/swtools/jboss/jboss-eap-6.3"

    source /opt/hy-vee/scripts/env-setup.sh

    secret=$(echo $wm_db_pass | openssl enc -aes-128-cbc -a -d -salt -pass pass:$wm_db_salt)

    PATH=$PATH:$HOME/.local/bin:$HOME/bin:$ORACLE_HOME/bin
    export DATABASE_HOME=$ORACLE_HOME
    PATH=$ANT_HOME/bin:$JAVA_HOME/bin:$ORACLE_HOME/bin:$JBOSS_HOME/bin:$PATH
    export PATH

query() {
    sqlplus -S $wm_db_username/$secret@$wm_db_servicename <<ENDOFSQL
        select cle.msg_id,
        ldcwm.cle.when_queued,
        cl.data
        from ldcwm.cl_endpoint_queue cle
        join ldcwm.cl_message cl on cl.msg_id = cle.msg_id
        where cle.error_count > 0
        and (cl.source_id = 'DEMATIC_IB_ItemStatus'
        or data like '%ITEMDOWN%'
        or cl.source_id = 'MHE Delete Wave')
        and cle.when_status_changed > sysdate - 1/24
        order by 2 desc;
        EXIT;
ENDOFSQL
}
    query_return=$(query | grep -i "itemstatus" | wc -l)
    query_dsp_locn=$(query | grep -i "itemstatus" | awk '{print $1}')

    if [ "$query_return" -ge "$2" ]; then
        echo "WMS Team - CRITICAL: There are errors in the LDC Message Queue - $query_return error(s) - $query_dsp_locn - $wm_env | Errors = $query_return"
        exit 2
    else
        echo "WMS Team - OK: Everything is fine - No errors - $wm_env | Errors = $query_return"
        exit 0
    fi
else 
    # If inputs are not as expected, print help.
    sName="`echo $0|awk -F '/' '{print $NF}'`"
    echo -e "# Usage:\t$sName -c 1 -e $hostname"
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/$sName -c 1"
    exit
fi
