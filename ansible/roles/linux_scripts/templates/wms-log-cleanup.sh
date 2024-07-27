#!/bin/bash
FIND=/usr/bin/find
GREP=/usr/bin/grep
TAR=/usr/bin/tar
LS=/usr/bin/ls
AWK=/usr/bin/awk
SED=/usr/bin/sed
GZIP=/usr/bin/gzip
RM=/usr/bin/rm
ECHO=/usr/bin/echo
DATE=`/usr/bin/date -d '1 day ago' '+%y-%m-%d'`
DAY_AGO=`/usr/bin/date -d '1 day ago' '+%b %d'`
TAR_FILE=/manh/apps/scope/log_collect/Logs-$DATE.tar

#For loops looking for previous day's cbs logs then bundling them up
for a in `$FIND /manh/apps/scope -name logs -type d | $GREP cbs | $GREP -v data`
do
  PREV_LOGS=`$LS -ald $a/* |$GREP "$DAY_AGO" |$GREP -v gz |$AWK {'print $9'}| $SED ':a;N;$!ba;s/\n/ /g'`
  if [ -f $TAR_FILE ]; then
    $TAR -rf $TAR_FILE $PREV_LOGS
  else
    $TAR -cf $TAR_FILE $PREV_LOGS
  fi
#Cleanup logs before moving to next directory in for loop
  $RM -f $PREV_LOGS
done

#Archiving that server-startup log file that lacks any sort of log rotation
for i in  `$FIND /manh/apps/scope -name 'server-startup.log'`
do
  if [ -f $TAR_FILE ]; then
    $TAR -rf $TAR_FILE $i
  else
    $TAR -cf $TAR_FILE $i
  fi
#Cleanup that massive startup file
  $ECHO /dev/null > $i
done

#Same thing for the SnapShotCollector directory
for n in `$FIND /manh/apps/scope -name logs -type d | $GREP WMSnapShotCollector`
do
  PREV_LOGS=`$LS -ald $n/* |$GREP "$DAY_AGO" |$GREP -v gz |$AWK {'print $9'}| $SED ':a;N;$!ba;s/\n/ /g'`
  PREV_CPP=`$LS -ald $n/CppLog/* |$GREP "$DAY_AGO" |$GREP -v gz |$AWK {'print $9'}| $SED ':a;N;$!ba;s/\n/ /g'`
  PREV_JAVA=`$LS -ald $n/JavaLog/* |$GREP "$DAY_AGO" |$GREP -v gz |$AWK {'print $9'}| $SED ':a;N;$!ba;s/\n/ /g'`
  if [ -f $TAR_FILE ]; then
    $TAR -rf $TAR_FILE $PREV_LOGS
    $TAR -rf $TAR_FILE $PREV_CPP
    $TAR -rf $TAR_FILE $PREV_JAVA
  else
    $TAR -cf $TAR_FILE $PREV_LOGS
    $TAR -rf $TAR_FILE $PREV_LOGS
    $TAR -rf $TAR_FILE $PREV_LOGS
  fi
#Cleanup logs before moving to next set of directories
  $RM -f $PREV_LOGS
  $RM -f $PREV_CPP
  $RM -f $PREV_JAVA
done

#Gzipping the tarball
$GZIP $TAR_FILE

#Cleanup any log collects older than 2 weeks
$FIND /manh/apps/scope/log_collect/ -iname ".tar.gz" -type f -mtime +14 -exec rm {} \;

exit 0
