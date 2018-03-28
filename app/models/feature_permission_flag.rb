class FeaturePermissionFlag < ActiveRecord::Base
  validates :name, uniqueness: true

  class << self
    
    def global_feature_flag_map
      available_feature_map = {}

      FeaturePermissionFlag.all.pluck(:name, :enabled).each do |name, enabled|
        available_feature_map[name] = enabled
      end

      available_feature_map
    end

    def all_feature_names
      FeaturePermissionFlag.all.pluck(:name)
    end

  end

end
