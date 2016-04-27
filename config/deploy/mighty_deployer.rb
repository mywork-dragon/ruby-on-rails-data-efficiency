require 'json'
require 'aws-sdk'
require 'httparty'

require_relative '../../lib/clients/aws_api'
require_relative '../../lib/clients/wtf_is_my_ip'

module MightyDeployer

  MIGHTY_SIGNAL_PUBLIC_IP = '173.247.196.70'
  LOCAL_STAGES = [:darth_vader, :kylo_ren]

  @targets = []

  def self.deploy_to(server_symbols)
    valid_symbols = [:web, :scraper, :sdk_scraper, :sdk_scraper_live_scan, :darth_vader, :kylo_ren, :staging, :ios_live_scan, :monitor, :aviato]
    
    raise "Input an array with a combination of these values: #{valid_symbols}" unless (server_symbols - valid_symbols).empty?

    cloud_stages = server_symbols - LOCAL_STAGES
    local_stages = server_symbols & LOCAL_STAGES

    add_cloud_servers(cloud_stages) if cloud_stages.any?
    add_local_servers(local_stages) if local_stages.any?

    configure_servers
  end

  def self.add_server(ip:, roles:, user: 'deploy', port: 22)
    @targets << {
      ip: ip,
      roles: [:app] + roles,
      user: user,
      port: port
    }
  end

  def self.configure_servers
    @targets.each do |target|
      server target[:ip], roles: target[:roles], user: target[:user], port: target[:port]
    end
  end

  def self.add_cloud_servers(stages)

    stages.each do |stage|

      ips = AwsApi.new.deploy_ips_for_stage(stage)

      ips.each do |ip|

        roles = [stage]

        # stage specific hacks
        roles << :db if stage == :web # for migrations
        roles << :scraper_master if stage == :scraper && ip == '52.3.11.3'
        # TODO: move scraper_master to it's own stage

        add_server(ip: ip, roles: roles)

      end

    end

  end

  def self.add_local_servers(stages)

    map = {
      kylo_ren: {
        local_ips: ["192.168.2.102"],
        remote_ips: [MIGHTY_SIGNAL_PUBLIC_IP],
        user: 'kylo-ren',
        port: 50001
      },
      darth_vader: {
        local_ips: ["192.168.2.101"],
        remote_ips: [MIGHTY_SIGNAL_PUBLIC_IP],
        user: 'darth-vader',
        port: 50000
      }
    }

    stages.each do |stage|

      entry = map[stage]

      if inside_mighty_signal_network?
        
        entry[:local_ips].each do |ip|
          add_server(ip: ip, roles: [stage], user: entry[:user])
        end

      else

        entry[:remote_ips].each do |ip|
          add_server(ip: ip, roles: [stage], user: entry[:user], port: entry[:port])
        end

      end

    end

  end

  def self.inside_mighty_signal_network?
    info = WtfIsMyIp.connection_info
    info[:ip] == MIGHTY_SIGNAL_PUBLIC_IP
  end 

end
