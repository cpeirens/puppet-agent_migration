module MCollective
  module Agent
    class Migrate<RPC::Agent

      action 'migrate_3_to_4' do
        to_fqdn = request[:to_fqdn]
        to_ip = request[:to_ip]
        run_migration(to_fqdn, to_ip, true)
      end

      action 'migrate' do
        to_fqdn = request[:to_fqdn]
        to_ip = request[:to_ip]
        run_migration(to_fqdn, to_ip, false)
      end

      private

      def execute(cmd)

        process = IO.popen("#{cmd}") do |io|
          while line = io.gets
            line.chomp!
            # log_debug(line)
          end
          io.close
          $result = $?.to_i == 0
          raise "Command #{cmd} failed execution" unless $result
        end

      rescue Exception => e
        # log_error e
        # log_fatal("Execution FAILED for: #{cmd}")
        return false
      else
        return true
      end

      def run_migration(to_fqdn, to_ip, reinstall_from_new_master=false)
        reinstall_script=''

        if reinstall_from_new_master then
          reinstall_script = <<REINSTALL
          /usr/bin/wget --no-check-certificate https://prd-artifactory.sjrb.ad:8443/artifactory/shaw-private-core-devops-ext-release/com/puppetlabs/puppet-enterprise/2015.2.3/puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz
          /bin/tar -xvf puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz
          cd puppet-enterprise-2015.2.3-el-6-x86_64
          ./puppet-enterprise-uninstaller -pdy
          /bin/rm -rf /root/puppet-enterprise-*
REINSTALL
        end

        script = <<OEF
        cd /root
        /etc/init.d/pe-puppet stop
        sed -i '/puppet/c\\#{to_ip} puppet #{to_fqdn}' /etc/hosts
        #{reinstall_script}
        curl -k https://devcorepptl918.matrix.sjrb.ad:8140/packages/current/install.bash | sudo bash
        rm -rf /etc/yum.repos.d/pe_repo.repo
        cd /root
        /etc/init.d/puppet start
OEF

        result =  execute(script)

        reply[:complete] = result
        reply.fail "Migration failed. Please intervene manually." unless result
      end

    end
  end
end
