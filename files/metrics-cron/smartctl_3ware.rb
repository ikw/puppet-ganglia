#!/usr/bin/env ruby
#
smartctl = %x{which smartctl}.chomp
tw_cli = %x{which tw_cli}.chomp
gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0
debug = ARGV[1] == "debug" ? true : false;

gmetric = "#{gmetric} --dmax=30000 --tmax=1800 --type=uint16 --slope=positive"
if smartctl != "" and tw_cli != ""
  %x{ls /dev/tw*}.chomp.split(/\n/).each{ |tw|
    controller=tw.match(/[0-9]+/)[0]
    numdevs = %x{tw_cli /c#{controller} show 2>/dev/null |grep -e '^p.'|grep -v NOT-PRESENT |wc -l}.chomp.to_i
    if numdevs > 0
      (numdevs-1).to_i.downto(0).each { |dev|
        %x{#{smartctl} -d 3ware,#{dev} -A #{tw}}.chomp.each { |line|
          vals = line.split(" ")
          port = "tw_c#{controller}_p#{dev}"
          if line =~ /Temperature_Celsius/
            #  puts "#{gmetric} --units=\"degrees C\" --name=\"Sensors HDD Temp #{port}\" --value=#{vals[9]}" if debug
            %x{#{gmetric} --units="degrees C" --name="Sensors HDD Temp #{port}" --value=#{vals[9]}}
          elsif line =~ /Current_Pending_Sector/
            #  puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Current Pending Sector #{port}\" --value=#{vals[9]}" if debug
            %x{#{gmetric} --units="Number" --name="Sensors HDD Current Pending Sector #{port}" --value=#{vals[9]}}
          elsif line =~ /Offline_Uncorrectable/
            #  puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD Offline Uncorrectable #{port}\" --value=#{vals[9]}" if debug
            %x{#{gmetric} --units="Number" --name="Sensors HDD Offline Uncorrectable #{port}" --value=#{vals[9]}}
          elsif line =~ /UDMA_CRC_Error_Count/
            #  puts "#{gmetric} --units=\"Number\" --name=\"Sensors HDD UDMA CRC Error #{port}\" --value=#{vals[9]}" if debug
            %x{#{gmetric} --units="Number" --name="Sensors HDD UDMA CRC Error #{port}" --value=#{vals[9]}}
          end
        }
      }
    end
  }
end
