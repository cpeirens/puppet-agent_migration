class agent_migration (
  $mco_plugin_basedir =$agent_migration::params::mco_plugin_basedir,
  ) inherits agent_migration::params {

  # only do this on PE. OSS could be functional but more work is required.
  # the is_pe fact seems broken on 2015.2, this one should be sufficient
  #if puppet3 PE || puppet4 PE
  if str2bool($::is_pe) or $::puppetversion  {
    file {"${mco_plugin_basedir}/agent/migrate.ddl":
      ensure => file,
      source => "puppet:///modules/${module_name}/agent/migrate.ddl",
    }

    file {"${mco_plugin_basedir}/agent/migrate.rb":
      ensure => file,
      source => "puppet:///modules/${module_name}/agent/migrate.rb",
    }

    file {"${mco_plugin_basedir}/application/migrate.rb":
      ensure => file,
      source => "puppet:///modules/${module_name}/application/migrate.rb",
    }
  } else {
    notice("This version of puppet is not supported")
  }

  if $::kernel == 'Windows' {
    include agent_migration::windows
  }

  if(defined(Service['mcollective'])){
    Class[$title] ~> Service['mcollective']
  }
}
