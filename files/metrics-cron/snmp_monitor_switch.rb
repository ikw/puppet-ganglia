#!/usr/bin/env ruby
# $Id$
#
# written by udo.waechter@uni-osnabrueck.de
# (c) July 2011
#
require 'snmp'
require 'yaml'

switch_ip='10.10.10.10'
gmetric="gmetric --tmax=60 --dmax=999100 -u 'bytes/min' -t uint32"
state="/var/lib/puppet/state/snmp_bw.state"
debug=false
yaml = {}
lastrun = 0
t_delta = 1
if File.exist?(state)
	yaml = YAML.load_file(state)
	t_last = File.mtime(state)
	t_delta = (Time.now() - t_last).to_i
end
ifTable_columns = ["ifDescr", "ifInOctets", "ifOutOctets", "ifInErrors", "ifOutErrors", ]

SNMP::Manager.open(:Host => switch_ip) do |manager|
	hname="#{manager.get_value("sysName.0")}"
	gmetric2="#{gmetric} --spoof=\"#{switch_ip}:#{hname}\""
	manager.walk(ifTable_columns) do |ifDescr, ifInOctets, ifOutOctets, ifInErrors, ifOutErrors|
		desc=ifDescr.value.gsub(/\#(.)$/,'0\1').gsub(/\#/,'')
		next if desc =~ /^IP\ Interface/
		ifin=ifInOctets.value.to_i
		ifout=ifOutOctets.value.to_i
		ifine=ifInErrors.value.to_i
		ifoute=ifOutErrors.value.to_i
		if yaml.has_key?(desc)
			ifin_r=(ifin - yaml[desc][ifin].to_i) / t_delta
		        ifout_r=(ifout - yaml[desc][ifout].to_i) / t_delta
			ifine_r=(ifine - yaml[desc][ifine].to_i) / t_delta
		        ifoute_r=(ifoute - yaml[desc][ifoute].to_i) / t_delta
		else
			ifin_r=ifin % 1000
			ifout_r=ifout % 1000
			ifine_r=ifine % 1000
			ifoute_r=ifoute % 1000
		end
		gmetric_real="#{gmetric2} --name='Network #{desc} RX_octets' --value=#{ifin_r}"
		gmetric_real2="#{gmetric2} --name='Network #{desc} TX_octets' --value=#{ifout_r}"
		gmetric_real3="#{gmetric2} --name='Network #{desc} RX_errors' --value=#{ifine_r}"
		gmetric_real4="#{gmetric2} --name='Network #{desc} TX_errors' --value=#{ifoute_r}"
		if debug
			puts gmetric_real
			puts gmetric_real2
			puts gmetric_real3
			puts gmetric_real4
		end	
		%x{#{gmetric_real}}
		%x{#{gmetric_real2}}
		%x{#{gmetric_real3}}
		%x{#{gmetric_real4}}
		#end
		yaml["#{desc}"] = { 
				"ifin" => ifin, 
				"ifout" => ifout, 
				"ifine" => ifine, 
				"ifoute" => ifoute 
		}
	end
end
File.open(state,"w").write(yaml.to_yaml)
