class IosDeveloper < ActiveRecord::Base

  belongs_to :company
  has_many :ios_apps
  
  has_many :ios_developers_websites
  has_many :websites, through: :ios_developers_websites

  has_many :valid_ios_developer_websites, -> { where(is_valid: true)}, class_name: 'IosDevelopersWebsite'
  has_many :valid_websites, through: :valid_ios_developer_websites, source: :website

  has_one :app_developers_developer, -> { where 'app_developers_developers.flagged' => false }, as: :developer
  has_one :app_developer, through: :app_developers_developer

  has_many :developer_link_options

  def get_website_urls
    self.websites.pluck(:url).uniq
  end

  def sorted_ios_apps(category, order, page)
    filter_args = {
      app_filters: {'publisherId' => self.id},
      page_size: 100,
      page_num: [page.to_i, 1].max,
      sort_by: category || 'last_updated',
      order_by: order || 'desc'
    }
    
    filter_results = FilterService.filter_ios_apps(filter_args)

    ids = filter_results.map { |result| result.attributes["id"] }
    results = ids.any? ? IosApp.where(id: ids).order("FIELD(id, #{ids.join(',')})") : []
    return results, filter_results.total_count
  end

  def headquarters
    headquarters = []
    valid_websites.joins(:domain_datum).select('domain_data.*, websites.url').each do |website|
      next unless website.country_code
      headquarters << {
        domain: website.domain,
        street_number: website.street_number,
        street_name: website.street_name,
        sub_premise: website.sub_premise,
        city: website.city,
        postal_code: website.postal_code,
        state: website.state,
        state_code: website.state_code,
        country: website.country,
        country_code: website.country_code,
        lat: website.lat,
        lng: website.lng
      }
    end
    headquarters.uniq
  end
end
