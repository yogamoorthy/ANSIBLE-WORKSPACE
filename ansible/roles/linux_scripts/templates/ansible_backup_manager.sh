# Description: All this does is move a backup config file to a directory and ensure there isn't more than 4 copies of it in that directory.
#
# Author: Tony Welder
# email: twelder@hy-vee.com
#
# Usage: ./ansible_backup_manager <Fully Qualified path to file>
# Example: ./ansible_backup_manager /etc/ntp.conf
# DO NOT put the actual backup file name in, the script will discover it!

#Read in arguments
CONFIG_PATH="$1"
BACKUP_PATH="/opt/hy-vee/ansible_backups"
if [ ! -d $BACKUP_PATH ]; then
  /usr/bin/mkdir -p $BACKUP_PATH
fi
if [ $(ls ${CONFIG_PATH}*~ 2> /dev/null | wc -l) -gt 0 ]; then

  /bin/mv ${CONFIG_PATH}*~ ${BACKUP_PATH}/
  /bin/chmod 440 ${BACKUP_PATH}/*
  /bin/chown root:wheel ${BACKUP_PATH}/*

  CONFIG_FILE=`echo $CONFIG_PATH | awk '{n=split($1,A,"/"); print A[n]}'`
  echo "the config file $CONFIG_FILE"




else
  echo "No backup files exist at ${CONFIG_PATH}"
  exit 0
fi

exit 0
