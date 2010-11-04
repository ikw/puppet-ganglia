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
  tag("ganglia")
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
      default => "latest",
  }
  package{"${package}":
    ensure => "${pack_ensure}",
	   before => [ Service["gmetad"], Exec["generate-metadconf"] ],
  }
  case $kernel {
    "Linux": {
      file{"/etc/init.d/gmetad":
	source => "puppet:///ganglia/gmetad-init",
	       notify => Service["gmetad"],
	       before => Service["gmetad"],
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
  notice("${fqdn} should be \"${presence}\"")
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
	    onlyif => "test -f ${ganglia_metaconf}",
  } 
  file{["/var/lib/ganglia","/var/lib/ganglia/rrds"]:
    ensure => $pres_real ? {
      "absent" => "absent",
	default => "directory"
    },
	   backup => false,
	   owner => "ganglia",
	   group => "ganglia",
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
  tag("ganglia")
    $present_real = $present ? {
      "absent" => "absent",
	default => "present"
    }
  notice ("${fqdn} should be \"${present_real}\"")
    if $present_real == "present" {
      include ganglia::metaserver::common
#collect the meta configs for this host.  
	File <<| tag == "ganglia_metad_${hostname}" |>>
    }
  $presence = "absent"
    include ganglia::metaserver::tmpfs
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
    include ganglia::metaserver
    $presence = "absent"
    include ganglia::metaserver::tmpfs
}

class ganglia::metaserver::tmpfs { 
  $pres_real = $presence ? {
    "absent" => "absent",
      default => "present"
  }
  $ganglia_tmpfs_real= $ganglia_tmpfs ? {
    "" => "/var/lib/ganglia/rrds",
      default => $ganglia_tmpfs
  }
  include ganglia::metaserver::common
#collect the meta configs for this host.  
    File <<| tag == "ganglia_metad_${hostname}" |>>

    if $ganglia_tmpfs_real != "/var/lib/ganglia/rrds" {
      notice("$hostname ganglia::tmpfs ensure: $pres_real, tmpfs: $ganglia_tmpfs_real")
	cron{"ganglia-tmpfs":
	  minute => "*/30",
		 command => "if [ -d ${ganglia_tmpfs_real}/rrds/__SummaryInfo__ ]; then rsync -aczH ${ganglia_tmpfs_real}/rrds/ /var/lib/ganglia/rrds/; fi 2>&1",
		 user => "ganglia",
		 ensure => $pres_real,
	}

      mount{"${ganglia_tmpfs_real}":
	device => "none",
	       fstype => "tmpfs",

	       ensure => $pres_real ? {
		 "absent" => "absent",
		 default => "mounted"
	       },
	       dump => 0,
	       pass => 0,
	       options => "size=1024M,mode=755,uid=ganglia,gid=ganglia",
#require => File["${ganglia_tmpfs_real}"],
	       before => Service["gmetad"],
      }
    }
}

class ganglia::metaserver::tmpfs::none {
  $presence = "absent"
    include ganglia::metaserver::tmpfs::none
}
