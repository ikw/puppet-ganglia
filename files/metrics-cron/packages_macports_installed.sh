#!/usr/bin/env bash
# $Id$
#
# Ganglia metric for installed macports on mac os x

STATEFILE="/var/tmp/packages_macports_installed.state"
#update if state does not exist, or if older than 14 days
if [ ! -e ${STATEFILE} ] || [ $(stat -f %m -t %s ${STATEFILE}) -lt $(expr $(date '+%s') - 172800) ]; then
  nice /opt/local/bin/port list installed |wc -l |awk '{print $1}' >${STATEFILE}
fi

PKGS=$(cat ${STATEFILE})
gmetric --dmax=30000 --tmax=3600 --type=uint8 --name="Packages MacPorts installed" --value=${PKGS}
