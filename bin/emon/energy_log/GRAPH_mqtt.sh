#!/bin/bash

# https://community.openenergymonitor.org/t/how-to-rrd-graph-mqtt-topic-from-devices/1679

now=$(date +%s)
now_formatted=$(date +%s | awk '{printf "%s\n", strftime("%c",$1)}' | sed -e 's/:/\:/g')

# create power graph for last week
/usr/bin/rrdtool graph /var/www/TMPFS/power-week.png \
--start end-7d --width 543 --height 267 --end $now-1min --slope-mode \
--vertical-label "KiloWatts" --lower-limit 0 \
--alt-autoscale-max \
--title "Power: Last week vs. week before" \
--watermark "(©) $(date +%Y) TED monitor " \
--font WATERMARK:8 \
DEF:kw=EMON_mqtt.rrd:kw:AVERAGE \
DEF:Power2=EMON_mqtt.rrd:kw:AVERAGE:end=$now-7d1min:start=end-7d \
VDEF:Last=kw,LAST \
VDEF:First=kw,FIRST \
VDEF:Min=kw,MINIMUM \
VDEF:Peak=kw,MAXIMUM \
VDEF:Average=kw,AVERAGE \
CDEF:kWh=kw,1,/,168,* \
CDEF:Cost=kWh,.0665,* \
SHIFT:Power2:604800 \
LINE1:Power2#00CF00FF:"Last Week\\n" \
HRULE:Min#58FAF4:"Min    " \
GPRINT:kw:MIN:"%6.4lf%sKW" \
COMMENT:"\\n" \
LINE1:kw#005199FF:"Power  " \
AREA:kw#00519933:"" \
GPRINT:Last:"%6.4lf%sKW" \
COMMENT:"\\n" \
HRULE:Average#9595FF:"Average" \
GPRINT:kw:AVERAGE:"%6.4lf%sKW" \
COMMENT:"\\n" \
HRULE:Peak#ff0000:"Peak   " \
GPRINT:kw:MAX:"%6.3lf%sKW" \
COMMENT:"\\n" \
GPRINT:kWh:AVERAGE:"  total    %6.4lfkWh\\n" \
GPRINT:Cost:AVERAGE:"  cost     %6.2lf $\\n" \
GPRINT:Cost:AVERAGE:"$(printf \\" cost %11s\\" $%.2lf | sed 's/\$/\$ /g')\\n" \
COMMENT:" \\n" \