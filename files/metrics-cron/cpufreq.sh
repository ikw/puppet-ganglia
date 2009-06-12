#!/bin/bash
# $Id$ 
# measure cpu frequency for ganglia
GMETRIC=$(which gmetric)
[[ $? == 0 ]] || exit 0
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
	for CPU in /sys/devices/system/cpu/*; do
		CURR=$(basename $CPU)
		if [ -e /sys/devices/system/cpu/${CURR}/cpufreq/scaling_cur_freq ]; then
		  VAL=$(cat /sys/devices/system/cpu/${CURR}/cpufreq/scaling_cur_freq)
		${GMETRIC} --dmax=30000 --tmax=300 --value=${VAL} --name="CPU Frequency ${CURR}" --type=int16 --units=Megahertz
        fi
	done
fi