#!/bin/sh -e

# this script send a sms after service is started

TOPHONE="0733331236"
SERVICE="gammu-smsd"
MSG="WARNING!\rGPRS link is stopped\rSMS commands avalaible"

if [ "/bin/systemctl is-active $SERVICE" != "active" ]
  then
    /usr/local/bin/sms $TOPHONE "$MSG"
fi
wait
> /home/pi/data/shared/gsm/sms/last.log

