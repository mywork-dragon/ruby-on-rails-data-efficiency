module Sdk
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def platform
      self.class.platform
    end

    def publisher
      ios? ? ios_developer : android_developer
    end

    def ios?
      platform == 'ios'
    end

    def android?
      platform == 'android'
    end
    
    def top_200_apps
      # This all apps in the top 200 apps which have this sdk installed.
      get_current_apps(app_ids: self.class.app_class.top_n_app_ids(200), limit: 200)[:apps]
    end
    
    def mightysignal_public_page_link
      "https://mightysignal.com/sdk/#{platform}/#{id}/#{name.parameterize}"
    end
  end

  module ClassMethods

    def sdks_installed_in_top_n_apps(n)
      app_es_records = FilterService.filter_apps(
        app_filters: {"appIds" => app_class.top_n_app_ids(n)},
      page_size: n, platform: app_class.platform).to_a

      sdks = Hash.new(0)

      app_es_records.map do |es_record|
        es_record.installed_sdks.map do | es_sdk_record|
          sdks[es_sdk_record["id"]] += 1
        end
      end

      sdks = sdks.map {|sdk_id, install_count| [sdk_id, install_count]}
      sdk_order = sdks.map {|sdk_id, install_count| [sdk_id, 1.0 / install_count] }.to_h

      sdk_ids = sdks.map {|sdk_id, _|  sdk_id}

      if sdk_ids.count <= 0
        return []
      end

      sdks = self.find_by_sql("SELECT #{self.table_name}.* FROM #{self.table_name}, tag_relationships  WHERE
          #{self.table_name}.id =  taggable_id
          AND `tag_relationships`.`taggable_id` in (#{sdk_ids.join(',')})
          AND `tag_relationships`.`taggable_type` = '#{self.name}'
           GROUP BY `tag_relationships`.`taggable_id`;").to_a

      # Save the id of the original sdk, in order to sort by the original install base
      sdks_with_resolved_links = sdks.map {|sdk| sdk.outbound_sdk ? [sdk.outbound_sdk, sdk.id] : [sdk,  sdk.id]}

      sorted_sdks = sdks_with_resolved_links.sort_by {|a| sdk_order[a[1]]}
      sorted_sdks.map {|sdk, id| sdk}
    end

    def top_n_tags(n)
      sdks_installed_in_top_n_apps(n).flat_map {|sdk| sdk.tags}.uniq
    end

    def top_200_tags #tags that have sdks in the top 200
      top_n_tags(200)
    end

  end

end
