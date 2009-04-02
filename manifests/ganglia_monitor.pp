# $Id$

class ganglia::monitor {
  $ganglia_mconf_dir = $kernel ? {
    "FreeBSD" => "/usr/local/etc",
      default => "/etc/ganglia"
  }
  $ganglia_monitor_conf = "${ganglia_mconf_dir}/gmond.conf"
    $package = $kernel ? {
      "FreeBSD" => "ganglia-monitor-core",
      "Darwin" => "ganglia-3.1.2-2.pkg.dmg",
      default => "ganglia-monitor",
    }
  $service = $kernel ? {
    "FreeBSD" => "gmond",
    "Darwin" => "de.ikw.uos.gmond",
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
      package{["libganglia1", "${package}"]:
	ensure => "3.1.2-ikw-1",
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
          }
    }
    default: {
	       package{"${package}":
		 before => [ Service["${service}"], 
			File["${ganglia_monitor_conf}"] ],
	       }
	     }
  }   
  service{"${service}":
    ensure => "running",
	   enable => "true",
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
	ensure => "present",
	notify => Exec["generate-metadconf"],
	content => template("ganglia/ganglia-datasource-cluster.erb"),
  }   

### metrics configuration
  file{"${ganglia_metrics}":
    ensure => "directory",
	   owner => "root",
	   mode => 0700
  }
  file{"${ganglia_metrics_cron}":
    ensure => "directory",
	   owner => "root",
	   mode => 0700,
	   require => File["${ganglia_metrics}"],
  }
  file{"${ganglia_metrics}/run-metrics.sh":
    source => "puppet:///ganglia/run-metrics.sh",
	   mode => 0700,
	   owner => root,
	   require => File["${ganglia_metrics}"],
  }
  cron{"ganglia-runmetrics":
    require => File["${ganglia_metrics}/run-metrics.sh"],
	    command => "${ganglia_metrics}/run-metrics.sh ${ganglia_metrics_cron}",
	    user => root,
	    minute => "*",
	    hour => "*",
  }
}
