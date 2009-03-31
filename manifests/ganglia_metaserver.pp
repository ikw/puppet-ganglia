# $Id$

class ganglia::metaserver::common {
  file{"${ganglia-metacollects}":
    ensure => "directory",
  }

  $ganglia-metaconf = "/etc/ganglia/gmetad.conf"
    $package = "gmetad"

    package{"${package}":
      ensure => "latest",
	     before => [ Service["gmetad"], Exec["generate-metadconf"] ],
    }

  service{"gmetad":
    ensure => "running",
	   enable => "true",
	   subscribe => Exec["generate-metadconf"],
  }

  file{"${ganglia-metacollects}/0000-gmetad.conf":
    content => template("ganglia/ganglia-metad-conf.erb"),
	    ensure => "present",
	    notify => Exec["generate-metadconf"],  
  }
  @@file{"${ganglia-metacollects}/meta-${fqdn}":
    tag => [ "ganglia_metad_all", "ganglia_metad_${hostname}" ]
      ensure => "present",
	     notify => Exec["generate-metadconf"],
  }
### generate the configuration file
  exec{"generate-metadconf":
    command => "cat ${ganglia-metacollects/* >${ganglia-metaconf}",
	    refreshonly => "true",
  } 
}

class ganglia::metaserver inherits ganglia::metaserver::common {
#collect the meta configs for this host.  
  File <<| tag == "ganglia_metad_${hostname}" |>>
}
