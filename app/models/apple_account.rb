class AppleAccount < ActiveRecord::Base
  has_many :ios_devices
  has_many :class_dumps
  belongs_to :app_store
  
  enum kind: [:static, :flex, :v2_download]
end
