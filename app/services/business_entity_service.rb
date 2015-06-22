class BusinessEntityService

  class << self

    def run_ios_test(company)
        ids = []
        IosApp.joins(ios_apps_websites: {website: :company}).where('companies.id = ?', company).each do |a|
            ids << a.newest_ios_app_snapshot_id if a.newest_ios_app_snapshot_id.present?
        end
        BusinessEntityIosServiceWorker.new.perform(ids)
    end

    def run_ios_by_id_test(company)
        ids = []
        IosApp.joins(ios_apps_websites: {website: :company}).where('companies.id = ?', company).each do |a|
            ids << a.id if a.id.present?
        end
        BusinessEntityIosServiceWorker.new.perform(ids)
    end

    def run_ios_by_app_id
      IosApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        ios_app_ids = batch.map{|ia| ia.id}.select{ |ia| ia.present?}

        BusinessEntityIosServiceWorker.perform_async(ios_app_ids)
      end
    end

    def run_android_by_app_id(method_name)
      AndroidApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        android_app_ids = batch.map{|aa| aa.id}.select{ |aa| aa.present?}

        BusinessEntityAndroidServiceWorker.perform_async(android_app_ids, method_name)
      end
    end

    def run_ios_by_app
      IosApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        ios_app_snapshot_ids = batch.map{|ia| ia.newest_ios_app_snapshot_id}.select{ |ia| ia.present?}

        BusinessEntityIosServiceWorker.perform_async(ios_app_snapshot_ids)
      end
    end
  
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
    # Do not use this unless you know what you're doing!!!
    def delete_all_companies_with_google_play_identifier
      cs_gp = Company.where.not(google_play_identifier: nil)
      count = cs_gp.count
      
      cs_gp.each_with_index do |c, index|
        
        puts "Company #{index + 1} of #{count}"
        
        c.websites.each do |w|
          w.delete
        end
        
        c.delete
        
      end
      
    end
    
    def hard_code_gpi
      ids = %w(
        3057
        2733
        2889
        2640
        5279
        8568
        4642
        3360
        11291
        2111
        9666
        424
        1467
        3418
        3645
        224
        23235
        3336
        2785
        12797
        29093
        27298
        34493
        47267
        23898
        11329
        3707
        22236
        7435
        22264
        8110
        7714
        14638
        2405
        56660
        1219
        3895
        69113
        23423
        96787
        2910
        6782
        710
        80468
        25407
      )
      
      gpis = %w(
        Google+Inc.
        Fiserv+Solutions,+Inc.
        Gannett
        Facebook
        Oracle+America,+Inc.
        Yahoo
        Microsoft+Corporation
        Hewlett+Packard+Development+Company,+L.P.
        AT%26T+Services,+Inc.
        Disney
        ELECTRONIC+ARTS
        Amazon+Mobile+LLC
        Cisco+Systems,+Inc.
        IBM+Collaboration+Solutions
        Intel+Corporation
        Adobe
        MasterCard
        Honeywell+International,+Inc.
        Ford+Motor+Co.
        Pfizer+Inc.
        U.S.+Bank+Mobile
        Tribune+Broadcasting+Company+LLC
        Hasbro+Inc.
        John+Deere
        3M+Company
        Symantec+Corporation
        Intuit+Inc
        Mattel
        Trimble+Navigation
        Avaya+Incorporated
        Xerox
        Verizon+-+VZ
        American+Express
        EMC+Corporation
        FirstEnergy+Service+Company
        CA+Technologies,+Inc
        Juniper+Networks+Inc.+and+Affiliates
        Parker+Hannifin+Corporation
        Eastman+Kodak+Company
        SYNNEX+Corporation
        General+Electric++Company
        State+Farm+Insurance
        Autodesk+Inc.
        Kimberly-Clark+Corporation
        DIRECTV,+LLC
      )
      
      ids.each_with_index do |id, index|
        c = Company.find(id)
        c.google_play_identifier = gpis[index]
        c.save!
      end
    end
  
  end

end