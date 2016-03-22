class NewBusinessEntityService

  class << self
    
    def ios_app_snapshot_ids
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

    def create_android_developers
      batch = Sidekiq::Batch.new
      batch.description = "Create android developer objects"
      batch.on(:complete, "NewBusinessEntityService#on_complete")
      AndroidApp.where(android_developer_id: nil).find_in_batches(batch_size: 10000).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*10000}"
          args = the_batch.map{ |android_app| [:create_developers, android_app.id, 'android'] }
          Sidekiq::Client.push_bulk('class' => CreateDevelopersWorker, 'args' => args)
        end
      end
    end

    def create_ios_developers
      batch = Sidekiq::Batch.new
      batch.description = "Create ios developer objects"
      batch.on(:complete, "NewBusinessEntityService#on_complete")
      IosApp.where(ios_developer_id: nil).find_in_batches(batch_size: 10000).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*10000}"
          args = the_batch.map{ |ios_app| [:create_developers, ios_app.id, 'ios'] }
          Sidekiq::Client.push_bulk('class' => CreateDevelopersWorker, 'args' => args)
        end
      end
    end

    def dedupe_ios_developers
      IosDeveloper.pluck(:identifier).group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first).each do |identifier|
        CreateDevelopersWorker.perform_async(:dedupe_developers, identifier, 'ios')
      end
    end

    def dedupe_android_developers
      AndroidDeveloper.pluck(:identifier).group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first).each do |identifier|
        CreateDevelopersWorker.perform_async(:dedupe_developers, identifier, 'android')
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Created developer objects')
  end

end