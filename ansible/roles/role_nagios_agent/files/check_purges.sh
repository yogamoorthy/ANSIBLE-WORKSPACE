#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-e" ]; then

ENVIRONMENT=$4

if [ $ENVIRONMENT = "chrdevapp1-v-per" ]; then
  source /opt/hy-vee/scripts/per/env-setup.sh
elif [ $ENVIRONMENT = "chrapp1a-v-per" ]; then
  source /opt/hy-vee/scripts/per/env-setup.sh
elif [ $ENVIRONMENT = "chrdevapp1-v-gro" ]; then
  source /opt/hy-vee/scripts/gro/env-setup.sh
elif [ $ENVIRONMENT = "chrapp1a-v-gro" ]; then
  source /opt/hy-vee/scripts/gro/env-setup.sh
elif [ $ENVIRONMENT = "chrdevapp1-v-hbc" ]; then
  source /opt/hy-vee/scripts/hbc/env-setup.sh
elif [ $ENVIRONMENT = "chrapp1a-v-hbc" ]; then
  source /opt/hy-vee/scripts/hbc/env-setup.sh
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
    select sc.code_id, sc.code_desc, ph.nbr_days_old, ph.purge_status, ph.nbr_rows_purged, ph.message,ph.purge_start_dttm
    from $wm_db_schemaname.purge_hist ph, $wm_db_schemaname.sys_code sc, $wm_db_schemaname.purge_config pc
    where ph.purge_code = sc.code_id
    and pc.purge_code = ph.purge_code
    and sc.code_type = '708'
    and ph.purge_status != 'Completed'
    and ph.purge_start_dttm > sysdate - 2
    order by ph.nbr_rows_purged desc;
ENDOFSQL
}

query_return=$(query | grep "rows selected" | awk '{ print $1 }')

if [ "$query_return" == "no" ]; then
  query_return="0"
fi


if [ "$query_return" -ge "$2" ]; then
  echo "There was $query_return missed purges in $wm_env | Errors = $query_return"
  exit 1
else
  echo "There was $query_return missed purges in $wm_env | Errors = $query_return"
  exit 0
fi
else 
# If inputs are not as expected, print help.
sName="`echo $0|awk -F '/' '{print $NF}'`"
echo -e "# Usage:\t$sName -w -c "
echo -e "\t\t= warnlevel and critlevel is numeric value"
echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_purges -w 1 -e (XI HOSTNAME VARIABLE HERE)"
exit
fi
