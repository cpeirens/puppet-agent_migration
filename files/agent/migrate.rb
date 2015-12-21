module MCollective
  module Agent
    class Migrate<RPC::Agent
      # require 'date'
      #
      # require 'logger'
      # require 'fileutils'
      #
      # $working_dir = '/var/log'
      # $log_file = "#{working_dir}/var/log/mcollective-migrator-migrate.log"
      #
      # FileUtils.mkdir_p $working_dir
      #
      # file = File.open($log_file, File::WRONLY | File::APPEND | File::CREAT)
      # $log = Logger.new(file)
      # $log.level = Logger::DEBUG

      action 'agent_from_3_to_4' do
        to_fqdn = request[:to_fqdn]
        to_ip = request[:to_ip]
        run_reinstall_migration(to_fqdn, to_ip)
      end

      action 'agent' do
        to_fqdn = request[:to_fqdn]
        to_ip = request[:to_ip]
        run_migration(to_fqdn, to_ip)
      end

      action 'test_activation' do
        reply[:fqdn] = `facter fqdn`
      end

      def log(msg)
        # $log.info(msg)
        # Log.info(msg)

        logfile='/var/log/mcollective-migrator.log'
        `/bin/touch #{logfile}`

        `/bin/echo '#{msg}' >> #{logfile}`
      end

      def run_migration(to_fqdn, to_ip)
        reply[:msg] = "not implemented yet. This will be used to migrate between masters of the same version."
      end

      def run_reinstall_migration(to_fqdn, to_ip)
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
        [ -f /etc/init.d/pe-puppet ] && puppet resource service pe-puppet ensure=stopped
        [ -f /etc/init.d/puppet ] &&  puppet resource service puppet ensure=stopped
        sed -i '/puppet/c\\#{to_ip} puppet #{to_fqdn}' /etc/hosts
        #{reinstall_script}
        /usr/bin/curl -o install_puppet.sh -k https://devcorepptl918.matrix.sjrb.ad:8140/packages/current/install.bash
        /bin/chmod +x install_puppet.sh
        /bin/bash install_puppet.sh
        /bin/rm -rf /etc/yum.repos.d/pe_repo.repo
        /bin/rm -rf install_puppet.sh
        [ -f /etc/init.d/puppet ] &&  /usr/local/bin/puppet resource service puppet ensure=running
OEF

        reinstall_file='/tmp/reinstall_puppet_from_new_master.sh'
        File.write(reinstall_file, full_script)

        reply[:msg] = run("nohup /bin/bash #{reinstall_file} &", :stdout => :out, :stderr => :err, :cwd => "/tmp")

        reply[:msg] = "Migration was triggered, and mcollective will uninstall now. Go look for your cert at https://#{to_fqdn}/#/node_groups/inventory/nodes/certificates"
      end



      activate_when do
        #deactivate if any puppet master services exist
        if (File.exists?("/etc/init.d/pe-puppetserver") ||
            File.exists?("/etc/init.d/pe-httpd") ||
            File.exists?("/etc/init.d/pe-console-services") ||
            File.exists?("/etc/init.d/pe-httpd") ||
            File.exists?("/etc/init.d/pe-memcached") ||
            File.exists?("/etc/init.d/pe-postgresql") ||
            File.exists?("/init.d/pe-puppet-dashboard-workers") ||
            File.exists?("/etc/init.d/pe-puppetdb") ||
            File.exists?("/etc/init.d/pe-puppetserver") ) then
            return false
        else
          return true
        end

      end
    end
  end
end
