#!/usr/bin/env ruby
# $Id$
#
# Ganglia metric for tivoli backup statistics

gmetric=%x{which gmetric}.chomp
exit 1 if $?.exitstatus != 0

gmetric="#{gmetric} --type=float --dmax=99999 --tmax=3600 --slope=positive"

logs=["/var/log/dsmsched.log", "/var/log/dsmsched.backuppc.log", "/var/log/dsmsched.net.log" ]

logs.each do |log|
    if (File.exist?(log) && File.readable?(log))
        label=File.basename(log)
        %x{tail -13 #{log} |grep Total |sed -e 's/,//g' -e 's/Total number of //g' -e 's/bytes //'}.chomp.each do |line|
            nam=line.split(":")
            nam[0].rstrip!
            nam[1].rstrip!
            nam[0].lstrip!
            nam[1].lstrip!.to_i
            if nam[1] =~ /\ .B/
                nam[0] = "MB #{nam[0]}"
                number = nam[1].split(" ")[0]
                if nam[1] =~ /\ \ B/
                    nam[1] = number.to_f / 1048576
                elsif nam[1] =~ /\ KB/
                    nam[1] = number.to_f / 1024
                elsif nam[1] =~ /\ GB/
                    nam[1] = number.to_f * 1024
                else
                    nam[1] = number.to_f
                end
            end
            puts "#{gmetric} --name=\"Tivoli #{label} #{nam[0]}\" --value=#{nam[1]}" if ARGV[0] == "debug"
            %x{#{gmetric} --name=\"Tivoli #{label} #{nam[0]}\" --value=#{nam[1]}}
        end
    end
end
