#!/bin/bash

# catch of gpio-outputs  status ( put result in /root/files/catch_output/gpio.status )

pins="21 22 23 24 25 27 28 29"

for i in $pins
do
	echo -n $i " "
	/usr/local/bin/gpio read $i
done > /root/files/catch_output/gpio.status
