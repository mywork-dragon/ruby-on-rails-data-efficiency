# == Schema Information
#
# Table name: websites
#
#  id           :integer          not null, primary key
#  url          :string(191)
#  created_at   :datetime
#  updated_at   :datetime
#  kind         :integer
#  company_id   :integer
#  ios_app_id   :integer
#  match_string :string(191)
#  domain       :string(191)
#

class Website < ActiveRecord::Base

  class BadFormat; end

  belongs_to :company
  # belongs_to :ios_app TODO: This relationship exists in DB Remove if deprecated

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

  before_create :populate_helper_fields

  def populate_helper_fields
    set_match_string
    set_domain
  end

  def set_match_string
    result = self.class.website_comparison_format(url)
    self.match_string = result unless result == BadFormat
  end

  def set_domain
    uri = URI.parse(url)
    if uri.class == URI::Generic
      uri = URI.parse('http://' + url) # give it a scheme for proper parsing
    end

    self.domain = uri.host.gsub(/^www\./, '').downcase
  rescue URI::InvalidURIError
    nil
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
