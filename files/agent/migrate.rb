module MCollective
  module Agent
    class Migrate<RPC::Agent
      require 'date'

      action 'puppet_reinstall' do
        to_fqdn = request[:to_fqdn]
        run_reinstall_migration(to_fqdn)
      end

      action 'puppet_agent' do
        to_fqdn = request[:to_fqdn]
        run_migration(to_fqdn)
      end

      action 'test_activation' do
        reply[:fqdn] = run("hostname -f", :stdout => :out, :stderr => :err)
      end

      def run_migration(to_fqdn)
        kernel=run("facter kernel", :stdout => kernel)
        case kernel
        when "Windows"
          run_migration_windows
        when "Linux"
          run_migration_linux
        else
          reply[:msg] = "kernel #{kernel} not supported"
          exit
        end
      end

      def run_migration_windows(to_fqdn)
        update_puppet_conf_and_nuke_ssl_cmd="powershell -file c:/windows/temp/migrate_to_new_master.ps1 -to_fqdn #{to_fqdn}"
        run_command(update_puppet_conf_and_nuke_ssl_cmd)

        certlink="https://#{to_fqdn}/#/node_groups/inventory/nodes/certificates"
        reply[:msg] = "Migration complete. Go look for your cert at #{certlink}"
        reply[:certlink]=certlink
      end

      def run_migration_linux(to_fqdn)
        # update_puppet_conf_cmd="puppet resource ini_setting 'server' ensure=present path='/etc/puppetlabs/puppet/puppet.conf' section='main' setting='server' value='#{to_fqdn}'" #hmm, doesn't work?
        update_puppet_conf_cmd="sed -i '/server/cserver = #{to_fqdn}' /etc/puppetlabs/puppet/puppet.conf"
        nuke_ssl_dir_cmd="rm -rf /etc/puppetlabs/puppet/ssl"
        # nuke_ssl_dir_cmd="puppet resource file '/etc/puppetlabs/puppet/ssl' ensure=absent force=true"   #hmm, doesn't work?
        restart_agent_cmd='/etc/init.d/puppet restart'
        reply[:exitstatus] = "initialized"
        reply[:command_list] = []
        run_command(update_puppet_conf_cmd)
        run_command(nuke_ssl_dir_cmd)
        run_command(restart_agent_cmd)

        certlink="https://#{to_fqdn}/#/node_groups/inventory/nodes/certificates"
        reply[:msg] = "Migration complete. Go look for your cert at #{certlink}"
        reply[:certlink]=certlink
      end

      def run_reinstall_migration(to_fqdn)
        reinstall_script=''
          reinstall_script = <<REINSTALL
          /usr/bin/wget --no-check-certificate https://prd-artifactory.sjrb.ad:8443/artifactory/shaw-private-core-devops-ext-release/com/puppetlabs/puppet-enterprise/2015.2.3/puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz
          /bin/tar -xvf puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz
          /bin/bash puppet-enterprise-2015.2.3-el-6-x86_64/puppet-enterprise-uninstaller -pdy
          /bin/rm -rf puppet-enterprise-*
REINSTALL

        full_script = <<OEF
        #!/bin/bash
        set -x
        exec 2> >(logger)
        [ -f /etc/init.d/puppet ] &&  puppet resource service puppet ensure=stopped
        #{reinstall_script}
        /usr/bin/curl -o /tmp/install_puppet.sh -k https://#{to_fqdn}:8140/packages/current/install.bash
        /bin/chmod +x /tmp/install_puppet.sh
        /bin/bash /tmp/install_puppet.sh
        /bin/rm -rf /etc/yum.repos.d/pe_repo.repo
        /bin/rm -rf /etc/yum.repos.d/pc_repo.repo
        /bin/rm -rf /tmp/install_puppet.sh
        [ -f /etc/init.d/puppet ] &&  /usr/local/bin/puppet resource service puppet ensure=running
OEF

        reinstall_file='/tmp/reinstall_puppet_from_new_master.sh'
        File.write(reinstall_file, full_script)

        reply[:msg] = run("nohup /bin/bash #{reinstall_file} &", :stdout => :out, :stderr => :err, :cwd => "/tmp")
        certlink="https://#{to_fqdn}/#/node_groups/inventory/nodes/certificates"
        reply[:msg] = "Migration was triggered, and mcollective will uninstall now. Go look for your cert at #{certlink}"
        reply[:certlink]=certlink
      end

      activate_when do
        #deactivate if any puppet master services exist. Migrating a master would be bad.
        #TODO: use a fact?
        if (File.exists?("/etc/init.d/pe-puppetserver") ||
            File.exists?("/etc/init.d/pe-httpd") ||
            File.exists?("/etc/init.d/pe-console-services") ||
            File.exists?("/etc/init.d/pe-memcached") ||
            File.exists?("/etc/init.d/pe-postgresql") ||
            File.exists?("/etc/init.d/pe-puppet-dashboard-workers") ||
            File.exists?("/etc/init.d/pe-puppetdb")) then
            return false
        else
          return true
        end
      end

      private

      def run_command(cmd)
        Log.info("Executing:   #{cmd}")
        #create reply[:out] and reply[:error] entries in the hash.
        status = run(cmd, :stdout => :out, :stderr => :error)
        reply[:exitstatus] = "Success" if status
        reply[:command_list] << "Command: #{cmd} exited with: #{status}"

        Log.info("Status is:   #{reply[:exitstatus]}")
        Log.info("STDOUT:")
        Log.info(reply[:out])
        Log.info("Execution Success for: #{cmd}")
      end
    end
  end
end
