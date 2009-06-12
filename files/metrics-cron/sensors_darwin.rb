#!/usr/bin/env ruby
# $Id$
# temperature monitoring on darwin-x86 with tempmonitor from:
# http://www.bresink.de/osx/TemperatureMonitor.html
#
# writen by udo.waechter@uos.de 2009
#

if File.exist?("/usr/local/bin/tempmonitor")
  %x{/usr/local/bin/tempmonitor -a -l |grep -v SMART}.chomp.each_line do |line|
      l=line.chomp.split(":")
      val = l[1].lstrip.split(" ")[0]
      key = l[0]
      %x{gmetric --dmax=3600 --name="Sensors #{key}" --value="#{val}" --type=float --units="degrees C" --tmax=300}
  end
end
  

