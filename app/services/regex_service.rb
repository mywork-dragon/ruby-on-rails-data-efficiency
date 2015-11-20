class RegexService

  class << self

    def populate_regex
      companies = JSON.parse(File.open('../../Desktop/regexes.json').read)
      companies.each do |company, data|
        sdk_company = SdkCompany.find_or_create_by(name: company)
        data.each do |sdk, sdk_data|
          android_sdk = AndroidSdk.create(name: sdk, website: sdk_data['website'], open_source: sdk_data['open_source'])
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
          SdkPackage.create(package: package, android_sdk_id: regex.android_sdk_id)
          # also need to create a join table between snapshots packages
        end
      end
    end

  end

end