#!/bin/bash

# a script to read and save temperature readings from all temperature sensors
# familly DS18*20 1-wire temperature sensors (classes S:10-... or B:28-...)
# save temperature -> °C & time -> hh:mm:ss @ msec :-)
# warn with repeated mails (every 15 minutes) if a failure occurred
#
W1DIR="/sys/bus/w1/devices/w1_bus_master1"
RAMDIR="/var/www/files/data/TMPFS"
LOG="$RAMDIR/1wire/temp"
yy=$(date +\%y)
mm=$(date +\%m)
dd=$(date +\%d)
DATA=$LOG/${yy}/${mm}/${dd}
CLS=$'\xc2\xb0'C
###
ASIGN="/root/bin/1wire/temp_log#6/sensors.asign"
HOSTNAME=$(/bin/hostname)
NOW=$(date '+%a %d %b %Y %H:%M:%S')
TOADDR1="ovidiu.constantin@gmx.com"
MARK="/var/www/files/data/TMPFS/sensor.broken"
TMAX=900 # 15 min beetwin the warning mails
MAIL1="$HOSTNAME @  $NOW\n\nConexiune pierduta cu senzor de temperatura!\n\nSistemul nu poate inregistra corect temperaturile."
MAIL2="$HOSTNAME @  $NOW\n\nConexiune nerestabilita inca cu senzor de temperatura!\n\nSistemul nu poate inregistra corect temperaturile."


# preserve size of ram storage folder to3 MB
size ()
{
SIZE=`du -s $RAMDIR | cut -c 1-4`

if (( $SIZE >= 2999 ));then
	rm -rf $LOG
fi
}

size

# mail delay function
delay ()
{
LST_MDF=$(stat -c %Y ${MARK})
DIFF=$(( $(date +"%s") - $LST_MDF ))

if (( $DIFF > $TMAX ));then
	echo -e "$MAIL2" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
	rm -f $MARK
fi
}

# make 1-wire archives directory if not exist
if [ ! -d $DATA ];then
mkdir -p $DATA
chown -R www-data:www-data $DATA
fi
#
# get all devices in the group
FILES=`ls $W1DIR/ | grep '^10\|^28'`
# iterate through all the devices
for ID in $FILES
    do
    # get the 2 lines of the response from the device
      GETDATA=`cat $W1DIR/$ID/w1_slave`
      GETDATA1=`echo "$GETDATA" | grep crc`
      GETDATA2=`echo "$GETDATA" | grep t=`
      TEMP=`echo $GETDATA2 | sed -n 's/.*t=//;p'`
      #TEMPERATURE=`echo "scale=3;$TEMP/1000" | bc | sed 's/^\./0./'`
      #TEMPERATURE=`echo "scale=3;$TEMP/1000" | bc | awk '{printf "%f", $0}'`
    # get temperature human readable format - restore leading zero & handle negative values (work OK both folowed comands)
      #TEMPERATURE=`echo "scale=3;$TEMP/1000" | bc | sed -r 's/^(-?)\./\10./'`	# OK
      TEMPERATURE=` printf "%0.3f" $( echo 'scale=3; '$TEMP'/1000' | bc ) `	# OK
    # get device name
      NAME=`grep $ID $ASIGN | awk {'print $2'}`
    # get temperature
        # test if crc is 'YES' and temperature is not -62 or +85
        if [ `echo $GETDATA1 | sed 's/^.*\(...\)$/\1/'` == "YES" -a $TEMP != "-62" -a $TEMP != "85000"  ]
           then
               # crc is 'YES' and temperature is not -62 or +85 - so save result
               echo `date +"%H:%M:%S:%3N "; echo "temperatura: "$TEMP $TEMPERATURE$CLS` >> $DATA/$NAME
               #echo $(echo "scale=1;$TEMPERATURE/1" | bc ) "   :   " $ID > /var/www/files/data/TMPFS/temp.values
               #echo $(echo "scale=1;$TEMPERATURE/1" | bc ) "   :   " $ID
               echo "$ID : $(echo "scale=1;$TEMPERATURE/1" | bc )"$CLS
           else
               # there was an error (crc not 'yes' or invalid temperature)
               # try again after waiting 1 second
               sleep 1
               # get the 2 lines of the response from the device again
               GETDATA=`cat $W1DIR/$ID/w1_slave`
               GETDATA1=`echo "$GETDATA" | grep crc`
               GETDATA2=`echo "$GETDATA" | grep t=`
               # get the temperature from the new response
               TEMP=`echo $GETDATA2 | sed -n 's/.*t=//;p'`
                  if [ `echo $GETDATA1 | sed 's/^.*\(...\)$/\1/'` == "YES" -a $TEMP != "-62" -a $TEMP != "85000" ]
                      then
                      # save result if crc is 'YES' and temperature is not -62 or +85 - if not, just miss it and move on
                      echo `date +"%H:%M:%S:%3N "; echo $TEMPERATURE$CLS` >> $DATA/$ID
                  fi
               # this is a retry so log the failure - record date/time & device ID & NAME
               echo `date +"%H:%M:%S:%3N "`" - $ID -> $NAME" >> $DATA/err.log
###
               # warn with repeated mails (every 15 minutes) if a failure occurred.
#<<"COMMENT"
                  if [ ! -e $MARK ]
                  then
                     echo -e "$MAIL1" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
                     touch $MARK
<<"COMMENT"
                  else
                     LST_MDF=$(stat -c %Y ${MARK})
                     DIFF=$(( $(date +"%s") - $LST_MDF ))
                     if (( $DIFF > $TMAX ))
                     then
                        echo -e "$MAIL2" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
                        rm -f $MARK

                     fi
COMMENT
                  fi
#COMMENT
                  delay
           fi
    done > /var/www/files/data/TMPFS/temp.values

LST_MDF=$(stat -c %Y ${MARK})
DIFF=$(( $(date +"%s") - $LST_MDF ))
if (( $DIFF > $TMAX ));then
    echo -e "$MAIL2" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
    rm -f $MARK

#exit 0
