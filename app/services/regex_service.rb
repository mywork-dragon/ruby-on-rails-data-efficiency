class RegexService

  class << self

    # also need to link sdk_companies to android and ios sdks

    def populate_regex
      companies = JSON.parse(File.open('regexes.json').read)
      companies.each do |company, data|
        sdk_company = SdkCompany.find_or_create_by(name: company)
        data.each do |sdk, sdk_data|
          android_sdk = AndroidSdk.create_with(website: sdk_data['website'], open_source: sdk_data['open_source'], sdk_company_id: sdk_company.id).find_or_create_by(name: sdk)
          sdk_data['regexes'].each do |regex|
            sr = SdkRegex.find_or_create_by(regex: regex)
            sr.android_sdk_id = android_sdk.id
            sr.save
          end
        end
      end
    end


    def delete_android_sdks_packages_and_companies
      puts "Are you sure you want to do this? [yes/no]"
      a = gets.chomp
      if a == 'yes'
        # clear android_sdks
        AndroidSdk.delete_all
        AndroidSdksApkSnapshot.delete_all
        AndroidSdk.connection.execute('ALTER TABLE android_sdks AUTO_INCREMENT = 1;')
        AndroidSdksApkSnapshot.connection.execute('ALTER TABLE android_sdks_apk_snapshots AUTO_INCREMENT = 1;')

        # clear sdk_packages
        SdkPackage.where(ios_sdk_id: nil).where.not(android_sdk_id: nil).each(&:delete)
        SdkPackage.where.not(ios_sdk_id: nil, android_sdk_id: nil).each{ |x| x.android_sdk_id = nil; x.save }
        SdkPackagesApkSnapshot.delete_all

        # clear sdk_companies
        SdkCompany.delete_all
        SdkCompany.connection.execute('ALTER TABLE sdk_companies AUTO_INCREMENT = 1;')

        # reset regexes
        populate_regex
      else
        puts "Nothing will be deleted."
      end
    end

  end

end