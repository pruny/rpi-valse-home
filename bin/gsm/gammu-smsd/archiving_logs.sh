#!/bin/bash

LOG="/home/pi/data/shared/gsm/gammu.log"
DATA="/home/pi/data/shared/gsm/logs_archive"

yyyy=$(date +\%Y)
mm=$(date +\%m)
dd=$(date +\%d)

### make gsm archives directory if not exist
if [ ! -d $DATA ];then
mkdir -p $DATA
fi

### preserve size of log data to 1 MB
size ()
{
SIZE=`ls -l $LOG | awk {'print $5'}`

if (( $SIZE >= 999999 ));then
	cp $LOG $DATA/${yyyy}/${mm}/${dd}
	rm -f $LOG
	//echo -e "$HOSTNAME @  $NOW\n\n[ $LOGDIR ]\nwas removed to preserve the size of RAM storage" | mail -r "\"$HOSTNAME"\" -s "WARNING!! Log files removed" $TOADDR1
fi
}

size
