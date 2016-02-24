metadata :name        => "migrate",
:description          => "Moves an agent to a new master",
:author               => "Brett Swift",
:license              => "Apache-2.0",
:version              => "0.0.4",
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


action "puppet_agent", :description => "Migration of Puppet 4 agents between masters" do
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
        :description => "Message with result of the command",
        :display_as  => "Message: ",
        :default     => "unknown"

  output :command_list,
        :description => "An Array of commands run and their exit codes",
        :display_as  => "Commands: ",
        :default     => ""

  output :error,
        :description => "error output if it failed",
        :display_as  => "errors or messages from client",
        :default     => "unknown"

  output :exitstatus,
        :description => "status of the last command run during migration",
        :display_as  => "Exit Status",
        :default     => "-1"

  output :certlink,
        :description => "Convenience link for signing certificates",
        :display_as  => "Sign cert here:"

  summarize do
       aggregate summary(:exitstatus)
  end
end



action "test_activation", :description => "Assists in determining which nodes are activated - giving more insight than just a filter" do
  output :fqdn,
        :description => "returns the fqdn if activated",
        :display_as  => "activated fqdn:"
end
