class AndroidDeveloper < ActiveRecord::Base
  
  belongs_to :company
  has_many :android_apps

  has_many :android_developers_websites
  has_many :websites, through: :android_developers_websites

  has_one :app_developers_developer, -> { where 'app_developers_developers.flagged' => false }, as: :developer
  has_one :app_developer, through: :app_developers_developer

  has_many :valid_android_developer_websites, -> { where(is_valid: true)}, class_name: 'AndroidDevelopersWebsite'
  has_many :valid_websites, through: :valid_android_developer_websites, source: :website

  def get_website_urls
    self.websites.map{|w| w.url}
  end

  def sorted_android_apps(category, order, page)
    filter_args = {
      app_filters: {'publisherId' => self.id},
      page_size: 100,
      page_num: [page.to_i, 1].max,
      sort_by: category || 'last_updated',
      order_by: order || 'desc'
    }
     
    filter_results = FilterService.filter_android_apps(filter_args)

    ids = filter_results.map { |result| result.attributes["id"] }
    results = ids.any? ? AndroidApp.where(id: ids).order("FIELD(id, #{ids.join(',')})") : []
    return results, filter_results.total_count
  end

  def headquarters
    headquarters = []
    valid_websites.each do |website|
      data = website.domain_datum
      next unless data && data.country_code
      headquarters << {
        domain: data.domain,
        street_number: data.street_number,
        street_name: data.street_name,
        sub_premise: data.sub_premise,
        city: data.city,
        postal_code: data.postal_code,
        state: data.state,
        state_code: data.state_code,
        country: data.country,
        country_code: data.country_code,
        lat: data.lat,
        lng: data.lng
      }
    end
    headquarters.uniq
  end
end
