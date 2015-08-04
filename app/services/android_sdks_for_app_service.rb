class AndroidSdksForAppService
  
  class << self
    
    def sdks_hash(android_app_id)
      aa = AndroidApp.find(android_app_id)

      if aa.newest_apk_snapshot.blank?

        ai = aa.app_identifier

        j = ApkSnapshotJob.create!(notes: ai)

        batch = Sidekiq::Batch.new
        batch.jobs do
          ApkSnapshotServiceSingleWorker.perform_async(j.id, android_app_id)
        end
        bid = batch.bid

        360.times do |i|
          break if Sidekiq::Batch::Status.new(bid).complete?
          sleep 0.25
        end

        new_snap = AndroidApp.find(android_app_id).newest_apk_snapshot

      else

        new_snap = aa.newest_apk_snapshot

      end

      if new_snap.present? && new_snap.status == "success"

        p = new_snap.android_packages.where('android_package_tag != 1')

        hash = clean_up_android_sdks(p)

      else
        hash = nil
      end

      # HANDLE NIL CASE!!!!!!!
    
      hash
    end
    
    def clean_up_android_sdks(p)
      hash = Hash.new

      if p.present?
        p.each do |packages|
        
          package = " " + packages.package_name

          [' com.',' net.',' org.',' edu.',' eu.',' io.',' ui.',' .'].each{|u| package.slice! u}

          name = package.split('.')[0].strip

          if name.count("0-9").zero? && name.exclude?("android")

            name = name.capitalize

            if hash[name].blank?
              hash[name] = [packages.package_name]
            else
              hash[name] << packages.package_name
            end

          end
        end
      end

      hash

    end
  

  end

end