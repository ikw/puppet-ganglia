#!/bin/sh
# $Id$
# show nvidia card sensors

GMETRIC=$(which gmetric)
NVC=$(which nvclock)

[[ -x ${GMETRIC} ]] || exit 0
[[ -x ${NVC} ]] || exit 0

GMETRIC="${GMETRIC} --dmax=30000 --slope=positive --tmax=1800"

INF=$(nvclock -i)

TEMP=$(echo "${INF}" | awk '/GPU temperature:/{sub(/C/,"",$3); print $3}')
BTEMP=$(echo "${INF}" | awk '/Board temperature:/{sub(/C/,"",$3); print $3}')
FAN=$(echo "${INF}" | awk '/Fanspeed:/{sub(/%/,"",$2); print $2}')
if [ $(echo "${INF}" |grep Fanspeed: |grep -c RPM) -eq 1 ]; then
		UNITS="RPM"
else
	UNITS="%"
fi

${GMETRIC} --name="Sensors GPU Temp" --type=uint32 --units="degrees C" --value=${TEMP}
[[ "X${BTEMP}" == "X" ]] || ${GMETRIC} --name="Sensors GPU Board Temp" --type=uint32 --units="degrees C" --value=${BTEMP}
${GMETRIC} --name="Sensors GPU Fanspeed" --type=float --units=${UNITS} --value=${FAN}