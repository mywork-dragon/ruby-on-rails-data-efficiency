class CleanDataService

	class << self

    def delete_duplicate_android_apps

      AndroidApp.group(:app_identifier).having('count(*) > 1').each do |app|

        CleanDataServiceWorker.new.(app.app_identifier)

      end

    end

	end

end