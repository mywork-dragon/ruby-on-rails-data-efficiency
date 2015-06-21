class BusinessEntityIosServiceWorker
  include Sidekiq::Worker
  
  sidekiq_options :queue => :critical
  sidekiq_options retry: false

  def perform(ios_app_snapshot_ids)
    stephens_thing(ios_app_snapshot_ids)
  end

  def stephens_thing(ios_app_snapshot_ids)

    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.find(ios_app_snapshot_id)
      return if ss.nil?
      
      ios_app = ss.ios_app
    
      # urls = [ss.seller_url, ss.support_url].select{ |url| url.present? }

      urls = ss.ios_app.websites.map{ |site| site.url }
      
      urls = urls.map{|url| UrlHelper.url_with_http_and_domain(url)}
      
      urls.each do |url|

        # url = UrlHelper.url_with_http_and_domain(url)
        
        #will be a number greater than 0 (known site, dev id for site), a 0(known site, no dev id known for site), or a nil (not known site)

        next if url.nil?

        known_dev_id = UrlHelper.known_website(url) 

        ss_dasi = ss.developer_app_store_identifier
        
        next if ss_dasi.blank? #skip if no developer identifier
        
        company = Company.find_by_app_store_identifier(ss_dasi)

        website = Website.find_or_create_by(url: url)

        f1000 = website.company.present? && website.company.fortune_1000_rank.present?  #f1000 is a boolean


        if known_dev_id.present?
          if ss_dasi == known_dev_id
            websites_to_remove = ios_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            ios_app.websites.delete(websites_to_remove)
            link_co_and_web(website: website, company: company)
            link_ios_and_web(ios_app: ios_app, website: website)
          else
            unlink_ios_and_web(ios_app: ios_app, website: website)
          end
        end
        # elsif website.company.present? && website.company.app_store_identifier.present? && website.company.app_store_identifier != ss_dasi && !f1000
        #   unlink_ios_and_web(ios_app: ios_app, website: website)

        # elsif company.present?
        #   websites_to_remove = ios_app.websites.to_a.select{|site| urls.exclude?(site.url)}
        #   ios_app.websites.delete(websites_to_remove)
          
        #   link_co_and_web(website: website, company: company)
        #   link_ios_and_web(ios_app: ios_app, website: website)
 
        # elsif website.company.blank?
        #   websites_to_remove = ios_app.websites.to_a.select{|site| urls.exclude?(site.url)}
        #   ios_app.websites.delete(websites_to_remove)
        #   new_co = Company.create(name: ss.seller, app_store_identifier: ss_dasi)
        #   link_co_and_web(website: website, company: new_co)
        #   link_ios_and_web(ios_app: ios_app, website: website)
        # end
        
      end
    end
  end

  def link_ios_and_web(ios_app:, website:)
    if !ios_app.websites.include?(website)
      ios_app.websites << website
    end
  end

  def unlink_ios_and_web(ios_app:, website:)
    if ios_app.websites.include?(website)
      ios_app.websites.delete(website)
    end
  end

  def link_co_and_web(website:, company:)
    website.company = company
    website.save
  end














  def jasons_thing(ios_app_snapshot_ids)

    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.find(ios_app_snapshot_id)
      ios_app = ss.ios_app
      
      return if ss.nil?
    
      if dasi = ss.developer_app_store_identifier
        c = Company.find_by_app_store_identifier(dasi)

        if c && !c.websites.empty?
          primary_website = c.websites.first
        
          if !ios_app.websites.include?(primary_website)
            ios_app.websites << primary_website 
            ios_app.save
          end
        
          next  #go to the next app
        end
      end
    
      urls = [ss.seller_url, ss.support_url].select{|url| url}
      
      urls.each do |url|
        if UrlHelper.secondary_site?(url)
          kind = :secondary
        else
          url = UrlHelper.url_with_http_and_domain(url)
          kind = :primary
        end
        
        w = Website.find_by_url(url)
        
        if w.nil?
          c = Company.find_by_app_store_identifier(ss.developer_app_store_identifier)
          c = Company.create(name: ss.seller, app_store_identifier: ss.developer_app_store_identifier) if c.nil?
          w = Website.create(url: url, company: c, kind: kind)
        elsif w.company.nil?
          w.company = Company.create(name: ss.seller, app_store_identifier: ss.developer_app_store_identifier)
          w.save
        elsif !w.company.app_store_identifier.blank?  
          next
        end
        
        ios_app.websites << w if !ios_app.websites.include?(w)
        ios_app.save
        
      end
      
    end

  end
  
end