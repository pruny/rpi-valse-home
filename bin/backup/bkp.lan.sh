#!/bin/bash

DIR=/mnt/nas.rPi/bkp@rPi/
HOSTNAME=$(hostname)
NOW1=$(date '+%a %d %b %Y %H:%M:%S')
TOADDR1=ovidiu.constantin@gmx.com
TOADDR2=ovidiu.constantin@kantarmedia.com
echo "==================================================="
echo "$HOSTNAME >>>> $NOW1"
echo "Starting BACKUP process! Please wait..."
mount -a
OFILE="${DIR}backup_$(date +%Y%m%d_%H%M%S)"
OFILEFINAL=$OFILE.img
OFILEBKP="backup_$(date +%Y%m%d_%H%M%S)".img
sync; sync
service apache2 stop
service mysql stop
service cron stop
SDSIZE=`/sbin/blockdev --getsize64 /dev/mmcblk0`;
pv -tpreb /dev/mmcblk0 -s $SDSIZE | timeout 30m dd of=$OFILE bs=1M conv=sync,noerror iflag=fullblock
RESULT=$?
service apache2 start
service mysql start
service cron start
NOW2=$(date '+%a %d %b %Y %H:%M:%S')
if [ $RESULT = 0 ];
   then
# delete the oldest backup file in the folder
    file_count=$(ls -tr ${DIR} | wc -l)
    to_delete=$(ls -tr ${DIR} | head -n1)
    if [ "${file_count}" -gt "1" ];
       then
        rm ${DIR}${to_delete}
    fi
# all time remains the four last files      #rm -f $DIR/backup_*.img
      mv $OFILE $OFILEFINAL
      echo "BACKUP process COMPLETED. Backup file is saved in NAS: //NAS/rPi/bkp@rPi/$OFILEBKP"
      echo -e "$HOSTNAME SUCCESSFUL BACKUP @ $NOW2\n\nBackup file [ $OFILEBKP ] is saved in NAS" | mail -r "\"$HOSTNAME"\" -s "Backup OK" $TOADDR1 $TOADDR2
   else
      rm -f $OFILE
      echo "BACKUP process FAILED. Previous backup file untouched!"
      echo -e "$HOSTNAME UNSUCCESSFUL BACKUP @ $NOW2\n\nPrevious backup file untouched!" | mail -r "\"$HOSTNAME"\" -s "WARNING!! Backup failed." $TOADDR1 $TOADDR2
fi
echo "$HOSTNAME >>>> $NOW2"
echo "==================================================="
