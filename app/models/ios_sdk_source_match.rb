class IosSdkSourceMatch < ActiveRecord::Base
  belongs_to :source_sdk, class_name: 'IosSdk'
  belongs_to :match_sdk, class_name: 'IosSdk'
end
