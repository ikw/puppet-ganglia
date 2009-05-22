# $Id$
# Writtenby: udo.waechter@uni-osnabrueck.de
#
# _Class:_ ganglia::metaserver::common
# 
# Common class for Metaserver and webfrontend class. Do not use directly
#
# This module was tested with Debian (Etch/Lenny)
#
# _Parameters:_
#
# _Actions:_
#   Installs the metaserver.
#
# _Requires:_
#   
# _Sample Usage:_
#
class ganglia::metaserver::common {
  $presence = $present ? {
    "absent" => "absent",
    default => "present",
  }
  $ganglia_metaconf = "/etc/ganglia/gmetad.conf"
    $package = "gmetad"
    $fpresent = $presence ? {
      "absent" => "absent",
      default => "directory",
    }
    file{"${ganglia_metacollects}":
      ensure => "${fpresent}",
             owner => "root",
             mode => 0700,
	     force => true,
	     backup => false,
	     recurse => true,
    }
   
   $pack_ensure = $presence ? {
      "absent" => "absent",
      default => "3.1.2-ikw-1",
   }
  package{"${package}":
    ensure => "${pack_ensure}",
           before => [ Service["gmetad"], Exec["generate-metadconf"] ],
  }
  case $kernel {
        "Linux": {
          file{"/etc/init.d/gmetad":
              source => "puppet:///ganglia/gmetad-init",
                notify => Service["${service}"],
              before => Service["${service}"],
	      ensure => "${presence}",
          }          
        }
    }
    $run = $presence ? {
      "absent" => "stopped",
      default => "running"
    }
    $enabled = $presence ? {
      "absent" => "false",
      default => "true"
    }

  service{"gmetad":
    ensure => "${run}",
           enable => "${enabled}",
           subscribe => Exec["generate-metadconf"],
           require => Package["${package}"],
  }

  file{"${ganglia_metacollects}/0000-gmetad.conf":
    content => template("ganglia/ganglia-metad-conf.erb"),
            ensure => "${presence}",
            notify => Exec["generate-metadconf"],  
            require => [ Package["${package}"], File["${ganglia_metacollects}"] ],
  }

  @@file{"${ganglia_metacollects}/meta-all-${fqdn}":
    tag => "ganglia_metad_all",
        ensure => "${presence}",
        notify => Exec["generate-metadconf"],
        content => template("ganglia/ganglia-datasource-all.erb"),
  }

### generate the configuration file
  exec{"generate-metadconf":
    command => "cat ${ganglia_metacollects}/* >${ganglia_metaconf}",
            refreshonly => "true",
            require => Package["${package}"],
	    onlyif => "test -d ${ganglia_metaconf}",
  } 
  monit::process{"gmetad": ensure => "${presence}" }
}
# Writtenby: udo.waechter@uni-osnabrueck.de
#
# _Class:_ ganglia::metaserver
# 
# Install and configure a ganglia metaserver
#
# This module was tested with Debian (Etch/Lenny)
#
# _Parameters:_
#
# _Actions:_
#   Installs a metaserver.
#
# _Requires:_
#   
# _Sample Usage:_
#   +include ganglia::metaserver+
class ganglia::metaserver {
  include ganglia::metaserver::common
#collect the meta configs for this host.  
    File <<| tag == "ganglia_metad_${hostname}" |>>

}
# Writtenby: udo.waechter@uni-osnabrueck.de
#
# _Class:_ ganglia::metaserver::none
# 
# Uninstall and deconfigure a ganglia metaserver
#
# This module was tested with Debian (Etch/Lenny)
#
# _Parameters:_
#
# _Actions:_
#   Uninstalls a metaserver.
#
# _Requires:_
#   
# _Sample Usage:_
#   +include ganglia::metaserver::none+
class ganglia::metaserver::none {
  $present = "absent"
  include ganglia::metaserver::common

}
