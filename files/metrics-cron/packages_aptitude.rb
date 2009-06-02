#!/usr/bin/ruby
# $Id$!
## monitor package upgades for aptitude

statefile="/var/tmp/packages_aptitude.state"

if (! File.exist?(statefile)) || (File.mtime(statefile).to_i < (Time.new.to_i - 172800)) || File.size(statefile) == 0
  ## upgrade the statefile
apt = %x{apt-get -u dist-upgrade --print-uris --yes -s |grep -e '^Inst' 2>/dev/null}
  results={}
apt.each_line { |line|
  match = line.chomp.match('Inst.*\(.*\/(.*)\)')
  if match.nil?
      match = "other"
  else
      match = match[1] 
  end
  if results.has_key?(match)
    results[match] = results[match].succ
  else
    results[match] = 1
  end
}
file = File.open(statefile,'w')
results.each_pair { |key,value|
  file.puts("#{key}:#{value}")
}
file.close
end 

File.open(statefile,'r').each { |line|
  keyval = line.chomp.split(":")
  %x{gmetric --dmax=30000 --tmax=3600 --type=uint16 --name="Upgradeable Packages #{keyval[0]}" --value=#{keyval[1]}}
}
