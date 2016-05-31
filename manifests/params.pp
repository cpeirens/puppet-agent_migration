class agent_migration::params{

  if($::kernel == 'Linux') {
    # $plugin_basedir = $puppet_enterprise::params::mco_plugin_basedir
    if str2bool($::is_pe) {
      #puppet3
      $mco_plugin_basedir = '/opt/puppet/libexec/mcollective/mcollective'
    } else {
      #puppet4
      if $::puppetversion and versioncmp($::puppetversion, '4.0.0') >= 0 {
        $mco_plugin_basedir = '/opt/puppetlabs/mcollective/plugins/mcollective'
      }
    }
  } elsif($::kernel == 'Windows') {
    if str2bool($::is_pe) {
      #puppet3 doesn't have the fact $::mco_confdir
      $mco_plugin_basedir = 'C:/ProgramData/PuppetLabs/mcollective/etc/plugins/mcollective'
    } else {
      #puppet4
      if $::puppetversion and versioncmp($::puppetversion, '4.0.0') >= 0 {
        # libdir for mco (from puppet_enterprise)
        #              "C:\ProgramData/PuppetLabs/mcollective/etc/plugins;
        #               C:\ProgramData/PuppetLabs/mcollective/plugins"
        #mco_confdir => C:/ProgramData/PuppetLabs/mcollective/etc
        $mco_plugin_basedir = "${::mco_confdir}/plugins"
      }
    }
  }
}
