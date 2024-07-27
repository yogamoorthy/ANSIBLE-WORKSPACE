#!/bin/bash

if [ "$1" = "-e" ]; then

ENVIRONMENT=$2

export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.x86_64"
export ANT_HOME="/manh/3rdparty/swtools/ant/apache-ant-1.9.4"
export ORACLE_HOME="/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1"
export JBOSS_HOME="/manh/3rdparty/swtools/jboss/jboss-eap-6.3"

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

PATH=$PATH:$HOME/.local/bin:$HOME/bin:$ORACLE_HOME/bin

export DATABASE_HOME=$ORACLE_HOME

PATH=$ANT_HOME/bin:$JAVA_HOME/bin:$ORACLE_HOME/bin:$JBOSS_HOME/bin:$PATH


export PATH

query() {
    sqlplus -S $wm_db_username/$secret@$wm_db_servicename <<ENDOFSQL
        SELECT regexp_substr(to_char(substr(data,1,3000)),'[^,^]+',1,5)||regexp_substr(to_char(substr(data,1,3000)),'[^,^]+',1,6),count(1)
        FROM $wm_db_schemaname.CL_ENDPOINT_QUEUE CIEQ
        INNER JOIN $wm_db_schemaname.CL_MESSAGE CM
        on CM.MSG_ID = CIEQ.MSG_ID
        WHERE cm.event_id = 2420000 and CM.WHEN_CREATED >= sysdate - .5/24  and cm.data like 'prTaskODRPicked%'
        group by regexp_substr(to_char(substr(data,1,3000)),'[^,^]+',1,5)||regexp_substr(to_char(substr(data,1,3000)),'[^,^]+',1,6) having count(1) > 1;
ENDOFSQL
}
query_return=`query | grep "selected" | awk '{print $1}'`

if [ "$query_return" -ge "1" ]; then
  echo "Duplicate pick orders - $query_return - $wm_env | Errors = $query_return"
  exit 1
else
  echo "Duplicate pick orders - $query_return - $wm_env | Errors = $query_return"
  exit 0
fi
else # If inputs are not as expected, print help.
sName="`echo $0|awk -F '/' '{print $NF}'`"
echo -e "# Usage:\t$sName -w -c "
echo -e "\t\t= warnlevel and critlevel is numeric value"
echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_tran -w 1 -c 2"
exit
fi
