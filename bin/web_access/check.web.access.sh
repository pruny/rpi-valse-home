#!/bin/bash

# Reboots the machine on which it resides if more then a given time interval has passed since this script (itself) was last touched.

# Local parameters:
    HOSTNAME=`/bin/hostname`
    NOW=$(date '+%a %d %b %Y %H:%M:%S')
    TOADDR1="ovidiu.constantin@kantarmedia.com"
    TOADDR2="ovidiu.constantin@gmx.com"

# How many minutes to allow to pass before rebooting the machine
    TMAX_touch=360 # 6 hours

# How many minutes of warning (broadcast to logged in users) before actual reboot?
    WARN_1hour=$(( $TMAX_touch - 60 )) # 5 hours
    DEL_REBOOT=1 # 3 minute

# Obtain the time when this script was last touched
    TLAST_touch=`stat -c %Y $0`

# Calculate the difference in seconds between the current time and the time of the last touch
    DIFF_sec=$(( $(date +"%s") - $TLAST_touch ))

# Calculate the difference in minutes
    DIFF_min=$(( $DIFF_sec / 60 ))

# Display the elapsed time
    echo "Time elapsed since the last touch of script [${0##*/}] : $DIFF_min min ($DIFF_sec sec)."

# If more than the given number of minutes have elapsed since the last access, first mail warnings and then reboot the machine
# WARNINGS: [5h; 5h 15 min; 5h 30 min] - [5h 45 min] - [6h]

    # 6 hours (TMAX_touch)
    # If more than the given number of minutes have elapsed since the last login, then reboot the machine
    # Give logged in users 3 minutes to save their stuff (3 minutes warning before the actual reboot)
    # Touch this script file
    if (( $DIFF_min >= $TMAX_touch ));
      then
        touch $0
        echo -e "$HOSTNAME @  $NOW\n\nTime elapsed since the last access via INTERNET of [${0##*/}] is $DIFF_min minutes ( exceed $(( $TMAX_touch / 60 )) hours)\n\nJUST NOW >> REBOOT! REBOOT! REBOOT!" | mail -r "\"$HOSTNAME"\" -s "WARNING!! NO WEB ACCESS" $TOADDR1 $TOADDR2
        #/root/files/web_access/reset.sh
        #/sbin/shutdown -r +$DEL_REBOOT
      else
	# 5h 45 min (WARN_1hour +45 minutes)
        if (( $DIFF_min >= $(( $WARN_1hour + 45 ))));
          then
	        echo -e "$HOSTNAME @  $NOW\n\nTime elapsed since the last access via INTERNET of [${0##*/}] is $DIFF_min minutes ( exceed $(( WARN_1hour / 60 )) hours & 45 minutes)\n\nREBOOT in 15 minutes!" | mail -r "\"$HOSTNAME"\" -s "WARNING!! NO WEB ACCESS" $TOADDR1 $TOADDR2
          else
            # 5 hours (WARN_1hour)
            if (( $DIFF_min >= $WARN_1hour ));
              then
                echo -e "$HOSTNAME @  $NOW\n\nTime elapsed since the last access via INTERNET of [${0##*/}] is $DIFF_min minutes ( exceed $(( $DIFF_min / 60 )) hours)\n\nThe system will be rebooted!" | mail -r "\"$HOSTNAME"\" -s "WARNING!! NO WEB ACCESS" $TOADDR1 $TOADDR2
              else
                exit
            fi
        fi
    fi
