class BusinessEntityIosServiceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :ios_web_scrape

  def perform(ids, method_name)
    m = method_name.to_sym
    send(m, ids)
  end

  def clean_ios(ios_app_snapshot_ids)

    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.find_by_id(ios_app_snapshot_id)
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
          # puts "known dev id present"
          if ss_dasi == known_dev_id
            # puts "known dev id match"
            websites_to_remove = ios_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            ios_app.websites.delete(websites_to_remove)
            # puts "website: #{website.url}"
            # puts "company: #{company.name}"
            link_co_and_web(website: website, company: company)
            link_ios_and_web(ios_app: ios_app, website: website)
            puts ios_app.websites
          else
            unlink_ios_and_web(ios_app: ios_app, website: website)
          end
        else
          # puts "not a known dev id"
          if website.company.present? && website.company.app_store_identifier.present? && website.company.app_store_identifier != ss_dasi && !f1000
            # puts "id doesn't match"
            unlink_ios_and_web(ios_app: ios_app, website: website)
          end
        
          if company.present?
            # puts "dasi match"
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
      begin
        ios_app.websites << website
      rescue ActiveRecord::RecordInvalid => e
      end
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
end
