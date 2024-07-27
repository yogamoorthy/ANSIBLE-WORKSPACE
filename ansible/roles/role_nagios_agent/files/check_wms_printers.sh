#!/bin/bash

# quick and dirty printer checker
# checks to see if there are any printers with queues.

LPSTAT='/bin/lpstat'
ECHO='/bin/echo'
WC='/bin/wc'

QUEUED_JOBS="$(${LPSTAT} -o | ${WC} -l)"

if [ $QUEUED_JOBS -gt 1500 ]
then
    $ECHO "$QUEUED_JOBS print jobs queued!!"
    exit 2
elif [ $QUEUED_JOBS -gt 750 ]
then
    $ECHO "$QUEUED_JOBS print jobs queued!"
    exit 1
else
    $ECHO "Print Queues OK"
    exit 0
fi

