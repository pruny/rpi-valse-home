#!/usr/bin/perl -w

# https://community.openenergymonitor.org/t/how-to-rrd-graph-mqtt-topic-from-devices/1679

open(SUB, "/usr/bin/mosquitto_sub -t /wind |");
#SUB->autoflush(1);
while ($wind = <SUB>) {
 $wind=($wind/1000);
print "$wind ";	
system("rrdtool update EMON_mqtt.rrd N:$wind");
}
