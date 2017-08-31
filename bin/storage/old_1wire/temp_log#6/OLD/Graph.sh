#!/bin/bash

INCOLOUR="#FF0000"
OUTCOLOUR="#0000FF"
TRENDCOLOUR="#000000"

############################
#
# Parameters to adjust
#
############################

# location (my home) valse
LAT="45.1722867N"
LON="24.7955867E"

# graph folder (volatile, in RAM)
DIR="/var/www/files/data/TMPFS/PNG/"
mkdir -p $DIR

# sensor labels
G1="ROOM"
G2="HALL"
G3="OUTSIDE"
G4="BASEMENT"
G5="COLD_WATER"
G6="WARM_WATER"

# colored lines graph
L1="#00FF00"
L2="#00C957"
L3="#0000FF"
L4="#FFA500"
L5="#00EEEE"
L6="#FF0000"
LX="#000000"

# colored areas graph
A1="#98FF98"
A2="#A0D2B6"
A3="#B8B8FF"
A4="#FFF4DE"
A5="#C7EEEE"
A6="#E8ADAA"
AX="#B6B6B4"


# rrdgraph options
Hall="-A --y-grid 1:5 --right-axis 1:0 --start -3h --full-size-mode -w 955 -h 350"
Dall="-A --y-grid 1:5 --right-axis 1:0 --start -30h --full-size-mode -w 955 -h 350"
Wall="-A --y-grid 1:5 --right-axis 1:0 --start -9d --full-size-mode -w 955 -h 350"
Mall="-A --y-grid 1:5 --right-axis 1:0 --start -35d --full-size-mode -w 955 -h 350"
Yall="-A --y-grid 1:5 --right-axis 1:0 --start -400d --full-size-mode -w 955 -h 350"
H="--alt-autoscale --y-grid 0.1:10 --start -3h --full-size-mode --width 315 --height 150"
D="--alt-autoscale --y-grid 0.1:10 --start -30h --full-size-mode --width 315 --height 150"
W="--alt-autoscale --y-grid 0.1:10 --start -9d --full-size-mode --width 315 --height 150"
M="--alt-autoscale --y-grid 0.1:10 --start -35d --full-size-mode --width 315 --height 150"
Y="--alt-autoscale --y-grid 0.1:10 --start -400d --full-size-mode --width 315 --height 150"

# Calculating Civil Twilight based on location from LAT LON (amurg si zori de zi)
DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 46-47`
DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 48-49`
DAWNHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 30-31`
DAWNMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 32-33`

# Calculating sunset/sunrise based on location from LAT LON (apusul si rasaritul) 
SUNRISEHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 30-31`
SUNRISEMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 32-33`
SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 46-47`
SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 48-49`

# Converting to seconds
SUNR=$(($SUNRISEHR * 3600 + $SUNRISEMIN * 60))
SUNS=$(($SUNSETHR * 3600 + $SUNSETMIN * 60))
DUSK=$(($DUSKHR * 3600 + $DUSKMIN * 60))
DAWN=$(($DAWNHR * 3600 + $DAWNMIN * 60))

############################
#
# plot graphs for 6 sensors
# graph set up is optimal
# for 960 x 540 display
# aka Samsung Galaxy S4 mini
#
############################

############################
#
# Creating graphs
#
############################

#hour=>3h/average=1m

rrdtool graph ${DIR}T1h.png \
${Hall} \
--title "IN CASA" \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,60,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T1temp$A1:"   "${G1}"   " \
LINE:T1temp$L1 \
GPRINT:T1temp:MIN:"\t\t\t\t\tmin\: %2.2lf °C\t" \
GPRINT:T1temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T1temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T1temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T2h.png \
${Hall} \
--title "HOL" \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,60,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T2temp$A2:"   "${G2}"   " \
LINE:T2temp$L2 \
GPRINT:T2temp:MIN:"\t\t\t\t\tmin\: %2.2lf °C\t" \
GPRINT:T2temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T2temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T2temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T3h.png \
${Hall} \
--title "AFARA" \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,60,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T3temp$A3:"   "${G3} \
LINE:T3temp$L3 \
GPRINT:T3temp:MIN:"\t\t\t\t\tmin\: %2.2lf °C\t" \
GPRINT:T3temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T3temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T3temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}T4h.png \
${Hall} \
--title "BECI" \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,60,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T4temp$A4:"  "${G4} \
LINE:T4temp$L4 \
GPRINT:T4temp:MIN:"\t\t\t\t\tmin\: %2.2lf °C\t" \
GPRINT:T4temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T4temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T4temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:10#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}T5h.png \
${Hall} \
--title "APA RECE" \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,60,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T5temp$A5:"   "${G5}"   " \
LINE:T5temp$L5 \
GPRINT:T5temp:MIN:"\t\t\t\tmin\: %2.2lf °C\t" \
GPRINT:T5temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T5temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T5temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6h.png \
${Hall} \
--title "APA CALDA" \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,60,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T6temp$A6:"   "${G6}"   " \
LINE:T6temp$L6 \
GPRINT:T6temp:MIN:"\t\t\t\tmin\: %2.2lf °C\t" \
GPRINT:T6temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T6temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T6temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

#day=>30h/average=5m

rrdtool graph ${DIR}T1d.png \
${Dall} \
--title "IN CASA" \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,300,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T1temp$A1:"   "${G1}"  @ 5 min AVERAGE   " \
LINE:T1temp$L1 \
GPRINT:T1temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T1temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T1temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T1temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T2d.png \
${Dall} \
--title "HOL" \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,300,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T2temp$A2:"   "${G2}"  @ 5 min AVERAGE   " \
LINE:T2temp$L2 \
GPRINT:T2temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T2temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T2temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T2temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T3d.png \
${Dall} \
--title "AFARA" \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,300,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T3temp$A3:"   "${G3}"  @ 5 min AVERAGE" \
LINE:T3temp$L3 \
GPRINT:T3temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T3temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T3temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T3temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}T4d.png \
${Dall} \
--title "BECI" \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,300,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T4temp$A4:"   "${G4}"  @ 5 min AVERAGE     " \
LINE:T4temp$L4 \
GPRINT:T4temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T4temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T4temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T4temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:10#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"
 
rrdtool graph ${DIR}T5d.png \
${Dall} \
--title "APA RECE" \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,300,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T5temp$A5:"   "${G5}"  @ 5 min AVERAGE   " \
LINE:T5temp$L5 \
GPRINT:T5temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T5temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T5temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T5temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6d.png \
${Dall} \
--title "APA CALDA" \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,300,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T6temp$A6:"   "${G6}"  @ 5 min AVERAGE   " \
LINE:T6temp$L6 \
GPRINT:T6temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T6temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T6temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T6temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

#week=>9d/average=1h

rrdtool graph ${DIR}T1w.png \
${Wall} \
--title "IN CASA" \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,3600,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T1temp$A1:"   "${G1}" @ Hourly AVERAGE   " \
LINE:T1temp$L1 \
GPRINT:T1temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T1temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T1temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T1temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T2w.png \
${Wall} \
--title "HOL" \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,3600,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T2temp$A2:"   "${G2}" @ Hourly AVERAGE   " \
LINE:T2temp$L2 \
GPRINT:T2temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T2temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T2temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T2temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T3w.png \
${Wall} \
--title "AFARA" \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,3600,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T3temp$A3:"   "${G3}" @ Hourly AVERAGE" \
LINE:T3temp$L3 \
GPRINT:T3temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T3temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T3temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T3temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing" 

rrdtool graph ${DIR}T4w.png \
${Wall} \
--title "BECI" \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,3600,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T4temp$A4:"   "${G4}" @ Hourly AVERAGE     " \
LINE:T4temp$L4 \
GPRINT:T4temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T4temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T4temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T4temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:10#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}T5w.png \
${Wall} \
--title "APA RECE" \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,3600,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T5temp$A5:"   "${G5}" @ Hourly AVERAGE   " \
LINE:T5temp$L5 \
GPRINT:T5temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T5temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T5temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T5temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6w.png \
${Wall} \
--title "APA CALDA" \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,3600,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:dusktilldawn#A6A6A6 \
AREA:dawntilldusk#A6A6A6 \
AREA:T6temp$A6:"   "${G6}" @ Hourly AVERAGE   " \
LINE:T6temp$L6 \
GPRINT:T6temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T6temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T6temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T6temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

#month=>35d/average=24h

rrdtool graph ${DIR}ALLm.png \
${Mall} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T1trend=T1temp,86400,TREND \
CDEF:T2trend=T2temp,86400,TREND \
CDEF:T3trend=T3temp,86400,TREND \
CDEF:T4trend=T4temp,86400,TREND \
CDEF:T5trend=T5temp,86400,TREND \
CDEF:T6trend=T6temp,86400,TREND \
AREA:T1temp$A1:${G1} \
LINE:T1temp$L1 \
AREA:T2temp$A2:${G2} \
LINE:T2temp$L2 \
AREA:T3temp$A3:${G3} \
LINE:T3temp$L3 \
AREA:T4temp$A4:${G4} \
LINE:T4temp$L4 \
AREA:T5temp$A5:${G5} \
LINE:T5temp$L5 \
AREA:T5temp$A6:${G6} \
LINE:T6temp$L6 \
GPRINT:T1temp:AVERAGE:"Daily AVERAGE ${G1} %2.2lf °C" \
GPRINT:T2temp:AVERAGE:"Daily AVERAGE ${G2} %2.2lf °C" \
GPRINT:T3temp:AVERAGE:"Daily AVERAGE ${G3} %2.2lf °C" \
GPRINT:T4temp:AVERAGE:"Daily AVERAGE ${G4} %2.2lf °C" \
GPRINT:T5temp:AVERAGE:"Daily AVERAGE ${G5} %2.2lf °C" \
GPRINT:T6temp:AVERAGE:"Daily AVERAGE ${G6} %2.2lf °C"

rrdtool graph ${DIR}T1m.png \
${Mall} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,86400,TREND \
AREA:T1temp$A1:${G1} \
LINE:T1temp$L1 \
GPRINT:T1temp:AVERAGE:"Daily AVERAGE ${G1} %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T2m.png \
${Mall} \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,86400,TREND \
AREA:T2temp$A2:${G2} \
LINE:T2temp$L2 \
GPRINT:T2temp:AVERAGE:"Daily AVERAGE ${G2} %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T3m.png \
${Mall} \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,86400,TREND \
AREA:T3temp$A3:${G3} \
LINE:T3temp$L3 \
GPRINT:T3temp:AVERAGE:"Daily AVERAGE ${G3} %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing" 

rrdtool graph ${DIR}T4m.png \
${Mall} \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,86400,TREND \
AREA:T4temp$A4:${G4} \
LINE:T4temp$L4 \
GPRINT:T4temp:AVERAGE:"Daily AVERAGE ${G4} %2.2lf °C\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:10#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}T5m.png \
${Mall} \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,86400,TREND \
AREA:T5temp$A5:${G5} \
LINE:T5temp$L5 \
GPRINT:T5temp:AVERAGE:"Daily AVERAGE ${G5} %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6m.png \
${Mall} \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,86400,TREND \
AREA:T6temp$A6:${G6} \
LINE:T6temp$L6 \
GPRINT:T6temp:AVERAGE:"Daily AVERAGE ${G6} %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

#year=>400d/average=24h

rrdtool graph ${DIR}ALLy.png \
${Yall} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T1trend=T1temp,86400,TREND \
CDEF:T2trend=T2temp,86400,TREND \
CDEF:T3trend=T3temp,86400,TREND \
CDEF:T4trend=T4temp,86400,TREND \
CDEF:T5trend=T5temp,86400,TREND \
CDEF:T6trend=T6temp,86400,TREND \
AREA:T1temp$A1:${G1} \
LINE:T1temp$L1 \
AREA:T2temp$A2:$${G2} \
LINE:T2temp$L2 \
AREA:T3temp$A3:${G3} \
LINE:T3temp$L3 \
AREA:T4temp$A4:${G4} \
LINE:T4temp$L4 \
AREA:T5temp$A5:${G5} \
LINE:T5temp$L5 \
AREA:T5temp$A6:${G6} \
LINE:T6temp$L6 \
GPRINT:T1temp:AVERAGE:"Daily AVERAGE ${G1} %2.2lf °C" \
GPRINT:T2temp:AVERAGE:"Daily AVERAGE $${G2}%2.2lf °C" \
GPRINT:T3temp:AVERAGE:"Daily AVERAGE ${G3} %2.2lf °C" \
GPRINT:T4temp:AVERAGE:"Daily AVERAGE ${G4} %2.2lf °C" \
GPRINT:T5temp:AVERAGE:"Daily AVERAGE ${G5} %2.2lf °C" \
GPRINT:T6temp:AVERAGE:"Daily AVERAGE ${G6} %2.2lf °C"

rrdtool graph ${DIR}T1y.png \
${Yall} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,86400,TREND \
AREA:T1temp$A1:${G1} \
LINE:T1temp$L1 \
GPRINT:T1temp:AVERAGE:"Daily AVERAGE ${G1} %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T2y.png \
${Yall} \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,86400,TREND \
AREA:T2temp$A2:${G2} \
LINE:T2temp$L2 \
GPRINT:T2temp:AVERAGE:"Daily AVERAGE ${G2} %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T3y.png \
${Yall} \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,86400,TREND \
AREA:T3temp$A3:${G3} \
LINE:T3temp$L3 \
GPRINT:T3temp:AVERAGE:"Daily AVERAGE ${G3} %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing" 

rrdtool graph ${DIR}T4y.png \
${Yall} \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,86400,TREND \
AREA:T4temp$A4:${G4} \
LINE:T4temp$L4 \
GPRINT:T4temp:AVERAGE:"Daily AVERAGE ${G4} %2.2lf °C\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:10#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"


rrdtool graph ${DIR}T5y.png \
${Yall} \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,86400,TREND \
AREA:T5temp$A5:${G5} \
LINE:T5temp$L5 \
GPRINT:T5temp:AVERAGE:"Daily AVERAGE ${G5} %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6y.png \
${Yall} \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,86400,TREND \
AREA:T6temp$A6:${G6} \
LINE:T6temp$L6 \
GPRINT:T6temp:AVERAGE:"Daily AVERAGE ${G6} %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

