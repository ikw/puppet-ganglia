#!/usr/bin/env bash

# read sensor data from poseidon device and send it to ganglia
#
SNMPGET="/usr/bin/snmpget -t 1 -r 5 -v 1 -c public sensor.ikw.Uni-Osnabrueck.DE:161"
 
TEMPERATUR=$($SNMPGET .1.3.6.1.4.1.21796.3.3.3.1.6.1 |awk -F : '{print $2/10}')
HUMIDITY=$($SNMPGET .1.3.6.1.4.1.21796.3.3.3.1.6.2 |awk -F : '{print $2/10}')
DOOR=$($SNMPGET .1.3.6.1.4.1.21796.3.3.1.1.2.1 |awk -F : '{print $2}')
[[ "x$DEBUG" != "x" ]] && echo "TEMP: $TEMPERATUR, HUM: $HUMIDITY, DOOR: $DOOR"
/usr/bin/gmetric -S 131.173.33.117:sensor.ikw.Uni-Osnabrueck.DE -x 300 -n Temperature -v $TEMPERATUR -t float -u Celsius
/usr/bin/gmetric -S 131.173.33.117:sensor.ikw.Uni-Osnabrueck.DE -x 300 -n Humidity -v $HUMIDITY -t float -u "% Rh"
/usr/bin/gmetric -S 131.173.33.117:sensor.ikw.Uni-Osnabrueck.DE -x 300 -n Door -v $DOOR -t int8 -u State
