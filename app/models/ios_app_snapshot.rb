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
