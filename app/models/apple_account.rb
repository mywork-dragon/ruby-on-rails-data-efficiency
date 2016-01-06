class AppleAccount < ActiveRecord::Base
  belongs_to :ios_device
  has_many :class_dumps
end
