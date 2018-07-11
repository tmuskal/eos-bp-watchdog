#! /bin/bash
PRODUCERACCT=$1
PASS=$2

LAST_UNPAID_BLOCKS=0
LAST_DATE=`date +%s`
GRACE=252
INTERVAL=5
SCHEDULE_GRACE=$GRACE
API=http://nodes.get-scatter.com

while true;
do
        UNPAID_BLOCKS=`curl "$API/v1/chain/get_producers" --stderr /dev/null  --data-binary '{"json":true,"limit":21}' | jq -e '.rows' | jq --arg prd "$PRODUCERACCT" '.[] | select(.owner == $prd)' | jq -r '.unpaid_blocks'`
        if [ "$UNPAID_BLOCKS" == "" ]
        then
                echo "not in top 21. sleeping"
                sleep $SCHEDULE_GRACE
                LAST_DATE=`date +%s`
                continue
        fi
        if [ "$UNPAID_BLOCKS" != "$LAST_UNPAID_BLOCKS" ]
        then
                if [ "$LAST_UNPAID_BLOCKS" != "0" ]
                then
                        echo "producing"
                else
                        echo "init"
                fi
                LAST_UNPAID_BLOCKS=$UNPAID_BLOCKS
                LAST_DATE=`date +%s`
                sleep 1
        else
                let "DELTA=`date +%s`-$LAST_DATE"
                if [ "$DELTA" -gt "$GRACE" ]
                then
                        cleos wallet unlock --password $PASS -n watchdog  > /dev/null 2> /dev/null
                        echo "NOT producing for too long - unregistering!!!!!"
                        # notify slack/phone/etc.
                        cleos -u $API system unregprod $PRODUCERACCT -p $PRODUCERACCT@watchdog
                        cleos wallet lock -n watchdog > /dev/null 2> /dev/null
                        sleep $SCHEDULE_GRACE
                else
                        echo "not currently producing"
                fi
                sleep $INTERVAL
        fi
done
