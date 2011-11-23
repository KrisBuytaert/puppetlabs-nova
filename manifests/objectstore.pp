class nova::objectstore( $enabled=false ) {

  Exec['post-nova_config'] ~> Service['nova-objectstore']
  Exec['nova-db-sync'] ~> Service['nova-objectstore']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  package { "nova-objectstore":
    name    => $operatingsystem ? {
	'default' => 'nova-objectstore',
	'centos'  => 'openstack-nova-objectstore'},

    ensure  => present,

    require => Package["python-greenlet"]
  }

  service { "nova-objectstore":
    name    => $operatingsystem ? {
	'default' => 'nova-objectstore',
	'centos' => 'openstack-nova-objectstore'},

    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["nova-objectstore"],
    #subscribe => File["/etc/nova/nova.conf"]
  }
}
