class foreman::repo {
  $version = '1.9'
  file { "/etc/apt/sources.list.d/foreman.list":
    content => "deb http://deb.theforeman.org/ ${::lsbdistcodename} $version\ndeb http://deb.theforeman.org/ plugins $version\n"
  } ->
  exec { "foreman-key":
    command => '/usr/bin/wget -q http://deb.theforeman.org/foreman.asc -O- | /usr/bin/apt-key add -',
    unless  => '/usr/bin/apt-key list | /bin/grep -q "Foreman Automatic Signing Key"'
  } ~>
  exec { "update-apt-foreman":
    command     => '/usr/bin/apt-get update',
    refreshonly => true
  }
}
