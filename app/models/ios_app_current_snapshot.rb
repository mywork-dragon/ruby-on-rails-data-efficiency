class IosAppCurrentSnapshot < ActiveRecord::Base

  serialize :screenshot_urls, Array
  serialize :ios_in_app_purchases, Hash

  belongs_to :app_store  

  belongs_to :ios_app
  belongs_to :ios_app_current_snapshot_job
  has_many :ios_app_categories_current_snapshots
  has_many :ios_app_categories, through: :ios_app_categories_current_snapshots

  has_many :ios_app_snapshot_exceptions
  has_many :ios_in_app_purchases

  enum mobile_priority: [:high, :medium, :low]
  enum user_base: [:elite, :strong, :moderate, :weak]

  # Sets columns to nil
  # @param columns An Array of Strings
  def set_columns_nil(columns)
    columns.each { |column_name| self.send("#{column_name}=", nil) }
  end

end
