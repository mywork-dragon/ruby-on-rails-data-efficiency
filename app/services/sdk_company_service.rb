class SdkCompanyService
  
  class << self

    def all_companies_sync

      SdkCompany.all.each.with_index do |com, index|
        li "app #{index}"
        SdkCompanyServiceWorker.new.perform(com.id)
      end

    end

  	def find
        AndroidApp.where("newest_apk_snapshot_id IS NOT NULL").find_each.with_index do |app, index|
          li "app #{index}"
          SdkCompanyServiceWorker.perform_async(app.id)
        end
  	end

    def duplicate_fix
      SdkCompany.all.each.with_index do |com, index|
        li "app #{index}"
        SdkCompanyServiceWorker.perform_async(com.id)
      end
    end

  	def google_check
  		SdkCompany.where('website IS NULL AND alias_website IS NULL AND flagged IS false').find_each.with_index do |com, index|
  			li "app #{index}"
        SdkCompanyServiceWorker.perform_async(com.id)
  		end
  	end

    def favicon_fix
      AndroidSdkCompany.where(favicon: nil).each.with_index do |com, index|
        li "app #{index}"
        SdkCompanyServiceWorker.perform_async(com.id)
      end
    end

    # def favicon_fix
    #   SdkCompany.where('website IS NOT NULL AND favicon IS NULL').each.with_index do |com, index|
    #     li "app #{index}"
    #     SdkCompanyServiceWorker.perform_async(com.id)
    #   end
    # end


    # ------------


    def change_company_name(name:, new_name:)

      sdk_com = SdkCompany.find_by_name(name)

      if sdk_com.present?
        sdk_com.alias_name = new_name
        sdk_com.save
      end

      puts "Company name has been changed from '#{name}' to '#{new_name}'"

    end

    def change_company_website(name:, new_website:)

      sdk_com = SdkCompany.find_by_name(name)

      if sdk_com.present?
        sdk_com.alias_website = new_website
        sdk_com.save
      end

      puts "Company name has been changed from '#{sdk_com.website}' to '#{new_website}'"

    end

    def flag_company(name:, id:)

      if name.present?
        sdk_com = SdkCompany.find_by_name(name)
      elsif id.present?
        sdk_com = SdkCompany.find_by_id(id)
      end

      sdk_com.flagged = true

      sdk_com.save

      puts "#{name} has been flagged"

    end

    def unflag_company(name:)

      sdk_com = SdkCompany.find_by_name(name)

      sdk_com.flagged = false

      sdk_com.save

      puts "#{name} has been unflagged"

    end

  end

end