#!/bin/bash
# $Id$
# 2010 - udo.waechter@uni-osnabrueck.de
# This script removes obsolete (>90 days) RRD files from the meta server
BDIR="/var/lib/ganglia/rrds"
all=0
exp=0
for RRD in $BDIR/*/*.rrd; do
ninety=$(( $(date +"%s") - 7776000 ))
last=$(rrdtool last "${RRD}")
all=$(( $all + 1))
if [ $last -lt $ninety ]; then
	echo "Expired ${RRD}"
	exp=$(( $exp + 1))
	rm "${RRD}"
fi
done
#remove empty dirs and files
find $BDIR -empty
echo "ALL: $all, EXPIRED: $exp"
if [ $exp -gt 0 ]; then
    /etc/init.d/gmetad restart
fi