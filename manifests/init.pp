# $Id$

$ganglia_metacollects = "/var/lib/puppet/exported/ganglia-metad"
$ganglia_metrics = "/var/lib/puppet/exported/ganglia-metrics"
$ganglia_metrics_cron = "${ganglia_metrics}/cron"
$ganglia_metrics_py = $kernel ? {
	"Darwin" => "/opt/local/lib/ganglia/python_modules",
		default => "/usr/lib/ganglia/python_modules"
}
$ganglia_mconf_dir = $kernel ? {
	"FreeBSD" => "/usr/local/etc",
		"Darwin" => "/opt/local/etc/ganglia",
		default => "/etc/ganglia"
}
$service = $kernel ? {
	"FreeBSD" => "gmond",
		"Darwin" => "org.macports.ganglia",
		default => "ganglia-monitor",
}

# _Define:_ ganglia::gmetric::python
# Manage a ganglia python metric (also known module).
# 
# _Parameters:_
#   $namevar   
#   - The metric's name
#   $source = "puppet:///ganglia/metrics-py/${namevar}.py"
#   - The source from where to get the metric. 
#  $additional_lib = ""
#   - additional library needed by this module
# $additional_lib_source = "ganglia/metrics-py"
# - from where to get the addtional library
#   $ensure = "present"
#   - {"present","absent"} whether or not this process should be monitored
#
# _Sample Usage:_
# 1. +ganglia::gmetric::python{"mysql":
#         additional_lib => "DBUtil.py",
#       }+
#       - installs the mysql.py module and its requirement DBUtil.py from
#         puppet:///ganglia/metrics-py/
#
define ganglia::gmetric::python(
		$source="",
		$ensure="present",
		$additional_lib="",
		$additional_lib_source="ganglia/metrics-py"
		)
{
	$source_real = $source ? {
		"" => "ganglia/metrics-py/${name}.py",
		default => "${source}/${name}.py",
	}
	if defined(File["${ganglia_metrics_py}"]){
		debug("already defined.")
	}else{
		file{"${ganglia_metrics_py}":
			ensure => "directory",
		}
	}
	if defined(File["${ganglia_mconf_dir}/conf.d"]){
		debug("already defined.")
	}else{
		file{"${ganglia_mconf_dir}/conf.d":
			ensure => $ensure ? {
				"present" => "directory",
				default => $ensure,
			},
			force => true,
			recurse => true,
		}
	}
	file{"${ganglia_metrics_py}/${name}.py":
		source => "puppet:///modules/${source_real}",
		       ensure => $ensure,
		       require => File["${ganglia_metrics_py}"],
		       notify => Service["${service}"],
	}
	file{"${ganglia_mconf_dir}/conf.d/${name}.pyconf":
		source => "puppet:///modules/${source_real}conf",
		       require => [ File["${ganglia_metrics_py}/${name}.py"], File["${ganglia_mconf_dir}/conf.d"] ],
		       ensure => $ensure,
	}
	case $additional_lib {
		"": {
			debug("no additional libraries.")
		}
		default: {
				 file{"${ganglia_metrics_py}/${additional_lib}":
					 source => "puppet:///modules/${additional_lib_source}/${additional_lib}",
						ensure => $ensure,              
						notify => Service["${service}"],
						recurse => true,
						force => true,
				 }
			 }
	}
}
# _Define:_ ganglia::gmetric::cron
# Manage a ganglia metric called via cron.
# 
# _Parameters:_
#   $namevar   
#   - The metric's name
#   $source = "puppet:///ganglia/metrics-cron/${namevar}"
#   - The source from where to get the metric. 
#   $source_name = ""
#   - The name of the source file if it differs from ${namevar}
#   $runwhen = "1"
#   - At which points in time this metric should be run [1,5,15,30,60]
#   $ensure = "present"
#   - {"present","absent"} whether or not this process should be monitored
#
# _Sample Usage:_
# 1. +ganglia::gmetric::cron{"smartctl": }+
#       - fetches smartctl and installs it in the ganglia::monitor.
#         This metric is then run every minute
#
# 1. +ganglia::gmetric::cron{"workusage": 
#               runwhen => "60",
#       }+
#       - install a metric 'workusage' and run it every 60 minutes.
#
define ganglia::gmetric::cron(
		$metric_name="",
		$source="",
		$source_name = "",
		$ensure="present",
		$runwhen="1"
		)
{
	$name_real = $metric_name ? {
		"" => $name,
		default => $metric_name
	}  
	$sname = $source_name ? {
		"" => "${name_real}",
		default => "${source_name}"
	}
	$source_real = $source ? {
		"" => "ganglia/metrics-cron/${sname}",
		default => "${source}/${sname}",
	}

	case $runwhen {
		"1","5","15","30","60": {
			debug("running every \"${runwhen}\" minutes")
		}
		default:{
				err("runwhen can be only one of: 1,5,15,30,60") 
			}
	}
	if defined(File["${ganglia_metrics_cron}"]){
		debug("already defined.") 
	}else{
		file{"${ganglia_metrics_cron}":
			ensure => $ensure ? {
				"present" => "directory",
					default => $ensure,
			},
			       force => true,
			       recurse => true,
			       owner => "root",
			       mode => 0700,
			       require => File["${ganglia_metrics}"],
		}
	}
	file{"${ganglia_metrics_cron}/${runwhen}/${name_real}":
		source => "puppet:///modules/${source_real}",
		       owner => root,
		       mode => 0700,
		       ensure => $ensure,
	}   
}
import "ganglia_*.pp"
