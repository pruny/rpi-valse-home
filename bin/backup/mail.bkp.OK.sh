#!/bin/bash

FILEBKP=files@rPi
TOADDR1=ovidiu.constantin@gmx.com
TOADDR2=ovidiu.constantin@kantarmedia.com

NOW=$(date '+%a %d %b %Y %H:%M:%S')
echo -e "$HOSTNAME: NEW FILES BACKUP @ $NOW\n\nCheck [ $FILEBKP ] in USB flash drive" | mail -r "\"$HOSTNAME"\" -s "Backup OK" $TOADDR1 $TOADDR2
echo "OK - mail sent..."