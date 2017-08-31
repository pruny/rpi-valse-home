#!/bin/bash

### a script to read and save temperature readings from all
### 1-wire temperature sensors familly from Maxim
### ex. Dallas Semiconductors aka DS18*2* temperature sensors 
### save temperature -> °C & time -> hh:mm:ss @ msec :-)
### warn with repeated mails (every 15 minutes) if a failure occurred

W1DIR="/sys/bus/w1/devices/w1_bus_master1"
RAMDIR="/var/www/TMPFS"
LOGDIR="$RAMDIR/1wire/temp"
yyyy=$(date +\%Y)
mm=$(date +\%m)
dd=$(date +\%d)
DATA=$LOGDIR/${yyyy}/${mm}/${dd}
CLS=$'\xc2\xb0'C
ASIGN="/root/bin/1wire/ds18b20/temp_log#6/sensors.config"
HOSTNAME=$(/bin/hostname)
NOW=$(date '+%a %d %b %Y %H:%M:%S')
TOADDR1="ovidiu.constantin@gmx.com"
MARK="/var/www/files/data/TMPFS/sensor.broken"
TMAX=900 ### 15 min beetwin the warning mails
MAIL1="$HOSTNAME @  $NOW\n\nSistemul nu poate inregistra corect temperaturile!\n\nConexiune pierduta cu senzorul de temperatura: "
MAIL2="$HOSTNAME @  $NOW\n\nSistemul nu poate inregistra corect temperaturile!\n\nConexiune nerestabilita inca cu senzor de temperatura:"

### preserve size of ram storage folder to 3 MB
size ()
{
SIZE=`du -s $RAMDIR | cut -c 1-4`

if (( $SIZE >= 2999 ));then
	#cp $LOGDIR /home/pi/data/shared/1wire/temp/${yyyy}/${mm}/${dd}
	rm -fr $LOGDIR/{*,.*}
	echo -e "$HOSTNAME @  $NOW\n\n[ $LOGDIR ]\nwas removed to preserve the size of RAM storage" | mail -r "\"$HOSTNAME"\" -s "WARNING!! Log files removed" $TOADDR1
fi
}

size

### mail delay function
delay ()
{
LST_MDF=$(stat -c %Y ${MARK})
DIFF=$(( $(date +"%s") - $LST_MDF ))

if (( $DIFF > $TMAX ));then
	echo -e "$MAIL2" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
	rm -f $MARK
fi
}

### make 1-wire archives directory if not exist
if [ ! -d $DATA ];then
mkdir -p $DATA
chown -R www-data:www-data $DATA
fi

### check if device directory exist
#if [ !-d $FILES ]; then echo -e "$MAIL1" | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1 ; fi

### get all devices in the group: DS18S20 or DS18B20 or DS1822
FILES=`ls $W1DIR/ | grep '^10\|^28\|^22'`

### iterate through all the devices
for ID in $FILES
    do

      ### get the 2 lines of the response from the device
      GETDATA=`cat $W1DIR/$ID/w1_slave`
      GETDATA1=`echo "$GETDATA" | grep crc`
      GETDATA2=`echo "$GETDATA" | grep t=`
      TEMP=`echo $GETDATA2 | sed -n 's/.*t=//;p'`

      ### get temperature human readable format - restore leading zero & handle negative values
      TEMPERAT_3=`printf "%0.3f" $( echo 'scale=3; '$TEMP'/1000' | bc )`	# restore leading zero & 3 decimal points
      TEMPERAT_1=`printf "%0.1f" $( echo 'scale=1; '$TEMP'/1000' | bc )`	# restore leading zero & 1 decimal points

      ### get device name
      LABEL=`grep $ID $ASIGN | awk -F',' {'print $4'}`
      NAME=`grep $ID $ASIGN | awk -F',' {'print $4'} | xargs`

        ### get temperature

        ### test if crc is 'YES' and temperature is not +85
        if [ `echo $GETDATA1 | sed 's/^.*\(...\)$/\1/'` == "YES" -a $TEMP != "85000" ]
           then
               ### crc is 'YES' and temperature is not +85 - so save result
               echo `date +"%H:%M:%S:%3N"; echo " ; temperatura ; "$TEMPERAT_3$CLS` >> $DATA/$NAME	# save in archive file
               echo "$ID ; $LABEL ; $TEMPERAT_1$CLS"				# write line in temp.val w one decimal point
               rm -f $MARK
           else
               ### there was an error (crc not 'yes' or invalid temperature) so try again after waiting 1 second
               sleep 1

               ### get the 2 lines of the response from the device again
               GETDATA=`cat $W1DIR/$ID/w1_slave`
               GETDATA1=`echo "$GETDATA" | grep crc`
               GETDATA2=`echo "$GETDATA" | grep t=`

               ### get the temperature from the new response
               TEMP=`echo $GETDATA2 | sed -n 's/.*t=//;p'`
                  ### test if crc is 'YES' and temperature is not +85
                  if [ `echo $GETDATA1 | sed 's/^.*\(...\)$/\1/'` == "YES" -a $TEMP != "85000" ]
                     then
                         ### save result if crc is 'YES' and temperature is not +85 - if not, just miss it and move on
                         echo `date +"%H:%M:%S:%3N"; echo  " ; temperatura ; "$TEMPERATURE$CLS" >> sensor error"` >> $DATA/$NAME
                  fi

               ### this is a retry so log the failure - record date/time & device ID & NAME
               echo `date +"%H:%M:%S:%3N"`" - $ID -> $NAME: $TEMPERATURE$CLS" >> $DATA/err.log

               ### warn with repeated mails (every 15 minutes) if failure still happen
                  if [ ! -e $MARK ];then
                     echo -e "$MAIL1" $NAME | mail -r "\"$HOSTNAME"\" -s "TEMP-SENSOR BROKEN!" $TOADDR1
                     touch $MARK
                  fi

           fi

    done > /var/www/files/data/TMPFS/temp.val
                  delay
#exit 0
