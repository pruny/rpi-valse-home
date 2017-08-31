#!/bin/bash

run_dir="/root/files/temperature_actions"
config_file=${run_dir}"/config"
#input_file="/var/www/files/data/TMPFS/temp.values"
input_file=${run_dir}"/temp.values"

/bin/cat /var/www/files/data/TMPFS/temp.values

line_number=1
while read line
do
	current_temp=${line:17:3}
	current_config=$(cat ${config_file} | grep -v '^#' |head -n${line_number} |tail -n1)
	min_temp=$(echo ${current_config} |awk '{print $1}')
	max_temp=$(echo ${current_config} |awk '{print $2}')
	output_pin=$(echo ${current_config} |awk '{print $3}')
	output_state=$(echo ${current_config} |awk '{print $4}')
	
	echo $current_temp
	echo $current_config

	if (( ${current_temp}>=${min_temp} &&  ${current_temp}<=${max_temp} ))
	then
		echo OUTPUT: ${output_pin} ${output_state}
		/usr/local/bin/gpio write  ${output_pin} ${output_state}
	else
		echo OUTPUT: ${output_pin} $((${output_state}^1))
		/usr/local/bin/gpio write ${output_pin} $((${output_state}^1))
	fi
	
	line_number=$(( ${line_number}+1 ))
done < ${input_file}
