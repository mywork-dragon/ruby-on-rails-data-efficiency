module AdDataPermissions
  # Requires a JSON serialized field named ad_data_permissions.

  AD_DATA_TIERS = {
    'tier-1' => ['facebook'],
    'tier-2' => ['facebook', 'applovin', 'chartboost', 'unity-ads', 'mopub']
  }

  APP_PLATFORMS = ['ios', 'android']

  AD_DATA_SOURCES = [
    {
      id:'facebook',
      name:'Facebook',
      icon: 'https://www.google.com/s2/favicons?domain=facebook.com'
    },
    {
      id:'chartboost',
      name:'ChartBoost',
      icon: 'https://www.google.com/s2/favicons?domain=chartboost.com'
    },
    {
      id:'applovin',
      name:'Applovin',
      icon: 'https://www.google.com/s2/favicons?domain=applovin.com'
    },
    {
      id:'unity-ads',
      name:'Unity',
      icon: 'https://www.google.com/s2/favicons?domain=unity3d.com'
    },
    {
      id:'mopub',
      name:'MoPub',
      icon: 'https://www.google.com/s2/favicons?domain=mopub.com'
    }
  ]

  AD_DATA_NETWORK_IDS = AD_DATA_SOURCES.map {|x| x[:id]}
  AD_DATA_NETWORK_ID_TO_NAME = AD_DATA_SOURCES.map {|x| [x[:id], x[:name]]}.to_h

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods

    def restrict_ad_sources(source_ids)
      enabled_sources = self.available_ad_sources.select{|x, v| v[:can_access]}.keys
      source_ids.select {|source_id| enabled_sources.include? source_id}
    end

    def available_ad_sources
      # Returns a list of ad intel data sources (networks).
      # Returns:
      #   [{id:'facebook', name:'Facebook', icon: 'https://www.google.com/s2/favicons?domain=facebook.com', 'can_access': true},...]
      h = {}
      AdDataPermissions::AD_DATA_SOURCES.map do |source|
        if visible_ad_networks.include? source[:id]
          h[source[:id]] = source.clone
          h[source[:id]][:can_access] = self.can_access_ad_network(source[:id])
        end
      end
      h
    end

    def account_ad_data_settings
      settings = { ad_networks: {}, ad_network_tiers: {} }
      AdDataPermissions::AD_DATA_TIERS.each do |key, networks|
        settings[:ad_network_tiers][key] = {}
        settings[:ad_network_tiers][key][:networks] = networks
        settings[:ad_network_tiers][key][:can_access] = ad_permissions['enabled_ad_network_tiers'].include?(key)
      end
      AdDataPermissions::AD_DATA_SOURCES.each do |source|
        settings[:ad_networks][source[:id]] = source.clone
        settings[:ad_networks][source[:id]][:can_access] = self.can_access_ad_network(source[:id])
        settings[:ad_networks][source[:id]][:hidden] = hidden_ad_networks.include?(source[:id])
      end
      settings
    end

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
      hidden = ad_permissions['hidden_ad_networks']
      hidden
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

    def clear_ad_permissions!
      self.ad_data_permissions = {
        'enabled_ad_networks' => [],
        'hidden_ad_networks' => [],
        'disabled_ad_networks' => [],
        'enabled_ad_network_tiers' => ['tier-1'] # Enable tier-1 by default
      }
      save!
    end

    def ad_permissions
      if ad_data_permissions.nil?
        self.ad_data_permissions = {
          'enabled_ad_networks' => [],
          'hidden_ad_networks' => [],
          'disabled_ad_networks' => [],
          'enabled_ad_network_tiers' => ['tier-1'] # Enable tier-1 by default
        }
      end
      ad_data_permissions
    end
  end

  module ClassMethods

  end

end
