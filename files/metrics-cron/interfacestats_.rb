#!/usr/bin/env ruby
# $Id$
#
#use bwm-ng to measure interface stats
# written by udo.waechter@uni-osnabrueck.de in Juli 2011
# if you find it, you can keep it!
#
#CSV output:
# unix timestamp;iface_name;bytes_out/s;bytes_in/s;bytes_total/s;bytes_in;bytes_out;packets_out/s;packets_in/s;packets_total/s;packets_in;packets_out;errors_out/s;errors_in/s;errors_in;errors_out\n
#1311330527;intern0;33180.00;65596.00;91760.00;52.00;54.00;106.00;0.00;0.00
g_metric=%x{which gmetric}.chomp
exit 0 if $?.exitstatus != 0
iface = $0.gsub(/.*_(.*)\.rb$/, '\1')
exit 0 if (iface.nil?  or  iface == "")
debug=false

stats=%x{bwm-ng -o csv -c 2 -T max -I #{iface} |grep -v ';total;'|tail -1}.chomp
(time, iface, bout_s, bin_s, b_tot, bin, bou, pin_s, pout_s, ptot_s, pin, pout, eout_s, ein_s, ein, eout) = stats.split(";")
g_metric = "#{g_metric} --dmax=9999999 --type=uint32 --tmax=300"

%x{#{g_metric} --value=#{bout_s.to_i} --units='bytes/s' --name='Network #{iface}_TX_bytes'}
%x{#{g_metric} --value=#{bin_s.to_i} --units='bytes/s' --name='Network #{iface}_RX_bytes'}
%x{#{g_metric} --value=#{pin_s.to_i} --units='packets/s' --name='Network #{iface}_RX_packets'}
%x{#{g_metric} --value=#{pout_s.to_i} --units='packets/s' --name='Network #{iface}_TX_packets'}
%x{#{g_metric} --value=#{eout.to_i} --units='errors' --name='Network #{iface}_TX_errors'}
%x{#{g_metric} --value=#{eout.to_i} --units='errors' --name='Network #{iface}_RX_errors'}

if debug 
    puts "#{g_metric} --value=#{bout_s.to_i} --units='bytes/s' --name='Network #{iface}_TX_bytes'"
    puts "#{g_metric} --value=#{bin_s.to_i} --units='bytes/s' --name='Network #{iface}_RX_bytes'"
    puts "#{g_metric} --value=#{pin_s.to_i} --units='packets/s' --name='Network #{iface}_RX_packets'"
    puts "#{g_metric} --value=#{pout_s.to_i} --units='packets/s' --name='Network #{iface}_TX_packets'"
    puts "#{g_metric} --value=#{eout.to_i} --units='errors' --name='Network #{iface}_TX_errors'"
    puts "#{g_metric} --value=#{eout.to_i} --units='errors' --name='Network #{iface}_RX_errors'"
end
