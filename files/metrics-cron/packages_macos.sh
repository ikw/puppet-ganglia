#!/usr/bin/env bash
# $Id$
#
# Ganglia metric for softwareupdates on mac os x

STATEFILE="/var/tmp/packages_macos.state"
#update if state does not exist, or if older than 7 days
if [ ! -e ${STATEFILE} ] || [ $(stat -f %m -t %s ${STATEFILE}) -lt $(expr $(date '+%s') - 86400) ]; then
  nice /usr/sbin/softwareupdate --list | grep -e '^[\ ]*\*' >${STATEFILE}
fi

PKGS=$(wc -l ${STATEFILE} | awk '{print $1}')
gmetric --dmax=30000 --tmax=3600 --type=uint8 --name="Upgradeable Packages MacOSX" --value=${PKGS}
