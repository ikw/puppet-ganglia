#!/usr/bin/env ruby
# $Id$
gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0

sens = %x{sysctl dev.cpu|grep temperature}
sens.each { |line|
  mtch = line.match(/dev.cpu.(\d).*:\s(\d+)/)
  %x{#{gmetric} --dmax=36000 --name="Sensors CPU #{mtch[1]}" --value="#{mtch[2]}" --type=float --tmax=300 --units="degrees C"}
}