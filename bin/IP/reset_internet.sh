#!/bin/bash

COUNTER=0
while [ $COUNTER -lt 5 ]
do
if ping -c 1 8.8.8.8 &> /dev/null
then
exit 1
elif ping -c 1 8.8.4.4 &> /dev/null
then
exit 1
else
let COUNTER=COUNTER+1
fi
done
echo -e "\nThe modem is rebooted NOW!" ## Watts Clever Off
sleep 5
echo -e "\nModem was started!" ## Watts Clever ON
echo 0