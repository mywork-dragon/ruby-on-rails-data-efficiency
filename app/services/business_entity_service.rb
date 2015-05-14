class BusinessEntityService

  class << self
  
    def run_ios(ios_app_snapshot_job_ids)
      IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_ids).find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        ios_app_snapshot_ids = batch.map{|ias| ias.id}
        
        BusinessEntityIosServiceWorker.perform_async(ios_app_snapshot_ids)
      end
    end
    
    def run_android(android_app_snapshot_job_ids)
      AndroidAppSnapshot.where(android_app_snapshot_job_id: android_app_snapshot_job_ids).find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        android_app_snapshot_ids = batch.map{|aas| aas.id}
        
        BusinessEntityAndroidServiceWorker.perform_async(android_app_snapshot_ids)
      end
    end
    
    # special purpose
    def run_ios_remove_f1000
      IosApp.includes(:newest_ios_app_snapshot, websites: :company).joins(websites: :company).where('companies.fortune_1000_rank <= ?', 1000).find_each.with_index do |ios_app, index|
        li "##{index}: IosApp id=#{ios_app.id}"
        
        ios_app.ios_apps_websites.delete_all
      end
    end
    
    # special purpose
    def run_ios_fix_f1000
      #get ids from CSV
      ios_app_ids = []
      
      CSV.foreach('db/fortune_1000_to_repop.csv', headers: true) do |row|
        ios_app_ids << row[0].to_i
      end
      
      li ios_app_ids
      
      ios_app_ids.each_with_index do |ios_app_id, index|
        li "App #{index}, id=#{ios_app_id}"
        
        BusinessEntityIosFixFortune1000Worker.perform_async(ios_app_id)
        
      end
    end
    
    # special purpose
    def delete_all_companies_with_google_play_identifier
      cs_gp = Company.where.not(google_play_identifier: nil)
      count = cs.gp.count
      
      cs_gp.each_with_index do |c, index|
        
        puts "Company #{index + 1} of #{count}"
        
        c.websites.each do |w|
          w.delete
        end
        
      end
      
    end
  
    
  
  end

end