#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ]; then

  dbserver="$5"
  database="$6"
  dbuser="$7"

  secret=$(cat ~/.mssqldb/.$dbuser)
  dbpass=$(echo "$secret" | openssl enc -aes-256-cbc -a -d -salt -pass pass:salt)

  query="select ord_ordid, ord_fulfillmentdate + ' ' + ord_fulfillmentstarttime as 'ord_fulfillmentdatetime',ord_storeid, sum(CONVERT(DECIMAL(8,2),ROUND(ote_total,2,1))) as ote_total from dbo.OGS_Order
      join dbo.OGS_Ordertender on ord_ordid = ote_ordid
      JOIN dbo.ogs_storelist ON OGS_StoreList.sli_storeID = OGS_Order.ord_storeID
      where (ord_ostid >= 5 AND ord_ostid NOT IN (6,11) AND ord_paid = 0 AND ord_actualtotalcharged IS NULL AND ord_total < (ord_estimatedtotal * 50.00))
      AND ((ord_onlinetaxadjusted = 1 AND sli_avalara = 1) OR (sli_Avalara = 0))
      group by ord_fulfillmentdate + ' ' + ord_fulfillmentstarttime, ord_storeID, ord_ordid
      order by ord_fulfillmentdate + ' ' + ord_fulfillmentstarttime, ord_storeid asc;"
  exequery=$(/opt/mssql-tools/bin/sqlcmd -K ReadOnly -S $dbserver -U $dbuser -P $dbpass -d $database -Q "$query")

  query_return=$(echo "$exequery" | grep "rows affected" | sed -e 's|[()]||g' | awk '{ print $1 }')

  if  [ "$query_return" -ge "$4" ]; then
    echo "OGS Tendering process has $query_return files to tender|Tenders=$query_return"
    exit 2
  elif [ "$query_return" -ge "$2" ]; then
    echo "OGS Tendering process has $query_return files to tender|Tenders=$query_return"
    exit 1
  else
    echo "OGS Tendering process has $query_return files to tender|Tenders=$query_return"
    exit 0
  fi
else # If inputs are not as expected, print help.
  echo "# Supplied: $0 $@"
  echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_ogs.sh -w 500 -c 750 ecomsql OnlineGroceryShopping nagios"
  exit
fi
