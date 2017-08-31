#!/bin/bash

# ============================================================================
# >>> Modify this script to set TOADDR <<<
# ============================================================================

TOADDR1="ovidiu.constantin@kantarmedia.com"
TOADDR2="ovidiu.constantin@gmx.com"

HOSTNAME=$(/bin/hostname)
NOW=$(date '+%a %d %b %Y %H:%M:%S')

# archive directory (volatile, in RAM)
DIR="/var/www/files/data/TMPFS/IP/"

# check if directory exists - after reboot RAM is erased & this directory is missing
if [ ! -d "$DIR" ];
   then
      echo "IP directory doesn't exist, creating it now!"
      mkdir -p $DIR
fi

SAVIP=""
OLDIP=""
NEWIP=""

# query to get own ip
MYIP=$(/sbin/ifconfig |awk -v i=2 -v j=1 'FNR ==  i{print $2}' |cut -b6-50)
#WMYIP=$(/sbin/ifconfig |awk -v i=18 -v j=1 'FNR ==  i{print $2}' |cut -b6-50)

# internet server query to get public ip
#NEWIP=""
#NEWIP=";; connection timed out; no servers could be reached"
#NEWIP=$(wget -qO- ipecho.net/plain)
#NEWIP=$(wget -qO - ifconfig.co/x-real-ip)

NEWIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
NEW=$(echo $NEWIP | awk '{print $1}' | cut -b1) #isolate first string of ip adress

# rejects ip if first string is empty or containing non-digits
# and save previous wan ip
case $NEW in
    ''|*[!0-9]*) exit 0 ;;
    *) cp ${DIR}ip.txt ${DIR}sav.ip.txt ;;
esac

# read old ip and save new ip
read OLDIP < ${DIR}ip.txt
read SAVIP < ${DIR}sav.ip.txt
echo "$NEWIP" > ${DIR}ip.txt

if [ "$OLDIP" != "" ];then # after reboot this variable is null (ram is erased)
  if [ "$NEWIP" != "$OLDIP" ];then # real change of external ip
    # save external ip address and send mail & sms
    echo "$NEWIP" > /var/www/files/data/TMPFS/IP/ip.txt
    echo -e "$HOSTNAME @  $NOW\n\nNEW WAN IP: $NEWIP\n\nPREVIOUS WAN IP: $SAVIP\n\nLAN IP: $MYIP" | mail -r "\"$HOSTNAME"\" -s "WARNING!! External IP changed" $TOADDR1 $TOADDR2
    #/usr/bin/gammu-smsd-inject TEXT +40733331236 -text "WARNING from $HOSTNAME: external IP changed @  $NOW - NEW WAN IP: $NEWIP - PREVIOUS WAN IP: $SAVIP - LAN IP: $MYIP"
    wait
  fi
fi