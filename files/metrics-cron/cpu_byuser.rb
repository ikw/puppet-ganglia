#!/usr/bin/env ruby1.8
# $Id$

$gmetric = %x{which gmetric}.chomp
exit 0 if $? != 0

ps = %x{ps xaeo user,pcpu,pmem,vsz,rss,time|grep -v USER}

users = {}
ps.each_line { |line|
  line.lstrip!
  larr = line.split(/\s+/)
  user = larr[0]
  cpu = larr[1].to_f
  mem = larr[2].to_f
  vsz = larr[3].to_f
  rss = larr[4].to_f

  time = larr[5]
  tarr = time.split(":")
  sec = tarr[1].to_f
  sec += tarr[0].to_f * 60

  if users[user]
    users[user]["cpu"] += cpu
    users[user]["mem"] += mem
    users[user]["vsz"] += vsz
    users[user]["time"] += sec
    users[user]["procs"] += 1
  else
    users[user] = {}
    users[user]["cpu"] = cpu
    users[user]["mem"] = mem
    users[user]["vsz"] = vsz
    users[user]["time"] = sec
    users[user]["procs"] = 1
  end
}

def gsend(name,value,units)
  gm = "#{$gmetric} -d 999999 -x 300 --type=float --name=#{name} --value=#{value} --units=#{units}"
  puts "#{gm}" if ARGV[0] == "debug"
  %x{#{gm}}
end

users.each_pair { |user,value|
  gsend("cpu_percent_#{user}",value['cpu'],"\%cpu")
  gsend("mem_percent_#{user}",value['mem'],"\%mem")
  gsend("mem_vsz_kb_#{user}",value['vsz'],"kilobytes")
  gsend("cpu_total_time_#{user}",value['time'],"seconds")
  gsend("procs_total_#{user}",value['procs'],"processes")
}