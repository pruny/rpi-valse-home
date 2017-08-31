#!/bin/bash

# This script reads the temperature from all connected 1-wire temperature sensors of the DS1820 family.
# The script will answer nothing if it can't find any sensors.
#

W1DIR="/sys/bus/w1/devices"

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

        # See if device really answered. When a previously existing device is removed
        # it will read 00 00 00 00 00 00 00 00 00 which results in a valid CRC.
        # That's why we need this extra test.

        echo -e "$ANSWER" | grep -q "00 00 00 00 00 00 00 00 00"

        if [ $? -ne 0 ]
        then
            # The temperature is only valid if the CRC matches
            echo -e "$ANSWER" | grep -q "YES"
            if [ $? -eq 0 ]
            then
                # Isolate the temperature from the second line (in millidegree Celsius)
                TEMP=$(echo -e "$ANSWER" | grep "t=" | cut -f 2 -d "=")
                # Convert CELSIUS to FAHRENHEIT
                FTEMP=$(echo "$TEMP*180/100+32000" |bc)
                # Isolate integer and fraction parts so we know where the decimal point should go
                # celsius
                INTEGER=${TEMP:0:(-3)}
                FRACTION=${TEMP:(-1)}
                # fahrenheit
                FINTEGER=${FTEMP:0:(-3)}
                FFRACTION=${FTEMP:(-1)}

                # Restore the leading 0 for positive and negative numbers
		# celsius
                if [ -z $INTEGER ]
                then
                    INTEGER="0"
                fi
                if [ "$INTEGER" == "-" ]
                then
                    INTEGER="-0"
                fi

                # fahrenheit
                if [ -z $FINTEGER ]
                then
                    FINTEGER="0"
                fi
                if [ "$FINTEGER" == "-" ]
                then
                    FINTEGER="-0"
                fi

                # Define symbol for degree celsius or fahrenheit
                CLS=$'\xc2\xb0'C
                FHR=$'\xc2\xb0'F

                # Write result of every sensor: celsius and fahrenheit
                echo "$DEVICE : $INTEGER.$FRACTION$CLS - $FINTEGER.$FFRACTION$FHR"
            else
                # A CRC was found, show error message instead
                echo "$DEVICE : CRC error"
            fi
        fi
    fi
done
