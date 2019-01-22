# == Schema Information
#
# Table name: ios_app_snapshots
#
#  id                              :integer          not null, primary key
#  created_at                      :datetime
#  updated_at                      :datetime
#  name                            :string(191)
#  price                           :integer
#  size                            :integer
#  seller_url                      :string(191)
#  support_url                     :string(191)
#  version                         :string(191)
#  released                        :date
#  recommended_age                 :string(191)
#  description                     :text(65535)
#  ios_app_id                      :integer
#  required_ios_version            :string(191)
#  ios_app_snapshot_job_id         :integer
#  release_notes                   :text(65535)
#  seller                          :string(191)
#  developer_app_store_identifier  :integer
#  ratings_current_stars           :decimal(3, 2)
#  ratings_current_count           :integer
#  ratings_all_stars               :decimal(3, 2)
#  ratings_all_count               :integer
#  editors_choice                  :boolean
#  status                          :integer
#  exception_backtrace             :text(65535)
#  exception                       :text(65535)
#  icon_url_350x350                :string(191)
#  icon_url_175x175                :string(191)
#  ratings_per_day_current_release :decimal(10, 2)
#  first_released                  :date
#  by                              :string(191)
#  copywright                      :string(191)
#  seller_url_text                 :string(191)
#  support_url_text                :string(191)
#

class IosAppSnapshot < ActiveRecord::Base

  has_many :ios_app_snapshots_languages
  has_many :ios_app_snapshots_scr_shts, -> {order(position: :asc)}
  has_many :ios_app_languages, through: :ios_app_snapshots_languages
  
  belongs_to :ios_app
  belongs_to :ios_app_snapshot_job
  has_many :ios_app_categories_snapshots
  has_many :ios_app_categories, through: :ios_app_categories_snapshots

  has_many :ios_app_snapshot_exceptions
  has_many :ios_in_app_purchases

  belongs_to :app_store
  
  enum status: [:failure, :success]

  def get_company_name
    company = ios_app.get_company
    puts "###"
    puts company.inspect
    if company.nil?
      return ""
    else
      return company.name
    end
  end

  def api_json(_options = {})
    {
      name: name,
      last_updated: released.to_s,
      seller: seller,
      description: description,
      support_url: support_url,
      price: price ? price / 100.0 : nil, # convert cents to dollars
      current_version: version,
      current_version_rating: ratings_current_stars,
      current_version_ratings_count: ratings_current_count,
      all_version_rating: ratings_all_stars,
      all_version_ratings_count: ratings_all_count,
      has_in_app_purchases: ios_in_app_purchases.any?,
      categories: ios_app_categories_snapshots.as_json
    }
  end
end
