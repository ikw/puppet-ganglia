#!/usr/bin/env ruby
# $Id$
#
require 'facter'
exit 0 if (File.exists?("/sys/kernel/mm/ksm/run") && File.read("/sys/kernel/mm/ksm/run").chomp == "0")

gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0
debug = ARGV[0] == "debug" ? true : false;


gmetric = "#{gmetric} --dmax=30000 --tmax=1800 --type=int32"
Dir.glob("/sys/kernel/mm/ksm/pages_*").each { |file|
  fname = File.basename(file)
  value = File.read(file)
  puts "#{gmetric} --units=\"Number\" --name=\"KSM #{fname}\" --value=#{value}" if debug
  %x{#{gmetric} --units="Number" --name="KSM #{fname}" --value=#{value}}
}
