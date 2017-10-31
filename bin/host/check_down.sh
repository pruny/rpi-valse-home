#!/bin/bash

# ============================================================================
# >>>  Modify accordingly this script to set email receiver(s) - TOADDR <<<
# ============================================================================

TOADDR1="ovidiu.constantin@gmx.com"
TOADDR2="ovidiu.constantin@kantarmedia.com"
HOST="ESPEasy"
HOSTIP="192.168.1.166"
FAULT="/var/www/TMPFS/"$HOST".down"
NOW=$(date '+%a %d %b %Y %H:%M:%S')

#ping -c 1 -t 1 $HOSTIP;  # count ping (normal way)
ping -w 10 -t 1 $HOSTIP;  # deadline ping in seconds (usefull if host is lasy)
if [ $? -ne 0 ] ; then
  if [ ! -e $FAULT ]; then
    touch $FAULT
    echo -e "$NOW \n$HOST is down! \nPlease check and turn ON if necessary!" | mail -r "\"$HOST"\" -s "WARNING!! $HOST is unreachable" $TOADDR1 $TOADDR2
  fi
  elif [ -e $FAULT ]; then
    rm -f $FAULT
    echo -e "$NOW \n$HOST connection recovery!" | mail -r "\"$HOST"\" -s "WARNING!! $HOST is UP!" $TOADDR1 $TOADDR2
fi





# ping ramane activ in backgroud (nefacand nimic -> :) pana cand www.google.com raspunde si apoi ping se inchide
# https://serverfault.com/questions/42021/how-to-ping-in-linux-until-host-is-known
#until ping -c1 www.google.com &>/dev/null; do :; done