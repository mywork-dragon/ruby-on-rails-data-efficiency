class BusinessEntityService

  class << self

    # For Ios linking

    # Use for `associate_newest_snapshot`
    def ios_by_app_id(method_name)
        IosApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
            li "Batch #{index}"
            ios_app_ids = batch.map{|ia| ia.id}.select{ |ia| ia.present?}

            BusinessEntityIosServiceWorker.perform_async(ios_app_ids, method_name)
        end
    end

    # Use for `clean_ios`
    def ios_by_snapshot_id(method_name)
        IosApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
            li "Batch #{index}"
            ios_app_snapshot_ids = batch.map{|ia| ia.newest_ios_app_snapshot_id}.select{ |ia| ia.present?}

            BusinessEntityIosServiceWorker.perform_async(ios_app_snapshot_ids, method_name)
        end
    end

    # For new apps every week
    # @author Jason Lew
    def ios_new_apps
      batch = Sidekiq::Batch.new
      batch.description = "ios_new_apps" 
      batch.on(:complete, 'BusinessEntityService#on_complete_ios_new_apps')
  
      batch.jobs do
        epf_full_feed_last = EpfFullFeed.last
    
        newest_date = IosAppEpfSnapshot.order('itunes_release_date DESC').limit(1).first.itunes_release_date
        week_before_newest = newest_date - 6.days


        IosAppEpfSnapshot.where(epf_full_feed: epf_full_feed_last, itunes_release_date: week_before_newest..newest_date).find_each.with_index do |epf_ss, index| 
          
          app_identifer = epf_ss.application_id
          
          ios_app = IosApp.find_by_app_identifier(app_identifer)
          
          if ios_app
            ss = ios_app.newest_ios_app_snapshot

            BusinessEntityIosServiceWorker.perform_async([ss.id], 'clean_ios') if ss
          end
        
        end
    
      end
      
    end

    # For Android linking

    # Use for `associate_newest_snapshot_android`, `unlink_android_without_dev_id`, `dupe_count`, `check_for_existence`
    def android_by_app_id
        AndroidApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
          li "Batch #{index}"
          android_app_ids = batch.map{|aa| aa.id}.select{ |aa| aa.present?}

          BusinessEntityAndroidServiceWorker.perform_async(android_app_ids)
        end
    end

    # Use for `clean_android`
    def android_by_snapshot_id
      AndroidApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        android_app_snapshot_ids = batch.map{|aa| aa.newest_android_app_snapshot_id}.select{ |aa| aa.present?}

        BusinessEntityAndroidServiceWorker.perform_async(android_app_snapshot_ids)
      end
    end


    # Use for `delete_duplicates_android`
    def dupe_search
      Dupe.where('count > 1').find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"      
        dupe_ids = batch.map{|dupe| dupe.id}.select{ |dupe_id| dupe_id.present?}
        BusinessEntityAndroidServiceWorker.perform_async(dupe_ids)
      end
    end
    
    def android_apps_with_char(char)
      AndroidApp.where(taken_down: nil).joins(:newest_android_app_snapshot).where("android_app_snapshots.name LIKE ?", "%#{char}%").find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"      
        aa_ids = batch.map{|aa| aa.id}.select{ |aa_id| aa_id.present?}
        BusinessEntityAndroidServiceWorker.perform_async(aa_ids)
      end
    end

    def ios_apps_with_char(char)
      IosApp.select(:id).joins(:newest_ios_app_snapshot).where("ios_app_snapshots.name LIKE ?", "%#{char}%").find_each do |batch, index|
        li "Batch #{index}"      
        ia_ids = batch.map{|ia| ia.id}.select{ |ia_id| ia_id.present?}
        # BusinessEntityIosServiceWorker.perform_async(ia_ids)
      end
    end

    def company_by_id
      Company.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"      
        co_ids = batch.map{|co| co.id}.select{ |co_id| co_id.present?}
        BusinessEntityCompanyServiceWorker.perform_async(co_ids)
      end
    end


# IosApp.joins(:newest_ios_app_snapshot).where("ios_app_snapshots.name LIKE ?", "%?%").limit(10).each{ |a| puts "https://itunes.apple.com/us/app/id#{a.app_identifier}" }

# AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.name LIKE ?", "%?%")


# IosApp.select(:id).joins(:newest_ios_app_snapshot).where("ios_app_snapshots.name LIKE ?", "%?%")












    # def run_ios_test(company)
    #     ids = []
    #     IosApp.joins(ios_apps_websites: {website: :company}).where('companies.id = ?', company).each do |a|
    #         ids << a.newest_ios_app_snapshot_id if a.newest_ios_app_snapshot_id.present?
    #     end
    #     BusinessEntityIosServiceWorker.new.perform(ids)
    # end

    # def run_ios_by_id_test(company)
    #     ids = []
    #     IosApp.joins(ios_apps_websites: {website: :company}).where('companies.id = ?', company).each do |a|
    #         ids << a.id if a.id.present?
    #     end
    #     BusinessEntityIosServiceWorker.new.perform(ids)
    # end

    # def run_ios_by_app_id
    #   IosApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
    #     li "Batch #{index}"
    #     ios_app_ids = batch.map{|ia| ia.id}.select{ |ia| ia.present?}

    #     BusinessEntityIosServiceWorker.perform_async(ios_app_ids)
    #   end
    # end

    # def run_android_by_app_id
    #   AndroidApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
    #     li "Batch #{index}"
    #     android_app_ids = batch.map{|aa| aa.id}.select{ |aa| aa.present?}

    #     BusinessEntityAndroidServiceWorker.perform_async(android_app_ids)
    #   end
    # end

    # def run_android_by_id_from_company(company)
    #     ids = []
    #     AndroidApp.joins(android_apps_websites: {website: :company}).where('companies.id = ?', company).each do |a|
    #         ids << a.id if a.id.present?
    #     end
    #     associate_newest_snapshot_android(ids)
    #     # delete_duplicate_android_apps(ids)
    # end

    # def run_android_from_company(company)
    #     ids = []
    #     AndroidApp.joins(android_apps_websites: {website: :company}).where('companies.id = ?', company).each do |a|
    #         ids << a.newest_android_app_snapshot_id if a.newest_android_app_snapshot_id.present?
    #     end
    #     clean_android(ids)
    # end

    # def run_ios_by_app
    #   IosApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
    #     li "Batch #{index}"
    #     ios_app_snapshot_ids = batch.map{|ia| ia.newest_ios_app_snapshot_id}.select{ |ia| ia.present?}

    #     BusinessEntityIosServiceWorker.perform_async(ios_app_snapshot_ids)
    #   end
    # end

    # def run_android_by_app
    #   AndroidApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
    #     li "Batch #{index}"
    #     android_app_snapshot_ids = batch.map{|ia| ia.newest_android_app_snapshot_id}.select{ |ia| ia.present?}

    #     BusinessEntityIosServiceWorker.perform_async(android_app_snapshot_ids)
    #   end
    # end
  
    # def run_ios(ios_app_snapshot_job_ids)
    #   IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_ids).find_in_batches(batch_size: 1000).with_index do |batch, index|
    #     li "Batch #{index}"
    #     ios_app_snapshot_ids = batch.map{|ias| ias.id}
        
    #     BusinessEntityIosServiceWorker.perform_async(ios_app_snapshot_ids)
    #   end
    # end
    
    # def run_android(android_app_snapshot_job_ids)
    #   AndroidAppSnapshot.where(android_app_snapshot_job_id: android_app_snapshot_job_ids).find_in_batches(batch_size: 1000).with_index do |batch, index|
    #     li "Batch #{index}"
    #     android_app_snapshot_ids = batch.map{|aas| aas.id}
        
    #     BusinessEntityAndroidServiceWorker.perform_async(android_app_snapshot_ids)
    #   end
    # end









    
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

    def run_ios_branch_job_8_12
      newest_date = IosAppEpfSnapshot.where(epf_full_feed: EpfFullFeed.find(1)).order('itunes_release_date DESC').limit(1).first.itunes_release_date
      week_before_newest = newest_date - 6.days

      IosAppEpfSnapshot.where(epf_full_feed: EpfFullFeed.find(1), itunes_release_date:  week_before_newest..newest_date).find_in_batches(batch_size: 1000).with_index do |batch, index|
         
        ios_app_ss_ids = batch.map{ |ios_app_epf_ss| IosApp.find_by_app_identifier(ios_app_epf_ss.application_id)}.select{ |ios_app| ios_app.present? }.map{ |ios_app| ios_app.newest_ios_app_snapshot }.select{ |ios_app_ss| ios_app_ss.present?}.map(&:id)
        BusinessEntityIosServiceWorker.perform_async(ios_app_ss_ids, 'clean_ios')
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

    def on_complete_ios_new_apps(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'ios_new_apps')

    # EpfService.generate_weekly_newest_csv   #Step 5
  end

end