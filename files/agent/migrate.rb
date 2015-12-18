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
        run_migration(to_fqdn, to_ip, true)
      end

      action 'agent' do
        to_fqdn = request[:to_fqdn]
        to_ip = request[:to_ip]
        run_migration(to_fqdn, to_ip, false)
      end

      def log(msg)
        # $log.info(msg)
        # Log.info(msg)

        logfile='/var/log/mcollective-migrator.log'
        `/bin/touch #{logfile}`

        `/bin/echo '#{msg}' >> #{logfile}`
      end

      def run_migration(to_fqdn, to_ip, reinstall_from_new_master=false)

        commands = []
        log("Reinstalling puppet from a new master: #{to_fqdn}") if reinstall_from_new_master
        log("This node is moving to a new master: #{to_fqdn}") unless reinstall_from_new_master

        commands << "[ -f /etc/init.d/pe-puppet ] && puppet resource service pe-puppet ensure=stopped"
        commands << "[ -f /etc/init.d/puppet ] &&  puppet resource service puppet ensure=stopped"
        commands << "sed -i '/puppet/c\\#{to_ip} puppet #{to_fqdn}' /etc/hosts"
        if reinstall_from_new_master then
          commands << "/usr/bin/wget --no-check-certificate https://prd-artifactory.sjrb.ad:8443/artifactory/shaw-private-core-devops-ext-release/com/puppetlabs/puppet-enterprise/2015.2.3/puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz"
          commands << "/bin/tar -xvf puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz"
          commands << "/bin/bash puppet-enterprise-2015.2.3-el-6-x86_64/puppet-enterprise-uninstaller -pdy"
          commands << "/bin/rm -rf puppet-enterprise-*"
        end
        commands << "/usr/bin/curl -o install_puppet.sh -k https://devcorepptl918.matrix.sjrb.ad:8140/packages/current/install.bash"
        commands << "/bin/chmod +x install_puppet.sh"
        commands << "/bin/bash install_puppet.sh"
        commands << "/bin/rm -rf /etc/yum.repos.d/pe_repo.repo"
        commands << "/bin/rm -rf install_puppet.sh"
        commands << "[ -f /etc/init.d/pe-puppet ] && puppet resource service pe-puppet ensure=running"
        commands << "[ -f /etc/init.d/puppet ] &&  puppet resource service puppet ensure=running"

        out = ""
        err = ""
        success=true
        commands.each { |cmd|
          # status = run(cmd, :stdout => out, :stderr => err, :cwd => "/tmp", :chomp => true)
          status = `#{cmd}`
          log("++++ stdout for: CMD: #{cmd}  ")
          log(out)
          log("---- end command #{cmd}")
          log("++++ stderr for: CMD: #{cmd} ")
          log(out)
          log("---- end command #{cmd}")
          reply.fail! "Migration failed running command: #{cmd} with error: #{err} Please intervene manually." unless status
          success=false unless status
        }

        reply[:status] = "Did migration succeed:  #{result}"
      end

    end
  end
end
