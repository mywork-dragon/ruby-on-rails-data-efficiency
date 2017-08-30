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
