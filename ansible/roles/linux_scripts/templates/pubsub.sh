#!/bin/bash

export_dir="/usr/local/gkretail/ucon/tenants/001/dataexchange/export_channel/results/import/IMPORT_SUCCESS/$(date "+%G%m%d")"
wait_counter="60"

timestamp() {
    date '+%b %d %T'
}

control_count="0"

while true; do
  file_count=$(ls -U ${export_dir} | sort | wc -l)
  echo -e "$(timestamp) - File count: ${file_count} | Diff $((file_count-control_count))"
  sleep ${wait_counter}
  control_count="$file_count"
done
