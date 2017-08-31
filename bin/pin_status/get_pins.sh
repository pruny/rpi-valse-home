#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------
# 11 input pins: 1, 2, 3, (12), (13), (14)(default SPI pins), *[5]*, *[6]*, [11][gsm_status], {7}{1wire}, {26}{free!!!}
#  - board input pins: 12, 13, 15, (19), (21), (23), *[18]*, *[22]*, [26], {7},  {32}
#  - pins mark with * (18 & 22) have MIXT function: input (most of the time) & output (for starting and restarting the gsm modem)
#  - all input pins have internal pullup, except MIXT pins that have 10Kohms external resistors pullup        
#-------------------------------------------------------------------------------------------------------------------------------------
#  3 emonpi pins: 4, 10, 0 (lcd_scroll_button, atmega_reset, shutdown_pi)
#  - board input pins: 16, 24, 11
#  - no action need @ boot for this pins
#-------------------------------------------------------------------------------------------------------------------------------------
# 11 output pins: 21, 22, 23, 24, 25, 27, 28, 29, {10}{rst_arduino}, [5][power_gsm_modem], [6][rst_gsm_modem]
#  - board output pins: 29, 31, 33, 35, 37, 36, 38, 40, {24}, *[18]*, *[22]*
#  - special output pins  {24}, *[18]*, *[22]* are declared & used in specific scripts
#-------------------------------------------------------------------------------------------------------------------------------------

####################
###   SETUP     ####
####################

BAKDIR="/home/pi/data/shared/pin_status"

if [ ! -d $BAKDIR ];then
  mkdir -p $BAKDIR
fi
chown -R www-data:www-data $BAKDIR	# permit filing states "buttons" (aka gpio) from web interface


input="1 2 3 12 13 14 5 6 11 7 26"
pullup="1 2 3 12 13 14 11 7 26"
output="21 22 23 24 25 27 28 29"


####################
###  FUNCTIONS   ###
####################

mode()					# run @ boot: get mode function of gpio & record status ( in file home/pi/data/shared/pin_status/gpio.startup )
{

for i in $input
do
  /usr/bin/gpio mode $i in
  #/usr/bin/gpio mode $i up
  for j in $pullup			# internal pullup - gpio 5 and 6 have external pullup
  do
    /usr/bin/gpio mode $j up
  done
  echo -n $(date +\%s\%3N) $(date +%d.%m.%Y) $(date +"%H:%M:%S:%3N")" " && echo -n $i" "
  /usr/bin/gpio read $i
done > $BAKDIR/gpio.startup

for k in $output
do
  /usr/bin/gpio mode $k out
  echo -n $(date +\%s\%3N) $(date +%d.%m.%Y) $(date +"%H:%M:%S:%3N")" " && echo -n $k" "
  /usr/bin/gpio read $k
done >> $BAKDIR/gpio.startup

}

status()			#run @ boot : set gpio output pins with last known status ( from /home/pi/data/shared/pin_status/gpio.status )
{

while read line;
do
  gpio=$(echo $line | awk '{print $4}')
  state=$(echo $line | awk '{print $5}')
  echo $gpio $state
  /usr/local/bin/gpio2 write $gpio $state
done < $BAKDIR/gpio.last

}


####################
###     MAIN     ###
####################

mode

status