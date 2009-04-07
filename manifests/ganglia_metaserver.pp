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

#    file{"${ganglia_metacollects}/meta-${fqdn}":
#      ensure => "absent",
#             notify => Exec["generate-metadconf"],
#             content => template("ganglia/ganglia-datasource.erb"),
#    }

}
