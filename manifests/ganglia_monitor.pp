# $Id$
# Writtenby: udo.waechter@uni-osnabrueck.de
#
# _Class:_ ganglia::monitor
# 
# Enables and installs the monitor daemond gmon.
#
# This module was tested with Debian (Etch/Lenny), Ubuntu (Hardy/Intrepid),
# Mac OS X Leopard and FreeBSD 7.
#
# _Parameters:_
#
# _Actions:_
#   Installs the ganglia-monitor package and configures it.
#
# _Requires:_
#   
# _Sample Usage:_
#   +include ganglia::monitor+
#
class ganglia::monitor {
  $presence = $present ? {
    "absent" => "absent",
      default => "present"
  }
  $ganglia_monitor_conf = "${ganglia_mconf_dir}/gmond.conf"
    $package = $kernel ? {
      "FreeBSD" => "ganglia-monitor-core",
	"Darwin" => "ganglia",
	default => "ganglia-monitor"
    }

  $pathprefix = $kernel ? {
    "FreeBSD" => "/usr/local",
      "Darwin" => "/opt/local",
      default => "/usr"
  } 
  $run_as = $kernel ? {
    "Darwin" => "nobody",
      default => "ganglia"
  }
  $pack_present = $presence ? {
    "absent" => "absent",
      default => $kernel ? {
	"Linux" => $lsbdistcodename ? {
	  "Lenny" => "3.1.7-1+b1",
	  default => "latest",
	},
	default => $presence
      },
  }
  package{"${package}":
    before => [ Service["${service}"], 
	   File["${ganglia_monitor_conf}"] ],
	   ensure => $presence,
  }

  case $kernel {
    "Linux": {
      file{"/etc/init.d/ganglia-monitor":
	source => "puppet:///ganglia/gmond-init",
	       notify => Service["${service}"],
	       before => Service["${service}"],
      }  

      package{"libganglia1":
	ensure => $pack_present,
	       before => [ Service["${service}"], File["${ganglia_monitor_conf}"], Package["${package}"] ],
      }      

      package{"ganglia-module-iostat":
	ensure => $presence,
	       notify => Service["${service}"],
	       require => Package["${package}"],
      }
      file {"${ganglia_mconf_dir}/conf.d/iostat.conf":
	source => "puppet:///ganglia/mod_iostat.conf",
	       ensure => $presence,
	       notify => Service["${service}"],
      }
    }      
    "Darwin": {
      darwin_firewall{"any":
	port => "8649",
	     ensure => $presence,
      }
    }
  }  
#### configure the service daemon
  $running = $presence ? {
    "absent" => "stopped",
      default => "running"
  }
  $enabled = $presence ? {
    "absent" => "false",
      default => "true"
  }

  service{"${service}":
    ensure => "${running}",
	   enable => "${enabled}",
	   pattern => "gmond",
	   subscribe => File["${ganglia_monitor_conf}"],
	   require => Package["${package}"],
  }

  file{"${ganglia_mconf_dir}":
    ensure => "directory",
  }
  file {"${ganglia_mconf_dir}/conf.d":
    ensure => "directory",
	   require => File["${ganglia_mconf_dir}"]
  }
  debug("${fqdn} should ${package} have ${presence} / running: ${running} / enable: ${enabled} / conf: ${ganglia_monitor_conf}") 
    file{"${ganglia_monitor_conf}":
      content => template("ganglia/ganglia-monitor-conf.erb"),
	      require =>  [ File["${ganglia_mconf_dir}"],  
	      Package["${package}"] ],
    }
  @@file{"${ganglia_metacollects}/meta-cluster-${fqdn}":
    tag => "ganglia_gmond_cluster_${ganglia_mcast_port}",
	ensure => $presence,
	group => "root",
	notify => Exec["generate-metadconf"],
	content => template("ganglia/ganglia-datasource-cluster.erb"),
  }   

# metrics configuration
  file{"${ganglia_metrics}":
    ensure => "directory",
	   owner => "root",
	   mode => 0700
  }
  file{"${ganglia_metrics}/run-metrics.sh":
    source => "puppet:///ganglia/run-metrics.sh",
	   mode => 0700,
	   owner => root,
	   require => File["${ganglia_metrics}"],
  }

## monitoring 
  monit::process{"gmond":
    start => "/etc/init.d/ganglia-monitor start",
	  stop => "/etc/init.d/ganglia-monitor stop",
	  ensure => $presence,
  }

  nagios2_service { "${fqdn}_mem_percent_ganglia":
    service_description => "mem_percent_ganglia",
			check_command => "check_ganglia!mem_percent_ganglia!15!30!${ganglia_metaserver_ip}",
			servicegroups => "Memory",
			notification_options => "c,u",
			ensure => "absent", 
#defined(Class["Ganglia::Monitor::None"]) ? {
#  true => "absent",
#  default => $kernel ? {
#    "Darwin" => "absent",
#    default => "${presence}", 
#  }
#},
  }
  case $kernel {
    "Darwin": {
#/Library/LaunchDaemons/de.ikw.uos.gmond.plist
      file{"/Library/LaunchDaemons/de.ikw.uos.gmond.plist":
	content => template("ganglia/de.ikw.uos.gmond.plist.erb")
      }
      service{"de.ikw.uos.gmond":
	ensure => stopped,
	       enable => false,
	       require => File["/Library/LaunchDaemons/de.ikw.uos.gmond.plist"],
      }
      file{[
	"/usr/bin/ganglia-config",
	  "/usr/bin/gstat",
	  "/usr/bin/gmetric",
	  "/etc/ganglia/",
	  "/usr/include/ganglia.h",
	  "/usr/include/ganglia_gexec.h",
	  "/usr/include/gm_metric.h",
	  "/usr/include/gm_mmn.h",
	  "/usr/include/gm_msg.h",
	  "/usr/include/gm_protocol.h",
	  "/usr/include/gm_value.h",
	  "/usr/lib/ganglia",
	  "/usr/lib/libganglia-3.1.2.0.0.0.dylib",
	  "/usr/lib/libganglia-3.1.2.0.dylib",
	  "/usr/lib/libganglia.a",
	  "/usr/lib/libganglia.dylib",
	  "/usr/lib/libganglia.la",
	  "/usr/sbin/gmond"
	    ]:
	    ensure => "absent",
	  backup => false,
	  recurse => true,
	  force => true,
      }
    }
  }
}

class ganglia::monitor::none {
  $present = "absent"
    include ganglia::monitor
}
