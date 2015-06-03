class ApkService

  class << self

    # def get

    # ActiveRecord::Base.logger.level = 1

    #   AndroidApp.select(:id, :app_identifier).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).each do |app|
    #     download_apk(app.id)
    #   end
    # end

    def download_apk(android_app_id)
      google_accounts_id, email, password, android_id = optimal_account()

      start_time = Time.now()

      ApkDownloader.configure do |config|
        config.email = email
        config.password = password
        config.android_id = android_id
      end

      app_identifier = AndroidApp.select(:app_identifier).where(id: android_app_id)[0]["app_identifier"]

      file_name = "data/apk_files/" + app_identifier + ".apk"
      print "\nDownloading #{app_identifier}..."

      begin
        ApkDownloader.download! app_identifier, file_name
      rescue Exception => e
        puts e
      else
        print "success"

        end_time = Time.now()
        download_time = (end_time - start_time).to_s
        puts " ( " + download_time + " sec ) "

        PackageSearchService.search(app_identifier, google_accounts_id, android_app_id, download_time)

        begin
          File.delete(file_name)
        rescue Exception => e
          puts e
        end

      end

    end

    def optimal_account()
      accounts = []
      ga = GoogleAccount.select(:id).where(blocked: false).each
      for account in ga
        accounts << ApkSnapshots.where(google_accounts: account.id).where("updated_at > ?", DateTime.now - 1).count
      end
      best_account = GoogleAccount.where(id: ga.to_a[accounts.each_with_index.min[1].to_i].id)[0]
      return best_account["id"], best_account["email"], best_account["password"], best_account["android_id"]
    end

  end

end
