class agent_migration::windows {

  if($::kernel == 'windows') {

    file {'c:/windows/temp/migrate_to_new_master.ps1':
      ensure => present,
      source => 'puppet:///modules/agent_migration/migrate_to_new_master.ps1'
    }

  }
  
}
