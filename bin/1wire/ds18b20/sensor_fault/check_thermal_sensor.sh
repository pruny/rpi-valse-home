#!/bin/bash

#
# This script reads the temperature from all connected 1-wire temperature sensors of the DS1820 family.
# The script will do nothing if it can't find any sensors.
# The script will  warn with repeated mails (every 15 minutes) if a failure occurred.
#

HOSTNAME=$(/bin/hostname)
NOW=$(date '+%a %d %b %Y %H:%M:%S')
yy=$(date +\%y)
mm=$(date +\%m)
dd=$(date +\%d)
TOADDR1="ovidiu.constantin@gmx.com"
DEV="1wire"
MSG="-> conexiune pierduta cu senzorul de temperatura"
FAULT="/var/www/files/data/TMPFS/1wire/fault"
FILE="/var/www/files/data/TMPFS/sensor.broken"
TMAX=900 # 15 min beetwin the warning mails
MAIL="$HOSTNAME @  $NOW\n\nConexiune pierduta cu senzor de temperatura!\n\nSistemul nu poate monitoriza corect temperaturile."
W1DIR="/sys/bus/w1/devices"
ASIGN="/root/bin/1wire/temp_log#6/sensors.asign"

# Exit if 1-wire directory does not exist
if [ ! -d $W1DIR ]
then
    echo "Can't find 1-wire device directory"
    exit 1
fi

# Get a list of all devices
DEVICES=$(ls $W1DIR)

# Loop through all devices
for DEVICE in $DEVICES
do
    # Ignore the bus master device
    if [ $DEVICE != "w1_bus_master1" ]
    then
        # Get an answer from this device
        ANSWER=$(cat $W1DIR/$DEVICE/w1_slave)
	if [ ! -e $W1DIR/$DEVICE/w1_slave ]
	then
	echo "BROKEN communication with the temperature sensor . Need to reboot!"
	fi
        # See if device really answered.
        # When a previously existing device is removed,
        # it will read 00 00 00 00 00 00 00 00 00 which results in a valid CRC.
        # That's why we need this extra test.

        echo -e "$ANSWER" | grep -q "00 00 00 00 00 00 00 00 00"

        if [ $? -ne 0 ]
        then
            # The comunication with temperature sensor failed if the CRC unmatches
            echo -e "$ANSWER" | grep -q "NO"
            #echo -e "$ANSWER" | grep -q "YES"
            if [ $? -eq 0 ]
            then
		# record failure
		mkdir -p $FAULT/${yy}/${mm}/${dd}/
		#echo $DEV $MSG $(date +\%s\%3N) >> $FAULT/${yy}/${mm}/${dd}/fault.${yy}${mm}${dd}
		NAME=$(grep $DEVICE $ASIGN | awk {'print $2'})
		echo $(date +"%H:%M:%S:%3N ") $DEV $MSG ":" $NAME "@ epoch" $(date +\%s\%3N) >> $FAULT/${yy}/${mm}/${dd}/fault.${yy}${mm}${dd}
		chown -R www-data:www-data $FAULT/
		mkdir -p /home/shared/Error/1wire/${yy}/${mm}/${dd}/
		cp $FAULT/${yy}/${mm}/${dd}/fault.${yy}${mm}${dd} /home/shared/Error/1wire/${yy}/${mm}/${dd}/
		#echo "LOST communication with the temperature sensor"

		if [ ! -e $FILE ]
		then
		    echo -e "$MAIL" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
		    #echo "Warning mail sent to recipients!"
		    touch $FILE
                else
		   LST_MDF=$(stat -c %Y ${FILE})
		   DIFF=$(( $(date +"%s") - $LST_MDF ))
		   #echo "last mod" $LST_MDF
		   #echo "diff" $DIFF
		   if (( $DIFF > $TMAX ))
		   then
		       #echo -e "$MAIL" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
		       rm -f /var/www/files/data/TMPFS/sensor.broken
		   fi
		fi
            else
		#echo "RESTORED communication with the temperature sensor "
		rm -f /var/www/files/data/TMPFS/sensor.broken
            fi
        fi
    fi
done




