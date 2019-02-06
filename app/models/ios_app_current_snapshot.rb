# == Schema Information
#
# Table name: ios_app_current_snapshots
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
#  ratings_per_day_current_release :decimal(10, 2)
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

class IosAppCurrentSnapshot < ActiveRecord::Base

  serialize :screenshot_urls, Array
  serialize :ios_in_app_purchases, Hash

  belongs_to :app_store

  belongs_to :ios_app
  belongs_to :ios_app_current_snapshot_job
  has_many :ios_app_categories_current_snapshots
  has_many :ios_app_categories, -> { where 'ios_app_categories_current_snapshots.kind' => 0 }, through: :ios_app_categories_current_snapshots

  has_many :ios_app_snapshot_exceptions
  has_many :ios_in_app_purchases

  enum mobile_priority: [:high, :medium, :low] # this enum isn't used anymore. mobile_priority is determined by the mobile priority function
  enum user_base: [:elite, :strong, :moderate, :weak]

  # Sets columns to nil
  # @param columns An Array of Strings
  def set_columns_nil(columns)
    columns.each { |column_name| self.send("#{column_name}=", nil) }
  end

  def mobile_priority
    IosApp.mobile_priority_from_date(released: released)
  end

end
