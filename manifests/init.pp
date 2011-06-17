class activemq {

  user { "activemq":
    ensure     => present,
    home       => "/opt/activemq",
    managehome => false,
    shell      => "/bin/false",
  }

  group { "activemq":
    ensure  => present,
    require => User["activemq"],
  }
  
  exec { "activemq_download":
    command => "wget https://static.arcs.org.au/apache-activemq-5.4.2-bin.tar.gz",
    cwd     => "/usr/local/src",
    creates => "/usr/local/src/apache-activemq-5.4.2-bin.tar.gz",
    path    => ["/usr/bin", "/usr/sbin"],
    require => Group["activemq"],
  }
  
  exec { "activemq_untar":
    command => "tar xf /usr/local/src/apache-activemq-5.4.2-bin.tar.gz && chown -R activemq:activemq /opt/apache-activemq-5.4.2",
    cwd     => "/opt",
    creates => "/opt/apache-activemq-5.4.2",
    path    => ["/bin",],
    require => Exec["activemq_download"],
#also need to chown activemq:activemq this dir
  }
  
  file { "/opt/activemq":
    ensure  => "/opt/apache-activemq-5.4.2",
    require => Exec["activemq_untar"],
  }
  
  file { "/etc/activemq":
    ensure  => "/opt/activemq/conf",
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
  
  file {["/opt/apache-activemq-5.4.2/bin/linux-x86-32/wrapper.conf",
         "/opt/apache-activemq-5.4.2/bin/linux-x86-64/wrapper.conf"]:
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
    require    => File["/opt/apache-activemq-5.4.2/bin/linux-x86-32/wrapper.conf"],
  }
  
}
