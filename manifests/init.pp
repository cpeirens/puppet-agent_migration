class agent_migration (
){

  # $plugin_basedir = $puppet_enterprise::params::mco_plugin_basedir
  # $mco_etc        = $puppet_enterprise::params::mco_etc
  $mco_etc            = '/etc/puppetlabs/mcollective'
  $mco_plugin_basedir = $::puppetversion ? {
      /^3/   => '/opt/puppet/libexec/mcollective/mcollective', # <= puppet3 not functional yet.
      default => '/opt/puppetlabs/mcollective/plugins/mcollective', #puppet4
  }

  # only do this on PE. OSS could be functional but more work is required.
  # the is_pe fact seems broken on 2015.2, this one should be sufficient
  if ($::pe_concat_basedir) {
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
  }

  if(defined(Service['mcollective'])){
    Class[$title] ~> Service['mcollective']
  }
}
