#!/bin/bash

# https://community.openenergymonitor.org/t/how-to-rrd-graph-mqtt-topic-from-devices/1679

rpi-rw

rrdtool create EMON_mqtt.rrd \
--step 3 \
DS:kw:GAUGE:5:0:U \
RRA:MIN:0.5:12:2592000 \
RRA:AVERAGE:0.5:12:2592000 \
RRA:MAX:0.5:12:2592000

mv ~/EMON_mqtt.rrd /home/pi/data/shared/emon/EMON_mqtt.rrd