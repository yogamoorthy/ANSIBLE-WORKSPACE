#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ] && [ "$5" = "-e" ]; then

    ENVIRONMENT=$6

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
SELECT
    COUNT(DISTINCT prod_trkg_tran.user_id) AS "users picking"
FROM
    $wm_db_schemaname.prod_trkg_tran
WHERE
    prod_trkg_tran.menu_optn_name = 'VocollectPack'
    AND prod_trkg_tran.mod_date_time BETWEEN sysdate - 1 / 1440 AND sysdate
GROUP BY
    trunc(prod_trkg_tran.mod_date_time, 'hh24') + trunc(to_char(prod_trkg_tran.mod_date_time, 'MI') / 5) * 5 / 1440
ORDER BY
    1 DESC;
ENDOFSQL
    }

    query_return_number=$(query | grep -v '^\s*$' | tail -n +$((2+1)))
    query_return=$(echo "$query_return_number" | tr -cd '[[:digit:]]')



    if [ "$query_return" -ge "$4" ]; then
        echo "There are $query_return pickers - $wm_env|pickers=$query_return;;;;"
        exit 2
    elif [ "${query_return}" -ge "$2" ]; then
        echo "There are $query_return pickers - $wm_env|pickers=$query_return;;;;"
        exit 1
    else
        echo "There are $query_return pickers - $wm_env|pickers=$query_return;;;;"
        exit 0
    fi
else # If inputs are not as expected, print help.
    sName="$(echo $0 | awk -F '/' '{print $NF}')"
    echo -e "# Usage:\t$sName -w -c "
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_wms_pulling_count -w 1 -c 2 -e"
    exit
fi

