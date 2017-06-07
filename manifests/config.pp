# == Class: transmission::config
#
# This class handles the main configuration files for the module
#
# == Actions:
#
# * Deploys configuration files and cron
#
# === Authors:
#
# Craig Watson <craig@cwatson.org>
#
# === Copyright:
#
# Copyright (C) Craig Watson
# Published under the Apache License v2.0
#
class transmission::config {

  # == Defaults

  File {
    owner   => "${::transmission::user}",
    group   => "${::transmission::group}",
    require => Package[$::transmission::params::packages],
  }

  # == Transmission config

  file { "${::transmission::config_dir}":
    ensure  => directory,
    owner   => "${::transmission::user}",
    group   => "${::transmission::group}",
    mode    => 'u=rwx,g=rwxs,o=rx',
    require => Package['transmission-cli','transmission-common','transmission-daemon'],
  }

  file { "${::transmission::config_dir}/settings.json.puppet":
    ensure  => file,
    owner   => "${::transmission::user}",
    group   => "${::transmission::group}",
    mode    => '0600',
    content => template('transmission/settings.json.erb'),
    require => File["${::transmission::config_dir}"],
  }

  file { "${::transmission::config_dir}/settings.json.puppet":
    ensure  => file,
    mode    => '0600',
    content => template('transmission/settings.json.erb'),
  }

  # == Transmission Home

  file { $::transmission::params::home_dir:
    ensure => directory,
    mode   => '0770',
    owner   => "${::transmission::user}",
    group   => "${::transmission::group}",
  }

  file { "${::transmission::params::home_dir}/settings.json":
    ensure  => link,
    target  => "${::transmission::config_dir}/settings.json",
    require => File[$::transmission::params::home_dir],
  }

  # == Blocklist update cron

  cron { 'transmission_update_blocklist':
    ensure  => $::transmission::params::cron_ensure,
    command => "/usr/bin/transmission-remote ${::transmission::params::remote_command_auth} --blocklist-update > /dev/null",
    require => Package['transmission-cli','transmission-common','transmission-daemon'],
    user    => 'root',
    minute  => '0',
    hour    => '*',
  }

}
