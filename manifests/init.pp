# $Id$

$ganglia_metacollects = "/var/lib/puppet/exported/ganglia-metad"
$ganglia_metrics = "/var/lib/puppet/exported/ganglia-metrics"
$ganglia_metrics_cron = "${ganglia_metrics}/cron"
import "ganglia_*.pp"


define ganglia::gmetric(
  $source="",
  $ensure="present"
  )
  {
      $source_real = $source ? {
        "" => "ganglia/metrics/${name}",
          default => $source
      }
      file{"${ganglia_metrics_cron}/${name}":
          source => "puppet:///${source_real}",
            owner => root,
            mode => 0700,
      ensure => $ensure,
      }        
  }
