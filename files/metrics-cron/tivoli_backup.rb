#!/usr/bin/env ruby
# $Id$
#
# Ganglia metric for tivoli backup statistics

gmetric=%x{which gmetric}.chomp
exit 1 if $?.exitstatus != 0

gmetric="#{gmetric} --type=float --dmax=99999 --tmax=60 --slope=positive"

logs=["/var/log/dsmsched.log", "/var/log/dsmsched.backuppc.log" ]

logs.each do |log|
  if (File.exist?(log) && File.readable?(log))
    label=File.basename(log)
    %x{tail -13 /var/log/dsmsched.log |grep Total |sed -e 's/,//g' -e 's/ MB//' -e 's/bytes/MB/' -e 's/Total number of //g'}.chomp.each do |line|
      nam=line.split(":")
      #puts "#{gmetric} --name=\"Tivoli #{label} #{nam[0].lstrip.rstrip}\" --value=#{nam[1].lstrip.rstrip}"
      %x{#{gmetric} --name=\"Tivoli #{label} #{nam[0].lstrip.rstrip}\" --value=#{nam[1].lstrip.rstrip.to_i}}
    end
  end
end
