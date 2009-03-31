# $Id$

class ganglia::webfrontend {
  $ganglia_webfrontend = "${fqdn}"  
    include webserver::apache2::basic
    package{["libapache2-mod-php5", "libgd2-xpm"]:
      ensure => "present",
	     before => Package["ganglia-webfrontend"],
    }

  webserver::apache2::virtualhost{"default_80":
    servername => "default",
	       vhostaddress => "${ipaddress}",
	       documentroot => "/usr/share/ganglia/webfrontend",
	       serveradmin => "webmaster@ikw.uni-osnabrueck.de",
	       syncconf => true,
	       order => "000",
  }
  webserver::apache2::config{"ganglia-webfrontend":
    ensure => "absent",
  }
  package{"ganglia-webfrontend":
    ensure => "latest",
  }  
}
