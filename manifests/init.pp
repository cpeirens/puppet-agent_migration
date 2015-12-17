class agent_migration (
) inherits agent_migration::params {

  # $plugin_basedir = $puppet_enterprise::params::mco_plugin_basedir
  # $mco_etc        = $puppet_enterprise::params::mco_etc
  $mco_etc            = '/etc/puppetlabs/mcollective'
  $mco_plugin_basedir = '/opt/puppet/libexec/mcollective/mcollective'
  File {
    owner => $pe_mcollective::params::root_owner,
    group => $pe_mcollective::params::root_group,
    mode  => $pe_mcollective::params::root_mode,
  }

  file {"${mco_plugin_basedir}/agent/migrate.ddl":
    ensure => file,
    source => "puppet:///modules/${module_name}/agent/migrate.ddl",
  }

  file {"${mco_plugin_basedir}/agent/migrate.rb":
    ensure => file,
    source => "puppet:///modules/${module_name}/agent/migrate.rb",
  }

  Class[$title] ~> Service['pe-mcollective']

}
