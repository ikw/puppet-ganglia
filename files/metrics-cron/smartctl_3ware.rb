#!/usr/bin/env ruby
#
smartctl = %x{which smartctl}.chomp
tw_cli = %x{which tw_cli}.chomp
gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0

gmetric = "#{gmetric} --dmax=30000 --tmax=1800 --units=\"degrees C\" --type=uint16 --slope=positive"
if smartctl != "" and tw_cli != ""
  
  %x{ls /dev/tw*}.chomp.split(/\n/).each{ |tw|
    da=0
    controller=tw.match(/[0-9]+/)[0]
    numdevs = %x{tw_cli /c#{controller} show 2>/dev/null |grep -e '^p.'|grep -v NOT-PRESENT |wc -l}.chomp.to_i
    if numdevs > 0
      (numdevs-1).to_i.downto(0).each { |dev|
        #temp = %x{#{smartctl} -d 3ware,#{dev} -A #{tw}|grep -v Airflow |grep Temperature}.chomp.split(" ")[9]
        %x{#{smartctl} -d 3ware,#{dev} -A #{tw}}.chomp.each { |line|
          vals = line.split(" ")
          if line =~ /Temperature_Celsius/
            %x{#{gmetric} --name="Sensors HDD Temp tw_c#{dev}_p#{da}" --value=#{vals[9]}}
          elsif line =~ /Current_Pending_Sector/
            %x{#{gmetric} --name="Sensors HDD Current Pending Sector tw_c#{dev}_p#{da}" --value=#{vals[9]}}
          elsif line =~ /Offline_Uncorrectable/
            %x{#{gmetric} --name="Sensors HDD Offline Uncorrectable tw_c#{dev}_p#{da}" --value=#{vals[9]}}
          elsif line =~ /UDMA_CRC_Error_Count/
            %x{#{gmetric} --name="Sensors HDD UDMA CRC Error tw_c#{dev}_p#{da}" --value=#{vals[9]}}
          end
        }
        da = da.next
      }
    end
  }
end
