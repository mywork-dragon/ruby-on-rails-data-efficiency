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
end
