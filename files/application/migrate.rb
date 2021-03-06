class MCollective::Application::Migrate<MCollective::Application
  description "Migrates an agent from one master to another"

  option :to_fqdn,
       :description => "Puppet Master FQDN to direct the agent to",
       :arguments      => ["-f", "--to_fqdn TO_FQDN"],
       :required       => true,
       :type           => String


  option :to_ip,
       :description => "Puppet Master IP Address to direct the agent to",
       :arguments      => ["-i", "--to_ip TO_IP"],
       :required       => true,
       :type           => String
  #TODO: accept a purge? parameter, and optionally execute the purge for them.
  # the puppet node purge commadn will not be accessible (root access) but puppetdb will be. Is that enough?
  def colorize(text, color_code)
   "\e[#{color_code}m#{text}\e[0m"
  end

  def red(text); colorize(text, 31); end
  def green(text); colorize(text, 32); end
  def white(text); colorize(text, 37); end

  def main
    mc = rpcclient("migrate")

    purge_commands=[]
    mc.puppet_agent(
          :to_fqdn => configuration[:to_fqdn],
          :to_ip   => configuration[:to_ip],
          :options => options) do |resp, simpleresp|

      sender    = simpleresp[:sender]
      statusmsg = resp[:body][:statusmsg]
      statuscode = resp[:body][:statuscode]
      if statuscode == 0
        printf("\n%-40s migration result: %s\n", sender, green(simpleresp[:data][:exitstatus]))
        purge_commands << "puppet node purge #{sender}"
      elsif statuscode == 1
        printf("\n%-40s migration result: %s\n", sender, red(simpleresp[:data][:exitstatus]))
        puts "The migrate agent returned an error: #{simpleresp[:data][:error]}"
        puts "Commands ran with results:"
        simpleresp[:data][:command_list].each do |cmd_result|
          puts cmd_result
        end
      else
        printf("\n%-40s migration result: %s\n", sender, red(simpleresp[:data][:exitstatus]))
        puts red("  - returned status code =#{statuscode}")
        puts red("  - Error: #{statusmsg}")
      end
    end

    puts("Copy the commands below to purge certs from this puppet master:")
    puts(" -- don't forget to run with sudo or as root --")
    purge_commands.each do |cmd|
      puts(white(cmd))
    end
    puts "\n"

    puts "Sign your certs here:"
    puts white("https://#{configuration[:to_fqdn]}/#/node_groups/inventory/nodes/certificates")

    printrpcstats
    halt mc.stats
  end
end

#  example simpleresp hash:
# {:msgtarget=>"/topic/mcollective.helloworld.reply",
#  :senderid=>"dev2.your.net",
#  :msgtime=>1261696663,
#  :hash=>"2d37daf690c4bcef5b5380b1e0c55f0c",
#  :body=>{:statusmsg=>"OK", :statuscode=>0, :data=>{:msg => "hello world"}},
#  :requestid=>"2884afb0b52cb38ea4d4a3146d18ef5f",
#  :senderagent=>"helloworld"}
