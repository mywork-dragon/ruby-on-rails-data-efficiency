# == Schema Information
#
# Table name: ios_app_current_snapshot_backups
#
#  id                              :integer          not null, primary key
#  name                            :string(191)
#  price                           :integer
#  size                            :integer
#  seller_url                      :string(191)
#  version                         :string(191)
#  released                        :date
#  recommended_age                 :string(191)
#  description                     :text(65535)
#  ios_app_id                      :integer
#  required_ios_version            :string(191)
#  ios_app_current_snapshot_job_id :integer
#  release_notes                   :text(65535)
#  developer_app_store_identifier  :integer
#  ratings_current_stars           :decimal(3, 2)
#  ratings_current_count           :integer
#  ratings_all_stars               :decimal(3, 2)
#  ratings_all_count               :integer
#  icon_url_60x60                  :text(65535)
#  icon_url_100x100                :text(65535)
#  icon_url_512x512                :text(65535)
#  ratings_per_day_current_release :decimal(10, )
#  first_released                  :date
#  game_center_enabled             :boolean
#  bundle_identifier               :string(191)
#  currency                        :string(191)
#  screenshot_urls                 :text(65535)
#  app_store_id                    :integer
#  app_identifier                  :integer
#  mobile_priority                 :integer
#  user_base                       :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  app_link_urls                   :text(65535)
#  has_in_app_purchases            :boolean
#  seller_name                     :text(65535)
#  latest                          :boolean          default(TRUE)
#  last_scraped                    :datetime
#  etag                            :string(64)
#

class IosAppCurrentSnapshotBackup < ActiveRecord::Base
  serialize :screenshot_urls, Array
  serialize :ios_in_app_purchases, Hash

  enum mobile_priority: [:high, :medium, :low]
  enum user_base: [:elite, :strong, :moderate, :weak]

end
