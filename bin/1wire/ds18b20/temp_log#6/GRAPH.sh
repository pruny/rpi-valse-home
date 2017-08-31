#!/bin/bash

# use locale environment to make the graphs
export LC_ALL='ro_RO.UTF-8'

# location (my home) valse
LAT="45.1722867N"
LON="24.7955867E"

<<"COMMENT"
	NIGHT have four phases:
 	twilight1 - sunset to dusk	>> TWL1
 	darkness1 - dusk to midnight	>> DRK1
 	darkness2 - midnight to dawn	>> DRK2
 	twilight2 - dawn to sunrise	>> TLW2
COMMENT

# Calculating Civil Twilight based on location from LAT LON (amurg si zori de zi tinand cont de ora de vara EEST:UTC+3 sau de iarna EET:UTC+2)
DAWNHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 30-31`
DAWNMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 32-33`
DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 48-49; else cut -c 46-47; fi`
DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 50-51; else cut -c 48-49; fi`

#==== winter time ====
#DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 45-46`
#DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 47-48`

#==== summer time ====
#DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 46-47`
#DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 48-49`

# Calculating sunset/sunrise based on location from LAT LON (apusul si rasaritul tinand cont de ora de vara EEST:UTC+3 sau de iarna EET:UTC+2) 
SUNRISEHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 30-31`
SUNRISEMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 32-33`
SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 48-49; else cut -c 46-47; fi`
SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 50-51; else cut -c 48-49; fi`

#==== winter time ====
#SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 45-46`
#SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 47-48`

#==== summer time ====
#SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 46-47`
#SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 48-49`

# Converting to seconds (format text as decimal numbers & calculate...)
SUNR=$((10#$SUNRISEHR * 3600 + 10#$SUNRISEMIN * 60))
SUNS=$((10#$SUNSETHR * 3600 + 10#$SUNSETMIN * 60))
DUSK=$((10#$DUSKHR * 3600 + 10#$DUSKMIN * 60))
DAWN=$((10#$DAWNHR * 3600 + 10#$DAWNMIN * 60))

INCOLOUR="#FF0000"
OUTCOLOUR="#0000FF"
TRENDCOLOUR="#000000"

############################
#
# Parameters to adjust
#
############################

# RRD-DB path (in rw partition)
RRD="/home/pi/data/shared/temp/TH.rrd"

# graph folder (volatile, in RAM - sometime is corrupted so delete first and create after that)
DIR="/var/www/TMPFS/PNG/temp/"
rm -rf $DIR
mkdir -p $DIR

# sensor labels
G1="ROOM"
G2="HALL"
G3="OUTSIDE"
G4="BASEMENT"
G5="COLD_WATER"
G6="WARM_WATER"

# colored graph lines
L1="#FF3300"
L2="#00C957"
L3="#0000FF"
L4="#00FF00"
L5="#00EEEE"
L6="#FF0000"
LX="#000000"

# colored graph areas
A1="#FFF4DE"
A2="#A0D2B6"
A3="#B8B8FF"
A4="#98FF98"
A5="#C7EEEE"
A6="#E8ADAA"
AX="#B6B6B4"

# colored night areas
N1="#F2F2F2"	# verrylightgray
N2="#E0E0E0"	# lightgray
N3="#A6A6A6"	# gray
N4="#4D4D4D"	# darkgray

TWLC1=$N1
TWLC2=$N1
DRKC1=$N2
DRKC2=$N2

#----------------

<<"COMMENT"
multiline-comment
COMMENT

#----------------

# rrdgraph options
H="-A -y 0.1:10 -s -3h -D -E -w 315 -h 150"
D="-A -y 0.1:10 -s -30h -D -E -w 315 -h 150"
W="-A -y 0.1:10 -s -9d -D -E -w 315 -h 150"
M="-A -y 0.1:10 -s -35d -D -E -w 315 -h 150"
Y="-A -y 0.1:10 -s -400d -D -E -w 315 -h 350"
Hall="-A -y 0.1:10 --right-axis 1:0 -s -3h -D -E -w 955 -h 350"
Dall="-A -y 1:5 --right-axis 1:0 -s -30h -D -E -w 955 -h 350"
Wall="-A -y 1:5 --right-axis 1:0 -s -9d -D -E -w 955 -h 350"
Mall="-A -y 1:5 --right-axis 1:0 -s -35d -D -E -w 955 -h 350"
Yall="-A -y 1:5 --right-axis 1:0 -s -400d -D -E -w 955 -h 350"

<<"COMMENT"
H="--alt-autoscale --y-grid 0.1:10 --start -3h --full-size-mode --width 315 --height 150"
D="--alt-autoscale --y-grid 0.1:10 --start -30h --full-size-mode --width 315 --height 150"
W="--alt-autoscale --y-grid 0.1:10 --start -9d --full-size-mode --width 315 --height 150"
M="--alt-autoscale --y-grid 0.1:10 --start -35d --full-size-mode --width 315 --height 150"
Y="--alt-autoscale --y-grid 0.1:10 --start -400d --full-size-mode --width 315 --height 150"
Hall="-A --y-grid 1:5 --right-axis 1:0 --slope-mode --start -3h --full-size-mode -w 955 -h 350"
Dall="-A --y-grid 1:5 --right-axis 1:0 --slope-mode --start -30h --full-size-mode -w 955 -h 350"
Wall="-A --y-grid 1:5 --right-axis 1:0 --slope-mode --start -9d --full-size-mode -w 955 -h 350"
Mall="-A --y-grid 1:5 --right-axis 1:0 --slope-mode --start -35d --full-size-mode -w 955 -h 350"
Yall="-A --y-grid 1:5 --right-axis 1:0 --slope-mode --start -400d --full-size-mode -w 955 -h 350"
COMMENT

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
--units-exponent=0 \
--title "IN CASA" \
DEF:T1temp=$RRD:T1:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T1temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "HOL" \
DEF:T2temp=$RRD:T2:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T2temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "AFARA" \
DEF:T3temp=$RRD:T3:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T3temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "BECI" \
DEF:T4temp=$RRD:T4:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T4temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T4temp$A4:"   "${G4} \
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
--units-exponent=0 \
--title "APA RECE" \
DEF:T5temp=$RRD:T5:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T5temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
-y 1:5 \
--units-exponent=0 \
--title "APA CALDA" \
DEF:T6temp=$RRD:T6:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T6temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "IN CASA" \
DEF:T1temp=$RRD:T1:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T1temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "HOL" \
DEF:T2temp=$RRD:T2:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T2temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "AFARA" \
DEF:T3temp=$RRD:T3:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T3temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "BECI" \
DEF:T4temp=$RRD:T4:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T4temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "APA RECE" \
DEF:T5temp=$RRD:T5:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T5temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
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
--units-exponent=0 \
--title "APA CALDA" \
DEF:T6temp=$RRD:T6:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T6temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T6temp$A6:"   "${G6}"  @ 5 min AVERAGE   " \
LINE:T6temp$L6 \
GPRINT:T6temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T6temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T6temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T6temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

#week=>9d/average=15m

rrdtool graph ${DIR}T1w.png \
${Wall} \
--units-exponent=0 \
--title "IN CASA" \
DEF:T1temp=$RRD:T1:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T1temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T1temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T1temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T1temp$A1:"   "${G1}" @ Quarter-Hour AVERAGE   " \
LINE:T1temp$L1 \
GPRINT:T1temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T1temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T1temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T1temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T2w.png \
${Wall} \
--units-exponent=0 \
--title "HOL" \
DEF:T2temp=$RRD:T2:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T2temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T2temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T2temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T2temp$A2:"   "${G2}" @ Quarter-Hour AVERAGE   " \
LINE:T2temp$L2 \
GPRINT:T2temp:MIN:"\t\tmin\: %2.2lf °C\t" \
GPRINT:T2temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T2temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T2temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T3w.png \
${Wall} \
--units-exponent=0 \
--title "AFARA" \
DEF:T3temp=$RRD:T3:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T3temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T3temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T3temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T3temp$A3:"   "${G3}" @ Quarter-Hour AVERAGE" \
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
--units-exponent=0 \
--title "BECI" \
DEF:T4temp=$RRD:T4:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T4temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T4temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T4temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T4temp$A4:"   "${G4}" @ Quarter-Hour AVERAGE     " \
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
--units-exponent=0 \
--title "APA RECE" \
DEF:T5temp=$RRD:T5:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T5temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T5temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T5temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T5temp$A5:"   "${G5}" @ Quarter-Hour AVERAGE   " \
LINE:T5temp$L5 \
GPRINT:T5temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T5temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T5temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T5temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6w.png \
${Wall} \
--units-exponent=0 \
--title "APA CALDA" \
DEF:T6temp=$RRD:T6:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,T6temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,T6temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,T6temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:T6temp$A6:"   "${G6}" @ Quarter-Hour AVERAGE   " \
LINE:T6temp$L6 \
GPRINT:T6temp:MIN:"\tmin\: %2.2lf °C\t" \
GPRINT:T6temp:MAX:"max\: %2.2lf °C\t" \
GPRINT:T6temp:AVERAGE:"avg\: %2.2lf °C\t\t\t" \
GPRINT:T6temp:LAST:"cur\: %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

#month=>35d/average=30m

rrdtool graph ${DIR}ALLm.png \
${Mall} \
--units-exponent=0 \
--title "ALL" \
DEF:T1temp=$RRD:T1:AVERAGE \
DEF:T2temp=$RRD:T2:AVERAGE \
DEF:T3temp=$RRD:T3:AVERAGE \
DEF:T4temp=$RRD:T4:AVERAGE \
DEF:T5temp=$RRD:T5:AVERAGE \
DEF:T6temp=$RRD:T6:AVERAGE \
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
GPRINT:T1temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G1}\: %2.2lf °C" \
GPRINT:T2temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G2}\: %2.2lf °C" \
GPRINT:T3temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G3}\: %2.2lf °C" \
GPRINT:T4temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G4}\: %2.2lf °C" \
GPRINT:T5temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G5}\: %2.2lf °C" \
GPRINT:T6temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G6}\: %2.2lf °C"

rrdtool graph ${DIR}T1m.png \
${Mall} \
--units-exponent=0 \
--title "IN CASA" \
DEF:T1temp=$RRD:T1:AVERAGE \
CDEF:T1trend=T1temp,86400,TREND \
AREA:T1temp$A1:"   "${G1} \
LINE:T1temp$L1 \
GPRINT:T1temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G1}\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T2m.png \
${Mall} \
--units-exponent=0 \
--title "HOL" \
DEF:T2temp=$RRD:T2:AVERAGE \
CDEF:T2trend=T2temp,86400,TREND \
AREA:T2temp$A2:"   "${G2} \
LINE:T2temp$L2 \
GPRINT:T2temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G2}\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold"

rrdtool graph ${DIR}T3m.png \
${Mall} \
--units-exponent=0 \
--title "AFARA" \
DEF:T3temp=$RRD:T3:AVERAGE \
CDEF:T3trend=T3temp,86400,TREND \
AREA:T3temp$A3:"   "${G3} \
LINE:T3temp$L3 \
GPRINT:T3temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G3}\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing" 

rrdtool graph ${DIR}T4m.png \
${Mall} \
--units-exponent=0 \
--title "BECI" \
DEF:T4temp=$RRD:T4:AVERAGE \
CDEF:T4trend=T4temp,86400,TREND \
AREA:T4temp$A4:"   "${G4} \
LINE:T4temp$L4 \
GPRINT:T4temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G4}\: %2.2lf °C\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:10#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}T5m.png \
${Mall} \
--units-exponent=0 \
--title "APA RECE" \
DEF:T5temp=$RRD:T5:AVERAGE \
CDEF:T5trend=T5temp,86400,TREND \
AREA:T5temp$A5:"   "${G5} \
LINE:T5temp$L5 \
GPRINT:T5temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G5}\: %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6m.png \
${Mall} \
--units-exponent=0 \
--title "APA CALDA" \
DEF:T6temp=$RRD:T6:AVERAGE \
CDEF:T6trend=T6temp,86400,TREND \
AREA:T6temp$A6:"   "${G6} \
LINE:T6temp$L6 \
GPRINT:T6temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G6}\: %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

#year=>400d/average=1h

rrdtool graph ${DIR}ALLy.png \
${Yall} \
--units-exponent=0 \
--title "ALL" \
DEF:T1temp=$RRD:T1:AVERAGE \
DEF:T2temp=$RRD:T2:AVERAGE \
DEF:T3temp=$RRD:T3:AVERAGE \
DEF:T4temp=$RRD:T4:AVERAGE \
DEF:T5temp=$RRD:T5:AVERAGE \
DEF:T6temp=$RRD:T6:AVERAGE \
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
GPRINT:T1temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G1}\: %2.2lf °C" \
GPRINT:T2temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G2}\: %2.2lf °C" \
GPRINT:T3temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G3}\: %2.2lf °C" \
GPRINT:T4temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G4}\: %2.2lf °C" \
GPRINT:T5temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G5}\: %2.2lf °C" \
GPRINT:T6temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G6}\: %2.2lf °C"

rrdtool graph ${DIR}T1y.png \
${Yall} \
--units-exponent=0 \
--title "IN CASA" \
DEF:T1temp=$RRD:T1:AVERAGE \
AREA:T1temp$A1:"   "${G1} \
LINE:T1temp$L1 \
GPRINT:T1temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G1}\: %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T2y.png \
${Yall} \
--units-exponent=0 \
--title "HOL" \
DEF:T2temp=$RRD:T2:AVERAGE \
AREA:T2temp$A2:"   "${G2} \
LINE:T2temp$L2 \
GPRINT:T2temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G2}\: %2.2lf °C\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:25#FF0000:"   too hot"

rrdtool graph ${DIR}T3y.png \
${Yall} \
--units-exponent=0 \
--title "AFARA" \
DEF:T3temp=$RRD:T3:AVERAGE \
AREA:T3temp$A3:"   "${G3} \
LINE:T3temp$L3 \
GPRINT:T3temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G3}\: %2.2lf °C\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing" 

rrdtool graph ${DIR}T4y.png \
${Yall} \
--units-exponent=0 \
--title "BECI" \
DEF:T4temp=$RRD:T4:AVERAGE \
AREA:T4temp$A4:"   "${G4} \
LINE:T4temp$L4 \
GPRINT:T4temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G4}\: %2.2lf °C\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:10#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}T5y.png \
${Yall} \
--units-exponent=0 \
--title "APA RECE" \
DEF:T5temp=$RRD:T5:AVERAGE \
AREA:T5temp$A5:"   "${G5} \
LINE:T5temp$L5 \
GPRINT:T5temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G5}\: %2.2lf °C\n" \
HRULE:12#FF0000:"   too warm\n" \
HRULE:8#0066FF:"   too cold"

rrdtool graph ${DIR}T6y.png \
${Yall} \
--units-exponent=0 \
--title "APA CALDA" \
DEF:T6temp=$RRD:T6:AVERAGE \
AREA:T6temp$A6:"   "${G6} \
LINE:T6temp$L6 \
GPRINT:T6temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G6}\: %2.2lf °C\n" \
HRULE:40#FF0000:"   too hot\n" \
HRULE:30#0066FF:"   too cold"

