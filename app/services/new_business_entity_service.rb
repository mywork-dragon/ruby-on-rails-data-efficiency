class NewBusinessEntityService

  class << self
    
    def ios_app_snapshot_ids
      ids = []
      
      # https://github.com/MightySignal/varys/issues/154
      ids << IosAppSnapshot.find(1819705)
      
      #https://github.com/MightySignal/varys/issues/155
      #https://github.com/MightySignal/varys/issues/157
      ids << IosAppSnapshot.find(2909066)
      
      #https://github.com/MightySignal/varys/issues/156
      ids << IosAppSnapshot.find(2909501)
      
      #https://github.com/MightySignal/varys/issues/158
      ids << IosAppSnapshot.find(2909093)
      
      #https://github.com/MightySignal/varys/issues/159
      ids << IosAppSnapshot.find(2909535)
      
      # ids += IosAppSnapshot.where.not(name: nil).limit(50)
      # ids += IosAppSnapshot.where.not(name: nil).order('created_at DESC').limit(50)
      
      ids
    end
    
    def write_csv_line(csv: nil, ios_app_snapshot_id: nil, ios_app_snapshot_seller_url: nil, ios_app_snapshot_support_url: nil, website_id: nil, website_url: nil, company_id: nil, company_website: nil, ios_app_id: nil)
      line = [ios_app_snapshot_id, ios_app_snapshot_seller_url, ios_app_snapshot_support_url, website_id, website_url, company_id, company_website, ios_app_id]
      puts line.to_s
      csv << line
    end

    def run_ios
      
      csv = CSV.generate(col_sep: "\t") do |csv|
        
        csv << ['ios_app_snapshot.id', 'ios_app_snapshot.seller_url', 'ios_app_snapshot.support_url', 'website.id', 'website.url', 'company.id', 'company.website' 'company.url', 'ios_app.id']
        
        ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
          ss = IosAppSnapshot.find(ios_app_snapshot_id)
          ios_app = ss.ios_app
      
          if ss.nil?
            return
          end
    
          if dasi = ss.developer_app_store_identifier
            c = Company.find_by_app_store_identifier(dasi)

            if c && !c.websites.empty?
              primary_website = c.websites.first
        
              if !ios_app.websites.include?(primary_website)
                ios_app.websites << primary_website 
                #ios_app.save
              end
            
              write_csv_line(csv: csv, ios_app_snapshot_id: ss.id, ios_app_snapshot_seller_url: ss.seller_url, ios_app_snapshot_support_url: ss.support_url, website_id: primary_website.id, website_url: primary_website.url, company_id: (c ? c.id : nil), company_website: (c ? c.website : nil), ios_app_id: ios_app.id)
              
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
              #c = Company.create(name: ss.seller, app_store_identifier: ss.developer_app_store_identifier) if c.nil?
              #w = Website.create(url: url, company: c, kind: kind)
            elsif w.company.nil?
              #w.company = Company.create(name: ss.seller, app_store_identifier: ss.developer_app_store_identifier)
              #w.save
            elsif !w.company.app_store_identifier.blank?  
              skip_save = true
              next
            end
        
            ios_app.websites << w if !skip_save && !ios_app.websites.include?(w)
            #ios_app.save
            
            write_csv_line(csv: csv, ios_app_snapshot_id: ss.id, ios_app_snapshot_seller_url: ss.seller_url, ios_app_snapshot_support_url: ss.support_url, website_id: w.id, website_url: w.url, company_id: (c ? c.id : nil), company_website: (c ? c.website : nil), ios_app_id: ios_app.id)
        
          end
      
        end
        
      end
      
      puts "\n\n"
      
      print csv
      nil
      
    end
    
    def run_ios_new
      
      ios_app_snapshot_ids.each do |ss|
        
        ss = IosAppSnapshot.find(ios_app_snapshot_id)
        ios_app = ss.ios_app
        
        next if ss.nil?
        
        # 1. Link all apps to developer by by developer ID.
        if dasi = ss.developer_app_store_identifier
          
          ios_developer = IosDeveloper.find_by_identifier(developer_app_store_identifier)
          
          # Create a new developer if it doesn't exit
          if ios_developer.nil?
            ios_developer = IosDeveloper.create(identifier: dasi, name: )
            
          end
          
          c = Company.find_by_app_store_identifier(dasi)

          if c && !c.websites.empty?
            primary_website = c.websites.first
      
            if !ios_app.websites.include?(primary_website)
              ios_app.websites << primary_website 
              #ios_app.save
            end
          end
        end 
        
      end
      
    end
    
    def thresh
      #input: count of other apps for same snapshot with same developer ID with the same website
      
       
      
    end
    
  end

end