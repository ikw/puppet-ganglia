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
class ganglia::monitor ($ensure="present", 
		$cluster="${domain}",
		$company="${company}",
		$latlong="${network_location}",
		$url="${documentation_url}",
		$port="8650",
		$metaserver="gmetad.${domain}"
		){

	class {"ganglia::monitor::base": ensure => $ensure }
	$ganglia_monitor_conf = "${ganglia_mconf_dir}/gmond.conf"
		$package = $kernel ? {
			"FreeBSD" => "ganglia-monitor-core",
				"Darwin" => "ganglia",
				default => "ganglia-monitor"
		}
	$pathprefix = $kernel ? {
		"FreeBSD" => "/usr/local",
			"Darwin" => "/opt/local",
			default => "/usr"
	} 
	$run_as = $kernel ? {
		"Darwin" => "nobody",
			default => "ganglia"
	}
	$pack_present = $ensure ? {
		"absent" => "absent",
			default => $kernel ? {
				"Linux" => $lsbdistcodename ? {
					"Lenny" => "3.1.7-1+b1",
					default => "latest",
				},
				default => $ensure
			},
	}
	File{
		ensure => $ensure, 
		       owner => root,
		       mode => 0700,
		       force => true,
		       recurse => true,
	}
	package{$package:
		before => Service["${service}"], 
		       ensure => $ensure,
	}

	case $kernel {
		"Linux": {
			file{"/etc/init.d/ganglia-monitor":
				source => "puppet:///modules/ganglia/gmond-init",
				       notify => Service["${service}"],
			}  

			package{"libganglia1":
				ensure => $pack_present,
				       before => Package["${package}"],
			}      

		}      
		"Darwin": {
			darwin_firewall{"any":
				port => "8649",
				     ensure => $ensure,
			}
			replace{"/opt/local/etc/LaunchDaemon/org.macports.ganglia/org.macports.ganglia.plist":
				pattern => '/opt/local/var/log/',
					replacement => '/var/log/',
					notify => Service["${service}"],
			}
		}
	}  
#### configure the service daemon
	$enabled = $ensure ? {
		"absent" => "false",
			default => "true"
	}
	if $enabled == "true" {
		Service["${service}"] {
			require => Package["${package}"],
				subscribe => [ File["${ganglia_mconf_dir}"], File["${ganglia_mconf_dir}/conf.d"] ],
		}       
	}
	service{"${service}":
		ensure => "${enabled}",
		       enable => "${enabled}",
		       pattern => "gmond",
			hasstatus => false,
	}

	file{"${ganglia_mconf_dir}":
		ensure => $ensure ? {
			"present" => "directory",
				default => $ensure,
		},
	}
	if $ensure == "present" {
		File["${ganglia_mconf_dir}"] {
			source => "puppet:///modules/ganglia/conf.d",
		}
		file {"${ganglia_mconf_dir}/conf.d":
			ensure => "directory",
		}
	}
	if $ensure == "present" {
		file {"${ganglia_mconf_dir}/conf.d/0000-cluster.conf":
			content => template("ganglia/gmond-cluster.conf.erb"),
				require => File["${ganglia_mconf_dir}/conf.d"],
		}
		file {"${ganglia_mconf_dir}/conf.d/modules.conf":
			content => template("ganglia/gmond-modules.conf.erb"),
				require => File["${ganglia_mconf_dir}/conf.d"],
		}
		debug("${fqdn} should ${package} have ${presence} / running: ${running} / enable: ${enabled} / conf: ${ganglia_monitor_conf}") 
			file{"${ganglia_monitor_conf}":
				content => template("ganglia/ganglia-monitor-conf.erb"),
					require =>  [ File["${ganglia_mconf_dir}"],  
					Package["${package}"] ],
			}
### Create the listen statement for this port/host
		file {"${ganglia_mconf_dir}/conf.d/${port}-udp-receive.conf":
			content => template("ganglia/gmond-udp-receive.conf.erb"),
				require => File["${ganglia_mconf_dir}/conf.d"],
		}
	}
	notice("${fqdn}=$ensure, metaserver=${metaserver}, cluster=${cluster}, port=${port},")
#@@line{"${ganglia_metacollects}/ganglia-monitors_${port}":
	@@file{"${ganglia_metacollects}/ganglia-monitor_${fqdn}":
		tag => "ganglia_gmond_${metaserver}",
		    notify => Exec["generate-metadconf"],
		    content => template("ganglia/ganglia-datasource-cluster.erb")
	}   

## monitoring 
	monit::process{"gmond":
		start => "/etc/init.d/ganglia-monitor start",
		      stop => "/etc/init.d/ganglia-monitor stop",
		      ensure => $ensure,
	}
}


class ganglia::monitor::base ($ensure="present") {
# metrics configuration
	File {
		owner => "root",
		      mode => "0700",
		      force => true,
		      recurse => true,
		      backup => false,
	}
	file{"${ganglia_metrics}/run-metrics.sh":
		source => "puppet:///modules/ganglia/run-metrics.sh",
		       require => File["${ganglia_metrics}"],
		       ensure => $ensure,
	}
	$ens_dir = $ensure ? {
		"present" => "directory",
			default => $ensure,
	}
	file{"${ganglia_metrics}":
		ensure => $ens_dir,
	}
	file{"${ganglia_metrics_cron}":
		ensure => $ens_dir,
		       require => File["${ganglia_metrics}"],
	}

	file { ["${ganglia_metrics_cron}/1",
		"${ganglia_metrics_cron}/5",
		"${ganglia_metrics_cron}/15",
		"${ganglia_metrics_cron}/30",
		"${ganglia_metrics_cron}/60"]:
			ensure => $ens_dir,
		require => [ File["${ganglia_metrics}"],
		File["${ganglia_metrics_cron}"] ],
	} 
	Cron {
		user => "root",
		ensure => $ensure,
	}
	$pre_cmd = "if [ -e ${ganglia_metrics}/run-metrics.sh ]; then " #mind the trailing whitespace
		$post_cmd = " fi" #space at the beginning

		cron{"ganglia-runmetrics-1":
			command => "${pre_cmd} ${ganglia_metrics}/run-metrics.sh ${ganglia_metrics_cron}/1;${post_cmd}",
			minute => "*/1",
		}
	cron{"ganglia-runmetrics-5":
		command => "${pre_cmd} ${ganglia_metrics}/run-metrics.sh ${ganglia_metrics_cron}/5;${post_cmd}",
		minute => "*/5",
	}
	cron{"ganglia-runmetrics-15":
		command => "${pre_cmd} ${ganglia_metrics}/run-metrics.sh ${ganglia_metrics_cron}/15;${post_cmd}",
			minute => "*/15",
	}
	cron{"ganglia-runmetrics-30":
		command => "${pre_cmd} ${ganglia_metrics}/run-metrics.sh ${ganglia_metrics_cron}/30;${post_cmd}",
			minute => "*/30",
	}
	cron{"ganglia-runmetrics-60":
		command => "${pre_cmd} ${ganglia_metrics}/run-metrics.sh ${ganglia_metrics_cron}/60;${post_cmd}",
			minute => "*/60",
	}
}
