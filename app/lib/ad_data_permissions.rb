module AdDataPermissions
  # Requires a JSON serialized field named ad_data_permissions.
  AD_DATA_NETWORK_IDS = ['facebook', 'applovin', 'chartboost']

  AD_DATA_TIERS = {
    'tier-1' => ['facebook'],
    'tier-2' => ['facebook', 'applovin', 'chartboost']
  }

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def can_access_ad_network(network)
      enabled_ad_networks.include? network
    end

    def enabled_ad_networks
      networks = Set.new
      ad_permissions['enabled_ad_networks'].each {|network| networks.add(network)}
      ad_permissions['enabled_ad_network_tiers'].each do |tier|
        AD_DATA_TIERS[tier].each {|network| networks.add(network)}
      end
      disabled_ad_networks.each {|network| networks.delete(network) }
      networks.to_a.select {|x| visible_ad_networks.include? x}
    end

    def visible_ad_networks
      AD_DATA_NETWORK_IDS.select {|x| !hidden_ad_networks.include? x}
    end

    def disabled_ad_networks
      ad_permissions['disabled_ad_networks']
    end

    def hidden_ad_networks
      ad_permissions['hidden_ad_networks']
    end

    def enable_ad_network!(value)
      if !ad_permissions['enabled_ad_networks'].include?(value)
        ad_permissions['enabled_ad_networks'].append(value)
        save!
      end
      ad_permissions['disabled_ad_networks'].delete(value)
      save!
    end

    def disable_ad_network!(value)
      ad_permissions['enabled_ad_networks'].delete(value)
      if !ad_permissions['disabled_ad_networks'].include?(value)
        ad_permissions['disabled_ad_networks'].append(value)
        save!
      end
      save!
    end

    def unhide_ad_network!(value)
      ad_permissions['hidden_ad_networks'].delete(value)
      save!
    end

    def hide_ad_network!(value)
      if !ad_permissions['hidden_ad_networks'].include?(value)
        ad_permissions['hidden_ad_networks'].append(value)
        save!
      end
    end

    def enable_ad_network_tier!(value)
      if !ad_permissions['enabled_ad_network_tiers'].include?(value)
        ad_permissions['enabled_ad_network_tiers'].append(value)
        save!
      end
    end

    def disable_ad_network_tier!(value)
      ad_permissions['enabled_ad_network_tiers'].delete(value)
      save!
    end

    def ad_permissions
      if ad_data_permissions.nil?
        self.ad_data_permissions = {
          'enabled_ad_networks' => [],
          'hidden_ad_networks' => [],
          'disabled_ad_networks' => [],
          'enabled_ad_network_tiers' => []
        }
      end
      ad_data_permissions
    end
  end

  module ClassMethods

  end

end

