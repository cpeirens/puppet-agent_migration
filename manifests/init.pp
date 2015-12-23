class agent_migration (
){

  # $plugin_basedir = $puppet_enterprise::params::mco_plugin_basedir
  # $mco_etc        = $puppet_enterprise::params::mco_etc
  $mco_etc            = '/etc/puppetlabs/mcollective'
  $mco_plugin_basedir = '/opt/puppet/libexec/mcollective/mcollective'

  file {"${mco_plugin_basedir}/agent/migrate.ddl":
    ensure => file,
    source => "puppet:///modules/${module_name}/agent/migrate.ddl",
  }

  file {"${mco_plugin_basedir}/agent/migrate.rb":
    ensure => file,
    source => "puppet:///modules/${module_name}/agent/migrate.rb",
  }

  if(defined(Service['pe-mcollective'])){
    Class[$title] ~> Service['pe-mcollective']
  }
}
