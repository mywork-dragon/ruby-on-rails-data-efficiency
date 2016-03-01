class IosSdkLink < ActiveRecord::Base
  belongs_to :source_sdk, class_name: 'IosSdk'
  belongs_to :dest_sdk, class_name: 'IosSdk'

  before_create :ensure_no_chains

  def ensure_no_chains
    raise "Cannot link to an sdk that itself links to another" if IosSdkLink.where(source_sdk_id: self.dest_sdk_id).count > 0
  end
end
