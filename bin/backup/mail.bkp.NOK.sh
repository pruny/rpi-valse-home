#!/bin/bash

FILEBKP=files@rPi
TOADDR1=ovidiu.constantin@gmx.com
TOADDR2=ovidiu.constantin@kantarmedia.com

NOW=$(date '+%a %d %b %Y %H:%M:%S')
echo -e "$HOSTNAME: BACKUP FAILL @ $NOW\n\nCheck [ $FILEBKP ] in USB flash drive" | mail -r "\"$HOSTNAME"\" -s "Backup NOK" $TOADDR1 $TOADDR2
echo "NOK - mail sent..."