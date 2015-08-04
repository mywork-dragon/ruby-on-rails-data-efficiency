class SdkCompanyService
  
  class << self


  	def find
        AndroidApp.where("newest_apk_snapshot_id IS NOT NULL").each.with_index do |app, index|
          li "app #{index}"
          SdkCompanyServiceWorker.perform_async(app.id)
        end
  	end

  	def google_check
  		SdkCompany.each.with_index do |com, index|
  			li "app #{index}"
        SdkCompanyServiceWorker.perform_async(com.id)
  		end
  	end


  end

end