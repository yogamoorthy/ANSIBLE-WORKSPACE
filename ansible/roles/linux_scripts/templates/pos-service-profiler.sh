#!/bin/bash

timestamp() {
    date '+%b %d %T'
}


if [ "$1" == "lo" ]; then
  base_url="http://gkprodwebpos1-v.hy-vee.net:8080"
else
  base_url="https://gkprodwebpos.hy-vee.com:8443"
fi

# echo -n Password:
# read -s password
# echo

password="610424"
uuid=$(uuidgen)

# #WorkstationID: 91
# #busnessUnitId: 1224 or 1887

#echo -e "$(timestamp) Starting Profile: ID - $uuid"
echo ""

time curl -s -i --location --request POST ${base_url}/pos-service/tenants/001/services/com.gk_software.pos.api.service.session.PosSessionService/login \
  --header 'Accept: application/json;Format=GK-PLAIN-JSON' \
  --header 'Content-Type: application/json;Format=GK-PLAIN-JSON' \
  --data-raw '{
    "retailStoreId": "1224",
    "workstationId": "91",
    "workstationAddress": "001_1224_91",
    "loginName": "1000020",
    "tillId": {
        "businessUnitGroupID": "100000000000000418",
        "tillID": "91"
    },
    "password": "'"$password"'",
    "trainingMode": false,
    "finalizeControlTransactionFlag": true,
    "useLoginTypeTechnicalForLoginManager": false,
    "additionalSessionCriteria01": "401635392.60298.'"$uuid"'"
    }' | grep "HTTP"

echo ""
echo -e "$(timestamp) Finished Profile: ID - $uuid"