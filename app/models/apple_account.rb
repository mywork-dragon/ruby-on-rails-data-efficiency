class AppleAccount < ActiveRecord::Base
  belongs_to :ios_device
  has_many :class_dumps
  belongs_to :app_store
end
