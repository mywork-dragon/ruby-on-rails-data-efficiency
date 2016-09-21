class IosDeveloper < ActiveRecord::Base

  belongs_to :company
  has_many :ios_apps
  
  has_many :ios_developers_websites
  has_many :websites, through: :ios_developers_websites  

  has_one :app_developers_developer, -> { where 'app_developers_developers.flagged' => false }, as: :developer
  has_one :app_developer, through: :app_developers_developer

  has_many :developer_link_options

  def get_website_urls
    self.websites.map{|w| w.url}
  end

  def sorted_ios_apps(category, order, page)
    page = [page.to_i, 1].max
    category ||= 'lastUpdated'
    order ||= 'DESC'
    query = "includes(:ios_developer, :ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(:newest_ios_app_snapshot).where('ios_app_snapshots.name IS NOT null')."
    query += FilterService.ios_sort_order_query(category, order)
    self.ios_apps.instance_eval("self.#{query}").limit(100).offset((page - 1) * 100)
  end
end
