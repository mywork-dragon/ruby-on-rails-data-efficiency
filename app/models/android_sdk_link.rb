# == Schema Information
#
# Table name: android_sdk_links
#
#  id            :integer          not null, primary key
#  source_sdk_id :integer
#  dest_sdk_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class AndroidSdkLink < ActiveRecord::Base
  belongs_to :source_sdk, class_name: 'AndroidSdk'
  belongs_to :dest_sdk, class_name: 'AndroidSdk'

  before_create :ensure_no_chains

  def ensure_no_chains
    raise "Cannot link to an SDK that itself links to another" if AndroidSdkLink.where(source_sdk_id: self.dest_sdk_id).count > 0
  end
end
