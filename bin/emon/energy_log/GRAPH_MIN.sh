#!/bin/bash

INCOLOUR="#FF0000"
OUTCOLOUR="#0000FF"
TRENDCOLOUR="#000000"

########################
#                      #
# Parameters to adjust #
#                      #
########################

# database
RRD="EMON.rrd"		# symlink to /home/pi/data/shared/emon/EMON.rrd

# graph folder (volatile, in RAM - sometime is corrupted so delete first and create after that)
DIR="/var/www/TMPFS/PNG/emon/"
rm -rf $DIR
mkdir -p $DIR

# sensor labels
G1="V1"
G2="V2"
G3="V3"
G4="V0"
G5="I1"
G6="I2"
G7="I3"
G8="Ptot"

# units
U1="V"
U2="A"
U3="kW" # logarithmic scale

##################################### de modificat de aici
# colored graph lines
L1="#FF3300"
L2="#FF0000"
L3="#0000FF"
L4="#00C957"
L5="#00FF00"
L6="#00EEEE"
LX="#000000"

# colored graph areas
A1="#FFF4DE"
A2="#E8ADAA"
A3="#B8B8FF"
A4="#A0D2B6"
A5="#98FF98"
A6="#C7EEEE"
AX="#B6B6B4"

# colored night areas
N1="#F2F2F2"	# verylightgray
N2="#E0E0E0"	# lightgray
N3="#A6A6A6"	# gray
N4="#4D4D4D"	# darkgray

TWLC1=$N1
TWLC2=$N1
DRKC1=$N2
DRKC2=$N2

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

<<"COMMENT"
	NIGHT have four phases:
 	twilight1 - sunset to dusk	>> TWL1
 	darkness1 - dusk to midnight	>> DRK1
 	darkness2 - midnight to dawn	>> DRK2
 	twilight2 - dawn to sunrise	>> TLW2
COMMENT

# location (my home) valse
LAT="45.1722867N"
LON="24.7955867E"

# Calculating Civil Twilight based on location from LAT LON (amurg si zori de zi tinand cont de ora de vara EEST:UTC+3 sau de iarna EET:UTC+2)
DAWNHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 30-31`
DAWNMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 32-33`
DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 48-49; else cut -c 46-47; fi`
DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 50-51; else cut -c 48-49; fi`

# winter time
#DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 45-46`
#DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 47-48`

# summer time
#DUSKHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 46-47`
#DUSKMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 48-49`

# Calculating sunset/sunrise based on location from LAT LON (apusul si rasaritul tinand cont de ora de vara EEST:UTC+3 sau de iarna EET:UTC+2) 
SUNRISEHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 30-31`
SUNRISEMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 32-33`
SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 48-49; else cut -c 46-47; fi`
SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | if [ -e EEST ] ; then cut -c 50-51; else cut -c 48-49; fi`

# winter time
#SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 45-46`
#SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 47-48`

# summer time
#SUNSETHR=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 46-47`
#SUNSETMIN=`/usr/local/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 48-49`

# Converting to seconds (format text as decimal numbers & calculate...)
SUNR=$((10#$SUNRISEHR * 3600 + 10#$SUNRISEMIN * 60))
SUNS=$((10#$SUNSETHR * 3600 + 10#$SUNSETMIN * 60))
DUSK=$((10#$DUSKHR * 3600 + 10#$DUSKMIN * 60))
DAWN=$((10#$DAWNHR * 3600 + 10#$DAWNMIN * 60))

####################################
#                                  #
# Creating graphs for 29 variables #
#                                  #
####################################

#hour=>3h/average=1m

rrdtool graph ${DIR}ah.png \
${Hall} \
--logarithmic \
--units=si \
--title "Iluminance" \
DEF:light=$RRD:a:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,light,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,light,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,light,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,light,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:light$A1:"   "${G1}"     " \
LINE:light$L1 \
GPRINT:light:MIN:"\t\t\t\tmin\: %2.2lf ${U1}\t" \
GPRINT:light:MAX:"max\: %2.2lf ${U1}\t" \
GPRINT:light:AVERAGE:"avg\: %2.2lf ${U1}\t" \
GPRINT:light:LAST:"cur\: %2.2lf ${U1}\n" \
HRULE:50#FF0000:"   too light\n" \
HRULE:20#0066FF:"   too dark"

rrdtool graph ${DIR}bh.png \
${Hall} \
--units-exponent=0 \
--title "Temperature" \
DEF:temp=$RRD:b:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:temp$A2:"   "${G2}"    " \
LINE:temp$L2 \
GPRINT:temp:MIN:"\t\t\t\tmin\: %2.2lf ${U2}\t" \
GPRINT:temp:MAX:"max\: %2.2lf ${U2}\t\t" \
GPRINT:temp:AVERAGE:"avg\: %2.2lf ${U2}\t\t" \
GPRINT:temp:LAST:"cur\: %2.2lf ${U2}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}ch.png \
${Hall} \
--units-exponent=0 \
--title "DEW Point" \
DEF:dew=$RRD:c:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,dew,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,dew,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,dew,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,dew,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:dew$A3:"   "${G3}"      " \
LINE:dew$L3 \
GPRINT:dew:MIN:"\t\t\t\tmin\: %2.2lf ${U3}\t" \
GPRINT:dew:MAX:"max\: %2.2lf ${U3}\t\t" \
GPRINT:dew:AVERAGE:"avg\: %2.2lf ${U3}\t\t" \
GPRINT:dew:LAST:"cur\: %2.2lf ${U3}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}dh.png \
${Hall} \
--units-exponent=0 \
--title "RH (raw)" \
DEF:rhraw=$RRD:d:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,rhraw,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,rhraw,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,rhraw,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,rhraw,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:rhraw$A4:"   "${G4}" " \
LINE:rhraw$L4 \
GPRINT:rhraw:MIN:"\t\t\t\tmin\: %2.2lf ${U4}\t" \
GPRINT:rhraw:MAX:"max\: %2.2lf ${U4}\t" \
GPRINT:rhraw:AVERAGE:"avg\: %2.2lf ${U4}\t" \
GPRINT:rhraw:LAST:"cur\: %2.2lf ${U4}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}eh.png \
${Hall} \
--units-exponent=0 \
--title "RH (comp)" \
DEF:rhcomp=$RRD:e:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,rhcomp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,rhcomp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,rhcomp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,rhcomp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:rhcomp$A5:"   "${G5} \
LINE:rhcomp$L5 \
GPRINT:rhcomp:MIN:"\t\t\t\tmin\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:MAX:"max\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:AVERAGE:"avg\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:LAST:"cur\: %2.2lf ${U5}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}fh.png \
${Hall} \
-y 1:5 \
--units-exponent=0 \
--title "Vapor Pressure" \
DEF:vpress=$RRD:f:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,vpress,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,vpress,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,vpress,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,vpress,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:vpress$A6:"   "${G6}" " \
LINE:vpress$L6 \
GPRINT:vpress:MIN:"\t\t\t\tmin\: %2.2lf ${U6}\t" \
GPRINT:vpress:MAX:"max\: %2.2lf ${U6}\t" \
GPRINT:vpress:AVERAGE:"avg\: %2.2lf ${U6}\t" \
GPRINT:vpress:LAST:"cur\: %2.2lf ${U6}\n" \
HRULE:40#FF0000:"   too much\n" \
HRULE:30#0066FF:"   too little"

#day=>30h/average=5m

rrdtool graph ${DIR}ad.png \
${Dall} \
--logarithmic \
--units=si \
--title "Iluminance" \
DEF:light=$RRD:a:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,light,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,light,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,light,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,light,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:light$A1:"   "${G1}"  @ 5 min AVERAGE     " \
LINE:light$L1 \
GPRINT:light:MIN:"\tmin\: %2.2lf ${U1}\t" \
GPRINT:light:MAX:"max\: %2.2lf ${U1}\t" \
GPRINT:light:AVERAGE:"avg\: %2.2lf ${U1}\t" \
GPRINT:light:LAST:"cur\: %2.2lf ${U1}\n" \
HRULE:50#FF0000:"   too light\n" \
HRULE:20#0066FF:"   too dark"

rrdtool graph ${DIR}bd.png \
${Dall} \
--units-exponent=0 \
--title "Temperature" \
DEF:temp=$RRD:b:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:temp$A2:"   "${G2}"  @ 5 min AVERAGE    " \
LINE:temp$L2 \
GPRINT:temp:MIN:"\tmin\: %2.2lf ${U2}\t" \
GPRINT:temp:MAX:"max\: %2.2lf ${U2}\t\t" \
GPRINT:temp:AVERAGE:"avg\: %2.2lf ${U2}\t\t" \
GPRINT:temp:LAST:"cur\: %2.2lf ${U2}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}cd.png \
${Dall} \
--units-exponent=0 \
--title "DEW Point" \
DEF:dew=$RRD:c:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,dew,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,dew,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,dew,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,dew,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:dew$A3:"   "${G3}"  @ 5 min AVERAGE      " \
LINE:dew$L3 \
GPRINT:dew:MIN:"\tmin\: %2.2lf ${U3}\t" \
GPRINT:dew:MAX:"max\: %2.2lf ${U3}\t\t" \
GPRINT:dew:AVERAGE:"avg\: %2.2lf ${U3}\t\t" \
GPRINT:dew:LAST:"cur\: %2.2lf ${U3}\n" \
HRULE:40#FF0000:"   too much\n" \
HRULE:30#0066FF:"   too little"

rrdtool graph ${DIR}dd.png \
${Dall} \
--units-exponent=0 \
--title "RH (raw)" \
DEF:rhraw=$RRD:d:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,rhraw,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,rhraw,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,rhraw,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,rhraw,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:rhraw$A4:"   "${G4}"  @ 5 min AVERAGE " \
LINE:rhraw$L4 \
GPRINT:rhraw:MIN:"\tmin\: %2.2lf ${U4}\t" \
GPRINT:rhraw:MAX:"max\: %2.2lf ${U4}\t" \
GPRINT:rhraw:AVERAGE:"avg\: %2.2lf ${U4}\t" \
GPRINT:rhraw:LAST:"cur\: %2.2lf ${U4}\n" \
HRULE:18#FF0000:"   too hot\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}ed.png \
${Dall} \
--units-exponent=0 \
--title "RH (comp)" \
DEF:rhcomp=$RRD:e:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,rhcomp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,rhcomp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,rhcomp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,rhcomp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:rhcomp$A5:"   "${G5}"  @ 5 min AVERAGE" \
LINE:rhcomp$L5 \
GPRINT:rhcomp:MIN:"\tmin\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:MAX:"max\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:AVERAGE:"avg\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:LAST:"cur\: %2.2lf ${U5}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}fd.png \
${Dall} \
--units-exponent=0 \
--title "Vapor Pressure" \
DEF:vpress=$RRD:f:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,vpress,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,vpress,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,vpress,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,vpress,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:vpress$A6:"   "${G6}"  @ 5 min AVERAGE " \
LINE:vpress$L6 \
GPRINT:vpress:MIN:"\tmin\: %2.2lf ${U6}\t" \
GPRINT:vpress:MAX:"max\: %2.2lf ${U6}\t" \
GPRINT:vpress:AVERAGE:"avg\: %2.2lf ${U6}\t" \
GPRINT:vpress:LAST:"cur\: %2.2lf ${U6}\n" \
HRULE:40#FF0000:"   too much\n" \
HRULE:30#0066FF:"   too little"

#week=>9d/average=15m

rrdtool graph ${DIR}aw.png \
${Wall} \
--logarithmic \
--units=si \
--title "Iluminance" \
DEF:light=$RRD:a:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,light,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,light,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,light,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,light,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:light$A1:"   "${G1}" @ Quarter-Hour AVERAGE" \
LINE:light$L1 \
GPRINT:light:MIN:"       min\: %2.2lf ${U1}    " \
GPRINT:light:MAX:"max\: %2.2lf ${U1}\t" \
GPRINT:light:AVERAGE:"avg\: %2.2lf ${U1}\t\t" \
GPRINT:light:LAST:"cur\: %2.2lf ${U1}\n" \
HRULE:50#FF0000:"   too light\n" \
HRULE:20#0066FF:"   too dark"

rrdtool graph ${DIR}bw.png \
${Wall} \
--units-exponent=0 \
--title "Temperature" \
DEF:temp=$RRD:b:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,temp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,temp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,temp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,temp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:temp$A2:"   "${G2}" @ Quarter-Hour AVERAGE" \
LINE:temp$L2 \
GPRINT:temp:MIN:"      min\: %2.2lf ${U2}     " \
GPRINT:temp:MAX:"max\: %2.2lf ${U2}\t\t" \
GPRINT:temp:AVERAGE:"avg\: %2.2lf ${U2}\t\t" \
GPRINT:temp:LAST:"cur\: %2.2lf ${U2}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}cw.png \
${Wall} \
--units-exponent=0 \
--title "DEW Point" \
DEF:dew=$RRD:c:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,dew,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,dew,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,dew,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,dew,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:dew$A3:"   "${G3}" @ Quarter-Hour AVERAGE" \
LINE:dew$L3 \
GPRINT:dew:MIN:"\tmin\: %2.2lf ${U3}\t" \
GPRINT:dew:MAX:"max\: %2.2lf ${U3}\t\t" \
GPRINT:dew:AVERAGE:"avg\: %2.2lf ${U3}\t\t" \
GPRINT:dew:LAST:"cur\: %2.2lf ${U3}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}dw.png \
${Wall} \
--units-exponent=0 \
--title "RH (raw)" \
DEF:rhraw=$RRD:d:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,rhraw,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,rhraw,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,rhraw,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,rhraw,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:rhraw$A4:"   "${G4}" @ Quarter-Hour AVERAGE " \
LINE:rhraw$L4 \
GPRINT:rhraw:MIN:"   min\: %2.2lf ${U4}\t" \
GPRINT:rhraw:MAX:"max\: %2.2lf ${U4}\t" \
GPRINT:rhraw:AVERAGE:"avg\: %2.2lf ${U4}\t" \
GPRINT:rhraw:LAST:"cur\: %2.2lf ${U4}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}ew.png \
${Wall} \
--units-exponent=0 \
--title "RH (comp)" \
DEF:rhcomp=$RRD:e:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,rhcomp,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,rhcomp,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,rhcomp,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,rhcomp,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:rhcomp$A5:"   "${G5}" @ Quarter-Hour AVERAGE" \
LINE:rhcomp$L5 \
GPRINT:rhcomp:MIN:"  min\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:MAX:"max\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:AVERAGE:"avg\: %2.2lf ${U5}\t" \
GPRINT:rhcomp:LAST:"cur\: %2.2lf ${U5}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}fw.png \
${Wall} \
--units-exponent=0 \
--title "Vapor Pressure" \
DEF:vpress=$RRD:f:AVERAGE \
CDEF:TWL1=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,vpress,*,IF,IF \
CDEF:TWL2=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,vpress,*,IF,IF \
CDEF:DRK1=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,vpress,*,IF,IF \
CDEF:DRK2=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,vpress,*,IF,IF \
AREA:TWL1$TWLC1 \
AREA:DRK1$DRKC1 \
AREA:TWL2$TWLC2 \
AREA:DRK2$DRKC2 \
AREA:vpress$A6:"   "${G6}" @ Quarter-Hour AVERAGE " \
LINE:vpress$L6 \
GPRINT:vpress:MIN:"   min\: %2.2lf ${U6}\t" \
GPRINT:vpress:MAX:"max\: %2.2lf ${U6}\t" \
GPRINT:vpress:AVERAGE:"avg\: %2.2lf ${U6}\t" \
GPRINT:vpress:LAST:"cur\: %2.2lf ${U6}\n" \
HRULE:40#FF0000:"   too much\n" \
HRULE:30#0066FF:"   too little"

#month=>35d/average=30m

rrdtool graph ${DIR}ALLm.png \
${Mall} \
--title "ALL" \
DEF:light=$RRD:a:AVERAGE \
DEF:temp=$RRD:b:AVERAGE \
DEF:dew=$RRD:c:AVERAGE \
DEF:rhraw=$RRD:d:AVERAGE \
DEF:rhcomp=$RRD:e:AVERAGE \
DEF:vpress=$RRD:f:AVERAGE \
CDEF:atrend=light,86400,TREND \
CDEF:btrend=temp,86400,TREND \
CDEF:ctrend=dew,86400,TREND \
CDEF:dtrend=rhraw,86400,TREND \
CDEF:etrend=rhcomp,86400,TREND \
CDEF:ftrend=vpress,86400,TREND \
AREA:light$A1:${G1} \
LINE:light$L1 \
AREA:temp$A2:${G2} \
LINE:temp$L2 \
AREA:dew$A3:${G3} \
LINE:dew$L3 \
AREA:rhraw$A4:${G4} \
LINE:rhraw$L4 \
AREA:rhcomp$A5:${G5} \
LINE:rhcomp$L5 \
AREA:rhcomp$A6:${G6} \
LINE:vpress$L6 \
GPRINT:light:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G1}\: %2.2lf ${U1}" \
GPRINT:temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G2}\: %2.2lf ${U2}" \
GPRINT:dew:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G3}\: %2.2lf ${U3}" \
GPRINT:rhraw:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G4}\: %2.2lf ${U4}" \
GPRINT:rhcomp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G5}\: %2.2lf ${U5}" \
GPRINT:vpress:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G6}\: %2.2lf ${U6}"

rrdtool graph ${DIR}am.png \
${Mall} \
--logarithmic \
--units=si \
--title "Iluminance" \
DEF:light=$RRD:a:AVERAGE \
CDEF:atrend=light,86400,TREND \
AREA:light$A1:"   "${G1} \
LINE:light$L1 \
GPRINT:light:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G1}\: %2.2lf ${U1}\n" \
HRULE:50#FF0000:"   too light\n" \
HRULE:20#0066FF:"   too dark"

rrdtool graph ${DIR}bm.png \
${Mall} \
--units-exponent=0 \
--title "Temperature" \
DEF:temp=$RRD:b:AVERAGE \
CDEF:btrend=temp,86400,TREND \
AREA:temp$A2:"   "${G2} \
LINE:temp$L2 \
GPRINT:temp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G2}\: %2.2lf ${U2}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}cm.png \
${Mall} \
--units-exponent=0 \
--title "DEW Point" \
DEF:dew=$RRD:c:AVERAGE \
CDEF:ctrend=dew,86400,TREND \
AREA:dew$A3:"   "${G3} \
LINE:dew$L3 \
GPRINT:dew:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G3}\: %2.2lf ${U3}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}dm.png \
${Mall} \
--title "RH (raw)" \
DEF:rhraw=$RRD:d:AVERAGE \
CDEF:dtrend=rhraw,86400,TREND \
AREA:rhraw$A4:"   "${G4} \
LINE:rhraw$L4 \
GPRINT:rhraw:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G4}\: %2.2lf ${U4}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}em.png \
${Mall} \
--units-exponent=0 \
--title "RH (comp)" \
DEF:rhcomp=$RRD:e:AVERAGE \
CDEF:etrend=rhcomp,86400,TREND \
AREA:rhcomp$A5:"   "${G5} \
LINE:rhcomp$L5 \
GPRINT:rhcomp:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G5}\: %2.2lf ${U5}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}fm.png \
${Mall} \
--units-exponent=0 \
--title "Vapor Pressure" \
DEF:vpress=$RRD:f:AVERAGE \
CDEF:ftrend=vpress,86400,TREND \
AREA:vpress$A6:"   "${G6} \
LINE:vpress$L6 \
GPRINT:vpress:AVERAGE:"\t\t\t\t\tHalf-Hour AVERAGE ${G6}\: %2.2lf ${U6}\n" \
HRULE:40#FF0000:"   too much\n" \
HRULE:30#0066FF:"   too little"

#year=>400d/average=1h

rrdtool graph ${DIR}ALLy.png \
${Yall} \
--title "ALL" \
DEF:light=$RRD:a:AVERAGE \
DEF:temp=$RRD:b:AVERAGE \
DEF:dew=$RRD:c:AVERAGE \
DEF:rhraw=$RRD:d:AVERAGE \
DEF:rhcomp=$RRD:e:AVERAGE \
DEF:vpress=$RRD:f:AVERAGE \
AREA:light$A1:${G1} \
LINE:light$L1 \
AREA:temp$A2:$${G2} \
LINE:temp$L2 \
AREA:dew$A3:${G3} \
LINE:dew$L3 \
AREA:rhraw$A4:${G4} \
LINE:rhraw$L4 \
AREA:rhcomp$A5:${G5} \
LINE:rhcomp$L5 \
AREA:rhcomp$A6:${G6} \
LINE:vpress$L6 \
GPRINT:light:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G1}\: %2.2lf ${U1}" \
GPRINT:temp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G2}\: %2.2lf ${U2}" \
GPRINT:dew:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G3}\: %2.2lf ${U3}" \
GPRINT:rhraw:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G4}\: %2.2lf ${U4}" \
GPRINT:rhcomp:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G5}\: %2.2lf ${U5}" \
GPRINT:vpress:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G6}\: %2.2lf ${U6}"

rrdtool graph ${DIR}ay.png \
${Yall} \
--logarithmic \
--units=si \
--title "Iluminance" \
DEF:light=$RRD:a:AVERAGE \
AREA:light$A1:"   "${G1} \
LINE:light$L1 \
GPRINT:light:AVERAGE:"\t\t\t\t\tHourly AVERAGE ${G1}\: %2.2lf ${U1}\n" \
HRULE:50#FF0000:"   too light\n" \
HRULE:20#0066FF:"   too dark"

rrdtool graph ${DIR}by.png \
${Yall} \
--units-exponent=0 \
--title "Temperature" \
DEF:temp=$RRD:b:AVERAGE \
AREA:temp$A2:"   "${G2} \
LINE:temp$L2 \
GPRINT:temp:AVERAGE:"\t\t\t\t     Hourly AVERAGE ${G2}\: %2.2lf ${U2}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}cy.png \
${Yall} \
--units-exponent=0 \
--title "DEW Point" \
DEF:dew=$RRD:c:AVERAGE \
AREA:dew$A3:"   "${G3} \
LINE:dew$L3 \
GPRINT:dew:AVERAGE:"\t\t\t\t\t Hourly AVERAGE ${G3}\: %2.2lf ${U3}\n" \
HRULE:25#FF0000:"   too hot\n" \
HRULE:20#0066FF:"   too cold\n" \
HRULE:0#CC99FF:"   freezing"

rrdtool graph ${DIR}dy.png \
${Yall} \
--units-exponent=0 \
--title "RH (raw)" \
DEF:rhraw=$RRD:d:AVERAGE \
AREA:rhraw$A4:"   "${G4} \
LINE:rhraw$L4 \
GPRINT:rhraw:AVERAGE:"\t\t\t\tHourly AVERAGE ${G4}\: %2.2lf ${U4}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}ey.png \
${Yall} \
--units-exponent=0 \
--title "RH (comp)" \
DEF:rhcomp=$RRD:e:AVERAGE \
AREA:rhcomp$A5:"   "${G5} \
LINE:rhcomp$L5 \
GPRINT:rhcomp:AVERAGE:"\t\t\t\tHourly AVERAGE ${G5}\: %2.2lf ${U5}\n" \
HRULE:80#FF0000:"   too wet\n" \
HRULE:10#0066FF:"   too dry"

rrdtool graph ${DIR}fy.png \
${Yall} \
--units-exponent=0 \
--title "Vapor Pressure" \
DEF:vpress=$RRD:f:AVERAGE \
AREA:vpress$A6:"   "${G6} \
LINE:vpress$L6 \
GPRINT:vpress:AVERAGE:"\t\t\t\tHourly AVERAGE ${G6}\: %2.2lf ${U6}\n" \
HRULE:40#FF0000:"   too much\n" \
HRULE:30#0066FF:"   too little"
