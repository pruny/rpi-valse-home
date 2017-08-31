#!/bin/bash

# ============================================================================
# >>>  Modify this script to set email receiver(s) - TOADDR <<<
# ============================================================================

TOADDR1="ovidiu.constantin@kantarmedia.com"
TOADDR2="ovidiu.constantin@gmx.com"

HOSTNAME=`/bin/hostname`
NOW=$(date '+%a %d %b %Y %H:%M:%S')

#query to get own ip's
MYWAN=$(dig +short myip.opendns.com @resolver1.opendns.com) #my external ip adress
MYIP=$(/sbin/ifconfig |awk -v i=2 -v j=1 'FNR ==  i{print $2}' |cut -b6-50) #my lan ip adress

#send email
echo -e "$HOSTNAME succesful booting @ $NOW \n\nWAN IP: $MYWAN\n\nLAN IP: $MYIP" | mail -r "\"$HOSTNAME"\" -s "WARNING!! START-up" $TOADDR1 $TOADDR2

#send sms
#/usr/bin/gammu-smsd-inject TEXT +40733331236 -text "$HOSTNAME succesful booting @ $NOW - WAN IP: $MYWAN - LAN IP: $MYIP"
wait
