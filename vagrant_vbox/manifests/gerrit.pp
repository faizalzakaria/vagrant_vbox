#
# Faizal Zakaria
#

import 'config.pp'

class gerrit {

  $gerrit_war_file = "${gerrit_home}/gerrit-${gerrit_version}.war"
  
  notice('Installing all the necessaries ... ')
  notice('Please wait, it might takes a while ... ')

  exec { "apt-get update":
	command => "/usr/bin/apt-get update"
  }
  
  package { "wget":
	ensure => installed,
	require  => Exec['apt-get update'],
  }
  
  package { "gerrit_java":
    ensure => installed,
    name   => "${gerrit_java}",
	require  => Exec['apt-get update'],
	provider => 'apt'
  }
  
  package { "git":
	ensure => installed,
	require  => Exec['apt-get update'],
	name => 'git',
  }

  package { "apache2":
	ensure => installed,
	require  => Exec['apt-get update'],
	name => 'apache2',
  }
  
  # Crate Group for gerrit
  group { $gerrit_group:
    gid        => "$gerrit_gid",
    ensure     => "present",
  }
  
  # Create User for gerrit-home
  user { $gerrit_user:
    comment    => "User for gerrit instance",
    home       => "$gerrit_home",
    shell      => "/bin/false",
    uid        => "$gerrit_uid",
    gid        => "$gerrit_gid",
    groups     => $gerrit_groups,
    ensure     => "present",
    managehome => true,
    require    => Group["$gerrit_group"],
	password   => '$1$OPeeLkJz$jfxWJ1rsyx6.Mr2fZYPMB/'
  }

  augeas { "add_user_sudoers":
    context => "/files/etc/sudoers",
    changes => [
                "set spec[user = '$gerrit_user']/user $gerrit_user",
                "set spec[user = '$gerrit_user']/host_group/host ALL",
                "set spec[user = '$gerrit_user']/host_group/command ALL",
                "set spec[user = '$gerrit_user']/host_group/command/runas_user ALL",
                ],
  }
  
  # Correct gerrit_home uid & gid
  file { "${gerrit_home}":
    ensure     => directory,
    owner      => "${gerrit_uid}",
    group      => "${gerrit_gid}",
    require    => [
                   User["${gerrit_user}"],
                   Group["${gerrit_group}"],
                   ]
  }
  
  if versioncmp($gerrit_version, '2.5') < 0 {
    $warfile = "gerrit-${gerrit_version}.war"
  }
  else {
    $warfile = "gerrit-full-${gerrit_version}.war"
  }
  
  exec { "download_gerrit":
	command => "wget -q '${download_mirror}/${warfile}' -O ${gerrit_war_file}",
	path    => "/usr/bin/",
	creates => "${gerrit_war_file}",
	require => [ 
		         Package["wget"],
		         User["${gerrit_user}"],
		         File[$gerrit_home]
		         ],
  }
  
  # Changes user / group of gerrit war
  file { "gerrit_war":
	path => "${gerrit_war_file}",
	owner => "${gerrit_user}",
	group => "${gerrit_group}",
	require => Exec["download_gerrit"],
  }
  
  $command = "sudo -u ${gerrit_user} java -jar ${gerrit_war_file} init -d $gerrit_home/${gerrit_site_name} --batch --no-auto-start"
  
  # Initialisation of gerrit site
  exec {
    "init_gerrit":
      cwd       => $gerrit_home,
      command   => $command,
	  path      => '/usr/bin',
      creates   => "${gerrit_home}/${gerrit_site_name}/bin/gerrit.sh",
      logoutput => on_failure,
	  user => "${gerrit_user}",
      require   => [
                    Package["${gerrit_java}"],
                    File["gerrit_war"],
                    ],
  }

  file {'/etc/default/gerritcodereview':
    ensure  => present,
    content => "GERRIT_SITE=${gerrit_home}/${gerrit_site_name}\n",
    owner   => $gerrit_user,
    group   => $gerrit_group,
    mode    => '0444',
    require => Exec['init_gerrit']
  }
  
  file {'/etc/init.d/gerrit':
    ensure  => symlink,
    target  => "${gerrit_home}/${gerrit_site_name}/bin/gerrit.sh",
    require => [
                Exec['init_gerrit'],
                File['/etc/default/gerritcodereview']
    ]
  }
    
  # Manage Gerrit's configuration file (augeas would be more suitable).
  file { "${gerrit_home}/${gerrit_site_name}/etc/gerrit.config":
    content  => template('gerrit_config/gerrit.config'),
    owner   => $gerrit_user,
    group   => $gerrit_group,
    mode    => '0744',
    require => Exec['init_gerrit'],
    notify  => Service['gerrit']
  }

  service { 'gerrit':
    ensure    => running,
    hasstatus => false,
    pattern   => 'GerritCodeReview',
    require   => File['/etc/init.d/gerrit']
  }
}

include gerrit

