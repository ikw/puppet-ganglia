# $Id$

# ifconfig.rb - show ethernet device statistics

exit 0 if %x{uname -s}.chomp != "Linux"
gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0
netif="eth0"

ifc = %x{/sbin/ifconfig #{netif}}.chomp

gm = "#{gmetric} --type='uint32' --slope='positive' --tmax='1800' --dmax='999999'"
## loop through all lines
ifc.each_line { |line|
  line.lstrip!
  next if line !~ /^[RT]X packets/
  larr = line.split(" ")
  label = "#{netif}_#{larr[0]}_"
  larr[2..5].each { |field|
    farr = field.split(":")
    puts "#{gm} --name=#{label}#{farr[0]} --value=#{farr[1]}" if ARGV[0] == "debug"
    %x{#{gm} --name=#{label}#{farr[0]} --value=#{farr[1]}}
  }
}
