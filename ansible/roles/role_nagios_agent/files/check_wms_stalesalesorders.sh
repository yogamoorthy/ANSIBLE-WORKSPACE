# Description: this is a nagios script for checking if there are stale orders.
#              There are two different types of checks this will do
#              if there are any files that are an hour or older at any point
#              through out the day AND there are more than 10 of them, create
#              a critial alert because the port is probably down.
#              second alert is for a specific time periouds, where if there
#              are any files created before 10:18.344 within the time frame
#              of 10:45am -> 11:am or pm, then send a critical.

# environment is a folder name in /man/transfer/*
ENVIRONMENT="$1"
ORDERS_PATH="/manh/transfer/${ENVIRONMENT}/salesorder/drop"
#maximum age for a files in minutes, files newer than this time
MAX_ORDER_AGE=60
#maximum number of files allowed to exist without flaggin a warning that are older than the MAX_ORDER_AGE
MAX_ORDER_COUNT=10

#We have to pull the beginning of the day for time based calculations of this nature
CURRENT_EPOCH=`date +%s`
DAY=$(date -d "$D" '+%d')
MONTH=$(date -d "$D" '+%m')
YEAR=$(date -d "$D" '+%Y')
TODAY_START_EPOCH=`date "+%s" -d "$MONTH/$DAY/$YEAR 00:00:00"`

#10:45 am
AM_START_EPOCH=$(expr $TODAY_START_EPOCH + 38700)
#11:30 am
AM_END_EPOCH=$(expr $TODAY_START_EPOCH + 41400)
#10:45 pm
PM_START_EPOCH=$(expr $TODAY_START_EPOCH + 81900)
#11:30 pm
PM_END_EPOCH=$(expr $TODAY_START_EPOCH + 84600)


#AM rush check
if [ $CURRENT_EPOCH -gt $AM_START_EPOCH -a $CURRENT_EPOCH -lt $AM_END_EPOCH ]; then
  AM_CUT_OFF=$(expr $AM_START_EPOCH - 1641)
  for order in `find $ORDERS_PATH -maxdepth 1 -type f`; do
    if [ `stat -c%Y ${ORDERS_PATH}/${order}` -ls $AM_CUT_OFF ]; then
      echo "CRITICAL: ORDERS created before 10:18.344 AM exist in $ORDERS_PATH"
      exit 2
    fi
  done
  echo "OK: $ORDERS_PATH has no stale orders in it"
  exit 0
#PM rush check
elif [ $CURRENT_EPOCH -gt $PM_START_EPOCH -a $CURRENT_EPOCH -lt $PM_END_EPOCH ]; then
  PM_CUT_OFF=$(expr $PM_START_EPOCH - 1641)
  for order in `find $ORDERS_PATH -maxdepth 1 -type f`; do
    if [ `stat -c%Y ${ORDERS_PATH}/${order}` -ls $PM_CUT_OFF ]; then
      echo "CRITICAL: ORDERS created before 10:18.344 PM exist in $ORDERS_PATH"
      exit 2
    fi
  done
  echo "OK: $ORDERS_PATH has no stale orders in it"
  exit 0
#ALL day check
else
  ORDER_COUNT=`find $ORDERS_PATH -maxdepth 1 -type f -mmin +${MAX_ORDER_AGE} | wc -l`
  if [ $ORDER_COUNT -gt $MAX_ORDER_COUNT ]; then
    echo "CRITICAL: Too many orders have built up in $ORDERS_PATH!"
    echo "there are $ORDER_COUNT Orders that are more than $MAX_ORDER_AGE minutes old"
    echo "Check if ports are down."
    exit 2
  else
  echo "OK: $ORDERS_PATH has no stale orders in it"
  exit 0
  fi
fi


