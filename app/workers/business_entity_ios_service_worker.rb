class BusinessEntityIosServiceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(ids)
    # method_name.to_sym
    # send(method_name, ids)
    # associate_newest_snapshot_android(ids)
    clean_android(ids)
  end

  def reassosciate_empty_snapshots(ios_app_ids)
    ios_app_ids.each do |ios_app_id|
      ia = IosApp.find(ios_app_id)
      return if ia.nil?

      unless ia.newest_ios_app_snapshot.present?
        ss_id = IosAppSnapshot.find_by_ios_app_id(ia.id).id
        ia.newest_ios_app_snapshot_id = ss_id
        ia.save
      end
    end
  end

  def associate_newest_snapshot(ios_app_ids)
    ios_app_ids.each do |ios_app_id|
      ia = IosApp.find(ios_app_id)
      return if ia.nil?
      newest_snapshot = ia.ios_app_snapshots.select{|ss| ss.name.present?}.max_by{|ss| ss.ios_app_snapshot_job_id}
      if newest_snapshot.present?
        ia.newest_ios_app_snapshot = newest_snapshot
        ia.save
      end
    end
  end

  def associate_newest_snapshot_android(android_app_ids)
    android_app_ids.each do |android_app_id|
      aa = AndroidApp.find(android_app_id)
      return if aa.nil?
      newest_snapshot = aa.android_app_snapshots.select{|ss| ss.name.present?}.max_by{|ss| ss.android_app_snapshot_job_id}
      if newest_snapshot.present?
        aa.newest_android_app_snapshot = newest_snapshot
        aa.save
      end
    end
  end


  def fix_popular_website(ios_app_snapshot_ids)

    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.includes(ios_app: :websites).find(ios_app_snapshot_id)
      return if ss.nil?
      
      ios_app = ss.ios_app
    
      urls = ss.ios_app.websites.map{ |site| site.url }
      
      urls = urls.map{|url| UrlHelper.url_with_http_and_domain(url)}
      
      urls.each do |url|

        next if url.nil?

        known_dev_id = UrlHelper.known_website(url) 

        ss_dasi = ss.developer_app_store_identifier
        
        website = Website.find_or_create_by(url: url)

        if known_dev_id.present?
          if ss_dasi != known_dev_id
            unlink_ios_and_web(ios_app: ios_app, website: website)
          end
        end
      end
    end
  end

  def link_android_and_web(android_app:, website:)
    if !android_app.websites.include?(website)
      android_app.websites << website
    end
  end

  def unlink_android_and_web(android_app:, website:)
    if android_app.websites.include?(website)
      android_app.websites.delete(website)
    end
  end





  def clean_android(android_app_snapshot_ids)

    android_app_snapshot_ids.each do |android_app_snapshot_id|
    
      ss = AndroidAppSnapshot.find(android_app_snapshot_id)
      return if ss.nil?
      
      android_app = ss.android_app
    
      #linking logic for support and seller urls
      urls = [ss.seller_url, ss.support_url].select{ |url| url.present? }.map{|url| UrlHelper.url_with_http_and_domain(url)}
      
      urls = urls.map{|url| UrlHelper.url_with_http_and_domain(url)}
      
      urls.each do |url|    
        # puts url
        next if url.nil?

        known_dev_id = UrlHelper.known_website_android(url) 

        ss_dasi = ss.developer_google_play_identifier
        
        next if ss_dasi.blank? #skip if no developer identifier
        
        company = Company.find_by_google_play_identifier(ss_dasi)

        website = Website.find_or_create_by(url: url)

        f1000 = website.company.present? && website.company.fortune_1000_rank.present?  #f1000 is a boolean

        if known_dev_id.present?
          # puts"known dev id present"
          if ss_dasi == known_dev_id
            # puts"known dev id match"
            websites_to_remove = android_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            android_app.websites.delete(websites_to_remove)
            # puts"website: #{website.url}"
            # puts"company: #{company.name}"
            link_co_and_web(website: website, company: company)
            link_android_and_web(android_app: android_app, website: website)
            # putsandroid_app.websites
          else
            unlink_android_and_web(android_app: android_app, website: website)
          end
        else
          # puts"not a known dev id"
          if website.company.present? && website.company.google_play_identifier.present? && website.company.google_play_identifier != ss_dasi && !f1000
            # puts"id doesn't match"
            unlink_android_and_web(android_app: android_app, website: website)
          end
        
          if company.present?
            # puts"dasi match"
            # putscompany.name
            # putsurl
            websites_to_remove = android_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            android_app.websites.delete(websites_to_remove)

            link_co_and_web(website: website, company: company)
            link_android_and_web(android_app: android_app, website: website)
          end
        
          if website.company.blank?
            websites_to_remove = android_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            android_app.websites.delete(websites_to_remove)
            new_co = Company.create(name: ss.seller, google_play_identifier: ss_dasi)
            link_co_and_web(website: website, company: new_co)
            link_android_and_web(android_app: android_app, website: website)
          end

        end
      end
      
      # cleanse app's existing websites linked to app, that may have been unlisted from support / seller url on snapshot
      websites = android_app.websites.select{|w| urls.exclude?(w.url)}
      websites.each do |website|
        known_dev_id = UrlHelper.known_website(website.url)
        ss_dasi = ss.developer_google_play_identifier
        company = website.company
        
        known_dev_dasi_mismatch = known_dev_id.present? && ss_dasi != known_dev_id
        company_dasi_mismatch = company.present? && company.google_play_identifier.present? && company.google_play_identifier != ss_dasi
        if known_dev_dasi_mismatch || company_dasi_mismatch
          unlink_android_and_web(android_app: android_app, website: website)
        end
      end
      
      
    end
  end

  def link_android_and_web(android_app:, website:)
    if !android_app.websites.include?(website)
      android_app.websites << website
    end
  end

  def unlink_android_and_web(android_app:, website:)
    if android_app.websites.include?(website)
      android_app.websites.delete(website)
    end
  end






  def clean_ios(ios_app_snapshot_ids)

    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.find(ios_app_snapshot_id)
      return if ss.nil?
      
      ios_app = ss.ios_app
    
      #linking logic for support and seller urls
      urls = [ss.seller_url, ss.support_url].select{ |url| url.present? }.map{|url| UrlHelper.url_with_http_and_domain(url)}
      
      urls = urls.map{|url| UrlHelper.url_with_http_and_domain(url)}
      
      urls.each do |url|    
        # puts url
        next if url.nil?

        known_dev_id = UrlHelper.known_website(url) 

        ss_dasi = ss.developer_app_store_identifier
        
        next if ss_dasi.blank? #skip if no developer identifier
        
        company = Company.find_by_app_store_identifier(ss_dasi)

        website = Website.find_or_create_by(url: url)

        f1000 = website.company.present? && website.company.fortune_1000_rank.present?  #f1000 is a boolean

        if known_dev_id.present?
          puts "known dev id present"
          if ss_dasi == known_dev_id
            puts "known dev id match"
            websites_to_remove = ios_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            ios_app.websites.delete(websites_to_remove)
            puts "website: #{website.url}"
            puts "company: #{company.name}"
            link_co_and_web(website: website, company: company)
            link_ios_and_web(ios_app: ios_app, website: website)
            puts ios_app.websites
          else
            unlink_ios_and_web(ios_app: ios_app, website: website)
          end
        else
          puts "not a known dev id"
          if website.company.present? && website.company.app_store_identifier.present? && website.company.app_store_identifier != ss_dasi && !f1000
            puts "id doesn't match"
            unlink_ios_and_web(ios_app: ios_app, website: website)
          end
        
          if company.present?
            puts "dasi match"
            puts company.name
            puts url
            websites_to_remove = ios_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            ios_app.websites.delete(websites_to_remove)

            link_co_and_web(website: website, company: company)
            link_ios_and_web(ios_app: ios_app, website: website)
          end
        
          if website.company.blank?
            websites_to_remove = ios_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            ios_app.websites.delete(websites_to_remove)
            new_co = Company.create(name: ss.seller, app_store_identifier: ss_dasi)
            link_co_and_web(website: website, company: new_co)
            link_ios_and_web(ios_app: ios_app, website: website)
          end

        end
      end
      
      # cleanse app's existing websites linked to app, that may have been unlisted from support / seller url on snapshot
      websites = ios_app.websites.select{|w| urls.exclude?(w.url)}
      websites.each do |website|
        known_dev_id = UrlHelper.known_website(website.url)
        ss_dasi = ss.developer_app_store_identifier
        company = website.company
        
        known_dev_dasi_mismatch = known_dev_id.present? && ss_dasi != known_dev_id
        company_dasi_mismatch = company.present? && company.app_store_identifier.present? && company.app_store_identifier != ss_dasi
        if known_dev_dasi_mismatch || company_dasi_mismatch
          unlink_ios_and_web(ios_app: ios_app, website: website)
        end
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