class activemq {

  user { "activemq":
    ensure     => present,
    home       => "/opt/activemq",
    managehome => false,
    shell      => "/bin/false",
  }
  
  exec { "activemq_download":
    command => "wget https://static.arcs.org.au/apache-activemq-5.2.0-bin.tar.gz",
    cwd     => "/usr/local/src",
    creates => "/usr/local/src/apache-activemq-5.2.0-bin.tar.gz",
    path    => ["/usr/bin", "/usr/sbin"],
    require => User["activemq"],
  }
  
  exec { "activemq_untar":
    command => "tar xf /usr/local/src/apache-activemq-5.2.0-bin.tar.gz && chown -R activemq:activemq /opt/apache-activemq-5.2.0",
    cwd     => "/opt",
    creates => "/opt/apache-activemq-5.2.0",
    path    => ["/bin",],
    require => Exec["activemq_download"],
  }
  
  file { "/opt/activemq":
    ensure  => "/opt/apache-activemq-5.2.0",
    require => Exec["activemq_untar"],
  }
  
  file { ["/var/run/activemq", "/var/log/activemq"]:
    ensure  => directory,
    owner   => activemq,
    group   => activemq,
    mode    => 755,
    require => User["activemq"],
  }
  
  file { "/etc/init.d/activemq":
    owner  => root,
    group  => root,
    mode   => 755,
    source => "puppet://${servername}/activemq/activemq-init.d",
  }
  
  file {"/opt/apache-activemq-5.2.0/bin/linux-x86-32/wrapper.conf":
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
    require    => File["/opt/apache-activemq-5.2.0/bin/linux-x86-32/wrapper.conf"],
  }
  
}
