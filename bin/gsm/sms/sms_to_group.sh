#!/bin/bash

# =========================================================================================
# >>>  Modify config files to set receiver(s) number(s) - TOPHONE & message body - MSG  <<<
# =========================================================================================

HOSTNAME=`/bin/hostname`
NOW=$(date '+%a %d %b %Y %H:%M:%S')

# get all numbers in the group
NR="/home/rpi/bin/gsm/sms/conf/nr.config"
#TOPHONE=$(egrep "^" $NR | grep -c "#" | cut -d';' --complement -s -f1 )
TOPHONE=$(grep -v "#" $NR | awk {'print $3'})

# text message
TXT="/home/rpi/bin/gsm/sms/conf/txt.config"
#MSG=$(egrep "^TEXT" $TXT | cut -d';' --complement -s -f1 )
MSG=$(grep -v "#" $TXT | awk {'print $1'})

echo $'\n... please wait until the job is done!'

# loop through all receivers and send text message
for i in $TOPHONE
	do
	#/usr/local/bin/sms $i "$MSG - $HOSTNAME $NOW"
	/usr/local/bin/sms $i "$MSG"
	wait
	done > /home/pi/data/shared/gsm/sms/last.log

# archive logs
cat /home/pi/data/shared/gsm/sms/last.log >> /home/pi/data/shared/gsm/sms/ALL.LOG

# check if job is completely executed (long line split by \)
grep -q "ERROR" /home/pi/data/shared/gsm/sms/last.log \
&& echo -e "\n>>> Job failed!\n... read log for details!\n" \
|| echo -e "\n>>> SMS was send to all recipients\n"
