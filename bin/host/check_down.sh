#!/bin/bash

# ============================================================================
# >>>  Modify accordingly this script to set email receiver(s) - TOADDR <<<
# ============================================================================

TOADDR1="ovidiu.constantin@gmx.com"
TOADDR2="ovidiu.constantin@kantarmedia.com"
HOST="ESPEasy"
HOSTIP="192.168.1.66"

NOW=$(date '+%a %d %b %Y %H:%M:%S')

ping -c 1 -t 1 $HOSTIP;
if [ $? -ne 0 ] ; then
  echo -e "$NOW \n\n$HOST is down! \nPlease check and turn ON if necessary!" | mail -r "\"$HOST"\" -s "WARNING!! $HOST is unreachable" $TOADDR1 $TOADDR2
fi


# ping ramane activ in backgroud (nefacand nimic -> :) pana cand www.google.com raspunde si apoi ping se inchide
# https://serverfault.com/questions/42021/how-to-ping-in-linux-until-host-is-known
#until ping -c1 www.google.com &>/dev/null; do :; done