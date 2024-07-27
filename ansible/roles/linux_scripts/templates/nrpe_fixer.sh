#!/bin/bash
# Description: this script is designed to do just two things
#              Restart nrpe if its failed
#              ensure it's /run pid directory exists

# Set up:      should be run once every 10 minutes (every minute is overkill)
#              should be run as a user that has privs to /run

# Author:      Tony Welder
# Email:       twelder@hy-vee.com


/usr/sbin/service nrpe status > /dev/null
if [ $? = 0 ]; then
  #service is running, nothing to do
  exit 0
else
  #let's just fix the pid directory
  /usr/bin/mkdir -p /run/nrpe
  /usr/bin/chown -R nrpe:nrpe /run/nrpe
  /usr/bin/chmod -R 755 /run/nrpe
  /usr/sbin/service nrpe start > /dev/null
fi
