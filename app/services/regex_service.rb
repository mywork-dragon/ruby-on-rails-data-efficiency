class RegexService

  class << self

    # also need to link sdk_companies to android and ios sdks

    def populate_regex
      companies = JSON.parse(File.open('../../Documents/regexes.json').read)
      companies.each do |company, data|
        sdk_company = SdkCompany.find_or_create_by(name: company)
        data.each do |sdk, sdk_data|
          android_sdk = AndroidSdk.create(name: sdk, website: sdk_data['website'], open_source: sdk_data['open_source'], sdk_company_id: sdk_company.id)
          sdk_data['regexes'].each do |regex|
            SdkRegex.create(regex: regex, android_sdk_id: android_sdk.id)
          end
        end
      end
    end


    def match_regexes(packages = [])
      packages.each do |package|
        match_regex(package)
      end
    end


    def match_regex(package)
      SdkRegex.all.each do |regex|
        if !!(package =~ /#{regex.regex}/i)
          sdk_package = SdkPackage.create(package: package, android_sdk_id: regex.android_sdk_id)
          SdkPackageApkSnapshot.create(sdk_package_id: sdk_package.id, android_sdk_id: regex.android_sdk_id)
        end
      end
    end

  end

end