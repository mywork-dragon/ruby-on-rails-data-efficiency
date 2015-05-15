class BusinessEntityAndroidServiceWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: false
 
  def perform(android_snapshot_ids)
    android_snapshot_ids.each do |android_snapshot_id|
      ss = AndroidAppSnapshot.find(android_snapshot_id)
      android_app = ss.android_app

      return if ss.nil?

      if c = Company.find_by_google_play_identifier(ss.developer_google_play_identifier) && !c.websites.empty?
        primary_website = c.websites.first
        
        if !android_app.websites.include?(primary_website)
          android_app.websites << primary_website 
          android_app.save
        end
        
        next  #go to the next app
      end

      #start looking at url if identifier didn't match

      url = ss.seller_url

      next if url.blank?

      if UrlHelper.secondary_site?(url)
        kind = :secondary
      else
        url = UrlHelper.url_with_http_and_domain(url)
        kind = :primary
      end

      w = Website.find_by_url(url)

      if w.nil?
        c = Company.find_by_google_play_identifier(ss.developer_google_play_identifier)
        c = Company.create(name: I18n.transliterate(ss.seller), google_play_identifier: ss.developer_google_play_identifier) if c.nil?
        w = Website.create(url: url, company: c, kind: kind)
      elsif w.company.nil?
        w.company = Company.create(name: I18n.transliterate(ss.seller), google_play_identifier: ss.developer_google_play_identifier)
        w.save
      end

      android_app.websites << w unless android_app.websites.include?(w)
      android_app.save

    end
  end
  
end