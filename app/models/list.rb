# == Schema Information
#
# Table name: lists
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  filter     :text(65535)
#

class List < ActiveRecord::Base

  has_many :lists_users
  has_many :users, through: :lists_users

  has_many :listables_lists
  has_many :ios_apps, through: :listables_lists, source: :listable, source_type: 'IosApp'
  has_many :android_apps, through: :listables_lists, source: :listable, source_type: 'AndroidApp'
  
end
