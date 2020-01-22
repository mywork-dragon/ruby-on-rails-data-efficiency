# == Schema Information
#
# Table name: android_app_snapshots
#
#  id                               :integer          not null, primary key
#  created_at                       :datetime
#  updated_at                       :datetime
#  name                             :string(191)
#  price                            :integer
#  size                             :integer
#  updated                          :date
#  seller_url                       :string(191)
#  version                          :string(191)
#  released                         :date
#  description                      :text(65535)
#  android_app_id                   :integer
#  google_plus_likes                :integer
#  top_dev                          :boolean
#  in_app_purchases                 :boolean
#  required_android_version         :string(191)
#  content_rating                   :string(191)
#  seller                           :string(191)
#  ratings_all_stars                :decimal(3, 2)
#  ratings_all_count                :integer
#  status                           :integer
#  android_app_snapshot_job_id      :integer
#  in_app_purchase_min              :integer
#  in_app_purchase_max              :integer
#  downloads_min                    :integer
#  downloads_max                    :integer
#  icon_url_300x300                 :string(191)
#  developer_google_play_identifier :string(191)
#  apk_access_forbidden             :boolean
#

class AndroidAppSnapshot < ActiveRecord::Base

  belongs_to :android_app
  belongs_to :android_app_snapshot_job
  has_many :android_app_snapshot_exceptions

  has_many :android_app_snapshots_scr_shts, -> {order(position: :asc)}
  has_many :android_app_categories_snapshots
  has_many :android_app_categories, through: :android_app_categories_snapshots

  enum status: [:failure, :success]

  SNAPSHOT_ATTRIBUTES = %i[
    name
    description
    price
    seller
    seller_url
    released
    size
    top_dev
    required_android_version
    version
    content_rating
    ratings_all_stars
    ratings_all_count
    in_app_purchases
    icon_url_300x300
    developer_google_play_identifier
  ].freeze

  def api_json(_options = {})
    {
      name: name,
      last_updated: released.to_s,
      seller: seller,
      current_version: version,
      description: description,
      price: price ? price / 100.0 : nil, # convert cents to dollars
      all_version_rating: ratings_all_stars,
      all_version_ratings_count: ratings_all_count,
      downloads_min: downloads_min,
      downloads_max: downloads_max,
      categories: android_app_categories.as_json
    }
  end

  # Disabled for now
  def screenshot_urls
    return []
    # JSON.parse(MightyAws::S3.new.retrieve(
    #   bucket: Rails.application.config.app_snapshots_bucket,
    #   key_path: "googleplay/snapshots/#{id}/screenshots.json.gz",
    # ))
  end
end
