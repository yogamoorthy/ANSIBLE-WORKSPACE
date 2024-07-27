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
    select distinct (o.tc_order_id), o.pickup_start_dttm
    from $wm_db_schemaname.orders o
    join $wm_db_schemaname.order_line_item oli on o.order_id = oli.order_id
    where oli.vas_process_type = '1'
    and o.pickup_start_dttm >= sysdate - .5
    and o.pickup_start_dttm <= sysdate + .5
    and oli.pick_locn_id is not null
    and o.wm_order_status != '20'
    and o.Do_status ='110'
    and oli.do_dtl_status !='110'
    and oli.ref_field6 is null;
ENDOFSQL
}

query_return=$(query | grep "rows selected" | awk '{ print $1 }')

if [ "$query_return" == "no" ]; then
    query_return="0"
fi

  if [ "$query_return" -ge "$2" ]; then
    echo "There are $query_return special processes pending - $wm_env | Errors=$query_return"
    exit 2
  else
    echo "There are $query_return special processes pending - $wm_env | Errors=$query_return"
    exit 0
  fi
else # If inputs are not as expected, print help.
  sName="$(echo $0 | awk -F '/' '{print $NF}')"
  echo -e "# Usage:\t$sName -w -c "
  echo -e "\t\t= warnlevel and critlevel is numeric value"
  echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_spp -w 1 -e"
  exit
fi
