class AndroidMigrationService

  class << self

    def empty_new_tables

      ap "Empty the new android tables: AndroidSdk, AndroidSdksApkSnapshot, SdkPackage, SdkPackagesApkSnapshot SdkCompany ? [yes/no]"
      a = gets.chomp
      if a == 'yes'
        AndroidSdk.delete_all
        AndroidSdk.connection.execute('ALTER TABLE android_sdks AUTO_INCREMENT = 1;')

        ap "Done with AndroidSdk"

        AndroidSdksApkSnapshot.delete_all
        AndroidSdksApkSnapshot.connection.execute('ALTER TABLE android_sdks_apk_snapshots AUTO_INCREMENT = 1;')

        ap "Done with AndroidSdksApkSnapshot"

        SdkPackage.delete_all
        SdkPackage.connection.execute('ALTER TABLE sdk_packages AUTO_INCREMENT = 1;')

        ap "Done with SdkPackage"

        SdkPackagesApkSnapshot.delete_all
        SdkPackagesApkSnapshot.connection.execute('ALTER TABLE sdk_packages_apk_snapshots AUTO_INCREMENT = 1;')

        ap "Done with SdkPackagesApkSnapshot"

        SdkCompany.delete_all
        SdkCompany.connection.execute('ALTER TABLE sdk_companies AUTO_INCREMENT = 1;')

        ap "Done with SdkCompany"
      end
    end

    def migrate_sdks
      s = Time.now
      AndroidSdkCompany.find_each.with_index do |company, index|
        ap "Moving id #{index} after #{Time.now - s} seconds" if index % 1000 == 0
        new_row = company_to_sdk_row(company)

        previous = AndroidSdk.where(name: new_row[:name]).take
        if previous.nil?
          AndroidSdk.create!(new_row.merge({kind: :native}))
        else
          new_row[:name] = "DUPLICATE:#{previous.id}:#{new_row[:id]}"
          AndroidSdk.create!(new_row.merge({kind: :native}))
        end
      end
      ap "Completed after #{Time.now - s} seconds"
    end

    def company_to_sdk_row(company)
      {
        id: company.id,
        name: company.name,
        website: company.website,
        favicon: company.favicon,
        flagged: company.flagged,
        open_source: company.open_source,
      }
      # move created at information?
    end

    def migrate_snapshots


      s = Time.now
      if Rails.env.production?
        AndroidSdkCompaniesApkSnapshot.find_each.with_index do |row, index|
          ap "Queueing id #{index} after #{Time.now - s} seconds" if index % 1000 == 0
          AndroidMigrationSnapshotWorker.perform_async(row.id)
        end

        ap "Completed queueing after #{Time.now - s} seconds"
      else

        AndroidSdkCompaniesApkSnapshot.find_each.with_index do |row, index|
          ap "Queueing id #{index} after #{Time.now - s} seconds" if index % 1000 == 0
          AndroidMigrationSnapshotWorker.new.perform(row.id)
        end

        ap "Completed after #{Time.now - s} seconds"
      end
    end

    def fix_attributions

      s = Time.now
      if Rails.env.production?
        AndroidSdk.where("name like 'DUPLICATE:%'").find_each.with_index do |sdk, index|
          ap "Queueing id #{index} after #{Time.now - s} seconds"
          AndroidMigrationAttributionWorker.perform_async(sdk.id)
        end
      else
        AndroidSdk.where("name like 'DUPLICATE:%'").find_each.with_index do |sdk, index|
          ap "Queueing id #{index} after #{Time.now - s} seconds"
          AndroidMigrationAttributionWorker.new.perform(sdk.id)
        end
      end

      ap "Completed after #{Time.now - s} seconds"
    end

    def reset_regexes(try_linking: true)
      SdkRegex.where.not(android_sdk_id: nil).find_each.with_index do |row, index|
        row.update(android_sdk_id: nil)
        
        fit = AndroidSdk.where(name: row.regex).take
        if fit.present? && try_linking
          ap fit
          ap row
          puts "Potential Match Found. Link them? [y/n]"
          a = gets.chomp
          if a == 'y'
            row.update(android_sdk_id: fit.id)
          end
        end
      end
    end

  end
end