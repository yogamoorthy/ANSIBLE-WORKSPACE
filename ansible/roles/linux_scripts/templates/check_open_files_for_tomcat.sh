#checks to see how many concurret open files Tomcat current has
while true; do
  OPEN_FILES=$(ls /proc/`ps auxww | grep tomcat | grep -v grep | grep -v open_files | awk '{print $2}'`/fd | wc -l)
  DATE_TIME=`date | awk -F ' CST' '{print $1}'`
  echo "${DATE_TIME} : ${OPEN_FILES}" >> /tmp/tomcat_open_files.log
  sleep 5
done