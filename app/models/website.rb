class Website < ActiveRecord::Base

  class BadFormat; end

  belongs_to :company
  
  has_many :ios_apps_websites
  has_many :ios_apps, through: :ios_apps_websites

  has_many :android_apps_websites
  has_many :android_apps, through: :android_apps_websites

  has_many :ios_developers_websites
  has_many :ios_developers, through: :ios_developers_websites

  has_many :android_developers_websites
  has_many :android_developers, through: :android_developers_websites

  has_one :domain_datum, through: :websites_domain_datum
  has_one :websites_domain_datum

  has_many :clearbit_contacts

  enum kind: [:primary, :secondary]
  
  validates :url, presence: true

  before_create :set_match_string

  def set_match_string
    result = self.class.website_comparison_format(url)
    self.match_string = result unless result == BadFormat
  end

  class << self

    def website_comparison_format(url)
      regex = %r{(?:https?://)?(?:www\.)?([^\s\?]+)}
      match = regex.match(url)
      return BadFormat unless match
      url_format = match[1]
      result = DbSanitizer.truncate_string(url_format)
      result.gsub(%r{/+\z}, '') # remove trailing slash if no path
    end

  end

end
