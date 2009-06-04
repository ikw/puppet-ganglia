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
	"Darwin" => "ganglia-3.1.2-2.pkg.dmg",
	default => "ganglia-monitor",
    }

  $pathprefix = $kernel ? {
    "FreeBSD" => "/usr/local",
      default => "/usr",
  } 
  $run_as = $kernel ? {
    "Darwin" => "nobody",
      default => "ganglia",
  }
  case $kernel {
    "Linux": {
      $pack_present = $presence ? {
	"absent" => "absent",
	  default => "3.1.2-ikw-1"
      }
      package{["libganglia1", "${package}"]:
	ensure => $pack_present,
	       before => [ Service["${service}"], File["${ganglia_monitor_conf}"] ],
      }      
    }
    "Darwin": {
      pkg_deploy{"${package}": 
	before => [ Service["${service}"], File["${ganglia_monitor_conf}"] ],
      }
      file{"/Library/LaunchDaemons/${service}.plist":
	content => template("ganglia/${service}.plist.erb"),
		require => Pkg_deploy["${package}"],
      }      
      darwin_firewall{"any":
	port => "8649",
	     ensure => $presence,
      }
    }
    default: {
	       package{"${package}":
		 before => [ Service["${service}"], 
			File["${ganglia_monitor_conf}"] ],
			ensure => $presence,
	       }
	     }
  }  
  case $kernel {
    "Linux": {
      file{"/etc/init.d/ganglia-monitor":
	source => "puppet:///ganglia/gmond-init",
	       notify => Service["${service}"],
	       before => Service["${service}"],
      }          
    }
  }
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
	   require => $kernel ? {
	     "Darwin" => Pkg_deploy["${package}"],
	     default => Package["${package}"],
	   }
  }
  file{"${ganglia_mconf_dir}":
    ensure => "directory",
  }
  file {"${ganglia_mconf_dir}/conf.d":
    ensure => "directory",
	   require => File["${ganglia_mconf_dir}"]
  } 
  $interface = $kernel ? {
    "FreeBSD" => "",
      "Darwin" => "en0",
      default => "eth0"
  }
  file{"${ganglia_monitor_conf}":
    content => template("ganglia/ganglia-monitor-conf.erb"),
	    require => $kernel ? {
	      "Darwin" => [ 
		File["${ganglia_mconf_dir}"], 
	      Pkg_deploy["${package}"] 
		],
	      default => [ 
		File["${ganglia_mconf_dir}"],  
	      Package["${package}"] 
		],
	    }
  }
  @@file{"${ganglia_metacollects}/meta-cluster-${fqdn}":
    tag => "ganglia_gmond_cluster_${ganglia_mcast_port}",
	ensure => $presence,
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
  monit::process{"gmond":
    start => "/etc/init.d/ganglia-monitor start",
	  stop => "/etc/init.d/ganglia-monitor stop",
	  ensure => $presence,
  }
}

class ganglia::monitor::none {
  $present = "absent"
    include ganglia::monitor 
}
