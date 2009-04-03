# $Id$

$ganglia_metacollects = "/var/lib/puppet/exported/ganglia-metad"
$ganglia_metrics = "/var/lib/puppet/exported/ganglia-metrics"
$ganglia_metrics_cron = "${ganglia_metrics}/cron"
$ganglia_metrics_py = "/usr/lib/ganglia/python_modules"
$ganglia_mconf_dir = $kernel ? {
  "FreeBSD" => "/usr/local/etc",
    default => "/etc/ganglia"
}
$service = $kernel ? {
  "FreeBSD" => "gmond",
    "Darwin" => "de.ikw.uos.gmond",
    default => "ganglia-monitor",
}

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
      ensure => "directory",
    }
  }
  file{"${ganglia_metrics_py}/${name}.py":
    source => "puppet:///${source_real}",
	   ensure => $ensure,
	   require => File["${ganglia_metrics_py}"],
	   notify => Service["${service}"],
  }
  file{"${ganglia_mconf_dir}/conf.d/${name}.pyconf":
    source => "puppet:///${source_real}conf",
	   require => [ File["${ganglia_metrics_py}/${name}.py"], File["${ganglia_mconf_dir}/conf.d"] ],
	   ensure => $ensure,
  }
  case $additional_lib {
    "": {
      debug("no additional libraries.")
    }
    default: {
	       file{"${ganglia_metrics_py}/${additional_lib}}":
		 source => "puppet:///${additional_lib_source}/${additional_lib}",
			ensure => $ensure,              
			notify => Service["${service}"],
	       }
	     }
  }
}

define ganglia::gmetric::cron(
    $source="",
    $ensure="present",
    $runwhen="1"
    )
{
  $source_real = $source ? {
    "" => "ganglia/metrics-cron/${name}",
    default => "${source}/${name}",
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
      ensure => "directory",
      owner => "root",
      mode => 0700,
      require => File["${ganglia_metrics}"],
    }
  }
  if defined(File["${ganglia_metrics_cron}/${runwhen}"]){
    debug("already defined.") 
  }else{
    file{"${ganglia_metrics_cron}/${runwhen}":
      ensure => "directory",
	     owner => "root",
	     mode => 0700,
	     require => File["${ganglia_metrics_cron}"]
    } 

  }
  if defined(Cron["ganglia-runmetrics-${runwhen}"]){
    debug("already defined.")        
  }else{  
    cron{"ganglia-runmetrics-${runwhen}":
      require => File["${ganglia_metrics}/run-metrics.sh"],
	      command => "${ganglia_metrics}/run-metrics.sh ${ganglia_metrics_cron}/${runwhen}",
	      user => root,
	      minute => "*/${runwhen}",
	      hour => "*",
    }
  }
  file{"${ganglia_metrics_cron}/${runwhen}/${name}":
    source => "puppet:///${source_real}",
	   owner => root,
	   mode => 0700,
	   ensure => $ensure,
  }   
}


import "ganglia_*.pp"
