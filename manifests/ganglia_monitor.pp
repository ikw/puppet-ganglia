# $Id$

class ganglia::monitor {
  $ganglia_monitor_conf = $kernel ? {
    "FreeBSD" => "/usr/local/etc/ganglia/gmond.conf",
      default => "/etc/ganglia/gmond.conf"
  }
  $package = $kernel ? {
    "FreeBSD" => "ganglia-monitor-core",
      default => "ganglia-monitor",
  }
  package{["libganglia1", "${package}"]:
    ensure => "3.1.2-ikw-1",
	   before => [ Service["ganglia-monitor"], File["${ganglia_monitor_conf}"] ],
  }      
  service{"ganglia-monitor":
    ensure => "running",
	   enable => "true",
	   pattern => "gmond",
	   subscribe => File["${ganglia_monitor_conf}"],
	   require => Package["${package}"],
  }
  file{"${ganglia_monitor_conf}":
    content => template("ganglia/ganglia-monitor-conf.erb"),
	    require => Package["${package}"],
  }      
}
