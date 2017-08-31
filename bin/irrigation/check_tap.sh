#!/bin/bash

TAP="25"
FILE="/var/www/TMPFS/tap.open"
TMAX=3600 # 1 hour of irrigation

##########
# FUNCTION = switch betwen auto/manual
##########

manual ()
{
if [ ! -e /var/www/TMPFS/auto.stop ]	# "manual" mode
  then
	exit 0
fi
}


if [ -e $FILE ]
  then
      echo "irigarea este pornita"
      LST_MDF=$(stat -c %Y ${FILE})
      echo $LST_MDF
      DIFF=$(( $(date +"%s") - $LST_MDF ))
      echo $DIFF
      if (( $DIFF >= $TMAX ))
        then
            #manual # irrigation only in "manual" mode
            /usr/local/bin/gpio2 write $TAP 1
            echo "irigarea a fost oprita datorita depasirii duratei"
            rm -f $FILE
      fi
fi
