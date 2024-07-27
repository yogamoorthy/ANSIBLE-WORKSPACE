#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ]&& [ "$3" = "-e" ]; then

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
        select rule_id, open_paran, tbl_name, colm_name, oper_code, rule_cmpar_value, and_or_or, close_paran, mod_date_time, user_id, last_updated_dttm
        from rule_sel_dtl
        versions between timestamp sysdate - 1/24 and sysdate
        where rule_id in ('1434505', '1009296', '1004184', '1096772', '1030696',
        '1091559', '1030695', '1434505', '2526022', '1030694' ,'1062247', '1069739', '999798')
        and mod_date_time > sysdate -1/24
        and user_id <> 'WMADMIN'
        order by sel_seq_nbr;
        EXIT;
ENDOFSQL
  }
    query_return=$(query | tail -n +$((3 + 1)))

    if [ "${query_return}" -ge "$2" ]; then
        echo "There is a different wave clear than normal"
        exit 1
    else
        echo "No different waves"
        exit 0
    fi
else # If inputs are not as expected, print help.
    sName="$(echo $0 | awk -F '/' '{print $NF}')"
    echo -e "# Usage:\t$sName -w -c "
    echo -e "\t\t= warnlevel and critlevel is numeric value"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_pix -w 1 -c 2"
    exit
fi

