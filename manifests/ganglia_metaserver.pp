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
class ganglia::metaserver::common ($ensure="present"){
	tag("ganglia")
		$fqdn_r = downcase($fqdn)
		$ganglia_metaconf = "/etc/ganglia/gmetad.conf"
		$package = "gmetad"
		$fpresent = $ensure ? {
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

	$pack_ensure = $ensure ? {
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
				source => "puppet:///modules/ganglia/gmetad-init",
				       notify => Service["gmetad"],
				       before => Service["gmetad"],
				       ensure => $ensure,
			}          
		}
	}
	$run = $ensure ? {
		"absent" => false,
			default => true
	}
	notice("${fqdn_r} should be \"${presence}\"")
		service{"gmetad":
			ensure => $run,
			       enable => $run,
			       subscribe => Exec["generate-metadconf"],
			       require => Package["${package}"],
		}

	file{"${ganglia_metacollects}/0000-gmetad.conf":
		content => template("ganglia/ganglia-metad-conf.erb"),
			ensure => $ensure,
			notify => Exec["generate-metadconf"],  
			require => [ Package["${package}"], File["${ganglia_metacollects}"] ],
	}
	@@file{"${ganglia_metacollects}/meta-all-${fqdn_r}":
		tag => "ganglia_metad_all",
		    ensure => $ensure,
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
		ensure => $fpresent,
		       backup => false,
		       owner => "ganglia",
		       group => "ganglia",
	}
	monit::process{"gmetad": ensure => $ensure }
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
class ganglia::metaserver ($ensure="present"){
	tag("ganglia")
		$fqdn_r = downcase($fqdn)
		class{"ganglia::metaserver::common": ensure => $ensure }  
	notice ("${fqdn_r} should be \"${present_real}\"")
		if $ensure == "present" {
#collect the meta configs for this host.  
#Line <<| tag == "ganglia_gmond_${fqdn_r}" |>>
			File <<| tag == "ganglia_gmond_${fqdn_r}" |>>
		}

	class{"ganglia::metaserver::tmpfs": ensure => "absent" }
}
# Writtenby: udo.waechter@uni-osnabrueck.de
#
# _Class:_ ganglia::metaserver::tmpfs
# 
# Use tmpfs to store rrd metrics
#
# This module was tested with Debian (Etch/Lenny)
#
# _Parameters:_
#
# _Actions:_
#   Installs a metaserver and setups tmpfs.
#
# _Requires:_
#   
# _Sample Usage:_
#   +include ganglia::metaserver::tmpfs+

class ganglia::metaserver::tmpfs ($ensure="present", $ganglia_tmpfs="/var/lib/ganglia/rrds") { 

#class{"ganglia::metaserver::common" ensure => $ensure } 
#collect the meta configs for this host.
	if $ensure == "present" {
		File <<| tag == "ganglia_gmond_${domain}" |>>
	}
	if $ganglia_tmpfs != "/var/lib/ganglia/rrds" {
		notice("$hostname ganglia::tmpfs ensure: $ensure, tmpfs: $ganglia_tmpfs")
			cron{"ganglia-tmpfs":
				minute => "*/30",
				       command => "if [ -d ${ganglia_tmpfs}/rrds/__SummaryInfo__ ]; then rsync -aczH ${ganglia_tmpfs}/rrds/ /var/lib/ganglia/rrds/; fi 2>&1",
				       user => "ganglia",
				       ensure => $ensure,
			}

		mount{"${ganglia_tmpfs}":
			device => "none",
			       fstype => "tmpfs",
			       ensure => $ensure ? {
				       "absent" => "absent",
				       default => "mounted"
			       },
			       dump => 0,
			       pass => 0,
			       options => "size=1024M,mode=755,uid=ganglia,gid=ganglia",
			       before => Service["gmetad"],
		}
	}
}
