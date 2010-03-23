#!/usr/bin/env ruby
# $Id$
#
require 'facter'
require 'fileutils'

#exit if we already have running smartctl processes
%x{pgrep smartctl}
exit 0 if $? == 0

uname = %x{uname}.chomp
smartctl = case uname
when "Darwin" then "/opt/local/sbin/smartctl"
when "FreeBSD" then "/usr/local/sbin/smartctl"
else "/usr/sbin/smartctl"
end

gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0
debug = ARGV[0] == "debug" ? true : false;
drives = Facter.value("harddrives_smartcaps")
if drives.nil?
  exit 0
end
drives = drives.split(",")

gmetric = "#{gmetric} --dmax=30000 --tmax=1800 --type=int16"

if smartctl != "" && drives.length > 0
  drives.each{ |dev|
    %x{#{smartctl} -A /dev/#{dev}}.chomp.each { |line|
      vals = line.split(" ")
      if line =~ /Temperature_Celsius/
        puts "#{gmetric} --units=\"degrees C\" --name=\"Sensors HDD Temp #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="degrees C" --name="Sensors HDD Temp #{dev}" --value=#{vals[9]}}
      elsif line =~ /Current_Pending_Sector/
        puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Current Pending Sector #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD Current Pending Sector #{dev}" --value=#{vals[9]}}
      elsif line =~ /Offline_Uncorrectable/
        puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Offline Uncorrectable #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD Offline Uncorrectable #{dev}" --value=#{vals[9]}}
      elsif line =~ /UDMA_CRC_Error_Count/
        puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD UDMA CRC Error #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD UDMA CRC Error #{dev}" --value=#{vals[9]}}
      end
    }
  }
end
