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
FAN=$(echo "${INF}" | awk '/Fanspeed:/{sub(/%/,"",$2); print $2}')

${GMETRIC} --name="Sensors GPU Temp" --type=uint32 --units="degrees C" --value=${TEMP}
${GMETRIC} --name="Sensors GPU Fanspeed" --type=float --units="%" --value=${FAN}