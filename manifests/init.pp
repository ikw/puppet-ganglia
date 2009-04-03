# $Id$

$ganglia_metacollects = "/var/lib/puppet/exported/ganglia-metad"
$ganglia_metrics = "/var/lib/puppet/exported/ganglia-metrics"
$ganglia_metrics_cron = "${ganglia_metrics}/cron"
import "ganglia_*.pp"


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
