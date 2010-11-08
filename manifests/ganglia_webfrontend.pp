# $Id$
# Writtenby: udo.waechter@uni-osnabrueck.de
#
# _Class:_ ganglia::webfrontend
# 
# Install and configure a ganglia metaserver and a webfrontend.
#
# This module was tested with Debian (Etch/Lenny)
#
# _Parameters:_
#
# _Actions:_
#   Installs a metaserver and a ganglia webfrontend.
#
# _Requires:_
#   webserver::apache2 module
#   
# _Sample Usage:_
#   +include ganglia::webfrontend+
#
class ganglia::webfrontend {
  $www_dir = "/usr/share/ganglia-webfrontend"
    file{$www_dir:
      source => "puppet:///modules/ganglia/ganglia-webfrontend",
	     recurse => true,
    }
# include ganglia::metaserver::common
  include webserver::apache2::basic
    if !defined(Package["libapache2-mod-php5"]){
      package{"libapache2-mod-php5": }
    }      
  package{["libgd2-xpm"]:
    ensure => "present",
	   before => Package["ganglia-webfrontend"],
  }

  webserver::apache2::virtualhost{"${fqdn}_80":
    servername => "${fqdn}",
	       documentroot => "/usr/share/ganglia-webfrontend",
	       serveradmin => "webmaster@ikw.uni-osnabrueck.de",
	       syncconf => false,
	       order => "000",
	       additional => "Alias /munin/ /var/lib/munin/www/",
  }
  webserver::apache2::config{"ganglia-webfrontend":
    ensure => "absent",
  }
  package{"ganglia-webfrontend":
    ensure => "latest",
  } 

#collect the meta configs for this host.  
  File <<| tag == "ganglia_metad_all" |>>

## install the cleanupscript
    file{"/usr/local/sbin/ganglia_rrdcleanup.sh":
      source => "puppet:///modules/ganglia/rrdcleanup.sh",
	     owner => "root",
	     mode => 0700,
    }
  cron{"ganglia_rrdcleanup.sh":
    command => "/usr/local/sbin/ganglia_rrdcleanup.sh",
	    minute => "20",
	    hour => "3",
	    monthday => "*/10",
	    user => "root",
	    require => File["/usr/local/sbin/ganglia_rrdcleanup.sh"]
  }
}
