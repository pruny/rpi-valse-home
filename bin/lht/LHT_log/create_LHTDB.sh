#!/bin/bash

#This sets up an RRD called LHT.rrd which accepts one value every 60/10 seconds.
#If no new data is supplied for more than 120/20 seconds, the value becomes *UNKNOWN*.
#
#DS=6:
#  data sources:
#	a=illuminance: minimum is 0 and the maximum is 9999 [lux]
#	b=temperature: minimum is -40 and the maximum is 80 [°C]
#	c=dew point: minimum is -40 and the maximum is 80 [°C]
#	d=humidity (raw): minimum is 0 and the maximum is 100 [%RH]
#	e=humidity (comp): minimum is 0 and the maximum is 100 [%RH]
#	f=vapor pressure: minimum is  0 and the maximum is 100 [mmHg]
#samples rate = 60/10 seconds -> 1 PDP
#1hour=60/360 PDPs
#
#RRA=5
#  archives:
#	H	width: 3h	average: 1m
#	D	width: 30h	average: 5m
#	W	width: 9d	average: 15m
#	M	width: 35d	average: 30m	
#	Y	width: 400d	average: 1h
#

<<"COMMENT"

RRD="/home/pi/data/shared/lht/LHT.rrd"

rrdtool create $RRD \
--start now --step 60 \
DS:a:GAUGE:120:0:9999 \
DS:b:GAUGE:120:-40:80 \
DS:c:GAUGE:120:-40:80 \
DS:d:GAUGE:120:0:100 \
DS:e:GAUGE:120:0:100 \
DS:f:GAUGE:120:0:100 \
RRA:AVERAGE:0.5:1m:180 \
RRA:AVERAGE:0.5:5m:360 \
RRA:AVERAGE:0.5:15m:864 \
RRA:AVERAGE:0.5:30m:1680 \
RRA:AVERAGE:0.5:1h:9600

COMMENT

rrdtool create LHT.rrd \
--start now --step 10 \
DS:a:GAUGE:20:0:9999 \
DS:b:GAUGE:20:-40:80 \
DS:c:GAUGE:20:-40:80 \
DS:d:GAUGE:20:0:100 \
DS:e:GAUGE:20:0:100 \
DS:f:GAUGE:20:0:100 \
RRA:AVERAGE:0.5:1m:1080 \
RRA:AVERAGE:0.5:5m:2160 \
RRA:AVERAGE:0.5:15m:5184 \
RRA:AVERAGE:0.5:30m:10080 \
RRA:AVERAGE:0.5:1h:57600
