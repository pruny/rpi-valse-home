#!/bin/bash

INCOLOUR="#FF0000"
OUTCOLOUR="#0000FF"
TRENDCOLOUR="#000000"

############################
#
# Parameters to adjust
#
############################

# graph folder (volatile, in RAM)
DIR="/var/www/files/data/TMPFS/"

# sensor labels
G1="Room"
G2="Hall"
G3="Outside"
G4="Air"
G5="Cold Water"
G6="Warm Water"

# graph colors
C1="#00FF00"
C2="#00C957"
C3="#0000FF"
C4="#FFA500"
C5="#00EEEE"
C6="#FF0000"
CX="#000000"

# rrdgraph options
H="--alt-autoscale --y-grid 0.1:10 --start -3h --full-size-mode --width 315 --height 150"
D="--alt-autoscale --y-grid 0.1:10 --start -30h --full-size-mode --width 315 --height 150"
W="--alt-autoscale --y-grid 0.1:10 --start -9d --full-size-mode --width 315 --height 150"
M="--alt-autoscale --y-grid 0.1:10 --start -35d --full-size-mode --width 315 --height 150"
Y="--alt-autoscale --y-grid 0.1:10 --start -400d --full-size-mode --width 315 --height 150"

# some colours
#CRIMSON="#B0171F"
#PINK="#FFC0CB"
#PURPLE="#9B30FF"
#BLUE="#0000FF"
#CYAN="#00EEEE"
#GREEN="#00C957"
#LIME="#00FF00"
#YELLOW="#FFFF00"
#ORANGE="#FFA500"
#RED="#FF0000"
#BLACK="#000000"

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

rrdtool graph ${DIR}ALLh.png -A --y-grid 1:5 --start -3h --full-size-mode -w 955 -h 350 \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T1trend=T1temp,60,TREND \
CDEF:T2trend=T2temp,60,TREND \
CDEF:T3trend=T3temp,60,TREND \
CDEF:T4trend=T4temp,60,TREND \
CDEF:T5trend=T5temp,60,TREND \
CDEF:T6trend=T6temp,60,TREND \
LINE2:T1temp$C1:"${G1} vs hour" \
LINE1:T1trend$TRENDCOLOUR \
LINE2:T2temp$C2:"${G2} vs hour" \
LINE1:T2trend$TRENDCOLOUR \
LINE2:T3temp$C3:"${G3} vs hour" \
LINE1:T3trend$TRENDCOLOUR \
LINE2:T4temp$C4:"${G4} vs hour" \
LINE1:T4trend$TRENDCOLOUR \
LINE2:T5temp$C5:"${G5} vs hour" \
LINE1:T5trend$TRENDCOLOUR \
LINE2:T6temp$C6:"${G6} vs hour" \
LINE1:T6trend$TRENDCOLOUR

rrdtool graph ${DIR}T1h.png \
${H} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,60,TREND \
LINE2:T1temp$C1:"${G1} vs hour" \
LINE1:T1trend$CX:"1 min average"

rrdtool graph ${DIR}T2h.png \
${H} \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,60,TREND \
LINE2:T2temp$C2:"${G2} vs hour" \
LINE1:T2trend$CX:"1 min average"

rrdtool graph ${DIR}T3h.png \
${H} \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,60,TREND \
LINE2:T3temp$C3:"${G3} vs hour" \
LINE1:T3trend$CX:"1 min average"

rrdtool graph ${DIR}T4h.png \
${H} \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,60,TREND \
LINE2:T4temp$C4:"${G4} vs hour" \
LINE1:T4trend$CX:"1 min average"

rrdtool graph ${DIR}T5h.png \
${H} \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,60,TREND \
LINE2:T5temp$C5:"${G5} vs hour" \
LINE1:T5trend$CX:"1 min average"

rrdtool graph ${DIR}T6h.png \
${H} \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,60,TREND \
LINE2:T6temp$C6:"${G6} vs hour" \
LINE1:T6trend$CX:"1 min average"

#day=>30h/average=5m

rrdtool graph ${DIR}ALLd.png -A --y-grid 1:5 --start -30h --full-size-mode -w 955 -h 350 \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T1trend=T1temp,300,TREND \
CDEF:T2trend=T2temp,300,TREND \
CDEF:T3trend=T3temp,300,TREND \
CDEF:T4trend=T4temp,300,TREND \
CDEF:T5trend=T5temp,300,TREND \
CDEF:T6trend=T6temp,300,TREND \
LINE2:T1temp$C1:"${G1} vs day" \
LINE1:T1trend$TRENDCOLOUR \
LINE2:T2temp$C2:"${G2} vs day" \
LINE1:T2trend$TRENDCOLOUR \
LINE2:T3temp$C3:"${G3} vs day" \
LINE1:T3trend$TRENDCOLOUR \
LINE2:T4temp$C4:"${G4} vs day" \
LINE1:T4trend$TRENDCOLOUR \
LINE2:T5temp$C5:"${G5} vs day" \
LINE1:T5trend$TRENDCOLOUR \
LINE2:T6temp$C6:"${G6} vs day" \
LINE1:T6trend$TRENDCOLOUR

rrdtool graph ${DIR}T1d.png \
${D} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,300,TREND \
LINE2:T1temp$C1:"${G1} vs day" \
LINE1:T1trend$CX:"5 min average"

rrdtool graph ${DIR}T2d.png -A \
${D} \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,300,TREND \
LINE2:T2temp$C2:"${G2} vs day" \
LINE1:T2trend$CX:"5 min average"

rrdtool graph ${DIR}T3d.png -A \
${D} \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,300,TREND \
LINE2:T3temp$C3:"${G3} vs day" \
LINE1:T3trend$CX:"5 min average"

rrdtool graph ${DIR}T4d.png -A \
${D} \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,300,TREND \
LINE2:T4temp$C4:"${G4} vs day" \
LINE1:T4trend$CX:"5 min average"

rrdtool graph ${DIR}T5d.png \
${D} \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,300,TREND \
LINE2:T5temp$C5:"${G5} vs day" \
LINE1:T5trend$CX:"5 min average"

rrdtool graph ${DIR}T6d.png \
${D} \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,300,TREND \
LINE2:T6temp$C6:"${G6} vs day" \
LINE1:T6trend$CX:"5 min average"

#week=>9d/average=1h

rrdtool graph ${DIR}ALLw.png -A --y-grid 1:5 --start -9d --full-size-mode -w 955 -h 350 \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T1trend=T1temp,3600,TREND \
CDEF:T2trend=T2temp,3600,TREND \
CDEF:T3trend=T3temp,3600,TREND \
CDEF:T4trend=T4temp,3600,TREND \
CDEF:T5trend=T5temp,3600,TREND \
CDEF:T6trend=T6temp,3600,TREND \
LINE2:T1temp$C1:"${G1} vs week" \
LINE1:T1trend$TRENDCOLOUR \
LINE2:T2temp$C2:"${G2} vs week" \
LINE1:T2trend$TRENDCOLOUR \
LINE2:T3temp$C3:"${G3} vs week" \
LINE1:T3trend$TRENDCOLOUR \
LINE2:T4temp$C4:"${G4} vs week" \
LINE1:T4trend$TRENDCOLOUR \
LINE2:T5temp$C5:"${G5} vs week" \
LINE1:T5trend$TRENDCOLOUR \
LINE2:T6temp$C6:"${G6} vs week" \
LINE1:T6trend$TRENDCOLOUR

rrdtool graph ${DIR}T1w.png \
${W} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,3600,TREND \
LINE2:T1temp$C1:"${G1} vs week" \
LINE1:T1trend$CX:"1 hr average"

rrdtool graph ${DIR}T2w.png \
${W} \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,3600,TREND \
LINE2:T2temp$C2:"${G2} vs week" \
LINE1:T2trend$CX:"1 hr average"

rrdtool graph ${DIR}T3w.png -A \
${W} \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,3600,TREND \
LINE2:T3temp$C3:"${G3} vs week" \
LINE1:T3trend$CX:"1 hr average"

rrdtool graph ${DIR}T4w.png -A \
${W} \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,3600,TREND \
LINE2:T4temp$C4:"${G4} vs week" \
LINE1:T4trend$CX:"1 hr average"

rrdtool graph ${DIR}T5w.png -A \
${W} \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,3600,TREND \
LINE2:T5temp$C5:"${G5} vs week" \
LINE1:T5trend$CX:"1 hr average"

rrdtool graph ${DIR}T6w.png -A \
${W} \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,3600,TREND \
LINE2:T6temp$C6:"${G6} vs week" \
LINE1:T6trend$CX:"1 hr average"

#month=>35d/average=1h

rrdtool graph ${DIR}ALLm.png -A --y-grid 1:5 --start -35d --full-size-mode -w 955 -h 350 \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T1trend=T1temp,3600,TREND \
CDEF:T2trend=T2temp,3600,TREND \
CDEF:T3trend=T3temp,3600,TREND \
CDEF:T4trend=T4temp,3600,TREND \
CDEF:T5trend=T5temp,3600,TREND \
CDEF:T6trend=T6temp,3600,TREND \
LINE2:T1temp$C1:"${G1} vs month" \
LINE1:T1trend$TRENDCOLOUR \
LINE2:T2temp$C2:"${G2} vs month" \
LINE1:T2trend$TRENDCOLOUR \
LINE2:T3temp$C3:"${G3} vs month" \
LINE1:T3trend$TRENDCOLOUR \
LINE2:T4temp$C4:"${G4} vs month" \
LINE1:T4trend$TRENDCOLOUR \
LINE2:T5temp$C5:"${G5} vs month" \
LINE1:T5trend$TRENDCOLOUR \
LINE2:T6temp$C6:"${G6} vs month" \
LINE1:T6trend$TRENDCOLOUR

rrdtool graph ${DIR}T1m.png \
${M} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,3600,TREND \
LINE2:T1temp$C1:"${G1} vs month" \
LINE1:T1trend$CX:"1 hr average"

rrdtool graph ${DIR}T2m.png \
${M} \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,3600,TREND \
LINE2:T2temp$C2:"${G2} vs month" \
LINE1:T2trend$CX:"1 hr average"

rrdtool graph ${DIR}T3m.png \
${M} \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,3600,TREND \
LINE2:T3temp$C3:"${G3} vs month" \
LINE1:T3trend$CX:"1 hr average"

rrdtool graph ${DIR}T4m.png \
${M} \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,3600,TREND \
LINE2:T4temp$C4:"${G4} vs month" \
LINE1:T4trend$CX:"1 hr average"

rrdtool graph ${DIR}T5m.png -A \
${M} \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,3600,TREND \
LINE2:T5temp$C5:"${G5} vs month" \
LINE1:T5trend$CX:"1 hr average"

rrdtool graph ${DIR}T6m.png \
${M} \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,3600,TREND \
LINE2:T6temp$C6:"${G6} vs month" \
LINE1:T6trend$CX:"1 hr average"

#year=>400d/average=6h

rrdtool graph ${DIR}ALLy.png -A --y-grid 1:5 --start -400d --full-size-mode -w 955 -h 350 \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T1trend=T1temp,21600,TREND \
CDEF:T2trend=T2temp,21600,TREND \
CDEF:T3trend=T3temp,21600,TREND \
CDEF:T4trend=T4temp,21600,TREND \
CDEF:T5trend=T5temp,21600,TREND \
CDEF:T6trend=T6temp,21600,TREND \
LINE2:T1temp$C1:"${G1} vs year" \
LINE1:T1trend$TRENDCOLOUR \
LINE2:T2temp$C2:"${G2} vs year" \
LINE1:T2trend$TRENDCOLOUR \
LINE2:T3temp$C3:"${G3} vs year" \
LINE1:T3trend$TRENDCOLOUR \
LINE2:T4temp$C4:"${G4} vs year" \
LINE1:T4trend$TRENDCOLOUR \
LINE2:T5temp$C5:"${G5} vs year" \
LINE1:T5trend$TRENDCOLOUR \
LINE2:T6temp$C6:"${G6} vs year" \
LINE1:T6trend$TRENDCOLOUR

rrdtool graph ${DIR}T1y.png \
${Y} \
DEF:T1temp=Temp.rrd:T1:AVERAGE \
CDEF:T1trend=T1temp,21600,TREND \
LINE2:T1temp$C1:"${G1} vs year" \
LINE1:T1trend$CX:"6 hr average"

rrdtool graph ${DIR}T2y.png \
${Y} \
DEF:T2temp=Temp.rrd:T2:AVERAGE \
CDEF:T2trend=T2temp,21600,TREND \
LINE2:T2temp$C2:"${G2} vs year" \
LINE1:T2trend$CX:"6 hr average"

rrdtool graph ${DIR}T3y.png \
${Y} \
DEF:T3temp=Temp.rrd:T3:AVERAGE \
CDEF:T3trend=T3temp,21600,TREND \
LINE2:T3temp$C3:"${G3} vs year" \
LINE1:T3trend$CX:"6 hr average"

rrdtool graph ${DIR}T4y.png \
${Y} \
DEF:T4temp=Temp.rrd:T4:AVERAGE \
CDEF:T4trend=T4temp,21600,TREND \
LINE2:T4temp$C4:"${G4} vs year" \
LINE1:T4trend$CX:"6 hr average"

rrdtool graph ${DIR}T5y.png \
${Y} \
DEF:T5temp=Temp.rrd:T5:AVERAGE \
CDEF:T5trend=T5temp,21600,TREND \
LINE2:T5temp$C5:"${G5} vs year" \
LINE1:T5trend$CX:"6 hr average"

rrdtool graph ${DIR}T6y.png \
${Y} \
DEF:T6temp=Temp.rrd:T6:AVERAGE \
CDEF:T6trend=T6temp,21600,TREND \
LINE2:T6temp$C6:"${G6} vs year" \
LINE1:T6trend$CX:"6 hr average"
