# $Id$

class ganglia::monitor {
  $ganglia-monitor-conf = $kernel ? {
    "FreeBSD" => "/usr/local/etc/ganglia/gmond.conf",
      default => "/etc/ganglia/gmond.conf"
  }
  $package = $kernel ? {
    "FreeBSD" => "ganglia-monitor-core",
      default => "ganglia-monitor",
  }
  package{"${package}":
    ensure => "latest",
	   before => [ Service["ganglia-monitor"], File["${ganglia-monitor-conf}"] ],
  }      
  service{"ganglia-monitor":
    ensure => "running",
	   enable => "true",
	   pattern => "gmond",
	   subscribe => File["${ganglia-monitor-conf}"]
  }
  file{"${ganglia-monitor.conf}":
    content => template("ganglia/ganglia-monitor-conf.erb"),
  }      
}
