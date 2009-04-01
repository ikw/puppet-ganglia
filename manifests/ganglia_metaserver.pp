# $Id$

class ganglia::metaserver::common {
  $ganglia_metaconf = "/etc/ganglia/gmetad.conf"
    $package = "gmetad"
    file{"${ganglia_metacollects}":
      ensure => "directory",
	     owner => "root",
	     mode => 0700,
    }

  package{"${package}":
    ensure => "3.1.2-ikw-1",
	   before => [ Service["gmetad"], Exec["generate-metadconf"] ],
  }

  service{"gmetad":
    ensure => "running",
	   enable => "true",
	   subscribe => Exec["generate-metadconf"],
	   require => Package["${package}"],
  }

  file{"${ganglia_metacollects}/0000-gmetad.conf":
    content => template("ganglia/ganglia-metad-conf.erb"),
	    ensure => "present",
	    notify => Exec["generate-metadconf"],  
	    require => [ Package["${package}"], File["${ganglia_metacollects}"] ],
  }

  @@file{"${ganglia_metacollects}/meta-all-${fqdn}":
    tag => "ganglia_metad_all",
	ensure => "present",
	notify => Exec["generate-metadconf"],
	content => template("ganglia/ganglia-datasource-all.erb"),
  }
  
### generate the configuration file
  exec{"generate-metadconf":
    command => "cat ${ganglia_metacollects}/* >${ganglia_metaconf}",
	    refreshonly => "true",
	    require => Package["${package}"],
  } 
}

class ganglia::metaserver {
  include ganglia::metaserver::common
    file{"${ganglia_metacollects}/meta-${fqdn}":
      ensure => "absent",
	     notify => Exec["generate-metadconf"],
	     content => template("ganglia/ganglia-datasource.erb"),
    }

#collect the meta configs for this host.  
  File <<| tag == "ganglia_metad_${hostname}" |>>
#  define metacollect($mcast_port){
#  File <<| tag == "ganglia_gmond_cluster_${mcast_port}" |>>  
#  }
}
