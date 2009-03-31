# $Id$

class ganglia::webfrontend {
  include ganglia::metaserver::common
    include webserver::apache2::basic
    package{["libapache2-mod-php5", "libgd2-xpm"]:
      ensure => "present",
	     before => Package["ganglia-webfrontend"],
    }

  webserver::apache2::virtualhost{"${fqdn}_80":
    servername => "${fqdn}",
	       documentroot => "/usr/share/ganglia-webfrontend",
	       serveradmin => "webmaster@ikw.uni-osnabrueck.de",
	       syncconf => false,
	       order => "000",
  }
  webserver::apache2::config{"ganglia-webfrontend":
    ensure => "absent",
  }
  package{"ganglia-webfrontend":
    ensure => "latest",
  } 

#collect the meta configs for this host.  
  File <<| tag == "ganglia_metad_all" |>> 
}
