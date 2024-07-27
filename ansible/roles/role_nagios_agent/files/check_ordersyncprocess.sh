#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ]; then

    dbserver="$5"
    database="$6"
    dbuser="$7"

    secret=$(cat ~/.mssqldb/.$dbuser)
    dbpass=$(echo "$secret" | openssl enc -aes-256-cbc -a -d -salt -pass pass:salt)
    late_order_detail="SELECT COUNT(1) [LateOrders]
    FROM dbo.OGS_OrderStatusLog s (NOLOCK)
    JOIN dbo.OGS_Order o (NOLOCK) ON s.osl_ordID = o.ord_ordID
    WHERE osl_storereceived = 0
    AND DATEDIFF(MINUTE,osl_date,GETDATE()) > 45"

        exe_late_order_detail=$(/opt/mssql-tools/bin/sqlcmd -K ReadOnly -S $dbserver -U $dbuser -P $dbpass -d $database -Q "$late_order_detail" | tail -n +3)
        late_order_integers=$(echo "$exe_late_order_detail" | tr -cd '[[:digit:]]')
        late_order_count=${late_order_integers%?}
       if  [ "$late_order_count" -ge "$4" ]; then
         echo "Order sync process has $late_order_count files backed up"
         exit 2
       elif [ "$late_order_count" -ge "$2" ]; then
         echo "Order sync process has $exe_late_order_count files backed up"
         exit 1
       else
         echo "Order sync process has $late_order_count files backed up"
        echo "this is $late_order_count"
         exit 0
       fi

else "if inputs are not as expected, print help."
    echo "# Supplied: $0 $@"
    echo "# EXAMPLE:  /usr/lib64/nagios/plugins/check_ordersyncprocess.sh -w 30 -c 50 ecomsql OnlineGroceryShopping nagios"
    exit
fi
