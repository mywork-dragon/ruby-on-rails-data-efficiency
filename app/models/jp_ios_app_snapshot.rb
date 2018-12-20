# == Schema Information
#
# Table name: jp_ios_app_snapshots
#
#  id                             :integer          not null, primary key
#  name                           :string(191)
#  price                          :integer
#  size                           :integer
#  seller_url                     :string(191)
#  support_url                    :string(191)
#  version                        :string(191)
#  recommended_age                :string(191)
#  description                    :text(65535)
#  ios_app_id                     :integer
#  required_ios_version           :string(191)
#  release_notes                  :text(65535)
#  seller                         :string(191)
#  developer_app_store_identifier :integer
#  ratings_current_stars          :decimal(3, 2)
#  ratings_current_count          :integer
#  ratings_all_stars              :decimal(3, 2)
#  ratings_all_count              :integer
#  status                         :integer
#  job_identifier                 :integer
#  category                       :string(191)
#  user_base                      :integer
#  created_at                     :datetime
#  updated_at                     :datetime
#  business_country_code          :string(191)
#  business_country               :string(191)
#

class JpIosAppSnapshot < ActiveRecord::Base
  
  
  belongs_to :ios_app
  # belongs_to :ios_app_snapshot_job

  has_many :ios_app_snapshot_exceptions
  
  enum status: [:failure, :success]
  
  enum user_base: [:elite, :strong, :moderate, :weak]
  enum mobile_priority: [:high, :medium, :low]
  
end
