class foreman::proxy {
  include ::foreman::repo

  user { "foreman-proxy":
    groups => "puppet",
    require => Package["foreman-proxy"],
  }

  package { "foreman-proxy":
    ensure => installed,
    require => Class["foreman::repo"],
  }~>
  file { "/etc/foreman-proxy/ca.pem":
    source => "/var/lib/puppet/ssl/certs/ca.pem",
  }~>
  file { "/etc/foreman-proxy/node.pem":
    source => "/var/lib/puppet/ssl/certs/$fqdn.pem",
    mode => 0600,
    owner => "foreman-proxy",
  }~>
  file { "/etc/foreman-proxy/node.key":
    source => "/var/lib/puppet/ssl/private_keys/$fqdn.pem",
    mode => 0600,
    owner => "foreman-proxy",
  }~>
  file { "/etc/foreman-proxy/settings.d/ssl.yml":
    ensure => absent,
  }~>
  file { "/etc/foreman-proxy/settings.yml":
    content => template("foreman/settings.yml.erb"),
  }~>
  service { "foreman-proxy":
    ensure => running,
  }
}

class foreman::proxy::puppet {
  include foreman::proxy

  file { "/usr/lib/ruby/vendor_ruby/puppet/reports/foreman.rb":
    source => "puppet:///modules/foreman/foreman-report_v2.rb",
  }
  file { "/etc/puppet/foreman.yaml":
    content => template("foreman/puppet-foreman.yaml.erb"),
  }
  file { "/etc/puppet/foreman-node.rb":
    source => "puppet:///modules/foreman/external_node_v2.rb",
    mode => 0755,
  }

  sudo::conf { 'foreman-proxy':
    content => "foreman-proxy ALL = NOPASSWD: /usr/bin/puppet cert *\nDefaults:foreman-proxy !requiretty\n"
    #source => 'puppet:///modules/foreman/foreman-proxy.sudo',
  }
  #foreman-proxy ALL = NOPASSWD: /usr/bin/puppet cert *
  #Defaults:foreman-proxy !requiretty


  cron { foreman-push-facts:
    command => "/etc/puppet/foreman-node.rb --push-facts",
    hour => '*',
    minute => '*/15',
    user => "puppet",
  }
}
