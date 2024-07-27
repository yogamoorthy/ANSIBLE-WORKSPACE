#!/bin/bash
# This check is specific to Chariton
# Chariton is our only warehouse with this Quad function
if [ "$1" = "-c" ] && [ "$2" -gt "0" ] && [ "$3" = "-e" ]; then

    ENVIRONMENT=$4

    export JAVA_HOME="/usr/lib/jvm/java"
    export ANT_HOME="/manh/3rdparty/swtools/ant/apache-ant-1.9.4"
    export ORACLE_HOME="/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1"
    export JBOSS_HOME="/manh/3rdparty/swtools/jboss/jboss-eap-6.3"

    CHRENV=`echo "$ENVIRONMENT" | awk -F '-' '{print $3}'`
    source /opt/hy-vee/scripts/${CHRENV}/env-setup.sh

    secret=$(echo $wm_db_pass | openssl enc -aes-128-cbc -a -d -salt -pass pass:$wm_db_salt)

    PATH=$PATH:$HOME/.local/bin:$HOME/bin:$ORACLE_HOME/bin
    export DATABASE_HOME=$ORACLE_HOME
    PATH=$ANT_HOME/bin:$JAVA_HOME/bin:$ORACLE_HOME/bin:$JBOSS_HOME/bin:$PATH
    export PATH

query() {
    sqlplus -S $wm_db_username/$secret@$wm_db_servicename <<ENDOFSQL
        set linesize 1000
        col item_name for a25
        col description for a35
        with two as (
        select lh.dsp_locn,
        count (pld.item_id) Items
        from chrmda${CHRENV}.locn_hdr lh , chrwm${CHRENV}.pick_locn_dtl pld
        where lh.locn_id = pld.locn_id
        group by lh.dsp_locn
        having count( *) > 1)
        select lh.dsp_locn,
        ic.item_name,
        ic.description,
        ic.ref_field5 as "Quad?"
        from chrmda${CHRENV}.locn_hdr lh
        join chrwm${CHRENV}.pick_locn_dtl pld on pld.locn_id = lh.locn_id
        join chrwm${CHRENV}.item_cbo ic on ic.item_id = pld.item_id
        join two t on t.dsp_locn = lh.dsp_locn
        where ic.ref_field5 = 'quad'
        order by 1;
ENDOFSQL
}
    query_return=$(query | grep "quad" | wc -l)
    query_dsp_locn=$(query | grep "quad" | awk '{print $1}')

    if [ "$query_return" -ge "$2" ]; then
        echo "WMS Team - CRITICAL: Waves failing Quad double slotted - $query_return error(s) - $query_dsp_locn - $wm_env | Errors = $query_return"
        exit 2
    else
        echo "WMS Team - OK: Everything is fine - No errors - $wm_env | Errors = $query_return"
        exit 0
    fi
else 
    # If inputs are not as expected, print help.
    sName="`echo $0|awk -F '/' '{print $NF}'`"
    echo -e "# Usage:\t$sName -c 1 -e $hostname-warehouse"
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/$sName -c 1 -e chrdevapp1-v-per"
    exit
fi
