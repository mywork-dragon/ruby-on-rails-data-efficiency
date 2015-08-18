class IosAppSnapshot < ActiveRecord::Base

  has_many :ios_app_snapshots_languages
  has_many :ios_app_languages, through: :ios_app_snapshots_languages
  
  belongs_to :ios_app
  belongs_to :ios_app_snapshot_job
  has_many :ios_app_categories_snapshots
  has_many :ios_app_categories, through: :ios_app_categories_snapshots

  has_many :ios_app_snapshot_exceptions
  
  enum status: [:failure, :success]

  update_index('apps#ios_app_snapshot') {self} # updates Elasticsearch index upon changes to IosAppSnapshot

  def get_company_name
    company = IosApp.where(:newest_ios_app_snapshot_id => self.id).first.get_company
    puts "###"
    puts company.inspect
    if company.nil?
      return ""
    else
      return company.name
    end
  end
end
