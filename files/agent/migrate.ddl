metadata :name        => "migrate",
:description          => "Moves an agent to a new master",
:author               => "Brett Swift",
:license              => "MIT",
:version              => "0.1",
:url                  => "http://puppetlabs.com",
:timeout              => 120

action "migrate_3_to_4", :description => "Uninstalls puppet, reinstalls from designated master curl script" do
  input :to_fqdn,
        :prompt      => "new master fqdn",
        :description => "Master FQDN to direct the agent to",
        :optional    => false,
        :validation  => '.*',
        :maxlength   => 1024,
        :timeout     => 120,
        :type        => :string

  input :to_ip,
        :prompt      => "new master ip",
        :description => "Master IP Address to direct the agent to",
        :optional    => false,
        :validation  => '.*',
        :maxlength   => 1024,
        :timeout     => 120,
        :type        => :string

  output :complete,
         :description => "Whether migration was successful",
         :display_as  => "Migrated?",
         :default     => "unknown"
end


action "migrate", :description => "Leaves puppet version, changes server and /etc/hosts for new master" do
  input :to_fqdn,
        :prompt      => "new master fqdn",
        :description => "Master FQDN to direct the agent to",
        :optional    => false,
        :validation  => '.*',
        :maxlength   => 1024,
        :timeout     => 120,
        :type        => :string

  input :to_ip,
        :prompt      => "new master ip",
        :description => "Master IP Address to direct the agent to",
        :optional    => false,
        :validation  => '.*',
        :maxlength   => 1024,
        :timeout     => 120,
        :type        => :string

  output :complete,
         :description => "Was migration successful",
         :display_as  => "Migrated?",
         :default     => "unknown"
end
