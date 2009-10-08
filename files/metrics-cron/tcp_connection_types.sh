#!/usr/bin/env bash
CLIENT=`which gmetric`
[[ -x $CLIENT ]] || exit 0
NETSTAT=`which netstat`
[[ -x $NETSTAT ]] || exit 0
NETSTAT=`${NETSTAT} -t -n`
VALUE=$(echo "$NETSTAT"|egrep "ESTABLISHED"|wc -l)
$CLIENT --dmax=30000 --tmax=300 --units=Connections -t uint16 --slope=positive -n TCP_ESTABLISHED -v $VALUE
VALUE=$(echo "$NETSTAT"|egrep "CLOSE_WAIT"|wc -l)
$CLIENT --dmax=30000 --tmax=300 --units=Connections -t uint16 --slope=positive -n TCP_CLOSE_WAIT -v $VALUE
VALUE=$(echo "$NETSTAT"|egrep "TIME_WAIT"|wc -l)
$CLIENT --dmax=30000 --tmax=300 --units=Connections -t uint16 --slope=positive -n TCP_TIME_WAIT -v $VALUE
