class activemq (
    $ensure="present",
    $version="5.5.0",
    $baseurl="http://ftp.halifax.rwth-aachen.de/apache/activemq/apache-activemq/${version}/"
    ){

  user { "activemq":
    ensure     => $ensure,
    home       => "/opt/activemq",
    managehome => false,
    shell      => "/bin/false",
  }

  group { "activemq":
    ensure  => $ensure,
    require => User["activemq"],
  }
  File {
    ensure => $ensure,
  }
  if $ensure == "present" {
    exec { "activemq_download":
      command => "wget ${baseurl}/apache-activemq-${version}-bin.tar.gz",
      cwd     => "/usr/local/src",
      creates => "/usr/local/src/apache-activemq-${version}-bin.tar.gz",
      path    => ["/usr/bin", "/usr/sbin"],
      require => Group["activemq"],
    }

    exec { "activemq_untar":
      command => "tar xf /usr/local/src/apache-activemq-${version}-bin.tar.gz && chown -R activemq:activemq /opt/apache-activemq-${version}",
	      cwd     => "/opt",
	      creates => "/opt/apache-activemq-${version}",
	      path    => ["/bin",],
	      require => Exec["activemq_download"],
#also need to chown activemq:activemq this dir
    }
  } else {
    file{["/opt/apache-activemq-${version}","/usr/local/src/apache-activemq-${version}-bin.tar.gz" ]:
      backup => true,
	     force => true,
    }
  }
  file { "/opt/activemq":
    ensure  => "/opt/apache-activemq-${ensure}",
	    require => Exec["activemq_untar"],
  }

  file { "/etc/activemq":
    target => "/opt/activemq/conf",
	   ensure  => $ensure ? {
	     "present" => "link",
	     default => $ensure,
	   },
	   require => File["/opt/activemq"],
  }

  file { "/var/log/activemq":
    ensure  => "/opt/activemq/data",
	    require => File["/opt/activemq"],
  }

  file { "/opt/activemq/bin/linux":
    ensure  => "/opt/activemq/bin/linux-x86-32",
	    require => File["/opt/activemq"],
  }

  file { "/var/run/activemq":
    ensure  => directory,
	    owner   => activemq,
	    group   => activemq,
	    mode    => 755,
	    require => Group["activemq"],
  }

  file { "/etc/init.d/activemq":
    owner   => root,
	    group   => root,
	    mode    => 755,
	    content => template("activemq/activemq-init.d.erb"),
  }

  file {["/opt/apache-activemq-${version}/bin/linux-x86-32/wrapper.conf",
    "/opt/apache-activemq-${version}/bin/linux-x86-64/wrapper.conf"]:
      owner   => activemq,
    group   => activemq,
    mode    => 644,
    source  => "puppet://${servername}/activemq/wrapper.conf",
    require => File["/opt/activemq"],
  }

  service {"activemq":
    ensure => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File["/opt/apache-activemq-${version}/bin/linux-x86-32/wrapper.conf"],
  }

}
