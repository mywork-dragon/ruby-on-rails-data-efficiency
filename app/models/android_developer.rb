class AndroidDeveloper < ActiveRecord::Base
  
  validates :identifier, uniqueness: true
  
  belongs_to :company
  has_many :android_apps

  has_many :android_developers_websites
  has_many :websites, through: :android_developers_websites

  def get_website_urls
    self.websites.map{|w| w.url}
  end

  def sorted_android_apps(category, order, page)
    page = [page.to_i, 1].max
    category ||= 'lastUpdated'
    order ||= 'DESC'
    query = "includes(:android_developer, :android_fb_ad_appearances, newest_android_app_snapshot: :android_app_categories, websites: :company).joins(:newest_android_app_snapshot).where('android_app_snapshots.name IS NOT null')."
    query += FilterService.android_sort_order_query(category, order)
    self.android_apps.instance_eval("self.#{query}").limit(100).offset((page - 1) * 100)
  end
end
