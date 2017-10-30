#!/bin/bash

# location (my home)
LAT="44.4446359N"
LON="26.0926713E"

# calculating Civil Twilight based on location from LAT LON (amurg si zori de zi)
DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 45-46`
DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 47-48`
DAWNHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 30-31`
DAWNMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 32-33`

# calculating sunset/sunrise based on location from LAT LON (apusul si rasaritul) 
SUNRISEHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 30-31`
SUNRISEMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 32-33`
SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 45-46`
SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 47-48`

# calculating day
ieri=`date --date="yesterday" +"%d/%m/%Y"`
azi=`date --date="today" +"%d/%m/%Y"`	# sau asa: `date +"%d/%m/%Y"`
maine=`date --date="tomorrow" +"%d/%m/%Y"`

# path to log file
RAMDIR="/var/www/TMPFS"
LOGFILE="$RAMDIR/sunwait.log"

# path to app
gpio2="usr/local/bin/gpio2"

##########
# FUNCTION = preserve size of ram storage folder
##########
size ()
{
SIZE=`du -s $RAMDIR | cut -c 1-4`

if (( $SIZE >= 2999 ));then
	rm -f $LOGFILE
	echo -e "$HOSTNAME @  $NOW\n\n[ $LOGDFILE ]\nwas removed to preserve the size of RAM storage" | mail -r "\"$HOSTNAME"\" -s "WARNING!! Log files removed" $TOADDR1 $TOADDR2
fi
}

##########
# FUNCTION = switch betwen auto/manual
##########

auto ()
{
if [ -e /var/www/files/data/TMPFS/auto.stop ]	# stare "manual"
  then
	exit 0
fi
}

# Converting to seconds
ZORI=$((10#$DAWNHR * 3600 + 10#$DAWNMIN * 60))
RASARIT=$((10#$SUNRISEHR * 3600 + 10#$SUNRISEMIN * 60))
AMURG=$((10#$DUSKHR * 3600 + 10#$DUSKMIN * 60))
APUS=$((10#$SUNSETHR * 3600 + 10#$SUNSETMIN * 60))

# Converting "now" to seconds
ora=`date +'%H'`
min=`date +'%M'`
data=`date +'%d/%m/%Y %H:%M'`
acum=$(( 10#$ora * 3600 + 10#$min * 60 ))

#----------------

<<"COMMENT"
multiline-comment
COMMENT

#----------------

size	# preserve size of ram storage folder

##########
# MAIN = lumina curte
##########

auto	# mod "auto" dezafectat

if (( "$acum" > "($ZORI - 1)" ));then
  if (( "$acum" < "($AMURG + 1)" ));then
    gpio2 write 29 1	# perioada "zori de zi ~ amurg" - comuta in OFF ziua...
  else
    gpio2 write 29 0	# final "amurg" - comuta in ON seara...
  fi
 else
 gpio2 write 29 0	# premergator "zori de zi" - mentine in ON...
fi
