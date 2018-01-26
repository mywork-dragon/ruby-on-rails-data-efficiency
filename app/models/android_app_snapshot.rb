class AndroidAppSnapshot < ActiveRecord::Base

  belongs_to :android_app
  belongs_to :android_app_snapshot_job  
  has_many :android_app_snapshot_exceptions

  has_many :android_app_snapshots_scr_shts, -> {order(position: :asc)}
  has_many :android_app_categories_snapshots
  has_many :android_app_categories, through: :android_app_categories_snapshots
  
  enum status: [:failure, :success]

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

  def screenshot_urls
    JSON.parse(MightyAws::S3.new.retrieve(
      bucket: Rails.application.config.app_snapshots_bucket,
      key_path: "googleplay/snapshots/#{id}/screenshots.json.gz",
    ))
  end
end
