#!/bin/bash

# chech last day of month 55 23 28-31 * *
if [ "$(date -d 'today 12:00' +\%m)" != "$(date -d 'tomorrow 12:00' +\%m)" ]

# check last speciffic (ie. wednesday)day of week in the month 55 23 * * 3
#if [ "$(date -d 'today 12:00' +\%m)" != "$(date -d 'now + 7 days 12:00' +\%m)" ]

#then cp /root/files/backup/log_backup /mnt/nas.rPi/files@rPi/last_month_log_backup
then cp /root/files/backup/log_backup /media/usb.flash/files@rPi/last_month_log_backup
fi
