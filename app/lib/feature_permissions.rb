module FeaturePermissions
  # Requires a JSON serialized field named feature_permissions.

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    
    def feature_flag_map
      base_map = FeaturePermissionFlag.global_feature_flag_map
      base_map.merge(self.get_feature_permissions)
    end

    def can_access_feature?(feature)
      feature_flag_map[feature] == true
    end

    def enable_feature!(feature)
      if get_feature_permissions[feature] != true
        get_feature_permissions[feature] = true
        save!
      end
    end

    def disable_feature!(feature)
      if get_feature_permissions[feature] != false
        get_feature_permissions[feature] = false
        save!
      end
    end

    def get_feature_permissions
      if self.feature_permissions.nil?
        self.feature_permissions = {}
      end
      self.feature_permissions
    end

  end

  module ClassMethods

    def bulk_enable_feature!(feature, ids: [])
      self.where(:id => ids).each do |i|
        i.enable_feature!(feature)
      end
      true
    end

    def bulk_disable_feature!(feature, ids: [])
      self.where(:id => ids).each do |i|
        i.disable_feature!(feature)
      end
      true
    end

    def disable_feature_for_all!(feature)
      self.all.each do |i|
        i.disable_feature!(feature)
      end
      true
    end

    def all_ids_with_feature_enabled(feature)
      ids = []
      self.all.each do |i|
        ids << i.id if i.can_access_feature?(feature)
      end
      ids
    end

  end

end
