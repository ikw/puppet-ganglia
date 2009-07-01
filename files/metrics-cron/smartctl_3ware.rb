#!/usr/bin/env ruby
#
smartctl = %x{which smartctl}.chomp
tw_cli = %x{which tw_cli}.chomp
gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0

if smartctl != "" and tw_cli != ""
  da=0
%x{ls /dev/tw*}.chomp.split(/\n/).each{ |tw|
  controller=tw.match(/[0-9]+/)[0]
  numdevs = %x{tw_cli /c#{controller} show |grep -e '^p.'|grep -v NOT-PRESENT |wc -l}.chomp.to_i
  if numdevs > 0 
    (numdevs-1).to_i.downto(0).each { |dev|
      temp = %x{#{smartctl} -d 3ware,#{dev} -A #{tw}|grep -v Airflow |grep Temperature}.chomp.split(" ")[9]
    %x{#{gmetric} --dmax=30000 --tmax=1800 --units="degrees C" --name="HDDTemp da#{da}" --value=#{temp} --type=uint8}
    da = da.next
    }
  end
}
end
