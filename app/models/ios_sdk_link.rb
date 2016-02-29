class IosSdkLink < ActiveRecord::Base
  belongs_to :source_sdk, class_name: 'IosSdk'
  belongs_to :dest_sdk, class_name: 'IosSdk'
end
