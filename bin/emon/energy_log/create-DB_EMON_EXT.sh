#!/bin/bash

<<"COMMENT"
 This sets up an RRD called EMON_EXT.rrd which accepts one value every 10 seconds.
 If no new data is supplied for more than 20 seconds, the value becomes *UNKNOWN*.
--------------------------------------------------------------------------------------------------
 data sources: DS=47
--------------------------------------------------------------------------------------------------
 8 general inputs:
	V1=voltage on L1: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V2=voltage on L2: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V3=voltage on L3: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V0=voltage on N: minimum is 0 and the maximum is 400  [V] (measured between neutral and ground)
	I1=current on L1: minimum is 0 and the maximum is 100 [A]
	I2=current on L2: minimum is 0 and the maximum is 100 [A]
	I3=current on L3: minimum is 0 and the maximum is 100 [A]
	Ptot=total power: minimum is 0 and the maximum is 50  [kW]
--------------------------------------------------------------------------------------------------
 16 inputs from "corp A" (new building)
	V1a=voltage on L1: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V2a=voltage on L2: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V3a=voltage on L3: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	I1a1=current on L1: minimum is 0 and the maximum is 30 [A]
	I1a2=current on L1: minimum is 0 and the maximum is 30 [A]
	I1a3=current on L1: minimum is 0 and the maximum is 30 [A]
	I2a1=current on L2: minimum is 0 and the maximum is 30 [A]
	I2a2=current on L2: minimum is 0 and the maximum is 30 [A]
	I2a3=current on L2: minimum is 0 and the maximum is 30 [A]
	I3a1=current on L3: minimum is 0 and the maximum is 30 [A]
	I3a2=current on L3: minimum is 0 and the maximum is 30 [A]
	I3a3=current on L3: minimum is 0 and the maximum is 30 [A]
	Pa1=power: minimum is 0 and the maximum is 20          [kW]
	Pa2=power: minimum is 0 and the maximum is 20          [kW]
	Pa3=power: minimum is 0 and the maximum is 20          [kW]
	Patot=power: minimum is 0 and the maximum is 20        [kW]
--------------------------------------------------------------------------------------------------
 16 inputs from "corp B" (old building)
	V1b=voltage on L1: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V2b=voltage on L2: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V3b=voltage on L3: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	I1b1=current on L1: minimum is 0 and the maximum is 30 [A]
	I1b2=current on L1: minimum is 0 and the maximum is 30 [A]
	I1b3=current on L1: minimum is 0 and the maximum is 30 [A]
	I2b1=current on L2: minimum is 0 and the maximum is 30 [A]
	I2b2=current on L2: minimum is 0 and the maximum is 30 [A]
	I2b3=current on L2: minimum is 0 and the maximum is 30 [A]
	I3b1=current on L3: minimum is 0 and the maximum is 30 [A]
	I3b2=current on L3: minimum is 0 and the maximum is 30 [A]
	I3b3=current on L3: minimum is 0 and the maximum is 30 [A]
	Pb1=power: minimum is 0 and the maximum is 20          [kW]
	Pb2=power: minimum is 0 and the maximum is 20          [kW]
	Pb3=power: minimum is 0 and the maximum is 20          [kW]
	Pbtot=power: minimum is 0 and the maximum is 20        [kW]
--------------------------------------------------------------------------------------------------
 7 inputs from "corp C" (workshop)
	V1c=voltage on L1: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V2c=voltage on L2: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	V3c=voltage on L3: minimum is 0 and the maximum is 400 [V] (measured between line and neutral)
	I1c=current on L1: minimum is 0 and the maximum is 30  [A]
	I2c=current on L2: minimum is 0 and the maximum is 30  [A]
	I3c=current on L3: minimum is 0 and the maximum is 30  [A]
	Pa=power: minimum is 0 and the maximum is 20           [kW]
--------------------------------------------------------------------------------------------------
 samples rate = 10 seconds -> 1 PDP
 1 min= 6 PDPs; 1hour=360 PDPs 
--------------------------------------------------------------------------------------------------
 archives: RRA=5
--------------------------------------------------------------------------------------------------
	H	width: 3h	average: 1m	1080 PDPs
	D	width: 30h	average: 5m	2160 PDPs
	W	width: 9d	average: 15m	5184 PDPs
	M	width: 35d	average: 30m	10080 PDPs	
	Y	width: 400d	average: 1h	57600 PDPs
--------------------------------------------------------------------------------------------------
COMMENT

rpi-rw

rrdtool create EMON_EXT.rrd \
--start now --step 10 \
DS:V1:GAUGE:20:0:400 \
DS:V2:GAUGE:20:0:400 \
DS:V3:GAUGE:20:0:400 \
DS:v0:GAUGE:20:0:400 \
DS:I1:GAUGE:20:0:100 \
DS:I2:GAUGE:20:0:100 \
DS:I3:GAUGE:20:0:100 \
DS:Ptot:GAUGE:20:0:50 \
DS:V1a:GAUGE:20:0:400 \
DS:V2a:GAUGE:20:0:400 \
DS:V3a:GAUGE:20:0:400 \
DS:I1a1:GAUGE:20:0:30 \
DS:I1a2:GAUGE:20:0:30 \
DS:I1a3:GAUGE:20:0:30 \
DS:I2a1:GAUGE:20:0:30 \
DS:I2a2:GAUGE:20:0:30 \
DS:I2a3:GAUGE:20:0:30 \
DS:I3a1:GAUGE:20:0:30 \
DS:I3a2:GAUGE:20:0:30 \
DS:I3a3:GAUGE:20:0:30 \
DS:Pa1:GAUGE:20:0:20 \
DS:Pa2:GAUGE:20:0:20 \
DS:Pa3:GAUGE:20:0:20 \
DS:Patot:GAUGE:20:0:20 \
DS:V1b:GAUGE:20:0:400 \
DS:V2b:GAUGE:20:0:400 \
DS:V3b:GAUGE:20:0:400 \
DS:I1b1:GAUGE:20:0:30 \
DS:I1b2:GAUGE:20:0:30 \
DS:I1b3:GAUGE:20:0:30 \
DS:I2b1:GAUGE:20:0:30 \
DS:I2b2:GAUGE:20:0:30 \
DS:I2b3:GAUGE:20:0:30 \
DS:I3b1:GAUGE:20:0:30 \
DS:I3b2:GAUGE:20:0:30 \
DS:I3b3:GAUGE:20:0:30 \
DS:Pb1:GAUGE:20:0:20 \
DS:Pb2:GAUGE:20:0:20 \
DS:Pb3:GAUGE:20:0:20 \
DS:Pbtot:GAUGE:20:0:20 \
DS:V1c:GAUGE:20:0:400 \
DS:V2c:GAUGE:20:0:400 \
DS:V3c:GAUGE:20:0:400 \
DS:I1c:GAUGE:20:0:30 \
DS:I2c:GAUGE:20:0:30 \
DS:I3c:GAUGE:20:0:30 \
DS:Pctot:GAUGE:20:0:20 \
RRA:AVERAGE:0.5:1m:1080 \
RRA:AVERAGE:0.5:5m:2160 \
RRA:AVERAGE:0.5:15m:5184 \
RRA:AVERAGE:0.5:30m:10080 \
RRA:AVERAGE:0.5:1h:57600
