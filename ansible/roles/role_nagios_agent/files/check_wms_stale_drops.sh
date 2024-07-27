# Description: a simple check for alerting on files older than one hour
#              in various drop folders

# Author:      Tony Welder
# Email:       tony.wvoip@gmail.com

STALE_DROPS="$(for a in `find /manh/transfer/ -name "*drop" | grep \
            -v salesorder`; do find $a -type f -mmin +60;done;)"

if [ -z "$STALE_DROPS" ]; then
  echo "OK: no stale files reside in any drop folder"
  exit 0
else
  echo "CRITICAL: STALE DROPS EXIST - $STALE_DROPS"
  exit 2
fi

