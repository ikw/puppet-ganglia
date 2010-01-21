#!/usr/bin/env ruby
# $Id$
#
require 'fileutils'

#exit if we already have running smartctl processes
%x{pgrep smartctl}
exit 0 if $? == 0

### pid file handling
fname=File.basename($0)
pidfile="/var/run/#{fname}.pid"
exit 0 if File.exist?(pidfile)
pid=Process.pid
File.open(pidfile,"w") { |f| f.write(pid) }
##

uname = %x{uname}.chomp
smartctl = case uname
when "Darwin" then "/opt/local/sbin/smartctl"
when "FreeBSD" then "/usr/local/sbin/smartctl"
else "/usr/sbin/smartctl"
end

gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0
debug = ARGV[1] == "debug" ? true : false;

gmetric = "#{gmetric} --dmax=30000 --tmax=1800 --type=uint16 --slope=positive"
if smartctl != ""
  %x{ls /dev/sg*}.chomp.split(/\n/).each{ |dev|
    %x{#{smartctl} -d sat -c -q silent #{dev}}
    next if $?.exitstatus != 0
    dv = File.basename(dev)
    %x{#{smartctl} -d sat -A #{dev}}.chomp.each { |line|
      vals = line.split(" ")
      if line =~ /Temperature_Celsius/
        #puts "#{gmetric} --units=\"degrees C\" --name=\"Sensors HDD Temp #{dv}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="degrees C" --name="Sensors HDD Temp #{dv}" --value=#{vals[9]}}
      elsif line =~ /Current_Pending_Sector/
        #puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Current Pending Sector #{dv}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD Current Pending Sector #{dv}" --value=#{vals[9]}}
      elsif line =~ /Offline_Uncorrectable/
        #puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Offline Uncorrectable #{dv}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD Offline Uncorrectable #{dv}" --value=#{vals[9]}}
      elsif line =~ /UDMA_CRC_Error_Count/
        #puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD UDMA CRC Error #{dv}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD UDMA CRC Error #{dv}" --value=#{vals[9]}}
      end
    }
  }
end
## remove pid
FileUtils.remove(pidfile)