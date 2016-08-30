class AppStore < ActiveRecord::Base

  has_many :app_stores_ios_apps
  has_many :ios_apps, -> { uniq }, through: :app_stores_ios_apps
  has_many :app_store_ios_apps_backups
  has_many :ios_app_backups, source: :ios_app, through: :app_store_ios_apps_backups

  has_many :ios_app_category_names
  has_many :ios_app_categories, through: :ios_app_category_names

  has_many :ios_app_category_name_backups
  has_many :ios_app_category_backups, through: :ios_app_category_name_backups, source: :ios_app_category

  has_many :ios_app_current_snapshots
  has_many :ios_app_current_snapshot_backups

  has_one :app_store_scaling_factor
  has_one :app_store_scaling_factor_backup

  validates_uniqueness_of :priority, allow_blank: true
  validates_uniqueness_of :display_priority, allow_blank: true

  def disable(automate: false)
    ret = update(enabled: false)

    return ret unless automate

    puts 'Cleaning disabled app store to app links'
    AppStoresIosApp.clean_disabled_stores

    puts 'Kicking off job to reset app store availability on apps'
    if Rails.env.production?
      AppStoreInternationalAvailabilityWorker.perform_async
    else
      AppStoreInternationalAvailabilityWorker.new.perform
    end
  end

  def move_to_id(dest)
    curr_id = id
    last_id = AppStore.order(id: :desc).first.id
    temp_id = last_id + 1
    move = AppStore.find(dest)
    move.update!(id: temp_id)
    update!(id: dest)
    move.update(id: curr_id)
  end
end
