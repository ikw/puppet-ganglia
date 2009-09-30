#!/usr/bin/env ruby
#
require 'facter'

smartctl = %x{which smartctl}.chomp
gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0
debug = ARGV[1] == "debug" ? true : false;

drives = Facter.value("harddrives_smartcaps").split(",")
gmetric = "#{gmetric} --dmax=30000 --tmax=1800 --type=int16"

if smartctl != "" && drives.length > 0
  drives.each{ |dev|
    %x{#{smartctl} -A /dev/#{dev}}.chomp.each { |line|
      vals = line.split(" ")
      if line =~ /Temperature_Celsius/
        #puts "#{gmetric} --units=\"degrees C\" --name=\"Sensors HDD Temp #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="degrees C" --name="Sensors HDD Temp #{dev}" --value=#{vals[9]}}
      elsif line =~ /Current_Pending_Sector/
        #puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Current Pending Sector #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD Current Pending Sector #{dev}" --value=#{vals[9]}}
      elsif line =~ /Offline_Uncorrectable/
        #puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Offline Uncorrectable #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD Offline Uncorrectable #{dev}" --value=#{vals[9]}}
      elsif line =~ /UDMA_CRC_Error_Count/
        #puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD UDMA CRC Error #{dev}\" --value=#{vals[9]}" if debug
        %x{#{gmetric} --units="Number" --name="Sensors HDD UDMA CRC Error #{dev}" --value=#{vals[9]}}
      end
    }
  }
end
