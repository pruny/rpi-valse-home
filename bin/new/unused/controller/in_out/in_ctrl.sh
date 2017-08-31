#!/bin/bash

# this script controls the output state depending on the input state
# switching thresholds is a step-function (NORMAL input state is LOW)
#
#		  >>>>>>>>>>>
#                 v
#                 v
#                 v
#                 v
#                 v
#                 v
#                 v
#                 v
# INPUT >>>>>>>>>>>
#
#  


run_dir="/root/files/controller/in_out/"
config_file=${run_dir}"in.config"

while read line
do

	if [ ${line:0:1} = "#" ]
	then
		continue
	fi

# setup values (from config file)
	input_pin=$(echo $line |awk '{print $1}')
	input_value=$(echo $line |awk '{print $2}')
	output_pin=$(echo $line |awk '{print $3}')
	output_value=$(echo $line |awk '{print $4}')
# current values (from sensors)
	current_value=$(gpio read ${input_pin})

	echo ""
	echo "INPUT#"${input_pin}"_STATE: "$current_value

	if [ $current_value != $input_value ]
	  then
	    echo "GPIO#"$output_pin"_STATE: "$((${output_value}^1)) " -> ACTION"
	    gpio write $output_pin $((${output_value}^1)) # output abnormal state (LOW) - ACTION
	  else
	    echo "GPIO#"$output_pin"_STATE: "${output_value} " -> IDLE"
	    gpio write $output_pin $output_value # output normal state (HIGH) - IDLE
	fi
done <${config_file}
