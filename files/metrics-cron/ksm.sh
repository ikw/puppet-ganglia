#!/bin/sh
# $Id$

RD="/sys/kernel/mm/ksm"
GMETRIC=$(which gmetric)
[[ $? == 0 ]] || exit 0
for INF in pages_shared pages_sharing; do
	if [ -e $RD/$INF ]; then
		VAL=$(cat $RD/$INF)
		${GMETRIC} --dmax=300000 --slope=positive --tmax=1800 --value=${VAL} --name="ksm_${INF}" --type=int32 --units=Pages
	fi
done
