export ORACLE_HOME=/manh/3rdparty/swtools/oracle/app/oracle/product/12.1.0/client_1
export PATH=$PATH:$ORACLE_HOME/bin
DBUSER=$1
DBPWD=$2
DB=$3
RUN_AS=$4

PRI_SVC_URL="http://{{ pri_svc_url }}.hy-vee.net:12000/services"
SEC_SVC_URL="http://{{ sec_svc_url }}.hy-vee.net:12000/services"
DEV_SVC_URL=""

getNOW()
{
    date +"%m%d%y_%H%M"
}


usage()
{
    echo "Usage : ./Shipment_cleanup.sh <DBUSER> <DBPWD> <DB> <PRI|SEC|DEV>"
    echo "DBUSER - User account used to log into the DB"
    echo "DBPWD  - Password for DBUSER"
    echo "DB     - {database hostname}:{port}/{service name or SID}"
    echo "PRI    - Pass this when ran on primary node"
    echo "SEC    - Pass this when ran on secondary node"
    echo "DEV    - Pass this when ran on development node"
    exit 1
}

if [ "$#" -ne 4 ]
then
    usage
fi

##Check for Node availability
if [ "$RUN_AS" = "PRI" ]
then
        output=`curl ${PRI_SVC_URL} 2>&1 | grep -ci "connection refused"`
        if [ $output -eq 1 ]
        then
                echo "$(getNOW) Primary WM server not running ....exiting as failed"
                exit 1
        fi
fi

if [ "$RUN_AS" = "SEC" ]
then
        output=`curl ${PRI_SVC_URL} 2>&1 | grep -ci "connection refused"`
        if [ $output -eq 1 ]
        then
                echo "$(getNOW) Primary WM server not running..checking secondary"
                output=`curl ${SEC_SVC_URL} 2>&1 | grep -ci "connection refused"`
                if [ $output -eq 1 ]
                then
                        echo "$(getNOW) Secondary WM server is also not running...exiting as failed"
                        exit 1
                fi
        else
                echo "$(getNOW) Primary WM server running nothing to do...exiting as success"
                exit 0
        fi
fi

if [ "$RUN_AS" = "DEV" ]
then
                ##CBS_HOME=/manh/apps/scope/dev_wm/cbs
                ##echo "$(getNOW) $CBS_HOME"
        output=`curl ${DEV_SVC_URL} 2>&1 | grep -ci "connection refused"`
        if [ $output -eq 1 ]
        then
                echo "$(getNOW) Dev WM server not running ....exiting as failed"
                exit 1
        fi
fi
## Node check done, continue with rest of the program

echo "$(getNOW) Starting shipment cleanup."

## remove stops
sqlString=$(sqlplus -s $DBUSER/$DBPWD@$DB <<ENDOFSQL
        SET HEADING OFF;
        SET FEEDBACK OFF;
        SET LINESIZE 1000;
        delete from stop s
        where not exists
        (
            select 1 from lpn l where l.shipment_id = s.shipment_id
        )
        and shipment_id in (
            select shipment_id from shipment where pickup_start_dttm < sysdate - 7
        );
        COMMIT;
        EXIT;
ENDOFSQL
)

echo "$(getNOW) Stops removed."

## remove stop actions
sqlString=$(sqlplus -s $DBUSER/$DBPWD@$DB <<ENDOFSQL
        SET HEADING OFF;
        SET FEEDBACK OFF;
        SET LINESIZE 1000;
        delete from stop_action s
        where not exists
        (
            select 1 from lpn l where l.shipment_id = s.shipment_id
        )
        and shipment_id in (
            select shipment_id from shipment where pickup_start_dttm < sysdate - 7
        );
        COMMIT;
        EXIT;
ENDOFSQL
)

echo "$(getNOW) Stop actions removed."

## remove shipments
sqlString=$(sqlplus -s $DBUSER/$DBPWD@$DB <<ENDOFSQL
        SET HEADING OFF;
        SET FEEDBACK OFF;
        SET LINESIZE 1000;
        delete from shipment s
        where not exists
        (
            select 1 from lpn l where l.tc_shipment_id = s.tc_shipment_id
        )
        and not exists
        (
            select 1 from orders o where o.shipment_id = s.shipment_id
        )
        and s.pickup_start_dttm < sysdate -1;
        COMMIT;
        EXIT;
ENDOFSQL
)


echo "$(getNOW) Shipments removed. Shipment cleanup finished."
