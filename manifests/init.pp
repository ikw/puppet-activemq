class activemq {

    user { "activemq":
      ensure     => present,
      home       => "/opt/activemq",
      managehome => true,
      shell      => "/bin/false",
    }

}
