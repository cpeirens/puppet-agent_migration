metadata :name        => "migrate",
:description          => "Moves an agent to a new master",
:author               => "Brett Swift",
:license              => "MIT",
:version              => "0.1",
:url                  => "http://puppetlabs.com",
:timeout              => 120

action "agent_from_3_to_4", :description => "Uninstalls puppet, reinstalls from designated master curl script" do
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

  output :msg,
         :description => "error output if it failed",
         :display_as  => "errors or messages from client",
         :default     => "unknown"

   output :certlink,
         :description => "Convenience link for signing certificates",
         :display_as  => "Sign cert here:"
end


action "agent", :description => "Leaves puppet version, changes server and /etc/hosts for new master" do
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

  output :msg,
        :description => "error output if it failed",
        :display_as  => "errors or messages from client",
        :default     => "unknown"

  output :certlink,
        :description => "Convenience link for signing certificates",
        :display_as  => "Sign cert here:"
end



action "test_activation", :description => "Assists in determining which nodes are activated - giving more insight than just a filter" do
  output :fqdn,
        :description => "returns the fqdn if activated",
        :display_as  => "activated fqdn:"
end
