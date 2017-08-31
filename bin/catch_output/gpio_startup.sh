#!/bin/bash

# set gpio-outputs pins to last known state ( from /root/bin/catch_output/gpio.status )

while read line;
do
	gpio=$(echo $line | awk '{print $1}')
	state=$(echo $line | awk '{print $2}')
	/usr/local/bin/gpio write $gpio $state
done < /root/bin/catch_output/gpio.status
