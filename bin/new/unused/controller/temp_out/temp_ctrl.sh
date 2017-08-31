#!/bin/bash

# this script controls the output state depending on the temperature read by the sensors
# switching thresholds covers a function with hysteresis
#
#   OUTPUT        Tmin      Tmax
#
#   HIGH   >>>>>>>>>>>>>>>>>>>v
#   state  <<<<<<<<<^         v
#	            ^         v
#                   ^         v
#	            ^         v
#                   ^         v
#	            ^         v
#                   ^         v
#	            ^         v
#                   ^         v>>>>>>>>>     LOW
#		    ^<<<<<<<<<<<<<<<<<<<     state
#

run_dir="/root/files/controller/temp_out/"
config_file=${run_dir}"temp.config"
input_file="/var/www/files/data/TMPFS/temp.values"

line_number=1
while read line
do

# setup values (from config file)
	min_temp=$(echo ${current_config} |awk '{print $1}')
	max_temp=$(echo ${current_config} |awk '{print $2}')
	output_pin=$(echo ${current_config} |awk '{print $3}')
	output_state=$(echo ${current_config} |awk '{print $4}')
# current values (from sensors)
	current_temp=${line:17:3}
	current_config=$(cat ${config_file} | grep -v '^#' |head -n${line_number} |tail -n1)


	echo ""
	echo "CONFIG#"${line_number} ">>>" $current_config "<<<"

	if ((${current_temp}>=${max_temp} ))
	  then
	    echo "TEMP#"${line_number} ":" $current_temp "°C   => GPIO#"${output_pin}"_STATE : "$((${output_state}^1)) " -> ACTION"
	    gpio write ${output_pin} $((${output_state}^1)) # abnormal state - ACTION
	  else
	    if (( ${current_temp}<=${min_temp}))
	      then
		echo "TEMP#"${line_number} ":" $current_temp "°C   => GPIO#"${output_pin}"_STATE : "${output_state} " -> IDLE"
		gpio write  ${output_pin} ${output_state} #normal state - IDLE
	      else
	        echo  "TEMP#"${line_number} ":" $current_temp "°C  - is in range! => GPIO#"${output_pin}" - NO change!"
	    fi
	fi

	line_number=$(( ${line_number}+1 ))
done < ${input_file}
