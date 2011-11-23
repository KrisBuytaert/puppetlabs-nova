class nova::api($enabled=false) {

  Exec['post-nova_config'] ~> Service['nova-api']
  Exec['nova-db-sync'] ~> Service['nova-api']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  exec { "initial-db-sync":
    command     => "/usr/bin/nova-manage db sync",
    refreshonly => true,
    require     => [Package["nova-common"], Nova_config['sql_connection']],
  }

  package { "nova-api":
    name    => $operatingsystem ? { 
	'default' => 'nova-api',
	'centos'  => 'openstack-nova-api' },
    ensure  => present,
    require => Package["python-greenlet"],
    notify  => Exec['initial-db-sync'],
  }

  service { "nova-api":
    name    => $operatingsystem ? {
	'default' => 'nova-api',
	'centos'  => 'openstack-nova-api'},

    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["nova-api"],
    #subscribe => File["/etc/nova/nova.conf"]
  }
}
