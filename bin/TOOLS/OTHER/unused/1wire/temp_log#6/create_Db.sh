#!/bin/bash

#This sets up an RRD called temp.rrd which accepts one temperature value every 60 seconds.
#If no new data is supplied for more than 120 seconds, the temperature becomes *UNKNOWN*.
#The minimum acceptable value is -40 and the maximum is 80.
#samples rate 60 seconds -> 1 minute -> 1 PDP
#1hour=60 PDPs
#
#DS=6
#H	width: 3h	average: 1m
#D	width: 30h	average: 5m
#W	width: 9d	average: 1h
#M	width: 35d	average: 1h	
#Y	width: 400d	average: 6h
#
rrdtool create Temp.rrd \
--start now --step 60 \
DS:T1:GAUGE:120:-40:80 \
DS:T2:GAUGE:120:-40:80 \
DS:T3:GAUGE:120:-40:80 \
DS:T4:GAUGE:120:-40:80 \
DS:T5:GAUGE:120:-40:80 \
DS:T6:GAUGE:120:-40:80 \
RRA:AVERAGE:0.5:1:180 \
RRA:AVERAGE:0.5:5:360 \
RRA:AVERAGE:0.5:60:216 \
RRA:AVERAGE:0.5:60:840 \
RRA:AVERAGE:0.5:360:1600
