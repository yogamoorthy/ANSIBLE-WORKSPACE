#!/bin/bash
#rhelmif_version_of_staledrops
STALE_DROPS="$(for a in `find /apps/scope/mif/transfer/ -name "*drop" | grep \
            -v salesorder| grep \
            -v append`; do find $a -type f -mmin +30;done;)"
stale_drop_count=$(echo "$STALE_DROPS" | grep -v '^\s*$' | wc -l)

if [ "$stale_drop_count" -ge 1 ]; then
  echo "CRITICAL: STALE DROPS EXIST - $STALE_DROPS"
  exit 2
else
  echo "NO STALE DROPS EXIST"
  exit 0
fi
