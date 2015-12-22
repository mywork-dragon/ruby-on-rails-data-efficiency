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
          AndroidSdk.create!(new_row)
        else
          new_row[:name] = "DUPLICATE:#{previous.id}:#{new_row[:id]}"
          AndroidSdk.create!(new_row)
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
      AndroidSdkCompaniesApkSnapshot.find_each.with_index do |row, index|
        ap "Moving id #{index} after #{Time.now - s} seconds" if index % 1000 == 0
        new_row = {
          android_sdk_id: row.android_sdk_company_id,
          apk_snapshot_id: row.apk_snapshot_id
        }
        AndroidSdksApkSnapshot.create!(new_row)
      end
      ap "Completed after #{Time.now - s} seconds"
    end


  end
end

# create_table "android_sdk_companies", force: true do |t|
#   t.string   "name"
#   t.string   "website"
#   t.string   "favicon"
#   t.boolean  "flagged",           default: false
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.boolean  "open_source",       default: false
#   t.integer  "parent_company_id"
#   t.boolean  "is_parent"
# end

# create_table "android_sdks", force: true do |t|
#   t.string   "name"
#   t.string   "website"
#   t.string   "favicon"
#   t.boolean  "flagged",                default: false
#   t.boolean  "open_source"
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.integer  "sdk_company_id"
#   t.integer  "github_repo_identifier"
# end

