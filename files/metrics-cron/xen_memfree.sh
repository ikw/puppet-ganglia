#!/bin/sh
# show free memory on dom0

XM=$(which xm)
GMETRIC=$(which gmetric)

[[ -x ${XM} ]] || exit 0
[[ -x ${GMETRIC} ]] || exit 0

MEM=$(xm info |grep free_memory|awk '{print $3}')

${GMETRIC} --dmax=30000 --type=uint32 --slope=positive --tmax=1800 --name="XEN free memory" -u Megabytes --value=${MEM}